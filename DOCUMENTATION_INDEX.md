# Documentation Index

**Last Updated:** 2026-02-27
**Audience:** All contributors
**Purpose:** Central map of every documentation file in this project — what it contains, who it's for, and whether it's current.

> **Rules and governance:** [documentation/GOVERNANCE.md](documentation/GOVERNANCE.md)
> **Diagram roadmap:** [documentation/diagrams/DIAGRAM_PLAN.md](documentation/diagrams/DIAGRAM_PLAN.md)

---

## Root Level

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [README.md](README.md) | Public entry point: quick start, features, project links | New contributors, GitHub visitors | Current |
| [CLAUDE.md](CLAUDE.md) | AI assistant operational context: commands, conventions, quick reference | AI assistant, Developers | Current |
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | This file — central map of all documentation | All | Current |

---

## documentation/architecture/ — How the system is built

*Permanent. Updated when architecture changes.*

| File | Purpose | Audience | Status |
|------|---------|----------|--------|
| [SYSTEM_OVERVIEW.md](documentation/architecture/SYSTEM_OVERVIEW.md) | High-level: vision, tech stack, component interaction, deployed URLs | Architect, all devs | Current |
| [BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md) | Clean Architecture layers, API reference, patterns, testing | Backend devs, Architect | Current |
| [FRONTEND_ARCHITECTURE.md](documentation/architecture/FRONTEND_ARCHITECTURE.md) | App Router, auth flow, ISR, component structure, coding standards | Frontend devs, Architect | Current |
| [CMS_ARCHITECTURE.md](documentation/architecture/CMS_ARCHITECTURE.md) | Strapi 5 content model, deployment, webhooks, known gotchas | Frontend devs, Infra | Current |
| [DATA_MODEL.md](documentation/architecture/DATA_MODEL.md) | Entities, relationships, seeding, category enum mapping | Backend devs, Architect | Current |
| [SECURITY_OVERVIEW.md](documentation/architecture/SECURITY_OVERVIEW.md) | Auth architecture, CORS, CSP, rate limiting, security headers | Security, Architect, Devs | Current |

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

## documentation/diagrams/ — Planned visual diagrams

*To be created when diagram tooling is adopted.*

| File | Purpose | Status |
|------|---------|--------|
| [DIAGRAM_PLAN.md](documentation/diagrams/DIAGRAM_PLAN.md) | Lists all planned diagrams with type, target doc, and placeholder convention | Active |

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
