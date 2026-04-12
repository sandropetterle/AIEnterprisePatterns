# Testing Strategy

**Last Updated:** 2026-03-19
**Audience:** QA Engineers, Developers
**Purpose:** Define the testing approach, tools, coverage targets, and quality standards for the AI Enterprise Patterns Library.

## Overview
This document outlines the testing strategy for the AI Enterprise Patterns Library project. It covers both frontend and backend testing approaches, tools, and best practices to ensure code quality, reliability, and maintainability.

**Related Documents:**
- [MANUAL_TEST_PLAN.md](MANUAL_TEST_PLAN.md) - Detailed manual test cases organized by feature area (for pre-release validation)
- [../project/ROADMAP.md](../project/ROADMAP.md) - Phase-specific testing requirements and deliverables
- [../../deployment/github-secrets-setup.md](../../deployment/github-secrets-setup.md) - CI/CD credentials and secrets configuration

**Purpose of This Document:**
- Define test types, tools, and frameworks
- Establish coverage targets and quality standards
- Provide guidance on automated vs manual testing
- Document testing best practices and conventions

---

## 1. Test Types

### 1.1 Unit Tests
- **Frontend:** Test React components, utility functions, and hooks in isolation.
- **Backend:** Test C# services, controllers, and business logic independently of external dependencies.
- **Coverage Target:** 80%+ for core business logic

### 1.2 Integration Tests
- **Frontend:** Test component interactions and integration with mock APIs.
- **Backend:** Test API endpoints, database interactions, and middleware using in-memory or test databases.
- **API Integration:** Test frontend-backend communication with real API calls

### 1.3 End-to-End (E2E) Tests
- Simulate real user flows across the full stack (UI to database) to validate system behavior.
- **Critical Flows:** Browse patterns, view details, voting, search/filter, authentication (Phase 5+)
- **Cross-Browser:** Chromium, Firefox, WebKit — parallel matrix in CI (`strategy.matrix` in `test.yml`)

### 1.4 Visual Regression Tests (Phase 6.4 ✅)
- **Purpose:** Detect unintended UI changes across commits
- **Tool:** Chromatic (integrates with existing 38 Storybook stories)
- **Scope:** All 38 component stories; unreviewed visual changes block the deploy job
- **Config:** `--exit-zero-on-changes` + `continue-on-error: true` until baseline is accepted, then removed to harden the gate

### 1.5 Performance Tests (Phase 6.4 ✅)
- **Lighthouse CI (`@lhci/cli`):** LCP < 2.5s, FCP < 1.8s, TTI < 5s, Performance ≥ 0.80 — configured in `lighthouserc.yml`; tests `/` with 3 runs (plus 1 warmup). `/patterns` excluded — its LCP is dominated by live backend SSR latency on CI runners, not real user performance
- **API Performance:** Response time < 500ms for standard queries
- **Load Testing:** k6 or Apache JMeter for stress testing (Phase 7+)

### 1.6 Accessibility Tests (Phase 5+)
- **Automated:** axe-core integration with Jest and Playwright
- **Manual:** Screen reader testing, keyboard navigation validation
- **Standard:** WCAG 2.1 AA compliance

### 1.7 Manual Tests
- **Execution:** Follow `documentation/testing/MANUAL_TEST_PLAN.md` for structured manual testing
- **When:** Pre-release smoke testing, exploratory testing, UAT
- **Documentation:** Results stored in `documentation/test_results/`

---

## 2. Tools & Frameworks

### 2.1 Frontend
- **Unit/Integration:** Jest, React Testing Library
- **E2E:** Playwright — cross-browser matrix (Chromium, Firefox, WebKit); `playwright.config.ts` enables all three projects
- **Visual Regression:** Chromatic (Phase 6.4 ✅) — publishes Storybook to Chromatic on every deploy
- **Performance:** Lighthouse CI / `@lhci/cli` (Phase 6.4 ✅) — `lighthouserc.yml` at project root
- **Accessibility:** axe-core, @axe-core/playwright (Phase 5+)

### 2.2 Backend
- **Unit/Integration:** xUnit, Moq (for mocking dependencies), Entity Framework Core InMemory provider
- **API Testing:** Integration test projects with WebApplicationFactory, Postman (manual), Swagger (dev)
- **Load Testing:** k6 or Apache JMeter (Phase 6+)

