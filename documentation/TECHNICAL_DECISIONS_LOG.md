# Technical Decisions Log

This document captures significant technical design decisions made during the development and deployment of the AI Enterprise Patterns application.

---

## Decision 30: Strapi On-Demand Revalidation Webhook

**Date:** 2026-02-26
**Title:** Strapi → Next.js On-Demand ISR Revalidation via Webhook
**Category:** CMS / Performance

### Decision Details
Added a Next.js POST route handler at `app/api/revalidate/route.ts` that Strapi calls whenever CMS content is published, updated, unpublished, or deleted. The handler calls `revalidatePath()` to immediately purge the ISR cache for the affected pages rather than waiting for the TTL to expire.

**Content-type → path mapping:**
- `global` → `revalidatePath('/', 'layout')` — purges all pages (nav/footer affect every route)
- `home-page` → `/`
- `about-page` → `/about`
- `docs-page` → `/docs`
- `login-page` → `/login`
- `not-found-page`, `error-page` → `/`
- `pattern-*-labels` → `revalidatePath('/patterns', 'layout')` — purges listing, detail, and form pages

**Security:** A `REVALIDATE_SECRET` environment variable is required as a query param (`?secret=...`) to prevent unauthorized cache busting. Returns 401 if missing or wrong.

### Rationale
- ISR TTLs (5–60 min) are acceptable for low-traffic sites but introduce unnecessary staleness after a content editor publishes a change
- On-demand revalidation brings content live immediately without a full redeploy
- Webhook approach keeps CMS and frontend decoupled — Strapi only needs the URL + secret

### Strapi Webhook Setup
Settings → Webhooks → Create webhook:
- URL: `https://<domain>/api/revalidate?secret=<REVALIDATE_SECRET>`
- Events: Entry (Create, Update, Publish, Unpublish, Delete)

### Alternatives Evaluated
- **Time-based ISR only** — simple but up to 60 min delay after publish
- **Full redeploy on content change** — instant but overkill; breaks scale-to-zero cost model

---

## Decision 29: Azure SQL — Storage Reduced to 1 GB & Auto-Pause Shortened to 15 Minutes

**Date:** 2026-02-23
**Title:** Further Reduce Azure SQL Storage (2 GB → 1 GB) and Auto-Pause Delay (60 min → 15 min)
**Category:** Infrastructure / Cost Optimisation

### Decision Details
Two configuration changes applied to the production Azure SQL Serverless database (`sqldb-aipatterns-prod`) via the Azure Portal:

1. **Storage: 2 GB → 1 GB** — the previous reduction (Decision 13) went from 32 GB to 2 GB. With actual data still well under 100 MB, 1 GB is more than sufficient and uses the Azure General Purpose minimum.
2. **Auto-pause delay: 60 min → 15 min** — the database now pauses after just 15 minutes of inactivity instead of 60, significantly reducing billed compute time for a low-traffic application.

### Rationale
- The application has 6 patterns, 18 tags, and minimal text content — nowhere near 1 GB
- Most traffic is sporadic; a 60-minute auto-pause window kept the database running (and billing) long after the last request
- 15 minutes is the minimum auto-pause delay Azure allows, maximising cost savings for bursty/low-traffic workloads

### Savings
| | Before | After |
|---|---|---|
| Provisioned storage | 2 GB | 1 GB |
| Monthly storage cost | ~$0.23 | ~$0.12 |
| Auto-pause delay | 60 min | 15 min |
| Estimated active hours/day | ~4-6h | ~1-2h |

The auto-pause change has the larger impact — reducing billed compute hours by up to 75% for idle periods.

### Pros
- Further cost reduction with zero functional impact
- 15-minute pause means the database sleeps sooner during low-traffic periods
- Storage and auto-pause can be increased again at any time if needed

### Cons
- More frequent cold starts (~1-2s resume time) when the database has been paused
- If traffic patterns change to sustained load, the frequent pause/resume cycle could cause intermittent latency

### Alternatives Evaluated
1. **Keep 2 GB / 60 min** (rejected) — unnecessarily over-provisioned for current workload
2. **Disable auto-pause entirely** (rejected) — would increase cost significantly for a low-traffic app

---

## Decision 28: Strapi 5 Headless CMS for Static Content Management

**Date:** 2026-02-20
**Title:** Adopt Strapi 5 as Headless CMS for All Static Frontend Content
**Category:** Architecture / Content Management

### Decision Details

Adopt Strapi 5 as a headless CMS to manage all static frontend content (300+ items across 28 components and 10 pages). The content model uses Dynamic Zones for flexible page composition, 10 Single Types for pages and UI labels, and 4 component categories (seo, layout, sections, shared) with 15+ reusable Dynamic Zone blocks.

### Content Model Summary

**Single Types (10):**
- `global` — site-wide settings (navigation, footer, sign-in/out labels, SEO defaults)
- `home-page`, `about-page`, `docs-page` — page content with Dynamic Zones for flexible layouts
- `login-page`, `not-found-page`, `error-page` — fixed-structure page content
- `pattern-listing-labels`, `pattern-detail-labels`, `pattern-form-labels` — UI string labels

**Component Categories (4):**
- `seo/` — metadata component reused on every page
- `layout/` — nav-link, cta-button, footer-config
- `sections/` — 15 Dynamic Zone blocks (hero, cta-banner, stats-bar, feature-grid, tech-stack, doc-section, api-reference, etc.)
- `shared/` — atomic components (text-item, stat-item, feature-card, key-value, etc.)

### Infrastructure

- **Database:** Azure Database for MySQL Flexible Server (free tier: B1ms, 32 GiB storage, 12 months free)
- **Hosting:** Azure Container App for Strapi (scale-to-zero, ~$5-10/month)
- **Media:** Azure Blob Storage (~$0.02/month) via `@strapi/provider-upload-azure-storage`
- **Total cost:** ~$10-15/month (MySQL free tier) → ~$23-28/month after free tier expires

### Frontend Integration Pattern

- Server-side fetch in Server Components → pass CMS data as props to client components
- ISR caching: 5-60 min per content type (global 10min, pages 5min, labels 1hr)
- Fallback to hardcoded defaults when Strapi is unreachable
- Dynamic Zone renderer maps Strapi `__component` field → React components

### Rationale

- SRS already specifies Strapi CMS integration (Phase 3.2, Section 4.4)
- Enables non-developer content editing without code deployments
- Content versioning and draft/publish workflows built into Strapi
- Future i18n readiness (Phase 8.1) — Strapi has native i18n plugin
- Dynamic Zones allow content editors to compose pages from reusable blocks

### Pros
- **Non-developer friendly**: Visual admin panel for content editing
- **Flexible layouts**: Dynamic Zones allow page composition without code changes
- **Cost effective**: MySQL free tier + scale-to-zero Container App = ~$10-15/month
- **TypeScript support**: Strapi 5 has native TypeScript and auto-generated types
- **i18n ready**: Strapi i18n plugin provides multi-language content management
- **Incremental migration**: Fallback pattern ensures zero downtime during rollout

### Cons / Trade-offs
- **Added complexity**: New service to maintain (Strapi + MySQL + Blob Storage)
- **Build dependency**: Next.js ISR depends on Strapi being available at build time (mitigated by fallbacks)
- **Content model maintenance**: Schema changes require Strapi admin + frontend code updates
- **Additional infrastructure cost**: ~$10-15/month ongoing

### Alternatives Evaluated
1. **Contentful** — More expensive at scale ($489/month for Team tier), vendor lock-in
2. **Sanity** — Complex pricing model (pay per API call beyond free tier), less familiar to team
3. **Hardcoded with i18n JSON files** — No visual editing for non-developers, no draft/publish workflow
4. **WordPress headless** — Heavier infrastructure, PHP runtime, more attack surface
5. **Keep hardcoded** — No content governance, requires developer for every text change

### Reference
- Full implementation plan: `documentation/transient/PHASE_CMS_IMPLEMENTATION_PLAN.md`
- Phase definition: `documentation/instructions.md` → Phase CMS section

---

## Decision 27: E2E Authentication — Direct Session Injection Replaces Entra Browser Login

**Date:** 2026-02-20
**Title:** Use `@auth/core/jwt` `encode()` to Synthesise Auth.js Session Cookies in Playwright globalSetup
**Category:** Testing / Authentication

### Decision Details

Replaced the Playwright browser-based Entra CIAM login flow in `e2e/global.setup.ts` with direct session cookie creation using Auth.js's own `encode()` function from `@auth/core/jwt`.

