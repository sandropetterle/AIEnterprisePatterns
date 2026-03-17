# deploy.ps1 — Deploy AI Enterprise Patterns infrastructure via Bicep
#
# CRITICAL: Always uses --mode Incremental (never Complete).
# Complete mode would delete resources not in this template.
#
# Prerequisites:
#   - Azure CLI: az login
#   - Bicep: az bicep install
#   - Contributor role on rg-aipatterns-prod
#   - __SUBSCRIPTION_ID__ replaced in main.parameters.prod.json (one-time setup)
#
# Usage:
#   ./infrastructure/deploy.ps1           # validate + what-if + deploy
#   ./infrastructure/deploy.ps1 -WhatIf   # validate + what-if only (no deploy)

param(
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$ResourceGroup = 'rg-aipatterns-prod'
$TemplateFile = "$PSScriptRoot/main.bicep"
$ParametersFile = "$PSScriptRoot/main.parameters.prod.json"
$DeploymentName = "aipatterns-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "=== AI Enterprise Patterns — Infrastructure Deploy ===" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Validate (az bicep build compiles to ARM JSON locally) ────────────

Write-Host "Step 1/4: Validating Bicep templates..." -ForegroundColor Yellow
az bicep build --file $TemplateFile
if ($LASTEXITCODE -ne 0) { throw "Bicep validation failed." }
Write-Host "  ✓ Templates valid" -ForegroundColor Green
Write-Host ""

# ── Step 2: What-if (show planned changes before applying) ───────────────────

Write-Host "Step 2/4: Running what-if (preview changes)..." -ForegroundColor Yellow
az deployment group what-if `
    --resource-group $ResourceGroup `
    --template-file $TemplateFile `
    --parameters @$ParametersFile `
    --mode Incremental

if ($LASTEXITCODE -ne 0) { throw "What-if failed." }
Write-Host ""

if ($WhatIf) {
    Write-Host "  --WhatIf flag set. Stopping before deploy." -ForegroundColor Cyan
    exit 0
}

# ── Step 3: Confirm ───────────────────────────────────────────────────────────

Write-Host "Step 3/4: Review the what-if output above." -ForegroundColor Yellow
$confirm = Read-Host "Proceed with deployment? (yes/no)"
if ($confirm -ne 'yes') {
    Write-Host "  Deployment cancelled." -ForegroundColor Red
    exit 0
}
Write-Host ""

# ── Step 4: Deploy ────────────────────────────────────────────────────────────

Write-Host "Step 4/4: Deploying ($DeploymentName)..." -ForegroundColor Yellow
az deployment group create `
    --name $DeploymentName `
    --resource-group $ResourceGroup `
    --template-file $TemplateFile `
    --parameters @$ParametersFile `
    --mode Incremental `
    --output table

if ($LASTEXITCODE -ne 0) { throw "Deployment failed." }

Write-Host ""
Write-Host "  ✓ Deployment complete: $DeploymentName" -ForegroundColor Green
Write-Host ""
Write-Host "  Post-deploy checklist:" -ForegroundColor Cyan
Write-Host "  1. Set Key Vault secrets if not already set:"
Write-Host "       az keyvault secret set --vault-name kv-aipatterns-0754755 --name sql-connection-string --value '...'"
Write-Host "  2. Verify health endpoints:"
Write-Host "       curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health"
Write-Host "  3. CI/CD will update image tags automatically on next push to main."
