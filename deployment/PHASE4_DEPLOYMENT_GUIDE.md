# Phase 4: Azure Deployment - Complete Guide

This is the comprehensive guide for deploying the AI Enterprise Patterns application to Microsoft Azure with automated CI/CD.

## 📋 Overview

Phase 4 transforms the application from local development to production-ready cloud deployment with:
- ✅ Azure infrastructure (App Services, SQL Database, Key Vault, Application Insights)
- ✅ Automated CI/CD with GitHub Actions
- ✅ Production configurations (CORS, rate limiting, security headers)
- ✅ Monitoring and logging with Application Insights
- ✅ Database migration to Azure SQL

## 🎯 Goals

- Deploy backend API to Azure App Service
- Deploy frontend web app to Azure App Service
- Migrate database from SQLite to Azure SQL
- Implement automated deployments via GitHub Actions
- Enable monitoring and telemetry
- Secure the application for production use

## 📊 Architecture

```
┌─────────────┐
│   GitHub    │
│  Repository │
└──────┬──────┘
       │ (push to main)
       ▼
┌─────────────────────────┐
│   GitHub Actions        │
│  - Build & Test         │
│  - Deploy to Azure      │
└──────┬────────┬─────────┘
       │        │
       ▼        ▼
┌──────────┐  ┌──────────┐
│ Backend  │  │ Frontend │
│ App      │  │ App      │
│ Service  │  │ Service  │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             ▼
┌─────────────────────┐
│   Azure SQL DB      │
│   Key Vault         │
│   App Insights      │
└─────────────────────┘
```

## 🚀 Deployment Steps

### Step 1: Create Azure Infrastructure

#### 1.1. Review Configuration

Open `deployment/azure-setup.ps1` and update these variables:

```powershell
$RESOURCE_GROUP = "rg-aipatterns-prod"
$LOCATION = "eastus"  # Change to your preferred region
$SQL_SERVER_NAME = "sql-aipatterns-prod"      # Must be globally unique
$BACKEND_APP_NAME = "app-aipatterns-api-prod"   # Must be globally unique
$FRONTEND_APP_NAME = "app-aipatterns-web-prod"  # Must be globally unique
$KEY_VAULT_NAME = "kv-aipatterns-prod"  # Must be globally unique
```

**Important:** Names marked "globally unique" must be unique across **all** Azure customers worldwide. Add your initials or a random suffix if needed (e.g., `app-aipatterns-api-sp2026`).

#### 1.2. Login to Azure

```powershell
az login
```

Verify your subscription:
```powershell
az account show
```

If you have multiple subscriptions, set the correct one:
```powershell
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

#### 1.3. Run Infrastructure Setup

```powershell
cd deployment
.\azure-setup.ps1
```

This will create:
- Resource Group
- Azure SQL Server and Database
- Application Insights
- Key Vault (with secrets)
- App Service Plan
- Backend App Service (ASP.NET Core 8.0)
- Frontend App Service (Node.js 20)
- Firewall rules and CORS configuration

**Estimated time:** 5-10 minutes

#### 1.4. Save Output

The script outputs critical information:
- SQL connection string
- Admin password (**SAVE THIS!**)
- App Service URLs
- Application Insights keys

Output is automatically saved to `azure-resources-output.txt`.

⚠️ **CRITICAL:** Save the SQL admin password securely! Add `azure-resources-output.txt` to `.gitignore`.

---

### Step 2: Configure GitHub Secrets

GitHub Actions needs credentials to deploy to Azure.

#### 2.1. Automated Setup (Recommended)

```powershell
cd deployment
.\setup-github-secrets.ps1
```

This creates:
- Azure AD application
- Service principal
- Federated identity credentials (OIDC)
- Role assignments

The script will output three secrets you need to add to GitHub.

#### 2.2. Add Secrets to GitHub

1. Go to [https://github.com/sandropetterle/AIEnterprisePatterns/settings/secrets/actions](https://github.com/sandropetterle/AIEnterprisePatterns/settings/secrets/actions)
2. Click **New repository secret**
3. Add each of these:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `AZURE_CLIENT_ID` | Application (client) ID | From setup script output |
| `AZURE_TENANT_ID` | Azure AD tenant ID | From setup script output |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | From setup script output |

See [github-secrets-setup.md](./github-secrets-setup.md) for detailed instructions.

---

### Step 3: Migrate Database

#### 3.1. Set Connection String

Get the connection string from Key Vault:

```powershell
$CONNECTION_STRING = az keyvault secret show --vault-name kv-aipatterns-prod --name "SqlConnectionString" --query "value" --output tsv
$env:CONNECTION_STRING = $CONNECTION_STRING
```

#### 3.2. Run Migration

```bash
cd backend
dotnet ef database update --project src/AIEnterprisePatterns.Api --connection "$env:CONNECTION_STRING"
```

Expected output:
```
Build started...
Build succeeded.
Applying migration '20240101_InitialCreate'.
Done.
```

#### 3.3. Verify Migration

```sql
-- Check migration history
SELECT * FROM __EFMigrationsHistory;

