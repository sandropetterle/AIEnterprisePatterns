# Configure Application Insights Alerts for AI Enterprise Patterns
# Simplified version with correct Azure CLI syntax

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "rg-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$AppInsightsName = "appi-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$ActionGroupEmail = "sandropetterle@hotmail.com"
)

Write-Host "🚀 Configuring Application Insights Alerts..." -ForegroundColor Cyan
Write-Host ""

# Get Application Insights resource ID
Write-Host "📍 Getting Application Insights resource ID..." -ForegroundColor Yellow
$appInsightsId = (az monitor app-insights component show --app $AppInsightsName --resource-group $ResourceGroup --query 'id' -o tsv)

if (-not $appInsightsId) {
    Write-Host "❌ Error: Application Insights resource not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found: $appInsightsId" -ForegroundColor Green
Write-Host ""

# Create Action Group
Write-Host "📧 Creating Action Group..." -ForegroundColor Yellow
$actionGroupName = "ag-aipatterns-alerts"

# Delete if exists (for clean recreation)
az monitor action-group delete --name $actionGroupName --resource-group $ResourceGroup 2>$null

# Create action group with email
az monitor action-group create `
    --name $actionGroupName `
    --resource-group $ResourceGroup `
    --short-name "AIPatAlert" `
    --action email devops $ActionGroupEmail

$actionGroupId = (az monitor action-group show --name $actionGroupName --resource-group $ResourceGroup --query 'id' -o tsv)
Write-Host "✅ Action Group created: $actionGroupId" -ForegroundColor Green
Write-Host ""

# Create Alerts
Write-Host "🔔 Creating alerts..." -ForegroundColor Yellow

# Alert 1: High Error Rate
Write-Host "  1. High Error Rate alert..." -ForegroundColor Gray
az monitor metrics alert create `
    --name "alert-aipatterns-high-error-rate" `
    --resource-group $ResourceGroup `
    --scopes $appInsightsId `
    --description "Alert when failed request rate exceeds 5% over 5 minutes" `
    --condition "avg requests/failed > 5" `
    --window-size 5m `
    --evaluation-frequency 5m `
    --severity 2 `
    --action $actionGroupId 2>$null

# Alert 2: Slow Response
Write-Host "  2. Slow Response alert..." -ForegroundColor Gray
az monitor metrics alert create `
    --name "alert-aipatterns-slow-response" `
    --resource-group $ResourceGroup `
    --scopes $appInsightsId `
    --description "Alert when response time exceeds 2 seconds" `
    --condition "avg requests/duration > 2000" `
    --window-size 10m `
    --evaluation-frequency 5m `
    --severity 3 `
    --action $actionGroupId 2>$null

# Alert 3: Availability Drop
Write-Host "  3. Availability Drop alert..." -ForegroundColor Gray
az monitor metrics alert create `
    --name "alert-aipatterns-availability-drop" `
    --resource-group $ResourceGroup `
    --scopes $appInsightsId `
    --description "Alert when availability drops below 99%" `
    --condition "avg availabilityResults/availabilityPercentage < 99" `
    --window-size 5m `
    --evaluation-frequency 5m `
    --severity 1 `
    --action $actionGroupId 2>$null

# Alert 4: Exception Spike
Write-Host "  4. Exception Spike alert..." -ForegroundColor Gray
az monitor metrics alert create `
    --name "alert-aipatterns-exception-spike" `
    --resource-group $ResourceGroup `
    --scopes $appInsightsId `
    --description "Alert when exception count exceeds 10" `
    --condition "count exceptions/count > 10" `
    --window-size 5m `
    --evaluation-frequency 5m `
    --severity 2 `
    --action $actionGroupId 2>$null

Write-Host ""
Write-Host "✅ All alerts configured successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 View alerts: https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/alertsV2" -ForegroundColor Cyan
Write-Host "📧 Email notifications: $ActionGroupEmail" -ForegroundColor Cyan
