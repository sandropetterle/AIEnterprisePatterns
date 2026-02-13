# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Full-stack AI Enterprise Patterns Library: Next.js 16 + ASP.NET Core 8 backend with Clean Architecture. Platform for curating and sharing AI-driven enterprise implementation patterns and best practices.

**Tech Stack:**
- **Frontend:** Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS, shadcn/ui, Sonner (toast notifications), react-markdown with rehype-sanitize
- **Backend:** ASP.NET Core 8, Entity Framework Core 8, FluentValidation, API Versioning, Rate Limiting
- **Database:** SQLite (development), Azure SQL (production)
- **Deployment:** Azure Container Apps (scale-to-zero, cost-optimized) + App Services (traditional)
- **Testing:** Jest + React Testing Library (frontend), xUnit + Moq (backend)

**Current Phase:** Phase 4 - Production deployment complete, Azure Container Apps operational

## Development Commands

### Frontend (from project root)
```bash
npm run dev          # Start dev server at http://localhost:3000
npm run build        # Production build
npm start            # Start production server
npm run lint         # Run ESLint
```

### Backend (from backend directory)
```bash
# Run the API (starts at http://localhost:5255)
dotnet run --project src/AIEnterprisePatterns.Api

# Build and test
dotnet build
dotnet test

# Database migrations
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
dotnet ef migrations add MigrationName --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api

# Run from specific project
cd src/AIEnterprisePatterns.Api && dotnet run
```

### Swagger API Documentation
- **Development only:** http://localhost:5255/swagger
- Gated behind `IsDevelopment()` check in Program.cs

## Architecture

### Backend Clean Architecture Layers

```
Api/ (Controllers, DTOs, Middleware, Validators)
  ↓ depends on
Core/ (Entities, Services, Interfaces, Enums)
  ↓ depends on
Data/ (Repositories, DbContext, Migrations, Configurations)

Infrastructure/ (currently empty - placeholder for future services)
```

**Key Points:**
- **UnitOfWork**: Registered in DI but currently unused. PatternService calls repository.SaveAsync() directly.
- **Repository Pattern**: IPatternRepository/PatternRepository with async methods
- **FluentValidation**: Auto-validation enabled, validators in Api project with query models for input validation
- **Rate Limiting**: Three policies - `fixed` (100/min), `api` (50/min), `vote` (10/min per IP)
- **API Versioning**: v1 via URL segments, configured for future expansion
- **Value Objects**: Slug value object with GeneratedRegex for validation
- **TimeProvider**: TimeProvider.System injected for testable time operations
- **PatternMapper**: Dedicated mapper class for clean DTO transformations
- **Memory Caching**: IMemoryCache for featured/trending patterns
- **Query Optimization**: EF Core projections and atomic operations (ExecuteUpdateAsync) where applicable

### Frontend Architecture

```
app/                    # Next.js App Router pages
  patterns/
    page.tsx           # Patterns listing (server component)
    [slug]/page.tsx    # Pattern detail by slug (server component)

components/
  ui/                  # shadcn/ui primitives
  patterns/            # Pattern-specific components
  home/                # Home page components

lib/
  api/                 # Backend API client
    client.ts          # HTTP methods with timeout & error handling
    patterns.ts        # Pattern-specific API functions
    mappers.ts         # DTO transformations (handles category mapping)
    types.ts           # Backend DTO types
  types/               # Frontend types
  utils/               # Helper functions
```

**Key Patterns:**
- **Default to Server Components**: Only use `'use client'` when needed (hooks, events, browser APIs)
- **Data Fetching**: Async Server Components with loading.tsx/error.tsx boundaries
- **API Client**: Centralized in `lib/api/` with consistent error handling and 30s timeout
- **Optimistic Updates**: VotingButton implements optimistic UI with revert-on-error pattern
- **Performance**: React.memo, code splitting with next/dynamic, Next.js revalidation (5min home, 2min listing, 10min details)
- **Security**: CSP headers, HSTS, X-Frame-Options, sanitized markdown rendering, safe JSON-LD

