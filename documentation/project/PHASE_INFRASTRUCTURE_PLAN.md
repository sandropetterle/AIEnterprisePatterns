# Phase 6.8: Infrastructure as Code & Management

**Status:** 🔜 Next
**Date:** 2026-03-17
**Dependencies:** Phase 6.7 complete

## Context

The project is deployed and running on Azure Container Apps but infrastructure provisioning is entirely imperative (PowerShell scripts). This means no drift detection, no CI validation, no what-if previews, and a messy `deployment/` folder full of redundant scripts and plaintext credential files on disk. The `AIEnterprisePatterns.Infrastructure` .NET project is completely empty — cross-cutting service registrations live directly in `Program.cs`. There is no documentation describing the infrastructure management approach.

This phase addresses all of that at enterprise quality: declarative Bicep IaC, clean .NET Infrastructure layer, consolidated deployment scripts, and complete operations documentation.

Phase 6.8 fits between Phase 6.7 (CMS tests & docs, complete) and Phase 7 (community features, planned) — infrastructure hardening before major feature development resumes.

---

## Track 1 — Security Cleanup (15 min, no risk)

These 3 files exist on disk, are NOT tracked by git (confirmed with `git ls-files`), but contain live credentials. Delete them from disk:

- `deployment/sql-credentials.txt` — SQL admin password, ACR credentials
- `deployment/github-secrets-values.txt` — Azure client/tenant/subscription IDs
- `deployment/DEPLOYMENT_SUMMARY.txt` — SQL admin password + ACR password

No git history cleanup needed. Credentials are already in Key Vault.

---

## Track 2 — Script Consolidation (20 min)

**Delete these files** — they are either superseded, one-time historical fixes, or redundant. Git history preserves them if ever needed:

| File | Reason for deletion |
|------|---------------------|
| `azure-setup.ps1` | Legacy App Services approach, fully superseded by Container Apps + Bicep |
| `add-environment-cred.ps1` | One-time OIDC fix; problem resolved, not reusable |
| `fix-creds.ps1` | One-time OIDC fix; problem resolved, not reusable |
| `fix-federated-credential.ps1` | One-time OIDC fix; problem resolved, not reusable |
| `setup-github-secrets.ps1` | Redundant; superseded by the fixed variant |
| `setup-github-secrets-simple.ps1` | Redundant; superseded by the fixed variant |
| `azure-container-apps-setup.ps1` | Superseded by Bicep; `infrastructure/deploy.ps1` replaces it |

**Rename** `setup-github-secrets-fixed.ps1` → `setup-github-oidc.ps1` (canonical OIDC script — this is the one to keep).

**Update** `deployment/github-secrets-setup.md` to reference the new `setup-github-oidc.ps1` name and note that all other setup scripts have been removed (replaced by Bicep).

**Keep** as canonical active scripts:
- `setup-github-oidc.ps1` (renamed) — one-time OIDC federated identity setup
- `configure-acr-access.ps1` — one-time managed identity ACR access setup
- `azure-cleanup.ps1` — full teardown (kept for disaster recovery)
- `scripts/provision-cms.ps1` — CMS-specific provisioning (MySQL + Blob Storage)
- `scripts/configure-alerts.ps1` — Application Insights alert setup
- `scripts/create-monitoring-dashboard.ps1` — dashboard creation

---

## Track 3 — Bicep IaC (3–5 hours, main work)

### Directory structure

```
infrastructure/
  main.bicep                          # Orchestrator — calls all modules
  main.parameters.prod.json           # Production values (KV references for secrets)
  deploy.ps1                          # PowerShell: az bicep build + what-if + create
  README.md                           # Prerequisites, validate, deploy, warnings
  modules/
    containerAppsEnvironment.bicep    # Log Analytics + Container Apps Environment
    containerApps.bicep               # All 3 Container Apps (api, web, cms)
    sql.bicep                         # Azure SQL Serverless
    acr.bicep                         # Azure Container Registry
    keyvault.bicep                    # Key Vault (no secrets stored in Bicep)
    monitoring.bicep                  # Application Insights + 4 metric alerts
    cms.bicep                         # MySQL Flexible Server + Blob Storage
```

