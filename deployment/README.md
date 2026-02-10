# Azure Deployment Guide

This folder contains scripts and configuration for deploying the AI Enterprise Patterns application to Azure.

## 📋 Prerequisites

1. **Azure Subscription** - You need an active Azure subscription
2. **Azure CLI** - Install from [https://aka.ms/InstallAzureCLI](https://aka.ms/InstallAzureCLI)
3. **Permissions** - Contributor role or higher on the subscription
4. **PowerShell** - Windows PowerShell 5.1 or PowerShell 7+

## 🚀 Quick Start

### Step 1: Login to Azure

```powershell
az login
```

This will open a browser window for authentication.

### Step 2: Verify Your Subscription

```powershell
az account show
```

If you have multiple subscriptions, set the correct one:

```powershell
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 3: Review Configuration

Open `azure-setup.ps1` and update the configuration variables at the top:

```powershell
$RESOURCE_GROUP = "rg-aipatterns-prod"
$LOCATION = "eastus"  # Change to your preferred region
$SQL_SERVER_NAME = "sql-aipatterns-prod"      # Must be globally unique
$BACKEND_APP_NAME = "app-aipatterns-api-prod"   # Must be globally unique
$FRONTEND_APP_NAME = "app-aipatterns-web-prod"  # Must be globally unique
$KEY_VAULT_NAME = "kv-aipatterns-prod"  # Must be globally unique
```

**IMPORTANT:** SQL Server, App Service, and Key Vault names must be **globally unique** across all Azure customers.

### Step 4: Run the Setup Script

```powershell
cd deployment
.\azure-setup.ps1
```

The script will:
- ✅ Create resource group
- ✅ Create Azure SQL Server and Database
- ✅ Configure firewall rules
- ✅ Create Application Insights
- ✅ Create Key Vault with secrets
- ✅ Create App Service Plan
- ✅ Create Backend App Service (ASP.NET Core)
- ✅ Create Frontend App Service (Next.js)
- ✅ Configure CORS
- ✅ Enable managed identities
- ✅ Grant Key Vault access

**Estimated time:** 5-10 minutes

### Step 5: Save the Output

The script will display and save:
- SQL connection string
- Admin password (SAVE THIS!)
- App Service URLs
- Application Insights keys
- Key Vault URI

Output is saved to `azure-resources-output.txt`.

## 📦 What Gets Created

| Resource | Name Pattern | SKU/Tier | Purpose |
|----------|-------------|----------|---------|
| Resource Group | `rg-aipatterns-prod` | N/A | Container for all resources |
| SQL Server | `sql-aipatterns-prod` | N/A | Database server |
| SQL Database | `sqldb-aipatterns-prod` | Basic | Application database |
| App Service Plan | `asp-aipatterns-prod` | B1 (Basic) | Hosting plan for web apps |
| Backend App Service | `app-aipatterns-api-prod` | Linux | ASP.NET Core API |
| Frontend App Service | `app-aipatterns-web-prod` | Linux | Next.js web app |
| Application Insights | `appi-aipatterns-prod` | N/A | Monitoring and telemetry |
| Key Vault | `kv-aipatterns-prod` | Standard | Secrets management |

## 💰 Cost Estimate

With default configuration (Basic SQL, B1 App Service Plan):

| Resource | Monthly Cost (USD) |
|----------|-------------------|
| SQL Database (Basic) | ~$5 |
| App Service Plan (B1) | ~$13 |
| Application Insights | ~$0-5 (first 5GB free) |
| Key Vault | <$1 |
| **Total** | **~$19-24/month** |

> **Note:** Prices vary by region and usage. Use [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for accurate estimates.

## 🔧 Configuration Details

### SKU Options

You can modify SKUs in `azure-setup.ps1`:

**SQL Database:**
- `Basic` - $5/month, 2GB storage (development)
- `S0` - $15/month, 250GB storage (small production)
- `S1` - $30/month, 250GB storage (production)

**App Service Plan:**
- `F1` - Free tier (limited, no custom domains, stops after 60 min/day)
- `B1` - $13/month (recommended minimum for production)
- `S1` - $70/month (autoscale, staging slots)
- `P1V2` - $96/month (high performance)

### Resource Naming

Follow Azure naming conventions:
- **Resource Group:** `rg-{project}-{environment}`
- **SQL Server:** `sql-{project}-{environment}`
- **App Service:** `app-{project}-{service}-{environment}`
- **Key Vault:** `kv-{project}-{environment}` (3-24 chars, alphanumeric + hyphens)

### Regions

Choose a region close to your users:
- `eastus` - East US (Virginia)
- `westus2` - West US 2 (Washington)
- `westeurope` - West Europe (Netherlands)
- `northeurope` - North Europe (Ireland)
- `southeastasia` - Southeast Asia (Singapore)

List all regions: `az account list-locations --output table`

## 🔐 Security Configuration

### Managed Identity

The setup script enables **System-Assigned Managed Identity** for the backend App Service, allowing it to access Key Vault without storing credentials.

### Key Vault

Secrets stored in Key Vault:
- `SqlConnectionString` - Azure SQL connection string
- `ApplicationInsights--InstrumentationKey` - App Insights key
- `ApplicationInsights--ConnectionString` - App Insights connection string
- `SqlAdminPassword` - SQL admin password (backup)

App Services reference secrets using `@Microsoft.KeyVault(SecretUri=...)` syntax.

### Firewall Rules

SQL Server firewall rules:
- ✅ Azure services (required for App Service)
- ✅ Your current IP (for local development)
- ⚠️ Remove your IP rule after initial setup for production

### CORS

CORS is configured on the backend to only allow requests from the frontend App Service URL.

## 📝 Next Steps After Infrastructure Setup

1. **Run Database Migrations** (see [database-migration.md](./database-migration.md))
   ```powershell
   cd backend
   dotnet ef database update
   ```

2. **Deploy Applications** (see CI/CD section)
   - Option A: Manual deployment with Azure CLI
   - Option B: GitHub Actions (recommended)

3. **Test Deployments**
   - Backend: `https://{BACKEND_APP_NAME}.azurewebsites.net/swagger`
   - Frontend: `https://{FRONTEND_APP_NAME}.azurewebsites.net`

4. **Configure Custom Domain** (optional)
   - Add custom domain in Azure Portal
   - Configure SSL certificate

5. **Set Up Monitoring**
   - Review Application Insights dashboard
   - Configure alerts

## 🧹 Cleanup Resources

To delete all resources and stop charges:

```powershell
az group delete --name rg-aipatterns-prod --yes --no-wait
```

⚠️ **WARNING:** This will delete ALL resources in the resource group permanently!

## 🔍 Troubleshooting

### Issue: "Name already exists"

**Problem:** SQL Server, App Service, or Key Vault name is taken globally.

**Solution:** Modify the name variables to make them unique:
```powershell
$SQL_SERVER_NAME = "sql-aipatterns-prod-unique123"
```

### Issue: "Unauthorized to access Key Vault"

**Problem:** Managed identity doesn't have Key Vault permissions.

**Solution:** Re-run the Key Vault access policy section:
```powershell
$principalId = az webapp identity show --name $BACKEND_APP_NAME --resource-group $RESOURCE_GROUP --query "principalId" -o tsv
az keyvault set-policy --name $KEY_VAULT_NAME --object-id $principalId --secret-permissions get list
```

### Issue: "Cannot connect to SQL Database from App Service"

**Problem:** Firewall rule not configured or connection string incorrect.

**Solution:** Verify firewall allows Azure services:
```powershell
az sql server firewall-rule show --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name "AllowAzureServices"
```

### Issue: "Frontend cannot reach backend API"

**Problem:** CORS not configured or backend URL incorrect.

**Solution:** Verify CORS settings:
```powershell
az webapp cors show --name $BACKEND_APP_NAME --resource-group $RESOURCE_GROUP
```

## 📚 Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure SQL Documentation](https://docs.microsoft.com/azure/azure-sql/)
- [Azure Key Vault Documentation](https://docs.microsoft.com/azure/key-vault/)
- [Application Insights Documentation](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)

## 🆘 Support

- Check Azure Service Health: [status.azure.com](https://status.azure.com)
- Azure Support: [Azure Portal > Help + support](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- Project Issues: [GitHub Issues](https://github.com/sandropetterle/AIEnterprisePatterns/issues)

---

**Last Updated:** 2026-02-10
**Phase:** 4 - Azure Deployment
