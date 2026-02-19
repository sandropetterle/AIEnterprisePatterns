# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Full-stack AI Enterprise Patterns Library: Next.js 16 + ASP.NET Core 8 backend with Clean Architecture.

**Tech Stack:**
- **Frontend:** Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS, shadcn/ui, Sonner, react-markdown with rehype-sanitize
- **Backend:** ASP.NET Core 8, Entity Framework Core 8, FluentValidation, API Versioning, Rate Limiting
- **Database:** SQLite (development), Azure SQL (production)
- **Deployment:** Azure Container Apps (primary) + App Services (secondary)
- **Testing:** Jest + React Testing Library (frontend), xUnit + Moq (backend)
- **Current Phase:** 5.1 - Authentication & Authorization (complete)

## Development Commands

### Frontend (from project root)
```bash
npm run dev          # Start dev server at http://localhost:3000
npm run build        # Production build
npm run lint         # Run ESLint
npm test             # Run Jest tests
```

### Backend (from backend directory)
```bash
dotnet run --project src/AIEnterprisePatterns.Api    # Start API at http://localhost:5255
dotnet build && dotnet test                           # Build and test
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
dotnet ef migrations add MigrationName --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
```

Swagger (dev only): http://localhost:5255/swagger

## Architecture

### Backend
```
Api/ (Controllers, DTOs, Middleware, Validators)
  ↓ Core/ (Entities, Services, Interfaces, Enums)
  ↓ Data/ (Repositories, DbContext, Migrations)
Infrastructure/ (empty placeholder)
```
- **UnitOfWork**: Registered but unused; PatternService calls `repository.SaveAsync()` directly
- **Rate Limiting**: `fixed` (100/min), `api` (50/min), `vote` (10/min per IP)
- **PatternMapper**: Dedicated mapper class for DTO transformations
- **Memory Caching**: IMemoryCache for featured/trending patterns
- **TimeProvider**: TimeProvider.System injected for testable time
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
```

## API Endpoints

Base: `http://localhost:5255/api`

| Method | Endpoint | Auth Required | Rate Limit |
|--------|----------|---------------|------------|
| GET | `/patterns` | None | api (50/min) |
| GET | `/patterns/featured` | None | api |
| GET | `/patterns/trending` | None | api |
| GET | `/patterns/{slug}` | None | api |
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
- **Reference:** `deployment/DEPLOYMENT_SUMMARY.txt`, `deployment/CONTAINER_APPS_GUIDE.md`
- **Backend port:** 5255 local, 8080 in Docker (non-root user `appuser`)
- **Health checks:** CI/CD verifies content ("Healthy" for backend, "next-size-adjust" for frontend)

## Testing

- **Frontend:** `npm test` (Jest + React Testing Library); 286/286 tests, 70%+ coverage
- **Backend:** `dotnet test` (xUnit + Moq); 87/87 tests passing (~85% testable coverage)
- **Auth test strategy:** next-auth/react mocked globally in jest.setup.ts (unauthenticated default); per-test overrides via `(useSession as jest.Mock).mockReturnValue(...)`
- **Radix UI in tests:** Mock `@/components/ui/dropdown-menu` inline in test files (portals don't render in jsdom)
- **Backend auth tests:** TestAuthHandler (header-driven: `X-Test-Roles`) replaces JwtBearer in WebApplicationFactory
- **CI/CD:** Tests must pass before deployment

## Documentation Rules

Place files in the correct folder:
- `documentation/` — permanent reference (SRS, strategies, decisions)
- `documentation/test_results/` — test execution reports
- `documentation/reviews/` — code/security reviews
- `documentation/transient/` — phase-specific and temporary files

**Key docs:** `documentation/TECHNICAL_DECISIONS_LOG.md`, `documentation/TESTING_STRATEGY.md`, `documentation/instructions.md`

## Technical Decision Log (MANDATORY)

**Update `documentation/TECHNICAL_DECISIONS_LOG.md` whenever you make an architectural, security, infrastructure, performance, or technology decision.**

Include: date, title, category, what was decided and why, pros/cons, alternatives evaluated.

This is not optional — it preserves architectural knowledge across sessions.

## Important Notes

- **Infrastructure project** is empty (placeholder for future services)
- **DELETE endpoint** exists in controller but frontend doesn't wire it up yet
- **Vote endpoint** has race condition risk (uses `SaveAsync()` instead of `ExecuteUpdateAsync`)
- **Swagger** is development-only, gated behind `IsDevelopment()` check
- **Container security:** Non-root user in Docker requires port 8080 (ports <1024 need root)