## Critical Conventions

### Category Enum Mapping
Backend uses PascalCase enums (`DesignPatterns`, `Architecture`, `AIPrompts`, `Security`, `Performance`), frontend expects spaced strings (`Design Patterns`, `Architecture`, etc.).

**Mapping handled in:** `lib/api/mappers.ts`
- `mapBackendCategory()` - Backend → Frontend
- `mapFrontendCategory()` - Frontend → Backend

Always use mapper functions when transforming between backend DTOs and frontend types.

### Slug-Based Routing
Patterns are identified by slug (URL-safe string), not ID, for SEO.
- **Endpoint:** `GET /api/patterns/{slug}` (not `/api/patterns/{id}`)
- **Frontend route:** `/patterns/[slug]` dynamic route

### Database Seeding
ApplicationDbContext includes seed data:
- **6 patterns** with predefined GUIDs (`b0000000-0000-0000-0000-00000000000X`)
- **18 tags** with predefined GUIDs (`a0000000-0000-0000-0000-00000000000X`)
- **Many-to-many** junction table seeded via `HasMany().WithMany().UsingEntity()`

### Environment Variables

**Frontend (.env.local):**
```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:5255/api
NEXT_PUBLIC_API_TIMEOUT=30000
```

**Backend (appsettings.json):**
- `ConnectionString:DefaultConnection` - Empty in dev (uses SQLite), SQL Server connection in production
- `FrontendUrl` - Production frontend URL for CORS

## API Endpoints

Base: `http://localhost:5255/api`

| Method | Endpoint | Description | Rate Limit |
|--------|----------|-------------|------------|
| GET | `/patterns` | Paginated patterns with filters | api (50/min) |
| GET | `/patterns/featured` | Featured patterns | api |
| GET | `/patterns/trending` | Trending patterns | api |
| GET | `/patterns/{slug}` | Pattern by slug | api |
| POST | `/patterns/{id}/vote` | Vote for pattern | vote (10/min) |
| POST | `/patterns` | Create pattern | api |
| PUT | `/patterns/{id}` | Update pattern | api |
| DELETE | `/patterns/{id}` | Delete pattern | api |

**Health Checks:**
- `/health` - Basic health check
- `/health/ready` - Readiness probe with DB check

## Database

**Development:**
- SQLite at `backend/src/AIEnterprisePatterns.Api/aipatterns.db`
- Auto-created on startup if migrations exist

**Production:**
- SQL Server via connection string
- Migrations must be applied manually (not auto-applied in production)

**Entities:**
- `Pattern` - Main entity with Title, Slug, Content, Category, Status, VoteCount, IsFeatured, IsTrending
- `Tag` - Simple Name property
- **Many-to-many:** `Pattern.Tags` ↔ `Tag.Patterns`

## Frontend Patterns (from .cursorrules)

### Server vs Client Components
- **Default to Server Components** - Keep `'use client'` boundary as low in tree as possible
- Use `'use client'` only for: hooks (useState, useEffect), event handlers, browser APIs, Context consumers

### TypeScript
- Explicit types for component props (prefer `type` over `interface`)
- Explicit types for API responses and reusable data structures
- Let TypeScript infer simple cases (useState, const declarations)
- Avoid `any` - use `unknown` with type guards

### Styling with Tailwind
- Use **only** Tailwind utility classes (no CSS files or inline styles)
- Use `cn()` utility (clsx + tailwind-merge) for conditional classes
- Group related utilities for readability (layout, spacing, appearance, text, dark mode, responsive)

### Forms & Validation
- Validate on blur and on submit (not every keystroke)
- Show specific, actionable error messages
- Disable submit button during submission
- Use Zod for schema validation (if needed for complex forms)