### 2.3 Manual Testing
- **Test Execution:** Follow `documentation/testing/MANUAL_TEST_PLAN.md` for manual test cases
- **Exploratory Testing:** Ad-hoc testing for new features and bug verification
- **User Acceptance Testing (UAT):** Phase 8 enterprise features

---

## 3. Folder Structure

### 3.1 Backend Test Structure
```
backend/
├── tests/
│   ├── AIEnterprisePatterns.Core.Tests/      # Unit tests for Core layer
│   │   ├── Services/
│   │   ├── Entities/
│   │   └── ValueObjects/
│   ├── AIEnterprisePatterns.Data.Tests/      # Unit tests for Data layer
│   │   ├── Repositories/
│   │   └── Configurations/
│   └── AIEnterprisePatterns.Api.Tests/       # Integration tests for API
│       ├── Controllers/
│       ├── Middleware/
│       └── IntegrationTestFactory.cs
```

### 3.2 Frontend Test Structure
```
(project root)
├── __tests__/                          # Test utilities and global setup
│   ├── setup.ts
│   └── testUtils.tsx
├── lib/
│   ├── api/
│   │   ├── client.test.ts             # Unit tests for API client
│   │   ├── mappers.test.ts            # Unit tests for category/DTO mappers
│   │   └── patterns.test.ts           # Unit tests for pattern API functions
│   └── utils/
│       └── dateFormat.test.ts
├── components/
│   ├── patterns/
│   │   ├── PatternCard.test.tsx
│   │   ├── FilterPanel.test.tsx
│   │   ├── SearchBar.test.tsx
│   │   └── details/
│   │       ├── VotingButton.test.tsx
│   │       ├── PatternContent.test.tsx
│   │       └── Breadcrumb.test.tsx
│   └── layout/
│       ├── Header.test.tsx
│       └── Footer.test.tsx
├── app/
│   ├── patterns/
│   │   └── page.test.tsx
│   └── page.test.tsx
└── e2e/                                # Playwright E2E tests
    └── critical-flows.spec.ts          # 20 critical user-journey tests
```

### 3.3 Test Results & Documentation
```
documentation/
├── test_results/                  # Retention: current phase + 2 prior
│   ├── COMPREHENSIVE_TEST_RESULTS.md  # Archived (exempt from retention)
│   ├── phase6_test_results.md         # Phase 6 (N-2)
│   └── phase7_8_testing_baseline.md   # Phase 7 (N-1, current baseline)
├── TESTING_STRATEGY.md            # This document
└── MANUAL_TEST_PLAN.md            # Manual test cases
```

---

## 4. Automated vs Manual Testing

### 4.1 When to Automate
- **Unit tests:** Always automate (Jest, xUnit)
- **Integration tests:** Always automate (API endpoints, database operations)
- **Regression tests:** Automate high-value user flows (authentication, core features)
- **Visual tests:** Automate with snapshots (Phase 6+)
- **Performance tests:** Automate with budgets (Lighthouse CI in Phase 6+)
- **Accessibility tests:** Automate with axe-core (Phase 5+)

### 4.2 When to Test Manually
- **Exploratory testing:** New features, edge cases, creative bug hunting
- **Usability testing:** User experience validation, design feedback
- **Cross-browser compatibility:** Initial validation before automation (Phase 6)
- **Pre-release smoke tests:** Quick validation of deployment
- **UAT:** Business stakeholder acceptance (Phase 8)
- **Visual design reviews:** Pixel-perfect comparisons, subjective assessments

### 4.3 Test Execution Guide
1. **Daily Development:** Run unit tests locally (`npm test`, `dotnet test`)
2. **Before PR:** Run full test suite including E2E (local)
3. **In CI/CD:** Automated tests run on every PR and merge to main
4. **Before Release:** Execute manual test plan (`MANUAL_TEST_PLAN.md`)
5. **Post-Release:** Monitor production, run smoke tests

## 5. Best Practices

- Write tests for all critical business logic and UI components
- Use mocks/stubs for external dependencies
- Run tests automatically in CI/CD pipelines
- Maintain high code coverage (target: 80%+ for core logic)
- Review and update tests as features evolve
- Document test failures and root causes
- Keep tests fast (unit < 50ms, integration < 500ms, E2E < 30s per test)
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert) for clarity
- Isolate tests (no shared state between tests)

### 5.1 Coverage Verification (MANDATORY)

