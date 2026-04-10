# Infrastructure Management

**Last Updated:** 2026-04-10
**Audience:** DevOps, Infrastructure Engineers, Solutions Architects
**Purpose:** Single source of truth for Azure infrastructure management — how it's structured, how to deploy changes, and how secrets flow from Key Vault to application configuration.

---

## 1. Overview

All Azure infrastructure for AI Enterprise Patterns is managed declaratively using **Azure Bicep** (IaC). The Bicep templates in `infrastructure/` describe the complete desired state of `rg-aipatterns-prod`.

### Resource Inventory

| Resource | Type | Name | Region |
|----------|------|------|--------|
| Container Apps Environment | Microsoft.App/managedEnvironments | cae-aipatterns-prod | centralus |
| API Container App | Microsoft.App/containerApps | ca-aipatterns-api-prod | centralus |
| Web Container App | Microsoft.App/containerApps | ca-aipatterns-web-prod | centralus |
| Container Registry | Microsoft.ContainerRegistry/registries | craipatternssp54426 | centralus |
| Azure SQL Server | Microsoft.Sql/servers | sql-aipatterns-sandr-1770754196 | centralus |
| Azure SQL Database | Microsoft.Sql/servers/databases | sqldb-aipatterns-prod | centralus |
| Key Vault | Microsoft.KeyVault/vaults | kv-aipatterns-0754755 | centralus |
| Application Insights | Microsoft.Insights/components | appi-aipatterns-prod | centralus |
| Log Analytics Workspace | Microsoft.OperationalInsights/workspaces | log-aipatterns-prod | centralus |
| Blob Storage Account | Microsoft.Storage/storageAccounts | staipatternsmedia | centralus |

> **Note:** CMS resources removed in Phase CMS Cold Storage (2026-04-10) — `ca-aipatterns-cms-prod` (Strapi Container App) and `mysql-aipatterns-cms` (MySQL Flexible Server) deleted. See [Decision 64](../decisions/TECHNICAL_DECISIONS_LOG.md). `staipatternsmedia` is retained for historical media references.

---

## 2. Directory Structure

```
infrastructure/
  main.bicep                        # Orchestrator — calls all modules in dependency order
  main.parameters.prod.json         # Production values (Key Vault references, no plaintext)
  deploy.ps1                        # validate → what-if → confirm → deploy
  README.md                         # Quick-start for engineers
  modules/
    monitoring.bicep                # Log Analytics + Application Insights + 4 metric alerts
    acr.bicep                       # Azure Container Registry (Basic, admin disabled)
    keyvault.bicep                  # Key Vault (Standard, RBAC mode)
    sql.bicep                       # Azure SQL Serverless (GP_S_Gen5_1, auto-pause 15 min)
    containerAppsEnvironment.bicep  # Container Apps Environment linked to Log Analytics
    containerApps.bicep             # API + Web Container Apps with managed identity + ACR pull
```

---

## 3. Environment Strategy

Currently **production-only**. All resources deploy to `rg-aipatterns-prod` in `centralus` (MySQL in `francecentral`).

To add a staging environment:

1. Copy `main.parameters.prod.json` → `main.parameters.staging.json`
2. Change the `environment` parameter value to `staging`
3. Create a new resource group: `az group create --name rg-aipatterns-staging --location centralus`
4. Deploy: `az deployment group create --resource-group rg-aipatterns-staging --template-file infrastructure/main.bicep --parameters @infrastructure/main.parameters.staging.json --mode Incremental`

Resource names in modules use the `environment` parameter as a suffix, so staging resources will be named distinctly (e.g. `cae-aipatterns-staging`).

---

## 4. Deploying Infrastructure Changes

### Prerequisites

```powershell
az login
az account set --subscription <subscription-id>
az bicep install   # one-time
```

### Validate Locally

```bash
az bicep build --file infrastructure/main.bicep
```

No Azure login needed — this is a local compile step. CI runs this on every PR.

### What-If Preview

```powershell
az deployment group what-if \
  --resource-group rg-aipatterns-prod \
  --template-file infrastructure/main.bicep \
  --parameters @infrastructure/main.parameters.prod.json \
  --mode Incremental
```