New files/changes:
- **`e2e/auth-helpers.ts`** (new): `createSessionCookie({ roles })` encrypts a JWT payload with `AUTH_SECRET` using JWE A256CBC-HS512 (Auth.js's native format); `buildStorageState()` wraps the cookie in the Playwright storageState JSON structure.
- **`e2e/global.setup.ts`**: The entire 120-line headless Chromium login flow is replaced by a single `createSessionCookie()` call. Setup takes <100ms and requires only `AUTH_SECRET` (already a CI secret).
- **`e2e/authenticated-flows.spec.ts`**: Tests split into three describe blocks — `Unauthenticated guards` (always run), `Authenticated — UI` (always run, synthetic session sufficient), `Authenticated — API writes` (skipped by default; needs real Entra JWKS-valid token, opt-in via `E2E_API_WRITES=true`).

### Rationale

The browser-based approach failed in CI headless Chrome across 9 consecutive commits. Root cause: Entra External ID's "Stay signed in?" (KMSI) prompt renders inside a `position:fixed` container whose buttons have `offsetParent === null`. Playwright's visibility checks (waitFor, click) time out because they require a non-zero bounding box. Approaches tried:

1. Direct `click({ timeout: 25s })` — timed out before KMSI rendered
2. `waitForURL('/login')` then click — URL resolved before Entra's JS rendered KMSI content
3. `waitFor({ state: 'visible', timeout: 30s })` — still timed out (offsetParent===null)
4. `page.addInitScript()` with `MutationObserver` to auto-click "No" on DOM insertion — executed, but page navigated to `ciamlogin.com/login` 4 times without redirecting to `localhost:3000`

The fundamental issue is that Entra's hosted CIAM UI behaviour differs between headed/headless, local/CI, with/without existing Entra session cookies, and may change at any time. Testing authenticated flows via the real IdP in CI is inherently fragile.

### Pros
- **Deterministic**: same `AUTH_SECRET` always produces a valid session; no external network call
- **Fast**: <100ms vs 45-60s for the full OIDC browser flow
- **Stable**: does not depend on Entra UI structure, KMSI prompt behaviour, or network latency
- **Minimal CI surface**: only `AUTH_SECRET` required; no `E2E_ADMIN_EMAIL`/`PASSWORD` secrets needed for UI tests
- **Uses public Auth.js API**: `encode()` is the documented export from `@auth/core/jwt`

### Cons / Trade-offs
- The injected `accessToken` is a placeholder (`e2e-placeholder-token`), rejected by the ASP.NET Core API's JWKS validation. Tests that call protected API endpoints (POST/PUT/DELETE `/api/patterns`) must be skipped or run with `E2E_API_WRITES=true` and a real token.
- Does not exercise the actual Entra OIDC login flow — that flow is untested end-to-end in CI.

### Alternatives Evaluated
- **Persist a real token from a one-time manual login**: Would expire (Entra tokens last 1 hour); cannot be refreshed without user interaction in a CIAM tenant.
- **ROPC (Resource Owner Password Credential) grant**: Not supported by Entra External ID CIAM tenants.
- **Client credentials grant**: Gets an app token (no user context); doesn't carry user roles in the same way.
- **Test-only auth bypass endpoint**: Adds a `/api/auth/test-session` route gated by a secret; increases attack surface and adds application complexity.
- **Continue fixing the MutationObserver approach**: All viable dismissal strategies exhausted; the Entra CIAM UI is a moving target.

---

## Decision 26: Playwright E2E Test Locator — Role-Based Checkbox Selection

**Date:** 2026-02-20
**Title:** Use `getByRole('checkbox')` Instead of `getByLabel()` for Tag Checkboxes
**Category:** Testing

### Decision Details

Changed the E2E test locator for tag filter checkboxes from `page.getByLabel('Clean Architecture')` to `page.getByRole('checkbox', { name: 'Clean Architecture' })` in `e2e/critical-flows.spec.ts`.

### Rationale

Phase 5.4 accessibility work added `aria-label` attributes to `PatternCard` link elements (e.g., `aria-label="Clean Architecture with AI-Assisted Refactoring — Architecture"`). The `getByLabel()` locator matches any element with an `aria-label` containing the text, so it now matched both the tag checkbox label *and* the PatternCard link, causing a Playwright strict mode violation (`resolved to 2 elements`).

`getByRole('checkbox', { name: '...' })` is strictly scoped to checkbox-role elements, eliminating the ambiguity.

### Alternatives Evaluated
- Scope `getByLabel` to a container: more fragile, depends on DOM structure
- Use `getByTestId`: avoids semantic HTML; we don't use data-testid attributes
- Role-based query: semantically precise, resistant to future aria-label additions elsewhere

---

## Decision 25: Jest Coverage — Exclude Next.js Server Components from Collection

**Date:** 2026-02-20
**Title:** Exclude App Router Page/Layout Files from Jest Coverage Collection
**Category:** Testing

### Decision Details

Added exclusion patterns to `collectCoverageFrom` in `jest.config.mjs` for Next.js App Router server component files:

```javascript
'!app/**/page.tsx',
'!app/**/layout.tsx',
'!app/**/not-found.tsx',
'!app/api/**',
```

### Rationale

Next.js App Router `page.tsx` / `layout.tsx` files are `async` React Server Components. They cannot be imported or rendered in the jsdom environment used by Jest — doing so produces 0% coverage for every statement/function/line, which dragged the global coverage below the 70% threshold even though all testable client-side code was well-covered.

These files are covered by Playwright E2E tests instead, which run the full server + client stack. Including them in the Jest coverage metric is misleading and causes false CI failures.

### Alternatives Evaluated
- Lower the global threshold to ~65%: honest but hides genuine gaps in testable code
- Add unit tests for server components: not feasible — they require a real Next.js server runtime, not jsdom
- Per-file threshold overrides: more complex config with no material benefit

---

## Decision 24: Global `*:focus-visible` Override for Consistent Focus Rings

**Date:** 2026-02-19
**Title:** Global Focus-Visible Styles in globals.css
**Category:** Accessibility

### Decision Details

Added a global `*:focus-visible` rule to `app/globals.css` using the CSS custom property `--ring` (already defined by shadcn/ui) to provide a consistent focus ring across all interactive elements.

```css
*:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
  border-radius: 4px;
}
```

### Rationale

shadcn/ui components have their own focus styles via Tailwind utilities (e.g., `focus-visible:ring-2`). But non-shadcn interactive elements (native `<a>`, `<button>`, custom `<input>`) may rely on the browser's default `:focus` outline, which varies across browsers and themes.

A global `*:focus-visible` rule:
- Uses `focus-visible` (not `focus`), so it only applies during keyboard navigation — mouse clicks do not trigger the ring
- References `--ring` from the shadcn theme, so it respects light/dark mode
- Applies `border-radius: 4px` to avoid sharp corners on rounded elements

### Alternatives Evaluated

- **Per-component `focus-visible:ring` utility classes** — comprehensive but requires touching every component and easy to miss in future additions
- **Removing browser defaults via `outline: none` and relying on shadcn** — leaves non-shadcn elements without visible focus, a WCAG 2.1 AA violation
- **Global `*:focus` (not `focus-visible`)** — would show rings on mouse clicks too, visually distracting

---

## Decision 23: jest-axe for Automated Accessibility Regression Testing

**Date:** 2026-02-19
**Title:** jest-axe Integration for WCAG Violation Detection
**Category:** Testing

### Decision Details

Installed `jest-axe` and `@types/jest-axe` and extended Jest matchers in `jest.setup.ts` with `import 'jest-axe/extend-expect'`. Created four accessibility test files under `__tests__/accessibility/`:

- `patterns-listing.a11y.test.tsx` — FilterPanel, EmptyState, Pagination
- `pattern-detail.a11y.test.tsx` — VotingButton
- `pattern-form.a11y.test.tsx` — PatternForm (create mode)
- `layout.a11y.test.tsx` — PatternCard

Tests use `axe(container)` and assert with `expect(results).toHaveNoViolations()`.

### Rationale

jest-axe runs axe-core (the industry-standard accessibility engine) in the Jest/jsdom environment. It catches common WCAG violations (missing labels, invalid ARIA, contrast issues) automatically during unit test runs — before code reaches a browser or manual audit.

**Benefits:**
- Runs in CI with no browser required
- Catches regressions when components are modified
- Lightweight — no additional tooling or browser setup
- Integrates naturally with existing React Testing Library tests

### Limitations

- jsdom doesn't compute CSS, so colour-contrast violations are not detected
- Some complex ARIA patterns require a real browser (e.g., focus traps, live region timing)
- Supplements but does not replace manual keyboard testing

---

## Decision 22: AlertDialog for Delete Confirmation (Replacing window.confirm)

**Date:** 2026-02-19
**Title:** Accessible Delete Confirmation via shadcn AlertDialog
**Category:** Accessibility & UX

### Decision Details

Replaced the `window.confirm()` call in `PatternActions` with a shadcn `AlertDialog` component. The AlertDialog is always rendered in the component tree; the trigger button opens it.

```tsx
<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="destructive">Delete</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogTitle>Delete Pattern?</AlertDialogTitle>
    <AlertDialogDescription>This action cannot be undone.</AlertDialogDescription>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

### Rationale

`window.confirm()` is not accessible:
- The browser dialog is not announced by screen readers in a standard ARIA way
- Focus is not managed — no focus trap within the dialog
- Cannot be styled or localized
- Blocked by some browser popup-blockers in certain contexts

shadcn `AlertDialog` (built on Radix UI Dialog primitive) provides:
- **Focus trap** — keyboard users cannot Tab out of the dialog while it is open
- **Escape to close** — standard keyboard interaction
- **ARIA roles** — `role="alertdialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby` set automatically by Radix
- **Screen reader announcement** — dialog title and description are announced on open
- **Consistent styling** — matches the app's design system

### Test Impact

The 9 existing `PatternActions` tests were updated to mock `@/components/ui/alert-dialog` inline (same pattern as DropdownMenu — avoids Radix portal issues in jsdom). The mock always renders all dialog content, so confirm/cancel buttons are always accessible in tests without needing to open the dialog.

---

## Decision 21: localStorage for Recently Viewed and Saved Searches

**Date:** 2026-02-19
**Title:** Client-Side localStorage Persistence for User-Specific UX State
**Category:** Architecture & Data Storage

### Decision Details

`useRecentlyViewed` (max 5 entries, key `recently-viewed-patterns`) and `useSavedSearches` (max 10 entries, key `saved-searches`) both persist to `localStorage`. No backend API or database storage is involved.

Both hooks are SSR-safe: the initial state is always `[]` (empty array), and localStorage is only read after mount via `useEffect`, preventing hydration mismatches.

### Rationale

- **No backend needed** — recently viewed and saved search state is purely presentational and user-agent specific; it does not need to be shared across devices or users
- **Zero latency** — reads from localStorage are synchronous and instant; no network round-trip
- **No authentication required** — works for anonymous users too
- **Simple implementation** — no API endpoints, no database migrations, no backend changes

### Trade-offs

| Pro | Con |
|-----|-----|
| Zero infrastructure cost | Data lost if user clears browser storage |
| Works offline | Not synced across devices/browsers |
| Anonymous-user friendly | 5-10 MB localStorage quota shared across origin |
| No backend changes | No server-side search analytics |

### Limits

- Recently Viewed: **5 patterns** — prevents stale list becoming noise; most recent replaces oldest
- Saved Searches: **10 searches** — balances utility vs localStorage clutter; 11th would require deleting old (currently rejected with toast)

---

## Decision 20: Client-Side Search Suggestions (No Dedicated API Endpoint)

**Date:** 2026-02-19
**Title:** Search Autocomplete Sourced from Page Data, Not a Dedicated Endpoint
**Category:** Architecture & Performance

### Decision Details

The `useSearchSuggestions` hook generates autocomplete suggestions client-side by filtering the `allPatterns` and `allTags` arrays already passed as props to `SearchBar`. No new API endpoint was added.

- Debounce: 200ms
- Minimum query length: 2 characters
- Max suggestions: 8
- Priority: pattern title matches first, then tag matches
- Case-insensitive substring matching

### Rationale

The patterns listing page already fetches the full (paginated) pattern list on the server. Passing pattern titles and tag names to `SearchBar` via props costs negligible extra bytes (strings only — no content bodies). Client-side filtering avoids a network round-trip for every keystroke.

**Compared to a dedicated `/api/patterns/suggest?q=...` endpoint:**

| | Client-side | Dedicated endpoint |
|-|-------------|-------------------|
| Latency | ~0ms (local filter) | ~50-200ms (network) |
| Infrastructure | None | New controller action + caching |
| Freshness | Reflects current page data | Could be independently cached |
| Scale | Degrades with >1000 patterns | Stays fast at any scale |
| Offline | Works | Fails |

At the current scale (<100 patterns), client-side is the right trade-off. If the pattern library grows beyond ~500 entries, a dedicated suggest endpoint with server-side prefix indexing should be evaluated.

---

## Decision 19: Radix UI Select Mock Pattern for Jest

**Date:** 2026-02-19
**Title:** Context-Based Mock for Radix Select to Support id/value Wiring
**Category:** Testing

### Decision Details

Radix UI `Select` component cannot be used directly in jsdom tests because it relies on browser-native pointer event APIs. A context-based mock was created inside the `jest.mock()` factory:

```typescript
jest.mock('@/components/ui/select', () => {
  const React = require('react')
  const SelectCtx = React.createContext<{ value: string; onChange: (v: string) => void }>({
    value: '', onChange: () => {},
  })
  return {
    Select: ({ value, onValueChange, children }: any) => (
      <SelectCtx.Provider value={{ value, onChange: onValueChange }}>
        <div>{children}</div>
      </SelectCtx.Provider>
    ),
    SelectTrigger: ({ id, children }: any) => {
      const { value, onChange } = React.useContext(SelectCtx)
      return <select id={id} value={value} onChange={e => onChange(e.target.value)}>{children}</select>
    },
    SelectValue: ({ placeholder }: any) => <option value="">{placeholder}</option>,
    SelectContent: ({ children }: any) => <>{children}</>,
    SelectItem: ({ value, children }: any) => <option value={value}>{children}</option>,
  }
})
```

The `SelectTrigger` renders a native `<select>` element with the `id` from the parent `Select`'s context, making `getByLabelText` work in tests via `htmlFor`/`id` linkage.

### Alternatives Evaluated

- **`@testing-library/user-event` with real Radix** — fails because jsdom lacks pointer events and focus APIs
- **Flat mock with no context** — `SelectTrigger` cannot access parent `Select`'s `value`/`onValueChange` without context
- **`data-testid` selectors** — works but bypasses label/role accessibility checks

---

## Decision 18: Entra External ID OIDC Issuer Uses Tenant-ID Subdomain

**Date:** 2026-02-19
**Title:** OIDC Issuer Format for Azure Entra External ID CIAM Tenants
**Category:** Security & Authentication

### Decision Details

The `AUTH_ENTRA_ISSUER` (and backend `Authentication:Authority`) must use the **tenant ID** as the `ciamlogin.com` subdomain, not the friendly tenant name.

**Correct format:**
```
https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0
```
**Incorrect format (causes Auth.js "server configuration" error):**
```
https://<tenant-name>.ciamlogin.com/<tenant-id>/v2.0
```

### Root Cause

Auth.js v5 performs strict OIDC issuer validation per RFC 8414: after fetching the OIDC discovery document, it compares the configured `issuer` value to the `issuer` field returned in the document. For Entra External ID CIAM tenants, the discovery document's `issuer` field always uses the tenant ID as the subdomain — even when the discovery endpoint is accessed via the friendly name subdomain. Any mismatch causes Auth.js to throw "There is a problem with the server configuration."

### How to Verify

```bash
curl https://<tenant-name>.ciamlogin.com/<tenant-id>/v2.0/.well-known/openid-configuration \
  | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).issuer))"
```

The printed value is the exact string that must be used for `AUTH_ENTRA_ISSUER`.

---

## Decision 1: OIDC Federated Identity Authentication

**Date/Time:** 2026-02-12 09:00-10:00 UTC
**Title:** OIDC Federated Identity vs Service Principal with Secrets
**Category:** Security & Authentication

### Decision Details
Implemented OpenID Connect (OIDC) workload identity federation for GitHub Actions to authenticate with Azure, using federated identity credentials instead of storing service principal credentials as GitHub secrets.

Created two federated credentials:
1. Main branch credential: `repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/main`
2. Production environment credential: `repo:sandropetterle/AIEnterprisePatterns:environment:Production`

### Pros
- **No secrets to manage**: Eliminates need to store and rotate Azure credentials in GitHub
- **Enhanced security**: No long-lived credentials that could be compromised
- **Automatic credential rotation**: Azure AD handles token lifecycle
- **Principle of least privilege**: Each credential scoped to specific branch/environment
- **Audit trail**: Better tracking of authentication attempts

### Cons
- **Complex initial setup**: Requires understanding of Azure AD federated credentials
- **Multiple credentials needed**: Each branch and environment requires separate credential
- **Debugging challenges**: OIDC errors can be cryptic and harder to troubleshoot
- **Azure AD dependency**: Requires Azure AD application registration

### Impact
- Eliminated `AZURE_CLIENT_SECRET` from GitHub secrets
- Required adding `permissions: id-token: write` to all workflow jobs using Azure authentication
- Improved security posture by removing credential storage
- Set precedent for all future Azure deployments in the project

### Compromises
- Had to create two separate federated credentials (main branch + Production environment) instead of one
- Initial deployment delayed due to troubleshooting malformed credential subjects
- Required creating PowerShell scripts (`fix-creds.ps1`, `add-environment-cred.ps1`) for credential management

### Alternatives Evaluated
1. **Service Principal with Client Secret** (rejected)
   - Simpler setup but requires secret storage
   - Manual credential rotation needed
   - Higher security risk

2. **Azure CLI with Service Principal** (rejected)
   - Similar security concerns as above
   - No benefit over OIDC approach

3. **Managed Identity** (not applicable)
   - Only works for Azure-hosted runners, not GitHub-hosted

---

## Decision 2: System-Assigned Managed Identity for ACR Access

**Date/Time:** 2026-02-12 09:40 UTC
**Title:** Managed Identity for Container Registry Access
**Category:** Security & Container Registry

### Decision Details
Configured Azure Container Apps with system-assigned managed identities and assigned AcrPull role for accessing Azure Container Registry, eliminating need for ACR admin credentials or connection strings.

Implementation via `configure-acr-access.ps1`:
```powershell
az containerapp identity assign --system-assigned
az role assignment create --role AcrPull --scope $acrId
az containerapp registry set --identity "system"
```

### Pros
- **No credential management**: No passwords or connection strings to store
- **Automatic authentication**: Azure handles token exchange automatically
- **Azure best practice**: Recommended approach by Microsoft
- **Granular permissions**: Can assign specific roles (AcrPull) without full registry access
- **Audit compliance**: Better tracking of who/what accesses registry

### Cons
- **Additional provisioning step**: Not automatic with Container App creation
- **Delayed implementation**: Had to retroactively add after initial deployment
- **Propagation delay**: Role assignments can take time to become effective
- **Troubleshooting complexity**: UNAUTHORIZED errors don't clearly indicate missing managed identity

### Impact
- Both Container Apps (frontend and backend) can pull images without stored credentials
- Removed ACR admin username/password from deployment scripts
- Improved security compliance for production environment
- Standardized authentication pattern for all Azure container workloads

### Compromises
- Required creating separate PowerShell script for post-deployment configuration
- Had to enable managed identity on both Container Apps individually
- Temporary deployment failure until managed identity configured

### Alternatives Evaluated
1. **ACR Admin Credentials** (rejected)
   - Simple but insecure
   - Admin credentials have full registry access (over-privileged)
   - Credentials stored in Container App secrets

2. **Service Principal with AcrPull** (rejected)
   - Still requires credential storage
   - More complex than managed identity
   - Manual credential rotation needed

3. **Azure Key Vault Integration** (rejected)
   - Adds unnecessary complexity
   - Managed identity is more direct approach

---

## Decision 3: Build-Time API Fallback Strategy

**Date/Time:** 2026-02-12 09:45-10:05 UTC
**Title:** Graceful Degradation for Build-Time API Calls
**Category:** Frontend Build Strategy

### Decision Details
Implemented try/catch blocks around all build-time API calls in Next.js with fallback to empty state, allowing Docker builds to succeed even when backend API is unavailable. Relies on Incremental Static Regeneration (ISR) to generate pages on-demand.

Modified files:
- `app/patterns/[slug]/page.tsx` - generateStaticParams
- `app/page.tsx` - Featured patterns and stats
- `app/patterns/page.tsx` - Pattern listing with filters

### Pros
- **Resilient builds**: Docker builds succeed regardless of API availability
- **ISR compatibility**: Pages generate on first request with actual data
- **No build dependencies**: Frontend can build independently of backend
- **Graceful degradation**: Users see empty state initially, then real data
- **Faster builds**: No need to wait for API responses during build

### Cons
- **Multiple files to maintain**: Had to update 3 separate page files
- **Potential missed API calls**: Risk of forgetting to wrap new API calls in future
- **Initial empty state**: First visitors may see loading indicators
- **Type safety complexity**: Required explicit type annotations for fallback objects
- **Debugging confusion**: Build-time errors logged as warnings, may be overlooked

### Impact
- Docker builds complete successfully without running backend
- GitHub Actions workflows can build frontend and backend in parallel
- Reduced build time by ~30-60 seconds (no API wait time)
- Pages use ISR to populate with real data after first request

### Compromises
- Had to create properly typed fallback objects matching API response structure
- Multiple iterations to fix TypeScript type errors in fallback data
- Can't pre-generate static pages at build time (rely on on-demand generation)
- Console warnings during every Docker build (may mask real issues)

### Alternatives Evaluated
1. **Disable Static Generation Entirely** (rejected)
   - Would lose SEO benefits
   - All pages would be dynamic (slower)
   - No pre-rendering benefits

2. **Require API During Build** (rejected)
   - Creates build dependency
   - Docker builds would need running backend
   - More complex CI/CD orchestration

3. **Use Mock Data at Build Time** (rejected)
   - Would show stale/fake data initially
   - Confusing user experience
   - Maintenance burden for mock data

4. **Skip ISR, Make All Routes Dynamic** (rejected)
   - Loses performance benefits of static generation
   - Increased server load
   - Slower page loads for users

---

## Decision 4: Empty Public Folder Handling in Docker

**Date/Time:** 2026-02-12 10:10 UTC
**Title:** Ensure Public Directory Exists in Docker Build
**Category:** Docker Build Configuration

### Decision Details
Added `mkdir -p public` command in Dockerfile builder stage and used trailing slashes in COPY commands to handle empty public folder scenario.

```dockerfile
# Ensure public directory exists (even if empty)
RUN mkdir -p public

# Copy with trailing slashes for directories
COPY --from=builder --chown=nextjs:nodejs /app/public/ ./public/
```

### Pros
- **Build reliability**: Eliminates "not found" errors during Docker build
- **Follows Docker best practices**: Explicit directory creation
- **No conditional logic needed**: Simple, declarative approach
- **Works with any public folder state**: Empty or with files
- **Minimal overhead**: Single RUN command, negligible build time impact

### Cons
- **Extra build step**: Adds one RUN command to Dockerfile
- **Not strictly necessary**: Only needed when public folder is empty
- **Masks potential issues**: Build succeeds even if public assets missing

### Impact
- Docker builds no longer fail when public folder is empty
- More reliable CI/CD pipeline (no random failures)
- Aligned with Next.js standalone build expectations
- Set pattern for handling optional directories in Docker

### Compromises
- None significant - this is a standard Docker practice

### Alternatives Evaluated
1. **Copy public from Source in Runner Stage** (rejected)
   - Failed: No build context in runner stage
   - Would require keeping source files

2. **Conditional COPY** (rejected)
   - Not supported in Dockerfile syntax
   - Would require shell scripting

3. **Ignore Missing Directory** (rejected)
   - Build would still fail with COPY errors
   - Not a solution to the problem

---

## Decision 5: Enable Scale-to-Zero for Container Apps

**Date/Time:** 2026-02-12 (inherited from Phase 4 planning)
**Title:** Cost Optimization via Scale-to-Zero Configuration
**Category:** Cost Optimization & Infrastructure

### Decision Details
Configured Azure Container Apps with `minReplicas: 0`, allowing containers to scale down completely when idle, paying only for actual usage.

Configuration:
```yaml
scale:
  minReplicas: 0
  maxReplicas: 10
```

### Pros
- **Significant cost savings**: 60-80% reduction vs always-on App Services ($5-12/month vs $18-24/month)
- **Pay per use**: Only charged for actual compute time
- **Automatic scaling**: Handles traffic spikes without manual intervention
- **Environment friendly**: Zero compute resources when idle
- **Azure Container Apps feature**: Designed for this use case

### Cons
- **Cold start latency**: 10-30 seconds delay on first request after idle period
- **Inconsistent response times**: First request slow, subsequent requests fast
- **WebSocket limitations**: Connections dropped when scaling to zero
- **Monitoring gaps**: No metrics when scaled to zero
- **User experience impact**: Noticeable delay for first visitor after idle

### Impact
- Monthly production costs reduced from $18-24 to $5-12
- Annual savings: ~$150-200
- Acceptable for demo/portfolio application with sporadic traffic
- May need to revisit for high-traffic production workloads

### Compromises
- Accepted cold start latency for cost savings
- Not suitable for applications requiring consistent sub-second response times
- First visitor after idle period experiences degraded performance
- Can't maintain persistent connections or background jobs

### Alternatives Evaluated
1. **Always-On App Services** (rejected for cost)
   - $18-24/month
   - No cold starts
   - Better for production workloads
   - Not cost-effective for demo application

2. **Min Replicas = 1** (rejected for cost)
   - ~$10-15/month
   - Eliminates cold starts
   - Still more expensive than scale-to-zero

3. **Azure Functions Consumption Plan** (rejected for architecture)
   - Similar cost model
   - Doesn't support full containerized applications
   - Would require application restructuring

---

## Decision 6: Ingress Target Port Configuration

**Date/Time:** 2026-02-12 10:30 UTC
**Title:** Correct Port Mapping for Container Ingress
**Category:** Container Configuration & Networking

### Decision Details
Configured Container Apps ingress with correct target ports matching application listening ports:
- Backend API: `targetPort: 5255` (ASP.NET Core default)
- Frontend: `targetPort: 3000` (Next.js standalone default)

Initially misconfigured as port 80, causing Azure to route traffic to wrong port and display welcome page.

### Pros
- **Correct routing**: Traffic reaches application listeners
- **No application changes**: Uses default ports from frameworks
- **Standard practice**: Matches local development ports
- **Clear debugging**: Port mismatch obvious in logs

### Cons
- **Not immediately obvious**: Initial deployment succeeded but served wrong content
- **Azure defaults misleading**: Portal defaults to port 80
- **Delayed discovery**: Only caught after full deployment

### Impact
- Fixed apps showing Azure welcome page instead of application
- Aligned container configuration with application runtime expectations
- Established verification checklist for future Container App deployments

### Compromises
- Required post-deployment configuration update
- Temporary period where apps appeared deployed but weren't serving correct content

### Alternatives Evaluated
1. **Change Application Ports to 80** (rejected)
   - Would require Dockerfile changes
   - Non-standard for development
   - Unnecessary modification

2. **Use Port Mapping in Dockerfile** (rejected)
   - Adds complexity
   - Target port configuration is cleaner approach

---

## Decision 7: Multi-Stage Docker Build for Next.js

**Date/Time:** 2026-02-12 (inherited from Phase 4 planning)
**Title:** Optimize Frontend Docker Image Size and Security
**Category:** Docker Build Strategy & Security

### Decision Details
Implemented 3-stage Docker build for Next.js:
1. **deps stage**: Install all dependencies including devDependencies
2. **builder stage**: Build Next.js application
3. **runner stage**: Minimal production image with non-root user

### Pros
- **Smaller image size**: Only production artifacts in final image
- **Security hardening**: Non-root user (nextjs:nodejs), minimal attack surface
- **Build caching**: Dependencies cached separately from source
- **Best practice**: Follows Next.js official Dockerfile recommendations
- **Layer optimization**: Separate layers for dependencies, source, and build output

### Cons
- **Complex Dockerfile**: Three stages vs single-stage build
- **Longer initial builds**: More layers to build (mitigated by caching)
- **Troubleshooting harder**: Need to understand which stage has issues

### Impact
- Final image size: ~200MB vs ~1GB for non-optimized build
- Improved security posture with non-root execution
- Faster subsequent builds due to layer caching
- Production-ready container following Docker best practices

### Compromises
- Initially used `npm ci --only=production` which broke build (missing devDependencies)
- Changed to `npm ci` in deps stage to install all dependencies
- Slightly larger deps layer but necessary for build to succeed

### Alternatives Evaluated
1. **Single-Stage Build** (rejected)
   - Simpler but much larger image
   - Includes build tools in production
   - Poor security practice

2. **Two-Stage Build** (rejected)
   - Combines deps and builder
   - Less caching optimization

3. **Build on Host, Copy Artifacts** (rejected)
   - Doesn't work with GitHub Actions
   - Not reproducible across environments

---

## Decision 8: Port 8080 for Non-Root Container Security

**Date/Time:** 2026-02-13 11:45 UTC
**Title:** Change Backend Port from 80 to 8080 for Non-Root User
**Category:** Security & Container Configuration

### Decision Details
Changed ASP.NET Core backend to listen on port 8080 instead of port 80 to allow running as non-root user in Docker container.

**Root Cause of Change:**
Container was crashing with `SocketException (13): Permission denied` because:
- Dockerfile configured `USER appuser` (non-root) for security
- But set `ASPNETCORE_URLS=http://+:80`
- Ports below 1024 require root privileges on Linux

**Fix Applied:**
```dockerfile
# Changed from:
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# To:
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
```

### Pros
- **Container starts successfully**: No permission errors
- **Maintains security**: Continues running as non-root user
- **Standard practice**: Port 8080 is conventional for non-privileged HTTP services
- **Azure compatible**: Container Apps ingress can map any target port
- **No application changes**: Only infrastructure configuration updated

### Cons
- **Non-standard HTTP port**: Not the default port 80
- **Required ingress update**: Had to update Container App targetPort configuration
- **Documentation overhead**: Need to remember 8080 in all deployment docs
- **Delayed discovery**: Took multiple deployment attempts to identify root cause

### Impact
- Backend containers now start and serve traffic successfully
- Fixed 100% crash rate on Container Apps deployment
- Established pattern for all future ASP.NET Core containerized services
- Deployment time increased by ~2 hours due to troubleshooting
- Container App ingress targetPort updated to 8080

### Compromises
- Not using standard HTTP port 80
- External traffic still uses port 443 (HTTPS), so end-users unaffected
- Internal architecture documentation must specify port 8080

### Alternatives Evaluated
1. **Run container as root** (rejected)
   - Major security risk
   - Violates container best practices
   - Could allow container escape vulnerabilities

2. **Use port 80 with capabilities** (rejected)
   - Requires NET_BIND_SERVICE capability
   - More complex Dockerfile
   - Still less secure than non-privileged ports

3. **Change to port 5000 (Kestrel default)** (rejected)
   - Port 8080 more conventional for containerized apps
   - 8080 clearly indicates HTTP service

---

## Decision 9: Content-Verified Health Checks in CI/CD

**Date/Time:** 2026-02-13 12:00 UTC
**Title:** Verify Actual Application Content in Deployment Health Checks
**Category:** CI/CD & Quality Assurance

### Decision Details
Enhanced all GitHub Actions deployment workflows to verify actual application content instead of just HTTP status codes.

**Problem Identified:**
Health checks returned success (✓) when Azure welcome page was served because:
- Welcome page returns HTTP 200
- Workflow only checked `curl -w "%{http_code}"`
- False positive: Deployment "succeeded" but wrong content served

**Solution Implemented:**

**Backend API:**
```bash
response=$(curl -s /health)
if [ "$response" = "Healthy" ]; then
  echo "✓ Health check passed"
else
  echo "✗ Expected 'Healthy', got '$response'"
  exit 1
fi
```

**Frontend:**
```bash
response=$(curl -s /)
if echo "$response" | grep -q "next-size-adjust"; then
  echo "✓ Next.js content detected"
else
  echo "✗ Azure welcome page detected"
  exit 1
fi
```

### Pros
- **No false positives**: Fails when wrong content served
- **Earlier failure detection**: Catches misconfigurations immediately
- **Clear error messages**: Shows expected vs actual response
- **Simple implementation**: Uses grep for pattern matching
- **Comprehensive coverage**: Applied to all 4 workflows (Container Apps + App Services)

### Cons
- **Brittle checks**: May break if Next.js meta tag name changes
- **Extra network call**: Two curl requests instead of one (status + content)
- **String matching fragility**: Could fail on valid but unexpected responses
- **No semantic validation**: Doesn't check if API actually works, just if it returns expected string

### Impact
- Prevented future false positive deployments
- Saved debugging time by failing fast
- Increased confidence in deployment success indicators
- Set pattern for all future health check implementations
- Applied to 4 workflows: backend-deploy, frontend-deploy, backend-container-deploy, frontend-container-deploy

### Compromises
- Used simple string/pattern matching instead of full integration tests
- Chose specific marker (next-size-adjust) that could change in Next.js updates
- Two sequential curl calls instead of single optimized check

### Alternatives Evaluated
1. **Full integration tests** (deferred)
   - Would be more comprehensive
   - Too slow for deployment health checks
   - Better suited for separate E2E test suite

2. **Check for specific JSON structure** (considered)
   - More robust for API
   - Overkill for simple health endpoint
   - "Healthy" string check is sufficient

3. **Use regex for flexible matching** (rejected)
   - More complex to maintain
   - Simple string/grep matching adequate

4. **Parse HTML DOM** (rejected)
   - Would require additional tools (jq, xmllint)
   - Adds dependencies to GitHub Actions runner

---

## Summary

This log now covers **12 major technical decisions** across deployment and testing phases:
- **Security** (OIDC, Managed Identity, non-root containers, port privileges)
- **Cost Optimization** (scale-to-zero)
- **Build Reliability** (API fallback, public folder handling)
- **Deployment Configuration** (port mapping, multi-stage builds)
- **Quality Assurance** (content-verified health checks)
- **Testing** (Jest mocking strategy, ESM dependencies, Playwright E2E fetch interception)

### Key Themes
1. **Security-first approach**: Eliminated credential storage wherever possible, maintained non-root container execution
2. **Cost consciousness**: Prioritized cost savings for demo/portfolio application
3. **Resilience**: Built fault tolerance into build and deployment processes
4. **Best practices**: Followed Azure and Docker recommended patterns
5. **Fail-fast principle**: Enhanced CI/CD to catch misconfigurations early

### Lessons Learned
- OIDC setup requires careful attention to subject format
- Managed identities should be configured during initial provisioning
- Next.js build-time API calls need error handling for containerized builds
- Azure Container Apps port configuration must match application listeners
- Scale-to-zero trades latency for cost (acceptable for low-traffic apps)
- **Non-root containers cannot bind to privileged ports (<1024)** - use port 8080 for HTTP
- **HTTP 200 doesn't guarantee correct content** - verify actual application responses in health checks
- Stack traces with SocketException (13) indicate Linux permission issues, often port-related
- Azure welcome pages can mask deployment failures by returning HTTP 200

### Future Considerations
- Monitor cold start latency in production usage
- Consider min replicas = 1 if traffic increases
- Evaluate Azure Functions for truly serverless architecture
- Document all federated credential subjects for maintenance

---

## Decision 10: Jest Module Mocking Strategy — spyOn vs Factory Pattern

**Date:** 2026-02-19
**Title:** Use `jest.spyOn` for module-level mocking instead of `jest.mock` factory with `jest.fn()`
**Category:** Testing

### Decision Details

When writing tests for `lib/api/patterns.ts` (which calls `apiClient.get/post`), the initial approach used `jest.mock('../client', () => ({ apiClient: { get: jest.fn(), post: jest.fn() } }))`. This caused `TypeError: mockedGet.mockResolvedValueOnce is not a function` at runtime under Jest 30 with the Next.js SWC transformer.

The fix: import the module directly and use `jest.spyOn(apiClient, 'get').mockResolvedValueOnce(...)` within `beforeEach`, restoring with `jest.restoreAllMocks()` in `afterEach`.

### Why It Works
`apiClient` is a plain object (`export const apiClient = { get, post, put, delete: del }`). Jest's `spyOn` wraps the object property directly, meaning the spy intercepts calls made by any code that imported the same module instance — including the module under test.

### Pros
- Works reliably with SWC transformer (no hoist/factory scoping issue)
- Type-safe with `ReturnType<typeof jest.spyOn>`
- Per-test return values via `mockResolvedValueOnce`
- Clean restoration via `jest.restoreAllMocks()`

### Cons
- Requires the real module to be imported (not isolated)
- spyOn won't work if the export is a frozen object or primitive

### Alternatives Evaluated
1. **`jest.mock` with factory** (rejected) — `jest.fn()` inside factory unreliable with SWC
2. **Manual mock file** (`__mocks__/client.ts`) — heavier, more maintenance
3. **Auto-mock** (`jest.mock('../client')` no factory) — relies on Jest inferring mock shape, less explicit

---

## Decision 11: Mock ESM Dependencies in Component Tests (react-markdown)

**Date:** 2026-02-19
**Title:** Mock `react-markdown` and its plugins rather than adding SWC transform exceptions
**Category:** Testing

### Decision Details

`PatternContent.tsx` imports `react-markdown`, `remark-gfm`, and `rehype-sanitize`, all of which publish ES modules (`export {}`). Jest's default `transformIgnorePatterns` excludes `node_modules`, causing `SyntaxError: Unexpected token 'export'` when the test file is loaded.

Chose to mock the ESM packages at the test-file level rather than modifying `transformIgnorePatterns` to include a long list of transitive ESM dependencies.

```ts
jest.mock('react-markdown', () => function ReactMarkdown({ children }) {
  return <div data-testid="markdown-content">{children}</div>
})
jest.mock('remark-gfm', () => () => ({}))
jest.mock('rehype-sanitize', () => () => ({}))
```

### Pros
- Zero changes to shared jest config — no risk of breaking other tests
- Simpler: one mock per file, no need to enumerate all transitive ESM deps
- Tests `PatternContent`'s render logic (prose wrapper, content passing) without testing `react-markdown` internals

### Cons
- Custom component renderers (h2, h3, code, blockquote, etc.) defined in `PatternContent` are not exercised
- Any bugs in those renderers are invisible to unit tests — covered by E2E instead

### Alternatives Evaluated
1. **Modify `transformIgnorePatterns`** (rejected) — requires enumerating ~15 transitive ESM packages; brittle across package updates
2. **Use `jest.config.ts` `moduleNameMapper`** — could map to stub, but same trade-off as mocking
3. **E2E-only for PatternContent** — deferred; unit coverage gap would persist until Playwright E2E are fixed

---

## Decision 12: Playwright Vote Mocking — `page.addInitScript` vs `page.route`

**Date:** 2026-02-19
**Title:** Override `window.fetch` via `page.addInitScript` instead of using `page.route` for cross-origin vote API interception
**Category:** Testing / E2E

### Decision Details

The VotingButton E2E tests need to intercept `POST /api/patterns/{id}/vote` (cross-origin: frontend port 3000 → backend port 5255) and return a controlled 201 response. The initial implementation used `page.route(/\/patterns\/[^/]+\/vote/, handler)` — a standard Playwright network interception pattern.

**Problem:** `page.route` silently failed to intercept requests. `page.waitForRequest(regex)` timed out with no request fired, even after verifying React hydration was complete. The `apiClient.post` call uses `credentials: 'include'`, which triggers a CORS preflight (OPTIONS). When Playwright fulfills the OPTIONS request with a plain JSON response (no CORS headers), the browser's CORS policy blocks the subsequent POST — and Playwright's CDP-level interception doesn't inject the correct `Access-Control-Allow-*` headers automatically for pre-flight responses in cross-origin dev scenarios.

**Solution:** Use `page.addInitScript` to replace `window.fetch` in the browser's JavaScript runtime before the app bundle loads. This intercepts the vote fetch at the JS level, bypassing CORS entirely.

```typescript
await page.addInitScript(() => {
  const orig = window.fetch.bind(window)
  window.fetch = async function (input, init) {
    const url = typeof input === 'string' ? input : (input as Request).url
    if (url.includes('/vote')) {
      await new Promise<void>(r => setTimeout(r, 500)) // delay for optimistic UI
      return new Response(
        JSON.stringify({ voteCount: 99, patternId: 'mocked' }),
        { status: 201, headers: { 'Content-Type': 'application/json' } }
      )
    }
    return orig(input, init)
  }
})
```

`page.addInitScript` runs in the browser context before any page scripts, so the override is in place when `handleVote` calls `voteForPattern`. Only `/vote` URLs are intercepted, leaving all data-fetching requests (`/patterns`, `/patterns/{slug}`) intact.

### Pros
- Bypasses CORS completely — no preflight issues
- Guaranteed to run before app scripts (addInitScript ordering)
- Works regardless of `NEXT_PUBLIC_API_BASE_URL` value or backend availability
- Simpler test assertions — no `waitForRequest`, just check DOM state
- Captures optimistic UI behavior accurately: `setHasVoted(true)` is synchronous, so button disables immediately on click

### Cons
- `page.addInitScript` must be called before `page.goto` (not re-usable if page is already open)
- Overriding `window.fetch` could in theory conflict with Next.js's patched fetch; filtered by URL to minimize risk
- Does not test that a real network request is actually made (network-level verification traded for reliability)

### Alternatives Evaluated
1. **`page.route` with regex** (rejected) — CORS preflight issue silently prevented POST from firing; `waitForRequest` timed out reliably
2. **`page.route` with `route.fulfill()` including explicit CORS headers** (rejected) — complex and brittle; depends on Playwright correctly proxying the OPTIONS response
3. **`page.evaluate` post-navigation** — works but runs after the initial page scripts; `addInitScript` is cleaner and more reliable
4. **Disable CORS in backend for tests** (rejected) — changes production code behaviour; test should adapt to production config

---

## Decision 13: Azure SQL Storage Reduction — 32 GB → 2 GB

**Date:** 2026-02-19
**Title:** Reduce Azure SQL Database Max Storage from Default 32 GB to 2 GB
**Category:** Infrastructure / Cost Optimisation

### Decision Details
The Azure SQL Serverless database (`sqldb-aipatterns-prod`) was created without an explicit `--max-size`, so it defaulted to **32 GB** of provisioned storage. For a small-scale application with 6 seeded patterns and minimal data growth expected, 32 GB is heavily over-provisioned.

Changed via:
```bash
az sql db update \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --name sqldb-aipatterns-prod \
  --max-size 2GB
```

### Rationale
- Application data footprint is tiny (6 patterns, 18 tags, text content)
- 2 GB is a comfortable upper bound — would require tens of thousands of patterns to approach the limit
- Azure General Purpose storage is billed at $0.115/GB/month regardless of actual usage; provisioned size determines the charge

### Savings
| | Before | After |
|---|---|---|
| Provisioned storage | 32 GB | 2 GB |
| Monthly storage cost | ~$3.68 | ~$0.23 |
| **Monthly saving** | | **~$3.45** |

This is significant relative to total infrastructure cost ($5–12/month) and represents ~30–50% of the idle monthly bill.

### Pros
- Immediate ~$3.45/month saving with zero functional impact
- Storage can be increased again at any time via the same command or Azure Portal
- Backup storage allocation also shrinks proportionally

### Cons
- If data grows unexpectedly beyond 2 GB, an explicit resize will be required (non-disruptive, takes ~seconds)

### Alternatives Evaluated
1. **Leave at 32 GB default** (rejected) — unnecessary cost, no benefit for this workload
2. **1 GB minimum** (not chosen at the time) — later adopted in Decision 29 after confirming data footprint remained tiny

---

## Decision 14: Azure Entra External ID over Azure AD B2C

**Date:** 2026-02-19
**Title:** Use Azure Entra External ID (not Azure AD B2C) for Customer Authentication
**Category:** Security & Authentication

### Decision Details
Phase 5 requires authentication for CRUD operations. We evaluated Azure AD B2C (the original plan) versus Azure Entra External ID (B2C's successor).

Azure AD B2C is **no longer available for new customers as of May 2025**. Microsoft has replaced it with Entra External ID, which uses standard OIDC protocols and is free for up to 50,000 MAU.

Chosen: **Azure Entra External ID** with standard OIDC Authorization Code flow (PKCE).

### Pros
- **$0/month** for <50,000 MAU — no cost for our <10 users
- **Standard OIDC** — works with any OIDC client library; no Microsoft-specific SDK required
- **Free email OTP MFA** — secure multi-factor auth at no cost
- **Custom branding** — full CSS customization to match site design
- **App Roles** — built-in role assignment per user (Admin, Editor, Viewer)
- **Active product** — B2C is sunset; Entra External ID is the strategic direction

### Cons
- **ciamlogin.com domain** — slightly unusual (not login.microsoftonline.com)
- **External tenant required** — separate tenant from corporate directory
- **Setup complexity** — multiple Azure portal steps (documented in AUTH_SETUP_GUIDE.md)

### Alternatives Evaluated
1. **Azure AD B2C** (rejected) — no longer available for new registrations as of May 2025
2. **Auth0** — viable, free tier available; rejected as unnecessary complexity when Entra External ID is $0 and provides equivalent features
3. **Keycloak self-hosted** (rejected) — adds operational overhead (hosting, backups, updates) with no cost benefit at this scale
4. **ASP.NET Core Identity** (rejected) — requires database tables for users, sessions, and password hashes; introduces credential management risk

---

## Decision 15: Auth.js (NextAuth v5) over MSAL.js for Frontend Authentication

**Date:** 2026-02-19
**Title:** Use Auth.js Generic OIDC Provider Instead of Microsoft MSAL.js
**Category:** Architecture & Technology Selection

### Decision Details
The frontend required an authentication library to handle OIDC login redirects, token acquisition, session management, and token refresh.

Chosen: **Auth.js v5 (NextAuth beta)** with a generic `type: "oidc"` provider configured for Entra External ID.

Key configuration in `auth.ts`:
- `type: "oidc"` — generic, works with any OIDC provider
- `issuer: process.env.AUTH_ENTRA_ISSUER` — single env var to change provider
- JWT session strategy — no database tables needed
- `pages: { signIn: '/login' }` — branded login page

### Pros
- **Provider-agnostic**: Swapping to Auth0 or Keycloak = changing 4 env vars, zero code changes
- **App Router native**: Auth.js v5 designed for Next.js Server Components
- **JWT sessions**: No database table for sessions; encrypted cookie
- **Built-in CSRF protection**: Handled automatically
- **Server-side token access**: `auth()` function in server components

### Cons
- **Beta library**: Auth.js v5 is still beta; occasional breaking changes
- **ESM in tests**: Requires `transformIgnorePatterns` update in Jest config for SWC compatibility

### Alternatives Evaluated
1. **@azure/msal-react** (rejected) — Microsoft-specific, couples frontend to Azure AD; swapping providers would require full library replacement
2. **next-auth v4** (rejected) — older version without App Router support; v5 is the supported path
3. **Custom OAuth implementation** (rejected) — significant security risk; PKCE, state, nonce handling is complex to implement correctly

---

## Decision 16: Standard ASP.NET Core JwtBearer over Microsoft.Identity.Web

**Date:** 2026-02-19
**Title:** Use Standard JwtBearer Middleware, Not Microsoft.Identity.Web
**Category:** Architecture & Technology Selection

### Decision Details
The backend API needs to validate JWT access tokens issued by the OIDC provider. Two packages were evaluated:

Chosen: **`Microsoft.AspNetCore.Authentication.JwtBearer`** (standard ASP.NET Core package).

Configuration in `Program.cs`:
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Authentication:Authority"];
        options.Audience = builder.Configuration["Authentication:Audience"];
        options.TokenValidationParameters = new TokenValidationParameters
        {
            RoleClaimType = "roles",  // Entra uses "roles" claim
            NameClaimType = "name"
        };
    });
