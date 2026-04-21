# Dependabot PR Sweep — 21 Open PRs

## Context

21 Dependabot PRs have accumulated on `main` (dates 2026-03-19 to 2026-04-20). They split cleanly into three groups:

- **7 PRs** propose major version jumps that conflict with stated policy (Decision 35 in TECHNICAL_DECISIONS_LOG.md: defer Swashbuckle, tailwind/eslint/next-auth majors to Phase 8) or target non-LTS versions (Node 25 is odd-numbered STS, .NET 10 not yet a planned migration while 8 LTS runs until Nov 2026). These will keep re-appearing every month unless `.github/dependabot.yml` gains explicit ignore rules.
- **12 PRs** are patch/minor bumps inside the LTS lines already in use (.NET 8.0.25→8.0.26, Next 16.2.0→16.2.1, storybook 10.3.0→10.3.1, action v-bumps). CI (`test.yml`) gates them — if they break, the PR check fails.
- **2 PRs** bump CMS dependencies (`cms/`) which have no CI gate (CMS is local-only per Phase CMS Cold Storage). They need local verification.

Goal: clear the queue, lock the policy into `dependabot.yml` so the same PRs don't regenerate, and log the decision.

---

## PR Triage Matrix

### Batch A — Close + add ignore rules (7 PRs)

| # | Title | Reason |
|---|-------|--------|
| #2 | aspnet 8.0-alpine → 10.0-alpine (`backend/Dockerfile`) | .NET 8 LTS (Nov 2026); .NET 10 migration is its own project |
| #10 | dotnet/sdk 8.0 → 10.0 (`backend/Dockerfile`) | Same as #2 |
| #3 | node 20-alpine → 25-alpine (`cms/Dockerfile`) | Node 25 is odd-numbered (non-LTS); target is Node 22 LTS |
| #4 | node 20-alpine → 25-alpine (root `Dockerfile`) | Same as #3 |
| #20 | typescript 5.9.3 → 6.0.2 (root) | TS 6 is a major; Decision 35 defers frontend majors to Phase 8 |
| #25 | typescript 5.9.3 → 6.0.3 (`cms/`) | Same as #20 |
| #22 | Swashbuckle.AspNetCore 6.9.0 → 10.1.7 | Decision 35 explicitly defers Swashbuckle updates beyond 6.9.0 |

### Batch B — Merge on green CI (12 PRs)

| # | Title | Scope |
|---|-------|-------|
| #5 | azure/login SHA update | GitHub Actions |
| #6 | actions/checkout 4.2.2 → 6.0.2 | GitHub Actions |
| #7 | actions/upload-artifact 4.6.2 → 7.0.0 | GitHub Actions |
| #8 | actions/setup-dotnet 4.3.1 → 5.2.0 | GitHub Actions |
| #9 | actions/setup-node 4.4.0 → 6.3.0 | GitHub Actions |
| #11 | storybook group 10.3.0 → 10.3.1 (patch) | Frontend devDeps |
| #14 | xunit.runner.visualstudio 2.8.2 → 3.1.5 | Backend tests |
| #16 | eslint-config-next 16.2.0 → 16.2.1 (patch) | Frontend devDeps |
| #17 | next 16.2.0 → 16.2.1 (patch) | Frontend |
| #19 | isomorphic-dompurify 3.5.1 → 3.7.1 | Frontend |
| #26 | dotnet-servicing group 8.0.25 → 8.0.26 (9 pkgs) | Backend |
| #27 | ef-core group 8.0.25 → 8.0.26 (6 pkgs) | Backend |

### Batch C — Local verification then merge (2 PRs)

| # | Title | Why special |
|---|-------|-------------|
| #23 | esbuild 0.24.2 → 0.28.0 (`cms/`) | CMS has no CI gate; Strapi native deps can fail silently |
| #24 | better-sqlite3 11.10.0 → 12.9.0 (`cms/`) | Same — major version on a native binding |

