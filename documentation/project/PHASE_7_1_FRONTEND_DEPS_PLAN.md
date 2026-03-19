# Phase 7.1: Frontend Dependency Audit & Hardening — Implementation Plan

**Created:** 2026-03-17
**Status:** Ready for implementation
**Parent:** Phase 7 — Quality & Hardening Evaluation ([PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md))

---

## Context

Phase 6 is complete. Phase 7 is a 10-area quality & hardening evaluation. Area 7.1 audits frontend dependencies for vulnerabilities, currency, and automation gaps.

**Audit findings:** 14 npm vulnerabilities (10 low, 4 high — all in dev-only transitive deps), 18 outdated packages, no Dependabot, no `npm audit` in CI. Production deps are clean.

---

## Track 1: Security Fixes

**Files:** `package.json`, `package-lock.json`

1. Run `npm audit fix` — resolves ~10 low-severity issues (non-breaking)
2. Add `overrides` to `package.json` for safe transitive fixes:
   ```json
   "overrides": {
     "ajv": "^8.8.2",
     "flatted": ">=3.4.0",
     "serialize-javascript": ">=7.0.3"
   }
   ```
3. Run `npm install` to apply overrides
4. Run `npm audit` — verify remaining issues are dev-only (elliptic via Storybook, tmp via LHCI)
5. **Verify:** `npm run test:ci` (390 tests, coverage ≥70%), `npm run build`, `npm run build-storybook`

**Accepted dev-only risks:** `elliptic` (Storybook → crypto-browserify), `tmp` (LHCI → inquirer) — no patched versions available upstream.

**Commit:** `fix: resolve npm audit vulnerabilities and add overrides (Phase 7.1)`

---

## Track 2: Safe Dependency Updates

**Files:** `package.json`, `package-lock.json`

Update all minor/patch deps:

**Production:**
- `next` 16.1.6 → 16.1.7
- `lucide-react` 0.563.0 → latest 0.5xx
- `tailwind-merge` 3.4.0 → 3.5.0

**Dev:**
- `@storybook/*` + `storybook` 10.2.14 → 10.2.19
- `jest` + `jest-environment-jsdom` 30.2.0 → 30.3.0
- `@types/node` 25.2.2 → 25.5.0, `@types/react` 19.2.13 → 19.2.14
- `autoprefixer` 10.4.24 → 10.4.27
- `chromatic` 15.2.0 → 15.3.0
- `eslint-config-next` 16.1.6 → 16.1.7
- `postcss` 8.5.6 → 8.5.8

**NOT updating (out of scope):** tailwindcss v4, eslint v10, next-auth (intentionally on v5 beta)

**Verify:** `npm run test:ci`, `npm run build`, `npm run lint`, `npm run build-storybook`

**Commit:** `chore: update frontend dependencies to latest minor/patch (Phase 7.1)`

---

## Track 3: CMS Dependency Updates

**Files:** `cms/package.json`, `cms/package-lock.json`

1. Update Strapi to latest 5.x patch (all three `@strapi/*` packages together)
2. Update `mysql2` to latest 3.x
3. **Verify:** `cd cms && npm run build`
4. Optionally verify with `docker compose --profile cms up -d` if Docker is available

**NOT updating:** react 18→19, react-router-dom 6→7 (Strapi controls these)

**Commit:** `chore: update CMS dependencies — Strapi latest patch, mysql2 (Phase 7.1)`

---

## Track 4: CI Hardening

**Files:** `.github/workflows/test.yml`, `.github/workflows/frontend-container-deploy.yml`, `.github/dependabot.yml` (new)

### 4a. Add `npm audit` to CI

In `test.yml` `frontend-tests` job, after `npm ci`:
```yaml
      - name: Security audit (production deps)
        run: npm audit --omit=dev --audit-level=high
```

Same step in `frontend-container-deploy.yml` `run-tests` job after `npm ci`.

Using `--omit=dev` because the 4 remaining HIGHs are all in devDependencies. Production deps must be zero-vulnerability.

### 4b. Create `.github/dependabot.yml`

- **npm (root):** Weekly Monday, grouped PRs (storybook, testing, types), ignore major bumps for tailwindcss/eslint/next-auth
- **npm (cms/):** Weekly Monday, grouped Strapi PRs, ignore React/react-router-dom majors
- **nuget (backend/):** Weekly Monday
- **github-actions (/):** Weekly Monday

**Commit:** `ci: add npm audit gate and Dependabot configuration (Phase 7.1)`

---

## Track 5: Documentation

**Files:** `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`, `documentation/project/PHASE_QUALITY_HARDENING_PLAN.md`, `DOCUMENTATION_INDEX.md`, `documentation/project/ROADMAP.md`, `CLAUDE.md`

1. Add Decision 51 — Phase 7.1 frontend dependency hardening rationale
2. Mark Area 1 complete in `PHASE_QUALITY_HARDENING_PLAN.md`
3. Update decision count in `DOCUMENTATION_INDEX.md`
4. Update `ROADMAP.md` with 7.1 completion
5. Update `CLAUDE.md` if needed

**Commit:** `docs: document Phase 7.1 frontend dependency hardening`

---

## Verification Checklist

After all tracks:
- [ ] `npm audit --omit=dev` shows 0 vulnerabilities
- [ ] `npm run test:ci` — 390 tests pass, all coverage ≥70%
- [ ] `npm run build` — Next.js production build succeeds
- [ ] `npm run lint` — no ESLint errors
- [ ] `npm run build-storybook` — Storybook compiles (38 stories)
- [ ] `cd cms && npm run build` — Strapi admin panel compiles
- [ ] `.github/dependabot.yml` is valid YAML
- [ ] CI workflow YAML is valid (checked by pushing branch)