### Accessibility (Mandatory)
- Use semantic HTML (`<button>`, `<a>`, `<nav>`, `<main>`, headings)
- Associate labels with inputs: `<label htmlFor="id">` + `<input id="id">`
- ARIA attributes only when semantic HTML insufficient
- Ensure keyboard accessibility (native elements are focusable by default)

## Deployment

**4 GitHub Actions Workflows:**
1. `backend-deploy.yml` - Backend to App Services
2. `frontend-deploy.yml` - Frontend to App Services
3. `backend-container-deploy.yml` - Backend to Container Apps ✅ Primary
4. `frontend-container-deploy.yml` - Frontend to Container Apps ✅ Primary

**Production URLs (Azure Container Apps):**
- **Frontend:** https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- **Backend API:** https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/swagger

**Azure Resources:**
- **Container Apps** (Primary) - Scale-to-zero, cost: $5-12/month (60-80% savings vs App Services)
- **App Services** (Secondary) - Traditional hosting, cost: $18-24/month
- **Azure SQL Database** - Serverless tier
- **Azure Container Registry** - Docker image hosting

### Deployment Commands

**Setup GitHub Secrets:**
```powershell
cd deployment
.\setup-github-secrets.ps1
```
Add 3 secrets at: https://github.com/sandropetterle/AIEnterprisePatterns/settings/secrets/actions

**Apply Database Migrations (Production):**
```powershell
$env:CONNECTION_STRING = "Server=tcp:sql-aipatterns-sandr-1770754196.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=<password>;Encrypt=True;"

cd backend
dotnet ef database update --project src/AIEnterprisePatterns.Api --connection "$env:CONNECTION_STRING"
```

**View Container Logs:**
```powershell
az containerapp logs show --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod --follow
```

**Check Scaling Status:**
```powershell
az containerapp revision list --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod
```

**Key Files:**
- `deployment/DEPLOYMENT_SUMMARY.txt` - All passwords & URLs
- `deployment/CONTAINER_APPS_GUIDE.md` - Full deployment guide
- `deployment/COST_COMPARISON.md` - Cost analysis

## Troubleshooting

### Backend not starting
- Ensure .NET 8 SDK installed: `dotnet --version`
- Check port 5255 not in use
- Verify database migrations applied

### "Failed to load patterns" in frontend
1. Backend running? Check http://localhost:5255/swagger
2. CORS issue? Backend allows http://localhost:3000 by default
3. Environment variable correct? Check `.env.local` has `NEXT_PUBLIC_API_BASE_URL=http://localhost:5255/api`

### Database issues
- Run migrations: `dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api`
- Delete `aipatterns.db` and re-run migrations to reset

### Type errors in API client
- Check mapper functions in `lib/api/mappers.ts` handle category transformation
- Backend categories are PascalCase enums, frontend uses spaced strings

## Testing Strategy

### Test Frameworks
**Frontend:**
- **Unit/Integration:** Jest, React Testing Library
- **E2E:** Playwright or Cypress
- Run: `npm test`

**Backend:**
- **Unit/Integration:** xUnit, Moq (mocking), EF Core InMemory provider
- Run: `dotnet test` (from backend directory)

### Test Coverage Requirements
- Target: 80%+ for core business logic
- All critical UI components tested
- API endpoints have integration tests
- Tests run automatically in CI/CD before deployment

### Key Test Areas (from Phase 3 learnings)
1. **Category Mapping** - Test bidirectional transformation (PascalCase ↔ spaced strings)
2. **CORS** - Test with actual fetch calls, not just Swagger
3. **Type Safety** - Test null/undefined handling between C# and TypeScript
4. **Integration Points** - Test frontend-backend data flow end-to-end
5. **Optimistic Updates** - Test revert-on-error logic in voting

## Documentation

