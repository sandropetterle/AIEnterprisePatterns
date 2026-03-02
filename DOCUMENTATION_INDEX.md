# Documentation Index

**Last Updated:** 2026-03-02 (Storybook catalog added to .storybook/)
**Audience:** All contributors
**Purpose:** Central map of every documentation file in this project — what it contains, who it's for, and whether it's current.

> **Rules and governance:** [documentation/GOVERNANCE.md](documentation/GOVERNANCE.md)
> **Diagram index:** [documentation/diagrams/DIAGRAM_INDEX.md](documentation/diagrams/DIAGRAM_INDEX.md)

---

## Root Level

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [README.md](README.md) | Public entry point: quick start, features, project links | New contributors, GitHub visitors | Current |
| [CLAUDE.md](CLAUDE.md) | AI assistant operational context: commands, conventions, quick reference | AI assistant, Developers | Current |
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | This file — central map of all documentation | All | Current |

---

## .storybook/ — Interactive UI Component Catalog

*Updated when components are added or Storybook config changes.*

| File/Folder | Purpose | Audience | Status |
|-------------|---------|----------|--------|
| [.storybook/main.ts](.storybook/main.ts) | Framework config (`@storybook/nextjs`), addons, webpack alias for next-auth mock | Frontend devs | Current |
| [.storybook/preview.tsx](.storybook/preview.tsx) | Global decorators: ThemeProvider, withThemeByClassName (light/dark toolbar) | Frontend devs | Current |
| [.storybook/fixtures.ts](.storybook/fixtures.ts) | Shared mock data: Pattern fixtures + all 14 CMS block fixtures | Frontend devs | Current |
| [.storybook/mocks/next-auth-react.tsx](.storybook/mocks/next-auth-react.tsx) | next-auth/react mock with `withSession()` / `withLoadingSession` decorators | Frontend devs | Current |

**Stories (38 files, colocated with components):**
- `components/ui/*.stories.tsx` — shadcn/ui primitives (14 stories)
- `components/layout/*.stories.tsx` — Header, Footer, Navigation, ThemeToggle, UserMenu (5 stories)
- `components/shared/*.stories.tsx` — Logo, ErrorBoundary (2 stories)
- `components/home/*.stories.tsx` — Hero, PatternCard, FeaturedPatterns, StatsSection, CTASection (5 stories)
- `components/patterns/*.stories.tsx` — SearchBar, Pagination, PatternForm, NewPatternButton, EmptyState, PatternsGrid (6 stories)
- `components/patterns/details/*.stories.tsx` — VotingButton, Breadcrumb, PatternContent, PatternActions, RelatedPatternsSection (5 stories)
- `lib/cms/components.stories.tsx` — all 14 CMS block renderers + 3 composite page layouts

