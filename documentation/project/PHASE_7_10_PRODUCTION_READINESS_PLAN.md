# Phase 7.10: Production Readiness & Observability — Implementation Plan

**Last Updated:** 2026-03-19
**Audience:** DevOps, SRE, Architect, All contributors
**Purpose:** Implementation plan for Phase 7.10 — cross-cutting production readiness and observability hardening.
**Status:** Ready for implementation

---

## Overall Assessment

The system is in **good production shape** for a learning project on Azure Container Apps (~$5-12/month). The fundamentals are solid: Application Insights wired up, health endpoints exist, security headers configured, JSON-LD structured data present on all key pages, 4 accessibility test suites in place, ISR caching configured. The gaps are cross-cutting concerns that no single earlier phase addressed: alerts that fire but notify nobody, no robots.txt or sitemap, no container health probes in IaC, and no custom business telemetry.

**Findings:** 6 MEDIUM, 3 LOW actionable, 5 LOW accepted risks

---

## Area-by-Area Evaluation

### 1. Health Check Endpoints — ADEQUATE

**Current state:**
- Backend `/health` and `/health/ready` mapped in `Program.cs`, include `AddDbContextCheck<ApplicationDbContext>()`
- CI verifies health post-deploy (curl `/health` expecting "Healthy")
- Frontend verified by checking for `"next-size-adjust"` in HTML response

**Gaps:**
- **(MEDIUM)** No Container Apps liveness/readiness/startup probes in `infrastructure/modules/containerApps.bicep` — Azure uses only default TCP probe
- **(LOW)** `/health` and `/health/ready` are identical (both check DB) — no liveness-only endpoint

### 2. Structured Logging — ADEQUATE

**Current state:**
- Backend: `ILogger<T>` via DI, structured, auto-integrates with App Insights via `AddApplicationInsightsTelemetry()`
- Frontend: `console.warn`/`console.error` — unstructured but captured in Container Apps logs

**Gaps:**
- **(LOW — Accepted)** Frontend logging not structured; no App Insights JS SDK

### 3. Application Insights Integration — PARTIAL

**Current state:**
- Backend: `AddApplicationInsightsTelemetry()` with adaptive sampling and QuickPulse (live metrics)
- Connection string via Key Vault secret reference in `containerApps.bicep`
- Log Analytics Workspace connected (30-day retention)
- 4 metric alerts in `monitoring.bicep` (error rate, response time, availability, exception spike)

**Gaps:**
- **(MEDIUM)** Zero `TelemetryClient.TrackEvent()`/`TrackMetric()` calls anywhere — no business telemetry (votes, views, searches, cache hits)
- **(MEDIUM)** Alert action groups not wired — all 4 alerts fire into the void (confirmed: zero `actionGroup` references in any Bicep file)
- **(LOW)** Exception spike threshold is 20; Phase 7.5 recommended lowering to 10

### 4. Error Tracking and Alerting — CRITICAL GAP

**Current state:**
- `ExceptionHandlingMiddleware` catches unhandled exceptions, logs, returns generic 500
- App Insights captures exceptions automatically via ASP.NET SDK
- `error.tsx` has placeholder comment "Log the error to error reporting service" — never wired up

**Gaps:**
- **(MEDIUM)** Nobody gets notified when alerts fire — **highest-impact gap in 7.10**

### 5. Performance Baselines — ADEQUATE

**Current state:**
- Lighthouse CI gates deploy: LCP <2.5s, FCP <1.8s, TTI <5s, Performance ≥0.80
- MONITORING_GUIDE.md documents baselines (stale, from 2026-02-13)

**Gaps:**
- **(LOW)** Baselines in MONITORING_GUIDE.md pre-date IaC and CMS integration
- **(LOW — Accepted)** No bundle size budget; no backend P95 gate in CI

### 6. SEO and Meta Tags — STRONG with gaps

**Current state:**
- Comprehensive `Metadata` export in `app/layout.tsx`: title template, description, keywords, OG, Twitter, robots directives with googleBot
- JSON-LD structured data on all 3 key pages (`WebSite` + `SearchAction`, `CollectionPage`, `Article`)
- `JsonLd` component (`components/shared/JsonLd.tsx`) used consistently

**Gaps:**
- **(MEDIUM)** No `robots.txt` — neither `app/robots.ts` nor `public/robots.txt` exists
- **(MEDIUM)** No XML sitemap — no `app/sitemap.ts` exists
- **(MEDIUM)** `metadataBase` in `app/layout.tsx` uses placeholder `https://ai-patterns.example.com` instead of production URL; OpenGraph URLs also use placeholder

### 7. Accessibility Compliance (WCAG 2.1 AA) — STRONG

