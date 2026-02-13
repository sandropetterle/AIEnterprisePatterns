# Operational Runbook - AI Enterprise Patterns Library

**Document Version:** 1.0
**Last Updated:** 2026-02-13
**Audience:** DevOps Engineers, Support Team, On-Call Personnel

---

## Overview

This runbook contains step-by-step procedures for common operational tasks, troubleshooting guides, and quick reference commands for the AI Enterprise Patterns Library.

**Quick Links:**
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Deployment Procedures](#deployment-procedures)
- [Emergency Procedures](#emergency-procedures)

---

## Common Tasks

### 1. Check Application Status

```bash
# Check Container Apps status
az containerapp list \
  --resource-group rg-aipatterns-prod \
  --output table

# Check health endpoints
curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
curl https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/

# View application insights metrics (last hour)
# Navigate to Azure Portal → Application Insights → Metrics
```

**Expected Output:**
- Health endpoint: "Healthy" (200 OK)
- Container Apps: "Running" status

---

### 2. View Application Logs

**Backend Logs:**
```bash
# Tail logs in real-time
az containerapp logs show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --follow

# View last 100 log lines
az containerapp logs show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --tail 100

# Filter for errors
az containerapp logs show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --tail 500 | grep -i "error"
```

**Frontend Logs:**
```bash
# Tail frontend logs
az containerapp logs show \
  --name ca-aipatterns-web-prod \
  --resource-group rg-aipatterns-prod \
  --follow
```

**Application Insights Logs:**
```kql
// Recent errors (Azure Portal → Application Insights → Logs)
traces
| where severityLevel >= 3  // Error or Critical
| where timestamp > ago(1h)
| order by timestamp desc
| project timestamp, severityLevel, message
```

---

### 3. Restart Application

**When to Restart:**
- Configuration changes not taking effect
- Application appears frozen/unresponsive
- Memory leak suspected (high memory usage)

**Backend Restart:**
```bash
az containerapp revision restart \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod
```

**Frontend Restart:**
```bash
az containerapp revision restart \
  --name ca-aipatterns-web-prod \
  --resource-group rg-aipatterns-prod
```

**Expected Downtime:** 30-60 seconds during restart

**Verification:**
```bash
# Check health endpoint after 60 seconds
sleep 60
curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
```

---

### 4. Scale Container Apps

**View Current Scale:**
```bash
az containerapp show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --query properties.template.scale
```

**Scale Up (Increase Min/Max Replicas):**
```bash
# Increase min replicas (prevent scale-to-zero)
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --min-replicas 1 \
  --max-replicas 5

# Increase resources (CPU/Memory)
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --cpu 1.0 \
  --memory 2.0Gi
```

**Scale Down (After Traffic Decrease):**
```bash
# Return to scale-to-zero configuration
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --min-replicas 0 \
  --max-replicas 3
```

**When to Scale:**
- High CPU usage (> 80% sustained)
- High memory usage (> 80%)
- Slow response times (P95 > 2s)
- Expected traffic surge (marketing campaign, etc.)

---

### 5. Update Configuration

**Update Environment Variables:**
```bash
# Update API base URL (frontend)
az containerapp update \
  --name ca-aipatterns-web-prod \
  --resource-group rg-aipatterns-prod \
  --set-env-vars "NEXT_PUBLIC_API_BASE_URL=https://new-url/api"

# Update connection string (backend)
# NOTE: Use Key Vault reference, don't put secrets in env vars
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --set-env-vars "ConnectionStrings__DefaultConnection=secretref:db-connection-string"
```

**Update Secrets:**
```bash
# Update secret in Key Vault
az keyvault secret set \
  --vault-name appi-aipatterns-prod-kv \
  --name db-connection-string \
  --value "Server=tcp:...;Password=NEW_PASSWORD"

# Restart app to pick up new secret
az containerapp revision restart \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod
```

---

### 6. Database Operations

**Connect to Database:**
```bash
# Using sqlcmd (install: https://aka.ms/sqlcmd)
sqlcmd -S sql-aipatterns-sandr-1770754196.database.windows.net \
       -d sqldb-aipatterns-prod \
       -U aipatterns-admin \
       -P <password>

# Using Azure Data Studio (GUI)
# Download: https://aka.ms/azuredatastudio
# Server: sql-aipatterns-sandr-1770754196.database.windows.net
# Database: sqldb-aipatterns-prod
# Auth: SQL Login
```

**Common Queries:**
```sql
-- Check pattern count
SELECT COUNT(*) FROM Patterns;

-- Check recent patterns
SELECT TOP 10 * FROM Patterns ORDER BY CreatedDate DESC;

-- Check tag usage
SELECT t.Name, COUNT(pt.PatternsId) as PatternCount
FROM Tags t
LEFT JOIN PatternTag pt ON t.Id = pt.TagsId
GROUP BY t.Name
ORDER BY PatternCount DESC;

-- Check vote counts
SELECT Title, VoteCount FROM Patterns ORDER BY VoteCount DESC;
```

**Run Migrations:**
```bash
# From local machine with .NET 8 SDK
cd backend/src/AIEnterprisePatterns.Api

# Set connection string environment variable
export CONNECTION_STRING="Server=tcp:sql-aipatterns-sandr-1770754196.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=<password>;Encrypt=True;"

# Run migrations
dotnet ef database update --connection "$CONNECTION_STRING"
```

---

## Troubleshooting

### Issue 1: Application Not Responding (503/504 Errors)

**Symptoms:**
- Users report 503 Service Unavailable
- Health check fails
- Container Apps showing "Stopped" status

**Diagnosis:**
```bash
# Check Container Apps status
az containerapp list \
  --resource-group rg-aipatterns-prod \
  --output table

# Check replica status
az containerapp replica list \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --output table

# View recent logs for errors
az containerapp logs show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --tail 100
```

**Common Causes:**
1. **Scale-to-zero cold start** - Wait 30-60 seconds for warm-up
2. **Application crash on startup** - Check logs for exceptions
3. **Database connection failure** - Verify connection string

**Resolution:**
```bash
# If application crashed, restart it
az containerapp revision restart \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod

# If scale-to-zero causing issues, set min-replicas to 1
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --min-replicas 1

# If database connection issue, verify connection string in Key Vault
az keyvault secret show \
  --vault-name appi-aipatterns-prod-kv \
  --name db-connection-string
```

---

### Issue 2: Slow Performance (High Response Times)

**Symptoms:**
- Page loads slowly (> 5 seconds)
- P95 response time > 2000ms
- Users report sluggish UI

**Diagnosis:**
```kql
// Find slowest operations (Application Insights → Logs)
requests
| where timestamp > ago(1h)
| summarize avg(duration), percentiles(duration, 50, 95, 99) by name
| where percentile_duration_95 > 2000
| order by percentile_duration_95 desc

// Check database dependencies
dependencies
| where type == "SQL"
| where timestamp > ago(1h)
| summarize avg(duration), count() by name
| where avg_duration > 1000
| order by avg_duration desc
```

**Common Causes:**
1. **Slow database queries** - Missing indexes, large result sets
2. **Cold start** - Scale-to-zero causing delays
3. **High CPU/memory usage** - Insufficient resources
4. **External API timeout** - Third-party service slow

**Resolution:**
```bash
# Check resource usage
az containerapp show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --query properties.template.containers[0].resources

# Scale up if needed
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --cpu 1.0 \
  --memory 2.0Gi \
  --min-replicas 1

# Check database for slow queries
# Azure Portal → SQL Database → Query Performance Insight
```

---

### Issue 3: High Error Rate (4xx/5xx Errors)

**Symptoms:**
- Error rate > 5%
- Users report errors
- Application Insights showing many failures

**Diagnosis:**
```kql
// Find failing endpoints
requests
| where resultCode >= 400
| where timestamp > ago(15m)
| summarize count() by url, resultCode
| order by count_ desc

// Check for exceptions
exceptions
| where timestamp > ago(15m)
| summarize count() by type, outerMessage
| order by count_ desc
```

**Common Causes:**
1. **404 errors** - Broken links, missing resources
2. **500 errors** - Unhandled exceptions, database errors
3. **401/403 errors** - Authentication/authorization issues (Phase 5+)
4. **429 errors** - Rate limiting triggered

**Resolution:**
```bash
# View detailed error logs
az containerapp logs show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --tail 200 | grep "ERROR"

# If deployment-related, rollback to previous version
az containerapp revision list \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod

az containerapp revision activate \
  --resource-group rg-aipatterns-prod \
  --name ca-aipatterns-api-prod \
  --revision <previous-good-revision>
```

---

### Issue 4: Database Connection Errors

**Symptoms:**
- "Cannot connect to database" errors
- Timeout exceptions
- 500 errors on all endpoints

**Diagnosis:**
```bash
# Check if database is running
az sql db show \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --name sqldb-aipatterns-prod

# Test connection from local machine
sqlcmd -S sql-aipatterns-sandr-1770754196.database.windows.net \
       -d sqldb-aipatterns-prod \
       -U aipatterns-admin \
       -P <password>
```

**Common Causes:**
1. **Firewall rules** - Container Apps IP not allowed
2. **Wrong connection string** - Typo, expired password
3. **Database paused** - Serverless database auto-paused

**Resolution:**
```bash
# Check firewall rules
az sql server firewall-rule list \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196

# Add Container Apps outbound IPs (if needed)
# Get outbound IPs
az containerapp show \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --query properties.outboundIpAddresses

# Add firewall rule
az sql server firewall-rule create \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --name AllowContainerApps \
  --start-ip-address <outbound-ip> \
  --end-ip-address <outbound-ip>

# If database paused, resume it (serverless auto-resumes on connection)
# Just wait 30-60 seconds for auto-resume
```

---

## Deployment Procedures

### Deploy Backend (Container Apps)

**Prerequisite:** New Docker image pushed to ACR

```bash
# Get latest image tag from ACR
az acr repository show-tags \
  --name <acr-name> \
  --repository aipatterns-api \
  --orderby time_desc \
  --output table

# Update Container App with new image
az containerapp update \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --image <acr-name>.azurecr.io/aipatterns-api:latest

# Wait for deployment to complete (2-3 minutes)
# Check deployment status
az containerapp revision list \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --output table

# Verify health endpoint
curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
```

**Automated:** GitHub Actions workflow `backend-container-deploy.yml`

---

### Deploy Frontend (Container Apps)

```bash
# Update frontend Container App
az containerapp update \
  --name ca-aipatterns-web-prod \
  --resource-group rg-aipatterns-prod \
  --image <acr-name>.azurecr.io/aipatterns-web:latest

# Verify deployment
curl https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/
```

**Automated:** GitHub Actions workflow `frontend-container-deploy.yml`

---

### Rollback Deployment

**Fast Rollback (Activate Previous Revision):**
```bash
# List revisions
az containerapp revision list \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod \
  --output table

# Activate previous revision
az containerapp revision activate \
  --resource-group rg-aipatterns-prod \
  --name ca-aipatterns-api-prod \
  --revision <previous-revision-name>

# Deactivate current bad revision
az containerapp revision deactivate \
  --resource-group rg-aipatterns-prod \
  --name ca-aipatterns-api-prod \
  --revision <current-bad-revision>
```

**Estimated Time:** 2-3 minutes

---

## Emergency Procedures

### Emergency Contact List

| Role | Name | Phone | Email |
|------|------|-------|-------|
| Primary On-Call | TBD | +1-XXX-XXX-XXXX | devops@example.com |
| Secondary On-Call | TBD | +1-XXX-XXX-XXXX | devops2@example.com |
| Manager | TBD | +1-XXX-XXX-XXXX | manager@example.com |
| Azure Support | N/A | Azure Portal | N/A |

---

### Emergency: Complete Service Outage

**If all services are down:**

1. **Check Azure Service Health:**
   - Azure Portal → Home → Service Health
   - Look for incidents in Central US region

2. **Verify Container Apps:**
   ```bash
   az containerapp list \
     --resource-group rg-aipatterns-prod \
     --output table
   ```

3. **Restart all services:**
   ```bash
   # Backend
   az containerapp revision restart \
     --name ca-aipatterns-api-prod \
     --resource-group rg-aipatterns-prod

   # Frontend
   az containerapp revision restart \
     --name ca-aipatterns-web-prod \
     --resource-group rg-aipatterns-prod
   ```

4. **If restart fails, check database:**
   ```bash
   az sql db show \
     --resource-group rg-aipatterns-prod \
     --server sql-aipatterns-sandr-1770754196 \
     --name sqldb-aipatterns-prod
   ```

5. **If Azure-wide issue, activate DR plan:**
   - See [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) Section 5.3

---

### Emergency: Security Breach

1. **Activate Incident Response:**
   - See [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md)
   - Page security team immediately

2. **Immediate containment:**
   ```bash
   # Block suspicious IP (example)
   az network nsg rule create \
     --resource-group rg-aipatterns-prod \
     --nsg-name nsg-aipatterns \
     --name BlockMaliciousIP \
     --priority 100 \
     --source-address-prefixes <ip-address> \
     --access Deny

   # Rotate all credentials
   az keyvault secret set \
     --vault-name appi-aipatterns-prod-kv \
     --name db-connection-string \
     --value "<new-secure-connection-string>"
   ```

3. **Preserve evidence:**
   - Export logs from Application Insights
   - Do not delete or modify logs

---

## Quick Reference

### Useful Commands

```bash
# Check everything at once
az containerapp list -g rg-aipatterns-prod -o table && \
curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health && \
curl https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/

# Tail logs from both apps simultaneously
az containerapp logs show --name ca-aipatterns-api-prod -g rg-aipatterns-prod --follow &
az containerapp logs show --name ca-aipatterns-web-prod -g rg-aipatterns-prod --follow &

# Check resource usage across all Container Apps
az containerapp show --name ca-aipatterns-api-prod -g rg-aipatterns-prod --query "properties.template.containers[0].resources"
```

### Important URLs

**Production:**
- Frontend: https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- Backend API: https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io
- Health Check: https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
- Azure Portal: https://portal.azure.com
- Application Insights: https://portal.azure.com/#@yourtenant.com/resource/.../appi-aipatterns-prod

**Documentation:**
- GitHub Repo: https://github.com/sandropetterle/AIEnterprisePatterns
- Monitoring Guide: [MONITORING_GUIDE.md](MONITORING_GUIDE.md)
- Disaster Recovery: [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md)
- Incident Response: [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md)

---

**Document Owner:** DevOps Team
**Review Schedule:** Monthly
**Last Reviewed:** 2026-02-13
**Next Review:** 2026-03-13
