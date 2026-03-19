# Phase 7.8: Testing Coverage & Quality — Implementation Plan

**Created:** 2026-03-18
**Status:** Ready for implementation
**Parent:** Phase 7 — Quality & Hardening Evaluation ([PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md))

---

## Context

Phase 7 is a 10-area quality & hardening evaluation. Area 7.8 audits all test suites for coverage gaps, assertion quality, CI integration, and testing infrastructure maturity. The testing foundation is **enterprise-grade** — 390 frontend tests, 105 backend tests, 42 E2E tests across 3 browsers, Lighthouse CI performance gates, Chromatic visual regression, and 4 accessibility test suites. This evaluation identifies what's missing at the margins.

**Audit findings:** 5 MEDIUM findings, 5 LOW accepted risks. No critical or high-severity gaps. The three actionable tracks are lightweight (documentation + CI config); the three deferred tracks (mutation testing, load testing, contract testing) are significant effort better suited to Phase 8+.

---

## Current Baseline

| Layer | Framework | Tests | Coverage | CI Gate |
|-------|-----------|-------|----------|---------|
| Frontend unit | Jest + RTL | 390 (40 suites) | 75.97% lines, 76.77% branches, 71.70% fn, 75.84% stmt | 70% all metrics |
| Backend unit | xUnit + Moq | 105 (3 projects) | ~85% testable | Pass/fail only |
| E2E | Playwright | 42 (2 specs x 3 browsers) | Critical flows + auth | Cross-browser matrix |
| Performance | Lighthouse CI | 2 URLs x 3 runs | LCP/FCP/TTI/Score | Thresholds gate deploy |
| Visual | Chromatic | 38 stories | Snapshot diff | `exit-zero-on-changes` (baseline pending) |
| Accessibility | jest-axe + axe-playwright | 4 suites | WCAG 2.1 AA | Part of Jest suite |

**Test files (42 frontend):** 40 Jest (`*.test.ts(x)`) + 2 Playwright (`*.spec.ts`)
**Test result docs:** Last updated Phase 5.1 — no docs for Phases 6.3-6.8 additions

---

## Findings

| # | Finding | Severity | Category | Action |
|---|---------|----------|----------|--------|
| 1 | No mutation testing (assertion quality unverified) | MEDIUM | Quality | Defer to Phase 8 |
| 2 | No load/stress testing (rate limiters unverified under concurrency) | MEDIUM | Performance | Defer to Phase 8 |
| 3 | Test result documentation stale since Phase 5.1 | MEDIUM | Documentation | Track 1 |
| 4 | Backend has no coverage reporting or CI threshold | MEDIUM | CI Integration | Track 2 |
| 5 | E2E API write tests always skipped in CI (`E2E_API_WRITES` never set) | MEDIUM | CI Integration | Track 3 |
| 6 | No contract testing between frontend API client and backend DTOs | LOW | API Testing | Accept (defer Phase 9+) |
| 7 | Backend `OperationCanceledException` not unit-tested | LOW | Backend Coverage | Accept |
| 8 | SkeletonCard + LoadingAnnouncer at 0% Jest coverage | LOW | Frontend Coverage | Accept |
| 9 | Radix UI components mocked in Jest (jsdom portal limitation) | LOW | Testing Pattern | Accept |
| 10 | Chromatic baseline not yet hardened (exit-zero-on-changes) | LOW | Visual Testing | Accept |

---

## Track 1: Test Results Documentation Update

**Effort:** Light (1-2 hours)
**Files to create/update:**
- `documentation/test_results/phase6_test_results.md` — snapshot of Phase 6.3-6.8 additions (Lighthouse CI, Chromatic, cross-browser E2E, CMS query tests, auth E2E)
- `documentation/test_results/phase7_8_testing_baseline.md` — current metrics snapshot (all numbers from baseline table above)

**Why:** Stakeholders and future team members need an audit trail. Last test result doc is from Phase 5.1; Phases 6.3-6.8 added significant testing infrastructure with no documentation trail.

**Verify:** Files exist with accurate, current metrics.

---

## Track 2: Backend Coverage Reporting

**Effort:** Light-Medium (2-3 hours)
**Files:**
- Backend `.csproj` test projects (add `coverlet.collector` if missing)
- `.github/workflows/test.yml` (add `dotnet test --collect:"XPlat Code Coverage"` + Codecov upload)

**Steps:**
1. Verify `coverlet.collector` is referenced in all 3 test projects
2. Update `dotnet test` command in CI to collect coverage (`--collect:"XPlat Code Coverage"`)
3. Upload backend coverage to Codecov alongside frontend
4. Consider adding a coverage threshold (e.g., 70% line — matching frontend)

**Why:** Frontend has enforced 70% coverage thresholds; backend has none. A regression in backend coverage would go undetected. This is the most impactful quick win.

**Verify:** CI run shows backend coverage uploaded to Codecov; threshold (if added) enforced.

