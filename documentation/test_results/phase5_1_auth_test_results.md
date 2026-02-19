# Phase 5.1 — Authentication Test Results

**Date:** 2026-02-19
**Phase:** 5.1 — Authentication & Authorization (Azure Entra External ID)

## Summary

| Suite | Before | After | New Tests | Pass Rate |
|-------|--------|-------|-----------|-----------|
| Frontend (Jest) | 262 | 286 | +24 | 100% ✅ |
| Backend (xUnit) | 83 | 87 | +4 | 100% ✅ |
| **Total** | **345** | **373** | **+28** | **100%** ✅ |

---

## Frontend Tests (286/286)

### New auth test files

| File | Tests | Coverage |
|------|-------|----------|
| `lib/types/__tests__/auth.test.ts` | 10 | `hasRole`, `roleLabel` utility functions |
| `app/login/__tests__/LoginForm.test.tsx` | 6 | Login form rendering, signIn call, error display |
| `components/layout/__tests__/UserMenu.test.tsx` | 8 | Loading skeleton, sign-in button, user dropdown, signOut |

### auth.test.ts — `hasRole` and `roleLabel`

| Test | Result |
|------|--------|
| `hasRole` returns false when roles is undefined | ✅ |
| `hasRole` returns false when roles is empty | ✅ |
| `hasRole` returns true when user has exact role | ✅ |
| `hasRole` returns false when user lacks role | ✅ |
| Admin is superuser (passes any required role) | ✅ |
| `hasRole` true when role present among multiple | ✅ |
| `roleLabel` returns "Viewer" for undefined/empty | ✅ |
| `roleLabel` returns "Admin" when user is Admin | ✅ |
| `roleLabel` returns "Editor" when Editor only | ✅ |
| Admin takes precedence over other roles in label | ✅ |

### LoginForm.test.tsx

| Test | Result |
|------|--------|
| Renders sign-in heading and button | ✅ |
| Renders footer description text | ✅ |
| Calls `signIn('entra-external-id')` on click | ✅ |
| Shows alert with "Access denied" for `AccessDenied` error | ✅ |
| Shows fallback "unexpected error" for unknown error codes | ✅ |
| Does not show alert when no error prop given | ✅ |

### UserMenu.test.tsx

| Test | Result |
|------|--------|
| Renders loading skeleton while session is loading | ✅ |
| Renders Sign In button when unauthenticated | ✅ |
| Calls `signIn` when Sign In button clicked | ✅ |
| Renders user menu trigger with name when authenticated | ✅ |
| Shows role badge in dropdown | ✅ |
| Calls `signOut({ callbackUrl: '/' })` when Sign Out clicked | ✅ |

### Mock strategy for auth tests

- **`next-auth/react`**: Mocked globally in `jest.setup.ts` (default: unauthenticated). Tests override per-case via `(useSession as jest.Mock).mockReturnValue(...)`.
- **`@/components/ui/dropdown-menu`**: Mocked inline in UserMenu tests — Radix UI portals don't render in jsdom, so the mock renders content directly.
- **`CardTitle` heading fix**: `LoginForm.tsx` uses `<h1>` directly (not `CardTitle` which renders as `<div>`) so `getByRole('heading')` works correctly and accessibility is improved.

---

## Backend Tests (87/87)

### New auth tests in `PatternEndpointsTests.cs`

| Test | Result |
|------|--------|
| `CreatePattern_ShouldReturn401WhenUnauthenticated` | ✅ |
| `UpdatePattern_ShouldReturn401WhenUnauthenticated` | ✅ |
| `DeletePattern_ShouldReturn401WhenUnauthenticated` | ✅ |
| `DeletePattern_ShouldReturn403WhenEditorTriesToDelete` | ✅ |

### All existing 83 tests continue passing

No regressions. The auth guard clause (`if (!string.IsNullOrEmpty(authAuthority))`) ensures JwtBearer is not registered in the test environment, while authorization policies are always registered so `[Authorize]` attributes resolve correctly.

### TestAuthHandler pattern

Integration tests use a custom `TestAuthHandler` that reads the `X-Test-Roles` header and authenticates with those roles. Helper methods:

```csharp
private HttpRequestMessage AdminRequest(HttpMethod method, string url) =>
    new HttpRequestMessage(method, url).WithRole("Admin");

private HttpRequestMessage EditorRequest(HttpMethod method, string url) =>
    new HttpRequestMessage(method, url).WithRole("Editor");
```

---

## Test Infrastructure Changes

| File | Change |
|------|--------|
| `jest.setup.ts` | Added global `next-auth/react` mock + `AUTH_SECRET` env var |
| `jest.config.mjs` | `transformIgnorePatterns` updated to allow next-auth/`@auth` ESM |
| `TestAuthHandler.cs` (new) | Header-driven fake auth for backend integration tests |
