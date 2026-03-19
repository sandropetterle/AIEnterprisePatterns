# Phase 6 Test Results Snapshot

**Created:** 2026-03-19 (Phase 7.8 — Testing Coverage & Quality)
**Covers:** Phases 6.3 through 6.8 testing additions
**Purpose:** Audit trail for testing infrastructure added in Phase 6. The previous test results doc (`phase5_1_auth_test_results.md`) covered only through Phase 5.1; this document captures everything added in Phases 6.3–6.8.

---

## Phase 6.3 — Documentation Reuse & Storybook (2026-03-02)

**Changes:** 38 Storybook stories published; no new Jest or xUnit tests.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | 354/354 | ✅ Pass |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass |
| E2E (Playwright — Chromium) | 20/20 | ✅ Pass |

**Frontend coverage:** 71.70% fn / 75.84% stmt / 76.77% branch / 75.97% lines (CI gate: 70% all metrics)

**Storybook:** 38 stories colocated with components (`*.stories.tsx`). Config in `.storybook/`; shared fixtures in `.storybook/fixtures.ts`; mock for `next-auth/react` in `.storybook/mocks/next-auth-react.tsx`.

---

## Phase 6.4 — Testing Infrastructure: Lighthouse CI, Chromatic, Cross-Browser E2E (2026-03-03)

**Changes:** Lighthouse CI, Chromatic visual regression, and Playwright cross-browser matrix added to CI.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | 354/354 | ✅ Pass (unchanged) |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass (unchanged) |
| E2E (Playwright — Chromium + Firefox + WebKit) | 20/20 per browser | ✅ Pass |
| Performance (Lighthouse CI) | 2 URLs × 3 runs | ✅ Pass |
| Visual (Chromatic) | 38 stories | ✅ Published |

**E2E cross-browser matrix:** All 20 critical-flow tests run on 3 browsers in parallel via `strategy.matrix`. `fail-fast: false` — all browsers report independently.

**Lighthouse CI thresholds:**
- LCP < 2500ms
- FCP < 1800ms
- TTI < 5000ms
- Performance ≥ 0.80

**Chromatic:** `--exit-zero-on-changes` + `continue-on-error: true` until baseline is accepted. Once baseline is approved, both flags are removed to make visual regression a hard deploy gate.

**Updated deploy gate:** `run-tests` → (`build-and-push` + `lhci` + `chromatic`) in parallel → `deploy`.

---

## Phase 6.5 — CMS Content Migration: Page Content (2026-03-03)

**Changes:** `CmsErrorPageProvider` context + `useCmsErrorPage` hook added for error boundary CMS labels.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | 354/354 | ✅ Pass |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass (unchanged) |
| E2E | 20/20 | ✅ Pass (unchanged) |

**New tests:** 4 (CmsErrorPageProvider: default labels, CMS labels, partial override, outside-provider default). Test count 350 → 354.

---

## Phase 6.6 — CMS Content Migration: Pattern UI Labels (2026-03-03)

**Changes:** CMS label Single Types wired into 13 components; E2E suite expanded with authenticated flows.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | 354/354 | ✅ Pass (unchanged) |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass (unchanged) |
| E2E (Playwright — all 3 browsers) | 42/42 | ✅ Pass |

**E2E expansion:** 20 → 42 tests (auth + API write tests added). 2 API-write tests skipped when `E2E_API_WRITES` is unset (require real Entra token).

**Lighthouse fix:** `warmupRuns: 1` added to `lighthouserc.yml` — eliminates cold-start outlier (first run ~40% slower due to Node.js JIT + fetch-cache priming).

**WebKit patterns documented:** `fillDateInput()` helper for date inputs; `expect(page).toHaveURL()` for soft-navigation; `/param=[^&]*(%2C|,)/i` regex for comma-encoded query params.

---

## Phase 6.7 — CMS Content Migration: Tests & Documentation (2026-03-04)

**Changes:** CMS query tests added; documentation updated to reflect CMS integration.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | ~354+ | ✅ Pass |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass (unchanged) |
| E2E | 42/42 | ✅ Pass (unchanged) |

---

## Phase 6.8 — Infrastructure as Code & Management (2026-03-17)

**Changes:** `AddInfrastructure()` extension extracted from `Program.cs`; Bicep IaC modules added. No new application tests.

| Layer | Count | Status |
|-------|-------|--------|
| Frontend (Jest + RTL) | ~354+ | ✅ Pass |
| Backend (xUnit + Moq) | 105/105 | ✅ Pass |
| E2E | 42/42 | ✅ Pass |
| Bicep validation | main.bicep | ✅ az bicep build passes |

**CI addition:** `validate-infrastructure` job added to `test.yml` — runs `az bicep build --file infrastructure/main.bicep` on every PR and push to main.

---

## Summary: Testing Infrastructure Added in Phase 6

| Capability | Added In | Tooling |
|-----------|---------|---------|
| Storybook stories (38) | 6.3 | Storybook 8 |
| Visual regression | 6.4 | Chromatic |
| Performance CI gate | 6.4 | Lighthouse CI (`@lhci/cli`) |
| Cross-browser E2E matrix | 6.4 | Playwright (Chromium + Firefox + WebKit) |
| Authenticated E2E (UI checks) | 6.6 | Playwright + direct session injection |
| Authenticated E2E (API writes, opt-in) | 6.6 | `E2E_API_WRITES=true` |
| Bicep template validation | 6.8 | Azure CLI + Bicep |
