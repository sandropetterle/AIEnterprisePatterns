# Create Azure Monitoring Dashboard for AI Enterprise Patterns
# This script creates a custom dashboard with key metrics
# Prerequisites: Azure CLI installed and authenticated (az login)

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "rg-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$AppInsightsName = "appi-aipatterns-prod",

    [Parameter(Mandatory=$false)]
    [string]$DashboardName = "AIPatterns Production Monitoring"
)

Write-Host "🚀 Creating Azure Monitoring Dashboard..." -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Gray
Write-Host "App Insights: $AppInsightsName" -ForegroundColor Gray
Write-Host "Dashboard Name: $DashboardName" -ForegroundColor Gray
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
    exit 1
}

Write-Host "✅ Found Application Insights: $appInsightsId" -ForegroundColor Green
Write-Host ""

# Dashboard JSON definition
$dashboardJson = @"
{
  "properties": {
    "lenses": [
      {
        "order": 0,
        "parts": [
          {
            "position": {
              "x": 0,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "requests\n| where timestamp > ago(24h)\n| summarize count() by bin(timestamp, 15m)\n| render timechart"
                }
              ],
              "settings": {
                "content": {
                  "title": "Request Rate (Last 24h)",
                  "subtitle": "Requests per 15 minutes"
                }
              }
            }
          },
          {
            "position": {
              "x": 6,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "requests\n| where timestamp > ago(24h)\n| summarize avg(duration), percentile(duration, 95), percentile(duration, 99) by bin(timestamp, 15m)\n| render timechart"
                }
              ],
              "settings": {
                "content": {
                  "title": "Response Time (Last 24h)",
                  "subtitle": "Average, P95, P99 in milliseconds"
                }
              }
            }
          },
          {
            "position": {
              "x": 0,
              "y": 4,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "requests\n| where timestamp > ago(24h)\n| summarize Total = count(), Failed = countif(success == false) by bin(timestamp, 15m)\n| extend ErrorRate = round(100.0 * Failed / Total, 2)\n| render timechart"
                }
              ],
              "settings": {
                "content": {
                  "title": "Error Rate (Last 24h)",
                  "subtitle": "Percentage of failed requests"
                }
              }
            }
          },
          {
            "position": {
              "x": 6,
              "y": 4,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "availabilityResults\n| where timestamp > ago(24h)\n| summarize Availability = round(100.0 * countif(success == true) / count(), 2) by bin(timestamp, 15m)\n| render timechart"
                }
              ],
              "settings": {
                "content": {
                  "title": "Availability (Last 24h)",
                  "subtitle": "Percentage of successful health checks"
                }
              }
            }
          },
          {
            "position": {
              "x": 0,
              "y": 8,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "requests\n| where timestamp > ago(1h)\n| top 5 by duration desc\n| project timestamp, name, url, duration, resultCode"
                }
              ],
              "settings": {
                "content": {
                  "title": "Top 5 Slowest Requests (Last Hour)",
                  "subtitle": "Operation names and durations"
                }
              }
            }
          },
          {
            "position": {
              "x": 6,
              "y": 8,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "inputs": [
                {
                  "name": "resourceTypeMode",
                  "value": "components"
                },
                {
                  "name": "ComponentId",
                  "value": "$appInsightsId"
                },
                {
                  "name": "Query",
                  "value": "exceptions\n| where timestamp > ago(1h)\n| summarize count() by type, outerMessage\n| order by count_ desc\n| take 10"
                }
              ],
              "settings": {
                "content": {
                  "title": "Recent Exceptions (Last Hour)",
                  "subtitle": "Exception types and messages"
                }
              }
            }
          }
        ]
      }
    ],
    "metadata": {
      "model": {
        "timeRange": {
          "value": {
            "relative": {
              "duration": 24,
              "timeUnit": 1
            }
          },
          "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  },
  "name": "$DashboardName",
  "type": "Microsoft.Portal/dashboards",
  "location": "centralus",
  "tags": {
    "hidden-title": "$DashboardName"
  }
}
"@

# Save dashboard JSON to temp file
$tempFile = [System.IO.Path]::GetTempFileName() + ".json"
$dashboardJson | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "📊 Creating dashboard..." -ForegroundColor Yellow

# Create dashboard
$dashboardId = "dashboard-aipatterns-prod-" + (Get-Random)
az portal dashboard create `
    --name $dashboardId `
    --resource-group $ResourceGroup `
    --input-path $tempFile `
    --location centralus

# Clean up temp file
Remove-Item $tempFile

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ Dashboard created successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access your dashboard:" -ForegroundColor Cyan
Write-Host "   https://portal.azure.com/#dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "Dashboard contains:" -ForegroundColor Yellow
Write-Host "  ✓ Request Rate (24h)" -ForegroundColor White
Write-Host "  ✓ Response Time - Avg, P95, P99 (24h)" -ForegroundColor White
Write-Host "  ✓ Error Rate (24h)" -ForegroundColor White
Write-Host "  ✓ Availability (24h)" -ForegroundColor White
Write-Host "  ✓ Top 5 Slowest Requests (1h)" -ForegroundColor White
Write-Host "  ✓ Recent Exceptions (1h)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Pin the dashboard to your Azure Portal homepage" -ForegroundColor White
Write-Host "2. Share the dashboard with your team" -ForegroundColor White
Write-Host "3. Set up automatic refresh (click 'Auto refresh' in toolbar)" -ForegroundColor White