-- Count tables
SELECT COUNT(*) FROM Patterns;
```

See [database-migration.md](./database-migration.md) for detailed instructions and troubleshooting.

---

### Step 4: Deploy Applications

#### 4.1. Update Workflow Configuration

**Backend:** Edit `.github/workflows/backend-deploy.yml`
```yaml
env:
  AZURE_WEBAPP_NAME: 'app-aipatterns-api-prod' # Update to match your App Service name
```

**Frontend:** Edit `.github/workflows/frontend-deploy.yml`
```yaml
env:
  AZURE_WEBAPP_NAME: 'app-aipatterns-web-prod' # Update to match your App Service name

# In build step, update API URL:
env:
  NEXT_PUBLIC_API_BASE_URL: https://app-aipatterns-api-prod.azurewebsites.net/api
```

#### 4.2. Commit and Push

```bash
git add .
git commit -m "feat: add Azure deployment configuration"
git push origin main
```

This triggers GitHub Actions workflows automatically.

#### 4.3. Monitor Deployment

1. Go to [https://github.com/sandropetterle/AIEnterprisePatterns/actions](https://github.com/sandropetterle/AIEnterprisePatterns/actions)
2. Watch the running workflows:
   - **Backend API - Build and Deploy**
   - **Frontend Web - Build and Deploy**

Each workflow has 3 jobs:
- **Build:** Compile and test
- **Deploy:** Deploy to Azure
- **Healthcheck:** Verify deployment

**Estimated time:** 5-7 minutes per workflow

#### 4.4. Manual Trigger (Optional)

If you need to deploy without pushing code:

1. Go to **Actions** tab
2. Select a workflow
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow**

---

### Step 5: Verify Deployment

#### 5.1. Backend API

**Swagger UI:**
```
https://app-aipatterns-api-prod.azurewebsites.net/swagger
```

**API Test:**
```bash
curl https://app-aipatterns-api-prod.azurewebsites.net/api/patterns?page=1&pageSize=5
```

**Health Check:**
```bash
curl https://app-aipatterns-api-prod.azurewebsites.net/health
```

Expected response: `Healthy`

#### 5.2. Frontend Web

**Homepage:**
```
https://app-aipatterns-web-prod.azurewebsites.net
```

**Patterns Page:**
```
https://app-aipatterns-web-prod.azurewebsites.net/patterns
```

**About Page:**
```
https://app-aipatterns-web-prod.azurewebsites.net/about
```

#### 5.3. Application Insights

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Application Insights** → **appi-aipatterns-prod**
3. Check dashboards:
   - **Live Metrics:** Real-time requests and performance
   - **Failures:** Any errors or exceptions
   - **Performance:** Response times and dependencies

---

### Step 6: Configure Custom Domain (Optional)

#### 6.1. Add Custom Domain

```powershell
# Add custom domain to backend
az webapp config hostname add --webapp-name app-aipatterns-api-prod --resource-group rg-aipatterns-prod --hostname api.yourdomain.com

