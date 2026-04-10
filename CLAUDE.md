# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Full-stack AI Enterprise Patterns Library: Next.js 16 + ASP.NET Core 8 backend with Clean Architecture.

**Tech Stack:**
- **Frontend:** Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS, shadcn/ui, Sonner, react-markdown with rehype-sanitize
- **Backend:** ASP.NET Core 8, Entity Framework Core 8, FluentValidation, API Versioning, Rate Limiting
- **Database:** SQLite (development), Azure SQL (production)
- **Deployment:** Azure Container Apps (primary) + App Services (secondary)
- **Testing:** Jest + React Testing Library (frontend), xUnit + Moq (backend), Playwright (E2E, cross-browser), Lighthouse CI, Chromatic
- **CMS:** Strapi 5 local-only (`cms/` directory) with git-committed backups (`backups/cms/`); compile-time fallbacks in `lib/cms/queries.ts`; media references retained in Azure Blob Storage (`staipatternsmedia`)
- **Current Phase:** Phase CMS Cold Storage in progress (Phases 1–3 complete — backup/restore scripts, generate-fallbacks, 3 GHA workflows); Phase 8 after CMS Cold Storage

## Development Commands

### Frontend (from project root)
```bash
npm run dev          # Start dev server at http://localhost:3000
npm run build        # Production build
npm run lint         # Run ESLint
npm test             # Run Jest tests
npm run storybook    # Storybook dev server at http://localhost:6006
npm run build-storybook  # Static Storybook build to storybook-static/
```

### Backend (from backend directory)
```bash
dotnet run --project src/AIEnterprisePatterns.Api    # Start API at http://localhost:5255
dotnet build && dotnet test                           # Build and test
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
dotnet ef migrations add MigrationName --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
```

Swagger (dev only): http://localhost:5255/swagger

### Docker / CMS (from project root)
```bash
docker compose up -d                    # Start SQL Server only (default)
docker compose --profile cms up -d     # Also start MySQL + Strapi (CMS profile)
docker compose --profile cms down      # Stop CMS containers when not needed
docker compose down                    # Stop all containers
```

> MySQL and Strapi are `cms`-profiled — they don't start with plain `docker compose up`. Start them only when working on CMS content. Strapi is **local-only** (Azure CMS resources are being removed in Phase CMS Cold Storage). WSL2 is capped at 2.5 GB via `~/.wslconfig`; container limits: SQL Server 1 GB, MySQL 512 MB, Strapi 512 MB.

## Architecture

### Backend
```
Api/ (Controllers, DTOs, Middleware, Validators)
  ↓ Infrastructure/ (AddInfrastructure: AppInsights, MemoryCache, TimeProvider, HealthChecks, RateLimiter)
  ↓ Core/ (Entities, Services, Interfaces, Enums)
  ↓ Data/ (Repositories, DbContext, Migrations)
```
- **UnitOfWork**: Registered but unused; PatternService calls `repository.SaveAsync()` directly
- **Rate Limiting**: `fixed` (100/min), `api` (50/min), `vote` (10/min per IP) — registered via `AddInfrastructure()`
- **PatternMapper**: Dedicated mapper class for DTO transformations
- **Memory Caching**: IMemoryCache for featured/trending patterns — registered via `AddInfrastructure()`
- **TimeProvider**: TimeProvider.System injected for testable time — registered via `AddInfrastructure()`
- **Value Objects**: Slug with GeneratedRegex validation

### Frontend
```
app/patterns/page.tsx          # Listing (server component)
app/patterns/[slug]/page.tsx   # Detail by slug (server component)
app/login/page.tsx             # Login page (server component; redirects if authenticated)
app/login/LoginForm.tsx        # Login form (client component; triggers Entra sign-in)
app/api/auth/[...nextauth]/    # Auth.js route handler
components/ui/                 # shadcn/ui primitives
components/layout/UserMenu.tsx # User menu / sign-in button in header
components/patterns/           # Pattern-specific components
components/providers/          # SessionProvider wrapper
lib/api/                       # client.ts, patterns.ts, mappers.ts, types.ts
lib/cms/                       # Strapi CMS client (client.ts, queries.ts, types.ts, components.tsx)
lib/types/                     # Frontend types (auth.ts: hasRole, roleLabel, Session extension)
auth.ts                        # Auth.js configuration (OIDC provider, JWT callbacks)
```
- Server Components by default; `'use client'` only for hooks/events/browser APIs
- VotingButton implements optimistic UI with revert-on-error
- Revalidation: 5min home, 2min listing, 10min details

