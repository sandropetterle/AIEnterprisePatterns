// main.bicep — Infrastructure orchestrator for AI Enterprise Patterns
// Calls all modules in dependency order.
//
// CRITICAL: Always deploy with --mode Incremental (never Complete).
// Complete mode would delete resources not in this template (e.g. DNS records, manual configs).
//
// Deploy via: infrastructure/deploy.ps1

@description('Azure region for all resources (default: centralus)')
param location string = 'centralus'

@description('Environment name suffix used in resource names')
param environment string = 'prod'

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('MySQL administrator password')
@secure()
param mysqlAdminPassword string

// ── 1. Monitoring (no dependencies) ──────────────────────────────────────────

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    environment: environment
  }
}

// ── 2. ACR (no dependencies) ─────────────────────────────────────────────────

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    location: location
  }
}

// ── 3. Key Vault (no dependencies) ───────────────────────────────────────────
// Secrets are NOT stored in Bicep. Set them post-deploy:
//   az keyvault secret set --vault-name kv-aipatterns-0754755 --name sql-connection-string --value "..."

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
  }
}

// ── 4. SQL (no dependencies) ─────────────────────────────────────────────────

module sql 'modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    sqlAdminPassword: sqlAdminPassword
  }
}

// ── 5. CMS — MySQL + Storage (no dependencies, separate region) ──────────────

module cms 'modules/cms.bicep' = {
  name: 'cms'
  params: {
    mysqlAdminPassword: mysqlAdminPassword
  }
}

// ── 6. Container Apps Environment (depends on monitoring) ────────────────────

module cae 'modules/containerAppsEnvironment.bicep' = {
  name: 'containerAppsEnvironment'
  params: {
    location: location
    logAnalyticsCustomerId: monitoring.outputs.logAnalyticsCustomerId
    logAnalyticsId: monitoring.outputs.logAnalyticsId
  }
}

// ── 7. Container Apps (depends on cae, acr, keyvault, monitoring, sql) ───────

module containerApps 'modules/containerApps.bicep' = {
  name: 'containerApps'
  params: {
    location: location
    caeId: cae.outputs.caeId
    acrLoginServer: acr.outputs.acrLoginServer
    acrResourceId: acr.outputs.acrResourceId
    kvName: keyvault.outputs.kvName
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

// ── 8. KV role assignment: Key Vault Secrets User → each Container App ───────
// Defined here (not in keyvault.bicep) to avoid circular dependency between
// keyvault and containerApps modules.
//
// Role assignment names use guid() with plan-time-known string literals only
// (BCP120: name must be calculable at deployment start, not from runtime outputs).

var kvSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource kvSecretsUserApi 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'kv-aipatterns-0754755', 'ca-aipatterns-api-prod', kvSecretsUserRoleId)
  scope: resourceGroup()
  properties: {
    principalId: containerApps.outputs.apiPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretsUserRoleId)
    principalType: 'ServicePrincipal'
  }
}

resource kvSecretsUserWeb 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'kv-aipatterns-0754755', 'ca-aipatterns-web-prod', kvSecretsUserRoleId)
  scope: resourceGroup()
  properties: {
    principalId: containerApps.outputs.webPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretsUserRoleId)
    principalType: 'ServicePrincipal'
  }
}

resource kvSecretsUserCms 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'kv-aipatterns-0754755', 'ca-aipatterns-cms-prod', kvSecretsUserRoleId)
  scope: resourceGroup()
  properties: {
    principalId: containerApps.outputs.cmsPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretsUserRoleId)
    principalType: 'ServicePrincipal'
  }
}
