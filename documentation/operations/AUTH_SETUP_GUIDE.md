# Authentication Setup Guide — Azure Entra External ID

**Last Updated:** 2026-03-19
**Audience:** Infrastructure Engineers, Solutions Architects
**Purpose:** Step-by-step guide for configuring Azure Entra External ID as the OIDC provider for frontend (Auth.js) and backend (JwtBearer) authentication.

This guide covers the Azure Entra External ID configuration required for the AI Enterprise Patterns application. Complete these steps once per environment (development, production).

---

## Prerequisites

- Azure subscription (for billing anchor; auth itself is $0 for <50,000 MAU)
- Tenant Creator role in Azure Entra (or Global Admin)
- Redirect URIs for each environment (see below)

---

## Cost Summary

| Resource | Cost |
|----------|------|
| Entra External Tenant | Free |
| App Registrations | Free |
| First 50,000 MAU | **Free** |
| Email OTP MFA | Free |
| SMS MFA | **Avoid — paid per SMS** |
| **Total for <10 users** | **$0/month** |

**Rule:** Always use email + password with email OTP for MFA. Never enable SMS MFA.

---

## Step 1: Create External Tenant

1. Go to **Azure Portal** → Microsoft Entra ID → Manage tenants → **Create**
2. Select tenant type: **External** (not Workforce)
3. Fill in:
   - **Tenant name:** `aipatterns-external` (or your preferred name)
   - **Domain name:** `aipatterns` → results in `aipatterns.onmicrosoft.com`
   - **Region:** Match your application region (e.g., United States)
4. Click **Review + Create** → **Create**
5. Wait for provisioning (~2 minutes), then **Switch to the new tenant**

> **Important:** Record the **Tenant ID** from the tenant overview — you'll need it for environment variables.

---

## Step 2: Register Backend API

1. In the external tenant, go to **App registrations** → **New registration**
2. Fill in:
   - **Name:** `AIPatterns-API`
   - **Supported account types:** Accounts in this organizational directory only
   - **Redirect URI:** Leave blank
3. Click **Register**
4. Record the **Application (client) ID** — this is your `AUTH_ENTRA_API_CLIENT_ID`

### 2a. Set Application ID URI

1. In the API app → **Expose an API** → **Set** (next to Application ID URI)
2. Set to: `api://aipatterns-api`
3. Click **Save**

### 2b. Add API Scopes

1. Click **Add a scope**
2. Scope 1:
   - **Scope name:** `patterns.read`
   - **Who can consent:** Admins and users
   - **Admin consent display name:** Read patterns
   - **State:** Enabled
3. Click **Add scope**
4. Add Scope 2:
   - **Scope name:** `patterns.write`
   - **Who can consent:** Admins only
   - **Admin consent display name:** Write patterns
   - **State:** Enabled

### 2c. Define App Roles

1. In the API app → **App roles** → **Create app role**
2. Role 1 — Admin:
   - **Display name:** Admin
   - **Allowed member types:** Users/Groups
   - **Value:** `Admin`
   - **Description:** Full access — create, edit, delete patterns
   - **State:** Enabled
3. Create Role 2 — Editor:
   - **Value:** `Editor`
   - **Description:** Can create and edit patterns
4. Create Role 3 — Viewer:
   - **Value:** `Viewer`
   - **Description:** Read-only access

---

## Step 3: Register Frontend App

1. In the external tenant, go to **App registrations** → **New registration**
2. Fill in:
   - **Name:** `AIPatterns-Web`
   - **Supported account types:** Accounts in this organizational directory only
   - **Redirect URI (Web):**
     - `http://localhost:3000/api/auth/callback/entra-external-id` (dev)
     - `https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api/auth/callback/entra-external-id` (prod)
3. Click **Register**
4. Record the **Application (client) ID** — this is your `AUTH_ENTRA_CLIENT_ID`

### 3a. Enable ID and Access Tokens

1. Frontend app → **Authentication**
2. Under **Implicit grant and hybrid flows**, enable:
   - ✅ Access tokens
   - ✅ ID tokens
3. Click **Save**

### 3b. Create Client Secret

1. Frontend app → **Certificates & secrets** → **New client secret**
2. **Description:** `nextauth-secret`
3. **Expires:** 24 months (or per your rotation policy)
4. Click **Add**
5. **Copy the secret Value immediately** — it won't be shown again
6. This is your `AUTH_ENTRA_CLIENT_SECRET`

### 3c. Grant API Permissions

1. Frontend app → **API permissions** → **Add a permission**
2. Select **My APIs** → `AIPatterns-API`
3. Select **Delegated permissions** → check:
   - `patterns.read`
   - `patterns.write`
4. Click **Add permissions**
5. Click **Grant admin consent for [tenant]** → **Yes**

---

## Step 4: Configure Sign-Up/Sign-In User Flow

1. External tenant → **User flows** → **New user flow**
2. Select **Sign up and sign in**
3. Fill in:
   - **Name:** `B2C_1_signupsignin` (or `susi`)
   - **Identity providers:** Email + password
   - **MFA:** Email one-time password (free — **do not select Phone/SMS**)
4. **User attributes to collect:** Display name, Email address
5. **Token claims to return:** Display name, Email address, Identity provider, User's object ID
6. Click **Create**

---

## Step 5: Configure Custom Branding

1. External tenant → **Company branding** → **Customize**
2. Upload assets matching the website design system:

