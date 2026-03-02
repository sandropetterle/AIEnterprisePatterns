# Backend Architecture

**Last Updated:** 2026-02-27
**Audience:** Backend Developers, Solutions Architects
**Purpose:** Describe the ASP.NET Core 8 backend structure, Clean Architecture layers, patterns used, and the full API reference.

---

## 1. Clean Architecture Layers

```
AIEnterprisePatterns.Api          ← HTTP layer: Controllers, DTOs, Middleware, Validators, Filters
        ↓ depends on
AIEnterprisePatterns.Core         ← Domain layer: Entities, Services, Interfaces, Enums, Value Objects
        ↓ depends on
AIEnterprisePatterns.Data         ← Persistence layer: Repositories, DbContext, Migrations
        (Infrastructure)          ← Empty placeholder for future services
```

**Dependency rule:** Outer layers depend on inner layers. `Api` → `Core` → `Data`. No reverse dependencies.

```mermaid
flowchart TD
    %% ── Api Layer ────────────────────────────────────────────────────────────
    subgraph API["🌐  .Api — HTTP Layer"]
        direction TB
        A1["🎮 Controllers<br/>PatternsController · AuthController"]
        A2["📋 DTOs<br/>Request · Response models"]
        A3["✅ Validators<br/>FluentValidation"]
        A4["🔒 Middleware<br/>Error handling · Rate Limiting"]
    end

    %% ── Core Layer ───────────────────────────────────────────────────────────
    subgraph Core["⚙️  .Core — Domain Layer"]
        direction TB
        C1["🏗️ Entities<br/>Pattern · Tag"]
        C2["🔌 Interfaces<br/>IPatternRepository · IPatternService"]
        C3["🔧 Services<br/>PatternService"]
        C4["🗺️ Mappers · Value Objects<br/>PatternMapper · Slug"]
    end

    %% ── Data Layer ───────────────────────────────────────────────────────────
    subgraph Data["🗄️  .Data — Persistence Layer"]
        direction TB
        D1["📂 Repositories<br/>PatternRepository · UnitOfWork"]
        D2["🔗 DbContext<br/>ApplicationDbContext"]
        D3["🔄 Migrations<br/>EF Core code-first"]
    end

    %% ── Infrastructure (placeholder) ─────────────────────────────────────────
    Infra(["🔧 .Infrastructure<br/>(empty — future services)"])

    %% ── Dependency Direction — outer layers depend on inner, never reversed ──
    API -->|"depends on"| Core
    Core -->|"depends on"| Data
    Data -.->|"future"| Infra

    %% ── Styles ───────────────────────────────────────────────────────────────
    classDef api   fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,font-weight:bold
    classDef core  fill:#D1FAE5,stroke:#059669,stroke-width:2px,color:#064E3B,font-weight:bold
    classDef data  fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F,font-weight:bold
    classDef infra fill:#F3F4F6,stroke:#9CA3AF,stroke-width:2px,color:#6B7280,stroke-dasharray:5 5

    class A1,A2,A3,A4 api
    class C1,C2,C3,C4 core
    class D1,D2,D3 data
    class Infra infra
```

---

## 2. Key Patterns & Components

### Repository Pattern
- Interface defined in `Core`: `IPatternRepository`
- Implementation in `Data`: `PatternRepository`
- `GetRelatedPatternsAsync(slug, limit=3)` — category-first + tag-overlap + vote-sorted, `AsNoTracking`

### Unit of Work
- `IUnitOfWork` registered as scoped service in DI
- `PatternService` calls `repository.SaveAsync()` directly (UoW not actively used — the interface is registered but bypassed)

### PatternMapper
- Dedicated mapper class (not AutoMapper) in `Core`
- `ToDto`: `Pattern` → `PatternListDto` (excludes `FullContent` for list queries)
- `ToDetailDto`: `Pattern` → `PatternDetailDto` (includes tags, full content)
- **Category mapping:** Backend enum `DesignPatterns` → frontend string `"Design Patterns"` (see [DATA_MODEL.md](DATA_MODEL.md))

### Value Objects
- `Slug`: immutable value object with `GeneratedRegex` validation (lowercase alphanumeric + hyphens)

### Memory Caching
- `IMemoryCache` for featured, trending, and related patterns
- Cache keys: `featured_patterns`, `trending_patterns`, `related_patterns_{slug}`
- TTL: 5 minutes, no explicit cache invalidation on vote

### Rate Limiting (Fixed Window)
| Policy | Limit | Window |
|--------|-------|--------|
| `fixed` | 100 req/min | Per IP |
| `api` | 50 req/min | Per IP |
| `vote` | 10 req/min | Per IP |

### TimeProvider
- `TimeProvider.System` injected via DI for testable time operations

---

## 3. API Reference

Base URL (development): `http://localhost:5255/api`
Base URL (production): `https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api`

**API Versioning:** URL segment reader. Current version: `v1`.
- Versioned: `/api/v1/patterns`
- Unversioned fallback: `/api/patterns`

