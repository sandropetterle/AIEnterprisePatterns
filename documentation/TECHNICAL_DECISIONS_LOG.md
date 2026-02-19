# Technical Decisions Log

This document captures significant technical design decisions made during the development and deployment of the AI Enterprise Patterns application.

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
2. **1 GB minimum** (not chosen) — Azure General Purpose minimum is 1 GB, but 2 GB gives comfortable headroom

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