---

## Track 3: Document E2E API Write Test Strategy

**Effort:** Light (30 min)
**Files:**
- `e2e/authenticated-flows.spec.ts` (improve skip comments)
- `documentation/testing/TESTING_STRATEGY.md` (add section on auth E2E approach)

**Steps:**
1. Add clear documentation that `E2E_API_WRITES=true` tests require Entra credentials and are intentionally skipped in CI
2. Document the rationale: single-developer project, healthcheck provides post-deploy validation, manual testing sufficient
3. Note that enabling these in CI would require: test Entra user, GitHub Secrets, protected environment

**Why:** The 2 skipped API write tests are an intentional trade-off, not a gap — but this isn't documented anywhere except a code comment. Future contributors need to understand why.

**Verify:** `TESTING_STRATEGY.md` has E2E auth test strategy section; comments in spec file are clear.

---

## Track 4: Documentation (Decision Log)

**Effort:** Light (15 min)
**Files:**
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — add decision entry for 7.8 evaluation

**Decision summary:** Phase 7.8 Testing Coverage & Quality evaluation — testing infrastructure is enterprise-grade (390 frontend + 105 backend + 42 E2E x 3 browsers + Lighthouse CI + Chromatic). Three lightweight tracks: test result docs, backend CI coverage, E2E auth strategy documentation. Mutation testing (Stryker), load testing (k6), and contract testing (Pact) deferred to Phases 8-9.

**Alternatives evaluated:**
- Stryker mutation testing now — significant effort (4-6 weeks), 70%+ coverage thresholds adequate for current scale
- k6 load testing now — needs staging environment and larger dataset; Lighthouse CI validates single-user performance
- Pact contract testing — single repo with tightly coupled frontend/backend; more valuable in multi-service architecture

---

## Deferred Findings (Phase 8+)

### Finding 1: Mutation Testing (Phase 8)
- **Tool:** Stryker (frontend) + Stryker.NET (backend)
- **Value:** Verifies assertions are meaningful, not just coverage-padding
- **Effort:** 4-6 weeks (setup + baseline tuning + CI integration)
- **Target:** 80%+ mutation score for new code
- **Why defer:** Significant setup effort; current 70%+ coverage thresholds are adequate for current phase

### Finding 2: Load/Stress Testing (Phase 8)
- **Tool:** k6 (lightweight, scriptable)
- **Value:** Validates rate limiters activate at claimed thresholds; measures API response times under concurrent load; tests database query performance beyond 6 seed patterns
- **Effort:** 3-4 weeks (scripts + CI nightly schedule + alerting)
- **Why defer:** Current Lighthouse CI validates single-user performance; load testing needs a staging environment and larger dataset

### Finding 6: Contract Testing (Phase 9+)
- **Tool:** Pact (consumer-driven contracts)
- **Value:** Catches frontend/backend DTO mismatches before integration
- **Effort:** 4-5 weeks
- **Why defer:** Single repo with tightly coupled frontend/backend; more valuable when APIs serve multiple consumers or move to separate repos

---

## Accepted Risks

| # | Risk | Rationale |
|---|------|-----------|
| 7 | `OperationCanceledException` not unit-tested | Rare edge case; logged correctly; Application Insights monitors in production |
| 8 | SkeletonCard + LoadingAnnouncer uncovered by Jest | Pure presentational, no logic; covered by E2E when loading states appear |
| 9 | Radix UI mocked in Jest (portals don't render in jsdom) | Documented pattern; mocks are comprehensive; real components validated in E2E |
| 10 | Chromatic `exit-zero-on-changes` still active | Intentional — baseline acceptance in progress; will be enforced once baseline is approved |

---

## Verification Checklist

After implementing Tracks 1-4:
- [ ] `documentation/test_results/phase6_test_results.md` exists with Phase 6.3-6.8 testing additions
- [ ] `documentation/test_results/phase7_8_testing_baseline.md` exists with current metrics
- [ ] Backend CI step collects coverage and uploads to Codecov
- [ ] `TESTING_STRATEGY.md` has E2E auth test strategy section
- [ ] Decision entry added to `TECHNICAL_DECISIONS_LOG.md`
- [ ] All existing tests still pass: `npm run test:ci` (390 tests, coverage >= 70%) + `dotnet test` (105 tests)

---

## Summary

| Track | Finding | Effort | Phase |
|-------|---------|--------|-------|
| 1 | Test results documentation | 1-2 hours | **7.8** |
| 2 | Backend coverage reporting in CI | 2-3 hours | **7.8** |
| 3 | Document E2E auth test strategy | 30 min | **7.8** |
| 4 | Decision log entry | 15 min | **7.8** |
| — | Mutation testing (Stryker) | 4-6 weeks | Defer to 8 |
| — | Load testing (k6) | 3-4 weeks | Defer to 8 |
| — | Contract testing (Pact) | 4-5 weeks | Defer to 9+ |