```

The `Authority` URL causes the middleware to auto-discover signing keys from the OIDC discovery document — no key management needed.

### Pros
- **Provider-agnostic**: Any OIDC provider can be used; change Authority + Audience config only
- **Standard package**: Ships with ASP.NET Core SDK, no additional dependency
- **Auto key rotation**: Discovery document enables automatic signing key refresh
- **Minimal surface area**: Does exactly one thing — validate JWT tokens

### Cons
- **Role claim type varies by provider**: Entra uses `roles`; Auth0 uses a custom claim; requires 1-line config change when switching providers
- **No Microsoft Graph integration**: Microsoft.Identity.Web includes Graph client helpers; these are not needed here

### Alternatives Evaluated
1. **Microsoft.Identity.Web** (rejected) — wraps JwtBearer with Microsoft-specific configuration; couples backend to Azure AD; harder to swap to Auth0/Keycloak
2. **Manual JWT validation** (rejected) — high complexity, error-prone; standard middleware handles all edge cases (key rotation, clock skew, audience validation)

---

## Decision 17: Auth Guard Clause + Always-Register Authorization Policies

**Date:** 2026-02-19
**Title:** Register Authorization Policies Unconditionally; Guard JwtBearer Registration
**Category:** Testing & Architecture

### Decision Details
A subtle ordering issue arose when adding `[Authorize(Policy = "RequireEditor")]` attributes:

**Problem:** `AddAuthorizationBuilder()` was initially inside the auth guard clause (only when `Authority` is set). In test environments without a real Entra tenant, no Authority is configured → `AddAuthorizationBuilder()` never ran → authorization policies didn't exist → ASP.NET returned 500 instead of 401/403 → existing integration tests started failing.

**Solution:**
```csharp
// Authorization policies — always registered (enables [Authorize] attributes in tests)
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"))
    .AddPolicy("RequireEditor", policy => policy.RequireRole("Admin", "Editor"))
    .AddPolicy("RequireViewer", policy => policy.RequireRole("Admin", "Editor", "Viewer"));

