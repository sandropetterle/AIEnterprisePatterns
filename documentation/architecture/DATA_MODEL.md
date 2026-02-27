# Data Model

**Last Updated:** 2026-02-27
**Audience:** Backend Developers, Solutions Architects
**Purpose:** Define the database entities, relationships, seeding data, and the critical category enum mapping convention.

---

## 1. Entities

### Pattern

The core domain entity.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| `Id` | GUID | Primary Key | |
| `Title` | string | Required, MaxLength | |
| `Slug` | string | Required, Unique, indexed | Value Object with `GeneratedRegex` validation |
| `ShortDescription` | string | MaxLength | Used in list cards |
| `FullContent` | string | — | Markdown; excluded from list queries via EF projection |
| `Category` | PatternCategory (enum) | Required, indexed | |
| `Author` | string | Optional | |
| `CreatedDate` | DateTime | — | Set via TimeProvider |
| `UpdatedDate` | DateTime | — | Set via TimeProvider |
| `VoteCount` | int | — | Updated atomically via `ExecuteUpdateAsync` |
| `Status` | PatternStatus (enum) | — | Draft or Published |
| `IsFeatured` | bool | — | Drives featured query |
| `IsTrending` | bool | — | Drives trending query |
| `Tags` | ICollection\<Tag\> | Many-to-many | Via `PatternTag` junction table |

### Tag

| Field | Type | Constraints |
|-------|------|-------------|
| `Id` | GUID | Primary Key |
| `Name` | string | Required, indexed |
| `Patterns` | ICollection\<Pattern\> | Many-to-many |

### Junction Table: PatternTag

Many-to-many relationship between `Pattern` and `Tag`. EF Core handles this automatically via the navigation properties.

---

## 2. Enums

### PatternCategory (Backend)

| Backend Enum Value | Frontend Display String |
|--------------------|------------------------|
| `DesignPatterns` | `"Design Patterns"` |
| `Architecture` | `"Architecture"` |
| `AIPrompts` | `"AI Prompts"` |
| `Security` | `"Security"` |
| `Performance` | `"Performance"` |

**Critical:** The backend serializes enums as camelCase JSON. The frontend must always use `lib/api/mappers.ts` to convert between backend and frontend values. Never hardcode the string representations.

### PatternStatus

| Value | Meaning |
|-------|---------|
| `Draft` | Not publicly visible |
| `Published` | Publicly visible |

---

## 3. Database Configuration

- **Development:** SQLite at `backend/src/AIEnterprisePatterns.Api/aipatterns.db`
- **Production:** Azure SQL Server (applied via EF Core migrations — **not** auto-applied on startup in production)
- **Migrations:** Code-first, stored in `AIEnterprisePatterns.Data/Migrations/`

Indexes defined on:
- `Pattern.Slug` (unique)
- `Pattern.Category`
- `Tag.Name`
- The junction table composite key

---

## 4. Seed Data

Seed data is applied during development database creation.

- **6 seed patterns** with IDs `b0000000-0000-0000-0000-000000000001` through `...000006`
- **18 seed tags** with IDs `a0000000-0000-0000-0000-000000000001` through `...000018`
- Many-to-many relationships seeded via junction table inserts

---

## 5. Entity Relationship Diagram

<!-- DIAGRAM: Database ERD (Pattern, Tag, PatternTag) -->
> 📐 *ERD diagram planned — see [DIAGRAM_PLAN.md](../diagrams/DIAGRAM_PLAN.md)*

---

## 6. EF Core Patterns

- **Projections:** `Select()` used on list queries to exclude `FullContent` (large field not needed in cards)
- **`AsNoTracking()`:** Applied to all read-only queries (repository, related patterns)
- **Atomic updates:** Vote count updated with `ExecuteUpdateAsync()` to avoid race conditions
- **Includes:** `Include(p => p.Tags)` applied when tags are needed

---

## 7. Migration Commands

```bash
# From repo root
dotnet ef database update \
  --project backend/src/AIEnterprisePatterns.Data \
  --startup-project backend/src/AIEnterprisePatterns.Api

# Add a new migration
dotnet ef migrations add MigrationName \
  --project backend/src/AIEnterprisePatterns.Data \
  --startup-project backend/src/AIEnterprisePatterns.Api
```

See [../../deployment/database-migration.md](../../deployment/database-migration.md) for production migration procedures.
