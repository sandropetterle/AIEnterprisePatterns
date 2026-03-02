# System Overview

**Last Updated:** 2026-02-27
**Audience:** Solutions Architect, all developers, new contributors
**Purpose:** High-level overview of the AI Enterprise Patterns Library system — what it is, what it does, and how its major components interact.

---

## 1. Vision

The AI Enterprise Patterns Library is a structured, searchable, and community-driven knowledge base of AI-assisted enterprise architectural patterns.

Each "Pattern" represents a reusable implementation blueprint that may include:

- Architectural guidance
- AI prompts or workflows
- Code examples
- Tooling recommendations
- Best practices and trade-offs

The platform is designed for extensibility and maintainability following enterprise-grade development practices (DRY, SOLID, Clean Architecture).

Organizations can use this platform to:

- Consume curated AI-based implementation patterns
- Share internal best practices
- Standardize AI-assisted development approaches
- Self-host the solution via GitHub for internal use

---

## 2. Technology Stack

### Frontend

| Technology | Purpose |
|-----------|---------|
| Next.js 16 (App Router, React 19) | Server-side rendering, routing, ISR |
| TypeScript | Type safety throughout |
| Tailwind CSS | Utility-first styling |
| shadcn/ui | Component primitives |
| Auth.js v5 (NextAuth) | Authentication (OIDC provider-agnostic) |
| react-markdown + rehype-sanitize | Safe markdown rendering |
| Sonner | Toast notifications |
| Lucide | Icon library |
| next/image | Optimized image loading |

### Backend

| Technology | Purpose |
|-----------|---------|
| ASP.NET Core 8 (Web API) | RESTful API server |
| C# 12 | Implementation language |
| Entity Framework Core 8 | ORM with code-first migrations |
| FluentValidation | DTO and query validation |
| xUnit + Moq | Testing framework |

### Infrastructure & Platform

| Technology | Purpose |
|-----------|---------|
| Azure Container Apps | Primary hosting (scale-to-zero) |
| Azure SQL | Production database |
| Azure Container Registry | Docker image storage |
| Azure Application Insights | Monitoring and telemetry |
| Azure Key Vault | Secrets management |
| Azure Blob Storage | CMS media files |
| GitHub Actions | CI/CD pipelines |

### CMS

| Technology | Purpose |
|-----------|---------|
| Strapi 5 | Headless CMS for all static site content |
| MySQL (Azure Flexible Server) | Strapi production database |
| Docker Compose | Local CMS development |

### Development Environment

| Environment | Database | API |
|------------|---------|-----|
| Development | SQLite | http://localhost:5255 |
| Production | Azure SQL | Azure Container Apps URL |

---

## 3. Architecture Components

The system has three distinct application tiers and a shared infrastructure layer:

```
Browser
  │
  ▼
Next.js Frontend (Azure Container App)
  │  - Server Components for ISR/SSR
  │  - Client Components for interactive UI
  │  - Auth.js for session management
  │
  ├──► ASP.NET Core API (Azure Container App)
  │      - RESTful endpoints
  │      - JWT validation via OIDC discovery
  │      - Rate limiting, caching, validation
  │      └──► Azure SQL Database
  │
  └──► Strapi CMS (Azure Container App)
         - Static content management
         - On-demand ISR revalidation webhook
         └──► Azure MySQL Database
```

