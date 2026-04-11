# Project Roadmap

**Last Updated:** 2026-04-11 (Phase CMS Script Fixes complete — 8 Windows/Git Bash bugs fixed, mint-token.sh added; Phase 7 verification next)
**Audience:** Project Managers, Solutions Architects, all stakeholders
**Purpose:** Track project phases, completion status, objectives, and deliverables. This is the project management view — what was built, in what order, and what comes next.

---

## Phase Status Summary

| Phase | Status | Date | Key Deliverables |
|-------|--------|------|-----------------|
| Phase 1 | ✅ Complete | 2024-Q1 | Frontend with mock data (Home, Listing, Detail pages) |
| Phase 2 | ✅ Complete | 2024-Q1 | ASP.NET Core 8 backend, EF Core, CRUD endpoints, voting |
| Phase 3 | ✅ Complete | 2026-02-10 | Frontend-backend integration, Strapi CMS initial setup |
| Phase 4 | ✅ Complete | 2026-02-11 | Azure deployment, CI/CD pipelines, security hardening (38 items) |
| Phase 4.5 | ✅ Complete | 2026-02-19 | Automated tests, monitoring, operational runbooks |
| Phase 5.1 | ✅ Complete | 2026-02-19 | Authentication & Authorization (Entra External ID) |
| Phase 5.2 | ✅ Complete | 2026-02-19 | Pattern Management UI (create/edit/delete forms) |
| Phase 5.3 | ✅ Complete | 2026-02-20 | Advanced Search & Discovery (full-text, date range, saved searches) |
| Phase 5.4 | ✅ Complete | 2026-02-20 | Accessibility Improvements (WCAG 2.1 AA) |
| Phase 5.5 | ✅ Complete | 2026-02-26 | CMS Infrastructure (Strapi 5, Azure Container App, MySQL, Blob Storage, ISR webhook) |
| Phase 6.1 | ✅ Complete | 2026-02-27 | UI/UX Polish (dark mode, skeleton loaders, animations, next/image) |
| Phase 6.2 | ✅ Complete | 2026-02-27 | Related Patterns endpoint (backend + frontend, cached) |
| Phase 6.3 | ✅ Complete | 2026-03-02 | Documentation Reuse & Storybook (API ref, CMS component ref, 38 stories, governance) |
| **Phase 6.4** | ✅ Complete | 2026-03-03 | Testing infrastructure (Lighthouse CI, Chromatic, Playwright cross-browser matrix) |
| **Phase 6.5** | ✅ Complete | 2026-03-03 | CMS Content Migration — page content (Logo siteName, Header, CmsErrorPageProvider, error.tsx) |
| **Phase 6.6** | ✅ Complete | 2026-03-03 | CMS Content Migration — pattern UI labels (listing, detail, form) |
| **Phase 6.7** | ✅ Complete | 2026-03-04 | CMS Content Migration — tests & documentation |
| **Phase 6.8** | ✅ Complete | 2026-03-17 | Infrastructure as Code & Management (Bicep IaC, script cleanup, Infrastructure .NET project) |
| **Phase 7** | ✅ Complete | 2026-03-19 | Quality & Hardening Evaluation (10-area audit: deps, security, infra, CI/CD, containers, tests, docs, observability) |
| **Phase 7.11** | ✅ Complete | 2026-03-23 | Infrastructure Drift Resolution & Live Hardening (30 drift items, 6 tracks — Bicep corrections, resource locks, KV diagnostics, MySQL SSL, alert email) |
| **Phase CMS Cold Storage** | 🔄 In Progress | 2026-04-09– | Move Strapi from live Azure to local-only; git-committed backups; compile-time fallback content; Azure MySQL + Container App deleted; IaC/code cleanup + docs/Decision 65 complete (Phases 1–6 done, ~€14-16/mo saved); Script Fixes complete (8 bugs, mint-token.sh); Phase 7 verification next |
| Phase 8 | 📋 Future | TBD | Community features, exports, performance, advanced content |
| Phase 9 | 📋 Future | TBD | Enterprise features, i18n, AI-powered features |

---

## Completed Phases

### Phase 1 — Frontend with Mock Data
Built the complete frontend UI against mock data: Home page, Patterns Listing page, Pattern Detail page.

