# Quality & Hardening Evaluation

**Last Updated:** 2026-03-19 (Phase 7.2 complete)
**Audience:** Solutions Architects, Security Engineers, all developers
**Purpose:** Consolidate all Phase 7 quality and hardening evaluation findings, implementation status, accepted risks, and deferred items into a single architect-facing reference. Updated as implementations progress.

---

## 1. Executive Summary

Phase 7 conducted a systematic 10-area audit of the entire solution — covering dependencies, code quality, security, infrastructure, CI/CD, containers, testing, documentation, and production readiness. The evaluation produced **46 implementation tracks** across **43 medium-severity** and **41 low-severity findings**, with **~35 accepted risks** documented with rationale.

**Overall Quality Posture:** The solution demonstrates enterprise-grade foundations across all layers. No critical vulnerabilities were found in production code. The primary gaps are operational (alert routing, SEO, telemetry) and supply-chain hardening (SHA pinning, Dependabot). One critical CI/CD bug was identified (rollback deploys broken image).

---

## 2. Progress Dashboard

| Area | Scope | Findings (M/L) | Tracks | Status |
|------|-------|-----------------|--------|--------|
| [7.1 Frontend Dependencies](#31-area-71--frontend-dependency-audit) | npm packages, vulnerabilities | 4H / 10L | 5 | ✅ Complete |
| [7.2 Backend Dependencies](#32-area-72--backend-dependency-audit) | NuGet packages, CVEs | 1H / 19 outdated | 5 | ✅ Complete |
| [7.3 Frontend Code Quality](#33-area-73--frontend-code-quality--security) | TypeScript, CSP, sanitization | 5M / 4L | 5 | Not Started |
| [7.4 Backend Code Quality](#34-area-74--backend-code-quality--security) | OWASP, CORS, race conditions | 4M / 4L | 5 | Not Started |
| [7.5 IaC & Azure Security](#35-area-75--infrastructure-as-code--azure-security) | Bicep modules, Key Vault, monitoring | 10M / 8L | 4 | Not Started |
| [7.6 CI/CD Pipeline](#36-area-76--cicd-pipeline-quality) | GitHub Actions, supply chain | 6M / 1L | 5 | Not Started |
| [7.7 Docker & Containers](#37-area-77--docker--container-security) | Dockerfiles, compose, images | 3M / 2L | 5 | Not Started |
| [7.8 Testing Coverage](#38-area-78--testing-coverage--quality) | Jest, xUnit, Playwright, Lighthouse | 5M / 5L | 4 | Not Started |
| [7.9 Documentation](#39-area-79--documentation-completeness--accuracy) | Stale docs, cross-references | 4M / 2L | 3 | Not Started |
| [7.10 Production Readiness](#310-area-710--production-readiness--observability) | Alerts, SEO, telemetry, probes | 6M / 3L | 5 | Not Started |

---

## 3. Detailed Findings by Area

### 3.1 Area 7.1 — Frontend Dependency Audit

**Scope:** `package.json` (root), `cms/package.json`, npm vulnerabilities, outdated packages

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.1-1 | HIGH | 14 npm vulnerabilities (10 low, 4 high — all dev-only transitive) | Track 1: Security fixes | ✅ Fixed |
| 7.1-2 | MEDIUM | 18 outdated packages | Track 2: Safe updates | ✅ Fixed |
| 7.1-3 | MEDIUM | No Dependabot configured | Track 4: CI hardening | ✅ Fixed |
| 7.1-4 | MEDIUM | No `npm audit` gate in CI | Track 4: CI hardening | ✅ Fixed |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Security fixes — npm overrides for ajv/flatted/serialize-javascript | ✅ Complete |
| 2 | Safe minor/patch updates — next, lucide-react, tailwind-merge, Storybook, jest, types | ✅ Complete |
| 3 | CMS dependency updates — Strapi 5 latest patch, mysql2 | ✅ Complete |
| 4 | CI hardening — npm audit gate + Dependabot configuration | ✅ Complete |
| 5 | Documentation — Decision 54 | ✅ Complete |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| `elliptic` vulnerability (Storybook transitive) | No upstream patch; dev-only dependency |
| `tmp` vulnerability (LHCI transitive) | No upstream patch; dev-only dependency |

**Intentionally not updating:** tailwindcss v4, eslint v10, next-auth v5 beta

---

### 3.2 Area 7.2 — Backend Dependency Audit

**Scope:** All 7 `.csproj` files, NuGet vulnerabilities, package currency

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.2-1 | HIGH | CVE-2024-43483 DoS in `Microsoft.Extensions.Caching.Memory 8.0.0` (test-only) | Track 1: Security fix | ✅ Fixed |
| 7.2-2 | MEDIUM | 19 outdated packages (all within .NET 8.x servicing) | Track 2–3: Updates | ✅ Fixed |
| 7.2-3 | MEDIUM | No CI vulnerability gate for NuGet | Track 4: CI hardening | ✅ Fixed |
| 7.2-4 | MEDIUM | No Dependabot for NuGet | Track 4: CI hardening | ✅ Fixed |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Security fix — CVE-2024-43483 patch (8.0.0 → 8.0.1) | ✅ Complete |
| 2 | Production dependency updates (Api, Data, Infrastructure to latest .NET 8.x) | ✅ Complete |
| 3 | Test infrastructure updates (xUnit, FluentAssertions, SDK, coverlet) | ✅ Complete |
| 4 | CI hardening — NuGet vulnerability gate + Dependabot config | ✅ Complete |
| 5 | Documentation — Decision 55 | ✅ Complete |

**Deferred:** .NET 9/10 upgrade (~Nov 2026 when .NET 10 LTS available), Swashbuckle → Microsoft.AspNetCore.OpenApi (with .NET 9+), xUnit 3.x (major API changes)

---

### 3.3 Area 7.3 — Frontend Code Quality & Security

**Scope:** TypeScript, ESLint, CSP headers, sanitization, API client error handling

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.3-1 | MEDIUM | CMS `dangerouslySetInnerHTML` without sanitization (3 sites) | Track 1: Sanitization | Not Started |
| 7.3-2 | MEDIUM | CSP missing `base-uri`/`object-src`, wide `img-src`, `unsafe-eval` present | Track 2: CSP hardening | Not Started |
| 7.3-3 | MEDIUM | No 429 rate-limit handling in API client | Track 3: Rate-limit UX | Not Started |
| 7.3-4 | MEDIUM | ESLint has no security plugin | Track 4: eslint-plugin-security | Not Started |
| 7.3-5 | MEDIUM | Source maps — verify not exposed in production | Track 5: Verification | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | CMS HTML sanitization — isomorphic-dompurify for 3 `dangerouslySetInnerHTML` sites | Not Started |
| 2 | CSP hardening — add `base-uri`, `object-src`; narrow `img-src`; test `unsafe-eval` removal | Not Started |
| 3 | 429 rate-limit handling — add case in `handleApiError` | Not Started |
| 4 | ESLint security plugin — `eslint-plugin-security` | Not Started |
| 5 | Source maps verification — confirm not exposed in production | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| `unsafe-inline` in CSP | Required by Next.js; nonce-based CSP deferred to Phase 8+ |
| No `middleware.ts` for auth routing | Per-page `auth()` + `redirect()` is equally secure |
| `console.warn` in mappers | Useful for debugging; data integrity, not security |
| CMS `href` without URL validation | Same trust boundary as CMS content |

---

### 3.4 Area 7.4 — Backend Code Quality & Security

**Scope:** OWASP Top 10, CORS, HSTS, race conditions, validation, error handling

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.4-1 | MEDIUM | CORS hardcodes `localhost:3000` in production | Track 1: CORS/HSTS | Not Started |
| 7.4-2 | MEDIUM | Missing HSTS header | Track 1: CORS/HSTS | Not Started |
| 7.4-3 | MEDIUM | Vote endpoint race condition (load-modify-save) | Track 2: Atomic vote | Not Started |
| 7.4-4 | MEDIUM | `OperationCanceledException` logged as Error (noise) | Track 3: Exception middleware | Not Started |
| 7.4-5 | LOW | Redundant `Enum.TryParse` after FluentValidation | Track 4: Validation cleanup | Not Started |
| 7.4-6 | LOW | Tag validation allows whitespace-only strings | Track 4: Validation cleanup | Not Started |
| 7.4-7 | LOW | DB provider selection uses fragile `Contains("localhost,1433")` | Track 1: DB provider | Not Started |
| 7.4-8 | LOW | `launchSettings.json` has `weatherforecast` leftover | Track 5: Template cleanup | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Security headers & CORS hardening — env-based CORS, HSTS, DB provider simplification | Not Started |
| 2 | Vote endpoint race condition — `ExecuteUpdateAsync` with InMemory fallback | Not Started |
| 3 | Exception middleware differentiation — `OperationCanceledException` separate catch | Not Started |
| 4 | Validation cleanup — remove redundant enum parse, add whitespace tag check | Not Started |
| 5 | Template cleanup & documentation — launchSettings, Decision entry | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| Unused UnitOfWork injection | Architectural refactor not justified now |
| Exception details in production logs | Intentional for debugging; generic response sent to clients |

**Deferred:** Audit logging (Phase 8+), UnitOfWork removal (Phase 8+), HSTS preload (post-launch)

---

### 3.5 Area 7.5 — Infrastructure as Code & Azure Security

**Scope:** Bicep modules, Key Vault, monitoring, network security, cost optimization

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.5-1 | MEDIUM | No resource tagging on any module | Track 1: Governance | Not Started |
| 7.5-2 | MEDIUM | Hardcoded resource names (not parameterized) | Track 1: Governance | Not Started |
| 7.5-3 | MEDIUM | Hardcoded `NEXT_PUBLIC_API_BASE_URL` in containerApps.bicep | Track 1: Governance | Not Started |
| 7.5-4 | MEDIUM | No parameter validation (`@minLength`, `@allowed`) | Track 1: Governance | Not Started |
| 7.5-5 | MEDIUM | No SQL diagnostic settings (no DB audit trail) | Track 2: Monitoring | Not Started |
| 7.5-6 | MEDIUM | Alert action groups missing — alerts fire, nobody notified | Track 2: Monitoring | Not Started |
| 7.5-7 | MEDIUM | Exception spike threshold too high (20 → 10) | Track 2: Monitoring | Not Started |
| 7.5-8 | MEDIUM | No Key Vault purge protection | Track 3: Key Vault | Not Started |
| 7.5-9 | MEDIUM | Soft delete only 7 days (too short for production) | Track 3: Key Vault | Not Started |
| 7.5-10 | MEDIUM | App Insights connection string passed as inline value | Track 3: Key Vault | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Governance & parameterization — tags, names, `@allowed`/`@minLength` validation | Not Started |
| 2 | Monitoring & observability — action group, SQL diagnostics, threshold adjustment | Not Started |
| 3 | Key Vault & secrets hardening — purge protection, 7→90 days, KV references | Not Started |
| 4 | Documentation — Decision 53, ACR cleanup docs | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| SQL/MySQL publicly accessible | Azure-services-only firewall; VNet requires Premium SKU |
| No VNet / network isolation | Premium CAE cost not justified for project scope |
| Container Apps HTTP transport | TLS termination at edge; correct architecture |
| Public blob access for Strapi media | Intentional — media assets must be publicly accessible |
| MySQL HA disabled | Cost optimization; CMS content is cached |
| 30-day Log Analytics retention | Adequate for project scope |
| ACR Basic SKU (no vulnerability scanning) | Standard SKU cost not justified |
| docker-compose hardcoded dev passwords | Dev-only local environment |

**Deferred:** Secret rotation policy (Phase 8+), VNet integration (Phase 8+)

---

### 3.6 Area 7.6 — CI/CD Pipeline Quality

**Scope:** 4 GitHub Actions workflows, supply chain security, deployment safety

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.6-1 | MEDIUM | GitHub Actions not pinned to SHA (~36 `uses:` refs) | Track 1: SHA pinning | Not Started |
| 7.6-2 | MEDIUM | No top-level `permissions` block in `test.yml` | Track 2: Security | Not Started |
| 7.6-3 | MEDIUM | No `concurrency:` groups on any workflow | Track 2: Security | Not Started |
| 7.6-4 | **MEDIUM** | **CRITICAL BUG:** Rollback deploys `:latest` overwritten with broken build | Track 2: Rollback fix | Not Started |
| 7.6-5 | MEDIUM | No `.github/dependabot.yml` configured | Track 3: Dependabot | Not Started |
| 7.6-6 | MEDIUM | `test-summary` does not include E2E results | Track 4: Test summary | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Action version pinning — ~36 refs to SHA format | Not Started |
| 2 | Workflow security & correctness — permissions, concurrency, rollback bug fix | Not Started |
| 3 | Dependabot configuration — npm, NuGet, GitHub Actions, Docker | Not Started |
| 4 | Test summary improvement — include E2E results | Not Started |
| 5 | Documentation — Decision 52, roadmap | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| Hardcoded Azure resource names in env blocks | Rarely change; settings dependency not worth it |
| CMS has no test gate | Managed CMS; healthcheck adequate |
| E2E tests don't run on PRs | Cost optimization; Entra dependency |
| `sleep 45/60` in healthchecks | Works reliably; polling loop deferred to Phase 8+ |
| No staging environment | Single developer; healthcheck + auto-rollback adequate |
| Codecov `fail_ci_if_error: false` | Coverage thresholds enforced in Jest config |
| Azure CLI via curl-pipe-bash | Ephemeral runner; common industry pattern |
| No production approval gates | Can enable via environment protection rules |

**Deferred:** Repository variables for Azure names (Phase 8+), healthcheck polling loop (Phase 8+)

---

### 3.7 Area 7.7 — Docker & Container Security

**Scope:** 3 Dockerfiles, docker-compose.yml, base images, build reproducibility

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.7-1 | MEDIUM | No SHA pinning on base images (3 Dockerfiles, 7 FROM lines) | Track 1: SHA pinning | Not Started |
| 7.7-2 | MEDIUM | Backend uses Debian `aspnet:8.0` + curl (~20 MB overhead) | Track 2: Alpine migration | Not Started |
| 7.7-3 | MEDIUM | CMS uses `npm install` instead of `npm ci` | Track 3: Reproducible builds | Not Started |
| 7.7-4 | LOW | `docker-compose.yml` deprecated `version: '3.8'` field | Track 4: Compose cleanup | Not Started |
| 7.7-5 | LOW | CMS `.dockerignore` missing `.git/`, IDE, OS file exclusions | Track 4: Dockerignore | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Base image SHA pinning — all 3 Dockerfiles, 7 FROM lines | Not Started |
| 2 | Backend Alpine migration — remove curl, ~50% smaller image | Not Started |
| 3 | CMS Dockerfile `npm ci` — reproducible builds | Not Started |
| 4 | Compose & Dockerignore cleanup — remove version field, add exclusions | Not Started |
| 5 | Documentation — Decision 53, roadmap, CLAUDE.md | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| docker-compose hardcoded dev passwords | Dev-only; also accepted in 7.5 |
| ACR Basic SKU — no scanning | Already accepted in 7.5 |
| No BuildKit `--mount=type=cache` | Ephemeral runners; marginal gain |
| CMS BusyBox wget healthcheck | Alpine wget works correctly |

**Deferred:** Container image signing (Phase 8+)

---

### 3.8 Area 7.8 — Testing Coverage & Quality

**Scope:** All test suites, coverage thresholds, CI integration, test quality

**Current Baseline:**

| Layer | Framework | Tests | Coverage | CI Gate |
|-------|-----------|-------|----------|---------|
| Frontend | Jest + RTL | 390 | 75.97% lines | 70% all metrics |
| Backend | xUnit + Moq | 105 | ~85% testable | Pass/fail only |
| E2E | Playwright | 42 x 3 browsers | Critical flows | Cross-browser matrix |
| Performance | Lighthouse CI | 2 URLs x 3 runs | LCP/FCP/TTI | Threshold gates |
| Visual | Chromatic | 38 stories | Snapshot diff | exit-zero (baseline pending) |
| Accessibility | jest-axe + axe-playwright | 4 suites | WCAG 2.1 AA | Jest suite |

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.8-1 | MEDIUM | No mutation testing (Stryker) | Deferred Phase 8 | Deferred |
| 7.8-2 | MEDIUM | No load/stress testing (k6) | Deferred Phase 8 | Deferred |
| 7.8-3 | MEDIUM | Test result documentation stale since Phase 5.1 | Track 1: Docs update | Not Started |
| 7.8-4 | MEDIUM | Backend has no coverage reporting or CI threshold | Track 2: Coverage CI | Not Started |
| 7.8-5 | MEDIUM | E2E API write tests always skipped | Track 3: Strategy docs | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Test results documentation — Phase 6 + Phase 7.8 baselines | Not Started |
| 2 | Backend coverage reporting — coverlet CI integration + Codecov upload | Not Started |
| 3 | Document E2E API write test strategy | Not Started |
| 4 | Decision log entry | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| No contract testing (Pact) | Single repo; defer to Phase 9+ |
| `OperationCanceledException` not unit-tested | Rare; logged correctly; monitored |
| SkeletonCard + LoadingAnnouncer uncovered | Presentational; covered by E2E |
| Radix UI mocked in Jest | Documented pattern; real components tested in E2E |
| Chromatic `exit-zero-on-changes` | Intentional; baseline pending approval |

**Deferred:** Mutation testing/Stryker (Phase 8, 4–6 weeks), load testing/k6 (Phase 8, 3–4 weeks), contract testing/Pact (Phase 9+, 4–5 weeks)

---

### 3.9 Area 7.9 — Documentation Completeness & Accuracy

**Scope:** All documentation folders, cross-references, currency

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.9-1 | MEDIUM | `COMPREHENSIVE_TEST_RESULTS.md` stale (Pre-Phase 4, 2026-02-10) | Track 1: Archive | Not Started |
| 7.9-2 | MEDIUM | 4 operations docs stale relative to Phase 6.8 IaC (all 2026-02-13) | Track 2: Cross-refs | Not Started |
| 7.9-3 | MEDIUM | `CMS_ARCHITECTURE.md` Phase 2 status says "upcoming" (completed 2026-03-03) | Track 3: Fixes | Not Started |
| 7.9-4 | MEDIUM | `AUTH_SETUP_GUIDE.md` missing governance header | Track 3: Fixes | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Archive `COMPREHENSIVE_TEST_RESULTS.md` (stale snapshot) | Not Started |
| 2 | Operations docs IaC cross-references (RUNBOOK, DR, INCIDENT, MONITORING) | Not Started |
| 3 | CMS phase status + Auth guide header + decision log | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| Dead links to `COMPREHENSIVE_TEST_PLAN.md` (8 occurrences) | Trivial find-replace; bundled as optional fix |
| `SYSTEM_OVERVIEW.md` missing IaC reference | Architecturally accurate; `INFRASTRUCTURE_MANAGEMENT.md` is SSOT |

**Strengths (no action needed):** DOCUMENTATION_INDEX excellent, 52+ decisions logged, API docs complete, CMS component docs comprehensive (26 components), 14 Mermaid diagrams all embedded, GOVERNANCE.md authoritative.

---

### 3.10 Area 7.10 — Production Readiness & Observability

**Scope:** Alerting, SEO, health probes, telemetry, accessibility CI, monitoring docs

| ID | Severity | Finding | Track | Status |
|----|----------|---------|-------|--------|
| 7.10-1 | MEDIUM | Alert action groups not wired — alerts fire, nobody notified | Track 1: Alert routing | Not Started |
| 7.10-2 | MEDIUM | No `robots.txt` or XML sitemap | Track 2: SEO | Not Started |
| 7.10-3 | MEDIUM | `metadataBase` uses placeholder URL | Track 2: SEO | Not Started |
| 7.10-4 | MEDIUM | No Container Apps liveness/readiness/startup probes in IaC | Track 3: Health probes | Not Started |
| 7.10-5 | MEDIUM | Zero `TelemetryClient` business telemetry | Track 4: Telemetry | Not Started |
| 7.10-6 | MEDIUM | Web container missing 6 env vars in IaC (AUTH/Strapi) | Track 3: Env parity | Not Started |
| 7.10-7 | LOW | Exception spike threshold is 20; should be 10 | Track 1 (with 7.5) | Not Started |
| 7.10-8 | LOW | MONITORING_GUIDE.md pre-dates IaC integration | Track 5: Docs | Not Started |
| 7.10-9 | LOW | No Lighthouse accessibility score gated in CI | Track 5: CI gate | Not Started |

**Tracks:**

| # | Track | Status |
|---|-------|--------|
| 1 | Alert action group wiring + threshold adjustment | Not Started |
| 2 | SEO essentials — `robots.ts`, `sitemap.ts`, `metadataBase` | Not Started |
| 3 | IaC health probes & env parity — probes + 6 missing env vars | Not Started |
| 4 | Business telemetry — `TelemetryClient` in `PatternService` | Not Started |
| 5 | Documentation & CI updates — MONITORING_GUIDE, Lighthouse a11y gate | Not Started |

**Accepted Risks:**

| Risk | Rationale |
|------|-----------|
| Unstructured frontend logging | Container Apps captures console; structured lib adds complexity |
| No frontend App Insights SDK | Would add bundle size; server-side already tracked |
| No explicit `Cache-Control` headers on API | ISR + server-component revalidation sufficient |
| No bundle size budget in CI | Lighthouse performance ≥ 0.80 implicitly gates growth |
| `/health` and `/health/ready` identical | DB is only dependency; IaC probes are the real fix |

**Deferred:** Frontend App Insights JS SDK, synthetic availability tests, custom Azure dashboards, backend P95 CI gate, CDN / Azure Front Door

---

## 4. Cross-Area Dependencies

| Item | Owner Area | Related Areas | Notes |
|------|-----------|---------------|-------|
| Dependabot configuration | 7.6 Track 3 | 7.1, 7.2 | Single `.github/dependabot.yml` covers npm, NuGet, Actions, Docker |
| Docker image SHA pinning | 7.7 Track 1 | 7.3, 7.6 | Referenced in multiple areas; 7.7 implements |
| Alert action group | 7.10 Track 1 | 7.5 Track 2 | Both areas identified; 7.10 implements |
| Exception threshold 20→10 | 7.10 Track 1 | 7.5 Track 2 | Both areas identified; implemented together |
| HSTS header | 7.4 Track 1 | 7.3 | Backend security header; complements frontend CSP |
| IaC cross-references in ops docs | 7.9 Track 2 | 7.5, 7.10 | Docs referencing infrastructure changes |
| `COMPREHENSIVE_TEST_RESULTS.md` archive | 7.9 Track 1 | 7.8 Track 1 | 7.9 archives; 7.8 creates replacement baselines |
| 429 rate-limit UX | 7.3 Track 3 | 7.10 | Frontend error handling for backend rate limiting |
| CMS HTML sanitization | 7.3 Track 1 | 7.10 | Security improvement visible in production |

---

## 5. Accepted Risks Register

All risks below were evaluated and explicitly accepted with documented rationale. They do not require implementation unless the project context changes.

| ID | Area | Risk | Severity | Rationale |
|----|------|------|----------|-----------|
| AR-01 | 7.1 | `elliptic` npm vulnerability (Storybook transitive) | LOW | No upstream patch; dev-only |
| AR-02 | 7.1 | `tmp` npm vulnerability (LHCI transitive) | LOW | No upstream patch; dev-only |
| AR-03 | 7.3 | `unsafe-inline` required in CSP | LOW | Next.js requirement; nonce-based CSP = Phase 8+ |
| AR-04 | 7.3 | No `middleware.ts` for auth routing | LOW | Per-page `auth()` + `redirect()` equally secure |
| AR-05 | 7.3 | `console.warn` in mappers | LOW | Debugging utility; not a security concern |
| AR-06 | 7.3 | CMS `href` without URL validation | LOW | Same trust boundary as CMS content |
| AR-07 | 7.4 | Unused UnitOfWork injection | LOW | Refactor not justified now |
| AR-08 | 7.4 | Exception details in production logs | LOW | Intentional; generic response to clients |
| AR-09 | 7.5 | SQL/MySQL publicly accessible | LOW | Azure-services-only firewall; VNet = Premium SKU |
| AR-10 | 7.5 | No VNet / network isolation | LOW | Premium CAE cost not justified |
| AR-11 | 7.5 | Container Apps HTTP transport | LOW | TLS at edge; correct architecture |
| AR-12 | 7.5 | Public blob access for Strapi media | LOW | Intentional — media must be public |
| AR-13 | 7.5 | MySQL HA disabled | LOW | Cost optimization; CMS cached |
| AR-14 | 7.5 | 30-day Log Analytics retention | LOW | Adequate for project scope |
| AR-15 | 7.5 | ACR Basic SKU (no scanning) | LOW | Standard SKU cost not justified |
| AR-16 | 7.5 | docker-compose hardcoded dev passwords | LOW | Dev-only local environment |
| AR-17 | 7.6 | Hardcoded Azure resource names in env | LOW | Rarely change |
| AR-18 | 7.6 | CMS has no test gate | LOW | Managed CMS; healthcheck adequate |
| AR-19 | 7.6 | E2E tests don't run on PRs | LOW | Cost optimization; Entra dependency |
| AR-20 | 7.6 | `sleep` in healthchecks | LOW | Works reliably |
| AR-21 | 7.6 | No staging environment | LOW | Single developer; auto-rollback adequate |
| AR-22 | 7.6 | Codecov `fail_ci_if_error: false` | LOW | Thresholds in Jest config |
| AR-23 | 7.6 | Azure CLI curl-pipe-bash | LOW | Ephemeral runner; common pattern |
| AR-24 | 7.6 | No production approval gates | LOW | Environment protection rules available |
| AR-25 | 7.7 | docker-compose hardcoded dev passwords | LOW | Dev-only; duplicate of AR-16 |
| AR-26 | 7.7 | ACR Basic no scanning | LOW | Duplicate of AR-15 |
| AR-27 | 7.7 | No BuildKit cache mount | LOW | Ephemeral runners; marginal gain |
| AR-28 | 7.7 | CMS BusyBox wget healthcheck | LOW | Works correctly |
| AR-29 | 7.8 | No contract testing (Pact) | LOW | Single repo; Phase 9+ |
| AR-30 | 7.8 | `OperationCanceledException` untested | LOW | Rare; monitored |
| AR-31 | 7.8 | SkeletonCard/LoadingAnnouncer uncovered | LOW | Presentational; E2E covers |
| AR-32 | 7.8 | Radix UI mocked in Jest | LOW | Documented; real E2E testing |
| AR-33 | 7.8 | Chromatic `exit-zero-on-changes` | LOW | Baseline pending |
| AR-34 | 7.9 | Dead links to `COMPREHENSIVE_TEST_PLAN.md` | LOW | Trivial fix; optional |
| AR-35 | 7.9 | `SYSTEM_OVERVIEW.md` missing IaC reference | LOW | Architecturally accurate |
| AR-36 | 7.10 | Unstructured frontend logging | LOW | Container Apps captures console |
| AR-37 | 7.10 | No frontend App Insights SDK | LOW | Bundle cost; server-side tracked |
| AR-38 | 7.10 | No `Cache-Control` headers on API | LOW | ISR handles caching |
| AR-39 | 7.10 | No bundle size budget in CI | LOW | Lighthouse gates growth |
| AR-40 | 7.10 | Identical health endpoints | LOW | IaC probes are the real fix |

---

## 6. Deferred to Future Phases

| Item | Target Phase | Estimated Effort | Reason for Deferral |
|------|-------------|-----------------|---------------------|
| .NET 9/10 upgrade | Phase 8+ (~Nov 2026) | Medium | Wait for .NET 10 LTS |
| Swashbuckle → Microsoft.AspNetCore.OpenApi | Phase 8+ | Light | Requires .NET 9+ |
| xUnit 3.x | Phase 8+ | Medium | Major API changes |
| Nonce-based CSP | Phase 8+ | Medium | Next.js complexity |
| Audit logging for CRUD | Phase 8+ | Medium | Not yet required |
| UnitOfWork removal | Phase 8+ | Light | Low-priority refactor |
| HSTS preload submission | Post-launch | Light | Requires stable production domain |
| Secret rotation policy | Phase 8+ | Medium | Operational maturity |
| VNet integration | Phase 8+ | High | Premium CAE cost |
| Repository variables for Azure names | Phase 8+ | Light | Low priority |
| Healthcheck polling loop | Phase 8+ | Light | Current sleep works |
| Container image signing | Phase 8+ | Medium | Supply chain maturity |
| Mutation testing (Stryker) | Phase 8 | 4–6 weeks | Testing maturity |
| Load testing (k6) | Phase 8 | 3–4 weeks | Pre-production requirement |
| Contract testing (Pact) | Phase 9+ | 4–5 weeks | Multi-service prerequisite |
| Frontend App Insights JS SDK | Phase 8+ | Light | Bundle cost trade-off |
| Synthetic availability tests | Phase 8+ | Light | Scale-to-zero noise |
| CDN / Azure Front Door | Phase 8+ | Medium | $35+/month cost |
| Backend P95 CI gate | Phase 8+ | Medium | Baseline needed first |

---

## 7. References

### Individual Evaluation Plans
- [PHASE_QUALITY_HARDENING_PLAN.md](../project/PHASE_QUALITY_HARDENING_PLAN.md) — Master evaluation coordinator
- [PHASE_7_1_FRONTEND_DEPS_PLAN.md](../project/PHASE_7_1_FRONTEND_DEPS_PLAN.md) — Frontend dependency audit
- [PHASE_7_2_BACKEND_DEPS_PLAN.md](../project/PHASE_7_2_BACKEND_DEPS_PLAN.md) — Backend dependency audit
- [PHASE_7_3_FRONTEND_CODE_PLAN.md](../project/PHASE_7_3_FRONTEND_CODE_PLAN.md) — Frontend code quality & security
- [PHASE_7_4_BACKEND_CODE_PLAN.md](../project/PHASE_7_4_BACKEND_CODE_PLAN.md) — Backend code quality & security
- [PHASE_7_5_IAC_SECURITY_PLAN.md](../project/PHASE_7_5_IAC_SECURITY_PLAN.md) — IaC & Azure security
- [PHASE_7_6_CICD_PLAN.md](../project/PHASE_7_6_CICD_PLAN.md) — CI/CD pipeline quality
- [PHASE_7_7_DOCKER_PLAN.md](../project/PHASE_7_7_DOCKER_PLAN.md) — Docker & container security
- [PHASE_7_8_TESTING_PLAN.md](../project/PHASE_7_8_TESTING_PLAN.md) — Testing coverage & quality
- [PHASE_7_9_DOCUMENTATION_PLAN.md](../project/PHASE_7_9_DOCUMENTATION_PLAN.md) — Documentation completeness
- [PHASE_7_10_PRODUCTION_READINESS_PLAN.md](../project/PHASE_7_10_PRODUCTION_READINESS_PLAN.md) — Production readiness & observability

### Related Architecture Documents
- [SECURITY_OVERVIEW.md](SECURITY_OVERVIEW.md) — Security architecture and protection measures
- [BACKEND_ARCHITECTURE.md](BACKEND_ARCHITECTURE.md) — Backend patterns and infrastructure
- [FRONTEND_ARCHITECTURE.md](FRONTEND_ARCHITECTURE.md) — Frontend architecture and coding standards
- [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) — High-level system architecture
