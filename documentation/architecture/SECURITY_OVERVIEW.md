# Security Overview

**Last Updated:** 2026-02-27
**Audience:** Security Engineers, Solutions Architects, Backend Developers, Infrastructure Engineers
**Purpose:** Document the security architecture, authentication flow, protection measures against common vulnerabilities, and security headers configuration.

---

## 1. Authentication Architecture

```
Browser
  │
  ▼
Next.js (Auth.js v5 — OIDC client)
  │  - Encrypted JWT session cookie
  │  - No database session table
  │
  ▼
Azure Entra External ID (OIDC provider)
  │  - Handles sign-in, MFA, branding
  │  - Issues ID token + access token
  │  - Roles embedded in access token via App Roles
  │
  ▼
ASP.NET Core API (JwtBearer middleware)
  - Validates JWT via OIDC discovery endpoint
  - No Microsoft-specific packages
  - Standard AddJwtBearer()
```

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#DBEAFE', 'primaryBorderColor': '#2563EB', 'primaryTextColor': '#1E3A8A', 'noteBkgColor': '#FEF3C7', 'noteTextColor': '#78350F'}}}%%
sequenceDiagram
    actor Browser as 👤 Browser
    participant NextJS as ⚡ Next.js<br/>(Auth.js v5)
    participant Entra as 🔐 Entra<br/>External ID
    participant API as 🔧 ASP.NET Core<br/>API

    Browser->>NextJS: GET /login
    NextJS-->>Browser: Redirect to /api/auth/signin
    Browser->>NextJS: GET /api/auth/signin
    NextJS-->>Browser: Redirect to Entra /authorize URL

    Browser->>Entra: GET /authorize (OIDC)
    Entra-->>Browser: Sign-in page
    Browser->>Entra: Submit credentials

    alt Authentication successful
        Entra-->>Browser: Redirect with authorization code
        Browser->>NextJS: GET /api/auth/callback?code=...
        NextJS->>Entra: POST /token (code exchange)
        Entra-->>NextJS: ID token + access token (roles embedded)
        NextJS->>NextJS: Encrypt session → JWT cookie
        NextJS-->>Browser: Set-Cookie: authjs.session-token
        Note over Browser,NextJS: User is now authenticated
    else Authentication failed
        Entra-->>Browser: Error redirect
        NextJS-->>Browser: Show error page
    end

    Note over Browser,API: Subsequent API calls (protected endpoints)
    Browser->>NextJS: Submit create/edit pattern form
    NextJS->>API: POST /api/patterns<br/>(Authorization: Bearer access_token)
    API->>Entra: GET /.well-known/openid-configuration
    Entra-->>API: JWKS URI
    API->>API: Validate JWT signature + roles claim
    API-->>NextJS: 201 Created
    NextJS-->>Browser: Pattern saved
```

**Provider:** Azure Entra External ID (free tier, <50,000 MAU). Note: Azure AD B2C was deprecated May 2025.

**Provider-agnostic design:** Swapping OIDC providers requires only changing environment variables. The code uses Auth.js generic `type: "oidc"` provider.

**Guard clause:** JwtBearer is only registered when `Authentication:Authority` is configured. Tests and local development work without Entra credentials.

---

## 2. Authorization Model

### Roles

Roles are embedded in the JWT access token via Azure Entra App Roles.

| Role | Permissions |
|------|------------|
| `Admin` | Full access — create, edit, delete patterns |
| `Editor` | Create and edit patterns |
| `Viewer` | Read-only (same access as anonymous users) |

### Authorization Policies

Policies are always registered (even without Entra configured), required for `[Authorize]` attributes to function in tests:

| Policy | Required Role | Applied To |
|--------|-------------|-----------|
| `RequireAdmin` | Admin | DELETE `/patterns/{id}` |
| `RequireEditor` | Editor or Admin | POST `/patterns`, PUT `/patterns/{id}` |
| `RequireViewer` | Any authenticated | GET `/auth/me` |

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#DBEAFE', 'primaryBorderColor': '#2563EB', 'primaryTextColor': '#1E3A8A', 'noteBkgColor': '#FEF3C7', 'noteTextColor': '#78350F'}}}%%
stateDiagram-v2
    [*] --> Unauthenticated : Initial visit

    Unauthenticated --> SigningIn : Click Sign In
    SigningIn --> Unauthenticated : Cancel or auth error
    SigningIn --> Authenticated : OIDC callback success

    state Authenticated {
        [*] --> Viewer
        Viewer --> Editor : Has Editor role
        Viewer --> Admin : Has Admin + Editor roles
        Editor --> Admin : Has Admin role
    }

    Authenticated --> Unauthenticated : Sign out / session expired

    note right of Unauthenticated
        Can browse patterns and vote.
        No write access.
    end note

    note right of Authenticated
        Viewer: read-only (same as anonymous)<br/>Editor: create + edit patterns<br/>Admin: + delete patterns
    end note
```