The CI gate enforces **≥ 70% for all four metrics** (statements, branches, functions, lines) via `jest.config.mjs` `coverageThreshold`. A breach blocks deployment.

**Run before every commit that touches `app/`, `components/`, or `lib/`:**

```bash
npm run test:ci   # Runs jest --ci --coverage; must pass all four 70% thresholds
```

**Triggers that commonly cause a breach:**
| Change | Risk | Mitigation |
|---|---|---|
| New exported function with no test | Function coverage drops | Add at least one test covering the happy path |
| Library mock that swallows `components` prop | Inline renderers never called | Make the mock invoke the renderers (see `PatternContent.test.tsx` pattern) |
| Deleting a test file | Covered functions removed from numerator | Check coverage after deletion |
| Adding a new file that is complex but untested | All metrics drop | Add tests alongside the new file |

**The `PatternContent` mock pattern** (reference for mocking libraries that accept render-function props):

```tsx
// Instead of ignoring the `components` prop entirely, invoke the renderers
jest.mock('react-markdown', () => {
  return function ReactMarkdown({ children, components }: any) {
    const Img = components?.img
    const Code = components?.code
    return (
      <div data-testid="markdown-content">
        <span>{children}</span>
        {Img && <Img src="https://optimizable-host.com/img.png" alt="test" />}
        {Code && <Code className="language-js">{'block code'}</Code>}
        {Code && <Code>{'inline code'}</Code>}
      </div>
    )
  }
})
```

---

## 6. Running Tests

### 6.1 Frontend
```bash
# Unit and integration tests
npm test                    # Run all tests
npm test -- --watch        # Watch mode for development
npm test -- --coverage     # Generate coverage report

# E2E tests (Playwright)
npx playwright test                 # Run all E2E tests
npx playwright test --headed        # Run with visible browser
npx playwright test --project=chromium  # Run on specific browser
npx playwright test --debug         # Debug mode with inspector
```

### 6.2 Backend
```bash
# Run all tests
dotnet test

# Run tests with coverage
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

# Run specific test project
dotnet test backend/tests/AIEnterprisePatterns.Core.Tests

# Run tests in watch mode (for development)
dotnet watch test --project backend/tests/AIEnterprisePatterns.Core.Tests
```

### 6.3 CI/CD Test Execution
Tests run automatically in GitHub Actions on:
- Every pull request (all test types)
- Every push to main (all test types + deployment)
- Scheduled runs (nightly full regression suite)

---

## 7. Quality Gates & Reporting

### 7.1 Quality Gates (Enforced in CI/CD)
- ✅ All unit tests must pass (100% pass rate required)
- ✅ All integration tests must pass (100% pass rate required)
- ✅ All E2E tests must pass on all three browsers (Chromium, Firefox, WebKit)
- ✅ Code coverage ≥ 70% all four metrics (stmt/branch/fn/line — enforced via `jest.config.mjs`)
- ✅ No critical accessibility violations (axe-core failures block merge)
- ✅ Lighthouse CI thresholds: LCP < 2500ms, FCP < 1800ms, TTI < 5000ms, Performance ≥ 0.80, Accessibility ≥ 0.90 (warn — Phase 7.10)
- ✅ Chromatic: no unreviewed visual changes (once baseline is accepted and `continue-on-error` removed)
- ⚠️ No high-severity security vulnerabilities (npm audit, Snyk, or similar)

### 7.2 Reporting
- **Coverage Reports:** Generated by Codecov or Coverlet, visible in PRs
- **Test Results:** Displayed in GitHub Actions with detailed failure logs
- **Performance Reports:** Lighthouse CI comments on PRs with metrics
- **Visual Regression:** Percy/Chromatic provides visual diff reviews
- **Accessibility Reports:** axe-core results exported to artifacts

### 7.3 Manual Test Reporting
- Manual test execution results documented in `documentation/test_results/`
- Use naming convention: `phase{N}_test_results.md` or `test_run_YYYY-MM-DD.md`
- Include test execution date, tester name, pass/fail status, screenshots, issues found

---

## 8. Future Enhancements

### Phase 5+
- ✅ Accessibility testing (axe-core) - **Implemented in Phase 5.4**

### Phase 6.4
- ✅ Performance testing (Lighthouse CI) - **Implemented in Phase 6.4**
- ✅ Visual regression testing (Chromatic) - **Implemented in Phase 6.4**
- ✅ Playwright cross-browser matrix (Chromium / Firefox / WebKit) - **Implemented in Phase 6.4**

