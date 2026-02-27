# Testing Strategy

## Overview
This document outlines the testing strategy for the AI Enterprise Patterns Library project. It covers both frontend and backend testing approaches, tools, and best practices to ensure code quality, reliability, and maintainability.

**Related Documents:**
- `documentation/COMPREHENSIVE_TEST_PLAN.md` - Detailed manual test cases organized by feature area (for pre-release validation)
- `documentation/CI_CD_STRATEGY.md` - CI/CD pipeline configuration and quality gates
- `documentation/instructions.md` - Phase-specific testing requirements and deliverables

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
- **Cross-Browser:** Run on Chromium, Firefox, WebKit

### 1.4 Visual Regression Tests (Phase 6+)
- **Purpose:** Detect unintended UI changes across commits
- **Tool:** Percy or Chromatic
- **Scope:** All major pages, responsive breakpoints, dark mode (if implemented)

### 1.5 Performance Tests (Phase 6+)
- **Lighthouse CI:** Automated performance budgets (LCP < 2.5s, TTI < 5s, FCP < 1.8s)
- **API Performance:** Response time < 500ms for standard queries
- **Load Testing:** k6 or Apache JMeter for stress testing

### 1.6 Accessibility Tests (Phase 5+)
- **Automated:** axe-core integration with Jest and Playwright
- **Manual:** Screen reader testing, keyboard navigation validation
- **Standard:** WCAG 2.1 AA compliance

### 1.7 Manual Tests
- **Execution:** Follow `documentation/COMPREHENSIVE_TEST_PLAN.md` for structured manual testing
- **When:** Pre-release smoke testing, exploratory testing, UAT
- **Documentation:** Results stored in `documentation/test_results/`

---

## 2. Tools & Frameworks

### 2.1 Frontend
- **Unit/Integration:** Jest, React Testing Library
- **E2E:** Playwright (selected for cross-browser support and MCP integration)
- **Visual Regression:** Percy or Chromatic (Phase 6+)
- **Performance:** Lighthouse CI (Phase 6+)
- **Accessibility:** axe-core, @axe-core/playwright (Phase 5+)

### 2.2 Backend
- **Unit/Integration:** xUnit, Moq (for mocking dependencies), Entity Framework Core InMemory provider
- **API Testing:** Integration test projects with WebApplicationFactory, Postman (manual), Swagger (dev)
- **Load Testing:** k6 or Apache JMeter (Phase 6+)

### 2.3 Manual Testing
- **Test Execution:** Follow `documentation/COMPREHENSIVE_TEST_PLAN.md` for manual test cases
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
├── test_results/                  # All test execution reports
│   ├── phase5_test_results.md
│   └── test_run_2026-02-13.md
├── TESTING_STRATEGY.md            # This document
└── COMPREHENSIVE_TEST_PLAN.md     # Manual test cases
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
4. **Before Release:** Execute manual test plan (`COMPREHENSIVE_TEST_PLAN.md`)
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
- ✅ All E2E tests must pass (100% pass rate required)
- ✅ Code coverage ≥ 80% for core business logic (Core, Data, Services layers)
- ✅ No critical accessibility violations (axe-core failures block merge)
- ✅ Performance budgets met (Lighthouse scores: Performance > 90, Accessibility > 95)
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
- 🔜 Performance testing (Lighthouse CI) - **Planned for Phase 6.3**
- 🔜 Visual regression testing (Percy/Chromatic) - **Planned for Phase 6.3**

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

### Phase 6.2 Complete — as of 2026-02-27

**Backend (xUnit + Moq):**
- ✅ 105/105 tests passing (~85% testable coverage)
- Core: PatternService (20+ tests incl. related patterns caching)
- Data: PatternRepository (38+ tests incl. GetRelatedPatternsAsync)
- Api/Integration: PatternsController (47+ tests incl. related endpoint + auth scenarios)

**Frontend (Jest + React Testing Library):**
- ✅ 391/391 tests passing
- Coverage: 70%+ stmt/branch/fn/line (CI gate enforced)
- New in Phase 6.1: ThemeProvider (5 tests), ThemeToggle (6 tests)
- New in Phase 6.2: related endpoint integration via `getRelatedPatterns`
- Deleted in Phase 6.2: 50 obsolete client-side filterAndSort + relatedPatterns tests

**E2E (Playwright — Chromium):**
- ✅ 20/20 tests passing (`e2e/critical-flows.spec.ts`)
- Covers: Home Page (3), Browse Patterns (6), Pattern Detail (6), Error Handling (2), Page Titles (3)
- Auth: Direct session injection via `@auth/core/jwt` encode (replaces Entra browser login in CI)
- Network mocking: `page.addInitScript` to override `window.fetch` for vote endpoint (see Decision 12)

**CI/CD Gates (`.github/workflows/test.yml`):**
- ✅ Backend tests → Frontend tests → E2E tests must all pass before deployment

### Next Phase: Phase 6.3
- Lighthouse CI (LCP < 2.5s, TTI < 5s)
- Visual regression testing (Percy or Chromatic)
- Playwright cross-browser (Chromium / Firefox / WebKit)

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
- Manual tests: `documentation/COMPREHENSIVE_TEST_PLAN.md`
- Results: `documentation/test_results/`
