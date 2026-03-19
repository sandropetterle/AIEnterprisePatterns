// keyvault.bicep — Azure Key Vault (RBAC mode, no secrets stored in Bicep)
// Secrets are set post-deploy via: az keyvault secret set
// Role assignment for Container App managed identity is done in main.bicep
// after containerApps module outputs the principal IDs.

@description('Azure region for all resources')
param location string

@description('Resource tags applied to all resources in this module')
param tags object

@description('Key Vault resource name')
param kvName string = 'kv-aipatterns-0754755'

// ── Key Vault ─────────────────────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: kvName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('Key Vault name')
output kvName string = keyVault.name

@description('Key Vault resource ID')
output kvResourceId string = keyVault.id