**Commands:** `npm run storybook` (dev at http://localhost:6006) · `npm run build-storybook`

---

## documentation/architecture/ — How the system is built

*Permanent. Updated when architecture changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [SYSTEM_OVERVIEW.md](documentation/architecture/SYSTEM_OVERVIEW.md) | High-level: vision, tech stack, component interaction, deployed URLs | Architect, all devs | Current |
| [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) | Clean Architecture layers, key patterns (caching, rate limiting, mapper), testing | Backend devs, Architect | Current |
| [FRONTEND_ARCHITECTURE.md](documentation/architecture/FRONTEND_ARCHITECTURE.md) | App Router, auth flow, ISR, component structure, coding standards | Frontend devs, Architect | Current |
| [CMS_ARCHITECTURE.md](documentation/architecture/CMS_ARCHITECTURE.md) | Strapi 5 content model, deployment, webhooks, known gotchas | Frontend devs, Infra | Current |
| [DATA_MODEL.md](documentation/architecture/DATA_MODEL.md) | Entities, relationships, seeding, category enum mapping | Backend devs, Architect | Current |
| [SECURITY_OVERVIEW.md](documentation/architecture/SECURITY_OVERVIEW.md) | Auth architecture, CORS, CSP, rate limiting, security headers | Security, Architect, Devs | Current |

---

## documentation/api/ — REST API Reference

*Updated when endpoints, DTOs, or validation rules change.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [API_REFERENCE_INDEX.md](documentation/api/API_REFERENCE_INDEX.md) | Overview: base URLs, versioning, auth, rate limiting, error shapes | Developers, API consumers | Current |
| [PATTERNS_API.md](documentation/api/PATTERNS_API.md) | All `/patterns` endpoints — DTOs, validation rules, request/response examples | Developers, API consumers | Current |
| [AUTH_API.md](documentation/api/AUTH_API.md) | `/auth/me` — current user identity and roles | Developers | Current |
| [HEALTH_API.md](documentation/api/HEALTH_API.md) | `/health`, `/health/ready` — liveness and readiness probes | DevOps, Infrastructure | Current |

---

## documentation/cms-components/ — CMS Component Reference

*Updated when Strapi component schemas change.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [COMPONENT_INDEX.md](documentation/cms-components/COMPONENT_INDEX.md) | Scannable catalog of all 26 Strapi components with "Used By" dependency map | Frontend devs, Content editors | Current |
| [LAYOUT_COMPONENTS.md](documentation/cms-components/LAYOUT_COMPONENTS.md) | `layout` namespace — `cta-button`, `footer-config`, `nav-link` (3 components) | Frontend devs | Current |
| [SECTION_COMPONENTS.md](documentation/cms-components/SECTION_COMPONENTS.md) | `sections` namespace — all 15 Dynamic Zone block components with renderers | Frontend devs, Content editors | Current |
| [SHARED_COMPONENTS.md](documentation/cms-components/SHARED_COMPONENTS.md) | `shared` namespace — 8 reusable primitives embedded within section components | Frontend devs | Current |
| [SEO_COMPONENTS.md](documentation/cms-components/SEO_COMPONENTS.md) | `seo` namespace — `metadata` component used on all page content types | Frontend devs | Current |

---

## documentation/requirements/ — What the system should do

*Permanent. Updated when scope changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [FUNCTIONAL_REQUIREMENTS.md](documentation/requirements/FUNCTIONAL_REQUIREMENTS.md) | Feature requirements by page, assumptions, out-of-scope, acceptance criteria | Product/UX, PM, Devs | Current |
| [NON_FUNCTIONAL_REQUIREMENTS.md](documentation/requirements/NON_FUNCTIONAL_REQUIREMENTS.md) | Performance, scalability, maintainability, usability, deployment NFRs | Architect, Infra, PM | Current |

---

## documentation/decisions/ — Why we built it this way

*Append-only + quarterly compaction. See GOVERNANCE.md Section 6.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [TECHNICAL_DECISIONS_LOG.md](documentation/decisions/TECHNICAL_DECISIONS_LOG.md) | 41 active architectural decisions (newest first) | Architect, Senior Devs | Current |
| [DECISIONS_ARCHIVE.md](documentation/decisions/DECISIONS_ARCHIVE.md) | Compacted/superseded decisions (full text) | Architect | Current |
| [DECISION_TEMPLATE.md](documentation/decisions/DECISION_TEMPLATE.md) | Standard format for new decision entries | All devs | Current |

---

## documentation/testing/ — How we test

*Permanent. Updated when testing approach changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [TESTING_STRATEGY.md](documentation/testing/TESTING_STRATEGY.md) | Test types, tools, coverage targets, best practices | QA, Developers | Current |
| [MANUAL_TEST_PLAN.md](documentation/testing/MANUAL_TEST_PLAN.md) | Manual test checklists organized by feature area | QA testers | Current |
| [MANUAL_TEST_EXECUTION_GUIDE.md](documentation/testing/MANUAL_TEST_EXECUTION_GUIDE.md) | Guide for executing manual tests with environment setup | QA testers | Current |
| [MANUAL_TEST_RESULTS_TEMPLATE.md](documentation/testing/MANUAL_TEST_RESULTS_TEMPLATE.md) | Template for documenting manual test execution results | QA testers | Current |
| [PERFORMANCE_BASELINE_GUIDE.md](documentation/testing/PERFORMANCE_BASELINE_GUIDE.md) | Guide for establishing and measuring performance baselines | QA, Developers | Current |

---

## documentation/project/ — Project management

*Updated per phase. Phase plans deleted 1 phase after completion.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [ROADMAP.md](documentation/project/ROADMAP.md) | Phase plans, status summary table, deliverables, upcoming phases | PM, Architect, all | Current |
| [PHASE_CMS_IMPLEMENTATION_PLAN.md](documentation/project/PHASE_CMS_IMPLEMENTATION_PLAN.md) | Strapi 5 CMS integration implementation plan | Developers, Architect | Active (Phase 6.4-6.6) |

---

## documentation/operations/ — How to run in production

*Permanent. Updated on infrastructure changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [AUTH_SETUP_GUIDE.md](documentation/operations/AUTH_SETUP_GUIDE.md) | Step-by-step Azure Entra External ID configuration | DevOps, Infra | Current |
| [DISASTER_RECOVERY.md](documentation/operations/DISASTER_RECOVERY.md) | DR procedures, backup strategy, RTO/RPO (4h/24h) | SRE, DevOps | Current |
| [INCIDENT_RESPONSE.md](documentation/operations/INCIDENT_RESPONSE.md) | Incident procedures, severity levels, communication templates | SRE, Security | Current |
| [MONITORING_GUIDE.md](documentation/operations/MONITORING_GUIDE.md) | Alert thresholds (single source of truth), dashboards, App Insights | SRE, DevOps | Current |
| [RUNBOOK.md](documentation/operations/RUNBOOK.md) | Common ops tasks, troubleshooting, deployment rollback | SRE, On-Call | Current |

---

## documentation/reviews/ — Point-in-time audit snapshots

*Immutable after creation.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [CODEBASE_REVIEW_REPORT.md](documentation/reviews/CODEBASE_REVIEW_REPORT.md) | Phase 4 security and architecture audit (38 remediation items) | Architect, Security | Archived snapshot (Phase 4) |

---

## documentation/test_results/ — Phase test execution reports

*Retention: current phase + 2 prior phases. COMPREHENSIVE_TEST_RESULTS.md is exempt.*

| File | Purpose | Status |
|------|---------|--------|
| [COMPREHENSIVE_TEST_RESULTS.md](documentation/test_results/COMPREHENSIVE_TEST_RESULTS.md) | Rolling summary of all test results (exempt from retention) | Current |
| [phase4_5_coverage_report.md](documentation/test_results/phase4_5_coverage_report.md) | Phase 4.5 code coverage report | Historical |
| [phase4_5_e2e_test_results.md](documentation/test_results/phase4_5_e2e_test_results.md) | Phase 4.5 E2E test results | Historical |
| [phase4_5_frontend_test_results.md](documentation/test_results/phase4_5_frontend_test_results.md) | Phase 4.5 frontend test results | Historical |
| [phase4_5_week1_setup_complete.md](documentation/test_results/phase4_5_week1_setup_complete.md) | Phase 4.5 week 1 setup completion report | Historical |
| [phase4_5_week2_completion.md](documentation/test_results/phase4_5_week2_completion.md) | Phase 4.5 week 2 completion report | Historical |
| [phase4_5_week3_test_results.md](documentation/test_results/phase4_5_week3_test_results.md) | Phase 4.5 week 3 test results | Historical |
| [phase5_1_auth_test_results.md](documentation/test_results/phase5_1_auth_test_results.md) | Phase 5.1 auth test results | Historical |
| [PHASE3_TEST_RESULTS.md](documentation/test_results/PHASE3_TEST_RESULTS.md) | Phase 3 test results (eligible for deletion at Phase 7 start) | Historical — deletion eligible |

---

## documentation/diagrams/ — Visual diagrams

*Mermaid format, embedded directly in their target architecture docs. All 14 complete.*

| File | Purpose | Status |
|------|---------|--------|
| [DIAGRAM_INDEX.md](documentation/diagrams/DIAGRAM_INDEX.md) | Index of all 14 diagrams — where each lives, format, and Mermaid conventions. | Current |

**All diagrams (embedded in their target docs):**
| Diagram | Embedded In |
|---------|------------|
| System Architecture Overview | [SYSTEM_OVERVIEW.md](documentation/architecture/SYSTEM_OVERVIEW.md) |
| Clean Architecture Layers | [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) |
| Frontend Component Tree | [FRONTEND_ARCHITECTURE.md](documentation/architecture/FRONTEND_ARCHITECTURE.md) |
| CMS ISR Revalidation Flow | [CMS_ARCHITECTURE.md](documentation/architecture/CMS_ARCHITECTURE.md) |
| CMS Component Dependency Map | [COMPONENT_INDEX.md](documentation/cms-components/COMPONENT_INDEX.md) |
| Azure Infrastructure | [CONTAINER_APPS_GUIDE.md](deployment/CONTAINER_APPS_GUIDE.md) |
| Authentication Flow (sequence) | [SECURITY_OVERVIEW.md](documentation/architecture/SECURITY_OVERVIEW.md) |
| Pattern Vote Flow (sequence) | [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) |
| Database Schema (ERD) | [DATA_MODEL.md](documentation/architecture/DATA_MODEL.md) |
| Browse and Vote (user journey) | [FUNCTIONAL_REQUIREMENTS.md](documentation/requirements/FUNCTIONAL_REQUIREMENTS.md) |
| Create Pattern (user journey) | [FUNCTIONAL_REQUIREMENTS.md](documentation/requirements/FUNCTIONAL_REQUIREMENTS.md) |
| Pattern Lifecycle (state) | [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) |
| Authentication States (state) | [SECURITY_OVERVIEW.md](documentation/architecture/SECURITY_OVERVIEW.md) |
| Backend Domain Model (class) | [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) |

---

## documentation/

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [GOVERNANCE.md](documentation/GOVERNANCE.md) | Documentation rules, folder purposes, naming, lifecycle policies | All contributors | Current |

---

## deployment/ — Azure deployment

*Updated on infrastructure changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [README.md](deployment/README.md) | Deployment entry point: Container Apps quick start, resource map | DevOps, Infra | Current |
| [CONTAINER_APPS_GUIDE.md](deployment/CONTAINER_APPS_GUIDE.md) | Full Container Apps setup and configuration reference | DevOps, Infra | Current |
| [COST_ANALYSIS.md](deployment/COST_ANALYSIS.md) | Cost breakdown: Container Apps vs App Services (single source) | Architect, Finance | Current |
| [database-migration.md](deployment/database-migration.md) | Apply EF Core migrations to Azure SQL | DevOps, Backend devs | Current |
| [github-secrets-setup.md](deployment/github-secrets-setup.md) | GitHub OIDC federated identity secrets for CI/CD | DevOps | Current |
| [scripts/README_MONITORING.md](deployment/scripts/README_MONITORING.md) | Alert and dashboard PowerShell scripts (thresholds from MONITORING_GUIDE) | DevOps | Current |

---

## backend/

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [backend/README.md](backend/README.md) | Backend quick start and brief API overview | Backend devs | Current |

---

## Maintenance

When you create, move, or delete a documentation file:
1. Update this index table
2. Update cross-references in affected documents
3. Update `CLAUDE.md` if the file is a key doc

See [documentation/GOVERNANCE.md](documentation/GOVERNANCE.md) for full maintenance rules.