### Phase 7+
- Mutation testing for critical modules (Stryker for frontend, Stryker.NET for backend)
- Contract testing for API versioning (Pact or similar)
- Chaos engineering for resilience testing (Phase 8)

### Phase 8+
- Security scanning automation (SAST/DAST in CI/CD)
- AI-powered test generation for edge cases
- Synthetic monitoring for production environments

---

## 9. Summary & Current State

### Phase 6.3 Complete — as of 2026-03-02

Phase 6.3 (Documentation Reuse & Storybook) added 38 Storybook stories but no new Jest/xUnit tests — test counts unchanged from Phase 6.2.

**Backend (xUnit + Moq):**
- ✅ 105/105 tests passing (~85% testable coverage)
- Core: PatternService (20+ tests incl. related patterns caching)
- Data: PatternRepository (38+ tests incl. GetRelatedPatternsAsync)
- Api/Integration: PatternsController (47+ tests incl. related endpoint + auth scenarios)

**Frontend (Jest + React Testing Library):**
- ✅ 354/354 tests passing
- Coverage: 71.70% functions / 75.84% statements / 76.77% branches / 75.97% lines (CI gate: 70% all metrics)
- New in Phase 6.1: ThemeProvider (5 tests), ThemeToggle (6 tests)
- New in Phase 6.2: `getRelatedPatterns` (4 tests); PatternContent img/code renderers + `isOptimizable` (5 new tests)
- Deleted in Phase 6.2: 50 obsolete client-side filterAndSort + relatedPatterns tests
- New in Phase 6.5: CmsErrorPageProvider context + useCmsErrorPage hook (4 tests)

**E2E (Playwright — Chromium):**
- ✅ 20/20 tests passing (`e2e/critical-flows.spec.ts`)
- Covers: Home Page (3), Browse Patterns (6), Pattern Detail (6), Error Handling (2), Page Titles (3)
- Auth: Direct session injection via `@auth/core/jwt` encode (replaces Entra browser login in CI)
- Network mocking: `page.addInitScript` to override `window.fetch` for vote endpoint (see Decision 12)

**CI/CD Gates (`.github/workflows/test.yml`):**
- ✅ Backend tests → Frontend tests → E2E (Chromium) must all pass before deployment

### Phase 6.4 Complete — as of 2026-03-03

Phase 6.4 (Testing Infrastructure) added Lighthouse CI, Chromatic visual regression, and cross-browser Playwright. No new Jest/xUnit tests — counts unchanged from Phase 6.3.

**E2E (Playwright — Chromium + Firefox + WebKit):**
- ✅ All 20 critical-flow tests now run on three browsers in parallel (`strategy.matrix` in `test.yml`)
- Each browser installs via `npx playwright install --with-deps ${{ matrix.browser }}`
- `fail-fast: false` — all three browsers report independently; per-browser Playwright HTML reports uploaded as artifacts

**Lighthouse CI:**
- ✅ `lhci` job added to `frontend-container-deploy.yml` — runs after `run-tests`, parallel with Docker build
- Thresholds: LCP < 2500ms, FCP < 1800ms, TTI < 5000ms, Performance ≥ 0.80
- Tests `/` only (3 runs + 1 warmup run to eliminate cold-start outliers) against the built Next.js app. `/patterns` was removed — its LCP is dominated by live backend SSR fetch latency on CI runners (consistently 3600–3900ms) making the 2500ms gate a false-positive; the patterns listing is covered functionally by E2E tests
- Results uploaded to temporary-public-storage; optional GitHub status check via `LHCI_GITHUB_APP_TOKEN`

**Chromatic:**
- ✅ `chromatic` job added to `frontend-container-deploy.yml` — publishes all 38 Storybook stories
- Uses `fetch-depth: 0` for baseline tracking; `continue-on-error: true` + `--exit-zero-on-changes` until baseline accepted
- Remove both flags after baseline approval to make visual regression a hard deploy gate

**Updated deploy gate (`.github/workflows/frontend-container-deploy.yml`):**
- `run-tests` → (`build-and-push` + `lhci` + `chromatic`) in parallel → `deploy`

### Phase 6.5 Complete — as of 2026-03-03