# Add custom domain to frontend
az webapp config hostname add --webapp-name app-aipatterns-web-prod --resource-group rg-aipatterns-prod --hostname www.yourdomain.com
```

#### 6.2. Enable SSL

Azure App Service provides free SSL certificates:

1. Go to Azure Portal → App Service
2. Click **Custom domains**
3. Click **Add binding**
4. Select **App Service Managed Certificate** (free)
5. Click **Validate** and **Add**

#### 6.3. Update CORS

Update backend to allow custom domain:

```powershell
az webapp cors add --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod --allowed-origins https://www.yourdomain.com
```

---

## 📊 Monitoring and Maintenance

### Application Insights

**Key Metrics to Monitor:**
- Request rate and response times
- Failed requests (4xx, 5xx errors)
- Database query performance
- Dependency failures (SQL, external APIs)

**Set Up Alerts:**

```powershell
# Alert on failed requests
az monitor metrics alert create --name "High Error Rate" --resource-group rg-aipatterns-prod --scopes /subscriptions/.../app-aipatterns-api-prod --condition "count failures > 10" --window-size 5m
```

### Log Streaming

**Real-time logs:**

```powershell
# Backend logs
az webapp log tail --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod

# Frontend logs
az webapp log tail --name app-aipatterns-web-prod --resource-group rg-aipatterns-prod
```

### Database Monitoring

**Check database performance:**

1. Go to Azure Portal → SQL databases → sqldb-aipatterns-prod
2. Click **Query Performance Insight**
3. Review slow queries and optimize indexes

---

## 💰 Cost Management

### Estimated Monthly Costs

| Resource | SKU | Estimated Cost (USD/month) |
|----------|-----|---------------------------|
| Azure SQL Database | Basic | $5 |
| App Service Plan | B1 (Basic) | $13 |
| Application Insights | Standard | $0-5 (first 5GB free) |
| Key Vault | Standard | <$1 |
| **Total** | | **~$19-24** |

### Cost Optimization Tips

1. **Use Free Tier for Testing:**
   - Change App Service to F1 (Free) during development
   - Delete resources when not in use

2. **Scale Down Off-Hours:**
   ```powershell
   # Stop App Services
   az webapp stop --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod
   az webapp stop --name app-aipatterns-web-prod --resource-group rg-aipatterns-prod
   ```

3. **Monitor Costs:**
   - Enable Azure Cost Management alerts
   - Review billing regularly

4. **Delete Test Resources:**
   ```powershell
   az group delete --name rg-aipatterns-dev --yes
   ```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: "Deployment failed with 403 Forbidden"

**Cause:** GitHub Actions doesn't have permissions.

**Solution:**
```powershell
# Re-run GitHub secrets setup
.\deployment\setup-github-secrets.ps1
```

#### Issue: "Database connection failed"

**Cause:** Firewall rule not configured or incorrect connection string.

**Solution:**
```powershell
# Add your IP to firewall
$MY_IP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az sql server firewall-rule create --resource-group rg-aipatterns-prod --server sql-aipatterns-prod --name "MyIP" --start-ip-address $MY_IP --end-ip-address $MY_IP

# Verify connection string in Key Vault
az keyvault secret show --vault-name kv-aipatterns-prod --name "SqlConnectionString"
```

#### Issue: "Frontend cannot reach backend API"

**Cause:** CORS not configured or incorrect backend URL.

**Solution:**
```powershell
# Check CORS settings
az webapp cors show --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod

# Add frontend origin
az webapp cors add --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod --allowed-origins https://app-aipatterns-web-prod.azurewebsites.net
```

#### Issue: "App Service shows 'Application Error'"

**Cause:** App crashed on startup or deployment failed.

**Solution:**
```powershell
# Check logs
az webapp log tail --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod

# Restart app
az webapp restart --name app-aipatterns-api-prod --resource-group rg-aipatterns-prod
```

#### Issue: "502 Bad Gateway"

**Cause:** App didn't start or health check failed.

**Solution:**
```bash
# Check health endpoint
curl https://app-aipatterns-api-prod.azurewebsites.net/health

