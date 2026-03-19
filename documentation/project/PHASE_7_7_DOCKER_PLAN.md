# Phase 7.7: Docker & Container Security — Evaluation & Implementation Plan

**Created:** 2026-03-18
**Status:** Evaluated — ready for implementation
**Parent:** [Phase 7 — Quality & Hardening](PHASE_QUALITY_HARDENING_PLAN.md)

---

## Context

Phase 7.7 audits the 3 Dockerfiles, `docker-compose.yml`, 3 `.dockerignore` files, and container build steps in CI/CD deploy workflows. Docker image SHA pinning was explicitly deferred here from phases 7.3, 7.4, 7.5, and 7.6.

**Overall assessment:** Container infrastructure is in good shape — all 3 Dockerfiles use multi-stage builds, non-root users, and HEALTHCHECK instructions. The `.dockerignore` files are comprehensive. Findings are hardening improvements, not critical vulnerabilities. The "Light effort" classification is accurate.

---

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | No SHA pinning on base images across all 3 Dockerfiles | MEDIUM | Track 1 |
| 2 | Backend runtime uses Debian `aspnet:8.0` + installs `curl` for healthcheck (~20 MB overhead); Alpine available | MEDIUM | Track 2 |
| 3 | CMS Dockerfile uses `npm install` instead of `npm ci` (non-reproducible builds) | MEDIUM | Track 3 |
| 4 | `docker-compose.yml` has deprecated `version: '3.8'` field | LOW | Track 4 |
| 5 | CMS `.dockerignore` missing `.git/`, IDE, OS file exclusions | LOW | Track 4 |

## Accepted Risks

| # | Finding | Rationale |
|---|---------|-----------|
| A | docker-compose hardcoded dev passwords (`YourStrong@Passw0rd`, `strapiPassword123`, local Strapi secrets) | Dev-only containers, no network exposure. Already accepted in 7.5. Replacing with `.env` adds friction with no security benefit. |
| B | ACR Basic SKU — no vulnerability scanning | Already accepted in 7.5. Standard SKU ($20/mo) not justified at current scale. |
| C | No BuildKit `--mount=type=cache` in CI | Ephemeral runners; multi-stage layers already effective. Marginal gain (~10-15s) not worth complexity. |
| D | CMS healthcheck uses BusyBox `wget` | Alpine includes BusyBox `wget` — works correctly as-is. |

## Deferred

| Item | Phase | Rationale |
|------|-------|-----------|
| `:latest` rollback bug | 7.6 Track 2c | CI/CD concern, already planned |
| Container image signing (Notary/Cosign) | 8+ | Over-engineering at current scale |

---

## Track 1: Base Image SHA Pinning (All 3 Dockerfiles)

**Effort:** ~15 min | **Risk:** None — same image, immutable reference

**Files:**
- `Dockerfile` — lines 7, 17, 43 (3 `FROM` lines, all `node:20-alpine`)
- `backend/Dockerfile` — lines 7, 28 (`dotnet/sdk:8.0`, `dotnet/aspnet:8.0`)
- `cms/Dockerfile` — lines 2, 38 (2 `FROM` lines, both `node:20-alpine`)

### Problem
All `FROM` lines use mutable tags. A tag can be re-published to point at a different digest — supply chain risk where a compromised upstream image silently enters the build.

### Implementation
Pin each `FROM` to the current digest, keeping the tag as a comment:

```bash
# Look up digests at implementation time
docker pull node:20-alpine && docker inspect --format='{{index .RepoDigests 0}}' node:20-alpine
docker pull mcr.microsoft.com/dotnet/sdk:8.0 && docker inspect --format='{{index .RepoDigests 0}}' mcr.microsoft.com/dotnet/sdk:8.0
docker pull mcr.microsoft.com/dotnet/aspnet:8.0-alpine && docker inspect --format='{{index .RepoDigests 0}}' mcr.microsoft.com/dotnet/aspnet:8.0-alpine
```

Format: `FROM node:20-alpine@sha256:<64-char-hex> AS deps`

**Note:** Phase 7.6 Track 3 adds `.github/dependabot.yml` with a `docker` ecosystem entry. Once implemented, Dependabot auto-opens PRs when new digests are published — keeps pins current without manual effort.

### Verification
- `docker build -t test-frontend .` succeeds
- `docker build -t test-backend .` succeeds (from `backend/`)
- `docker build -t test-cms --target production .` succeeds (from `cms/`)

**Commit:** `fix: pin Docker base images to SHA digests for supply chain security (Phase 7.7)`

---

## Track 2: Backend Alpine Migration — Remove curl Dependency

**Effort:** ~15 min | **Risk:** Low — `aspnet:8.0-alpine` is first-class Microsoft image

**File:** `backend/Dockerfile` — lines 28, 32, 34-35, 50-51

### Problem
Line 35 installs `curl` via `apt-get` solely for the healthcheck (line 51). This adds ~20 MB and a `apt-get` attack surface. Switching the runtime base to `aspnet:8.0-alpine` (a) eliminates the `curl`/`apt-get` layer, (b) reduces image size ~50% (~220 MB → ~110 MB), (c) uses BusyBox `wget` for healthcheck (already present in Alpine).

### Implementation
Replace lines 28-35 and 50-51:

