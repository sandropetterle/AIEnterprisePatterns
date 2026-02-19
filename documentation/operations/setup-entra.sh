#!/usr/bin/env bash
# =============================================================================
# setup-entra.sh — Azure Entra External ID app registration automation
# =============================================================================
# Run AFTER completing Step 1 (creating the External tenant) in AUTH_SETUP_GUIDE.md.
#
# What this script does (Steps 2–7):
#   - Creates the Backend API app registration with App ID URI, scopes, and roles
#   - Creates the Frontend Web app registration with redirect URIs and client secret
#   - Grants admin consent for the API permissions
#   - Assigns your account the Admin role
#   - Prints ready-to-paste environment variables
#
# Remaining manual steps after running this script:
#   - Step 4: Configure Sign-Up/Sign-In user flow in the portal
#   - Step 5: Configure branding (optional)
#
# Prerequisites:
#   - Azure CLI installed: https://aka.ms/installazurecli
#   - python3 available (for JSON + UUID handling)
#   - Logged into the External tenant (not your main subscription tenant):
#       az login --tenant <external-tenant-id> --allow-no-subscriptions
#
# Usage:
#   bash documentation/operations/setup-entra.sh
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ  ${NC}$*"; }
success() { echo -e "${GREEN}✓  ${NC}$*"; }
warn()    { echo -e "${YELLOW}⚠  ${NC}$*"; }
die()     { echo -e "${RED}✗  ${NC}$*" >&2; exit 1; }

new_uuid() {
  node -e "const { randomUUID } = require('crypto'); console.log(randomUUID())"
}

# Parse a field from JSON piped to stdin: json_field <field>
json_field() {
  node -e "let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>console.log(JSON.parse(d)['$1']))"
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
command -v az   >/dev/null 2>&1 || die "Azure CLI not found. Install: https://aka.ms/installazurecli"
command -v node >/dev/null 2>&1 || die "node not found — required for JSON/UUID handling"

echo ""
echo -e "${BOLD}=== Entra External ID Setup (Steps 2–7) ===${NC}"
echo ""

# ---------------------------------------------------------------------------
# Verify tenant
# ---------------------------------------------------------------------------
TENANT_ID=$(az account show --query tenantId --output tsv 2>/dev/null || echo "")
[[ -n "$TENANT_ID" ]] || die "Not logged in. Run:  az login --tenant <external-tenant-id> --allow-no-subscriptions"

info "Active tenant: $TENANT_ID"
echo ""
warn "Make sure this is your Entra External ID tenant — NOT your main Azure subscription tenant."
warn "If wrong, run:  az login --tenant <external-tenant-id> --allow-no-subscriptions"
echo ""
read -rp "Continue with tenant $TENANT_ID? (y/N): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
echo ""

# ---------------------------------------------------------------------------
# Derive issuer from tenant domain (e.g. aipatterns.ciamlogin.com/<tenant-id>/v2.0)
# ---------------------------------------------------------------------------
info "Fetching tenant domain..."
TENANT_DOMAIN=$(az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/organization" \
  --output json | node -e "
let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
  const org=JSON.parse(d).value[0];
  const dom=org.verifiedDomains.find(x=>x.name.endsWith('.onmicrosoft.com'));
  console.log(dom ? dom.name : '');
});
")
[[ -n "$TENANT_DOMAIN" ]] || die "Could not determine tenant domain. Verify you are in the External tenant."
TENANT_NAME="${TENANT_DOMAIN%.onmicrosoft.com}"
CIAM_ISSUER="https://${TENANT_NAME}.ciamlogin.com/${TENANT_ID}/v2.0"
success "Tenant domain: $TENANT_DOMAIN  →  issuer: $CIAM_ISSUER"
echo ""

# ===========================================================================
# Step 2: Backend API app registration (AIPatterns-API)
# ===========================================================================
info "Creating Backend API app (AIPatterns-API)..."

BACKEND_JSON=$(az ad app create \
  --display-name "AIPatterns-API" \
  --sign-in-audience "AzureADMyOrg" \
  --output json)
BACKEND_APP_ID=$(echo "$BACKEND_JSON" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).appId))")
BACKEND_OBJ_ID=$(echo "$BACKEND_JSON"  | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).id))")
success "AIPatterns-API  client ID: $BACKEND_APP_ID"

# 2a. App ID URI
info "Setting App ID URI (api://aipatterns-api)..."
az ad app update --id "$BACKEND_APP_ID" --identifier-uris "api://aipatterns-api"
success "App ID URI set"