### Authentication Architecture
```
Browser → Next.js (Auth.js v5 / NextAuth) → Entra External ID (OIDC)
                    ↓ (access token in Authorization header)
              ASP.NET Core API (JwtBearer validation via OIDC discovery)
```
- **Provider:** Azure Entra External ID (free for <50,000 MAU)
- **Frontend:** Auth.js v5 with generic `type: "oidc"` provider — swapping providers = changing env vars only
- **Backend:** Standard `AddJwtBearer()` middleware — no Microsoft-specific packages
- **Sessions:** JWT-based encrypted cookie — no database table needed
- **Roles:** Admin, Editor, Viewer — embedded in JWT access token via Entra App Roles
- **Role policies:** RequireAdmin, RequireEditor, RequireViewer (always registered regardless of auth config)
- **Public endpoints:** All GET patterns, vote — no auth required
- **Protected endpoints:** POST/PUT patterns → RequireEditor; DELETE → RequireAdmin
- **Guard clause:** JwtBearer only registered when `Authentication:Authority` is configured (tests/local work without Entra setup)
- **Setup guide:** `documentation/operations/AUTH_SETUP_GUIDE.md`

## Critical Conventions

### Category Enum Mapping
Backend uses PascalCase enums (`DesignPatterns`, `Architecture`, `AIPrompts`, `Security`, `Performance`), frontend expects spaced strings (`Design Patterns`, etc.).

**Always use `lib/api/mappers.ts`:** `mapBackendCategory()` / `mapFrontendCategory()`

### Slug-Based Routing
Patterns use slug (not ID): `GET /api/patterns/{slug}` → route `/patterns/[slug]`

### Database Seeding
6 patterns (`b0000000-...`) + 18 tags (`a0000000-...`), many-to-many via junction table.

### Environment Variables
```bash
# Frontend (.env.local)
NEXT_PUBLIC_API_BASE_URL=http://localhost:5255/api
NEXT_PUBLIC_API_TIMEOUT=30000
AUTH_SECRET=<generate: openssl rand -base64 32>
AUTH_TRUST_HOST=true
AUTH_ENTRA_ISSUER=https://aipatterns.ciamlogin.com/aipatterns.onmicrosoft.com/v2.0
AUTH_ENTRA_CLIENT_ID=<frontend-app-client-id>
AUTH_ENTRA_CLIENT_SECRET=<frontend-app-client-secret>
AUTH_API_SCOPE_READ=api://aipatterns-api/patterns.read
AUTH_API_SCOPE_WRITE=api://aipatterns-api/patterns.write
# Backend: ConnectionString:DefaultConnection (empty=SQLite dev), FrontendUrl (CORS)
# Backend auth: Authentication:Authority, Authentication:Audience, Authentication:RequireHttpsMetadata
# CMS (server-only, no NEXT_PUBLIC_ prefix — local dev only; not set in production)
STRAPI_URL=http://localhost:1337       # local Strapi only; unset in production (fallbacks used)
STRAPI_API_TOKEN=<read-only-api-token> # local dev only; not needed in production
```

## API Endpoints

Base: `http://localhost:5255/api` | Full reference: `documentation/api/`

| Method | Endpoint | Auth Required | Rate Limit |
|--------|----------|---------------|------------|
| GET | `/patterns` | None | api (50/min) |
| GET | `/patterns/featured` | None | api |
| GET | `/patterns/trending` | None | api |
| GET | `/patterns/{slug}` | None | api |
| GET | `/patterns/{slug}/related` | None | api |
| POST | `/patterns/{id}/vote` | None | vote (10/min) |
| POST | `/patterns` | RequireEditor | api |
| PUT | `/patterns/{id}` | RequireEditor | api |
| DELETE | `/patterns/{id}` | RequireAdmin | api |
| GET | `/auth/me` | Authorize | — |
| GET | `/health`, `/health/ready` | None | — |

## Database

- **Dev:** SQLite at `backend/src/AIEnterprisePatterns.Api/aipatterns.db`
- **Prod:** SQL Server (migrations applied manually, not auto-applied)
- **Entities:** `Pattern` (Title, Slug, Content, Category, Status, VoteCount, IsFeatured, IsTrending) + `Tag` + many-to-many

## Frontend Coding Standards

