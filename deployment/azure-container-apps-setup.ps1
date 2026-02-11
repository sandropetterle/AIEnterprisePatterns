# ============================================================================
# Azure Container Apps Infrastructure Setup Script
# AI Enterprise Patterns - Phase 4 (Consumption-Based Deployment)
# ============================================================================
#
# This script creates a consumption-based Azure infrastructure that scales
# to zero when not in use, significantly reducing costs.
#
# Prerequisites:
# 1. Install Azure CLI: https://aka.ms/InstallAzureCLI
# 2. Run: az login
# 3. Verify subscription: az account show
# 4. Update variables below as needed
#
# Estimated Monthly Cost: $0-5 (vs $19-24 with App Services)
#
# Usage:
# .\azure-container-apps-setup.ps1
#
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# CONFIGURATION VARIABLES - UPDATE THESE
# ============================================================================

$RESOURCE_GROUP = "rg-aipatterns-prod"
$LOCATION = "eastus"  # Change to your preferred region
$SUBSCRIPTION_ID = "" # Leave empty to use default subscription

# Naming convention: {resource-type}-{project}-{environment}
$SQL_SERVER_NAME = "sql-aipatterns-prod"      # Must be globally unique
$SQL_DATABASE_NAME = "sqldb-aipatterns-prod"
$SQL_ADMIN_USER = "aipatterns-admin"
$SQL_ADMIN_PASSWORD = ""  # Will be generated if empty

$CONTAINER_ENVIRONMENT = "cae-aipatterns-prod"
$BACKEND_APP_NAME = "ca-aipatterns-api-prod"    # Container App for backend
$FRONTEND_APP_NAME = "ca-aipatterns-web-prod"   # Container App for frontend

$CONTAINER_REGISTRY = "craipatternsreg"  # Must be globally unique, alphanumeric only
$KEY_VAULT_NAME = "kv-aipatterns-prod"   # Must be globally unique (3-24 chars)
$APP_INSIGHTS_NAME = "appi-aipatterns-prod"
$LOG_ANALYTICS_NAME = "log-aipatterns-prod"

# Container Apps Configuration
$BACKEND_IMAGE = "mcr.microsoft.com/dotnet/samples:aspnetapp"  # Temporary, will be replaced by CI/CD
$FRONTEND_IMAGE = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"  # Temporary

# SQL Database - Serverless Tier (Auto-pause when idle)
$SQL_EDITION = "GeneralPurpose"
$SQL_FAMILY = "Gen5"
$SQL_COMPUTE_MODEL = "Serverless"
$SQL_MIN_VCORES = 0.5  # Minimum cores (0.5 = half core)
$SQL_MAX_VCORES = 2    # Maximum cores
$SQL_AUTOPAUSE_DELAY = 60  # Auto-pause after 60 minutes of inactivity

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Yellow
}

function Generate-Password {
    $length = 20
    $bytes = [byte[]]::new($length)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    $password = -join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })
    return $password
}

# ============================================================================
# VALIDATION
# ============================================================================

Write-Step "Validating Prerequisites"

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Success "Azure CLI version: $($azVersion.'azure-cli')"
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install from: https://aka.ms/InstallAzureCLI" -ForegroundColor Red
    exit 1
}

# Check if logged in
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Success "Logged in as: $($account.user.name)"
    Write-Info "Subscription: $($account.name) ($($account.id))"

    if ($SUBSCRIPTION_ID -and $account.id -ne $SUBSCRIPTION_ID) {
        Write-Info "Setting subscription to: $SUBSCRIPTION_ID"
        az account set --subscription $SUBSCRIPTION_ID
    }
} catch {
    Write-Host "❌ Not logged in to Azure. Please run: az login" -ForegroundColor Red
    exit 1
}

# Generate SQL password if not provided
if (-not $SQL_ADMIN_PASSWORD) {
    $SQL_ADMIN_PASSWORD = Generate-Password
    Write-Info "Generated SQL admin password (save this securely!)"
}

# ============================================================================
# RESOURCE GROUP
# ============================================================================

Write-Step "Creating Resource Group"

