# Phase 6.4 — Testing Infrastructure Implementation Plan

**Last Updated:** 2026-03-02
**Audience:** Developers, DevOps
**Purpose:** Implementation plan for Phase 6.4 — adding Lighthouse CI, visual regression testing (Chromatic), and Playwright cross-browser matrix to the CI/CD pipeline.

**Dependencies:** Phase 6.3 complete ✅ (Storybook is required for Chromatic)
**Status:** 🔜 Next

---

## Overview

Three additions to the testing pipeline:

| Tool | Purpose | Gate |
|------|---------|------|
| Lighthouse CI (`@lhci/cli`) | Performance metrics (LCP, FCP, TTI) | Blocks deploy on regression |
| Chromatic | Visual regression against Storybook stories | Blocks deploy on unreviewed visual changes |
| Playwright cross-browser | Chromium + Firefox + WebKit E2E coverage | Blocks deploy on any browser failure |

---

## 1. Lighthouse CI

### Package & Config

Install:
```bash
npm install --save-dev @lhci/cli
```

Create `lighthouserc.yml` at project root:
```yaml
ci:
  collect:
    url:
      - http://localhost:3000
      - http://localhost:3000/patterns
    numberOfRuns: 3
    startServerCommand: npm run start
    startServerReadyPattern: "ready on"
  assert:
    assertions:
      largest-contentful-paint:
        - error
        - maxNumericValue: 2500
      first-contentful-paint:
        - error
        - maxNumericValue: 1800
      interactive:
        - error
        - maxNumericValue: 5000
      categories:performance:
        - error
        - minScore: 0.80
  upload:
    target: temporary-public-storage
```

### CI Integration

Add `lhci` job to `.github/workflows/frontend-container-deploy.yml` **after** the build step, **before** the deploy step:

```yaml
lhci:
  name: Lighthouse CI
  needs: build
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    - run: npm ci
    - run: npm run build
      env:
        NEXT_PUBLIC_API_BASE_URL: ${{ secrets.LHCI_API_BASE_URL }}
    - run: npm run start &
    - run: npx wait-on http://localhost:3000 --timeout 60000
    - run: npx lhci autorun
      env:
        LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

Add `LHCI_API_BASE_URL` and `LHCI_GITHUB_APP_TOKEN` to GitHub Secrets.

---

## 2. Visual Regression — Chromatic

Chromatic integrates directly with the existing Storybook setup (38 stories already in place).

### Package

```bash
npm install --save-dev chromatic
```

Add npm script to `package.json`:
```json
"chromatic": "chromatic --project-token=$CHROMATIC_PROJECT_TOKEN"
```

### CI Integration

Add `chromatic` job to `.github/workflows/frontend-container-deploy.yml`, running in parallel with `lhci`:

```yaml
chromatic:
  name: Chromatic Visual Regression
  needs: build   # or runs independently
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0   # required for Chromatic baselines
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    - run: npm ci
    - run: npx chromatic --project-token=${{ secrets.CHROMATIC_PROJECT_TOKEN }} --exit-zero-on-changes
```

Add `CHROMATIC_PROJECT_TOKEN` to GitHub Secrets (from https://www.chromatic.com).

**Note:** `--exit-zero-on-changes` on first run lets you establish a baseline. Remove this flag once the baseline is approved to make it a hard gate.

---

## 3. Playwright Cross-Browser Matrix

### Config Changes (`playwright.config.ts`)

Add Firefox and WebKit to the `projects` array:

```ts
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
  { name: 'webkit',   use: { ...devices['Desktop Safari'] } },
],
```

### CI Integration

Update the existing E2E job in `.github/workflows/e2e.yml` (or equivalent) to run a matrix:

```yaml
e2e:
  strategy:
    matrix:
      browser: [chromium, firefox, webkit]
    fail-fast: false
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    - run: npm ci
    - run: npx playwright install --with-deps ${{ matrix.browser }}
    - run: npx playwright test --project=${{ matrix.browser }}
      env:
        BASE_URL: http://localhost:3000
        # ... other required env vars
```

### Browser-Agnostic Test Considerations

Before enabling WebKit and Firefox, audit existing E2E tests for:
- Chrome-specific APIs (e.g., `page.evaluate(() => chrome.*)`) — none expected but verify
- Timing assumptions — use `waitForSelector` / `waitForLoadState('domcontentloaded')` rather than `networkidle` (already noted as flaky in CI)
- File download tests — browser-specific handling may differ

---

## Files to Create / Modify

| File | Action |
|------|--------|
| `lighthouserc.yml` | Create (project root) |
| `package.json` | Add `chromatic` script |
| `playwright.config.ts` | Add firefox + webkit projects |
| `.github/workflows/frontend-container-deploy.yml` | Add `lhci` + `chromatic` jobs |
| `.github/workflows/e2e.yml` (or equivalent) | Add browser matrix |

---

## Verification Checklist

1. `npx lhci autorun` passes locally against `npm run build && npm run start`
2. Chromatic baseline established — all 38 stories accepted in Chromatic dashboard
3. `npx playwright test --project=firefox` passes (all existing E2E tests)
4. `npx playwright test --project=webkit` passes (all existing E2E tests)
5. CI pipeline: `lhci` job green on a PR
6. CI pipeline: `chromatic` job green with no unreviewed changes
7. CI pipeline: E2E matrix green on all three browsers
8. A deliberate performance regression (e.g., add `Thread.Sleep`) causes `lhci` to fail and block the deploy
