$appId = "07c7fbe8-959d-4f60-9570-c43533f6acd2"
$appObjectId = az ad app show --id $appId --query id -o tsv

# Get existing credentials
Write-Host "[INFO] Getting existing federated credentials..."
$creds = az ad app federated-credential list --id $appObjectId | ConvertFrom-Json

# Delete each credential
foreach ($cred in $creds) {
    Write-Host "  Deleting: $($cred.name)" -ForegroundColor Yellow
    az ad app federated-credential delete --id $appObjectId --federated-credential-id $cred.id 2>$null
}

# Create new credential with correct subject
Write-Host "[INFO] Creating new federated credential..."

$credentialJson = @"
{
    "name": "github-main-branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
}
"@

$tempFile = [System.IO.Path]::GetTempFileName()
$credentialJson | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline

az ad app federated-credential create --id $appObjectId --parameters $tempFile

Remove-Item $tempFile

Write-Host "[OK] Federated credential created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Subject: repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/main" -ForegroundColor Cyan
