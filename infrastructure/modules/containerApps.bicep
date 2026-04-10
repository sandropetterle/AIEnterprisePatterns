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

@description('Key Vault name (for secret references in all apps)')
param kvName string

@description('Public API base URL for the frontend app')
param apiBaseUrl string = 'https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api'

@description('Azure Entra External ID OIDC issuer URL')
param authEntraIssuer string = 'https://aipatterns.ciamlogin.com/aipatterns.onmicrosoft.com/v2.0'

@description('Azure Entra External ID frontend client ID')
param authEntraClientId string = ''

@description('Auth.js API scope for read access')
param authApiScopeRead string = 'api://aipatterns-api/patterns.read'

@description('Auth.js API scope for write access')
param authApiScopeWrite string = 'api://aipatterns-api/patterns.write'

@description('Resource tags applied to all resources in this module')
param tags object

// Image tags — placeholder used on first deploy; CI manages these via az containerapp update
@description('API container image (including tag). Set to placeholder on first deploy.')
param apiImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Web container image (including tag). Set to placeholder on first deploy.')
param webImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

// Built-in role definition IDs
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// ── API Container App ─────────────────────────────────────────────────────────

resource apiApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-aipatterns-api-prod'
  location: location
  tags: tags
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
          keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/secrets/appinsights-connection-string'
          identity: 'system'
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
          probes: [
            {
              type: 'Startup'
              httpGet: {
                path: '/health'
                port: 8080
              }
              initialDelaySeconds: 30
              periodSeconds: 10
              failureThreshold: 3
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 8080
              }
              periodSeconds: 10
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health/ready'
                port: 8080
              }
              periodSeconds: 10
              failureThreshold: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
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
  tags: tags
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
              value: apiBaseUrl
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
            {
              name: 'AUTH_ENTRA_ISSUER'
              value: authEntraIssuer
            }
            {
              name: 'AUTH_ENTRA_CLIENT_ID'
              value: authEntraClientId
            }
            {
              name: 'AUTH_API_SCOPE_READ'
              value: authApiScopeRead
            }
            {
              name: 'AUTH_API_SCOPE_WRITE'
              value: authApiScopeWrite
            }
          ]
          probes: [
            {
              type: 'Startup'
              httpGet: {
                path: '/'
                port: 3000
              }
              initialDelaySeconds: 30
              periodSeconds: 10
              failureThreshold: 3
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/'
                port: 3000
              }
              periodSeconds: 10
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/'
                port: 3000
              }
              periodSeconds: 10
              failureThreshold: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
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

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('API Container App managed identity principal ID (for KV Secrets User role)')
output apiPrincipalId string = apiApp.identity.principalId

@description('Web Container App managed identity principal ID')
output webPrincipalId string = webApp.identity.principalId