# 2b. API scopes
SCOPE_READ_ID=$(new_uuid)
SCOPE_WRITE_ID=$(new_uuid)
info "Adding scopes: patterns.read, patterns.write..."

az rest --method PATCH \
  --uri "https://graph.microsoft.com/v1.0/applications/$BACKEND_OBJ_ID" \
  --headers "Content-Type=application/json" \
  --body "$(cat <<BODY
{
  "api": {
    "oauth2PermissionScopes": [
      {
        "id": "$SCOPE_READ_ID",
        "adminConsentDescription": "Read patterns",
        "adminConsentDisplayName": "Read patterns",
        "isEnabled": true,
        "type": "User",
        "userConsentDescription": "Read patterns",
        "userConsentDisplayName": "Read patterns",
        "value": "patterns.read"
      },
      {
        "id": "$SCOPE_WRITE_ID",
        "adminConsentDescription": "Write patterns",
        "adminConsentDisplayName": "Write patterns",
        "isEnabled": true,
        "type": "Admin",
        "userConsentDescription": "Write patterns",
        "userConsentDisplayName": "Write patterns",
        "value": "patterns.write"
      }
    ]
  }
}
BODY
)"
success "Scopes added"

# 2c. App Roles
ROLE_ADMIN_ID=$(new_uuid)
ROLE_EDITOR_ID=$(new_uuid)
ROLE_VIEWER_ID=$(new_uuid)
info "Adding App Roles: Admin, Editor, Viewer..."

az rest --method PATCH \
  --uri "https://graph.microsoft.com/v1.0/applications/$BACKEND_OBJ_ID" \
  --headers "Content-Type=application/json" \
  --body "$(cat <<BODY
{
  "appRoles": [
    {
      "id": "$ROLE_ADMIN_ID",
      "allowedMemberTypes": ["User"],
      "description": "Full access — create, edit, delete patterns",
      "displayName": "Admin",
      "isEnabled": true,
      "value": "Admin"
    },
    {
      "id": "$ROLE_EDITOR_ID",
      "allowedMemberTypes": ["User"],
      "description": "Can create and edit patterns",
      "displayName": "Editor",
      "isEnabled": true,
      "value": "Editor"
    },
    {
      "id": "$ROLE_VIEWER_ID",
      "allowedMemberTypes": ["User"],
      "description": "Read-only access",
      "displayName": "Viewer",
      "isEnabled": true,
      "value": "Viewer"
    }
  ]
}
BODY
)"
success "App Roles added"

# Service principal for backend (required for role assignments and admin consent)
info "Creating service principal for AIPatterns-API..."
BACKEND_SP_ID=$(az ad sp create --id "$BACKEND_APP_ID" --query id --output tsv)
success "Backend service principal: $BACKEND_SP_ID"
echo ""

# ===========================================================================
# Step 3: Frontend Web app registration (AIPatterns-Web)
# ===========================================================================
info "Creating Frontend Web app (AIPatterns-Web)..."

DEV_REDIRECT="http://localhost:3000/api/auth/callback/entra-external-id"
PROD_REDIRECT="https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api/auth/callback/entra-external-id"

FRONTEND_JSON=$(az ad app create \
  --display-name "AIPatterns-Web" \
  --sign-in-audience "AzureADMyOrg" \
  --web-redirect-uris "$DEV_REDIRECT" "$PROD_REDIRECT" \
  --output json)
FRONTEND_APP_ID=$(echo "$FRONTEND_JSON" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).appId))")
FRONTEND_OBJ_ID=$(echo "$FRONTEND_JSON"  | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).id))")
success "AIPatterns-Web  client ID: $FRONTEND_APP_ID"

# 3a. Enable ID tokens and access tokens
info "Enabling ID and access tokens (implicit grant)..."
az rest --method PATCH \
  --uri "https://graph.microsoft.com/v1.0/applications/$FRONTEND_OBJ_ID" \
  --headers "Content-Type=application/json" \
  --body '{
    "web": {
      "implicitGrantSettings": {
        "enableAccessTokenIssuance": true,
        "enableIdTokenIssuance": true
      }
    }
  }'
success "Implicit grant tokens enabled"

# 3b. Client secret
info "Creating client secret (2-year expiry)..."
SECRET_JSON=$(az ad app credential reset \
  --id "$FRONTEND_APP_ID" \
  --display-name "nextauth-secret" \
  --years 2 \
  --output json)
CLIENT_SECRET=$(echo "$SECRET_JSON" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).password))")
success "Client secret created"

