# Configure Container App to access Azure Container Registry
$ErrorActionPreference = "Stop"

Write-Host "[INFO] Configuring Container App ACR access..."

# Backend Container App
$caName = "ca-aipatterns-api-prod"
$rgName = "rg-aipatterns-prod"
$acrName = "craipatternssp54426"

# Check/enable managed identity
Write-Host "[INFO] Checking managed identity for $caName..."
$ca = az containerapp show --name $caName --resource-group $rgName | ConvertFrom-Json

if (-not $ca.identity -or -not $ca.identity.principalId) {
    Write-Host "  Enabling system-assigned managed identity..."
    az containerapp identity assign --name $caName --resource-group $rgName --system-assigned | Out-Null
    Start-Sleep -Seconds 5
    $ca = az containerapp show --name $caName --resource-group $rgName | ConvertFrom-Json
}

$principalId = $ca.identity.principalId
Write-Host "[OK] Managed identity: $principalId" -ForegroundColor Green

# Get ACR resource ID
$acrId = az acr show --name $acrName --query id -o tsv
Write-Host "[INFO] ACR resource ID: $acrId"

# Assign AcrPull role
Write-Host "[INFO] Assigning AcrPull role to Container App..."
$existing = az role assignment list --assignee $principalId --scope $acrId --query "[?roleDefinitionName=='AcrPull']" | ConvertFrom-Json

if ($existing.Count -eq 0) {
    az role assignment create --assignee $principalId --role AcrPull --scope $acrId | Out-Null
    Write-Host "[OK] AcrPull role assigned" -ForegroundColor Green
} else {
    Write-Host "[OK] AcrPull role already assigned" -ForegroundColor Yellow
}

# Configure Container App to use managed identity for ACR
Write-Host "[INFO] Configuring Container App registry authentication..."
az containerapp registry set `
    --name $caName `
    --resource-group $rgName `
    --server "$acrName.azurecr.io" `
    --identity "system"

Write-Host ""
Write-Host "[OK] Container App can now pull images from ACR!" -ForegroundColor Green
Write-Host ""
Write-Host "Now doing the same for frontend Container App..."

# Frontend Container App
$caFrontendName = "ca-aipatterns-web-prod"

Write-Host "[INFO] Checking managed identity for $caFrontendName..."
$caFrontend = az containerapp show --name $caFrontendName --resource-group $rgName | ConvertFrom-Json

if (-not $caFrontend.identity -or -not $caFrontend.identity.principalId) {
    Write-Host "  Enabling system-assigned managed identity..."
    az containerapp identity assign --name $caFrontendName --resource-group $rgName --system-assigned | Out-Null
    Start-Sleep -Seconds 5
    $caFrontend = az containerapp show --name $caFrontendName --resource-group $rgName | ConvertFrom-Json
}

$principalIdFrontend = $caFrontend.identity.principalId
Write-Host "[OK] Managed identity: $principalIdFrontend" -ForegroundColor Green

# Assign AcrPull role for frontend
Write-Host "[INFO] Assigning AcrPull role to frontend Container App..."
$existingFrontend = az role assignment list --assignee $principalIdFrontend --scope $acrId --query "[?roleDefinitionName=='AcrPull']" | ConvertFrom-Json

if ($existingFrontend.Count -eq 0) {
    az role assignment create --assignee $principalIdFrontend --role AcrPull --scope $acrId | Out-Null
    Write-Host "[OK] AcrPull role assigned" -ForegroundColor Green
} else {
    Write-Host "[OK] AcrPull role already assigned" -ForegroundColor Yellow
}

# Configure frontend Container App registry
Write-Host "[INFO] Configuring frontend Container App registry authentication..."
az containerapp registry set `
    --name $caFrontendName `
    --resource-group $rgName `
    --server "$acrName.azurecr.io" `
    --identity "system"

Write-Host ""
Write-Host "[OK] Both Container Apps configured successfully!" -ForegroundColor Green