$existingRg = az group exists --name $RESOURCE_GROUP
if ($existingRg -eq "true") {
    Write-Info "Resource group '$RESOURCE_GROUP' already exists"
} else {
    az group create `
        --name $RESOURCE_GROUP `
        --location $LOCATION `
        --output none
    Write-Success "Resource group created: $RESOURCE_GROUP"
}

# ============================================================================
# SQL SERVER AND DATABASE (SERVERLESS)
# ============================================================================

Write-Step "Creating Azure SQL Server"

$existingSqlServer = az sql server list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$SQL_SERVER_NAME'].name" `
    --output tsv

if ($existingSqlServer) {
    Write-Info "SQL Server '$SQL_SERVER_NAME' already exists"
} else {
    az sql server create `
        --name $SQL_SERVER_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --admin-user $SQL_ADMIN_USER `
        --admin-password $SQL_ADMIN_PASSWORD `
        --output none
    Write-Success "SQL Server created: $SQL_SERVER_NAME"
}

Write-Step "Configuring SQL Server Firewall"

# Allow Azure services
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name "AllowAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 `
    --output none

# Allow your current IP
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name "AllowMyIP" `
    --start-ip-address $myIp `
    --end-ip-address $myIp `
    --output none

Write-Success "Firewall rules configured (Azure services + your IP: $myIp)"

Write-Step "Creating Azure SQL Database (Serverless - Auto-pause)"

$existingDb = az sql db list `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --query "[?name=='$SQL_DATABASE_NAME'].name" `
    --output tsv

if ($existingDb) {
    Write-Info "SQL Database '$SQL_DATABASE_NAME' already exists"
} else {
    az sql db create `
        --resource-group $RESOURCE_GROUP `
        --server $SQL_SERVER_NAME `
        --name $SQL_DATABASE_NAME `
        --edition $SQL_EDITION `
        --family $SQL_FAMILY `
        --compute-model $SQL_COMPUTE_MODEL `
        --min-capacity $SQL_MIN_VCORES `
        --capacity $SQL_MAX_VCORES `
        --auto-pause-delay $SQL_AUTOPAUSE_DELAY `
        --backup-storage-redundancy Local `
        --output none
    Write-Success "SQL Database created: $SQL_DATABASE_NAME (Serverless - auto-pause after $SQL_AUTOPAUSE_DELAY min)"
}

# ============================================================================
# LOG ANALYTICS WORKSPACE (Required for Container Apps)
# ============================================================================

Write-Step "Creating Log Analytics Workspace"

$existingLogAnalytics = az monitor log-analytics workspace show `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --query "name" `
    --output tsv 2>$null

if ($existingLogAnalytics) {
    Write-Info "Log Analytics workspace '$LOG_ANALYTICS_NAME' already exists"
} else {
    az monitor log-analytics workspace create `
        --resource-group $RESOURCE_GROUP `
        --workspace-name $LOG_ANALYTICS_NAME `
        --location $LOCATION `
        --output none
    Write-Success "Log Analytics workspace created: $LOG_ANALYTICS_NAME"
}

$logAnalyticsId = az monitor log-analytics workspace show `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --query "customerId" `
    --output tsv

$logAnalyticsKey = az monitor log-analytics workspace get-shared-keys `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --query "primarySharedKey" `
    --output tsv

# ============================================================================
# APPLICATION INSIGHTS
# ============================================================================

Write-Step "Creating Application Insights"

$existingAppInsights = az monitor app-insights component show `
    --resource-group $RESOURCE_GROUP `
    --app $APP_INSIGHTS_NAME `
    --query "name" `
    --output tsv 2>$null

if ($existingAppInsights) {
    Write-Info "Application Insights '$APP_INSIGHTS_NAME' already exists"
} else {
    az monitor app-insights component create `
        --resource-group $RESOURCE_GROUP `
        --app $APP_INSIGHTS_NAME `
        --location $LOCATION `
        --kind web `
        --application-type web `
        --workspace "/subscriptions/$($account.id)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_NAME" `
        --output none
    Write-Success "Application Insights created: $APP_INSIGHTS_NAME"
}

$appInsightsKey = az monitor app-insights component show `
    --resource-group $RESOURCE_GROUP `
    --app $APP_INSIGHTS_NAME `
    --query "instrumentationKey" `
    --output tsv

$appInsightsConnString = az monitor app-insights component show `
    --resource-group $RESOURCE_GROUP `
    --app $APP_INSIGHTS_NAME `
    --query "connectionString" `
    --output tsv

# ============================================================================
# CONTAINER REGISTRY
# ============================================================================

Write-Step "Creating Azure Container Registry"

$existingAcr = az acr list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$CONTAINER_REGISTRY'].name" `
    --output tsv

if ($existingAcr) {
    Write-Info "Container Registry '$CONTAINER_REGISTRY' already exists"
} else {
    az acr create `
        --name $CONTAINER_REGISTRY `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --sku Basic `
        --admin-enabled true `
        --output none
    Write-Success "Container Registry created: $CONTAINER_REGISTRY"
}

$acrLoginServer = az acr show `
    --name $CONTAINER_REGISTRY `
    --resource-group $RESOURCE_GROUP `
    --query "loginServer" `
    --output tsv

$acrUsername = az acr credential show `
    --name $CONTAINER_REGISTRY `
    --query "username" `
    --output tsv

$acrPassword = az acr credential show `
    --name $CONTAINER_REGISTRY `
    --query "passwords[0].value" `
    --output tsv

Write-Success "ACR Login Server: $acrLoginServer"

# ============================================================================
# KEY VAULT
# ============================================================================

Write-Step "Creating Azure Key Vault"

$existingKv = az keyvault list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$KEY_VAULT_NAME'].name" `
    --output tsv

if ($existingKv) {
    Write-Info "Key Vault '$KEY_VAULT_NAME' already exists"
} else {
    az keyvault create `
        --name $KEY_VAULT_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --enable-rbac-authorization false `
        --output none
    Write-Success "Key Vault created: $KEY_VAULT_NAME"
}

Write-Step "Storing Secrets in Key Vault"

$sqlConnectionString = "Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=$SQL_DATABASE_NAME;Persist Security Info=False;User ID=$SQL_ADMIN_USER;Password=$SQL_ADMIN_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az keyvault secret set --vault-name $KEY_VAULT_NAME --name "SqlConnectionString" --value $sqlConnectionString --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ApplicationInsights--InstrumentationKey" --value $appInsightsKey --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ApplicationInsights--ConnectionString" --value $appInsightsConnString --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "SqlAdminPassword" --value $SQL_ADMIN_PASSWORD --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "AcrUsername" --value $acrUsername --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "AcrPassword" --value $acrPassword --output none

Write-Success "Secrets stored in Key Vault"

# ============================================================================
# CONTAINER APPS ENVIRONMENT
# ============================================================================

Write-Step "Creating Container Apps Environment"

$existingEnv = az containerapp env list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$CONTAINER_ENVIRONMENT'].name" `
    --output tsv

if ($existingEnv) {
    Write-Info "Container Apps Environment '$CONTAINER_ENVIRONMENT' already exists"
} else {
    az containerapp env create `
        --name $CONTAINER_ENVIRONMENT `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --logs-workspace-id $logAnalyticsId `
        --logs-workspace-key $logAnalyticsKey `
        --output none
    Write-Success "Container Apps Environment created: $CONTAINER_ENVIRONMENT"
}

# ============================================================================
# BACKEND CONTAINER APP
# ============================================================================

Write-Step "Creating Backend Container App"

$existingBackend = az containerapp list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$BACKEND_APP_NAME'].name" `
    --output tsv

if ($existingBackend) {
    Write-Info "Backend Container App '$BACKEND_APP_NAME' already exists"
} else {
    az containerapp create `
        --name $BACKEND_APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --environment $CONTAINER_ENVIRONMENT `
        --image $BACKEND_IMAGE `
        --target-port 80 `
        --ingress external `
        --min-replicas 0 `
        --max-replicas 5 `
        --cpu 0.5 `
        --memory 1.0Gi `
        --secrets `
            "sql-connection-string=$sqlConnectionString" `
            "app-insights-key=$appInsightsKey" `
            "app-insights-conn=$appInsightsConnString" `
        --env-vars `
            "ASPNETCORE_ENVIRONMENT=Production" `
            "ConnectionStrings__DefaultConnection=secretref:sql-connection-string" `
            "ApplicationInsights__InstrumentationKey=secretref:app-insights-key" `
            "ApplicationInsights__ConnectionString=secretref:app-insights-conn" `
        --output none
    Write-Success "Backend Container App created: $BACKEND_APP_NAME"
}

$backendUrl = az containerapp show `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "properties.configuration.ingress.fqdn" `
    --output tsv

# Enable managed identity
az containerapp identity assign `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --system-assigned `
    --output none

$backendPrincipalId = az containerapp identity show `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "principalId" `
    --output tsv

az keyvault set-policy `
    --name $KEY_VAULT_NAME `
    --object-id $backendPrincipalId `
    --secret-permissions get list `
    --output none

Write-Success "Managed identity enabled and Key Vault access granted"

# ============================================================================
# FRONTEND CONTAINER APP
# ============================================================================

Write-Step "Creating Frontend Container App"

$existingFrontend = az containerapp list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$FRONTEND_APP_NAME'].name" `
    --output tsv

if ($existingFrontend) {
    Write-Info "Frontend Container App '$FRONTEND_APP_NAME' already exists"
} else {
    az containerapp create `
        --name $FRONTEND_APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --environment $CONTAINER_ENVIRONMENT `
        --image $FRONTEND_IMAGE `
        --target-port 3000 `
        --ingress external `
        --min-replicas 0 `
        --max-replicas 5 `
        --cpu 0.5 `
        --memory 1.0Gi `
        --env-vars `
            "NODE_ENV=production" `
            "NEXT_PUBLIC_API_BASE_URL=https://$backendUrl/api" `
        --output none
    Write-Success "Frontend Container App created: $FRONTEND_APP_NAME"
}

$frontendUrl = az containerapp show `
    --name $FRONTEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "properties.configuration.ingress.fqdn" `
    --output tsv

# ============================================================================
# UPDATE BACKEND CORS
# ============================================================================

Write-Step "Updating Backend CORS Configuration"

az containerapp update `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --set-env-vars "FrontendUrl=https://$frontendUrl" `
    --output none

Write-Success "CORS configured to allow frontend origin"

# ============================================================================
# SUMMARY
# ============================================================================

Write-Step "Deployment Summary"

Write-Host ""
Write-Host "✓ Azure Container Apps infrastructure setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "Location: $LOCATION" -ForegroundColor White
Write-Host ""
Write-Host "💰 Cost Model: CONSUMPTION-BASED (Scale to Zero)" -ForegroundColor Yellow
Write-Host "   Estimated: `$0-5/month for low traffic (vs `$19-24 with App Services)" -ForegroundColor Yellow
Write-Host ""
Write-Host "SQL Server (Serverless):" -ForegroundColor Yellow
Write-Host "  Server: $SQL_SERVER_NAME.database.windows.net" -ForegroundColor White
Write-Host "  Database: $SQL_DATABASE_NAME" -ForegroundColor White
Write-Host "  Admin User: $SQL_ADMIN_USER" -ForegroundColor White
Write-Host "  Admin Password: $SQL_ADMIN_PASSWORD" -ForegroundColor Red
Write-Host "  Auto-pause: After $SQL_AUTOPAUSE_DELAY minutes idle" -ForegroundColor Cyan
Write-Host "  Capacity: $SQL_MIN_VCORES-$SQL_MAX_VCORES vCores" -ForegroundColor Cyan
Write-Host ""
Write-Host "Container Apps:" -ForegroundColor Yellow
Write-Host "  Backend:  https://$backendUrl" -ForegroundColor White
Write-Host "  Frontend: https://$frontendUrl" -ForegroundColor White
Write-Host "  Scaling: 0-5 replicas (auto-scale to zero when idle)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Container Registry:" -ForegroundColor Yellow
Write-Host "  Server: $acrLoginServer" -ForegroundColor White
Write-Host "  Username: $acrUsername" -ForegroundColor White
Write-Host ""
Write-Host "Application Insights:" -ForegroundColor Yellow
Write-Host "  Name: $APP_INSIGHTS_NAME" -ForegroundColor White
Write-Host "  Key: $appInsightsKey" -ForegroundColor White
Write-Host ""
Write-Host "Key Vault:" -ForegroundColor Yellow
Write-Host "  Name: $KEY_VAULT_NAME" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: Save the SQL Admin Password and ACR credentials securely!" -ForegroundColor Red
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run database migrations using the connection string above" -ForegroundColor White
Write-Host "2. Build and push Docker images to ACR" -ForegroundColor White
Write-Host "3. Update Container Apps with your images" -ForegroundColor White
Write-Host "4. Configure GitHub Actions with ACR credentials" -ForegroundColor White
Write-Host "5. Push to main branch to trigger automated deployment" -ForegroundColor White
Write-Host ""

# Save output to file
$outputFile = "azure-container-apps-output.txt"
@"
Azure Container Apps Setup - $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
================================================================

💰 CONSUMPTION-BASED DEPLOYMENT - SCALES TO ZERO
Estimated Cost: `$0-5/month (vs `$19-24 with App Services)

Resource Group: $RESOURCE_GROUP
Location: $LOCATION

SQL Server (Serverless - Auto-pause):
  Server: $SQL_SERVER_NAME.database.windows.net
  Database: $SQL_DATABASE_NAME
  Admin User: $SQL_ADMIN_USER
  Admin Password: $SQL_ADMIN_PASSWORD
  Auto-pause: After $SQL_AUTOPAUSE_DELAY minutes idle
  Capacity: $SQL_MIN_VCORES-$SQL_MAX_VCORES vCores

Connection String:
$sqlConnectionString

Container Apps (Scale to Zero):
  Backend API: https://$backendUrl
  Frontend Web: https://$frontendUrl
  Scaling: 0-5 replicas automatically

Container Registry:
  Server: $acrLoginServer
  Username: $acrUsername
  Password: $acrPassword

Application Insights:
  Name: $APP_INSIGHTS_NAME
  Instrumentation Key: $appInsightsKey
  Connection String: $appInsightsConnString

Key Vault:
  Name: $KEY_VAULT_NAME

Log Analytics:
  Workspace: $LOG_ANALYTICS_NAME

"@ | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Configuration saved to: $outputFile" -ForegroundColor Green
Write-Host ""