Phase 6.5 (CMS Content Migration — Page Content) completed the CMS wiring for all page content.
New `CmsErrorPageProvider` context provider allows `app/error.tsx` (which must be `'use client'`) to receive CMS error page labels injected at root layout.

**Frontend (Jest + React Testing Library):**
- ✅ 354/354 tests passing (4 new: CmsErrorPageProvider context provider)
- Coverage: 71.70% functions / 75.84% statements / 76.77% branches / 75.97% lines

### Phase 6.6 Complete — as of 2026-03-03

Phase 6.6 (CMS Content Migration — Pattern UI Labels) wired CMS label Single Types into 13 components across the listing, detail, and form pages. No new Jest/xUnit tests added (coverage maintained); E2E tests expanded to 42 across all browsers.

**Frontend (Jest + React Testing Library):**
- ✅ 354/354 tests passing (unchanged from Phase 6.5)
- Coverage: 71.70% functions / 75.84% statements / 76.77% branches / 75.97% lines

**E2E (Playwright — Chromium + Firefox + WebKit):**
- ✅ 42 tests across all three browsers (up from 20 in Phase 6.4; Auth + API write tests added in Phase 6.1–6.5)
- 3 tests skipped when `E2E_API_WRITES` is unset (API write tests require real Entra access token)

**Lighthouse CI — `warmupRuns: 1` added:**
- One unmeasured warm-up request per URL now precedes the 3 measured runs. Eliminates the cold-start outlier (first run ~40% slower due to Node.js JIT and fetch-cache priming) that was inflating the measured median above the 2500ms LCP threshold.

**webkit date input pattern:**

`page.fill()` on `type="date"` inputs in webkit can be intercepted by the native date-picker widget, preventing React's synthetic `onChange` from firing. Server-rendered headings also appear before React hydration completes, causing a race when tests interact immediately after a visibility check.