- **TypeScript:** Prefer `type` over `interface`; avoid `any`; use `unknown` with type guards
- **Tailwind:** Only utility classes; use `cn()` for conditionals; no CSS files or inline styles
- **Accessibility:** Semantic HTML, `<label htmlFor>` + matching `id`, keyboard accessible
- **Forms:** Validate on blur + submit; disable button during submission; use Zod for complex schemas
- **Server vs Client:** Default to Server Components; `'use client'` only when needed

## Deployment

- **Primary:** Azure Container Apps (scale-to-zero, ~$5-12/month)
- **Frontend:** https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- **Backend:** https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- **Reference:** `deployment/CONTAINER_APPS_GUIDE.md`, `infrastructure/README.md` (Bicep IaC)
- **Backend port:** 5255 local, 8080 in Docker (non-root user `appuser`)
- **Health checks:** CI/CD verifies content ("Healthy" for backend, "next-size-adjust" for frontend)

## Testing

- **Frontend:** `npm test` (Jest + React Testing Library); 396/396 tests, 70%+ coverage (stmt/branch/fn/line — enforced in CI)
- **Backend:** `dotnet test` (xUnit + Moq); 114/114 tests passing (~85% testable coverage)
- **E2E:** Playwright cross-browser matrix — Chromium, Firefox, WebKit (CI runs all three in parallel via `strategy.matrix`)
- **Performance:** Lighthouse CI (`@lhci/cli`) — LCP < 2.5s, FCP < 1.8s, TTI < 5s, Performance ≥ 0.80 — gates deploy in `frontend-container-deploy.yml`
- **Visual regression:** Chromatic — 38 Storybook stories published on every deploy; unreviewed changes block deploy once baseline is hardened (`continue-on-error: true` + `--exit-zero-on-changes` until baseline accepted)
- **Auth test strategy:** next-auth/react mocked globally in jest.setup.ts (unauthenticated default); per-test overrides via `(useSession as jest.Mock).mockReturnValue(...)`
- **Radix UI in tests:** Mock `@/components/ui/dropdown-menu` inline in test files (portals don't render in jsdom)
- **Backend auth tests:** TestAuthHandler (header-driven: `X-Test-Roles`) replaces JwtBearer in WebApplicationFactory
- **CI/CD deploy gate:** `run-tests` → (`build-and-push` + `lhci` + `chromatic`) in parallel → `deploy` (all three must pass)

### Coverage Verification Rule (MANDATORY)

Whenever you add or modify code in `app/`, `components/`, or `lib/` that introduces new exported functions, component renderers, or utility logic, **run `npm run test:ci` before committing** and confirm all four metrics are ≥ 70%:

```bash
npm run test:ci   # stmt/branch/fn/line must all be ≥ 70%
```

**Common pitfalls:**
- Mocking a library (e.g. `react-markdown`) in a way that bypasses inline renderers — update the mock to invoke those renderers so they are exercised
- Adding new functions to an existing file without corresponding tests
- Deleting test files without checking whether the removed coverage drops below threshold

Fix any breach **before** committing — do not rely on CI to catch it.

### Testing Gotchas

**Jest / React Testing Library:**
- Use `jest.spyOn(apiClient, 'get')` not `jest.mock` factory for plain-object module exports (SWC compat)
- Mock ESM packages (react-markdown, remark-gfm, rehype-sanitize, isomorphic-dompurify) at test-file level. `isomorphic-dompurify` has nested ESM deps (`@exodus/bytes`) — do NOT add to `transformIgnorePatterns`; always mock at file level
- `next-auth/react`: mocked globally in jest.setup.ts (unauthenticated default); override per-test with `(useSession as jest.Mock).mockReturnValue(...)`
- **Radix UI DropdownMenu / AlertDialog**: mock inline — portals don't render in jsdom
- **Radix UI Select**: context-based mock; `TS2347` fix: cast context defaults instead of using generic `React.createContext<T>()` inside factory
- **localStorage hooks**: split add + clear into separate `act()` calls (React 18 batching)
- **Dialog mock for SavedSearches**: don't gate rendering on `open` prop
- **Moq + optional params**: specify ALL params explicitly with `It.IsAny<T>()` — expression trees can't use optional defaults
- **CardTitle renders as div**: use `<h1>` directly where heading role matters
- **Slow userEvent.type loops**: adding many tags in a loop can exceed 5000ms; add explicit timeout as 3rd arg: `it('...', async () => {...}, 15000)`

**E2E / Playwright:**
- **Vote mocking**: use `page.addInitScript` (not `page.route`) to intercept client-side fetch
- **E2E CI**: build needs `NEXT_PUBLIC_API_BASE_URL` baked in; explicit `npm run start &` + health-poll before e2e
- Avoid `waitForLoadState('networkidle')` for filtered/search URLs — use element-based waiting instead
- **webkit date inputs**: `page.fill()` on `type="date"` can be intercepted by webkit's native picker; use `fillDateInput()` helper in `e2e/critical-flows.spec.ts`
- **Hydration race**: don't use heading visibility as sole wait signal — wait for the specific input element
- **`toHaveURL` vs `waitForURL`**: use `expect(page).toHaveURL()` for Next.js App Router pushState navigation — `waitForURL` never fires for `history.pushState`
- **WebKit URL-encodes commas**: WebKit encodes `,` as `%2C`; regex must handle both: `/param=[^&]*(%2C|,)/i`
- **Lighthouse CI cold-start**: `warmupRuns: 1` eliminates the first-run ~40% latency outlier

## Documentation Rules

Full governance rules in `documentation/GOVERNANCE.md`. Quick reference:

| Content Type | Folder |
|-------------|--------|
| How the system is built | `documentation/architecture/` |
| REST API reference (endpoints, DTOs, examples) | `documentation/api/` |
| CMS component schemas, field tables, dependency map | `documentation/cms-components/` |
| What the system should do | `documentation/requirements/` |
| Why we made a decision | `documentation/decisions/` |
| How we test | `documentation/testing/` |
| How to run in production | `documentation/operations/` |
| Project roadmap and phase plans | `documentation/project/` |
| Audit/review snapshots | `documentation/reviews/` |
| Phase-specific test reports | `documentation/test_results/` |
| Azure deployment guides | `deployment/` |
| Visual diagrams (Mermaid) | `documentation/diagrams/` |

**Key docs:** `documentation/EXECUTIVE_SUMMARY.md` (CTO-facing overview), `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` (63 decisions), `documentation/testing/TESTING_STRATEGY.md`, `documentation/architecture/SYSTEM_OVERVIEW.md`, `DOCUMENTATION_INDEX.md`

**Diagrams:** All 15 Mermaid diagrams are complete and embedded in their target docs. See `documentation/diagrams/DIAGRAM_INDEX.md` for the full inventory and the established color palette convention (blue=frontend/API, green=backend/core, amber=database, purple=CMS/providers, sky=Azure services, gray=CI/CD).

**Storybook:** Stories are colocated with their components (`*.stories.tsx`). Config in `.storybook/`. Shared fixtures in `.storybook/fixtures.ts`. Mock for `next-auth/react` in `.storybook/mocks/next-auth-react.tsx`.

## Technical Decision Log (MANDATORY)

**Update `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` whenever you make an architectural, security, infrastructure, performance, or technology decision.**

Use the format in `documentation/decisions/DECISION_TEMPLATE.md`. Include: date, title, category, what was decided and why, alternatives evaluated.

This is not optional — it preserves architectural knowledge across sessions.

## Important Notes

- **CMS project:** `cms/` (Strapi 5) — local-only content authoring; content model, Dockerfile, seed script. Architecture: `documentation/architecture/CMS_ARCHITECTURE.md`
- **CMS cold storage:** Strapi is local-only. Backups in `backups/cms/`. Scripts: `scripts/cms/backup.sh`, `scripts/cms/restore.sh`. Azure MySQL + Container App being deleted (Phase CMS Cold Storage). `deployment/scripts/provision-cms.ps1` retained for historical reference / rollback only.
- **Infrastructure project** — `AddInfrastructure()` extension registers AppInsights, MemoryCache, TimeProvider, HealthChecks, RateLimiter (extracted from Program.cs in Phase 6.8)
- **DELETE endpoint** exists in controller but frontend doesn't wire it up yet
- **Vote endpoint** uses atomic `ExecuteUpdateAsync` for relational providers (SQLite/SQL Server), with InMemory fallback for tests
- **Swagger** is development-only, gated behind `IsDevelopment()` check
- **Container security:** Non-root user in Docker requires port 8080 (ports <1024 need root)
- **Docker base images:** All 3 Dockerfiles use SHA-pinned `FROM` lines (`@sha256:<digest>`) for supply chain security; Dependabot Docker ecosystem keeps pins current
- **Backend runtime:** `aspnet:8.0-alpine` (not Debian) — ~90 MB image, no `curl`/`apt-get` layer; healthcheck uses BusyBox `wget -qO-`