### Module responsibilities

**`monitoring.bicep`** — `appi-aipatterns-prod` (AppInsights linked to Log Analytics) + 4 `microsoft.insights/metricalerts` (error rate, response time, availability, exception spike). No dependencies. Outputs: `logAnalyticsId`, `appInsightsConnectionString`.

**`acr.bicep`** — `craipatternssp54426` (Basic, admin disabled). No dependencies. Outputs: `acrLoginServer`, `acrResourceId`.

**`keyvault.bicep`** — `kv-aipatterns-0754755` (Standard, RBAC mode). Grants `Key Vault Secrets User` role to backend Container App managed identity (passed as param). Secrets NOT set in Bicep — set via `az keyvault secret set` in `deploy.ps1` post-step. Outputs: `kvName`.

**`sql.bicep`** — `sql-aipatterns-sandr-1770754196` + `sqldb-aipatterns-prod` (Serverless GP_S_Gen5_1, auto-pause 15 min, local backup). Firewall: Azure services rule only (developer IPs set manually). Outputs: `sqlFqdn`.

**`cms.bicep`** — `mysql-aipatterns-cms` (francecentral, B_Standard_B1ms, 20 GiB) + `strapi_cms` database + `staipatternsmedia` storage account + `strapi-media` blob container (public blob read). Outputs: `mysqlFqdn`, `storageAccountName`.

**`containerAppsEnvironment.bicep`** — `cae-aipatterns-prod` (linked to Log Analytics workspace from monitoring module). Depends on monitoring. Outputs: `caeId`.

**`containerApps.bicep`** — All 3 Container Apps:
- `ca-aipatterns-api-prod`: port 8080, 0–5 replicas, 0.5 CPU/1 GiB, env vars via KV secret references
- `ca-aipatterns-web-prod`: port 3000, 0–5 replicas, 0.5 CPU/1 GiB
- `ca-aipatterns-cms-prod`: port 1337, 0–2 replicas, 0.25 CPU/0.5 GiB
- All: system-assigned managed identity, registry pull via managed identity (no admin password)
- **Image tags**: set to a stable placeholder on first deploy only. CI/CD manages tags via `az containerapp update --image`. Bicep does NOT overwrite image tags on subsequent deploys (`--mode Incremental`).

### `main.bicep` orchestrator parameters
- `location` (default: `'centralus'`)
- `environment` (default: `'prod'`)
- `sqlAdminPassword` — `@secure()`
- `mysqlAdminPassword` — `@secure()`

### `main.parameters.prod.json`
Uses Key Vault references for `sqlAdminPassword` and `mysqlAdminPassword` — no plaintext in the file.

### `deploy.ps1`
```powershell
# 1. Validate: az bicep build --file infrastructure/main.bicep
# 2. What-if:  az deployment group what-if (show changes before applying)
# 3. Confirm interactively
# 4. Deploy:   az deployment group create --mode Incremental
# CRITICAL: always --mode Incremental (Complete would delete unmanaged resources)
```

### `infrastructure/README.md`
Cover: prerequisites (Azure CLI + `az bicep install`), validate locally, what-if pattern, deploy, Incremental vs Complete warning, image tag separation from IaC, pointer to `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md`.

### CI validation
Add `validate-infrastructure` job to `.github/workflows/test.yml` (parallel to `backend-tests`/`frontend-tests`):
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
No Azure credentials needed — `az bicep build` is a local compile step.

Also add `validate-infrastructure` to the `test-summary` job's `needs` array so it gates the green checkmark.

---

## Track 4 — Infrastructure .NET Project (1–2 hours)

### What moves to `AddInfrastructure()`

From `Program.cs` lines 17–197, extract these 5 registrations into `InfrastructureServiceCollectionExtensions.cs`:

| Lines | Concern | Moves? |
|-------|---------|--------|
| 18–23 | `AddApplicationInsightsTelemetry()` | ✅ Yes |
| 127 | `AddMemoryCache()` | ✅ Yes |
| 128 | `AddSingleton(TimeProvider.System)` | ✅ Yes |
| 162–163 | `AddHealthChecks().AddDbContextCheck<>()` | ✅ Yes |
| 166–197 | `AddRateLimiter()` with 3 policies | ✅ Yes |

**Stays in Program.cs** (composition-root decisions):
- `AddDbContext<>()` — SQLite vs SQL Server branching logic
- `AddCors()` — reads multiple config keys with branching
- `AddAuthentication/AddJwtBearer()` — guard clause on `authAuthority`
- `AddAuthorizationBuilder()` — domain policy definitions
- `AddControllers()`, Swagger, API Versioning, FluentValidation — API presentation layer
- `AddScoped<IPatternService>()` etc. — domain service wiring

### Project changes required

**`AIEnterprisePatterns.Infrastructure.csproj`** — add:
```xml
<ProjectReference Include="..\AIEnterprisePatterns.Data\AIEnterprisePatterns.Data.csproj" />
<PackageReference Include="Microsoft.ApplicationInsights.AspNetCore" Version="2.22.0" />
<PackageReference Include="Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore" Version="8.0.0" />
```
(Rate limiting is in `Microsoft.AspNetCore.App` — no extra package needed)

**`AIEnterprisePatterns.Api.csproj`** — add:
```xml
<ProjectReference Include="..\AIEnterprisePatterns.Infrastructure\AIEnterprisePatterns.Infrastructure.csproj" />
```

**New file**: `backend/src/AIEnterprisePatterns.Infrastructure/InfrastructureServiceCollectionExtensions.cs`

Namespace: `AIEnterprisePatterns.Infrastructure`
Method: `public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)`

Registers AppInsights, MemoryCache, TimeProvider.System, HealthChecks+DbContextCheck, and RateLimiter with all 3 policies (exact values preserved from Program.cs).

**`Program.cs`** call site — replace extracted blocks with:
```csharp
builder.Services.AddInfrastructure(builder.Configuration);
```

### Test safety
The 105 backend integration tests use `WebApplicationFactory<Program>` with `ConfigureServices` overrides. Identical registrations, different source location. `AddDbContextCheck<ApplicationDbContext>()` already works in tests today — moving it to Infrastructure is safe.

---

## Track 5 — Documentation (1 hour)

### New: `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md`
Sections:
1. Overview (Bicep + Container Apps + resource inventory table)
2. Directory Structure (`infrastructure/` tree with descriptions)
3. Environment Strategy (prod-only today; how to add staging via parameter files)
4. Deploying Infrastructure Changes (prerequisites, validate, what-if, deploy, warnings)
5. CI Validation (`validate-infrastructure` job description)
6. Secrets Management (Key Vault → Container App secret refs → IConfiguration flow)
7. Script Inventory (canonical active scripts; legacy scripts deleted in this phase)
8. Adding a New Resource (step-by-step Bicep workflow)

### Update: `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`
Prepend Decision 50:
- **Date**: 2026-03-17
- **Title**: Adopt Azure Bicep for Declarative IaC
- **Category**: Infrastructure
- Rationale: drift detection, what-if, CI validation, readable vs ARM JSON
- Alternatives: Terraform (state complexity), ARM JSON (verbose), keep PowerShell (no validation/drift)
- Covers both Bicep adoption and `AddInfrastructure()` .NET cleanup

### Update: `documentation/project/ROADMAP.md`
- Mark Phase 6.7 as ✅ Complete (2026-03-04)
- Add Phase 6.8 row as 🔜 Next with link to this plan

### Update: `DOCUMENTATION_INDEX.md`
Add row for `INFRASTRUCTURE_MANAGEMENT.md` in the operations section.

### Update: `CLAUDE.md`
Update phase reference to "Phase 6.8 next".

---

## Critical Files

