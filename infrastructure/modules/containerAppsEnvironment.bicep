// containerAppsEnvironment.bicep — Container Apps Environment linked to Log Analytics
// Depends on: monitoring module (logAnalyticsCustomerId + logAnalyticsId)

@description('Azure region for all resources')
param location string

@description('Log Analytics workspace customer ID')
param logAnalyticsCustomerId string

@description('Log Analytics workspace resource ID')
param logAnalyticsId string

// ── Container Apps Environment ────────────────────────────────────────────────

resource cae 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-aipatterns-prod'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: listKeys(logAnalyticsId, '2022-10-01').primarySharedKey
      }
    }
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('Container Apps Environment resource ID')
output caeId string = cae.id
