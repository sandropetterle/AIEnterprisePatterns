# ============================================================================
# GitHub Secrets Setup - Automated Script
# AI Enterprise Patterns - Configure OIDC Authentication for GitHub Actions
# ============================================================================
#
# This script automates the setup of Azure AD application and federated
# credentials for GitHub Actions OIDC authentication.
#
# Prerequisites:
# 1. Azure CLI installed and logged in (az login)
# 2. Owner or Contributor role on Azure subscription
# 3. Permissions to create Azure AD applications
#
# Usage:
# .\setup-github-secrets-simple.ps1
#
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# CONFIGURATION
# ============================================================================

$APP_NAME = "github-aipatterns-deploy"
$RESOURCE_GROUP = "rg-aipatterns-prod"  # Must match azure-setup.ps1
$REPO_OWNER = "sandropetterle"
$REPO_NAME = "AIEnterprisePatterns"

# ============================================================================
# HELPER FUNCTIONS (ASCII-safe versions)
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# ============================================================================
# VALIDATION
# ============================================================================

Write-Step "Validating Prerequisites"

# Check Azure CLI
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Success "Azure CLI version: $($azVersion.'azure-cli')"
} catch {
    Write-ErrorMessage "Azure CLI is not installed. Please install from: https://aka.ms/InstallAzureCLI"
    exit 1
}

# Check if logged in
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Success "Logged in as: $($account.user.name)"
    Write-Info "Subscription: $($account.name)"
} catch {
    Write-ErrorMessage "Not logged in to Azure. Please run: az login"
    exit 1
}

# Get IDs
$SUBSCRIPTION_ID = $account.id
$TENANT_ID = $account.tenantId

Write-Success "Subscription ID: $SUBSCRIPTION_ID"
Write-Success "Tenant ID: $TENANT_ID"

# Check if resource group exists
$rgExists = az group exists --name $RESOURCE_GROUP
if ($rgExists -eq "false") {
    Write-ErrorMessage "Resource group '$RESOURCE_GROUP' not found. Run azure-setup.ps1 first."
    exit 1
}
Write-Success "Resource group found: $RESOURCE_GROUP"

# ============================================================================
# CREATE OR UPDATE AZURE AD APPLICATION
# ============================================================================

Write-Step "Setting Up Azure AD Application"

# Check if app already exists
$existingApp = az ad app list --display-name $APP_NAME --query "[0].appId" --output tsv 2>$null

if ($existingApp) {
    Write-Info "Application '$APP_NAME' already exists"
    $APP_ID = $existingApp
} else {
    # Create new application
    az ad app create --display-name $APP_NAME --output none
    $APP_ID = az ad app list --display-name $APP_NAME --query "[0].appId" --output tsv
    Write-Success "Application created: $APP_NAME"
}

Write-Success "Application ID: $APP_ID"

# ============================================================================
# CREATE SERVICE PRINCIPAL
# ============================================================================

Write-Step "Setting Up Service Principal"

# Check if service principal exists
$existingSp = az ad sp list --display-name $APP_NAME --query "[0].id" --output tsv 2>$null

if ($existingSp) {
    Write-Info "Service Principal already exists"
    $SP_OBJECT_ID = $existingSp
} else {
    az ad sp create --id $APP_ID --output none
    $SP_OBJECT_ID = az ad sp list --display-name $APP_NAME --query "[0].id" --output tsv
    Write-Success "Service Principal created"
}

Write-Success "Service Principal Object ID: $SP_OBJECT_ID"

# ============================================================================
# ASSIGN PERMISSIONS
# ============================================================================

Write-Step "Assigning Azure Permissions"

# Check if role assignment exists
$existingRole = az role assignment list `
    --assignee $SP_OBJECT_ID `
    --role Contributor `
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" `
    --query "[0].id" `
    --output tsv 2>$null

if ($existingRole) {
    Write-Info "Contributor role already assigned"
} else {
    az role assignment create `
        --assignee $SP_OBJECT_ID `
        --role Contributor `
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" `
        --output none
    Write-Success "Contributor role assigned to resource group"
}

# ============================================================================
# CONFIGURE FEDERATED CREDENTIALS
# ============================================================================

Write-Step "Configuring Federated Credentials (OIDC)"

