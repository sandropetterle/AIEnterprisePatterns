# AI Enterprise Patterns - Backend API

ASP.NET Core 8.0 Web API with Clean Architecture.

## Quick Start

```bash
cd backend
dotnet run --project src/AIEnterprisePatterns.Api
```

API runs at `http://localhost:5000`. Swagger UI at `http://localhost:5000/swagger`.

SQLite is used for local development (auto-created on first run). Migrations apply automatically in development mode.

## Architecture

Clean Architecture with 4 layers:

- **Api** - Controllers, DTOs, middleware
- **Core** - Entities, enums, interfaces, services
- **Data** - EF Core DbContext, repositories, configurations, migrations
- **Infrastructure** - External services (reserved for Phase 3)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/patterns` | List patterns (paginated, filterable) |
| GET | `/api/patterns/featured` | Get featured patterns |
| GET | `/api/patterns/trending` | Get trending patterns |
| GET | `/api/patterns/{slug}` | Get pattern by slug |
| POST | `/api/patterns/{id}/vote` | Vote for a pattern |
| POST | `/api/patterns` | Create a pattern |
| PUT | `/api/patterns/{id}` | Update a pattern |
| DELETE | `/api/patterns/{id}` | Delete a pattern |

### Query Parameters (GET /api/patterns)

- `page` (default: 1)
- `pageSize` (default: 9)
- `sortBy` - `recent`, `votes`, `alphabetical`
- `category` - `Architecture`, `DesignPatterns`, `AIPrompts`, etc.
- `tags` - Comma-separated tag names
- `search` - Full-text search on title and description

## Production (SQL Server / Azure SQL)

Update `appsettings.json` with your SQL Server connection string. The app will use SQL Server when not in Development environment or when pointing to a non-localhost connection.

### Docker SQL Server (local)

```bash
docker-compose up -d
```

## EF Core Migrations

```bash
# Add migration
dotnet ef migrations add <Name> --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api

# Apply migration
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
```
