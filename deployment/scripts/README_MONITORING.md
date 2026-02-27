# Monitoring Configuration Scripts

**Last Updated:** 2026-02-27
**Audience:** Infrastructure Engineers, DevOps
**Purpose:** Document the PowerShell scripts for configuring Azure Application Insights alerts and dashboards.

> ⚠️ **Alert threshold values** are defined in the authoritative reference:
> [../../documentation/operations/MONITORING_GUIDE.md](../../documentation/operations/MONITORING_GUIDE.md)
> The thresholds below reflect those values. If thresholds change, update MONITORING_GUIDE.md first, then update these scripts.

This folder contains PowerShell scripts to configure Application Insights monitoring for the AI Enterprise Patterns Library.

## Prerequisites

1. **Azure CLI** installed ([Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
2. **Authenticated** with Azure: `az login`
3. **Subscription selected**: `az account set --subscription <subscription-id>`
4. **Application Insights resource deployed** (should exist from Phase 4 deployment)

## Scripts

### 1. configure-alerts.ps1

Configures 4 critical production alerts for monitoring application health.

**Alerts Created:**
- ✅ High Error Rate (>5% over 5 min) - Severity 2
- ✅ Slow Response Time (P95 >2s over 10 min) - Severity 3
- ✅ Availability Drop (<99% over 5 min) - Severity 1 (Critical)
- ✅ Exception Spike (>10 exceptions over 5 min) - Severity 2

**Usage:**

```powershell
# Default (uses rg-aipatterns-prod and appi-aipatterns-prod)
.\configure-alerts.ps1

# Custom parameters
.\configure-alerts.ps1 `
    -ResourceGroup "rg-aipatterns-prod" `
    -AppInsightsName "appi-aipatterns-prod" `
    -ActionGroupEmail "your-team@example.com"
```

**Parameters:**
- `-ResourceGroup`: Azure resource group name (default: rg-aipatterns-prod)
- `-AppInsightsName`: Application Insights resource name (default: appi-aipatterns-prod)
- `-ActionGroupEmail`: Email address for alert notifications (default: devops@example.com)

**After Running:**
1. Update the email address in the Action Group to your actual team email
2. Test alerts by triggering them (e.g., cause errors in the application)
3. Verify email notifications are received
4. View alerts in [Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/alertsV2)

---

### 2. create-monitoring-dashboard.ps1

Creates a custom Azure Portal dashboard with 6 key monitoring tiles.

**Dashboard Tiles:**
1. ✅ Request Rate (last 24h) - Line chart
2. ✅ Response Time - Avg, P95, P99 (last 24h) - Line chart
3. ✅ Error Rate (last 24h) - Line chart
4. ✅ Availability (last 24h) - Line chart
5. ✅ Top 5 Slowest Requests (last hour) - Table
6. ✅ Recent Exceptions (last hour) - Table

**Usage:**

```powershell
# Default
.\create-monitoring-dashboard.ps1

# Custom parameters
.\create-monitoring-dashboard.ps1 `
    -ResourceGroup "rg-aipatterns-prod" `
    -AppInsightsName "appi-aipatterns-prod" `
    -DashboardName "My Custom Dashboard Name"
```

**Parameters:**
- `-ResourceGroup`: Azure resource group name (default: rg-aipatterns-prod)
- `-AppInsightsName`: Application Insights resource name (default: appi-aipatterns-prod)
- `-DashboardName`: Dashboard display name (default: "AIPatterns Production Monitoring")

**After Running:**
1. Navigate to https://portal.azure.com/#dashboard
2. Find your dashboard in the list
3. Pin it to your homepage for quick access
4. Share it with your team
5. Enable auto-refresh (click "Auto refresh" in toolbar)

---

## Quick Start

Run both scripts to set up complete monitoring:

```powershell
# Navigate to scripts folder
cd deployment/scripts

# Configure alerts (update email!)
.\configure-alerts.ps1 -ActionGroupEmail "your-team@example.com"

# Create dashboard
.\create-monitoring-dashboard.ps1
```

---

## Verification

After running the scripts, verify everything is working:

### Check Alerts
```bash
# List all alerts
az monitor metrics alert list \
    --resource-group rg-aipatterns-prod \
    --output table

# Check alert details
az monitor metrics alert show \
    --name alert-aipatterns-high-error-rate \
    --resource-group rg-aipatterns-prod
```

### Check Action Group
```bash
# List action groups
az monitor action-group list \
    --resource-group rg-aipatterns-prod \
    --output table

# Check action group details
az monitor action-group show \
    --name ag-aipatterns-alerts \
    --resource-group rg-aipatterns-prod
```

### View Dashboard
1. Go to https://portal.azure.com/#dashboard
2. Look for "AIPatterns Production Monitoring" in the dashboard list
3. Verify all 6 tiles are rendering data

---

## Troubleshooting

### Error: "Application Insights resource not found"

**Solution:**
1. Verify the resource exists: `az monitor app-insights component list --resource-group rg-aipatterns-prod`
2. Check the resource name matches: `appi-aipatterns-prod`
3. Ensure you're authenticated with the correct subscription: `az account show`

### Error: "Action Group already exists"

This is expected if you run the script multiple times. The script will update the existing action group.

### Error: "Alert already exists"

This is expected if you run the script multiple times. The script will update the existing alerts.

### Dashboard not showing data

**Possible causes:**
1. Application hasn't generated telemetry yet (wait 5-10 minutes)
2. Application Insights connection string not configured
3. Time range is too narrow (dashboard shows last 24 hours)

**Solution:**
- Check Application Insights is receiving data: `az monitor app-insights metrics show --app appi-aipatterns-prod --resource-group rg-aipatterns-prod --metric requests/count`
- Verify connection string in application configuration
- Generate some traffic to the application

---

## Additional Resources

- [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [Application Insights Overview](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Alert Rules Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Dashboard Documentation](https://docs.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards)

---

## Next Steps

After configuring monitoring:

1. ✅ **Test Alerts** - Trigger each alert to verify notifications work
2. ✅ **Document Runbooks** - Create response procedures for each alert
3. ✅ **Set Up On-Call** - Configure rotation schedule for alert responses
4. ✅ **Review Regularly** - Check dashboard daily, tune thresholds as needed
5. ✅ **Expand Monitoring** - Add custom metrics, logs, and traces as needed

---

**Created:** 2026-02-13
**Phase:** 4.5 - Testing Foundation & Operational Readiness
**Author:** Claude Code
