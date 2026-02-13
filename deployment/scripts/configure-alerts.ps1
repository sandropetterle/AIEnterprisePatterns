# Configure Application Insights Alerts for AI Enterprise Patterns
# This script creates 4 critical production alerts
# Prerequisites: Azure CLI installed and authenticated (az login)

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "rg-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$AppInsightsName = "appi-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$ActionGroupEmail = "devops@example.com"
)

Write-Host "🚀 Configuring Application Insights Alerts..." -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Gray
Write-Host "App Insights: $AppInsightsName" -ForegroundColor Gray
Write-Host ""

# Get Application Insights resource ID
Write-Host "📍 Getting Application Insights resource ID..." -ForegroundColor Yellow
$appInsightsId = az monitor app-insights component show `
    --app $AppInsightsName `
    --resource-group $ResourceGroup `
    --query 'id' `
    --output tsv

if (-not $appInsightsId) {
    Write-Host "❌ Error: Application Insights resource not found!" -ForegroundColor Red
    Write-Host "   Make sure the resource exists: $AppInsightsName in $ResourceGroup" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found Application Insights: $appInsightsId" -ForegroundColor Green
Write-Host ""

# Create Action Group (email notification)
Write-Host "📧 Creating Action Group for email notifications..." -ForegroundColor Yellow
$actionGroupName = "ag-aipatterns-alerts"

# Check if action group exists
$existingActionGroup = az monitor action-group show `
    --name $actionGroupName `
    --resource-group $ResourceGroup `
    2>$null

if ($existingActionGroup) {
    Write-Host "⚠️  Action Group already exists: $actionGroupName" -ForegroundColor Yellow
} else {
    az monitor action-group create `
        --name $actionGroupName `
        --resource-group $ResourceGroup `
        --short-name "AIPatAlert" `
        --email-receiver email devops $ActionGroupEmail

    Write-Host "✅ Created Action Group: $actionGroupName" -ForegroundColor Green
}

$actionGroupId = az monitor action-group show `
    --name $actionGroupName `
    --resource-group $ResourceGroup `
    --query 'id' `
    --output tsv

Write-Host ""

# Function to create or update metric alert
function New-MetricAlert {
    param(
        [string]$Name,
        [string]$Description,
        [string]$Condition,
        [int]$Severity,
        [int]$WindowSize,
        [int]$Frequency
    )

    Write-Host "🔔 Creating alert: $Name..." -ForegroundColor Yellow

    # Check if alert exists
    $existingAlert = az monitor metrics alert show `
        --name $Name `
        --resource-group $ResourceGroup `
        2>$null

    if ($existingAlert) {
        Write-Host "   ⚠️  Alert already exists, updating..." -ForegroundColor Yellow

        az monitor metrics alert update `
            --name $Name `
            --resource-group $ResourceGroup `
            --description $Description `
            --severity $Severity `
            --action $actionGroupId `
            --enabled true
    } else {
        az monitor metrics alert create `
            --name $Name `
            --resource-group $ResourceGroup `
            --scopes $appInsightsId `
            --description $Description `
            --condition $Condition `
            --window-size "${WindowSize}m" `
            --evaluation-frequency "${Frequency}m" `
            --severity $Severity `
            --action $actionGroupId
    }

    Write-Host "   ✅ Alert configured: $Name" -ForegroundColor Green
}

# Alert 1: High Error Rate
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Alert 1: High Error Rate (>5% over 5 minutes)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

New-MetricAlert `
    -Name "alert-aipatterns-high-error-rate" `
    -Description "Alert when failed request rate exceeds 5% over 5 minutes" `
    -Condition "avg requests/failed > 5" `
    -Severity 2 `
    -WindowSize 5 `
    -Frequency 5

Write-Host ""

# Alert 2: Slow Response Time
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Alert 2: Slow Response Time (P95 >2s over 10 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

New-MetricAlert `
    -Name "alert-aipatterns-slow-response" `
    -Description "Alert when P95 response time exceeds 2 seconds over 10 minutes" `
    -Condition "avg requests/duration > 2000" `
    -Severity 3 `
    -WindowSize 10 `
    -Frequency 5

Write-Host ""

# Alert 3: Availability Drop
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Alert 3: Availability Drop (<99% over 5 minutes)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

New-MetricAlert `
    -Name "alert-aipatterns-availability-drop" `
    -Description "Alert when availability drops below 99% over 5 minutes" `
    -Condition "avg availabilityResults/availabilityPercentage < 99" `
    -Severity 1 `
    -WindowSize 5 `
    -Frequency 5

Write-Host ""

# Alert 4: Exception Spike
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Alert 4: Exception Spike (>10 exceptions over 5 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

New-MetricAlert `
    -Name "alert-aipatterns-exception-spike" `
    -Description "Alert when exception count exceeds 10 over 5 minutes" `
    -Condition "count exceptions/count > 10" `
    -Severity 2 `
    -WindowSize 5 `
    -Frequency 5

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ All alerts configured successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "📊 View alerts in Azure Portal:" -ForegroundColor Cyan
Write-Host "   https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/alertsV2" -ForegroundColor Gray
Write-Host ""
Write-Host "📧 Email notifications will be sent to: $ActionGroupEmail" -ForegroundColor Cyan
Write-Host "   Update the email in the Action Group if needed:" -ForegroundColor Gray
Write-Host "   https://portal.azure.com/#view/Microsoft_Azure_Monitoring/ActionGroupBlade" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update the email address in the Action Group to your actual team email" -ForegroundColor White
Write-Host "2. Test the alerts by triggering them (e.g., cause errors, slow responses)" -ForegroundColor White
Write-Host "3. Verify email notifications are received" -ForegroundColor White
Write-Host "4. Create a monitoring dashboard to visualize these metrics" -ForegroundColor White