### Phase 2 — Backend
Implemented ASP.NET Core 8 Web API with Clean Architecture, EF Core code-first database, CRUD endpoints, and voting endpoint.

### Phase 3 — Integration
Connected the frontend to the live backend API, replaced mock data, and created the initial Strapi CMS project (SQLite dev, content model scaffolded).

### Phase 4 — Azure Deployment & Production Readiness (2026-02-11)
**38 remediation items completed:**
- 4 Critical security issues resolved
- 10 High priority improvements implemented
- 20 Medium priority enhancements completed
- 4 DevOps/CI-CD improvements finalized

Key deliverables: Azure Container Apps + App Services deployment, GitHub Actions CI/CD (4 workflows), Azure Key Vault, Application Insights, Clean Architecture enforcement, performance optimizations, security hardening.

### Phase 4.5 — Testing Foundation (2026-02-19)
Established automated test infrastructure and operational readiness before Phase 5 feature development.

Key deliverables: xUnit test projects, Jest + React Testing Library setup, Playwright E2E setup, CI/CD test integration, Azure monitoring alerts, operational runbooks (MONITORING_GUIDE, DISASTER_RECOVERY, INCIDENT_RESPONSE, RUNBOOK).

### Phase 5 — Authentication & Core Features (2026-02-19/20)
**5.1 Authentication:** Auth.js v5 + Azure Entra External ID (OIDC). JWT sessions, Admin/Editor/Viewer roles, provider-agnostic design.

**5.2 Pattern Management UI:** Pattern creation form, edit form, delete with AlertDialog confirmation, draft/publish workflow.

**5.3 Advanced Search & Discovery:** Full-text search, date range filtering, multi-tag AND/OR mode, search autocomplete, recently viewed (localStorage), saved searches (localStorage).

**5.4 Accessibility:** WCAG 2.1 AA compliance — skip-to-content, focus indicators, ARIA attributes, screen reader support, jest-axe integration.

### Phase 5.5 — CMS Infrastructure (2026-02-26)
Full Strapi 5 production deployment for the headless CMS layer:
- Strapi 5 project (`cms/`) with TypeScript, Docker, SQLite (dev) / MySQL (prod)
- Azure infrastructure: MySQL Flexible Server (B1ms), Container App, Blob Storage (media)
- CI/CD workflow (`cms-container-deploy.yml`), Docker image via ACR
- Seed script (`cms/data/seed.ts`) populating all 10 Single Types from hardcoded content
- On-demand ISR revalidation webhook (`app/api/revalidate/route.ts`) — Strapi triggers on publish/update/delete
- `lib/cms/` client, types, queries, Dynamic Zone renderer, CmsUnavailableError with fallbacks

### Phase 6.1 — UI/UX Polish (2026-02-27)
Dark mode (system/light/dark toggle with localStorage persistence and anti-flash script), CSS animations (slide-up hero, fade-in sections, card hover lift), enhanced skeleton loaders, next/image integration for Strapi media.

### Phase 6.2 — Related Patterns Endpoint (2026-02-27)
`GET /api/patterns/{slug}/related` — category-first + tag-overlap algorithm, vote-sorted, cached 5 minutes. Removed client-side computation (no more fetch-100-patterns approach).

