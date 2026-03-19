// acr.bicep — Azure Container Registry
// No dependencies on other modules.

@description('Azure region for all resources')
param location string

@description('Resource tags applied to all resources in this module')
param tags object

@description('ACR resource name')
param acrName string = 'craipatternssp54426'

// ── Container Registry ────────────────────────────────────────────────────────

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('ACR login server hostname (e.g. craipatternssp54426.azurecr.io)')
output acrLoginServer string = acr.properties.loginServer

@description('ACR resource ID (for managed identity pull role assignment)')
output acrResourceId string = acr.id
