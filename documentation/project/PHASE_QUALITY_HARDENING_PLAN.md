# Phase 7: Quality & Hardening Evaluation Plan

**Created:** 2026-03-17
**Status:** Active
**Purpose:** Systematically audit every aspect of the solution to ensure enterprise best-in-class standards before adding new features.

---

## Context

With Phase 6 complete, the solution is feature-complete. This evaluation phase systematically audits code quality, security, dependencies, infrastructure, CI/CD, and documentation to produce actionable recommendations. After all evaluations, we select which recommendations to implement.

## Approach

The evaluation is split into **10 focused areas**, each designed to fit within a single Claude session context. Each area produces a findings report with prioritized recommendations (Critical / High / Medium / Low). After all evaluations, we consolidate and select which to implement.

---

## Evaluation Areas

### Area 1: Dependency Audit — Frontend
**Scope:** `package.json` (root), `cms/package.json`
**What to evaluate:**
- Are all npm dependencies on their latest compatible versions?
- Are there known vulnerabilities (`npm audit`)?
- Are there deprecated packages or better modern alternatives?
- Are dev vs prod dependencies correctly classified?
- Is the lock file healthy and consistent?
- CMS (Strapi 5) plugin/dependency currency

**Key files:** `package.json`, `package-lock.json`, `cms/package.json`, `cms/package-lock.json`

---

### Area 2: Dependency Audit — Backend
**Scope:** All 7 `.csproj` files
**What to evaluate:**
- Are all NuGet packages on latest stable versions?
- Are there known CVEs in any dependencies?
- Are test framework packages current (xUnit, Moq, etc.)?
- Is the .NET 8 SDK still the best target or should we plan for .NET 9?
- Are there redundant or unused package references?

**Key files:** All `.csproj` files in `backend/src/` and `backend/tests/`

---

### Area 3: Frontend Code Quality & Security
**Scope:** `app/`, `components/`, `lib/`, `hooks/`, root configs
**What to evaluate:**
- TypeScript strictness settings and best practices
- ESLint rule coverage — are we using recommended security/a11y plugins?
- CSP headers, XSS prevention, CSRF protection
- `next.config.mjs` security headers
- Server vs client component boundaries — any unnecessary `'use client'`?
- API client error handling robustness
- Input sanitization (especially markdown rendering with rehype-sanitize)
- Modern JS/TS patterns (are we using latest syntax, avoiding legacy patterns?)
- Tailwind config optimization

**Key files:** `next.config.mjs`, `tsconfig.json`, `.eslintrc.json`, `auth.ts`, `lib/api/client.ts`, `middleware.ts` (if exists), select app/component files

---

### Area 4: Backend Code Quality & Security
**Scope:** `backend/src/` (Api, Core, Data, Infrastructure)
**What to evaluate:**
- OWASP Top 10 compliance (injection, auth, SSRF, etc.)
- Rate limiting configuration adequacy
- Input validation completeness (FluentValidation rules)
- Error handling and information leakage prevention
- CORS configuration security
- JWT validation strictness
- EF Core query safety (SQL injection via raw queries?)
- The known vote race condition — severity and fix options
- API versioning implementation
- Logging practices (no PII leakage)
- `Program.cs` and middleware pipeline ordering

**Key files:** `Program.cs`, controllers, validators, `PatternService.cs`, `ApplicationDbContext.cs`, `InfrastructureExtensions.cs`

---

### Area 5: Infrastructure as Code & Azure Security
**Scope:** `infrastructure/` (Bicep), `deployment/` scripts
**What to evaluate:**
- Bicep modules following Azure best practices (naming, tagging, diagnostics)
- Key Vault usage — are all secrets properly managed?
- Network security — are services properly isolated?
- Container Apps security (ingress, scaling, managed identity)
- SQL Server firewall rules and encryption
- ACR security (admin disabled, RBAC access)
- Monitoring completeness (alerts, dashboards, log retention)
- Deployment scripts — idempotency, error handling
- Cost optimization opportunities

**Key files:** All `infrastructure/*.bicep`, `deployment/*.ps1`, `deployment/scripts/*.ps1`

---

