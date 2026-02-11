# ============================================================================
# Azure Infrastructure Setup Script
# AI Enterprise Patterns - Phase 4 Deployment
# ============================================================================
#
# Prerequisites:
# 1. Install Azure CLI: https://aka.ms/InstallAzureCLI
# 2. Run: az login
# 3. Verify subscription: az account show
# 4. Update variables below as needed
#
# Usage:
# .\azure-setup.ps1
#
# ============================================================================

# Stop on errors
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

$APP_SERVICE_PLAN = "asp-aipatterns-prod"
$BACKEND_APP_NAME = "app-aipatterns-api-prod"   # Must be globally unique
$FRONTEND_APP_NAME = "app-aipatterns-web-prod"  # Must be globally unique

$KEY_VAULT_NAME = "kv-aipatterns-prod"  # Must be globally unique (3-24 chars, alphanumeric + hyphens)
$APP_INSIGHTS_NAME = "appi-aipatterns-prod"

# SKUs and Tiers
$SQL_SKU = "Basic"  # Basic, S0, S1, etc.
$APP_SERVICE_SKU = "B1"  # F1 (Free), B1 (Basic), S1 (Standard), P1V2 (Premium)

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
# SQL SERVER AND DATABASE
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

# Allow your current IP (for local testing)
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name "AllowMyIP" `
    --start-ip-address $myIp `
    --end-ip-address $myIp `
    --output none

Write-Success "Firewall rules configured (Azure services + your IP: $myIp)"

Write-Step "Creating Azure SQL Database"

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
        --service-objective $SQL_SKU `
        --backup-storage-redundancy Local `
        --output none
    Write-Success "SQL Database created: $SQL_DATABASE_NAME ($SQL_SKU)"
}

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
        --output none
    Write-Success "Application Insights created: $APP_INSIGHTS_NAME"
}

# Get instrumentation key
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

Write-Success "Instrumentation Key: $appInsightsKey"

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

# Build SQL connection string
$sqlConnectionString = "Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=$SQL_DATABASE_NAME;Persist Security Info=False;User ID=$SQL_ADMIN_USER;Password=$SQL_ADMIN_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Store secrets
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "SqlConnectionString" --value $sqlConnectionString --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ApplicationInsights--InstrumentationKey" --value $appInsightsKey --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ApplicationInsights--ConnectionString" --value $appInsightsConnString --output none
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "SqlAdminPassword" --value $SQL_ADMIN_PASSWORD --output none

Write-Success "Secrets stored in Key Vault"

# ============================================================================
# APP SERVICE PLAN
# ============================================================================

Write-Step "Creating App Service Plan"

$existingPlan = az appservice plan list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$APP_SERVICE_PLAN'].name" `
    --output tsv

if ($existingPlan) {
    Write-Info "App Service Plan '$APP_SERVICE_PLAN' already exists"
} else {
    az appservice plan create `
        --name $APP_SERVICE_PLAN `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --sku $APP_SERVICE_SKU `
        --is-linux `
        --output none
    Write-Success "App Service Plan created: $APP_SERVICE_PLAN ($APP_SERVICE_SKU)"
}

# ============================================================================
# BACKEND APP SERVICE (ASP.NET Core)
# ============================================================================

Write-Step "Creating Backend App Service"

$existingBackend = az webapp list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$BACKEND_APP_NAME'].name" `
    --output tsv

