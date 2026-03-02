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

> Full API reference has moved to **[`documentation/api/`](../api/API_REFERENCE_INDEX.md)** — includes DTOs, validation rules, request/response examples, and query parameter details.

Quick links:
- [API Reference Index](../api/API_REFERENCE_INDEX.md) — base URLs, versioning, auth, rate limiting, error shapes
- [Patterns API](../api/PATTERNS_API.md) — all `/patterns` endpoints with full DTO tables and examples
- [Auth API](../api/AUTH_API.md) — `/auth/me`
- [Health API](../api/HEALTH_API.md) — `/health`, `/health/ready`

---

## 3a. Pattern Vote Flow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#D1FAE5', 'primaryBorderColor': '#059669', 'primaryTextColor': '#064E3B', 'noteBkgColor': '#FEF3C7', 'noteTextColor': '#78350F'}}}%%
sequenceDiagram
    actor Client as 👤 Client
    participant RL as 🚦 Rate Limiter<br/>(vote: 10/min per IP)
    participant Ctrl as 🎮 PatternsController
    participant Svc as 🔧 PatternService
    participant DB as 🗄️ Database

    Client->>RL: POST /api/patterns/{id}/vote

    alt Rate limit exceeded
        RL-->>Client: 429 Too Many Requests
    else Within limit
        RL->>Ctrl: Forward request
        Ctrl->>Ctrl: Validate pattern ID (GUID)

        alt Invalid GUID
            Ctrl-->>Client: 400 Bad Request
        else Valid GUID
            Ctrl->>Svc: VoteAsync(patternId)
            Svc->>DB: ExecuteUpdateAsync()<br/>SET VoteCount = VoteCount + 1<br/>WHERE Id = @id

            alt Pattern not found (0 rows updated)
                DB-->>Svc: 0 rows affected
                Svc-->>Ctrl: null
                Ctrl-->>Client: 404 Not Found
            else Vote recorded
                DB-->>Svc: 1 row affected
                Svc->>DB: SELECT updated pattern
                DB-->>Svc: PatternDetailDto
                Svc-->>Ctrl: PatternDetailDto
                Ctrl-->>Client: 200 OK {voteCount: N}
                Note over Client: Optimistic UI update confirmed
            end
        end
    end
```

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

## 6a. Pattern Lifecycle

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#D1FAE5', 'primaryBorderColor': '#059669', 'primaryTextColor': '#064E3B', 'noteBkgColor': '#FEF3C7', 'noteTextColor': '#78350F'}}}%%
stateDiagram-v2
    [*] --> Draft : Editor creates pattern

    Draft --> Published : Set status = Published
    Published --> Draft : Set status = Draft
    Draft --> Draft : Editor saves edits
    Published --> Published : Editor saves edits
    Published --> Deleted : Admin deletes
    Draft --> Deleted : Admin deletes
    Deleted --> [*]

    note right of Draft
        Not returned by GET /patterns<br/>Visible to Editor+ via direct URL
    end note

    note right of Published
        Returned by all list + search<br/>endpoints. Visible to all users.
    end note
```

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

## 7a. Backend Domain Model

```mermaid
classDiagram
    class Pattern {
        +Guid Id
        +string Title
        +Slug Slug
        +string ShortDescription
        +string FullContent
        +PatternCategory Category
        +string Author
        +DateTime CreatedDate
        +DateTime UpdatedDate
        +int VoteCount
        +PatternStatus Status
        +bool IsFeatured
        +bool IsTrending
        +ICollection~Tag~ Tags
    }

    class Tag {
        +Guid Id
        +string Name
        +ICollection~Pattern~ Patterns
    }

    class IPatternRepository {
        <<interface>>
        +GetAllAsync(query) Task~PagedResult~
        +GetBySlugAsync(slug) Task~Pattern~
        +GetFeaturedAsync() Task~IEnumerable~
        +GetTrendingAsync() Task~IEnumerable~
        +GetRelatedPatternsAsync(slug, limit) Task~IEnumerable~
        +CreateAsync(pattern) Task
        +UpdateAsync(pattern) Task
        +DeleteAsync(id) Task~bool~
        +VoteAsync(id) Task~Pattern~
        +SaveAsync() Task
    }

    class IPatternService {
        <<interface>>
        +GetAllAsync(query) Task~PagedResult~
        +GetBySlugAsync(slug) Task~PatternDetailDto~
        +GetFeaturedAsync() Task~IEnumerable~
        +GetTrendingAsync() Task~IEnumerable~
        +GetRelatedPatternsAsync(slug) Task~IEnumerable~
        +CreateAsync(dto) Task~PatternDetailDto~
        +UpdateAsync(id, dto) Task~PatternDetailDto~
        +DeleteAsync(id) Task~bool~
        +VoteAsync(id) Task~PatternDetailDto~
    }

    class PatternService {
        -IPatternRepository _repository
        -IMemoryCache _cache
    }

    class PatternRepository {
        -ApplicationDbContext _context
    }

    class IUnitOfWork {
        <<interface>>
        +IPatternRepository Patterns
        +SaveAsync() Task
    }

    class PatternMapper {
        <<static>>
        +ToDto(pattern)$ PatternListDto
        +ToDetailDto(pattern)$ PatternDetailDto
    }

    class Slug {
        <<value object>>
        +string Value
        +Slug(value)
    }

    Pattern "1" --> "0..*" Tag : many-to-many via PatternTag
    PatternService ..|> IPatternService
    PatternRepository ..|> IPatternRepository
    PatternService --> IPatternRepository : uses
    PatternMapper --> Pattern : maps to DTOs
    Pattern --> Slug : value object
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
