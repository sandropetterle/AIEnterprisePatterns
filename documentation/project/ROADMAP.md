# Project Roadmap

**Last Updated:** 2026-02-27
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
| Phase 6.1 | ✅ Complete | 2026-02-27 | UI/UX Polish (dark mode, skeleton loaders, animations, next/image) |
| Phase 6.2 | ✅ Complete | 2026-02-27 | Related Patterns endpoint (backend + frontend, cached) |
| **Phase 6.3** | 🔜 Next | TBD | Testing infrastructure (Lighthouse CI, visual regression, cross-browser) |
| **Phase 6.4** | 🔜 Next | TBD | CMS Phase 2 — about, docs, login, error, 404 pages |
| **Phase 6.5** | 🔜 Next | TBD | CMS Phase 2 — pattern listing/detail/form labels |
| **Phase 6.6** | 🔜 Next | TBD | CMS Phase 2 — tests & documentation |
| Phase 7 | 📋 Planned | TBD | Community features, exports, performance, advanced content |
| Phase 8 | 📋 Future | TBD | Enterprise features, i18n, AI-powered features |

---

## Completed Phases

### Phase 1 — Frontend with Mock Data
Built the complete frontend UI against mock data: Home page, Patterns Listing page, Pattern Detail page.

### Phase 2 — Backend
Implemented ASP.NET Core 8 Web API with Clean Architecture, EF Core code-first database, CRUD endpoints, and voting endpoint.

### Phase 3 — Integration
Connected the frontend to the live backend API, replaced mock data, and integrated initial Strapi CMS setup.

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

### Phase 6.1 — UI/UX Polish (2026-02-27)
Dark mode (system/light/dark toggle with localStorage persistence and anti-flash script), CSS animations (slide-up hero, fade-in sections, card hover lift), enhanced skeleton loaders, next/image integration for Strapi media.

### Phase 6.2 — Related Patterns Endpoint (2026-02-27)
`GET /api/patterns/{slug}/related` — category-first + tag-overlap algorithm, vote-sorted, cached 5 minutes. Removed client-side computation (no more fetch-100-patterns approach).

---

## Active Phases

### Phase 6.3 — Testing Infrastructure
**Priority:** HIGH | **Dependencies:** Phase 6.2 complete

- Integrate Lighthouse CI into GitHub Actions (LCP < 2.5s, TTI < 5s, FCP < 1.8s)
- Visual regression testing (Percy or Chromatic)
- Playwright cross-browser matrix (Chromium, Firefox, WebKit)
- Block deployments on performance regression

### Phase 6.4 — CMS Phase 2: Page Content Migration
**Priority:** HIGH | **Dependencies:** CMS Phase 1 complete ✅

- About page — Dynamic Zone (mission-block, feature-grid, tech-stack, open-source-info, cta-banner)
- Docs page — Dynamic Zone (quick-nav, doc-section, api-reference, contributing, support-links)
- Login page — server-side label fetching, pass as props to `LoginForm`
- Error page — with try/catch fallback (cannot fail on the error page)
- Not-Found page — content from CMS

### Phase 6.5 — CMS Phase 2: Pattern UI Labels
**Priority:** HIGH | **Dependencies:** Phase 6.4

- `pattern-listing-labels` → SearchBar, FilterPanel, SortSelector, EmptyState, Pagination
- `pattern-detail-labels` → all detail sub-components
- `pattern-form-labels` → PatternForm create/edit

### Phase 6.6 — CMS Phase 2: Tests & Documentation
**Priority:** HIGH | **Dependencies:** Phase 6.5

- Unit tests for new CMS query functions (mock `fetchStrapi`)
- Fallback behavior tests (Strapi unavailable → hardcoded defaults render correctly)
- Verify all 350+ frontend tests still pass after label prop threading
- Update TECHNICAL_DECISIONS_LOG.md with new decisions

---

## Planned Phases

### Phase 7 — Community Features, Integrations & Performance (Planned)
**Priority:** MEDIUM → LOW | **Dependencies:** Phase 6 complete

Sub-phases:
- **7.1** User Engagement: commenting, rating, bookmarks, social sharing, activity feed
- **7.2** Export & Integration: PDF export, Markdown export, RSS feed, embedding, webhooks, public API portal
- **7.3** Performance: CDN integration, service worker (offline), load testing suite (k6)
- **7.4** Content Organization: collections/playlists, versioning, dependency tracking, learning paths
- **7.5** Notifications: email alerts, browser push, comment reply notifications
- **7.6** Collaboration: multi-author, review/approval workflow, contributor leaderboard

### Phase 8 — Enterprise & Global Features (Future)
**Priority:** FUTURE | **Dependencies:** Phase 7 complete

- **8.1** Internationalization (i18n): next-i18next, multi-language, RTL support
- **8.2** Advanced Analytics: view tracking, user journey, popular tags visualization
- **8.3** Enterprise Features: multi-tenant, SSO (SAML), compliance/audit logging, white-labeling
- **8.4** AI-Powered: pattern recommendations, similarity detection, natural language search, auto-tagging

---

## Notes

- Phase timelines may be adjusted based on business needs and user feedback
- Technical decisions for each phase are recorded in [../decisions/TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md)
- Active phase implementation plans are in [PHASE_CMS_IMPLEMENTATION_PLAN.md](PHASE_CMS_IMPLEMENTATION_PLAN.md)
- Test results per phase are in [../test_results/](../test_results/)