### Phase 6.3 — Documentation Reuse & Storybook (2026-03-02)
Four-pillar documentation and reuse infrastructure:
- **API Reference** (`documentation/api/`): `API_REFERENCE_INDEX.md`, `PATTERNS_API.md`, `AUTH_API.md`, `HEALTH_API.md`
- **CMS Component Reference** (`documentation/cms-components/`): COMPONENT_INDEX + 4 namespace pages covering all 26 Strapi components with field tables, "Used By" map, dependency diagram (diagram #14)
- **Storybook UI Catalog** (`.storybook/`): 38 story files colocated with components, `@storybook/nextjs`, a11y + themes addons, shared fixtures, next-auth mock
- **Governance** (`documentation/GOVERNANCE.md`, `DOCUMENTATION_INDEX.md`, `CLAUDE.md`): lifecycle rules, folder purposes, stakeholder reading paths, single-source-of-truth table

---

## Completed Phases (continued)

### Phase 6.4 — Testing Infrastructure (2026-03-03)
Lighthouse CI performance gates (LCP < 2.5s, FCP < 1.8s, TTI < 5s, Performance ≥ 80), Chromatic visual regression against the 38-story Storybook catalog, Playwright E2E cross-browser matrix (Chromium, Firefox, WebKit). Deploy in `frontend-container-deploy.yml` now requires `lhci` + `chromatic` + `build-and-push` before proceeding.

**Required GitHub Secrets to configure:** `LHCI_API_BASE_URL`, `LHCI_GITHUB_APP_TOKEN` (optional), `CHROMATIC_PROJECT_TOKEN`.

### Phase 6.5 — CMS Content Migration: Page Content (2026-03-03)
Global layout, home page, about, docs, auth pages — all CMS-driven with hardcoded fallbacks for build safety:
- `Logo.tsx`: optional `siteName` prop (from `global.siteName`)
- `Header.tsx`: threads `siteName` to Logo
- New `CmsErrorPageProvider` context — fetched at root layout, injected via client context so `error.tsx` (must be `'use client'`) can access CMS labels
- `app/layout.tsx`: fetches `getGlobal()` + `getErrorPage()` in parallel; wraps children in `CmsErrorPageProvider`; passes `siteName` to Header
- All other page/component CMS wiring (home, about, docs, login, not-found) was already complete from Phase 5.5

### Phase 6.6 — CMS Content Migration: Pattern UI Labels (2026-03-03)
All pattern listing, detail, and form UI strings migrated to CMS-driven props with hardcoded fallbacks:
- Prop-threading architecture: server pages fetch `CmsPatternListingLabels` / `CmsPatternDetailLabels` / `CmsPatternFormLabels` and pass as props; FilterPanel/FilterSheet accept a single `labels?` object (avoids prop explosion); leaf components use individual optional props defaulting to previous hardcoded strings
- Components updated: SearchBar, SortSelector, DateRangeFilter, SavedSearches, RecentlyViewedSidebar, FilterPanel, FilterSheet, VotingButton, Breadcrumb, PatternForm
- Fixed bug: CMS fallback `sortOptions` values were incorrect (`'newest'` → `'recent'`, etc.) — now match the backend `SortOption` type
- Template placeholders: `{count}`, `{slug}`, `{max}` replaced at render time in VotingButton and PatternForm
- 354/354 frontend tests passing; Decision 45 added to TECHNICAL_DECISIONS_LOG.md

---

### Phase 6.7 — CMS Content Migration: Tests & Documentation (2026-03-04)
36 unit tests for all 10 CMS query functions (`lib/cms/__tests__/queries.test.ts`), mocking `global.fetch` to bypass SWC's non-configurable ES module exports. 390/390 frontend tests passing; all 4 coverage metrics ≥ 70%. Decision 49 added (CMS query test strategy).

---

## Active Phases

### Phase 6.8 — Infrastructure as Code & Management (2026-03-17) ✅

Four tracks completed:
1. **Security cleanup** — deleted 3 plaintext credential files (`sql-credentials.txt`, `github-secrets-values.txt`, `DEPLOYMENT_SUMMARY.txt`) from disk (never tracked in git)
2. **Script consolidation** — deleted 7 legacy/redundant deployment scripts; renamed `setup-github-secrets-fixed.ps1` → `setup-github-oidc.ps1`; updated `github-secrets-setup.md`
3. **Bicep IaC** — `infrastructure/` with `main.bicep` + 7 modules (monitoring, acr, keyvault, sql, cms, containerAppsEnvironment, containerApps); `deploy.ps1`; `infrastructure/README.md`; `validate-infrastructure` CI job added to `test.yml`
4. **Infrastructure .NET project** — `AddInfrastructure()` extension in `AIEnterprisePatterns.Infrastructure` extracts AppInsights, MemoryCache, TimeProvider, HealthChecks, RateLimiter from `Program.cs`; 105/105 backend tests pass

**Implementation plan:** Deleted per governance (1 phase after completion). Decisions preserved in [TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md) and [INFRASTRUCTURE_MANAGEMENT.md](../operations/INFRASTRUCTURE_MANAGEMENT.md).

---

## Completed Phases (continued)

### Phase 7 — Quality & Hardening Evaluation (2026-03-19) ✅
**Priority:** HIGH | **Dependencies:** Phase 6 complete | **Completed:** 2026-03-19

Systematic 10-area audit ensuring enterprise best-in-class standards. Each area evaluated independently, findings consolidated, then selectively implemented.

| Area | Scope | Effort | Status |
|------|-------|--------|--------|
| 7.1 | Dependency Audit — Frontend | Light | ✅ Complete — overrides, dep updates, CMS updates, npm audit CI gate, Dependabot |
| 7.2 | Dependency Audit — Backend | Light | ✅ Complete — CVE-2024-43483 patched, .NET 8.x servicing updates, NuGet audit CI gate, Dependabot groups |
| 7.3 | Frontend Code Quality & Security | Medium | ✅ Complete — CMS HTML sanitization (isomorphic-dompurify), CSP base-uri/object-src/narrowed img-src, 429 rate-limit UX, eslint-plugin-security, source maps verified |
| 7.4 | Backend Code Quality & Security | Medium | ✅ Complete — CORS/HSTS hardening, atomic vote, exception middleware, validation cleanup |
| 7.5 | Infrastructure as Code & Azure Security | Medium | ✅ Complete — resource tags, parameterized names, KV purge protection + 90-day soft-delete, SQL diagnostics, alert action group, App Insights to KV |
| 7.6 | CI/CD Pipeline Quality | Medium | ✅ Complete — SHA pinning, permissions, concurrency, rollback bug fix, Dependabot Docker, e2e gate |
| 7.7 | Docker & Container Security | Light | ✅ Complete — SHA pinning (all 3 Dockerfiles), Alpine backend (~63% smaller, no curl), compose cleanup, .dockerignore hardening |
| 7.8 | Testing Coverage & Quality | Medium | ✅ Complete — test result docs (phase6 + 7.8 baseline), E2E auth strategy documented, Decision 60 |
| 7.9 | Documentation Completeness & Accuracy | Light | ✅ Complete — archived stale test results, IaC cross-refs in 4 ops docs, CMS phase status, auth guide header, dead links, Decision 61 |
| 7.10 | Production Readiness & Observability | Medium | ✅ Complete — robots.txt/sitemap, metadataBase fix, IaC health probes, web env vars, business telemetry, Lighthouse a11y gate, Decision 62 |

**Key deliverables:** 62 technical decisions logged (63 with Phase 7.11); 114 backend tests / 396 frontend tests passing; all 5 tracks complete (alert action group, SEO, IaC health probes, business telemetry, docs/CI). System confirmed production-ready for a learning project on Azure Container Apps.

**Implementation plan:** [PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md)

---

### Phase 7.11 — Infrastructure Drift Resolution & Live Hardening (2026-03-23) ✅
**Priority:** HIGH | **Dependencies:** Phase 7 complete | **Status:** ✅ Complete

Live Azure subscription audit revealed **30 configuration drift items** between the Bicep IaC (written in Phase 6.8) and the actual deployed resources (provisioned earlier via scripts/portal). The Bicep was never fully applied to the live environment.

**6 implementation tracks (all complete):**

| Track | Scope | Status |
|-------|-------|--------|
| 1 | Fix Bicep to match live (admin logins, DB size, maxReplicas, CMS env vars, storage location) | ✅ |
| 2 | Security hardening (KV RBAC, purge protection, Storage TLS 1.2, MySQL SSL enforcement) | ✅ |
| 3 | IaC hardening (resource locks on KV/SQL/MySQL/Storage, KV audit diagnostics, SQL backup policy) | ✅ |
| 4 | Tags + cleanup (tags via Bicep, orphaned MySQL test server deletion documented) | ✅ |
| 5 | Documentation (Decision 63, `.github/CODEOWNERS`, `.github/SECURITY.md`) | ✅ |
| 6 | Alert email (`sandropetterle@hotmail.com` in `main.parameters.prod.json`) | ✅ |

**Key deliverables:** 63 technical decisions logged; Bicep IaC now accurately reflects live state; resource locks prevent accidental deletion; KV audit trail enabled; MySQL SSL enforced; alert notifications wired.

**Implementation plan:** [PHASE_7_11_INFRASTRUCTURE_DRIFT_PLAN.md](PHASE_7_11_INFRASTRUCTURE_DRIFT_PLAN.md)

### Phase CMS Cold Storage — Cost Reduction & Cold Recovery Mode (2026-04-09, In Progress)

Moves Strapi CMS from live Azure hosting to local-only with git-committed backups and compile-time fallback content. All 10 frontend CMS queries already use `safeFetch()` with hardcoded fallbacks — production renders identically with or without a live Strapi instance.

**Cost impact:** ~€14-16/mo saved (MySQL Flexible Server B1ms deletion).

**8 sub-phases:**
| Phase | Status | Deliverable |
|-------|--------|------------|
| Phase 1 | ✅ Complete | `scripts/cms/backup.sh`, `scripts/cms/restore.sh`, initial backup bundle in `backups/cms/2026-04-09/` |
| Phase 2 | ✅ Complete | `scripts/cms/generate-fallbacks.ts`, `lib/cms/queries.ts` fallbacks refreshed from live content with delimited marker regions |
| Phase 3 | ✅ Complete | 3 GitHub Actions workflows (`cms-backup`, `cms-restore-bundle`, `cms-sync-fallbacks`) — `workflow_dispatch`, SHA-pinned, no third-party actions |
| Phase 4 | ✅ Complete | Azure cleanup — `ca-aipatterns-cms-prod` + `mysql-aipatterns-cms` deleted; 8 KV secrets were already purged; `staipatternsmedia` retained |
| Phase 5 | ✅ Complete | IaC + code changes — `cms.bicep` deleted, `cms-container-deploy.yml` deleted, STRAPI_* refs removed from containerApps.bicep + frontend workflow |
| Phase 6 | ✅ Complete | Documentation — Decision 65 (CMS Cold Storage), CMS runbook section, DR §12 (CMS Recovery), CMS_ARCHITECTURE.md §12 ref updated, CLAUDE.md updated |
| **Script Fixes** | ✅ Complete | 8 Windows/Git Bash bugs fixed; `scripts/cms/mint-token.sh` added; `restore.sh` auto-mints token at step [5/5]; `backup.sh` auto-sources `.env.local-token` |
| Phase 7 | 📋 Pending | Verification — backup round-trip, fallback generator idempotency, live smoke tests, cost confirmation (48h post-deletion) |

**Implementation plans:** [PHASE_CMS_COLD_STORAGE_PLAN.md](PHASE_CMS_COLD_STORAGE_PLAN.md) · [PHASE_CMS_SCRIPT_FIXES_PLAN.md](PHASE_CMS_SCRIPT_FIXES_PLAN.md)

---

## Planned Phases

### Phase 8 — Community Features, Integrations & Performance (Future)
**Priority:** MEDIUM → LOW | **Dependencies:** Phase 7 complete

Sub-phases:
- **8.1** User Engagement: commenting, rating, bookmarks, social sharing, activity feed
- **8.2** Export & Integration: PDF export, Markdown export, RSS feed, embedding, webhooks, public API portal
- **8.3** Performance: CDN integration, service worker (offline), load testing suite (k6)
- **8.4** Content Organization: collections/playlists, versioning, dependency tracking, learning paths
- **8.5** Notifications: email alerts, browser push, comment reply notifications
- **8.6** Collaboration: multi-author, review/approval workflow, contributor leaderboard

### Phase 9 — Enterprise & Global Features (Future)
**Priority:** FUTURE | **Dependencies:** Phase 8 complete

- **9.1** Internationalization (i18n): next-i18next, multi-language, RTL support
- **9.2** Advanced Analytics: view tracking, user journey, popular tags visualization
- **9.3** Enterprise Features: multi-tenant, SSO (SAML), compliance/audit logging, white-labeling
- **9.4** AI-Powered: pattern recommendations, similarity detection, natural language search, auto-tagging

---

## Notes

- Phase timelines may be adjusted based on business needs and user feedback
- Technical decisions for each phase are recorded in [../decisions/TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md)
- Completed phase implementation plans: [PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md) (Phase 7), [PHASE_7_11_INFRASTRUCTURE_DRIFT_PLAN.md](PHASE_7_11_INFRASTRUCTURE_DRIFT_PLAN.md) (Phase 7.11)
- Active phase implementation plan: [PHASE_CMS_COLD_STORAGE_PLAN.md](PHASE_CMS_COLD_STORAGE_PLAN.md) (CMS Cold Storage)
- Test results per phase are in [../test_results/](../test_results/)
