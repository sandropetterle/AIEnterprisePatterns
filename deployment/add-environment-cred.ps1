$appId = "07c7fbe8-959d-4f60-9570-c43533f6acd2"
$appObjectId = az ad app show --id $appId --query id -o tsv

Write-Host "[INFO] Adding federated credential for Production environment..."

$credentialJson = @"
{
    "name": "github-environment-production",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:sandropetterle/AIEnterprisePatterns:environment:Production",
    "audiences": ["api://AzureADTokenExchange"]
}
"@

$tempFile = [System.IO.Path]::GetTempFileName()
$credentialJson | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline

az ad app federated-credential create --id $appObjectId --parameters $tempFile

Remove-Item $tempFile

Write-Host "[OK] Production environment credential created!" -ForegroundColor Green
Write-Host ""
Write-Host "Subject: repo:sandropetterle/AIEnterprisePatterns:environment:Production" -ForegroundColor Cyan