# 3c. API permissions + admin consent
info "Adding API permissions (patterns.read, patterns.write)..."
# Small sleep to allow scope propagation
sleep 5
az ad app permission add \
  --id "$FRONTEND_APP_ID" \
  --api "$BACKEND_APP_ID" \
  --api-permissions "${SCOPE_READ_ID}=Scope" "${SCOPE_WRITE_ID}=Scope"
success "Permissions added"

info "Creating service principal for AIPatterns-Web..."
az ad sp create --id "$FRONTEND_APP_ID" --output none
success "Frontend service principal created"

info "Granting admin consent..."
az ad app permission admin-consent --id "$FRONTEND_APP_ID" || {
  warn "Admin consent command failed — grant manually in the portal:"
  warn "  App registrations → AIPatterns-Web → API permissions → Grant admin consent"
}
echo ""

# ===========================================================================
# Step 6: Assign current user the Admin role
# ===========================================================================
info "Looking up your user account..."
CURRENT_USER_OID=$(az ad signed-in-user show --query id --output tsv 2>/dev/null || echo "")
if [[ -z "$CURRENT_USER_OID" ]]; then
  warn "Could not determine current user object ID (common in CIAM tenants)."
  warn "Assign manually: Enterprise Applications → AIPatterns-API → Users and groups → Add user/group → Admin"
else
  info "Assigning Admin role to user $CURRENT_USER_OID..."
  az rest --method POST \
    --uri "https://graph.microsoft.com/v1.0/users/$CURRENT_USER_OID/appRoleAssignments" \
    --headers "Content-Type=application/json" \
    --body "$(cat <<BODY
{
  "principalId": "$CURRENT_USER_OID",
  "resourceId": "$BACKEND_SP_ID",
  "appRoleId": "$ROLE_ADMIN_ID"
}
BODY
)" && success "Admin role assigned" || {
    warn "Role assignment failed — assign manually:"
    warn "  Enterprise Applications → AIPatterns-API → Users and groups → Add user/group → Admin"
  }
fi

# ===========================================================================
# Step 7: Print environment variables
# ===========================================================================
AUTH_SECRET_PLACEHOLDER="$(node -e "const {randomBytes}=require('crypto');console.log(randomBytes(32).toString('base64'))")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}Environment Variables — copy to .env.local and GitHub Secrets${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# .env.local (frontend)"
echo "AUTH_SECRET=${AUTH_SECRET_PLACEHOLDER}"
echo "AUTH_TRUST_HOST=true"
echo "AUTH_ENTRA_ISSUER=${CIAM_ISSUER}"
echo "AUTH_ENTRA_CLIENT_ID=${FRONTEND_APP_ID}"
echo "AUTH_ENTRA_CLIENT_SECRET=${CLIENT_SECRET}"
echo "AUTH_API_SCOPE_READ=api://aipatterns-api/patterns.read"
echo "AUTH_API_SCOPE_WRITE=api://aipatterns-api/patterns.write"
echo ""
echo "# Backend — appsettings.Development.json (or Container Apps env vars)"
echo "Authentication__Authority=${CIAM_ISSUER}"
echo "Authentication__Audience=api://aipatterns-api"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}⚠  AUTH_ENTRA_CLIENT_SECRET shown ONCE — save it now before closing this terminal.${NC}"
echo ""
echo -e "${BOLD}GitHub Secrets to add (repo Settings → Secrets → Actions):${NC}"
echo "  AUTH_ENTRA_ISSUER        = ${CIAM_ISSUER}"
echo "  AUTH_ENTRA_CLIENT_ID     = ${FRONTEND_APP_ID}"
echo "  AUTH_API_SCOPE_READ      = api://aipatterns-api/patterns.read"
echo "  AUTH_API_SCOPE_WRITE     = api://aipatterns-api/patterns.write"
echo ""
echo -e "${BOLD}Container App secrets (run these in your main subscription terminal):${NC}"
echo "  az containerapp secret set \\"
echo "    --name ca-aipatterns-web-prod \\"
echo "    --resource-group rg-aipatterns-prod \\"
echo "    --secrets \\"
echo "      \"auth-secret=${AUTH_SECRET_PLACEHOLDER}\" \\"
echo "      \"auth-entra-client-secret=${CLIENT_SECRET}\""
echo ""
echo -e "${BOLD}Remaining manual steps:${NC}"
echo "  4. Portal → External tenant → User flows → New user flow"
echo "     Select: Sign up and sign in | Email + password | Email OTP MFA (not SMS)"
echo "     Collect: Display name, Email address"
echo "  5. (Optional) Portal → Company branding → Customize"
echo ""
echo -e "${BOLD}Verification checklist:${NC}  AUTH_SETUP_GUIDE.md → Verification Checklist"
echo ""
success "Done."
