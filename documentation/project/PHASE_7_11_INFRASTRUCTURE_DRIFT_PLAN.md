# Phase 7.11 — Infrastructure Drift Resolution & Live Hardening

**Status:** 📋 Planned
**Priority:** HIGH
**Dependencies:** Phase 7 complete
**Created:** 2026-03-19
**Estimated Effort:** Medium (6 tracks, ~30 drift items)

---

## Context

A comprehensive audit compared the **live Azure subscription** against the Bicep IaC definitions and documentation. This revealed **significant configuration drift** — the live resources were originally provisioned via scripts/portal before Bicep was written (Phase 6.8), and the Bicep has never been fully applied to the live environment. This plan addresses both the drift and new hardening improvements.

---

## DRIFT FINDINGS: Live Azure vs Bicep

### CRITICAL DRIFT (Security Impact)

| # | Resource | Property | Live Value | Bicep Value | Impact |
|---|----------|----------|-----------|-------------|--------|
| D1 | Key Vault | `enableRbacAuthorization` | **`false`** (access policy mode) | `true` (RBAC mode) | Live KV uses legacy access policies with `all` permissions instead of scoped RBAC roles. The 3 KV role assignments in main.bicep (lines 153-181) are **not effective** because KV is in access policy mode. |
| D2 | Key Vault | `enablePurgeProtection` | **`null`** (disabled) | `true` | Live KV can be permanently purged — no protection against accidental/malicious deletion of secrets |
| D3 | Key Vault | tags | **`{}`** (empty) | `{project, environment, managedBy}` | No tags on live KV |
| D4 | SQL Server | `administratorLogin` | **`aipatterns-admin`** | `sqladmin` | Different admin username — Bicep redeploy would fail or create conflict |
| D5 | SQL Server | tags | **`null`** (none) | `{project, environment, managedBy}` | No tags on any SQL resources |
| D6 | SQL Database | `maxSizeBytes` | **1 GB** (`1073741824`) | **32 GB** (`34359738368`) | Live DB is 32x smaller than Bicep specifies |
| D7 | Storage Account | `minimumTlsVersion` | **`TLS1_0`** | `TLS1_2` | **Security risk** — live storage allows TLS 1.0 connections |
| D8 | Storage Account | location | **`centralus`** | `francecentral` (cms.bicep) | Storage was created in centralus but Bicep defaults to francecentral |
| D9 | Storage Account | tags | **`{}`** (empty) | `{project, environment, managedBy}` | No tags |
| D10 | MySQL Server | `administratorLogin` | **`strapiAdmin`** | `mysqladmin` | Different admin username — matches provision-cms.ps1 but not Bicep |
| D11 | MySQL Server | `storage.autoGrow` | **`Disabled`** | `Enabled` | Live storage won't auto-grow |
| D12 | MySQL Server | tags | **`null`** | `{project, environment, managedBy}` | No tags |
| D13 | All Container Apps | tags | **`null`** | `{project, environment, managedBy}` | No tags on any Container App |
| D14 | ACR | tags | **`{}`** | `{project, environment, managedBy}` | No tags |
| D15 | API Container App | secrets | `app-insights-key` (InstrumentationKey) | `appinsights-connection-string` (ConnectionString) | Live uses deprecated InstrumentationKey; Bicep uses ConnectionString (recommended) |
| D16 | API Container App | secrets source | Direct secret values | Key Vault references (`keyVaultUrl + identity: system`) | Live API secrets are stored directly in Container App, not referenced from KV |
| D17 | API Container App | env vars | Missing `ASPNETCORE_URLS`, auth vars | Has `ASPNETCORE_URLS`, `Authentication__*` vars | Live API missing explicit URL binding and auth config env vars |
| D18 | API Container App | probes | **None** | HTTP probes (startup/liveness/readiness) | No health probes on live API |
| D19 | API Container App | `maxReplicas` | **10** | **5** | Live allows more replicas than Bicep specifies |
| D20 | Web Container App | probes | **TCP** probes (port 3000) | **HTTP** probes (`/` path) | Live uses TCP socket checks, Bicep uses HTTP path checks |
| D21 | Web Container App | `maxReplicas` | **10** | **5** | Same as API |
| D22 | CMS Container App | identity | **`None`** | `SystemAssigned` | Live CMS has no managed identity — uses ACR admin credentials instead of MI |
| D23 | CMS Container App | ACR registry | Admin credentials (`passwordSecretRef`) | Managed identity (`identity: 'system'`) | Live CMS pulls via ACR admin creds (less secure) |
| D24 | CMS Container App | secrets | 8 secrets (direct values) | 3 secrets (KV references) | Live has more secrets, stored directly not via KV |
| D25 | CMS Container App | env vars | Full set including storage vars | Partial set (missing storage, JWT, transfer token) | Bicep CMS missing several env vars that live has |
| D26 | Metric Alerts | count | **0 alerts** | 4 alerts defined | No metric alerts deployed despite Bicep defining them |
| D27 | Log Analytics / App Insights | tags | `null` / `{}` | `{project, environment, managedBy}` | No tags |
| D28 | Stale MySQL | `mysql-aipatterns-cms-test` | Exists in live | Not in Bicep | Orphaned test MySQL server in production RG |
| D29 | KV diagnostic settings | count | **0** | Not in Bicep (new finding) | No audit logging on Key Vault |
| D30 | Resource locks | count | **0** | Not in Bicep (new finding) | No deletion protection on any resource |

### Root Cause
Live was provisioned via scripts/portal, then Bicep was written as the target state (Phase 6.8) but **never fully applied** to the live environment. Some drift items (D4, D10) mean the Bicep cannot be naively redeployed without parameter fixes first.

---

## IMPLEMENTATION PLAN