| Setting | Value |
|---------|-------|
| Logo (PNG/SVG, ≤36px height recommended) | Site logo (from `/public/logo.*`) |
| Background color | `#ffffff` (light) / `#0f172a` (dark) |
| Sign-in page text | `Sign in to AI Enterprise Patterns` |
| Favicon | Same SVG favicon as website |
| Button color | `#3b82f6` (matches `--primary` Tailwind blue-500) |
| Font | Inter (via Google Fonts URL) |

3. Custom CSS template (upload as CSS file):

```css
/* Match shadcn/ui design tokens */
:root {
  --font-family: 'Inter', system-ui, sans-serif;
}
.ext-sign-in-box {
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  font-family: var(--font-family);
}
.ext-button-primary {
  background-color: #3b82f6;
  border-radius: 0.375rem;
  font-family: var(--font-family);
}
.ext-button-primary:hover {
  background-color: #2563eb;
}
```

---

## Step 6: Assign Roles to Users

For each authorized user:

1. External tenant → **Enterprise applications** → `AIPatterns-API`
2. **Users and groups** → **Add user/group**
3. Select the user → Select the appropriate role (Admin, Editor, or Viewer)
4. Click **Assign**

> **Note:** A user with no role assigned will receive a 403 Forbidden from the API on any write operation. They can still browse patterns (read endpoints are anonymous).

---

## Step 7: Gather Environment Variables

After completing the above steps, collect these values for `.env.local` (dev) and Azure Container Apps secrets (prod):

```bash
# Auth.js
AUTH_SECRET=<generate: openssl rand -base64 32>
AUTH_TRUST_HOST=true

# Entra External ID — Frontend App
AUTH_ENTRA_ISSUER=https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0
AUTH_ENTRA_CLIENT_ID=<Frontend App (client) ID>
AUTH_ENTRA_CLIENT_SECRET=<Frontend App client secret value>

# API scopes
AUTH_API_SCOPE_READ=api://aipatterns-api/patterns.read
AUTH_API_SCOPE_WRITE=api://aipatterns-api/patterns.write
```

> **Where to find the issuer:** Fetch the OIDC discovery document and read the `issuer` field directly — it is the authoritative value Auth.js validates against:
> ```
> curl https://aipatterns.ciamlogin.com/<tenant-id>/v2.0/.well-known/openid-configuration | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).issuer))"
> ```
> For Entra External ID CIAM tenants the issuer uses the **tenant ID as the subdomain**, not the tenant name:
> `https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0`
> (Using the friendly name subdomain in AUTH_ENTRA_ISSUER causes an issuer mismatch error in Auth.js.)

---

## Step 8: Backend Configuration

Add to `appsettings.Development.json` (local dev):

```json
{
  "Authentication": {
    "Authority": "https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0",
    "Audience": "api://aipatterns-api",
    "RequireHttpsMetadata": false
  }
}
```

Add to Azure Container Apps environment variables (production):

| Name | Value |
|------|-------|
| `Authentication__Authority` | `https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0` |
| `Authentication__Audience` | `api://aipatterns-api` |
| `Authentication__RequireHttpsMetadata` | `true` |

---

## Verification Checklist

After completing setup, verify each step:

- [ ] `GET /api/patterns` returns 200 without any token (anonymous)
- [ ] `POST /api/patterns` returns 401 without a token
- [ ] `POST /api/patterns` returns 403 with a Viewer-role token
- [ ] `POST /api/patterns` returns 201 with an Editor-role token
- [ ] `DELETE /api/patterns/{id}` returns 403 with Editor token
- [ ] `DELETE /api/patterns/{id}` returns 204 with Admin token
- [ ] `GET /api/auth/me` returns user info with a valid token
- [ ] `/login` page renders with "Sign in" heading and "Continue with Microsoft" button
- [ ] Clicking "Continue with Microsoft" redirects to Entra External ID sign-in page
- [ ] After signing in, header shows user name and role badge
- [ ] Sign Out button clears session and redirects to home

---

## Swapping to a Different OIDC Provider

The implementation is provider-agnostic. To switch to Auth0, Keycloak, or another OIDC provider:

| Change | What to update |
|--------|---------------|
| Provider issuer | `AUTH_ENTRA_ISSUER` env var → new issuer URL |
| Client credentials | `AUTH_ENTRA_CLIENT_ID` / `AUTH_ENTRA_CLIENT_SECRET` → new values |
| API scopes | `AUTH_API_SCOPE_READ` / `AUTH_API_SCOPE_WRITE` → new scope names |
| Backend Authority | `Authentication__Authority` → new issuer URL |
| Backend Audience | `Authentication__Audience` → new audience value |
| Role claim type | `Program.cs`: `RoleClaimType` — check if provider uses `roles`, `https://yourapp.com/roles`, or `realm_access.roles` |

No other code changes are needed.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| 401 on all requests | Backend Authority not set or wrong | Check `appsettings.json`, verify issuer matches token |
| 403 even with correct role | Roles not in access token | Ensure app role assignment in Enterprise Applications, not just App Registration |
| Redirect loop on /login | AUTH_SECRET mismatch | Regenerate `AUTH_SECRET`, ensure same value across restarts |
| "OAuthCallback" error | Redirect URI mismatch | Add exact callback URL to Frontend app registration |
| Token has no `roles` claim | Role assigned to wrong app | Assign roles via Enterprise Applications → `AIPatterns-API` (not the frontend app) |
| `ciamlogin.com` blocked | CSP header | Verify `next.config.mjs` includes `*.ciamlogin.com` in `connect-src` |