**Key Documents:**
- `README.md` - Quick start guide and setup instructions
- `CODEBASE_REVIEW_REPORT.md` - Security and code quality audit (1 critical, 11 high, 27 medium issues identified)
- `documentation/instructions.md` - Full Software Requirements Specification (SRS)
- `documentation/TESTING_STRATEGY.md` - Comprehensive testing approach
- `documentation/CI_CD_STRATEGY.md` - Pipeline and deployment strategy
- `documentation/PHASE3_LEARNINGS.md` - Integration patterns and best practices
- `documentation/QUICK_START_PHASE4.md` - Azure deployment quick start
- `documentation/TECHNICAL_DECISIONS_LOG.md` - Architecture and design decisions with rationale
- `.claude/plans/hashed-swinging-peach.md` - 38-step remediation plan (approved, not yet implemented)

## Technical Decision Documentation (MANDATORY)

**⚠️ CRITICAL RULE: Always update the Technical Decisions Log when making architectural or design decisions.**

When you make a technical decision that affects the project's architecture, infrastructure, security, performance, or development workflow, you **MUST** update `documentation/TECHNICAL_DECISIONS_LOG.md`.

### What qualifies as a technical decision:
- **Architecture changes**: New patterns, layer modifications, service integrations
- **Security decisions**: Authentication methods, authorization patterns, credential management
- **Infrastructure changes**: Deployment strategies, hosting configurations, scaling approaches
- **Build & deployment**: CI/CD modifications, Docker strategies, dependency management
- **Performance optimizations**: Caching strategies, query optimizations, scaling configurations
- **Technology choices**: Selecting libraries, frameworks, or tools over alternatives
- **Development workflow**: Testing strategies, code organization, tooling decisions

### When to update the log:
- ✅ **Immediately** after implementing a significant technical decision
- ✅ **Before finalizing** architectural changes (document the decision process)
- ✅ **After evaluating** multiple alternatives (document why one was chosen)

### Required information for each decision:
1. **Date/Time** - When the decision was made (UTC preferred)
2. **Title** - Clear, concise summary of the decision
3. **Category** - Classification (Security, Architecture, Performance, Cost, etc.)
4. **Decision Details** - What was decided and implemented
5. **Pros** - Benefits and advantages of the chosen approach
6. **Cons** - Drawbacks and limitations
7. **Impact** - How this affects the project, team, or users
8. **Compromises** - Trade-offs or concessions made (if any)
9. **Alternatives Evaluated** - Other options considered and why they were rejected

### Format:
Follow the existing structure in the log file. Each decision should be a standalone section with clear headings and bullet points for easy scanning.

### Examples of decisions to document:
- Choosing OIDC over service principal credentials
- Implementing scale-to-zero for cost optimization
- Using multi-stage Docker builds for security
- Adding rate limiting to specific endpoints
- Selecting a caching strategy
- Changing database migration approaches
- Adding or removing infrastructure components

**This is not optional** - maintaining this log ensures:
- Future maintainers understand why decisions were made
- Architectural knowledge is preserved across sessions
- Trade-offs are transparent and can be revisited if requirements change
- The project has a clear audit trail of technical evolution

## Important Notes

- **Infrastructure project** exists but is empty (placeholder for future services like email, caching, etc.)
- **DELETE endpoint** exists in controller but frontend doesn't wire it up yet
- **Vote endpoint** uses `SaveAsync()` directly - should use atomic ExecuteUpdateAsync (race condition risk)
- **Swagger** is development-only - secured behind environment check
- **Rate limiting** applies per-IP with different policies per endpoint group
- **Backend ports**: Local development uses port 5255 (dotnet run), Docker containers use port 8080 (non-root user requirement)
- **Health checks**: CI/CD workflows verify actual content ("Healthy" for backend, "next-size-adjust" meta tag for frontend), not just HTTP 200
- **Container security**: Backend runs as non-root user (appuser) in Docker, requires port 8080 (ports <1024 need root)
- **Remediation Plan** - 38 security/architecture improvements identified but not yet implemented (see hashed-swinging-peach.md)
- **Phase 3 Complete** - Frontend-backend integration with 15/15 tests passing
- **Phase 4 Complete** - Azure Container Apps deployed and operational with content-verified health checks