```dockerfile
# Stage 2: Runtime (Alpine — smaller image, BusyBox wget for healthcheck)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine@sha256:<digest> AS runtime
WORKDIR /app

# Create non-root user (Alpine syntax)
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Copy published app from build stage
COPY --from=build /app/publish .
```

Healthcheck change:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1
```

**Key changes:**
1. `aspnet:8.0` (Debian) → `aspnet:8.0-alpine` (Alpine)
2. `groupadd`/`useradd` → `addgroup -S`/`adduser -S` (Alpine BusyBox)
3. `apt-get install -y curl && rm -rf /var/lib/apt/lists/*` deleted entirely
4. `curl -f` → `wget -qO-` (BusyBox wget, pre-installed)

**Note:** Alpine uses `musl` instead of `glibc`. ASP.NET Core 8 officially supports Alpine. This app has no native library dependencies that would cause musl issues.

### Verification
- `docker build -t test-backend .` succeeds (from `backend/`)
- `docker run -d --name test-be -p 8080:8080 test-backend && curl http://localhost:8080/health` → "Healthy"
- `docker inspect test-be` shows healthcheck passing
- `docker images test-backend` — size < 150 MB (was ~240 MB)
- `dotnet test` — 105/105 backend tests still pass (app code unchanged)

**Commit:** `perf: switch backend to Alpine runtime, remove curl dependency (~50% smaller) (Phase 7.7)`

---

## Track 3: CMS Dockerfile — Use npm ci

**Effort:** ~2 min | **Risk:** None — stricter install

**File:** `cms/Dockerfile` — line 8

### Problem
Line 8 uses `npm install` which can modify `package-lock.json` and produce non-reproducible builds. `npm ci` installs exactly what the lockfile specifies and fails on inconsistency. (The frontend Dockerfile already uses `npm ci` correctly.)

### Implementation
```dockerfile
# Before (line 8):
RUN npm install

# After:
RUN npm ci
```

### Verification
- `docker build -t test-cms --target production .` succeeds (from `cms/`)

**Commit:** `fix: use npm ci in CMS Dockerfile for reproducible builds (Phase 7.7)`

---

## Track 4: Compose & Dockerignore Cleanup

**Effort:** ~5 min | **Risk:** None

**Files:**
- `docker-compose.yml` — line 1
- `cms/.dockerignore`

### Problem A: Deprecated version field
`version: '3.8'` is ignored by Compose v2 and emits a deprecation warning. Remove it.

### Problem B: CMS .dockerignore gaps
Only 10 lines. Missing `.git/`, IDE dirs, OS files. While the CMS build context is `./cms` (small), these exclusions prevent unnecessary context transfer.

### Implementation

**docker-compose.yml** — delete line 1 (`version: '3.8'`).

**cms/.dockerignore** — replace with:
```
node_modules
.tmp
.cache
dist
build
*.log
.env
.env.*
!.env.example
public/uploads

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Git
.git/
.gitignore

# Docs
*.md
```

### Verification
- `docker compose config` parses without deprecation warning
- `docker compose --profile cms up -d` starts all services
- `docker compose --profile cms down`

**Commit:** `chore: remove deprecated compose version, improve CMS .dockerignore (Phase 7.7)`

---

## Track 5: Documentation (Decision 53)

**Effort:** ~10 min | **Risk:** None

**Files:**
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — add Decision 53
- `documentation/project/ROADMAP.md` — update 7.7 status
- `CLAUDE.md` — update Docker notes (Alpine backend, SHA pinning)

### Implementation
- **Decision 53:** "Phase 7.7 — Docker & Container Security Hardening" — SHA pinning (supply chain), Alpine backend runtime (50% smaller, no curl), `npm ci` (reproducibility). Alternatives rejected: Distroless (no shell for healthcheck debugging), Chainguard (over-engineering).
- **ROADMAP:** 7.7 → "Evaluated — implementation plan ready"
- **CLAUDE.md:** Update backend Dockerfile notes (Alpine, no curl), note SHA-pinned base images

**Commit:** `docs: add Phase 7.7 decision and update roadmap (Phase 7.7)`

---

## Execution Order

1. **Track 3** — CMS `npm ci` (smallest, zero risk, quick win)
2. **Track 4** — Compose + .dockerignore cleanup (housekeeping)
3. **Track 1** — SHA pinning (all 3 Dockerfiles — pull digests first)
4. **Track 2** — Backend Alpine migration (most impactful — test thoroughly)
5. **Track 5** — Documentation (last, references all completed tracks)

---

## Verification Checklist

- [ ] All `FROM` lines in 3 Dockerfiles contain `@sha256:` digests
- [ ] `docker build` succeeds for frontend, backend, CMS (production target)
- [ ] Backend runtime is `aspnet:8.0-alpine` (not Debian)
- [ ] Backend image has no `curl` or `apt-get` layer
- [ ] Backend image size < 150 MB
- [ ] Backend healthcheck passes (`wget -qO-`)
- [ ] CMS Dockerfile uses `npm ci` (not `npm install`)
- [ ] `docker-compose.yml` has no `version:` field
- [ ] `cms/.dockerignore` includes `.git/`, IDE, OS exclusions
- [ ] `docker compose config` parses without warnings
- [ ] 105/105 backend tests pass
- [ ] 390/390 frontend tests pass
- [ ] Decision 53 added to TECHNICAL_DECISIONS_LOG.md
- [ ] ROADMAP.md 7.7 updated
- [ ] CLAUDE.md Docker references updated