Use the `fillDateInput()` helper in `e2e/critical-flows.spec.ts`. It accepts a `Page` or a scoped `Locator` — pass a container locator when the same `id` appears in multiple DOM subtrees (e.g. SSR renders both the desktop `FilterPanel` and the Sheet's `FilterPanel`):

```ts
async function fillDateInput(root: Page | Locator, selector: string, value: string) {
  await root.locator(selector).evaluate((el, val: string) => {
    Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')!.set!.call(el, val)
    el.dispatchEvent(new Event('input', { bubbles: true }))
    el.dispatchEvent(new Event('change', { bubbles: true }))
  }, value)
}
```

Scope date and filter interactions to `[data-testid="desktop-filter-panel"]` on the patterns page — SSR renders both the desktop `FilterPanel` and the Sheet's `FilterPanel` into the HTML, producing duplicate `#date-from`/`#date-to` IDs and duplicate tag checkboxes. Strict-mode violations occur if locators are unscoped:

```ts
const desktopPanel = page.locator('[data-testid="desktop-filter-panel"]')
await expect(desktopPanel.locator('#date-from')).toBeVisible({ timeout: 10_000 })
await fillDateInput(desktopPanel, '#date-from', '2024-01-01')
```

In `beforeEach`, wait for the specific input element rather than a parent heading:
```ts
// Heading may be in server HTML before React hydrates — wait for the input itself
await expect(desktopPanel.locator('#date-from')).toBeVisible({ timeout: 10_000 })
```

When clicking multiple tag checkboxes sequentially, wait for the first checkbox `checked` state before clicking the second — confirms React has re-rendered with the updated URL params before the next click:
```ts
await firstTag.click()
await expect(page).toHaveURL(/tags=/, { timeout: 10_000 })
await expect(firstTag).toBeChecked({ timeout: 5_000 }) // wait for re-render before next click
await secondTag.click()
```

**Next.js soft navigation — `toHaveURL` vs `waitForURL`:**

Next.js App Router uses `history.pushState` for client-side navigation (filter changes, search param updates). Playwright's `page.waitForURL()` defaults to `waitUntil: 'load'`, which expects a full navigation lifecycle event — `pushState` never fires one. This causes consistent WebKit test timeouts even though the URL has already changed.

Use `expect(page).toHaveURL()` instead — it polls the current URL via assertion retries and is not tied to navigation events:

```ts
// ❌ Unreliable with Next.js pushState (especially WebKit)
await page.waitForURL(/tags=/, { timeout: 10_000 })

// ✅ Reliable across all browsers
await expect(page).toHaveURL(/tags=/, { timeout: 10_000 })
```

**WebKit URL-encodes commas in query strings:**

When matching comma-separated query param values in URL assertions, WebKit encodes `,` as `%2C` while Chromium keeps a literal comma. Regex patterns must handle both:

```ts
// ❌ Fails in WebKit — comma is %2C not ,
await expect(page).toHaveURL(/tags=[^&]*,/, { timeout: 10_000 })

// ✅ Handles both encodings
await expect(page).toHaveURL(/tags=[^&]*(%2C|,)/i, { timeout: 10_000 })
```

### Phase 7.8 Complete — as of 2026-03-19

Phase 7.8 (Testing Coverage & Quality) audited all test layers. Testing infrastructure confirmed enterprise-grade. Three lightweight tracks implemented; three deferred.

**Testing baseline (Phase 7.8):**
- Frontend: 396/396 Jest tests passing; 76.04% lines / 76.77% branches / 71.70% fn / 75.84% stmt (CI gate: 70%)
- Backend: 114/114 xUnit tests passing; ~85% testable coverage; Codecov upload in CI (9 telemetry tests added in Phase 7.10)
- E2E: 42 tests × 3 browsers; critical flows + auth guards; API-write tests opt-in (`E2E_API_WRITES=true`)
- Lighthouse CI, Chromatic (38 stories), 4 a11y suites — all in CI

**Deferred:** Mutation testing (Stryker, Phase 8), load testing (k6, Phase 8), contract testing (Pact, Phase 9+)

See [`phase7_8_testing_baseline.md`](../test_results/phase7_8_testing_baseline.md) for the full metrics snapshot.

---

### 9.1 E2E Auth Test Strategy

The authenticated E2E tests in `e2e/authenticated-flows.spec.ts` are split into three tiers:

| Tier | Tests | CI Status | Requirement |
|------|-------|-----------|-------------|
| Unauthenticated guards | 4 | Always run | None |
| Authenticated — UI | 4 | Always run (when `AUTH_SECRET` set) | Synthetic session cookie |
| Authenticated — API writes | 3 | **Skipped in CI** | Real Entra access token |

#### Why API-write tests are skipped in CI

The "Authenticated — API writes" tests (create/edit/delete patterns) call the ASP.NET Core API with a JWT bearer token. The backend validates the token against Entra's JWKS endpoint — only tokens issued by the real Entra External ID tenant pass validation. A synthetic session cookie (created via `@auth/core/jwt encode()`) contains a placeholder access token that is rejected by the backend.

Enabling these tests in CI would require:
1. A dedicated test Entra user with Editor and Admin roles
2. The test user's credentials stored in GitHub Secrets
3. A mechanism to obtain a real Entra access token in CI (browser-based OIDC flow or client-credentials grant)
4. Potentially a protected CI environment to prevent credential exposure in PRs

**Current trade-off decision:** This is a single-developer project. Post-deploy validation is covered by the healthcheck in `frontend-container-deploy.yml` (`curl -sf https://<url>` checking for "next-size-adjust" in the response). Manual pre-release testing of create/edit/delete flows is sufficient given the deployment cadence.

#### How to enable API-write tests locally or in a protected environment

```bash
# 1. Log in to the app via browser (creates a real Entra session)
# 2. Export the session cookie to e2e/.auth/admin.json
# 3. Run with the flag set:
E2E_API_WRITES=true npx playwright test e2e/authenticated-flows.spec.ts
```

If enabling in CI: set `E2E_API_WRITES: true` in the `e2e-tests` job environment (`.github/workflows/test.yml`, line ~208) and store real Entra test user credentials in GitHub Secrets. Use a protected environment to prevent exposure in fork PRs.

---

### Next Phase: Phase 8
- Community Features, Integrations & Performance (includes Stryker mutation testing, k6 load testing)

See [../project/ROADMAP.md](../project/ROADMAP.md) for the full phase plan.

### Maintenance
- Update tests as features are added/modified
- Review coverage reports monthly
- Run full manual test suite before major releases
- Archive test results in `documentation/test_results/`

---

For test implementation examples, see:
- Backend: `backend/tests/`
- Frontend: `__tests__/` and `*.test.tsx` files throughout the project
- E2E: `e2e/critical-flows.spec.ts`
- Manual tests: `documentation/testing/MANUAL_TEST_PLAN.md`
- Results: `documentation/test_results/`
