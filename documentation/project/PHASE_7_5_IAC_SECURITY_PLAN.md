# Phase 7.5: Infrastructure as Code & Azure Security — Evaluation & Implementation Plan

**Created:** 2026-03-18
**Status:** Evaluated — ready for implementation
**Parent:** Phase 7 — Quality & Hardening (PHASE_QUALITY_HARDENING_PLAN.md)

---

## Context

Phase 6.8 established the Bicep IaC foundation: 7 modules, `deploy.ps1`, CI validation. Phase 7.5 audits these for Azure best practices, security gaps, and governance improvements.

**Overall assessment:** The IaC foundation is solid — RBAC-mode Key Vault, system-assigned managed identity on all Container Apps, admin-disabled ACR, secrets via Key Vault references, TLS 1.2 enforced, CI validation on every PR. Findings are hardening improvements, not critical vulnerabilities.

---

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | No resource tagging on any module | MEDIUM | Track 1 |
| 2 | Hardcoded resource names (not parameterized) | MEDIUM | Track 1 |
| 3 | Hardcoded `NEXT_PUBLIC_API_BASE_URL` in containerApps.bicep:198 | MEDIUM | Track 1 |
| 4 | No parameter validation decorators (`@minLength`, `@allowed`) | MEDIUM | Track 1 |
| 5 | No SQL diagnostic settings (no DB audit trail in Log Analytics) | MEDIUM | Track 2 |
| 6 | Alert action groups missing (alerts fire, nobody notified) | MEDIUM | Track 2 |
| 7 | Exception spike threshold too high (20 → should be 10) | MEDIUM | Track 2 |
| 8 | No Key Vault purge protection | MEDIUM | Track 3 |
| 9 | Soft delete only 7 days (too short for production) | MEDIUM | Track 3 |
| 10 | App Insights connection string passed as inline value (visible in ARM deploy history) | MEDIUM | Track 3 |

### Accepted Risks (LOW — document only)

| # | Finding | Rationale |
|---|---------|-----------|
| 11 | SQL/MySQL publicly accessible | Azure-services-only firewall. VNet requires Premium SKU — not justified for this project. |
| 12 | No VNet / network isolation | Requires Premium Container Apps Environment. Current firewall rules adequate. |
| 13 | Container Apps HTTP transport | Internal to CAE. Azure handles TLS at the edge. Correct architecture. |
| 14 | Public blob access for Strapi media | Intentional — media must be publicly accessible for frontend rendering. |
| 15 | MySQL HA disabled | Cost optimization. CMS is cached; downtime doesn't break the site. |
| 16 | 30-day Log Analytics retention | Adequate for project scope. |
| 17 | ACR Basic SKU (no vuln scanning) | Standard ($20/mo) would add scanning. Not justified at current scale. |
| 18 | Docker-compose hardcoded dev passwords | Dev-only local containers. Low risk. |

### Deferred to Other Phases

| Item | Phase | Rationale |
|------|-------|-----------|
| GitHub Actions SHA pinning | 7.6 (CI/CD) | CI pipeline concern |
| Production approval gates | 7.6 (CI/CD) | Workflow concern |
| Docker image SHA pinning | 7.7 (Docker) | Container concern |
| Secret rotation policy | 8+ | Operational process |
| VNet integration | 8+ | Cost justified only at enterprise scale |

---

## Track 1: Governance & Parameterization (Quick Win)

**Effort:** ~30 min | **Risk:** None — defaults match production

**Files to modify:**
- `infrastructure/main.bicep` — add `tags` variable, pass to all modules, add `@allowed`/`@minLength` decorators, add `apiBaseUrl` param
- `infrastructure/modules/acr.bicep` — `param acrName`, `param tags`
- `infrastructure/modules/keyvault.bicep` — `param kvName`, `param tags`
- `infrastructure/modules/sql.bicep` — `param sqlServerName`, `param tags`
- `infrastructure/modules/cms.bicep` — `param mysqlServerName`, `param storageAccountName`, `param tags`
- `infrastructure/modules/monitoring.bicep` — `param tags`
- `infrastructure/modules/containerAppsEnvironment.bicep` — `param tags`
- `infrastructure/modules/containerApps.bicep` — `param apiBaseUrl`, `param tags`

### 1a. Resource Tags
Add in `main.bicep`:
```bicep
var tags = {
  project: 'AIEnterprisePatterns'
  environment: environment
  managedBy: 'bicep'
}
```
Each module gets `param tags object` and applies `tags: tags` to every resource. All resource types in use support tags.

### 1b. Parameterize Hardcoded Names
Convert hardcoded `var` names to params with production defaults:
- `acr.bicep`: `param acrName string = 'craipatternssp54426'`
- `keyvault.bicep`: `param kvName string = 'kv-aipatterns-0754755'`
- `sql.bicep`: `param sqlServerName string = 'sql-aipatterns-sandr-1770754196'`
- `cms.bicep`: `param mysqlServerName string = 'mysql-aipatterns-cms'`, `param storageAccountName string = 'staipatternsmedia'`

Defaults match production — `deploy.ps1` works unchanged. Future staging environment overrides via params.

### 1c. Parameterize API URL
In `containerApps.bicep`, replace hardcoded string on line 198:
```bicep
@description('Public API base URL for the frontend app')
param apiBaseUrl string = 'https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api'
```

### 1d. Parameter Validation
In `main.bicep`:
```bicep
@allowed(['centralus', 'eastus', 'eastus2', 'westus2'])
param location string = 'centralus'

@allowed(['prod', 'staging', 'dev'])
param environment string = 'prod'

@minLength(12)
@secure()
param sqlAdminPassword string

@minLength(12)
@secure()
param mysqlAdminPassword string
```