### Area 6: CI/CD Pipeline Quality
**Scope:** `.github/workflows/` (4 workflow files)
**What to evaluate:**
- Are GitHub Actions using pinned versions (SHA, not tags)?
- OIDC auth vs stored secrets — are we using best practice?
- Are there supply chain attack vectors (unpinned actions, script injection)?
- Build caching effectiveness
- Test matrix completeness
- Deployment safety (rollback capability, health checks, canary?)
- Secret management in workflows
- Workflow permissions (least privilege?)
- Are there warnings or deprecated features in action logs?
- Branch protection alignment

**Key files:** All `.github/workflows/*.yml`

---

### Area 7: Docker & Container Security
**Scope:** 3 Dockerfiles, `docker-compose.yml`
**What to evaluate:**
- Base image currency and security (are we on latest stable?)
- Multi-stage build optimization
- Non-root user enforcement
- No secrets baked into images
- `.dockerignore` completeness
- Image size optimization
- Health check configuration
- Docker Compose security (no hardcoded passwords in committed files)
- Container resource limits

**Key files:** `Dockerfile` (root), `backend/Dockerfile`, `cms/Dockerfile`, `docker-compose.yml`, `.dockerignore`

---

### Area 8: Testing Coverage & Quality
**Scope:** All test files (31 frontend, 26 backend, 2 E2E), test configs
**What to evaluate:**
- Are there untested critical paths?
- Test quality — are assertions meaningful or shallow?
- E2E coverage — are all critical user journeys covered?
- Playwright config — browser coverage, retry strategy, timeouts
- Jest config — coverage thresholds, module mapping
- Lighthouse CI thresholds — are they ambitious enough?
- Chromatic/Storybook coverage — are all visual components covered?
- Backend test coverage — are edge cases tested?
- Mock quality — are mocks realistic?
- Test performance — any slow tests that could be optimized?

**Key files:** `jest.config.mjs`, `playwright.config.ts`, `lighthouserc.yml`, select test files from each area

---

### Area 9: Documentation Completeness & Accuracy
**Scope:** `documentation/`, `CLAUDE.md`, `DOCUMENTATION_INDEX.md`, `deployment/` guides
**What to evaluate:**
- Is every architectural decision documented?
- Are all API endpoints documented with examples?
- Is the setup guide complete for a new developer?
- Are diagrams current and accurate?
- Is operations documentation sufficient for incident response?
- Are there stale/outdated docs that reference old phases or removed features?
- Is the documentation structure navigable?
- Are CMS component docs complete?

**Key files:** `DOCUMENTATION_INDEX.md`, `CLAUDE.md`, key docs in each `documentation/` subfolder

---

### Area 10: Production Readiness & Observability
**Scope:** Cross-cutting concerns
**What to evaluate:**
- Health check endpoints — comprehensive enough?
- Structured logging — is it consistent across frontend and backend?
- Application Insights integration — are custom metrics/events tracked?
- Error tracking and alerting — would we know if something breaks?
- Performance baselines — response times, bundle sizes
- SEO and meta tags
- Accessibility compliance (WCAG 2.1 AA)
- Cache strategy effectiveness (revalidation intervals, CDN)
- Environment parity (dev vs prod configuration drift)

**Key files:** Health check configs, `next.config.mjs` (headers), select pages for meta/SEO review, monitoring Bicep modules

---

## Execution Plan

| Order | Area | Est. Effort | Dependencies |
|-------|------|-------------|--------------|
| 1 | Dependency Audit — Frontend | Light | None |
| 2 | Dependency Audit — Backend | Light | None |
| 3 | Frontend Code Quality & Security | Medium | None |
| 4 | Backend Code Quality & Security | Medium | None |
| 5 | Infrastructure as Code & Azure Security | Medium | None |
| 6 | CI/CD Pipeline Quality | Medium | None |
| 7 | Docker & Container Security | Light | None |
| 8 | Testing Coverage & Quality | Medium | None |
| 9 | Documentation Completeness & Accuracy | Light | None |
| 10 | Production Readiness & Observability | Medium | Areas 3-8 insights helpful |

Areas 1-9 are independent and could be evaluated in any order. Area 10 benefits from insights gathered in earlier areas.

## Output Format

Each area evaluation will produce:
- **Findings table** with severity (Critical / High / Medium / Low)
- **Specific recommendations** with rationale
- **Quick wins** vs **significant effort** classification

## Post-Evaluation

After all 10 areas are evaluated, we consolidate into a master recommendations list and select which to implement based on impact vs effort.
