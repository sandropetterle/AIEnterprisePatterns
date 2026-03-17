// containerApps.bicep — All 3 Container Apps (api, web, cms)
// All use system-assigned managed identity + ACR pull via managed identity.
//
// IMAGE TAGS: The imageTag parameters default to a stable placeholder for first deploy only.
// CI/CD manages image tags going forward via: az containerapp update --image <acr>/<repo>:<sha>
// Because deploy.ps1 uses --mode Incremental, re-running Bicep without specifying imageTag
// will reset to placeholder — pass current tags explicitly when re-deploying infrastructure.

@description('Azure region for all resources')
param location string

@description('Container Apps Environment resource ID')
param caeId string

@description('ACR login server hostname (e.g. craipatternssp54426.azurecr.io)')
param acrLoginServer string

@description('ACR resource ID (for AcrPull role assignment)')
param acrResourceId string

@description('Key Vault name (for secret references in API app)')
param kvName string

@description('Application Insights connection string')
@secure()
param appInsightsConnectionString string

// Image tags — placeholder used on first deploy; CI manages these via az containerapp update
@description('API container image (including tag). Set to placeholder on first deploy.')
param apiImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Web container image (including tag). Set to placeholder on first deploy.')
param webImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('CMS container image (including tag). Set to placeholder on first deploy.')
param cmsImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

// Built-in role definition IDs
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// ── API Container App ─────────────────────────────────────────────────────────

resource apiApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-aipatterns-api-prod'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: caeId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: acrLoginServer
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'appinsights-connection-string'
          value: appInsightsConnectionString
        }
        {
          name: 'sql-connection-string'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/sql-connection-string'
          identity: 'system'
        }
        {
          name: 'auth-authority'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/auth-authority'
          identity: 'system'
        }
        {
          name: 'auth-audience'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/auth-audience'
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'api'
          image: apiImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://+:8080'
            }
            {
              name: 'ApplicationInsights__ConnectionString'
              secretRef: 'appinsights-connection-string'
            }
            {
              name: 'ConnectionStrings__DefaultConnection'
              secretRef: 'sql-connection-string'
            }
            {
              name: 'Authentication__Authority'
              secretRef: 'auth-authority'
            }
            {
              name: 'Authentication__Audience'
              secretRef: 'auth-audience'
            }
            {
              name: 'Authentication__RequireHttpsMetadata'
              value: 'true'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
      }
    }
  }
}

// ACR pull role for API app
resource apiAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(apiApp.id, acrResourceId, acrPullRoleId)
  scope: resourceGroup()
  properties: {
    principalId: apiApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalType: 'ServicePrincipal'
  }
}

// ── Web Container App ─────────────────────────────────────────────────────────

resource webApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-aipatterns-web-prod'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: caeId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 3000
        transport: 'http'
      }
      registries: [
        {
          server: acrLoginServer
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'auth-secret'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/auth-secret'
          identity: 'system'
        }
        {
          name: 'auth-entra-client-secret'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/auth-entra-client-secret'
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'web'
          image: webImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'NEXT_PUBLIC_API_BASE_URL'
              value: 'https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api'
            }
            {
              name: 'AUTH_TRUST_HOST'
              value: 'true'
            }
            {
              name: 'AUTH_SECRET'
              secretRef: 'auth-secret'
            }
            {
              name: 'AUTH_ENTRA_CLIENT_SECRET'
              secretRef: 'auth-entra-client-secret'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
      }
    }
  }
}

// ACR pull role for web app
resource webAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(webApp.id, acrResourceId, acrPullRoleId)
  scope: resourceGroup()
  properties: {
    principalId: webApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalType: 'ServicePrincipal'
  }
}

// ── CMS Container App ─────────────────────────────────────────────────────────

resource cmsApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-aipatterns-cms-prod'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: caeId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 1337
        transport: 'http'
      }
      registries: [
        {
          server: acrLoginServer
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'strapi-app-keys'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/strapi-app-keys'
          identity: 'system'
        }
        {
          name: 'strapi-admin-jwt-secret'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/strapi-admin-jwt-secret'
          identity: 'system'
        }
        {
          name: 'database-password'
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/mysql-admin-password'
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'cms'
          image: cmsImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'DATABASE_CLIENT'
              value: 'mysql2'
            }
            {
              name: 'DATABASE_HOST'
              value: 'mysql-aipatterns-cms.mysql.database.azure.com'
            }
            {
              name: 'DATABASE_PORT'
              value: '3306'
            }
            {
              name: 'DATABASE_NAME'
              value: 'strapi_cms'
            }
            {
              name: 'DATABASE_USERNAME'
              value: 'mysqladmin'
            }
            {
              name: 'DATABASE_PASSWORD'
              secretRef: 'database-password'
            }
            {
              name: 'DATABASE_SSL'
              value: 'true'
            }
            {
              name: 'APP_KEYS'
              secretRef: 'strapi-app-keys'
            }
            {
              name: 'ADMIN_JWT_SECRET'
              secretRef: 'strapi-admin-jwt-secret'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 2
      }
    }
  }
}

// ACR pull role for CMS app
resource cmsAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cmsApp.id, acrResourceId, acrPullRoleId)
  scope: resourceGroup()
  properties: {
    principalId: cmsApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalType: 'ServicePrincipal'
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('API Container App managed identity principal ID (for KV Secrets User role)')
output apiPrincipalId string = apiApp.identity.principalId

@description('Web Container App managed identity principal ID')
output webPrincipalId string = webApp.identity.principalId

@description('CMS Container App managed identity principal ID')
output cmsPrincipalId string = cmsApp.identity.principalId