**Current state:**
- 4 jest-axe suites, skip-to-content link, `<html lang="en">`, semantic HTML, `aria-live="polite"`
- Radix UI primitives handle ARIA; `<label htmlFor>` convention enforced
- Dark mode with system preference detection

**Gaps:**
- **(LOW)** No Lighthouse accessibility score gated in CI (only performance is gated)
- **(LOW — Accepted)** No production a11y audit beyond jest-axe

### 8. Cache Strategy Effectiveness — ADEQUATE

**Current state:**
- ISR revalidation: home 5min, listing 2min, details 10min
- Backend `IMemoryCache` for featured/trending (5min TTL)
- `generateStaticParams()` pre-renders known pages at build

**Gaps:**
- **(LOW — Accepted)** No cache-hit metrics; no explicit `Cache-Control` on API responses

### 9. Environment Parity — GOOD

**Current state:**
- `appsettings.Production.json` baked into Docker image handles CORS (`FrontendUrls` array includes both App Service and Container Apps URLs)
- Auth secrets flow via Key Vault references in `containerApps.bicep`
- SQLite (dev) vs SQL Server (prod) — intentional, documented

**Gaps:**
- **(MEDIUM)** Web container in `containerApps.bicep` is missing 6 env vars: `AUTH_ENTRA_ISSUER`, `AUTH_ENTRA_CLIENT_ID`, `AUTH_API_SCOPE_READ`, `AUTH_API_SCOPE_WRITE`, `STRAPI_URL`, `STRAPI_API_TOKEN` — likely set via `az containerapp update` in CI/CD but not declared in IaC

**Note:** `FrontendUrl` CORS concern is a false positive — handled via `appsettings.Production.json` `FrontendUrls` array baked into Docker image, not env var.

---

## Accepted Risks (Document Only)

| # | Risk | Rationale |
|---|------|-----------|
| 1 | Unstructured frontend logging | Container Apps captures console output; structured logging library adds complexity and bundle size for minimal gain at this scale |
| 2 | No frontend App Insights SDK | Would require `'use client'` instrumentation wrapper, increases bundle. Server-side API calls already tracked by backend App Insights |
| 3 | No explicit Cache-Control headers on API | ISR handles frontend caching; backend responses consumed by server components with their own revalidation. Browser-level API caching not needed |
| 4 | No bundle size budget in CI | Lighthouse performance ≥0.80 implicitly gates egregious bundle growth |
| 5 | `/health` and `/health/ready` identical | DB check is the only dependency; Container Apps health probes (Track 3) are the real fix |

## Deferred to Phase 8+

| Item | Rationale |
|------|-----------|
| Frontend Application Insights JS SDK | Consider when user session tracking matters |
| Synthetic availability tests | Scale-to-zero makes these noisy (cold start failures) |
| Custom Azure Portal dashboards | Single-developer project; not needed yet |
| Backend response time P95 CI gate | Requires benchmarking during CI — heavy infrastructure for marginal gain |
| CDN / Azure Front Door | Adds $35+/month; not justified at current traffic |

---

## Implementation Tracks

### Track 1: Alert Action Group (~20 min) — Critical Gap Fix

**Problem:** All 4 metric alerts in `monitoring.bicep` have no `actions` array. When thresholds are breached, Azure logs internally but sends no notification. The project owner would never know about outages or error spikes unless manually checking the Azure Portal.

**Implementation:**
1. Add `alertEmail` parameter to `monitoring.bicep`
2. Add `Microsoft.Insights/actionGroups` resource with an email receiver
3. Wire the action group ID into all 4 existing alert resources via `actions` array
4. Lower exception spike threshold from 20 to 10 (per 7.5 recommendation)
5. Thread `alertEmail` parameter through `main.bicep`

**Files to modify:**
- `infrastructure/modules/monitoring.bicep`
- `infrastructure/main.bicep`

**Overlap:** 7.5 Track 2 also identifies this — 7.10 owns the implementation since it's the cross-cutting alerting concern.

---

### Track 2: SEO Essentials (~30 min)

**Problem:** No `robots.txt` or XML sitemap. `metadataBase` uses placeholder URL.

**Implementation:**
1. Create `app/robots.ts` using Next.js Metadata API:
   - Allow all user agents
   - Disallow `/api/`, `/login/`
   - Point sitemap to production URL
2. Create `app/sitemap.ts` using Next.js Metadata API:
   - Fetch all patterns via `getPatterns({ pageSize: 100 })`
   - Generate entries for `/`, `/patterns`, and all `/patterns/[slug]`
   - Include `lastModified` from pattern `updatedDate`
   - Handle API unavailable gracefully (return static routes only)
3. Update `metadataBase` in `app/layout.tsx` to production URL
4. Update OpenGraph `url` in `app/layout.tsx`
5. Add tests for `robots.ts` and `sitemap.ts`