### Public Endpoints

All GET pattern endpoints and the vote endpoint are public (no authentication required):
- `GET /patterns`, `/patterns/featured`, `/patterns/trending`, `/patterns/{slug}`, `/patterns/{slug}/related`
- `POST /patterns/{id}/vote`
- `GET /health`, `/health/ready`

---

## 3. Input Validation

| Layer | Mechanism |
|-------|----------|
| Backend DTOs | FluentValidation (`CreatePatternDto`, `UpdatePatternDto`) |
| Backend query params | `GetPatternsQuery` with `Range` / `MaxLength` constraints |
| All text inputs | `MaxLength` constraints on all fields |
| Automatic enforcement | Model validation filter (`AddValidatorsFromAssembly` + validation filter) |

---

## 4. Protection Against Common Vulnerabilities

### XSS (Cross-Site Scripting)
- `rehype-sanitize` on all markdown content rendered on the frontend
- Secure JSON-LD structured data rendering
- Content Security Policy (CSP) headers on all responses

### CSRF (Cross-Site Request Forgery)
- `SameSite` cookie policy on Auth.js session cookies

### SQL Injection
- EF Core parameterized queries throughout — no raw SQL strings
- No dynamic query construction

### Information Disclosure
- No exception details in API responses (production)
- Swagger/OpenAPI UI disabled in production
- `ProblemDetails` format with generic error messages

### Rate Limiting
- Fixed window rate limiter on vote endpoint: 10 requests/minute per IP
- API endpoints: 50 requests/minute per IP
- General: 100 requests/minute per IP

---

## 5. CORS Configuration

Backend CORS policy is environment-specific:

| Setting | Value |
|---------|-------|
| Allowed origins | Configured per environment (frontend URL) |
| Allowed methods | GET, POST, PUT, DELETE |
| Allowed headers | Content-Type, Authorization |
| Credentials | Allowed |

Development: `http://localhost:3000`
Production: Azure Container Apps frontend URL

---

## 6. Security Headers (Frontend)

Applied to all Next.js responses via `next.config.mjs`:

| Header | Value |
|--------|-------|
| `Content-Security-Policy` | Restricts scripts, styles, images, fonts; includes `ciamlogin.com` for auth |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains; preload` |
| `X-Frame-Options` | `DENY` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `origin-when-cross-origin` |
| `Permissions-Policy` | Restricts camera, microphone, geolocation |

---

## 7. Secrets Management

| Secret | Storage |
|--------|---------|
| Database connection string | Azure Key Vault |
| Entra client secret | Azure Key Vault (via Container App secret references) |
| Strapi API token | Azure Key Vault / Container App secrets |
| Revalidation webhook secret | Azure Key Vault / Container App secrets |
| GitHub CI/CD credentials | GitHub Secrets (OIDC federated identity) |

**No secrets in code or committed files.** Deployment scripts use `az keyvault secret` for all sensitive values.

---

## 8. Container Security

- Backend Docker container runs as non-root user `appuser`
- Ports <1024 require root; backend uses port 8080 inside container (mapped to 80/443 externally)
- Container images stored in Azure Container Registry with RBAC access

---

## 9. Cryptographic Security

- Deployment scripts use `System.Security.Cryptography.RandomNumberGenerator` for password generation (not `Random`)
- Auth.js `AUTH_SECRET` generated with `openssl rand -base64 32`

---

## 10. Security Operations

| Topic | Reference |
|-------|----------|
| Setting up Azure Entra External ID | [../operations/AUTH_SETUP_GUIDE.md](../operations/AUTH_SETUP_GUIDE.md) |
| Incident response procedures | [../operations/INCIDENT_RESPONSE.md](../operations/INCIDENT_RESPONSE.md) |
| Codebase security audit findings | [../reviews/CODEBASE_REVIEW_REPORT.md](../reviews/CODEBASE_REVIEW_REPORT.md) |