if ($existingBackend) {
    Write-Info "Backend App Service '$BACKEND_APP_NAME' already exists"
} else {
    az webapp create `
        --name $BACKEND_APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --plan $APP_SERVICE_PLAN `
        --runtime "DOTNETCORE:8.0" `
        --output none
    Write-Success "Backend App Service created: $BACKEND_APP_NAME"
}

Write-Step "Configuring Backend App Settings"

# Get Key Vault URI
$keyVaultUri = az keyvault show --name $KEY_VAULT_NAME --query "properties.vaultUri" --output tsv

# Configure app settings with Key Vault references
az webapp config appsettings set `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
        "ConnectionStrings__DefaultConnection=@Microsoft.KeyVault(SecretUri=$keyVaultUri/secrets/SqlConnectionString/)" `
        "ApplicationInsights__InstrumentationKey=@Microsoft.KeyVault(SecretUri=$keyVaultUri/secrets/ApplicationInsights--InstrumentationKey/)" `
        "ApplicationInsights__ConnectionString=@Microsoft.KeyVault(SecretUri=$keyVaultUri/secrets/ApplicationInsights--ConnectionString/)" `
        "ASPNETCORE_ENVIRONMENT=Production" `
    --output none

Write-Success "Backend app settings configured with Key Vault references"

# Enable managed identity
az webapp identity assign `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --output none

# Get managed identity principal ID
$backendPrincipalId = az webapp identity show `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "principalId" `
    --output tsv

# Grant Key Vault access
az keyvault set-policy `
    --name $KEY_VAULT_NAME `
    --object-id $backendPrincipalId `
    --secret-permissions get list `
    --output none

Write-Success "Managed identity enabled and Key Vault access granted"

# ============================================================================
# FRONTEND APP SERVICE (Next.js)
# ============================================================================

Write-Step "Creating Frontend App Service"

$existingFrontend = az webapp list `
    --resource-group $RESOURCE_GROUP `
    --query "[?name=='$FRONTEND_APP_NAME'].name" `
    --output tsv

if ($existingFrontend) {
    Write-Info "Frontend App Service '$FRONTEND_APP_NAME' already exists"
} else {
    az webapp create `
        --name $FRONTEND_APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --plan $APP_SERVICE_PLAN `
        --runtime "NODE:20-lts" `
        --output none
    Write-Success "Frontend App Service created: $FRONTEND_APP_NAME"
}

Write-Step "Configuring Frontend App Settings"

$backendUrl = "https://$BACKEND_APP_NAME.azurewebsites.net/api"

az webapp config appsettings set `
    --name $FRONTEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
        "NEXT_PUBLIC_API_BASE_URL=$backendUrl" `
        "NODE_ENV=production" `
        "SCM_DO_BUILD_DURING_DEPLOYMENT=true" `
    --output none

Write-Success "Frontend app settings configured"

# ============================================================================
# CORS CONFIGURATION
# ============================================================================

Write-Step "Configuring CORS for Backend"

$frontendUrl = "https://$FRONTEND_APP_NAME.azurewebsites.net"

az webapp cors add `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --allowed-origins $frontendUrl `
    --output none

Write-Success "CORS configured to allow frontend origin"

# ============================================================================
# SUMMARY
# ============================================================================

Write-Step "Deployment Summary"

Write-Host ""
Write-Host "✓ Azure infrastructure setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "Location: $LOCATION" -ForegroundColor White
Write-Host ""
Write-Host "SQL Server:" -ForegroundColor Yellow
Write-Host "  Server: $SQL_SERVER_NAME.database.windows.net" -ForegroundColor White
Write-Host "  Database: $SQL_DATABASE_NAME" -ForegroundColor White
Write-Host "  Admin User: $SQL_ADMIN_USER" -ForegroundColor White
Write-Host "  Admin Password: $SQL_ADMIN_PASSWORD" -ForegroundColor Red
Write-Host ""
Write-Host "App Services:" -ForegroundColor Yellow
Write-Host "  Backend:  https://$BACKEND_APP_NAME.azurewebsites.net" -ForegroundColor White
Write-Host "  Frontend: https://$FRONTEND_APP_NAME.azurewebsites.net" -ForegroundColor White
Write-Host ""
Write-Host "Application Insights:" -ForegroundColor Yellow
Write-Host "  Name: $APP_INSIGHTS_NAME" -ForegroundColor White
Write-Host "  Key: $appInsightsKey" -ForegroundColor White
Write-Host ""
Write-Host "Key Vault:" -ForegroundColor Yellow
Write-Host "  Name: $KEY_VAULT_NAME" -ForegroundColor White
Write-Host "  URI: $keyVaultUri" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: Save the SQL Admin Password securely!" -ForegroundColor Red
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run database migrations: dotnet ef database update --connection ""$sqlConnectionString""" -ForegroundColor White
Write-Host "2. Deploy backend: az webapp deploy or GitHub Actions" -ForegroundColor White
Write-Host "3. Deploy frontend: az webapp deploy or GitHub Actions" -ForegroundColor White
Write-Host "4. Test endpoints at the URLs above" -ForegroundColor White
Write-Host ""

# Save output to file
$outputFile = "azure-resources-output.txt"
@"
Azure Infrastructure Setup - $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
================================================================

Resource Group: $RESOURCE_GROUP
Location: $LOCATION

SQL Server:
  Server: $SQL_SERVER_NAME.database.windows.net
  Database: $SQL_DATABASE_NAME
  Admin User: $SQL_ADMIN_USER
  Admin Password: $SQL_ADMIN_PASSWORD

Connection String:
$sqlConnectionString

App Services:
  Backend API: https://$BACKEND_APP_NAME.azurewebsites.net
  Frontend Web: https://$FRONTEND_APP_NAME.azurewebsites.net

Application Insights:
  Name: $APP_INSIGHTS_NAME
  Instrumentation Key: $appInsightsKey
  Connection String: $appInsightsConnString

Key Vault:
  Name: $KEY_VAULT_NAME
  URI: $keyVaultUri

"@ | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Configuration saved to: $outputFile" -ForegroundColor Green
Write-Host ""
