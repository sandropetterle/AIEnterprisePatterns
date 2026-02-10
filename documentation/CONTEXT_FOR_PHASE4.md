# Context Summary for Phase 4

**Date:** 2026-02-10
**Current Phase:** Phase 4 - Azure Deployment & CI/CD
**Previous Phase:** Phase 3 - Frontend-Backend Integration ✅ COMPLETE

---

## Quick Start Context

You are working on the **AI Enterprise Patterns Library** - a Next.js + ASP.NET Core platform for curating AI-driven enterprise implementation patterns.

**Repository:** https://github.com/sandropetterle/AIEnterprisePatterns

---

## Project Status

### ✅ Completed Phases

**Phase 1 - Frontend (Mock Data)** ✅
- Next.js 16 App Router with TypeScript
- Tailwind CSS + shadcn/ui components
- 3 pages: Home, Patterns Listing, Pattern Details
- Mock data with 6 patterns

**Phase 2 - Backend** ✅
- ASP.NET Core 8.0 Web API
- Clean Architecture (4 layers: Api, Core, Data, Infrastructure)
- Entity Framework Core with SQLite/SQL Server
- 8 REST endpoints (GET, POST, PUT, DELETE)
- Repository pattern, seed data

**Phase 3 - Frontend-Backend Integration** ✅
- All mock data replaced with API calls
- Category mapping layer (PascalCase ↔ spaced strings)
- Server-side filtering, sorting, pagination
- Optimistic voting with error handling
- Error boundaries and loading states
- **Test Results:** 15/15 passed, 0 critical issues

---

## Technology Stack

### Frontend
- **Framework:** Next.js 16 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS v3.4
- **Components:** shadcn/ui
- **Port:** http://localhost:3000

### Backend
- **Framework:** ASP.NET Core 8.0
- **Database:** SQLite (dev) / SQL Server (prod)
- **ORM:** Entity Framework Core
- **Architecture:** Clean Architecture
- **Port:** http://localhost:5255

---

## Project Structure

```
AIEnterprisePatterns/
├── app/                       # Next.js pages (App Router)
├── components/                # React components
├── lib/
│   ├── api/                  # Backend API client (NEW in Phase 3)
│   ├── types/                # TypeScript types
│   └── utils/                # Helper functions
├── backend/                   # ASP.NET Core backend
│   └── src/
│       ├── AIEnterprisePatterns.Api/
│       ├── AIEnterprisePatterns.Core/
│       ├── AIEnterprisePatterns.Data/
│       └── AIEnterprisePatterns.Infrastructure/
└── documentation/             # Project documentation
    ├── instructions.md        # Full SRS
    ├── TESTING_STRATEGY.md
    ├── CI_CD_STRATEGY.md
    └── PHASE3_LEARNINGS.md    # Phase 3 insights
```

---

## Key Files & Locations

### API Integration Layer (Phase 3)
- `lib/api/config.ts` - Environment configuration
- `lib/api/client.ts` - Base HTTP client
- `lib/api/types.ts` - Backend DTO types
- `lib/api/mappers.ts` - **CRITICAL:** Category mapping (PascalCase ↔ spaced)
- `lib/api/patterns.ts` - Pattern API functions

### Configuration
- `.env.example` - Environment template
- `.env.local` - Local dev config (gitignored)
- `README.md` - Setup instructions

### Documentation
- `documentation/instructions.md` - Full SRS
- `documentation/PHASE3_LEARNINGS.md` - Phase 3 insights
- `PHASE3_TEST_RESULTS.md` - Test results (15/15 passed)

---

## Critical Implementation Details

### 1. Category Mapping (IMPORTANT!)

