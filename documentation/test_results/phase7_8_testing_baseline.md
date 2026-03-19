# Phase 7.8 Testing Baseline

**Created:** 2026-03-19 (Phase 7.8 — Testing Coverage & Quality)
**Purpose:** Snapshot of all test metrics at the time of the Phase 7.8 evaluation. Establishes the baseline for future phases.

---

## Test Layer Summary

| Layer | Framework | Tests | Coverage | CI Gate |
|-------|-----------|-------|----------|---------|
| Frontend unit | Jest + RTL | 396 (40+ suites) | 76.04% lines, 76.77% branches, 71.70% fn, 75.84% stmt | 70% all metrics (enforced) |
| Backend unit | xUnit + Moq | 105 (3 projects) | ~85% testable | Pass/fail + Codecov upload |
| E2E | Playwright | 42 (2 specs × 3 browsers) | Critical flows + auth | Cross-browser matrix |
| Performance | Lighthouse CI | 2 URLs × 3 runs | LCP/FCP/TTI/Score | Thresholds gate deploy |
| Visual | Chromatic | 38 stories | Snapshot diff | `exit-zero-on-changes` (baseline pending) |
| Accessibility | jest-axe + axe-playwright | 4 suites | WCAG 2.1 AA | Part of Jest suite |
| Bicep validation | Azure CLI + Bicep | main.bicep | Template syntax + schema | Gates test suite |

---

## Frontend Tests (Jest + React Testing Library)

**Test count:** 396/396 passing
**Test files:** 40 Jest suites (`*.test.ts(x)`) + 2 Playwright specs (`*.spec.ts`)

### Coverage Metrics (Phase 7.8 baseline)

| Metric | Value | Gate |
|--------|-------|------|
| Statements | 75.84% | ≥ 70% |
| Branches | 76.77% | ≥ 70% |
| Functions | 71.70% | ≥ 70% |
| Lines | 76.04% | ≥ 70% |

All four metrics are above the enforced 70% CI threshold.

### Known Coverage Gaps (Accepted)

| Component | Coverage | Reason |
|-----------|----------|--------|
| `SkeletonCard` | 0% Jest | Pure presentational loading state; no logic; covered by E2E when loading states appear |
| `LoadingAnnouncer` | 0% Jest | Pure presentational; covered by E2E |
| Radix UI components | Mocked | Portal limitation in jsdom; real components validated in E2E |

---

## Backend Tests (xUnit + Moq)

**Test count:** 105/105 passing
**Test projects:** 3 (Core.Tests, Data.Tests, Api.Tests)

### Project Breakdown

| Project | Tests | Notes |
|---------|-------|-------|
| `AIEnterprisePatterns.Core.Tests` | ~20+ | PatternService (caching, related patterns, all CRUD + filtering) |
| `AIEnterprisePatterns.Data.Tests` | ~38+ | PatternRepository (GetRelatedPatternsAsync, all queries) |
| `AIEnterprisePatterns.Api.Tests` | ~47+ | PatternsController integration tests + auth scenarios (TestAuthHandler) |

### Coverage Tooling

- **Tool:** `coverlet.collector` v6.0.4 (in all 3 test `.csproj` files)
- **Settings:** `backend/coverlet.runsettings` — formats: json + cobertura + lcov + opencover; excludes test assemblies and generated Migrations
- **CI command:** `dotnet test --no-build --configuration Release --collect:"XPlat Code Coverage" --results-directory ./TestResults --settings coverlet.runsettings`
- **Upload:** Codecov (flag: `backend`); `fail_ci_if_error: false`
- **Threshold:** None enforced in CI (no `--threshold` flag) — see accepted risk note below

### Known Coverage Gaps (Accepted)

| Gap | Reason |
|-----|--------|
| `OperationCanceledException` not unit-tested | Rare edge case; logged at `LogInformation`; Application Insights monitors in production |
| No CI coverage threshold | Adding 70% threshold deferred — backend structure is stable; threshold enforcement is Phase 8 work |

---

## E2E Tests (Playwright)

**Test count:** 42 tests across 2 spec files × 3 browsers = 126 test runs in CI
**Browsers:** Chromium, Firefox, WebKit (parallel `strategy.matrix` in `test.yml`)

### Spec Files

| File | Tests | Notes |
|------|-------|-------|
| `e2e/critical-flows.spec.ts` | 20 | Home, Browse, Detail, Error Handling, Page Titles |
| `e2e/authenticated-flows.spec.ts` | 22 | Unauthenticated guards + Authenticated UI + API writes (opt-in) |

### E2E Test Categories

| Category | Tests | Always Runs | Requirement |
|----------|-------|------------|-------------|
| Unauthenticated guards | 4 | ✅ Yes | None |
| Authenticated — UI | 4 | ✅ Yes (when `AUTH_SECRET` set) | Session injection via `@auth/core/jwt` |
| Authenticated — API writes | 3 | ❌ No | `E2E_API_WRITES=true` + real Entra token |
| Critical flows | 20 | ✅ Yes | None |

**Note:** The 3 API-write E2E tests are intentionally skipped in CI. See `TESTING_STRATEGY.md` Section 9.1 for rationale.

---

## Performance Tests (Lighthouse CI)

**Tool:** `@lhci/cli` in `frontend-container-deploy.yml`
**URLs tested:** `/` (home) and `/patterns` (listing)
**Runs per URL:** 3 measured + 1 warmup (warmup eliminates cold-start outlier)

### Thresholds

| Metric | Threshold | Enforcement |
|--------|-----------|-------------|
| LCP | < 2500ms | Hard gate (blocks deploy) |
| FCP | < 1800ms | Hard gate |
| TTI | < 5000ms | Hard gate |
| Performance score | ≥ 0.80 | Hard gate |

---

## Visual Regression (Chromatic)

**Stories:** 38 Storybook stories
**Config:** `--exit-zero-on-changes` + `continue-on-error: true` (baseline pending acceptance)
**Gate:** Will become a hard deploy gate once baseline is approved (remove both flags)

---

## Accessibility Tests

**Tools:** jest-axe (unit) + `@axe-core/playwright` (E2E)
**Standard:** WCAG 2.1 AA
**Suites:** 4 dedicated a11y test files
**Gate:** Part of Jest suite (failures block CI)

---

## CI Architecture

```
test.yml (every PR + push to main)
├── backend-tests       # dotnet test + Codecov upload
├── frontend-tests      # npm run test:ci + Codecov upload
├── e2e-tests (matrix)  # Playwright × {chromium, firefox, webkit} — main branch only
├── validate-infrastructure  # az bicep build
└── test-summary        # Fails if any of the above fail (e2e: skipped OK on PRs)

frontend-container-deploy.yml (on main push)
├── run-tests           # test.yml job (must pass)
├── build-and-push      # parallel with lhci + chromatic
├── lhci                # Lighthouse CI (parallel)
├── chromatic           # Visual regression (parallel)
└── deploy              # requires all 3 above
```

---

## Deferred Testing Capabilities

| Capability | Tool | Effort | Target Phase |
|-----------|------|--------|-------------|
| Mutation testing | Stryker (frontend) + Stryker.NET (backend) | 4-6 weeks | Phase 8 |
| Load/stress testing | k6 | 3-4 weeks | Phase 8 |
| Contract testing | Pact (consumer-driven) | 4-5 weeks | Phase 9+ |