---

## Step-by-Step Execution

### Step 1 ✅ — Extend `.github/dependabot.yml` with ignore rules

File: `.github/dependabot.yml`

Add the following ignore entries. Existing ignores (tailwind/eslint/next-auth majors, Strapi react majors, Microsoft.* major, coverlet.* major) stay as-is; we are adding alongside.

**Root npm** (existing `ignore:` block, add entries):
```yaml
- dependency-name: "typescript"
  update-types: ["version-update:semver-major"]
```

**CMS npm** (existing `ignore:` block, add entries):
```yaml
- dependency-name: "typescript"
  update-types: ["version-update:semver-major"]
```

**Backend NuGet** (existing `ignore:` block, add entry):
```yaml
- dependency-name: "Swashbuckle.AspNetCore"
  update-types: ["version-update:semver-major"]
```

**Docker (root)** — if no `ignore:` yet, add one:
```yaml
ignore:
  - dependency-name: "node"
    update-types: ["version-update:semver-major"]
```

**Docker (backend)** — add:
```yaml
ignore:
  - dependency-name: "mcr.microsoft.com/dotnet/sdk"
    update-types: ["version-update:semver-major"]
  - dependency-name: "mcr.microsoft.com/dotnet/aspnet"
    update-types: ["version-update:semver-major"]
```

**Docker (cms)** — add:
```yaml
ignore:
  - dependency-name: "node"
    update-types: ["version-update:semver-major"]
```

Commit this change on its own branch (`chore/dependabot-pin-lts-majors`) and merge after `test.yml` passes. This locks the policy *before* we close the PRs — so they won't immediately regenerate.

Also log the decision in `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` as Decision 66: "Pin Dependabot to LTS/current major lines (Node 20, .NET 8, TypeScript 5, Swashbuckle 6)."

### Step 2 ✅ — Close Batch A PRs (7 PRs)

For each PR in Batch A, post a short comment and close:

```bash
for pr in 2 3 4 10 20 22 25; do
  gh pr close $pr --comment "Closing — major-version bumps deferred per Decision 35. Ignore rule added to .github/dependabot.yml in <commit-sha>."
done
```

Do NOT use `@dependabot ignore` comments — those create hidden state outside the repo. The explicit rules in `dependabot.yml` are the source of truth.

### Step 3 ✅ — Merge Batch B in order (12 PRs)

**Blocker encountered and resolved:** All PRs had failing `Frontend Tests` due to CVE GHSA-q4gf-8mx6-v5v3 — `next 16.0.0–16.2.2` flagged HIGH severity by `npm audit --omit=dev --audit-level=high`. Fixed in PR #28 (commit 475b120) by bumping to `next@16.2.4`. PRs #16 and #17 (targeting still-vulnerable `16.2.1`) were closed instead of merged.

**Actual execution (deviations from plan noted):**

| # | Action | Outcome |
|---|--------|---------|
| #28 | Security prereq: merged `chore/dependabot-pin-lts-majors` with next→16.2.4 fix | ✅ Merged |
| #5 | azure/login SHA | ✅ Merged |
| #8 | actions/setup-dotnet 4→5 | ✅ Merged |
| #6 | actions/checkout 4→6 | ✅ Merged |
| #7 | actions/upload-artifact 4→7 | ✅ Applied manually (Dependabot auto-closed after #28 merge) |
| #9 | actions/setup-node 4→6 | ✅ Applied manually (same reason) |
| #26 | dotnet-servicing 8.0.26 | ✅ Merged (also included ef-core packages) |
| #27 | ef-core 8.0.26 | ✅ Auto-closed by Dependabot ("no longer updatable" — packages already in #26) |
| #14 | xunit.runner.visualstudio 2→3 | ✅ Merged |
| #17 | next 16.2.1 | ✅ Closed (would downgrade from 16.2.4 to vulnerable 16.2.1) |
| #16 | eslint-config-next 16.2.1 | ✅ Closed (same reason) |
| #11 | storybook 10.3.1 | ✅ Merged |
| #19 | isomorphic-dompurify 3.7.1 | ✅ Superseded by #36 (3.9.0); closed |
| #36 | isomorphic-dompurify 3.9.0 (new) | ✅ Merged |