### Track 1: Fix Bicep to Match Live Reality (Prerequisite)

Before applying any hardening, the Bicep must accurately reflect live state to avoid destructive drift on redeploy.

**Files:** `infrastructure/modules/containerApps.bicep`, `infrastructure/modules/sql.bicep`, `infrastructure/modules/cms.bicep`

| Fix | File | Change |
|-----|------|--------|
| D4 | sql.bicep:20 | Change `var sqlAdminLogin = 'sqladmin'` → `'aipatterns-admin'` |
| D6 | sql.bicep:62 | Change `maxSizeBytes: 34359738368` → `1073741824` (match live 1 GB) |
| D10 | cms.bicep:20 | Change `var mysqlAdminLogin = 'mysqladmin'` → `'strapiAdmin'` |
| D8 | cms.bicep:5 | Storage location param: add `storageLocation` param defaulting to `'centralus'` (live reality) |
| D25 | containerApps.bicep:394-435 | Add missing CMS env vars: `API_TOKEN_SALT`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET`, `AZURE_STORAGE_ACCOUNT`, `AZURE_STORAGE_ACCOUNT_KEY`, `AZURE_STORAGE_CONTAINER`, `AZURE_STORAGE_URL`, `PUBLIC_URL` (with corresponding KV secret refs) |
| D19/D21 | containerApps.bicep:177,325 | Change `maxReplicas: 5` → `10` on API and Web to match live |

### Track 2: Security Fixes to Apply to Live (via Azure CLI or Bicep redeploy)

**High priority — these are actual security gaps in production:**

| Fix | Resource | Action |
|-----|----------|--------|
| D7 | Storage Account | `az storage account update --name staipatternsmedia -g rg-aipatterns-prod --min-tls-version TLS1_2` |
| D1 | Key Vault | Migrate from access policy → RBAC mode (requires careful cutover — existing access policies must be replaced with role assignments first) |
| D2 | Key Vault | Enable purge protection: `az keyvault update --name kv-aipatterns-0754755 -g rg-aipatterns-prod --enable-purge-protection` |
| D18 | API Container App | Add HTTP health probes (via `az containerapp update` or Bicep redeploy) |
| D22/D23 | CMS Container App | Enable system-assigned managed identity and switch from ACR admin to MI-based pull |

### Track 3: IaC Hardening (New Additions to Bicep)

These improve the Bicep and can be applied on next redeploy:

| Item | File | Change |
|------|------|--------|
| Resource locks | keyvault.bicep, sql.bicep, cms.bicep | Add `CanNotDelete` locks on KV, SQL Server, MySQL, Storage |
| KV diagnostics | keyvault.bicep + main.bicep | Add `logAnalyticsId` param + `AuditEvent` diagnostic settings |
| SQL backup policy | sql.bicep | Add explicit `backupShortTermRetentionPolicies` (7 days) |
| MySQL SSL | cms.bicep | Add `require_secure_transport = ON` configuration resource |
| MySQL backup | cms.bicep:41 | Change `backupRetentionDays: 7` → `14` |

### Track 4: Tags + Cleanup

| Item | Action |
|------|--------|
| D28 | Delete orphaned `mysql-aipatterns-cms-test` server: `az mysql flexible-server delete --name mysql-aipatterns-cms-test -g rg-aipatterns-prod --yes` |
| D3-D5, D9, D12-D14, D27 | Apply tags via `az tag update` on all resources, or fix via Bicep redeploy |
| D26 | Deploy the 4 metric alerts defined in monitoring.bicep (need `alertEmail` param) |

### Track 5: Documentation + Decision Log

| Item | File | Change |
|------|------|--------|
| Fix admin user doc | deployment/scripts/provision-cms.ps1:32 | Keep as `"strapiAdmin"` (live is correct, Bicep was wrong) |
| Decision 63 | documentation/decisions/TECHNICAL_DECISIONS_LOG.md | Log drift findings, fixes, and hardening additions |
| Community files | `.github/CODEOWNERS`, `.github/SECURITY.md` | Create both |

### Track 6: Alert Email

| Item | File | Change |
|------|------|--------|
| Add alertEmail | infrastructure/main.parameters.prod.json | Add `"alertEmail": { "value": "sandropetterle@hotmail.com" }` |

---

## Implementation Order

1. **Track 1** — Fix Bicep to match live (prevent destructive drift)
2. **Track 2** — Apply critical security fixes to live (TLS 1.2, KV RBAC, purge protection, probes)
3. **Track 3** — Add IaC hardening to Bicep (locks, diagnostics, backup policies)
4. **Track 4** — Tags + cleanup
5. **Track 5** — Documentation + decision log
6. **Track 6** — Alert email (after user provides address)

---

## Verification

```bash
# 1. Validate Bicep compiles
az bicep build --file infrastructure/main.bicep

# 2. What-if to preview changes (no destructive action)
az deployment group what-if --resource-group rg-aipatterns-prod \
  --template-file infrastructure/main.bicep \
  --parameters @infrastructure/main.parameters.prod.json

# 3. Verify TLS fix
az storage account show --name staipatternsmedia -g rg-aipatterns-prod --query minimumTlsVersion

# 4. Verify KV purge protection
az keyvault show --name kv-aipatterns-0754755 -g rg-aipatterns-prod --query properties.enablePurgeProtection
```

---

## NOT in Scope (Accepted Risks)
- SQL/MySQL public network access (VNet not justified — accepted risk from Phase 7.5)
- Public blob storage (intentional for media)
- HTTP transport in Container Apps (TLS at edge)
- ACR Basic tier (upgrade deferred)
- Container image signing, SBOM, container scanning (Phase 8+)
- Full Bicep redeploy (too risky without careful incremental approach)
