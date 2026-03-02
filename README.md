# AI Enterprise Patterns Library

A Next.js + ASP.NET Core platform for curating and sharing AI-driven enterprise implementation patterns, architectural blueprints, and best practices.

## 🏗️ Architecture

### Frontend
- **Framework:** Next.js 16 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS v3.4
- **Components:** shadcn/ui
- **Port:** http://localhost:3000

### Backend
- **Framework:** ASP.NET Core 8.0 Web API
- **Architecture:** Clean Architecture (4 layers)
- **ORM:** Entity Framework Core
- **Database:** SQLite (development) / SQL Server (production)
- **Port:** http://localhost:5255

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ (for frontend)
- **.NET SDK** 8.0+ (for backend)
- **Git**

### 1. Clone the Repository

```bash
git clone https://github.com/sandropetterle/AIEnterprisePatterns.git
cd AIEnterprisePatterns
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Restore dependencies
dotnet restore

# Apply database migrations (creates SQLite database)
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api

# Run the backend API
dotnet run --project src/AIEnterprisePatterns.Api
```

The backend API will start at **http://localhost:5255**

**Verify backend is running:**
- Open http://localhost:5255/swagger in your browser
- You should see the Swagger API documentation

### 3. Frontend Setup

```bash
# Navigate back to project root
cd ..

# Install dependencies
npm install

# Create environment file
cp .env.example .env.local

# Start the development server
npm run dev
```

The frontend will start at **http://localhost:3000**

## 🔧 Configuration

### Environment Variables

Create a `.env.local` file in the project root:

```bash
# Backend API Base URL
NEXT_PUBLIC_API_BASE_URL=http://localhost:5255/api

# API Request Timeout (milliseconds)
NEXT_PUBLIC_API_TIMEOUT=30000
```

### Backend Configuration

The backend uses SQLite for development. Database location:
```
backend/src/AIEnterprisePatterns.Api/aipatterns.db
```

For production, configure SQL Server in `appsettings.Production.json`.

## 📁 Project Structure

```
AIEnterprisePatterns/
├── app/                       # Next.js pages (App Router)
│   ├── page.tsx              # Home page
│   ├── patterns/             # Patterns pages
│   │   ├── page.tsx         # Patterns listing
│   │   └── [slug]/          # Pattern details
│   ├── error.tsx            # Global error boundary
│   └── loading.tsx          # Global loading state
├── components/               # React components
│   ├── ui/                  # shadcn/ui components
│   ├── home/                # Home page components
│   └── patterns/            # Pattern components
├── lib/                     # Utilities and data
│   ├── api/                 # Backend API client
│   │   ├── client.ts       # HTTP client
│   │   ├── patterns.ts     # Pattern API functions
│   │   ├── mappers.ts      # DTO transformations
│   │   └── types.ts        # Backend DTO types
│   ├── types/              # TypeScript types
│   ├── utils/              # Helper functions
├── backend/                 # ASP.NET Core backend
│   └── src/
│       ├── AIEnterprisePatterns.Api/        # API layer (Controllers, DTOs, Middleware)
│       ├── AIEnterprisePatterns.Core/       # Domain layer (Entities, Services, Interfaces)
│       ├── AIEnterprisePatterns.Data/       # Data layer (Repositories, DbContext, Migrations)
│       └── AIEnterprisePatterns.Infrastructure/  # Placeholder (future services)
├── cms/                     # Strapi 5 headless CMS
├── deployment/              # Azure deployment guides and scripts
└── documentation/           # Project documentation
    ├── architecture/        # How the system is built
    ├── requirements/        # What the system should do
    ├── decisions/           # Why we made technical choices
    ├── testing/             # Test strategy and guides
    ├── project/             # Roadmap and phase plans
    ├── operations/          # Production runbooks and guides
    └── test_results/        # Phase-specific test reports
```

## 🎯 Features

### Implemented ✅
- ✅ Home page with featured patterns, statistics, animations, dark mode
- ✅ Pattern listing with full-text search, filtering (category, tags, date), sorting, pagination
- ✅ Pattern details page with full markdown content and related patterns
- ✅ Voting system with optimistic UI updates and rate limiting
- ✅ RESTful API with 10+ endpoints (patterns, voting, auth, health)
- ✅ Authentication & authorization (Azure Entra External ID, Admin/Editor/Viewer roles)
- ✅ Pattern management UI — create, edit, delete forms (role-gated)
- ✅ Strapi 5 CMS integration (home page, global layout, on-demand ISR revalidation)
- ✅ Azure Container Apps deployment with CI/CD pipelines
- ✅ WCAG 2.1 AA accessibility compliance
- ✅ Dark mode with system preference detection
- ✅ Responsive design (mobile-first, Tailwind CSS)
- ✅ SEO optimization with JSON-LD
- ✅ 350+ frontend tests, 105 backend tests

