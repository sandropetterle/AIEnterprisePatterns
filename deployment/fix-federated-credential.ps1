# Fix Federated Identity Credential for GitHub Actions
# This script fixes the federated credential subject mismatch error

param(
    [string]$RepoOwner = "sandropetterle",
    [string]$RepoName = "AIEnterprisePatterns"
)

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Fixing federated credential for GitHub Actions OIDC..." -ForegroundColor Cyan
Write-Host ""

# Get the application
$appDisplayName = "GitHub-$RepoName"
Write-Host "[INFO] Looking for Azure AD app: $appDisplayName"

$app = az ad app list --display-name $appDisplayName | ConvertFrom-Json
if (-not $app) {
    Write-Host "[ERROR] Azure AD application not found: $appDisplayName" -ForegroundColor Red
    Write-Host "[INFO] Please run setup-github-secrets.ps1 first" -ForegroundColor Yellow
    exit 1
}

$appId = $app[0].appId
$objectId = $app[0].id
Write-Host "[OK] Found app: $appDisplayName (AppId: $appId)" -ForegroundColor Green

# Delete existing federated credentials (if any)
Write-Host "[INFO] Removing old federated credentials..."
$existing = az ad app federated-credential list --id $objectId | ConvertFrom-Json
foreach ($cred in $existing) {
    Write-Host "  Deleting: $($cred.name)"
    az ad app federated-credential delete --id $objectId --federated-credential-id $cred.id 2>$null
}

# Create new federated credential with correct subject
Write-Host "[INFO] Creating new federated credential..."

$credentialName = "GitHub-$RepoOwner-$RepoName-main"
$subject = "repo:$RepoOwner/$RepoName:ref:refs/heads/main"

$credential = @{
    name = $credentialName
    issuer = "https://token.actions.githubusercontent.com"
    subject = $subject
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json

# Save to temp file
$tempFile = [System.IO.Path]::GetTempFileName()
$credential | Out-File -FilePath $tempFile -Encoding UTF8

az ad app federated-credential create --id $objectId --parameters $tempFile

Remove-Item $tempFile

Write-Host "[OK] Federated credential created successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Credential Details:" -ForegroundColor Cyan
Write-Host "  Name:     $credentialName"
Write-Host "  Subject:  $subject"
Write-Host "  Issuer:   https://token.actions.githubusercontent.com"
Write-Host "  Audience: api://AzureADTokenExchange"
Write-Host ""
Write-Host "[OK] Fix complete! GitHub Actions should now authenticate successfully." -ForegroundColor Green
Write-Host "[INFO] Retry your failed workflow at: https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor Cyan