**Additional new PRs from Dependabot sweep triggered by main activity (all handled):**

| # | Package | Action |
|---|---------|--------|
| #29 | actions/setup-node 6.3→6.4 | ✅ Merged |
| #30 | node Docker pin (cms) | ✅ Merged |
| #31 | node Docker pin (root) | ✅ Merged |
| #32 | actions/upload-artifact 7.0→7.0.1 | ✅ Merged |
| #33 | @playwright/test patch | ✅ Merged |
| #34 | @types/node patch | ✅ Merged |
| #35 | next-auth beta.30→beta.31 | ✅ Merged |

### Step 4 — Batch C: local verification (2 PRs)

For **#23 (esbuild)** and **#24 (better-sqlite3)** — CMS-only, no CI coverage:

```bash
gh pr checkout 23            # or 24
docker compose --profile cms up -d
# Wait for Strapi to come up (~30-60s)
curl -sf http://localhost:1337/_health   # expect 204
# Verify admin loads
start http://localhost:1337/admin
# Run backup round-trip to confirm native deps still work
bash scripts/cms/backup.sh
# Tear down
docker compose --profile cms down
```

If the health check passes and backup completes, merge. If not, close with an explanatory comment — CMS is local-only, so a dep that doesn't build isn't a production blocker but shouldn't land.

Do #23 first (esbuild is pure JS tooling, less risky than native bindings), then #24.

### Step 5 — Document and wrap up

1. Add Decision 66 to `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`:
   - Title: "Dependabot pinned to LTS / current-major lines"
   - What: ignore rules for node/dotnet/typescript/Swashbuckle majors
   - Why: .NET 8 LTS to Nov 2026; Node 20 LTS; TS/Swashbuckle majors deferred to Phase 8 per Decision 35
   - Alternatives: blanket `open-pull-requests-limit: 0` (rejected — loses patch coverage); auto-merge action (rejected — low PR volume, manual review preferred)
2. Verify queue is clear: `gh pr list --author "app/dependabot" --state open` should return 0 PRs.

---

## Critical Files Modified

- `.github/dependabot.yml` — add ignore rules (Step 1)
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — add Decision 66 (Step 5)

No source code changes. All PR merges update only lock files / `.csproj` / workflow YAML / Dockerfile SHA pins.

---

## Verification

After Step 3 merges land on `main`:

1. **Tests** — backend + frontend CI must stay green on `main`:
   ```bash
   gh run list --branch main --workflow test.yml --limit 5
   ```
2. **Deploy gates** — frontend container deploy must pass `lhci` and `chromatic`:
   ```bash
   gh run list --branch main --workflow frontend-container-deploy.yml --limit 3
   ```
3. **Local smoke** — after all merges, pull main and run:
   ```bash
   npm ci && npm run test:ci      # frontend 396/396, 70%+ coverage
   cd backend && dotnet test      # backend 114/114
   ```
4. **Live site smoke** — after container-app deploys complete:
   ```bash
   curl -sf https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/
   curl -sf https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
   ```
5. **Dependabot queue** — confirm no unexpected re-opens 24–48h after closes:
   ```bash
   gh pr list --author "app/dependabot" --state open
   ```

## Rollback

- Any Batch B merge that reveals a regression post-merge: revert the merge commit on `main` (`git revert -m 1 <sha>`) and comment on the original PR to prevent re-attempt. Then open a targeted fix.
- The `dependabot.yml` changes are non-destructive — reverting only removes the ignore rules and Dependabot will re-raise the deferred PRs next schedule run.