### Upcoming 🔜
- 🔜 Lighthouse CI, Chromatic visual regression, cross-browser Playwright (Phase 6.4)
- 🔜 CMS Phase 2 — all page content and UI labels from Strapi (Phase 6.5-6.7)
- 🔜 Community features — comments, ratings, bookmarks (Phase 7)
- 🔜 Internationalization and enterprise features (Phase 8)

## 🔌 API Endpoints

**Base URL:** `http://localhost:5255/api`

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/patterns` | None | Get paginated patterns (with filters/search/sort) |
| GET | `/patterns/featured` | None | Get featured patterns (cached) |
| GET | `/patterns/trending` | None | Get trending patterns (cached) |
| GET | `/patterns/{slug}` | None | Get pattern by slug |
| GET | `/patterns/{slug}/related` | None | Get related patterns (cached) |
| POST | `/patterns/{id}/vote` | None | Vote for a pattern (rate limited: 10/min) |
| POST | `/patterns` | Editor+ | Create new pattern |
| PUT | `/patterns/{id}` | Editor+ | Update pattern |
| DELETE | `/patterns/{id}` | Admin | Delete pattern |
| GET | `/auth/me` | Authenticated | Get current user info |
| GET | `/health` | None | Health check |

**API Documentation:** http://localhost:5255/swagger

## 🧪 Testing

### Run Backend Tests

```bash
cd backend
dotnet test
```

### Run Frontend Tests

```bash
npm test
```

For more details, see [TESTING_STRATEGY.md](documentation/TESTING_STRATEGY.md)

## 🛠️ Development Scripts

### Frontend

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript compiler check
```

### Backend

```bash
# From backend directory
dotnet run --project src/AIEnterprisePatterns.Api    # Run API
dotnet build                                          # Build solution
dotnet test                                           # Run tests
dotnet ef database update                             # Apply migrations
```

## 🐛 Troubleshooting

### "Failed to load patterns" error

**Cause:** Backend API is not running or not accessible

**Solution:**
1. Ensure backend is running: `cd backend && dotnet run --project src/AIEnterprisePatterns.Api`
2. Verify backend at http://localhost:5255/swagger
3. Check `.env.local` has correct `NEXT_PUBLIC_API_BASE_URL`

### CORS errors

**Cause:** Frontend running on different port than configured

**Solution:**
Backend CORS is configured for `http://localhost:3000`. If using different port, update `Program.cs`:
```csharp
policy.WithOrigins("http://localhost:3000", "http://localhost:YOUR_PORT")
```

### Database not found

**Cause:** Migrations not applied

**Solution:**
```bash
cd backend
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api
```

### Type errors in API client

**Cause:** Category mapping mismatch

**Note:** Backend uses PascalCase categories (`DesignPatterns`), frontend uses spaced strings (`Design Patterns`). The mapper in `lib/api/mappers.ts` handles this automatically.

## 📚 Documentation

- **Documentation Index:** [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) — map of all docs with purpose and audience
- **System Overview:** [documentation/architecture/SYSTEM_OVERVIEW.md](documentation/architecture/SYSTEM_OVERVIEW.md)
- **Backend Architecture:** [documentation/architecture/BACKEND_ARCHITECTURE.md](documentation/architecture/BACKEND_ARCHITECTURE.md)
- **Frontend Architecture:** [documentation/architecture/FRONTEND_ARCHITECTURE.md](documentation/architecture/FRONTEND_ARCHITECTURE.md)
- **Security Overview:** [documentation/architecture/SECURITY_OVERVIEW.md](documentation/architecture/SECURITY_OVERVIEW.md)
- **Project Roadmap:** [documentation/project/ROADMAP.md](documentation/project/ROADMAP.md)
- **Testing Strategy:** [documentation/testing/TESTING_STRATEGY.md](documentation/testing/TESTING_STRATEGY.md)
- **Deployment Guide:** [deployment/README.md](deployment/README.md)
- **Operations Runbook:** [documentation/operations/RUNBOOK.md](documentation/operations/RUNBOOK.md)
- **API Documentation:** http://localhost:5255/swagger (when backend is running)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Links

- **Repository:** https://github.com/sandropetterle/AIEnterprisePatterns
- **Issues:** https://github.com/sandropetterle/AIEnterprisePatterns/issues

## 👥 Authors

- Sandro Petterle - [@sandropetterle](https://github.com/sandropetterle)

---

Built with ❤️ using Next.js and ASP.NET Core
