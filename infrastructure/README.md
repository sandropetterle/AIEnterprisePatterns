# Infrastructure as Code — AI Enterprise Patterns

Declarative Bicep templates for all Azure resources. Managed via [Azure Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview) with CI validation on every pull request.

---

## Prerequisites

```bash
# Install Azure CLI
winget install Microsoft.AzureCLI

# Install Bicep extension
az bicep install

# Log in and set subscription
az login
az account set --subscription <your-subscription-id>
```

---

## Directory Structure

```
infrastructure/
  main.bicep                        # Orchestrator — calls all modules in dependency order
  main.parameters.prod.json         # Production parameter values (KV references for secrets)
  deploy.ps1                        # Validate → what-if → confirm → deploy
  README.md                         # This file
  modules/
    monitoring.bicep                # Log Analytics + Application Insights + 4 metric alerts
    acr.bicep                       # Azure Container Registry (Basic, admin disabled)
    keyvault.bicep                  # Key Vault (Standard, RBAC mode)
    sql.bicep                       # Azure SQL Serverless (GP_S_Gen5_1)
    cms.bicep                       # MySQL Flexible Server + Blob Storage (francecentral)
    containerAppsEnvironment.bicep  # Container Apps Environment (linked to Log Analytics)
    containerApps.bicep             # All 3 Container Apps (api, web, cms)
```

---

## One-Time Setup

Update `main.parameters.prod.json` to replace `__SUBSCRIPTION_ID__` with your actual Azure subscription ID:

```powershell
$subId = az account show --query id --output tsv
(Get-Content infrastructure/main.parameters.prod.json) -replace '__SUBSCRIPTION_ID__', $subId |
    Set-Content infrastructure/main.parameters.prod.json
```

---

## Validate Locally

```bash
# Validate main template (and all modules it references)
az bicep build --file infrastructure/main.bicep

# Validate a specific module
az bicep build --file infrastructure/modules/monitoring.bicep
```

No Azure login needed — `az bicep build` is a local compile step. This is what the CI `validate-infrastructure` job runs.

---

## What-If Preview

Show exactly what Azure would change before applying — no resources are created or modified:

```powershell
az deployment group what-if \
  --resource-group rg-aipatterns-prod \
  --template-file infrastructure/main.bicep \
  --parameters @infrastructure/main.parameters.prod.json \
  --mode Incremental
```

For existing infrastructure, every resource should show **"no change"** unless you've modified a module.

---

## Deploy

```powershell
# Interactive: validate → what-if → confirm → deploy
./infrastructure/deploy.ps1

# What-if only (no deploy prompt)
./infrastructure/deploy.ps1 -WhatIf
```

---

## ⚠️ Incremental Mode Warning

**Always use `--mode Incremental`.** The deploy script enforces this.

`--mode Complete` would **delete any Azure resource in `rg-aipatterns-prod` that is not defined in this Bicep template**, including manually created resources, DNS records, and anything provisioned outside of IaC. This is destructive and irreversible.

---

## Image Tag Separation

Container App image tags are **not managed by Bicep**. CI/CD updates them via:

```bash
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --image craipatternssp54426.azurecr.io/aipatterns-api:<sha>
```

Bicep modules use stable placeholder images for first deploy only. Because deploy uses `--mode Incremental`, re-running the Bicep does not disrupt running Container Apps — unless you explicitly pass `apiImage`/`webImage`/`cmsImage` parameters.

---

## Secrets Management

Secrets are **never stored in Bicep or parameter files**. The flow is:

1. Key Vault is provisioned by `keyvault.bicep`
2. Secrets are set manually (one-time) via `az keyvault secret set`
3. Container Apps reference secrets from Key Vault via `keyVaultUrl` + `identity: 'system'`
4. ASP.NET Core reads them as `IConfiguration` values (env var naming: `__` → `:`)

**Required post-deploy secrets** (set before first container app deploy):

```bash
# SQL connection string (get from Azure Portal → SQL Database → Connection strings)
az keyvault secret set --vault-name kv-aipatterns-0754755 --name sql-connection-string --value "..."

# Application Insights connection string (get from Azure Portal → appi-aipatterns-prod → Overview → Connection String)
az keyvault secret set --vault-name kv-aipatterns-0754755 --name appinsights-connection-string --value "..."

# Auth secrets (see AUTH_SETUP_GUIDE.md for values)
az keyvault secret set --vault-name kv-aipatterns-0754755 --name auth-authority --value "..."
az keyvault secret set --vault-name kv-aipatterns-0754755 --name auth-audience --value "..."
az keyvault secret set --vault-name kv-aipatterns-0754755 --name auth-secret --value "..."
az keyvault secret set --vault-name kv-aipatterns-0754755 --name auth-entra-client-secret --value "..."

# CMS secrets
az keyvault secret set --vault-name kv-aipatterns-0754755 --name strapi-app-keys --value "..."
az keyvault secret set --vault-name kv-aipatterns-0754755 --name strapi-admin-jwt-secret --value "..."
az keyvault secret set --vault-name kv-aipatterns-0754755 --name mysql-admin-password --value "..."
```

See [`documentation/operations/INFRASTRUCTURE_MANAGEMENT.md`](../documentation/operations/INFRASTRUCTURE_MANAGEMENT.md) for the full secrets inventory.

---

## ACR Image Cleanup

ACR Basic SKU does not support automated purge policies. Clean up old image tags manually to avoid storage bloat:

```bash
# Keep the 5 most recent tags for the API image, delete the rest
az acr repository show-tags --name craipatternssp54426 --repository aipatterns-api --orderby time_asc --output tsv \
  | head -n -5 \
  | xargs -I {} az acr repository delete --name craipatternssp54426 --image aipatterns-api:{} --yes

# Repeat for the web and cms images
az acr repository show-tags --name craipatternssp54426 --repository aipatterns-web --orderby time_asc --output tsv \
  | head -n -5 \
  | xargs -I {} az acr repository delete --name craipatternssp54426 --image aipatterns-web:{} --yes

az acr repository show-tags --name craipatternssp54426 --repository aipatterns-cms --orderby time_asc --output tsv \
  | head -n -5 \
  | xargs -I {} az acr repository delete --name craipatternssp54426 --image aipatterns-cms:{} --yes
```

Run this cleanup periodically (e.g. monthly) or after major deploy cycles.

---

## Adding a New Resource

1. Create or edit the relevant module (or add a new `modules/foo.bicep`)
2. Add module call in `main.bicep` with appropriate dependencies
3. Run `az bicep build --file infrastructure/main.bicep` to validate locally
4. Run `deploy.ps1 -WhatIf` to preview the change
5. Review what-if output, then run `deploy.ps1` to apply

---

For full infrastructure management procedures, alerts, and runbooks, see [`documentation/operations/INFRASTRUCTURE_MANAGEMENT.md`](../documentation/operations/INFRASTRUCTURE_MANAGEMENT.md).