---

## Track 2: Monitoring & Observability (Moderate)

**Effort:** ~45 min | **Risk:** Low — conditional resources, new dependency edge (sql → monitoring)

**Files to modify:**
- `infrastructure/modules/monitoring.bicep` — add action group, lower exception threshold
- `infrastructure/modules/sql.bicep` — add diagnostic settings resource
- `infrastructure/main.bicep` — pass `logAnalyticsId` to sql module

### 2a. Alert Action Group
Add conditional action group to `monitoring.bicep`:
```bicep
@description('Email for alert notifications (empty = no notifications)')
param alertEmail string = ''

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = if (!empty(alertEmail)) {
  name: 'ag-aipatterns-alerts-${environment}'
  location: 'global'
  properties: {
    groupShortName: 'AIPatAlert'
    enabled: true
    emailReceivers: [{ name: 'DevOps', emailAddress: alertEmail, useCommonAlertSchema: true }]
  }
}
```
Wire into each alert's `actions` array (conditionally). Keeps template deployable without email config.

### 2b. SQL Diagnostic Settings
Add to `sql.bicep`:
```bicep
param logAnalyticsId string = ''

resource sqlDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsId)) {
  name: 'sql-diagnostics'
  scope: sqlDb
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      { category: 'SQLSecurityAuditEvents', enabled: true }
      { category: 'DevOpsOperationsAudit', enabled: true }
    ]
    metrics: [
      { category: 'Basic', enabled: true }
      { category: 'InstanceAndAppAdvanced', enabled: true }
    ]
  }
}
```
Update `main.bicep` to pass `monitoring.outputs.logAnalyticsId` to sql module.

### 2c. Exception Spike Threshold
In `monitoring.bicep` line 137: lower threshold from `20` to `10` (matches the existing `configure-alerts.ps1` script).

---

## Track 3: Key Vault & Secrets Hardening (Quick Win)

**Effort:** ~20 min | **Risk:** Purge protection is irreversible (one-way setting — intended)

**Files to modify:**
- `infrastructure/modules/keyvault.bicep` — purge protection, retention
- `infrastructure/modules/containerApps.bicep` — App Insights secret to KV reference
- `infrastructure/main.bicep` — remove `appInsightsConnectionString` passthrough

### 3a. Enable Purge Protection
In `keyvault.bicep`:
```bicep
enablePurgeProtection: true       // One-way — cannot be disabled (intended)
softDeleteRetentionInDays: 90     // Up from 7 days
```

### 3b. Move App Insights Connection String to Key Vault
Currently line 66-68 of `containerApps.bicep` uses `value: appInsightsConnectionString` (inline). Change to:
```bicep
{
  name: 'appinsights-connection-string'
  keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/appinsights-connection-string'
  identity: 'system'
}
```
- Remove `appInsightsConnectionString` param from `containerApps.bicep`
- Remove the passthrough in `main.bicep` (line 93)
- Add `az keyvault secret set --name appinsights-connection-string` to post-deploy checklist in `deploy.ps1` and `infrastructure/README.md`
- Keep `monitoring.outputs.appInsightsConnectionString` output for operational use

**Pre-deploy step:** Store App Insights connection string in Key Vault before deploying this change.

---

## Track 4: Documentation & Decision Log (Quick Win)

**Effort:** ~15 min

**Files to modify:**
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — Decision 53 (7.5 IaC & Azure Security)
- `documentation/project/ROADMAP.md` — mark 7.5 evaluated
- `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md` — ACR cleanup commands, updated secrets inventory
- `infrastructure/README.md` — ACR cleanup, App Insights secret in post-deploy checklist
- `CLAUDE.md` — Phase 7.5 summary

ACR cleanup commands (Basic SKU can't auto-purge; document manual cleanup):
```bash
az acr repository show-tags --name craipatternssp54426 --repository aipatterns-api --orderby time_asc --output tsv | head -n -5 | xargs -I {} az acr repository delete --name craipatternssp54426 --image aipatterns-api:{} --yes
```

---

## Execution Order

1. **Track 1** — Governance (foundation; tags propagate everywhere)
2. **Track 3** — Key Vault hardening (must store App Insights connection string in KV before Track 2 deploys)
3. **Track 2** — Monitoring (depends on Track 1 tags; adds SQL diagnostic dependency edge)
4. **Track 4** — Documentation (captures all changes)

---

## Verification

- [ ] `az bicep build --file infrastructure/main.bicep` compiles without errors
- [ ] CI `validate-infrastructure` job passes (push branch, verify in Actions)
- [ ] `deploy.ps1 -WhatIf` shows expected changes (tags, KV purge protection, SQL diagnostics)
- [ ] All resources have `project`, `environment`, `managedBy` tags
- [ ] Key Vault: `enablePurgeProtection: true`, `softDeleteRetentionInDays: 90`
- [ ] App Insights connection string uses `keyVaultUrl` reference (not inline value)
- [ ] SQL database has diagnostic settings sending to Log Analytics
- [ ] Exception spike threshold is 10 (not 20)
- [ ] `NEXT_PUBLIC_API_BASE_URL` is a parameter with production default
- [ ] `@minLength(12)` on both password params, `@allowed` on location/environment
- [ ] Decision 53 in TECHNICAL_DECISIONS_LOG.md
- [ ] ACR cleanup documented in infrastructure/README.md
