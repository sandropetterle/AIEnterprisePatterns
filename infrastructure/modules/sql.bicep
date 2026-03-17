// sql.bicep — Azure SQL Serverless (GP_S_Gen5_1, auto-pause 15 min)
// Firewall: Azure services rule only. Developer IPs are set manually.

@description('Azure region for all resources')
param location string

@description('SQL Server admin password')
@secure()
param sqlAdminPassword string

var sqlServerName = 'sql-aipatterns-sandr-1770754196'
var sqlAdminLogin = 'sqladmin'

// ── SQL Server ────────────────────────────────────────────────────────────────

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Allow Azure services to access the server
resource firewallAllowAzure 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// ── SQL Database (Serverless) ─────────────────────────────────────────────────

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: 'sqldb-aipatterns-prod'
  location: location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368 // 32 GiB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 15 // minutes
    minCapacity: json('0.5')
    requestedBackupStorageRedundancy: 'Local'
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('SQL Server fully qualified domain name')
output sqlFqdn string = sqlServer.properties.fullyQualifiedDomainName