// JwtBearer — only registered when Authority is configured (opt-in)
var authAuthority = builder.Configuration["Authentication:Authority"];
if (!string.IsNullOrEmpty(authAuthority))
{
    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options => { ... });
}
```

For integration tests, a `TestAuthHandler` reads the `X-Test-Roles` request header and authenticates the request with those roles — no real token needed.

### Pros
- **Existing 83 tests continue passing** without auth config
- **New auth boundary tests** (401/403) work correctly via TestAuthHandler
- **Docker/CI builds** succeed without Entra secrets
- **Local development** works without tenant setup
- **Clean separation**: Policies (always needed) vs. token validation (env-specific)

### Cons
- **Two-step mental model**: Policies always registered, scheme conditionally registered
- **TestAuthHandler complexity**: A small custom class required for test auth

### Alternatives Evaluated
1. **Always require auth config** (rejected) — breaks CI builds and local dev without Entra setup
2. **Skip [Authorize] in tests via mock middleware** (rejected) — hides real authorization behavior; tests wouldn't catch missing policies
3. **Separate test appsettings** (considered) — viable but adds file proliferation; TestAuthHandler is more explicit

---

## Decision 18: Client-Side Auth Checks for Conditional UI in Pattern Management

**Date:** 2026-02-19
**Title:** Use Client-Side Session Checks for Edit/Delete/New Buttons; Server-Side Auth Only for Form Pages
**Category:** Architecture & Security

### Decision Details
Phase 5.2 added CRUD UI (create/edit/delete patterns). Two approaches were evaluated for showing auth-gated UI elements (Edit button, Delete button, "New Pattern" button):

**Approach A (chosen for conditional UI):** Client components check `useSession()` and return `null` when not authorized. This is the same pattern used by the existing `UserMenu` component.

**Approach B (chosen for form pages):** Server components call `auth()` (Auth.js server-side) and `redirect()` for hard access control gates.

**Decision:** Use *both* in appropriate contexts:
- `PatternActions` (edit/delete buttons on detail page): client-side `useSession()` check → returns `null` for non-editors. Page stays ISR-cacheable.
- `NewPatternButton` (on listings page): client-side `useSession()` check → renders `null` for non-editors. Page stays ISR-cacheable.
- `/patterns/new` and `/patterns/[slug]/edit` pages: server-side `auth()` check → `redirect('/login')` or `redirect('/patterns')`. Prevents unauthorized users from even loading the form.

This dual approach avoids a "flash of unauthorized content" on form pages while keeping the read-heavy listing/detail pages in ISR cache.

### Pros
- **ISR caching preserved** for listing/detail pages (no dynamic auth call on the server)
- **Hard gate on write pages** — unauthenticated users redirected before form loads
- **Consistent with existing pattern** — UserMenu already uses client-side session check
- **No flash on form pages** — server redirect happens before any HTML is returned

### Cons
- **Brief null state** while session loads on listing/detail pages (same as UserMenu behavior; acceptable)
- **Two mental models**: conditional UI vs. access control gates behave differently

### Alternatives Evaluated
1. **Server-side auth on all pages** (rejected for listing/detail) — makes ISR-cached pages dynamic, losing caching benefits
2. **Client-side only everywhere** (rejected for form pages) — allows brief render of form HTML before redirect; form submits would still fail at API but UX is confusing

---

## Decision 19: Context-Based Radix UI Select Mock for Jest Tests

**Date:** 2026-02-19
**Title:** Use React.createContext in Jest Mock Factory for Radix UI Select
**Category:** Testing

### Decision Details
The `PatternForm` component uses the shadcn/ui `Select` (Radix UI `@radix-ui/react-select`). Radix UI Select uses portals which don't render in jsdom. The component structure separates `Select` (value/onChange owner), `SelectTrigger` (renders the trigger element with `id`), and `SelectContent`/`SelectItem` (render options).

**Problem:** A naïve mock that renders a native `<select>` inside the `Select` component caused:
1. HTML nesting errors (`<span>` inside `<select>` from `SelectValue`)
2. `getByLabelText` failures because the native select lacked the `id` that was on `SelectTrigger`

**Solution:** A context-based mock factory using `React.createContext`:
```typescript
jest.mock('@/components/ui/select', () => {
  const React = require('react')
  const Ctx = React.createContext({ value: '', onValueChange: () => {} })
  return {
    Select: ({ value, onValueChange, children }) =>
      <Ctx.Provider value={{ value, onValueChange }}>{children}</Ctx.Provider>,
    SelectTrigger: ({ id, children }) => {
      const ctx = React.useContext(Ctx)
      return <select id={id} value={ctx.value} onChange={e => ctx.onValueChange(e.target.value)}>{children}</select>
    },
    SelectValue: () => null,  // prevents <span> inside <select>
    SelectContent: ({ children }) => <>{children}</>,
    SelectItem: ({ value, children }) => <option value={value}>{children}</option>,
  }
})
```

This correctly:
- Links the `<Label htmlFor="category">` to the `<select id="category">` for `getByLabelText`
- Propagates `value` and `onValueChange` from `Select` to `SelectTrigger` via context
- Renders valid HTML (`<option>` elements only inside `<select>`)

### Pros
- **Semantically correct**: `getByLabelText` works; `userEvent.selectOptions` works
- **Valid HTML**: No hydration-style console errors in tests
- **Reusable pattern**: Same approach works for any Radix-style compound component

### Cons
- **Mock complexity**: Requires `React.createContext` inside mock factory
- **Fragile to component prop changes**: If `id` moves from `SelectTrigger` to `Select`, mock breaks

### Alternatives Evaluated
1. **Skip category field in tests** (rejected) — hides real validation logic
2. **Use `data-testid`** (rejected) — breaks `getByLabelText` accessibility-first testing pattern
3. **Mock entire component file** with simpler structure (rejected) — loses label association


---

## Decision 32: Strapi 5 Populate Syntax — Per-Query Bracket Notation

**Date:** 2026-02-25
**Title:** Replace `populate=deep` with Strapi 5 Bracket Notation Per Query
**Category:** Architecture / CMS Integration

### Decision Details

Strapi 5 does NOT support `populate=deep` without the community `strapi-plugin-populate-deep` plugin. The original `safeFetch()` in `lib/cms/queries.ts` sent `{ populate: 'deep' }` for all queries, which returned HTTP 400. Because `fetchStrapi()` wraps non-OK responses as `CmsUnavailableError`, the 400 was silently caught and all queries fell back to hardcoded data — meaning CMS integration appeared to work but never actually served CMS content.

### Fix

Replaced the single `populate=deep` with per-query populate presets using Strapi 5's bracket notation:

| Preset | Syntax | Used By |
|--------|--------|---------|
| `FLAT` | `populate=*` | login, not-found, error, all label types |
| `GLOBAL` | `populate[navigation]=*&populate[footer][populate][links]=*` | global config |
| `DYNAMIC_ZONE` | `populate[content][populate]=*&populate[seo]=*` | home page |
| `DYNAMIC_ZONE_WITH_HEADER` | `populate[content][populate]=*&populate[header]=*&populate[seo]=*` | about, docs pages |

### Why Not Install `strapi-plugin-populate-deep`

- Adds a dependency for something achievable with built-in syntax
- Plugin must be version-compatible with each Strapi upgrade
- Explicit populate is more predictable (no unexpected deep fetches that return excessive data)

---

## Decision 31: Strapi 5 Local Docker Development — Multiple Build Fixes

**Date:** 2026-02-25
**Title:** Strapi 5 Docker Setup Fixes (tsconfig JSON, MySQL Dialect, Multi-Stage Build, esbuild)
**Category:** Infrastructure / CMS

### Decision Details

Getting Strapi 5 running locally in Docker required four separate fixes:

1. **tsconfig.json — Include JSON schemas**: Strapi loads content-type schemas from `dist/`, not `src/`. TypeScript compiler only emits `.ts→.js` files. Schema `.json` files were NOT being copied to `dist/`, causing `TypeError: Cannot read properties of undefined (reading 'kind')` at startup with empty content-type registry. **Fix:** Added `"./src/**/*.json"` to `cms/tsconfig.json` `include` array.

2. **MySQL dialect name**: Strapi 5 uses `mysql` as the dialect key, not `mysql2`. Using `mysql2` caused `Unknown dialect mysql2` at startup. **Fix:** Changed `DATABASE_CLIENT` env var and `database.ts` connection key from `mysql2` to `mysql`.

3. **Multi-stage Dockerfile**: `strapi build` requires `APP_KEYS` and other secrets as env vars at build time. For local dev, building is unnecessary (Strapi auto-builds in dev mode). **Fix:** Restructured Dockerfile with 4 stages (deps → dev → build → production); docker-compose targets `dev` stage which skips the build step.

4. **esbuild dependency**: Strapi's startup auto-installs `react@^18`, `react-dom@^18`, `react-router-dom@^6`, and `styled-components@^6`. This `npm install` side-effect removes `esbuild` from `node_modules`, causing `Cannot find module 'esbuild'`. **Fix:** Added `esbuild`, `react`, `react-dom`, `react-router-dom`, and `styled-components` as explicit dependencies in `cms/package.json` to prevent Strapi's auto-install from disrupting the dependency tree.

### Files Modified
- `cms/tsconfig.json` — added `"./src/**/*.json"` to include
- `cms/config/database.ts` — changed `mysql2` key to `mysql`
- `cms/Dockerfile` — 4-stage build (deps/dev/build/production)
- `cms/package.json` — added esbuild + React deps explicitly
- `docker-compose.yml` — target `dev`, DATABASE_CLIENT `mysql`

---

## Decision 30: Strapi 5 Headless CMS Integration (Phase CMS)

**Date:** 2026-02-25
**Title:** Strapi 5 as Headless CMS for Static Frontend Content
**Category:** Architecture / Content Management

### Decision Details

Integrated Strapi 5 as a headless CMS to manage the 300+ hardcoded static content items across the frontend (headings, descriptions, CTAs, form labels, nav links, SEO metadata, etc.).

### What Was Built

**CMS Project (`cms/`):**
- Strapi 5 TypeScript project with SQLite (dev) / MySQL (production) database support
- 10 Single Types: `global`, `home-page`, `about-page`, `docs-page`, `login-page`, `not-found-page`, `error-page`, `pattern-listing-labels`, `pattern-detail-labels`, `pattern-form-labels`
- 15 Section components (Dynamic Zone blocks): hero, cta-banner, stats-bar, featured-patterns, rich-text, feature-grid, tech-stack, mission-block, open-source-info, page-header, doc-section, api-reference, quick-nav, contributing, support-links
- 12 Shared/Layout components: nav-link, cta-button, footer-config, text-item, stat-item, key-value, feature-card, tech-group, api-endpoint, quick-nav-item, support-item, metadata (SEO)
- Azure Blob Storage upload provider (production media uploads)
- Comprehensive seed script (`data/seed.ts`) with all current hardcoded content

**Infrastructure (`deployment/scripts/provision-cms.ps1`, `.github/workflows/cms-container-deploy.yml`):**
- Azure MySQL Flexible Server (Burstable B1ms, free tier for 12 months)
- Azure Blob Storage (`strapi-media` container)
- Azure Container App for Strapi (0.25 vCPU, 0.5 GiB RAM, scale-to-zero)
- Updated `docker-compose.yml` for local dev (MySQL + Strapi services)
- Estimated cost: ~$10-15/month (free MySQL for 12 months, then ~$23-28/month)

**Frontend CMS Layer (`lib/cms/`):**
- `client.ts`: `fetchStrapi()` with ISR revalidation + `CmsUnavailableError` for graceful fallback
- `types.ts`: Full TypeScript types for all Strapi response shapes
- `queries.ts`: One function per Single Type, with hardcoded fallbacks when CMS unavailable
- `components.tsx`: `DynamicZone` renderer mapping `__component` to React components

**Frontend Integration (Phase 1 — fallback-safe):**
- `app/layout.tsx` → fetches `global` → passes nav/footer/labels to Header and Footer
- `app/page.tsx` → fetches `home-page` → passes CMS block data to Hero, FeaturedPatterns, StatsSection, CTASection
- `components/layout/Header.tsx`, `Footer.tsx`, `Navigation.tsx`, `UserMenu.tsx` → accept optional CMS props with hardcoded fallbacks
- `components/home/Hero.tsx`, `CTASection.tsx`, `FeaturedPatterns.tsx`, `StatsSection.tsx` → accept optional CMS props with hardcoded fallbacks
- `app/login/page.tsx` + `LoginForm.tsx` → fetches `login-page` → CMS-driven labels
- `app/not-found.tsx` → fetches `not-found-page` → CMS-driven 404 content

### Rationale
- Non-developer content editing without code deployments (marketing, labels, CTAs)
- A/B testing of copy and page layouts in future
- Content versioning and draft/publish workflows
- Future i18n readiness (Phase 8)
- SRS already specified CMS integration (Phase 3.2, Section 4.4)

### Incremental Integration Strategy
- **Phase 1 (current):** Server-side fetch with hardcoded fallbacks → zero downtime
- **Phase 2:** Replace remaining hardcoded content (about/docs pages, pattern label props) one component at a time
- **Phase 3:** Remove fallbacks once CMS is stable and seeded

### Alternatives Considered
- **Contentful** — paid above free tier, vendor lock-in for content model
- **Sanity.io** — excellent DX but more complex and higher cost
- **Directus** — great but less mature ecosystem
- **Custom DB tables** — rejected (adds schema complexity without editorial UX)

### Key Technical Notes
- `cms/` directory excluded from root `tsconfig.json` (Strapi has its own tsconfig)
- Strapi single types use `PUT /api/{singular-name}` for upserts
- ISR revalidation: 600s (global), 300s (pages), 3600s (labels), 3600s (static error pages)
- CMS data fetched only in Server Components (no `NEXT_PUBLIC_` prefix for `STRAPI_URL` / `STRAPI_API_TOKEN`)
- `error.tsx` stays client-side (Next.js requirement) — no CMS integration possible

### Status
- ✅ CMS.1: Content model design (all schemas defined)
- ✅ CMS.2: Infrastructure (docker-compose, Dockerfile, provisioning script, CI/CD)
- ✅ CMS.3: Strapi project setup (schemas, seed script)
- ✅ CMS.4: Frontend integration — Phase 1 (lib/cms/, layout, home, login, 404)
- ✅ CMS.5: Production deployment (Azure MySQL + Blob Storage + Container App, seeded, live)

---

## Decision 33: Strapi 5 Production Dockerfile — tsconfig.json + config/ Required at Runtime

**Date:** 2026-02-26
**Title:** Strapi 5 Production Image Must Include tsconfig.json and config/ Source Files
**Category:** Infrastructure / Docker / CMS

### Decision Details

Strapi 5's TypeScript production mode requires both `tsconfig.json` and the `config/` source TypeScript files to be present at runtime, even though the app runs from compiled `dist/`. This is a non-obvious requirement that caused repeated container crashes during initial production deployment.

### Root Cause

Strapi 5 uses `tsUtils.resolveOutDirSync()` to locate the compiled output directory by reading `outDir` from `tsconfig.json`. Without `tsconfig.json`, this function returns `null` and Strapi falls back to loading raw config from `config/` (source), which doesn't exist in a production image that only contains `dist/`. Result: `db.config.connection` is undefined → crash.

If only `tsconfig.json` is present (without `config/` source files), Strapi attempts to recompile TypeScript at startup and fails with `TS18003: No inputs were found in config file` because no `.ts` source files are in the image.

### Fix Applied (cms/Dockerfile production stage)

```dockerfile
# Strapi 5 requires tsconfig.json + config/ source at runtime to resolve compiled config paths
COPY --from=build --chown=strapi:strapi /app/tsconfig.json ./tsconfig.json
COPY --from=build --chown=strapi:strapi /app/config ./config

