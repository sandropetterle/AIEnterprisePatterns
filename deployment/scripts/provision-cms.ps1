<#
.SYNOPSIS
    Provisions Azure infrastructure for Strapi 5 CMS.

.DESCRIPTION
    Creates:
    - Azure Database for MySQL Flexible Server (free tier, 12 months)
    - Azure Blob Storage account + container for media uploads
    - Azure Container App for Strapi 5
    - Container App Environment (reuses existing if present)

    Estimated monthly cost: ~$10-15 (free MySQL tier for 12 months, then ~$13/mo)

.PARAMETER ResourceGroup
    Azure Resource Group (default: rg-aipatterns-prod)

.PARAMETER Location
    Azure region (default: centralus — matches existing apps)

.PARAMETER MysqlAdminPassword
    Password for MySQL admin user. REQUIRED. Store securely (Key Vault / env var).

.EXAMPLE
    ./provision-cms.ps1 -MysqlAdminPassword "YourSecurePass123!"
#>
param(
    [string]$ResourceGroup  = "rg-aipatterns-prod",
    [string]$Location       = "centralus",
    [string]$ContainerRegistry = "craipatternssp54426",
    [string]$CmsImage       = "aipatterns-cms",
    [string]$MysqlServerName = "mysql-aipatterns-cms",
    [string]$MysqlAdminUser  = "strapiAdmin",
    [Parameter(Mandatory)]
    [string]$MysqlAdminPassword,
    [string]$StorageAccountName = "staipatternsmedia",
    [string]$StorageContainer   = "strapi-media",
    [string]$ContainerAppEnv    = "cae-aipatterns-prod",
    [string]$CmsContainerApp    = "ca-aipatterns-cms-prod"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Helpers ────────────────────────────────────────────────────────────────
function Log-Step { param([string]$msg) Write-Host "`n▶ $msg" -ForegroundColor Cyan }
function Log-Ok   { param([string]$msg) Write-Host "  ✓ $msg" -ForegroundColor Green }
function Log-Info { param([string]$msg) Write-Host "  · $msg" -ForegroundColor Gray }

# ── 0. Verify logged in ────────────────────────────────────────────────────
Log-Step "Verifying Azure CLI login"
$account = az account show --query name -o tsv 2>$null
if (-not $account) {
    Write-Error "Not logged in. Run: az login"
    exit 1
}
Log-Ok "Logged in as: $account"

# ── 1. MySQL Flexible Server (free tier) ──────────────────────────────────
Log-Step "Creating MySQL Flexible Server: $MysqlServerName"
$mysqlExists = az mysql flexible-server show `
    --resource-group $ResourceGroup `
    --name $MysqlServerName `
    --query name -o tsv 2>$null

if ($mysqlExists) {
    Log-Info "MySQL server already exists — skipping creation"
} else {
    az mysql flexible-server create `
        --resource-group $ResourceGroup `
        --name $MysqlServerName `
        --location $Location `
        --admin-user $MysqlAdminUser `
        --admin-password $MysqlAdminPassword `
        --sku-name Standard_B1ms `
        --tier Burstable `
        --storage-size 32 `
        --version 8.0.21 `
        --public-access 0.0.0.0 `
        --yes

    Log-Ok "MySQL server created"
}

# Create the strapi_cms database
Log-Step "Creating database: strapi_cms"
az mysql flexible-server db create `
    --resource-group $ResourceGroup `
    --server-name $MysqlServerName `
    --database-name strapi_cms 2>$null
Log-Ok "Database ready"

# Allow Azure services access
Log-Step "Configuring MySQL firewall"
az mysql flexible-server firewall-rule create `
    --resource-group $ResourceGroup `
    --name $MysqlServerName `
    --rule-name AllowAzureServices `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 2>$null
Log-Ok "Firewall rule set"

# Get MySQL hostname
$mysqlHost = az mysql flexible-server show `
    --resource-group $ResourceGroup `
    --name $MysqlServerName `
    --query fullyQualifiedDomainName -o tsv

Log-Info "MySQL host: $mysqlHost"

# ── 2. Azure Blob Storage ─────────────────────────────────────────────────
Log-Step "Creating Storage Account: $StorageAccountName"
$storageExists = az storage account show `
    --resource-group $ResourceGroup `
    --name $StorageAccountName `
    --query name -o tsv 2>$null

if ($storageExists) {
    Log-Info "Storage account already exists — skipping creation"
} else {
    az storage account create `
        --resource-group $ResourceGroup `
        --name $StorageAccountName `
        --location $Location `
        --sku Standard_LRS `
        --kind StorageV2 `
        --access-tier Hot `
        --allow-blob-public-access false
    Log-Ok "Storage account created"
}

