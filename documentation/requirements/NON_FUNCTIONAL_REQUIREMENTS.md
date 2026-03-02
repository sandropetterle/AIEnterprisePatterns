# Non-Functional Requirements

**Last Updated:** 2026-02-27
**Audience:** Solutions Architects, Developers, Infrastructure Engineers, Project Managers
**Purpose:** Define the quality attributes the system must achieve — performance, scalability, maintainability, usability, and deployment requirements.

---

## 1. Performance

### Targets
- API responses: < 500ms for standard queries (P95)
- LCP (Largest Contentful Paint): < 2.5s
- TTI (Time to Interactive): < 5s
- FCP (First Contentful Paint): < 1.8s

### Implemented Optimizations

**Backend:**
- Memory caching (`IMemoryCache`) for featured, trending, and related patterns — 5-minute TTL
- EF Core projections (`Select()`) exclude `FullContent` from list queries
- Atomic SQL updates (`ExecuteUpdateAsync()`) for vote operations — prevents race conditions
- Efficient database indexing on slug, category, and tags
- Query result pagination to limit data transfer

**Frontend:**
- `React.memo` on `PatternCard` (frequently rendered in grid)
- `useCallback` hooks on `FilterPanel` event handlers
- Code splitting with `next/dynamic` for `PatternContent` (lazy-loaded markdown renderer)
- `next/image` for optimized image loading (Strapi media)
- ISR (Incremental Static Regeneration) reduces full server renders
- Skeleton loaders for perceived performance

---

## 2. Scalability

- **Stateless API:** All state in database or cache — backend can horizontally scale
- **Azure Container Apps:** Scale-to-zero support; scales out on demand
- **ISR caching:** Reduces API load for popular pattern pages
- **Pagination:** Prevents unbounded data transfer on list endpoints
- **Rate limiting:** Protects against abuse at the application layer

---

## 3. Maintainability

- **SOLID principles** applied throughout backend (single responsibility, dependency inversion via interfaces)
- **DRY principles** — no duplicated business logic; PatternMapper centralizes DTO transformations
- **Clean Architecture** enforces clear layer boundaries (Api → Core → Data)
- **Dependency Injection** throughout backend
- **Consistent naming conventions:** PascalCase for C#, camelCase for TypeScript
- **TypeScript** strict mode — avoids runtime type errors
- **Documented architectural decisions** — see [../decisions/TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md)

---

## 4. Usability

### Responsive Design
- Mobile-first approach with Tailwind CSS breakpoints
- Consistent spacing and typography via design system
- shadcn/ui component primitives for consistent look and feel

### User Feedback
- Toast notifications (Sonner) for success/error states on all mutations
- Loading states with skeleton screens matching actual layout dimensions
- ErrorBoundary components with retry functionality
- Optimistic UI on voting with revert-on-error

### Accessibility (WCAG 2.1 AA)
- Skip-to-content link
- `aria-current` on pagination active page
- `aria-pressed` on filter toggle buttons
- `aria-required`, `aria-invalid` on form inputs
- `aria-busy`, `aria-live` on dynamic content
- `htmlFor` labels matching `id` on all form inputs
- Semantic HTML structure throughout
- Keyboard navigation support for all interactive elements
- Screen reader compatible
- Focus-visible indicators (`*:focus-visible` in globals.css)
- No use of `window.confirm()` — AlertDialog used for confirmations

---

## 5. Deployment & Operations

### Infrastructure
- **Platform:** Azure Container Apps (primary), scale-to-zero
- **Source control:** GitHub with automated CI/CD
- **Environment configuration:**
  - Development: SQLite database, localhost API
  - Production: Azure SQL, Azure Container Apps

### CI/CD Pipelines (GitHub Actions)
- **Backend:** restore → build → test → publish → deploy → health check
- **Frontend:** npm ci → TypeScript check → Next.js build → deploy → health check
- **CMS:** Docker build → push to ACR → deploy to Container App
- **Quality gates:** All tests must pass; 70%+ coverage enforced; TypeScript must compile clean
- Automatic rollback on health check failure (Container Apps)
- Build artifacts retained for 7 days

### Secrets Management
- Azure Key Vault for connection strings and sensitive configuration
- GitHub Secrets (OIDC federated identity) for CI/CD credentials
- No secrets committed to source control

### Database
- EF Core migrations version-controlled
- Production migrations applied manually (not auto-applied on startup)

---

## 6. Testing & Quality

### Coverage Targets
- Backend: ≥ 80% for Core/Data layers (current: ~85%)
- Frontend: ≥ 70% statement/branch/function/line — enforced in CI

### Mandatory Test Types
- Unit tests for all services, utilities, and business logic
- Integration tests for all API endpoints
- E2E tests for critical user flows (Playwright)
- Accessibility tests (jest-axe, axe-core)
- Performance tests — Lighthouse CI (Phase 6.4+)
- Visual regression tests (Phase 6.4+)

### Quality Gates
- All tests must pass before merging to main
- Coverage must meet thresholds for affected modules
- No critical accessibility violations in PR builds
- Performance budgets enforced: LCP < 2.5s, TTI < 5s (Phase 6.4+)

See [../testing/TESTING_STRATEGY.md](../testing/TESTING_STRATEGY.md) for the full testing approach.

---

## 7. Security

Security requirements are fully documented in [../architecture/SECURITY_OVERVIEW.md](../architecture/SECURITY_OVERVIEW.md). Summary:

- Input validation on all endpoints (FluentValidation)
- XSS protection (rehype-sanitize, CSP headers)
- CSRF protection (SameSite cookies)
- SQL injection prevention (EF Core parameterized queries)
- Rate limiting on all endpoints
- HTTPS enforcement
- Secrets in Azure Key Vault — never in code or environment files
- Swagger disabled in production
- No exception details in client responses