# View Application Insights for errors
# Go to Azure Portal → Application Insights → Failures
```

---

## 🔒 Security Best Practices

### Implemented Security Features

✅ **Rate Limiting** - Protects against abuse (50 requests/minute per IP)
✅ **CORS** - Restricts cross-origin requests to approved domains
✅ **HTTPS Enforcement** - All traffic encrypted
✅ **Security Headers** - X-Frame-Options, X-Content-Type-Options, etc.
✅ **Key Vault** - Secrets never stored in code or config
✅ **Managed Identity** - Passwordless authentication for App Service → Key Vault
✅ **SQL Encryption** - Data encrypted at rest and in transit

### Additional Recommendations

1. **Enable Azure AD Authentication** (Phase 5)
2. **Add WAF (Web Application Firewall)** for DDoS protection
3. **Implement logging and monitoring** of security events
4. **Regular security updates** - Keep packages up to date
5. **Penetration testing** before production launch

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [README.md](./README.md) | Overview of deployment folder |
| [azure-setup.ps1](./azure-setup.ps1) | Infrastructure creation script |
| [azure-cleanup.ps1](./azure-cleanup.ps1) | Resource deletion script |
| [setup-github-secrets.ps1](./setup-github-secrets.ps1) | GitHub Actions configuration |
| [github-secrets-setup.md](./github-secrets-setup.md) | Manual GitHub secrets guide |
| [database-migration.md](./database-migration.md) | Database migration guide |
| [PHASE4_DEPLOYMENT_GUIDE.md](./PHASE4_DEPLOYMENT_GUIDE.md) | This file |

---

## ✅ Phase 4 Checklist

Use this checklist to track your progress:

### Infrastructure Setup
- [ ] Azure CLI installed and logged in
- [ ] Updated `azure-setup.ps1` with unique names
- [ ] Ran `azure-setup.ps1` successfully
- [ ] Saved SQL admin password securely
- [ ] Verified all resources in Azure Portal

### GitHub Actions
- [ ] Ran `setup-github-secrets.ps1`
- [ ] Added 3 secrets to GitHub repository
- [ ] Updated workflow files with correct App Service names
- [ ] Verified service principal has Contributor role

### Database
- [ ] Installed `dotnet-ef` CLI tool
- [ ] Added firewall rule for local IP
- [ ] Ran database migrations successfully
- [ ] Verified tables exist in Azure SQL
- [ ] (Optional) Seeded initial data

### Deployment
- [ ] Updated backend workflow with App Service name
- [ ] Updated frontend workflow with API URL
- [ ] Committed and pushed changes to main branch
- [ ] Monitored GitHub Actions workflows
- [ ] Both workflows completed successfully

### Verification
- [ ] Backend Swagger UI accessible
- [ ] Backend API returns data
- [ ] Backend health check returns "Healthy"
- [ ] Frontend homepage loads
- [ ] Frontend can fetch patterns from API
- [ ] No CORS errors in browser console

### Monitoring
- [ ] Application Insights receiving telemetry
- [ ] Checked Live Metrics for requests
- [ ] Reviewed Failures dashboard
- [ ] Set up alerts (optional)

### Documentation
- [ ] Updated README with deployment URLs
- [ ] Documented custom configuration
- [ ] Saved credentials securely
- [ ] Shared deployment guide with team

---

## 🎉 Success Criteria

Phase 4 is complete when:

1. ✅ Backend API is live and accessible via HTTPS
2. ✅ Frontend web app is live and accessible via HTTPS
3. ✅ Database is migrated to Azure SQL with all tables
4. ✅ GitHub Actions workflows deploy automatically on push to main
5. ✅ Application Insights is receiving telemetry
6. ✅ Health checks return "Healthy"
7. ✅ All tests pass in CI/CD pipeline
8. ✅ Frontend can successfully fetch data from backend API
9. ✅ No errors in Application Insights Failures dashboard
10. ✅ Documentation is updated with deployment details

---

## 🔄 Next Steps (Phase 5)

After completing Phase 4, the next phase includes:

- **Authentication & Authorization** (Azure AD B2C)
- **Pattern Creation/Edit UI** (Forms and validation)
- **User engagement features** (Comments, ratings, favorites)
- **Advanced monitoring** (Custom dashboards, alerts)

See [documentation/instructions.md](../documentation/instructions.md) for full roadmap.

---

## 📞 Support

- **Azure Documentation:** [https://docs.microsoft.com/azure](https://docs.microsoft.com/azure)
- **GitHub Actions:** [https://docs.github.com/actions](https://docs.github.com/actions)
- **Project Issues:** [https://github.com/sandropetterle/AIEnterprisePatterns/issues](https://github.com/sandropetterle/AIEnterprisePatterns/issues)

---

**Last Updated:** 2026-02-10
**Phase:** 4 - Azure Deployment
**Status:** ✅ Complete