$storageKey = az storage account keys list `
    --resource-group $ResourceGroup `
    --account-name $StorageAccountName `
    --query "[0].value" -o tsv

# Create media container
az storage container create `
    --account-name $StorageAccountName `
    --account-key $storageKey `
    --name $StorageContainer `
    --public-access off 2>$null
Log-Ok "Blob container '$StorageContainer' ready"

$storageUrl = "https://$StorageAccountName.blob.core.windows.net"

# ── 3. Container App for Strapi ───────────────────────────────────────────
Log-Step "Creating Strapi Container App: $CmsContainerApp"

# Generate random secrets for Strapi
$appKeys      = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString() + [System.Guid]::NewGuid().ToString()))
$apiTokenSalt = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))
$adminJwt     = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))
$transferSalt = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))
$jwtSecret    = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))

$cmsExists = az containerapp show `
    --resource-group $ResourceGroup `
    --name $CmsContainerApp `
    --query name -o tsv 2>$null

if ($cmsExists) {
    Log-Info "Container App already exists — updating image"
    az containerapp update `
        --resource-group $ResourceGroup `
        --name $CmsContainerApp `
        --image "$ContainerRegistry.azurecr.io/${CmsImage}:latest"
} else {
    az containerapp create `
        --resource-group $ResourceGroup `
        --name $CmsContainerApp `
        --environment $ContainerAppEnv `
        --image "$ContainerRegistry.azurecr.io/${CmsImage}:latest" `
        --registry-server "$ContainerRegistry.azurecr.io" `
        --target-port 1337 `
        --ingress external `
        --min-replicas 0 `
        --max-replicas 2 `
        --cpu 0.25 `
        --memory 0.5Gi `
        --env-vars `
            "DATABASE_CLIENT=mysql2" `
            "DATABASE_HOST=$mysqlHost" `
            "DATABASE_PORT=3306" `
            "DATABASE_NAME=strapi_cms" `
            "DATABASE_USERNAME=$MysqlAdminUser" `
            "DATABASE_PASSWORD=secretref:db-password" `
            "DATABASE_SSL=true" `
            "APP_KEYS=secretref:app-keys" `
            "API_TOKEN_SALT=secretref:api-token-salt" `
            "ADMIN_JWT_SECRET=secretref:admin-jwt-secret" `
            "TRANSFER_TOKEN_SALT=secretref:transfer-token-salt" `
            "JWT_SECRET=secretref:jwt-secret" `
            "STORAGE_ACCOUNT=$StorageAccountName" `
            "STORAGE_ACCOUNT_KEY=secretref:storage-key" `
            "STORAGE_CONTAINER_NAME=$StorageContainer" `
            "STORAGE_URL=$storageUrl" `
            "NODE_ENV=production" `
        --secrets `
            "db-password=$MysqlAdminPassword" `
            "app-keys=$appKeys" `
            "api-token-salt=$apiTokenSalt" `
            "admin-jwt-secret=$adminJwt" `
            "transfer-token-salt=$transferSalt" `
            "jwt-secret=$jwtSecret" `
            "storage-key=$storageKey"
    Log-Ok "Container App created"
}

# ── 4. Summary ────────────────────────────────────────────────────────────
$cmsFqdn = az containerapp show `
    --resource-group $ResourceGroup `
    --name $CmsContainerApp `
    --query properties.configuration.ingress.fqdn -o tsv 2>$null

Log-Step "Provisioning complete"
Write-Host ""
Write-Host "  MySQL Host   : $mysqlHost" -ForegroundColor White
Write-Host "  Storage URL  : $storageUrl" -ForegroundColor White
Write-Host "  Strapi CMS   : https://$cmsFqdn" -ForegroundColor White
Write-Host "  Admin Panel  : https://$cmsFqdn/admin" -ForegroundColor White
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "   1. Build and push CMS image: docker build -t $ContainerRegistry.azurecr.io/${CmsImage}:latest ./cms && docker push ..." -ForegroundColor Yellow
Write-Host "   2. Open admin panel and create admin user" -ForegroundColor Yellow
Write-Host "   3. Create a read-only API token and add it to Next.js STRAPI_API_TOKEN env var" -ForegroundColor Yellow
Write-Host "   4. Run seed script: STRAPI_URL=https://$cmsFqdn STRAPI_API_TOKEN=<token> npx ts-node cms/data/seed.ts" -ForegroundColor Yellow
Write-Host ""