| File | Action |
|------|--------|
| `deployment/sql-credentials.txt` | Delete from disk |
| `deployment/github-secrets-values.txt` | Delete from disk |
| `deployment/DEPLOYMENT_SUMMARY.txt` | Delete from disk |
| `deployment/azure-setup.ps1` + 6 others (incl. `azure-container-apps-setup.ps1`) | Delete permanently |
| `deployment/setup-github-secrets-fixed.ps1` | Rename to `setup-github-oidc.ps1` |
| `infrastructure/` (new directory) | Create with 7 modules + main + params + deploy script + README |
| `.github/workflows/test.yml` | Add `validate-infrastructure` job |
| `backend/src/AIEnterprisePatterns.Infrastructure/AIEnterprisePatterns.Infrastructure.csproj` | Add Data ref + NuGet packages |
| `backend/src/AIEnterprisePatterns.Infrastructure/InfrastructureServiceCollectionExtensions.cs` | Create with `AddInfrastructure()` |
| `backend/src/AIEnterprisePatterns.Api/AIEnterprisePatterns.Api.csproj` | Add Infrastructure project ref |
| `backend/src/AIEnterprisePatterns.Api/Program.cs` | Replace 5 blocks with `AddInfrastructure()` call |
| `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md` | Create |
| `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` | Prepend Decision 50 |
| `documentation/project/ROADMAP.md` | Add Phase 6.8 row |
| `DOCUMENTATION_INDEX.md` | Add operations row |
| `CLAUDE.md` | Update phase reference |

---

## Verification

### After Track 1 (Security)
1. `git ls-files deployment/sql-credentials.txt deployment/github-secrets-values.txt deployment/DEPLOYMENT_SUMMARY.txt` — empty output (never tracked)
2. `ls deployment/*.txt` — returns nothing

### After Track 2 (Script Consolidation)
3. `ls deployment/` — only canonical scripts remain: `setup-github-oidc.ps1`, `configure-acr-access.ps1`, `azure-cleanup.ps1`, `database-migration.md`, `github-secrets-setup.md`, `CONTAINER_APPS_GUIDE.md`, `COST_ANALYSIS.md`, `README.md`, `scripts/`
4. `git log --oneline -5` — confirm clean commit with all deletions together

### After Track 3 (Bicep)
5. `az bicep build --file infrastructure/main.bicep` — exits 0 (no Azure login needed)
6. Validate each module individually:
   - `az bicep build --file infrastructure/modules/monitoring.bicep`
   - `az bicep build --file infrastructure/modules/acr.bicep`
   - `az bicep build --file infrastructure/modules/keyvault.bicep`
   - `az bicep build --file infrastructure/modules/sql.bicep`
   - `az bicep build --file infrastructure/modules/cms.bicep`
   - `az bicep build --file infrastructure/modules/containerAppsEnvironment.bicep`
   - `az bicep build --file infrastructure/modules/containerApps.bicep`
7. `az deployment group what-if --resource-group rg-aipatterns-prod ...` — every existing resource shows **"no change"**
8. `grep -r "password\|Password\|secret\|Secret" infrastructure/ --include="*.json"` — only Key Vault reference objects, no literal values

### After Track 4 (Infrastructure .NET Project)
9. `dotnet build` (backend/) — zero errors
10. `dotnet test` (backend/) — 105/105 pass
11. `Program.cs` no longer contains direct calls to `AddApplicationInsightsTelemetry`, `AddMemoryCache`, `AddRateLimiter`, `AddHealthChecks`, `AddSingleton(TimeProvider.System)`
12. `curl http://localhost:5255/health` → `Healthy`

### After Track 5 (Documentation)
13. `npm test` — 390/390 pass
14. All markdown links in `INFRASTRUCTURE_MANAGEMENT.md` resolve to existing files
15. Decision count in `TECHNICAL_DECISIONS_LOG.md` header reflects 50 decisions

### CI Validation (end-to-end)
16. Push branch — `validate-infrastructure` CI job passes in ~2 min
17. `test-summary` requires all 4 jobs (backend, frontend, validate-infrastructure, e2e) — all green
18. Merge to main — production URLs confirm no regressions:
    - `https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health` → `Healthy`
    - `https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io` → serves Next.js content