```mermaid
flowchart TD
    %% ── External Actor ─────────────────────────────────────────────────────
    User(["👤  User / Browser"])

    %% ── Azure Container Apps ────────────────────────────────────────────────
    subgraph ACA["☁️  Azure Container Apps Environment"]
        FE["⚡ Next.js 16<br/>App Router · ISR · Auth.js v5"]
        API["🔧 ASP.NET Core 8<br/>REST API · JWT · Rate Limiting"]
        CMS["📝 Strapi 5<br/>Headless CMS · Webhook"]
    end

    %% ── Databases ───────────────────────────────────────────────────────────
    subgraph DB["💾  Databases"]
        direction LR
        SQLDB[("Azure SQL<br/>Patterns & Tags")]
        MySQL[("Azure MySQL<br/>CMS Content")]
    end

    %% ── Azure Platform Services ─────────────────────────────────────────────
    subgraph Platform["🔷  Azure Platform Services"]
        direction LR
        Entra["🔐 Entra External ID<br/>OIDC Provider"]
        Blob["📦 Blob Storage<br/>Media Files"]
        AI["📊 Application Insights<br/>Monitoring"]
    end

    %% ── CI/CD Pipeline ──────────────────────────────────────────────────────
    subgraph CICD["🔄  CI/CD Pipeline"]
        direction LR
        GHA["⚙️  GitHub Actions"]
        ACR["🐳  Container Registry"]
    end

    %% ── Primary Flows ───────────────────────────────────────────────────────
    User -->|"HTTPS"| FE
    FE -->|"REST / JSON"| API
    FE -->|"Content API"| CMS
    FE <-->|"OIDC"| Entra
    CMS -->|"ISR Webhook"| FE
    API --> SQLDB
    CMS --> MySQL
    CMS -->|"Media Upload"| Blob

    %% ── Secondary Flows (dashed) ────────────────────────────────────────────
    GHA -->|"Push image"| ACR
    ACR -.->|"Pull"| FE
    ACR -.->|"Pull"| API
    ACR -.->|"Pull"| CMS
    FE -.->|"Telemetry"| AI
    API -.->|"Telemetry"| AI

    %% ── Node Styles ─────────────────────────────────────────────────────────
    classDef user     fill:#F9FAFB,stroke:#6B7280,stroke-width:2px,color:#111827,font-weight:bold
    classDef frontend fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,font-weight:bold
    classDef backend  fill:#D1FAE5,stroke:#059669,stroke-width:2px,color:#064E3B,font-weight:bold
    classDef cms      fill:#EDE9FE,stroke:#7C3AED,stroke-width:2px,color:#3B0764,font-weight:bold
    classDef database fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#78350F,font-weight:bold
    classDef azure    fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#0C4A6E,font-weight:bold
    classDef cicd     fill:#F3F4F6,stroke:#374151,stroke-width:2px,color:#111827,font-weight:bold

    class User user
    class FE frontend
    class API backend
    class CMS cms
    class SQLDB,MySQL database
    class Entra,Blob,AI azure
    class GHA,ACR cicd
```

---

## 4. Deployed URLs

| Service | URL |
|---------|-----|
| Frontend (Production) | https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Backend API (Production) | https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Strapi CMS (Production) | https://ca-aipatterns-cms-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Backend (Development) | http://localhost:5255 |
| Frontend (Development) | http://localhost:3000 |
| Strapi (Development) | http://localhost:1337 |

---

## 5. Key Architectural Decisions

The most significant architectural choices are recorded in [TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md). Notable examples:

- **Authentication:** Auth.js v5 + Azure Entra External ID (OIDC, provider-agnostic) — Decision 14-17
- **CMS:** Strapi 5 headless CMS for all static site content — Decision 28
- **Deployment:** Azure Container Apps (scale-to-zero, ~$5-12/month) — Decision 22
- **Related Patterns:** Server-side API endpoint replaces client-side computation — Decision 41
- **Dark Mode:** ThemeProvider with system preference detection — Decision 40

---

## 6. Further Reading

| Topic | Document |
|-------|---------|
| Backend layer details, API reference, data model | [BACKEND_ARCHITECTURE.md](BACKEND_ARCHITECTURE.md) |
| Frontend App Router, auth flow, component structure | [FRONTEND_ARCHITECTURE.md](FRONTEND_ARCHITECTURE.md) |
| Strapi CMS content model, webhooks, gotchas | [CMS_ARCHITECTURE.md](CMS_ARCHITECTURE.md) |
| Entity model, seeding, enum mapping | [DATA_MODEL.md](DATA_MODEL.md) |
| Auth, CORS, CSP, rate limiting, security headers | [SECURITY_OVERVIEW.md](SECURITY_OVERVIEW.md) |
| Feature requirements by page | [../requirements/FUNCTIONAL_REQUIREMENTS.md](../requirements/FUNCTIONAL_REQUIREMENTS.md) |
| Phase roadmap and status | [../project/ROADMAP.md](../project/ROADMAP.md) |
| Azure deployment guide | [../../deployment/README.md](../../deployment/README.md) |