For existing infrastructure, every resource should show **"no change"** unless you've modified a module.

### Deploy

```powershell
# Interactive: validate → what-if → confirm → deploy
./infrastructure/deploy.ps1

# What-if only (no deploy prompt)
./infrastructure/deploy.ps1 -WhatIf
```

### ⚠️ Incremental Mode — Critical Warning

**Always use `--mode Incremental`.** The deploy script enforces this.

`--mode Complete` deletes any resource in `rg-aipatterns-prod` that is not defined in the Bicep template. This is destructive and irreversible.

---

## 5. CI Validation

The `validate-infrastructure` job in `.github/workflows/test.yml` runs on every push and pull request:

```yaml
validate-infrastructure:
  name: Validate Bicep Templates
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Install Azure CLI + Bicep
      run: |
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        az bicep install
    - name: Validate Bicep templates
      run: az bicep build --file infrastructure/main.bicep
```

No Azure credentials are needed — `az bicep build` is a local compile step. The `test-summary` job requires all three jobs (`backend-tests`, `frontend-tests`, `validate-infrastructure`) to pass before gating the green checkmark.

---

## 6. Secrets Management

Secrets are never stored in Bicep templates, parameter files, or source control. The flow is:

```
Key Vault secrets (set once via az keyvault secret set)
  → Container App secret references (keyVaultUrl + identity: 'system')
    → IConfiguration values (ASP.NET Core reads env vars with __ → : mapping)
```

### Key Vault Secrets Inventory

| Secret Name | Used By | Description |
|-------------|---------|-------------|
| `sql-connection-string` | ca-aipatterns-api-prod | Azure SQL connection string |
| `sql-admin-password` | Bicep parameter reference | SQL Server admin password (for deploy only) |
| `auth-authority` | ca-aipatterns-api-prod | Azure Entra External ID OIDC authority URL |
| `auth-audience` | ca-aipatterns-api-prod | API app registration audience |
| `auth-secret` | ca-aipatterns-web-prod | Auth.js session signing secret |
| `auth-entra-client-secret` | ca-aipatterns-web-prod | Entra frontend app client secret |
| `appinsights-connection-string` | ca-aipatterns-api-prod | Application Insights connection string (recommended over InstrumentationKey) |

> **CMS secrets removed (Phase CMS Cold Storage, 2026-04-10):** `strapi-app-keys`, `strapi-admin-jwt-secret`, `mysql-admin-password`, `strapi-api-token-salt`, `strapi-transfer-token-salt`, `strapi-jwt-secret`, `strapi-storage-account-key`, `strapi-api-token` — all deleted and purged from Key Vault.

### Setting Secrets

```powershell
az keyvault secret set \
  --vault-name kv-aipatterns-0754755 \
  --name sql-connection-string \
  --value "Server=sql-aipatterns-sandr-1770754196.database.windows.net;Database=sqldb-aipatterns-prod;..."
```

### Role Assignment

Each Container App uses system-assigned managed identity. `main.bicep` assigns the `Key Vault Secrets User` role to the API and Web apps after they are provisioned.

---

## 7. Script Inventory

### Active Scripts

| Script | Location | Purpose | Run |
|--------|----------|---------|-----|
| `deploy.ps1` | `infrastructure/` | Validate + what-if + deploy Bicep | Per infrastructure change |
| `setup-github-oidc.ps1` | `deployment/` | One-time OIDC federated identity setup for GitHub Actions | One-time per repo |
| `configure-acr-access.ps1` | `deployment/` | One-time managed identity ACR access setup | One-time |
| `azure-cleanup.ps1` | `deployment/` | Full resource group teardown (disaster recovery) | Emergency only |
| `provision-cms.ps1` | `deployment/scripts/` | CMS provisioning (MySQL + Blob Storage) — retained for historical reference / rollback only | CMS rollback only |
| `configure-alerts.ps1` | `deployment/scripts/` | Application Insights alert setup | Per alert change |
| `create-monitoring-dashboard.ps1` | `deployment/scripts/` | Dashboard creation | Per dashboard change |

### Removed Scripts (Phase 6.8)

The following scripts were deleted in Phase 6.8 — they are preserved in git history if ever needed:

