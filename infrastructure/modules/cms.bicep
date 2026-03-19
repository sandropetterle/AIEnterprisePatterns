// cms.bicep — MySQL Flexible Server + Blob Storage for Strapi CMS
// Deployed to francecentral to match existing production resources.

@description('Azure region for CMS resources (francecentral matches existing production)')
param location string = 'francecentral'

@description('MySQL admin password')
@secure()
param mysqlAdminPassword string

@description('Resource tags applied to all resources in this module')
param tags object

@description('MySQL Flexible Server resource name')
param mysqlServerName string = 'mysql-aipatterns-cms'

@description('Storage account resource name')
param storageAccountName string = 'staipatternsmedia'

var mysqlAdminLogin = 'mysqladmin'

// ── MySQL Flexible Server ─────────────────────────────────────────────────────

resource mysqlServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
  name: mysqlServerName
  location: location
  tags: tags
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: mysqlAdminLogin
    administratorLoginPassword: mysqlAdminPassword
    version: '8.0.21'
    storage: {
      storageSizeGB: 20
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource mysqlDatabase 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = {
  parent: mysqlServer
  name: 'strapi_cms'
  properties: {
    charset: 'utf8mb4'
    collation: 'utf8mb4_unicode_ci'
  }
}

// Allow Azure services
resource mysqlFirewallAzure 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-30' = {
  parent: mysqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// ── Storage Account + Blob Container ─────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true // Required for Strapi media public serving
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource mediaContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'strapi-media'
  properties: {
    publicAccess: 'Blob' // Public read for media files
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('MySQL server fully qualified domain name')
output mysqlFqdn string = mysqlServer.properties.fullyQualifiedDomainName

@description('Storage account name for Strapi media')
output storageAccountName string = storageAccount.name