| Method | Endpoint | Auth Required | Rate Limit | Notes |
|--------|----------|---------------|------------|-------|
| GET | `/patterns` | None | `api` | Paginated; supports search, filter, sort |
| GET | `/patterns/featured` | None | `api` | Cached 5 min |
| GET | `/patterns/trending` | None | `api` | Cached 5 min |
| GET | `/patterns/{slug}` | None | `api` | Returns 404 if not found |
| GET | `/patterns/{slug}/related` | None | `api` | Cached 5 min per slug |
| POST | `/patterns/{id}/vote` | None | `vote` | Atomic update; 10 req/min |
| POST | `/patterns` | RequireEditor | `api` | Creates new pattern |
| PUT | `/patterns/{id}` | RequireEditor | `api` | Updates existing pattern |
| DELETE | `/patterns/{id}` | RequireAdmin | `api` | Soft-deletes or hard-deletes |
| GET | `/auth/me` | Authorize | — | Returns current user info |
| GET | `/health` | None | — | Returns "Healthy" |
| GET | `/health/ready` | None | — | Readiness probe |

**Query parameters for `GET /patterns`:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `search` | string | Full-text search across title, description, tags, content |
| `category` | string | Filter by category enum value |
| `tags` | string[] | Filter by tags (comma-separated) |
| `tagMode` | `any`\|`all` | Tag filter mode |
| `sortBy` | string | `newest`, `mostVoted`, `alphabetical` |
| `page` | int | Page number (1-based) |
| `pageSize` | int | Items per page |
| `dateFrom` | date | Filter by created date |
| `dateTo` | date | Filter by created date |

**Swagger UI:** Available at `/swagger` in development only. Disabled in production.

---

## 4. Data Validation

- `FluentValidation` applied to all DTOs: `CreatePatternDto`, `UpdatePatternDto`
- `GetPatternsQuery` validated with `Range` and `MaxLength` constraints
- Automatic model validation via `AddValidatorsFromAssembly` + validation filter
- `MaxLength` on all text input fields

---

## 5. Error Handling

- Global error handling middleware: returns consistent JSON error responses
- No exception details leaked to clients in production
- API returns standard problem detail objects (`ProblemDetails`)

---

## 6. Performance Optimizations

- **EF Core projections:** `Select()` excludes `FullContent` from list queries (only fetched on detail)
- **Atomic SQL updates:** `ExecuteUpdateAsync()` for vote operations to prevent race conditions
- **Memory caching:** Featured, trending, and related patterns cached for 5 minutes
- **Efficient indexing:** Database indexed on slug, category, and tags
- **Pagination:** All list endpoints paginate to limit data transfer
- **`AsNoTracking()`** on all read-only queries

---

## 7. Project Structure

```
backend/
├── src/
│   ├── AIEnterprisePatterns.Api/
│   │   ├── Controllers/
│   │   │   ├── PatternsController.cs
│   │   │   └── AuthController.cs
│   │   ├── DTOs/
│   │   ├── Middleware/
│   │   ├── Validators/
│   │   ├── Filters/
│   │   └── Program.cs
│   ├── AIEnterprisePatterns.Core/
│   │   ├── Entities/          ← Pattern, Tag
│   │   ├── Enums/             ← PatternCategory, PatternStatus
│   │   ├── Interfaces/        ← IPatternRepository, IPatternService, IUnitOfWork
│   │   ├── Services/          ← PatternService
│   │   ├── Mappers/           ← PatternMapper
│   │   └── ValueObjects/      ← Slug
│   └── AIEnterprisePatterns.Data/
│       ├── Repositories/      ← PatternRepository, UnitOfWork
│       ├── Migrations/
│       └── ApplicationDbContext.cs
└── tests/
    ├── AIEnterprisePatterns.Core.Tests/
    ├── AIEnterprisePatterns.Data.Tests/
    └── AIEnterprisePatterns.Api.Tests/   ← includes integration tests
```

---

## 8. Testing

- **Framework:** xUnit + Moq + FluentAssertions
- **Repository tests:** EF Core InMemory provider
- **Integration tests:** `WebApplicationFactory` with `TestAuthHandler` (header-driven auth via `X-Test-Roles`)
- **Current count:** 105 tests passing
- **Coverage:** ~85% on testable code

See [../testing/TESTING_STRATEGY.md](../testing/TESTING_STRATEGY.md) for full testing approach.

---

## 9. Configuration

```bash
# Backend environment variables
ConnectionStrings__DefaultConnection=   # Empty = SQLite dev; set for SQL Server
FrontendUrl=http://localhost:3000        # CORS allowed origin
Authentication__Authority=              # Entra OIDC authority (optional; auth disabled if not set)
Authentication__Audience=               # API app client ID
Authentication__RequireHttpsMetadata=true
```

See [../../deployment/github-secrets-setup.md](../../deployment/github-secrets-setup.md) for production secrets configuration.