| Script | Reason |
|--------|--------|
| `azure-setup.ps1` | Legacy App Services approach; superseded by Container Apps + Bicep |
| `azure-container-apps-setup.ps1` | Superseded by Bicep IaC |
| `add-environment-cred.ps1` | One-time OIDC fix; resolved |
| `fix-creds.ps1` | One-time OIDC fix; resolved |
| `fix-federated-credential.ps1` | One-time OIDC fix; resolved |
| `setup-github-secrets.ps1` | Redundant; superseded by `setup-github-oidc.ps1` |
| `setup-github-secrets-simple.ps1` | Redundant; superseded by `setup-github-oidc.ps1` |

---

## 8. Adding a New Resource

1. **Identify the module** — does it belong in an existing module (e.g. a new alert goes in `monitoring.bicep`) or needs a new one?
2. **Add the Bicep resource** — use the appropriate API version and properties
3. **Add outputs** if downstream modules need to reference it
4. **Wire in `main.bicep`** — add module call or resource, handle dependencies
5. **Validate**: `az bicep build --file infrastructure/main.bicep`
6. **Preview**: `./infrastructure/deploy.ps1 -WhatIf` — confirm the what-if output shows only the new resource as "create"
7. **Deploy**: `./infrastructure/deploy.ps1`
8. **Update this document** — add the resource to the Resource Inventory table in Section 1

---

## 9. Infrastructure Hardening (Phase 7.11)

Phase 7.11 (2026-03-23) resolved 30 live-vs-Bicep drift items and added new hardening to the IaC. Key changes applied to the Bicep modules:

| Module | Change |
|--------|--------|
| `sql.bicep` | Admin login corrected to `aipatterns-admin` (matches live); DB size 32 GB → 1 GB; backup retention policy (7 days); `CanNotDelete` resource lock |
| `cms.bicep` | Admin login corrected to `strapiAdmin`; `storageLocation` param (centralus); `autoGrow: Disabled`; backup retention 7 → 14 days; MySQL SSL (`require_secure_transport = ON`); `CanNotDelete` locks on MySQL + Storage |
| `keyvault.bicep` | `AuditEvent` diagnostic settings to Log Analytics; `CanNotDelete` resource lock |
| `containerApps.bicep` | `maxReplicas` 5 → 10 (API + Web); CMS `DATABASE_USERNAME` corrected; 7 new CMS secrets via KV references; 8 new CMS env vars (`API_TOKEN_SALT`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET`, `AZURE_STORAGE_*`, `PUBLIC_URL`) |
| `main.bicep` | Key Vault now depends on monitoring module (for Log Analytics ID) |
| `main.parameters.prod.json` | `alertEmail` added — activates alert action group email notifications |

**Operational steps still required (not automatable in Bicep):**
- Apply Storage Account TLS 1.2 to live: `az storage account update --name staipatternsmedia -g rg-aipatterns-prod --min-tls-version TLS1_2`
- Apply resource tags to live (applied on next Bicep redeploy with `--mode Incremental`)

> **Completed (2026-04-10, Phase CMS Cold Storage Phase 4):** `mysql-aipatterns-cms` and `ca-aipatterns-cms-prod` deleted. Orphaned test MySQL server (`mysql-aipatterns-cms-test`) was already removed. 8 CMS KV secrets deleted and purged. Bicep IaC cleanup pending in Phase 5.

See [Decision 63](../decisions/TECHNICAL_DECISIONS_LOG.md) for full rationale and accepted risks.

---

## References

- [Azure Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview)
- [Container Apps Environment Bicep reference](https://learn.microsoft.com/azure/templates/microsoft.app/managedenvironments)
- [Key Vault secret references in Container Apps](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [`infrastructure/README.md`](../../infrastructure/README.md) — quick-start for engineers
- [`deployment/github-secrets-setup.md`](../../deployment/github-secrets-setup.md) — OIDC setup for GitHub Actions
- [`documentation/operations/AUTH_SETUP_GUIDE.md`](AUTH_SETUP_GUIDE.md) — Entra External ID configuration
- [`documentation/operations/MONITORING_GUIDE.md`](MONITORING_GUIDE.md) — alert thresholds and dashboards