**Files to create/modify:**
- `app/robots.ts` (new)
- `app/sitemap.ts` (new)
- `app/layout.tsx`

---

### Track 3: IaC Health Probes & Env Parity (~45 min)

**Problem:** (a) No liveness/readiness/startup probes in `containerApps.bicep` — Azure uses default TCP probe only. (b) Web container missing 6 env vars in IaC.

**Implementation:**
1. Add health probes to API container app:
   - Startup: `GET /health`, 30s initial delay, 10s period, 3 failure threshold
   - Liveness: `GET /health`, 10s period, 3 failure threshold
   - Readiness: `GET /health/ready`, 10s period, 3 failure threshold
2. Add web container probes (HTTP GET on port 3000)
3. Add missing env vars to web container:
   - `AUTH_ENTRA_ISSUER`, `AUTH_ENTRA_CLIENT_ID` (plain values or Key Vault refs)
   - `AUTH_API_SCOPE_READ`, `AUTH_API_SCOPE_WRITE` (plain values)
   - `STRAPI_URL` (plain value — CMS container FQDN)
   - `STRAPI_API_TOKEN` (Key Vault secret reference)
4. Add `strapi-api-token` secret to Key Vault if not present
5. Document env var sources (IaC vs CI/CD vs baked-in) in INFRASTRUCTURE_MANAGEMENT.md

**Files to modify:**
- `infrastructure/modules/containerApps.bicep`
- `infrastructure/modules/keyvault.bicep` (if needed)
- `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md`

---

### Track 4: Business Telemetry (~1 hour)

**Problem:** Zero custom Application Insights events. No visibility into business-level activity.

**Implementation:**
1. Inject `TelemetryClient` into `PatternService` (already registered by `AddApplicationInsightsTelemetry()`)
2. Add `TrackEvent()` calls:
   - `PatternViewed` — when fetched by slug (properties: slug, category)
   - `PatternVoted` — when vote cast (properties: pattern ID)
   - `PatternSearched` — when listed with filters (properties: search term, category, tag count)
   - `PatternCreated` / `PatternUpdated` — on mutation
3. Add `TrackMetric()` for cache hit/miss on featured/trending patterns
4. Unit tests verifying `TelemetryClient.TrackEvent()` called with expected properties

**Files to modify:**
- `backend/src/AIEnterprisePatterns.Core/Services/PatternService.cs`
- `backend/tests/AIEnterprisePatterns.Core.Tests/Services/PatternServiceTests.cs`

---

### Track 5: Documentation & CI Updates (~30 min)

**Implementation:**
1. Update `MONITORING_GUIDE.md`:
   - Refresh performance baselines section
   - Add reference to IaC alert definitions (`monitoring.bicep`)
   - Document alert action group (after Track 1)
2. Add Lighthouse accessibility assertion to `lighthouserc.yml`:
   ```yaml
   categories:accessibility:
     - warn
     - minScore: 0.90
   ```
3. Add Decision 53 to `TECHNICAL_DECISIONS_LOG.md` (Phase 7.10 findings and trade-offs)

**Files to modify:**
- `documentation/operations/MONITORING_GUIDE.md`
- `lighthouserc.yml`
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`

---

## Summary

| Track | Description | Effort | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Alert Action Group | 20 min | None |
| 2 | SEO Essentials | 30 min | None |
| 3 | IaC Health Probes & Env Parity | 45 min | None (deploy after Track 1) |
| 4 | Business Telemetry | 1 hour | None |
| 5 | Documentation & CI Updates | 30 min | After Track 1 |
| **Total** | | **~2.75 hours** | |

**Recommended order:** Track 1 first (highest impact, lowest effort) → Tracks 2 + 3 in parallel → Track 4 → Track 5 last

## Overlap with 7.1–7.9 (DO NOT duplicate)

| Item | Owned By |
|------|----------|
| 429 rate-limit UX in API client | 7.3 Track 3 |
| `OperationCanceledException` middleware differentiation | 7.4 Track 3 |
| CMS HTML sanitization | 7.3 Track 1 |
| IaC cross-references in ops docs | 7.9 Track 2 |
| HSTS preload | Deferred to post-launch (7.4) |
| Alert action group (also in 7.5 Track 2) | 7.10 Track 1 owns implementation |

## Verification

- **Track 1:** `az deployment group what-if` validates action group + alert wiring
- **Track 2:** `npm run build` succeeds; visit `/robots.txt` and `/sitemap.xml` locally; run new tests
- **Track 3:** `az deployment group what-if` validates probes and env vars
- **Track 4:** `dotnet test` passes; verify `TelemetryClient` mock assertions
- **Track 5:** `npx lhci autorun` locally; review updated docs
