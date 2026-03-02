# Phases 6.5–6.7 — CMS Content Migration Implementation Plan

**Last Updated:** 2026-03-02
**Audience:** Frontend Developers, Architect
**Purpose:** Implementation plan for migrating 300+ hardcoded strings from frontend components into the live Strapi CMS (already production-deployed as of Phase 5.5).

**Dependencies:** Phase 6.4 complete | CMS live at https://ca-aipatterns-cms-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
**Status:** 🔜 Upcoming (after Phase 6.4)

---

## Context

The CMS infrastructure (Strapi 5, Azure MySQL, Blob Storage, ISR webhook, `lib/cms/` client) is fully live in production. The frontend still renders all UI strings as hardcoded values in components. This phase migrates that content page by page via the existing `fetchStrapi()` / `getXxx()` query functions.

CMS component schemas are documented in [`documentation/cms-components/`](../cms-components/COMPONENT_INDEX.md). Strapi admin: http://localhost:1337/admin (dev) or the production URL above.

---

## Integration Strategy

Three stages, applied per page/component:

1. **Fetch + fallback**: Page fetches CMS content at build time (ISR). If Strapi is unreachable (`CmsUnavailableError`), fall back to hardcoded defaults. Zero risk.
2. **Replace hardcoded strings**: Pass CMS values as props to client components. Hardcoded fallbacks remain in place.
3. **Remove fallbacks** (Phase 6.7): Once CMS is confirmed stable and seed data is verified, remove hardcoded fallback strings. Keep a minimal emergency fallback for critical strings only (site name, nav).

---

## Caching Strategy

| Content Type | `revalidate` | Rationale |
|-------------|-------------|-----------|
| `global` | 600s (10 min) | Rarely changes — nav/footer |
| Page Single Types (home, about, docs) | 300s (5 min) | Marketing content, infrequent edits |
| Label Single Types (listing, detail, form) | 3600s (1 hr) | UI labels almost never change |
| `login-page`, `error-page`, `not-found-page` | 3600s (1 hr) | Very static |

---

## Phase 6.5 — Page Content

### Files to Modify

| Priority | File | CMS Single Type / Change |
|----------|------|--------------------------|
| 1 | `app/layout.tsx` | `global` → nav links, footer, site metadata, skip-link label, sign in/out labels |
| 2 | `components/layout/Header.tsx` | Use global nav from CMS |
| 2 | `components/layout/Footer.tsx` | Use global footer config from CMS |
| 2 | `components/layout/Navigation.tsx` | Use global nav from CMS |
| 2 | `components/layout/UserMenu.tsx` | Use global signIn/signOut/userMenu labels |
| 2 | `components/shared/Logo.tsx` | Use global siteName |
| 3 | `app/page.tsx` | `home-page` → render Dynamic Zone |
| 3 | `components/home/Hero.tsx` | Accept CMS props (heading, subheading, CTAs) |
| 3 | `components/home/StatsSection.tsx` | Accept CMS props (stat items) |
| 3 | `components/home/FeaturedPatterns.tsx` | Accept CMS props (headings/labels; patterns still from API) |
| 3 | `components/home/CTASection.tsx` | Accept CMS props |
| 4 | `app/about/page.tsx` | `about-page` → render Dynamic Zone |
| 5 | `app/docs/page.tsx` | `docs-page` → render Dynamic Zone |
| 6 | `app/login/page.tsx` + `LoginForm.tsx` | `login-page` → fetch server-side, pass labels as props |
| 7 | `app/not-found.tsx` | `not-found-page` → heading, message, back button |
| 8 | `app/error.tsx` | `error-page` → title, description, button labels (wrap in try/catch — must never fail) |

**Query functions to use** (already exist in `lib/cms/queries.ts`):
`getGlobal()`, `getHomePage()`, `getAboutPage()`, `getDocsPage()`, `getLoginPage()`, `getNotFoundPage()`, `getErrorPage()`

---

## Phase 6.6 — Pattern UI Labels

### Files to Modify

| Priority | File | CMS Single Type |
|----------|------|----------------|
| 9 | `app/patterns/page.tsx` | `pattern-listing-labels` → fetch and pass to children |
| 9 | `components/patterns/SearchBar.tsx` | Accept labels as props |
| 9 | `components/patterns/FilterPanel.tsx` | Accept labels as props |
| 9 | `components/patterns/SortSelector.tsx` | Accept labels as props |
| 9 | `components/patterns/EmptyState.tsx` | Accept labels as props |
| 9 | `components/patterns/Pagination.tsx` | Accept labels as props |
| 10 | `app/patterns/[slug]/page.tsx` | `pattern-detail-labels` → fetch and pass to children |
| 10 | `components/patterns/details/*.tsx` | Accept labels as props |
| 11 | `app/patterns/new/page.tsx` + `app/patterns/[slug]/edit/page.tsx` | `pattern-form-labels` → fetch server-side, pass to PatternForm |
| 11 | `components/patterns/PatternForm.tsx` | Accept labels as props |

**Query functions to use** (already exist in `lib/cms/queries.ts`):
`getPatternListingLabels()`, `getPatternDetailLabels()`, `getPatternFormLabels()`

---

## Phase 6.7 — Tests & Documentation

### Test Tasks

1. **Unit tests for CMS queries** — mock `fetchStrapi` in `lib/cms/__tests__/queries.test.ts`; verify each query returns correctly shaped data
2. **Fallback tests** — mock `fetchStrapi` to throw `CmsUnavailableError`; verify each component renders its hardcoded defaults
3. **Coverage gate** — run `npm run test:ci`; all four metrics (stmt/branch/fn/line) must remain ≥ 70%
4. **Full test suite** — verify all 350+ frontend tests still pass after label prop threading
5. **Backend tests** — no backend changes; `dotnet test` must remain 105/105

### Documentation Tasks

1. Update `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` with decisions made during this phase (CMS fallback strategy, ISR revalidation values, prop-threading pattern)
2. Update `CLAUDE.md` current phase to 6.7 (complete); Phase 7 next
3. Delete this plan file (`PHASE_CMS_CONTENT_PLAN.md`) per governance lifecycle rules

---

## Verification Checklist

1. All pages render CMS content **identical to current hardcoded content** (seed data matches)
2. Stop Strapi (`docker compose stop strapi`) → frontend still renders with fallback content, no errors
3. Edit hero heading in Strapi admin → refresh frontend → new heading appears within 5-minute revalidation window
4. `npm run build` succeeds with `STRAPI_URL` pointing to production CMS
5. `npm run test:ci` — all four coverage metrics ≥ 70%
6. Backend: `dotnet test` — 105/105 passing, no regressions