# Function to create or update federated credential
function Set-FederatedCredential {
    param(
        [string]$Name,
        [string]$Subject,
        [string]$Description
    )

    # Check if credential already exists
    $existing = az ad app federated-credential list --id $APP_ID --query "[?name=='$Name'].name" --output tsv 2>$null

    if ($existing) {
        Write-Info "Federated credential '$Name' already exists"
    } else {
        $credentialJson = @{
            name = $Name
            issuer = "https://token.actions.githubusercontent.com"
            subject = $Subject
            description = $Description
            audiences = @("api://AzureADTokenExchange")
        } | ConvertTo-Json -Compress

        # Save to temp file
        $tempFile = [System.IO.Path]::GetTempFileName()
        $credentialJson | Out-File -FilePath $tempFile -Encoding utf8 -NoNewline

        try {
            az ad app federated-credential create --id $APP_ID --parameters "@$tempFile" --output none
            Write-Success "Federated credential created: $Name"
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Create credentials for main branch
Set-FederatedCredential `
    -Name "github-main-branch" `
    -Subject "repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main" `
    -Description "GitHub Actions - main branch deployments"

# Create credentials for pull requests
Set-FederatedCredential `
    -Name "github-pull-requests" `
    -Subject "repo:$REPO_OWNER/$REPO_NAME:pull_request" `
    -Description "GitHub Actions - pull request builds"

# ============================================================================
# DISPLAY GITHUB SECRETS
# ============================================================================

Write-Step "GitHub Secrets Configuration"

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "   ADD THESE SECRETS TO YOUR GITHUB REPOSITORY" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Repository: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions" -ForegroundColor White
Write-Host ""
Write-Host "1. AZURE_CLIENT_ID" -ForegroundColor Yellow
Write-Host "   Value: $APP_ID" -ForegroundColor White
Write-Host ""
Write-Host "2. AZURE_TENANT_ID" -ForegroundColor Yellow
Write-Host "   Value: $TENANT_ID" -ForegroundColor White
Write-Host ""
Write-Host "3. AZURE_SUBSCRIPTION_ID" -ForegroundColor Yellow
Write-Host "   Value: $SUBSCRIPTION_ID" -ForegroundColor White
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""

# Save to file
$outputFile = "github-secrets-values.txt"
$outputContent = @"
GitHub Secrets Configuration - $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
================================================================

WARNING: CONFIDENTIAL - Do not commit this file to Git!

Add these secrets to GitHub repository:
https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions

Required Secrets:
-----------------

Secret Name: AZURE_CLIENT_ID
Value: $APP_ID

Secret Name: AZURE_TENANT_ID
Value: $TENANT_ID

Secret Name: AZURE_SUBSCRIPTION_ID
Value: $SUBSCRIPTION_ID

Instructions:
-------------
1. Go to GitHub repository settings
2. Navigate to: Settings -> Secrets and variables -> Actions
3. Click "New repository secret"
4. Add each secret with the exact name and value shown above
5. Test by triggering a workflow: Actions -> Select workflow -> Run workflow

Verification:
-------------
After adding secrets, verify the setup:
- Push to main branch to trigger deployment
- Check Actions tab for workflow runs
- Backend should deploy to: https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- Frontend should deploy to: https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io

Azure Resources:
----------------
Service Principal: $SP_OBJECT_ID
Application Name: $APP_NAME
Resource Group: $RESOURCE_GROUP
Role: Contributor

Federated Credentials:
----------------------
- github-main-branch (main branch deployments)
- github-pull-requests (PR builds and tests)

"@

$outputContent | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Configuration saved to: $outputFile" -ForegroundColor Green
Write-Host "IMPORTANT: Add $outputFile to .gitignore (contains sensitive IDs)" -ForegroundColor Red
Write-Host ""

# ============================================================================
# SUMMARY
# ============================================================================

Write-Step "Setup Complete"

Write-Host "[OK] Azure AD Application configured" -ForegroundColor Green
Write-Host "[OK] Service Principal created" -ForegroundColor Green
Write-Host "[OK] Contributor role assigned" -ForegroundColor Green
Write-Host "[OK] Federated credentials configured" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Add the three secrets to GitHub (see above)" -ForegroundColor White
Write-Host "2. Commit and push code changes to trigger deployment:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'feat: add CI/CD workflows'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host "3. Monitor deployment: https://github.com/$REPO_OWNER/$REPO_NAME/actions" -ForegroundColor White
Write-Host "4. Verify backend: https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health" -ForegroundColor White
Write-Host "5. Verify frontend: https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io" -ForegroundColor White
Write-Host ""