**Backend (C# Enums):** `DesignPatterns`, `AIPrompts`, `BestPractices` (PascalCase, no spaces)
**Frontend (TypeScript):** `"Design Patterns"`, `"AI Prompts"`, `"Best Practices"` (spaced)

**Mapper Location:** `lib/api/mappers.ts`

This bidirectional mapping is **critical** - breaking it will cause category filtering to fail.

### 2. Environment Variables

**Required for Frontend:**
```bash
# .env.local
NEXT_PUBLIC_API_BASE_URL=http://localhost:5255/api
```

**Backend uses:**
- SQLite: `aipatterns.db` (dev)
- SQL Server: Connection string in `appsettings.Production.json`

### 3. API Endpoints

**Base URL:** `http://localhost:5255/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/patterns` | Paginated patterns (with filters) |
| GET | `/patterns/featured` | Featured patterns |
| GET | `/patterns/trending` | Trending patterns |
| GET | `/patterns/{slug}` | Get by slug |
| POST | `/patterns/{id}/vote` | Vote for pattern |
| POST | `/patterns` | Create pattern |
| PUT | `/patterns/{id}` | Update pattern |
| DELETE | `/patterns/{id}` | Delete pattern |

### 4. Running the Application

**Start Backend:**
```bash
cd backend
dotnet run --project src/AIEnterprisePatterns.Api
```
→ http://localhost:5255
→ Swagger: http://localhost:5255/swagger

**Start Frontend:**
```bash
npm run dev
```
→ http://localhost:3000

---

## Phase 4 Requirements (Next Steps)

From `documentation/instructions.md` and `documentation/CI_CD_STRATEGY.md`:

### Azure Deployment

1. **Azure Resources Needed:**
   - Azure App Service (Frontend - Next.js)
   - Azure App Service (Backend - ASP.NET Core)
   - Azure SQL Database
   - Azure Application Insights (monitoring)
   - Azure Key Vault (secrets)

2. **Configuration Updates:**
   - Update `NEXT_PUBLIC_API_BASE_URL` to production backend URL
   - Configure Azure SQL connection string
   - Set up CORS for production domain
   - Enable HTTPS

3. **Database Migration:**
   - Run EF Core migrations on Azure SQL
   - Seed production data
   - Set up backup strategy

### CI/CD Pipeline

1. **GitHub Actions Workflow:**
   - Build frontend (Next.js)
   - Build backend (.NET)
   - Run tests (both layers)
   - Deploy frontend to Azure App Service
   - Deploy backend to Azure App Service
   - Run database migrations

2. **Testing in Pipeline:**
   - TypeScript compilation check
   - .NET unit tests
   - Integration tests (optional)

See `documentation/CI_CD_STRATEGY.md` for detailed implementation plan.

---

## Known Issues & Future Improvements

### Non-Critical (from Phase 3 testing)

1. **Related Patterns Performance**
   - **Current:** Fetches all 100 patterns client-side
   - **Future:** Add `/api/patterns/{slug}/related` endpoint

2. **Toast Notifications**
   - **Current:** Errors only log to console
   - **Future:** Add toast library for user feedback

3. **Vote Deduplication**
   - **Current:** No server-side duplicate prevention
   - **Future:** Implement with authentication

4. **Database Query Optimization**
   - **Current:** Some N+1 queries for tags
   - **Future:** Add eager loading with `.Include()`

5. **ISR Optimization**
   - **Current:** Generates 100 static pages at build
   - **Future:** On-demand ISR for less popular patterns

---

## Important Commands

### Git
```bash
git status                              # Check status
git add -A                             # Stage all changes
git commit -m "message"                # Commit
git push origin main                   # Push to remote
```

### Frontend
```bash
npm run dev                            # Start dev server
npm run build                          # Build for production
npm run start                          # Start production server
npx tsc --noEmit                       # Check TypeScript errors
```

### Backend
```bash
cd backend
dotnet run --project src/AIEnterprisePatterns.Api    # Run API
dotnet build                                          # Build
dotnet test                                           # Run tests
dotnet ef database update                             # Apply migrations
```

---

## Recent Commits

**Latest:** `047b56e` - Complete Phase 3: Frontend-Backend Integration
- 17 files added (API client layer, error boundaries, loading states)
- 4 files modified (pages integrated with API)
- All tests passing (15/15)

**Previous:** `8f272d3` - Finalize documentation moves

---

## Key Contacts & Resources

- **Repository:** https://github.com/sandropetterle/AIEnterprisePatterns
- **Documentation:** `documentation/` folder
- **Test Results:** `PHASE3_TEST_RESULTS.md`
- **Learnings:** `documentation/PHASE3_LEARNINGS.md`

---

## What to Tell Claude in Next Conversation

**Quick Start Prompt:**

```
I'm working on the AI Enterprise Patterns project (Next.js + ASP.NET Core).

Repository: https://github.com/sandropetterle/AIEnterprisePatterns

We've completed Phase 3 (frontend-backend integration) - all tests passing.

Now starting Phase 4: Azure deployment and CI/CD pipeline.

Key context:
- Backend: ASP.NET Core 8.0 at localhost:5255
- Frontend: Next.js 16 at localhost:3000
- Database: SQLite (dev) → need to migrate to Azure SQL
- Critical: Category mapping in lib/api/mappers.ts

Please read documentation/CONTEXT_FOR_PHASE4.md for full context.

Ready to start Phase 4?
```

---

## Phase 4 Checklist

- [ ] Set up Azure resources (App Services, SQL Database)
- [ ] Configure environment variables for production
- [ ] Update CORS for production domain
- [ ] Create GitHub Actions workflow
- [ ] Test deployment to Azure
- [ ] Configure Application Insights
- [ ] Set up Azure Key Vault for secrets
- [ ] Run database migrations on Azure SQL
- [ ] Verify end-to-end functionality in production
- [ ] Document deployment process

---

**Document Version:** 1.0
**Last Updated:** 2026-02-10
**Status:** Ready for Phase 4