# Create writable directories required at runtime (non-root user cannot mkdir)
RUN mkdir -p /app/public/uploads /app/database/migrations && \
    chown -R strapi:strapi /app/public /app/database
```

### Why This Matters

- Omitting `tsconfig.json` → silent crash, misleading error about `db.config.connection`
- Omitting `config/` → TS compilation error at startup (not a build error)
- The pre-created `/app/database/migrations` directory is required because the non-root `strapi` user cannot `mkdir` at runtime

### Alternatives Considered

- **Patch tsconfig.json** to point `outDir` to `.` (no subdirectory) — would break the build stage
- **Use `node:alpine` without TypeScript support** — Strapi 5 does not support plain JavaScript projects at production time
- **Custom entrypoint that skips TS resolution** — too fragile, depends on internal Strapi internals

---

## Decision 34: Azure MySQL Flexible Server — francecentral Region Required

**Date:** 2026-02-26
**Title:** MySQL Flexible Server Unavailable in centralus; francecentral Used
**Category:** Infrastructure / Azure / Database

### Decision Details

Azure MySQL Flexible Server (Burstable B1ms SKU) is not available in `centralus` or `eastus2` for this subscription tier. `francecentral` was confirmed as the closest available region.

### Impact

- MySQL server located in `francecentral`, Container App environment in `centralus`
- Cross-region latency is negligible for a low-traffic CMS (Strapi reads happen at Next.js build/ISR time, not per user request)
- `provision-cms.ps1` has explicit `$MysqlLocation = "francecentral"` parameter

### Provider Registration

Both `Microsoft.DBforMySQL` and `Microsoft.Storage` resource providers required explicit registration before provisioning:

```bash
az provider register --namespace Microsoft.DBforMySQL --wait
az provider register --namespace Microsoft.Storage --wait
```

These are not auto-registered for all subscription types. The provisioning script now documents this as a prerequisite step.

---

## Decision 35: Azure Blob Storage — strapi-provider-upload-azure-storage-v5 for Strapi 5

**Date:** 2026-02-26
**Title:** Community Provider strapi-provider-upload-azure-storage-v5 Used for Azure Blob Media Uploads
**Category:** Infrastructure / Storage / CMS

### Decision Details

The official Strapi upload provider `@strapi/provider-upload-azure-storage` does not exist on npm (despite being referenced in some Strapi documentation). The community package `strapi-provider-upload-azure-storage-v5` (v1.1.0, peer dep `@strapi/strapi: ^5.0.0`) is the correct Strapi 5 compatible provider.

### Configuration

Provider only activated when `AZURE_STORAGE_ACCOUNT` env var is set — falls back to local filesystem in dev:

```typescript
// cms/config/plugins.ts
if (env('AZURE_STORAGE_ACCOUNT')) {
  config.upload = {
    config: {
      provider: 'strapi-provider-upload-azure-storage-v5',
      providerOptions: {
        account: env('AZURE_STORAGE_ACCOUNT'),
        accountKey: env('AZURE_STORAGE_ACCOUNT_KEY'),
        containerName: env('AZURE_STORAGE_CONTAINER'),
        ...
      }
    }
  };
}
```

### Blob Container Access

Container set to `--public-access blob` (individual blob public read, container listing private). This allows CMS media URLs to work in the Next.js frontend without authentication, while preventing directory browsing.

### Env Var Naming

Must use `AZURE_STORAGE_*` prefix (not `STORAGE_*`) to match provider expectations:
- `AZURE_STORAGE_ACCOUNT`
- `AZURE_STORAGE_ACCOUNT_KEY`
- `AZURE_STORAGE_CONTAINER`
- `AZURE_STORAGE_URL`

---

## Decision 36: Strapi Production Deployment — Azure Container Apps with Image Digest Pinning

**Date:** 2026-02-26
**Title:** Pin Strapi Container App to Specific Image Digest to Avoid Stale Cache
**Category:** Infrastructure / Deployment / Container Apps

### Decision Details

Azure Container Apps with `:latest` tag can serve stale images even after a new push because the platform may cache the previous layer locally. During initial Strapi production deployment, `az containerapp update --image ...latest` did not consistently pull the newly pushed image.

### Fix

Use explicit SHA256 digest when deploying a new image:

```bash
# Get the digest after push
DIGEST=$(az acr repository show --name craipatternssp54426 --image aipatterns-cms:latest --query digest -o tsv)

# Deploy with digest instead of :latest tag
az containerapp update \
  --name ca-aipatterns-cms-prod \
  --resource-group rg-aipatterns-prod \
  --image "craipatternssp54426.azurecr.io/aipatterns-cms@$DIGEST"
```

### CI/CD Implication

The `cms-container-deploy.yml` workflow should be updated to retrieve the digest post-push and deploy with it, rather than relying on `:latest`. This ensures each deployment uses the exact image that was built.

### Subscription Constraint

ACR Tasks (`az acr build`) are not available on this subscription tier (`TasksOperationsNotAllowed`). All Docker builds must be done locally or in GitHub Actions runners, then pushed to ACR with `docker push`.
- 🔲 CMS.4 Phase 2: about/docs pages, pattern label props propagation
