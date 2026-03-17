# GitHub Secrets Configuration Guide

This guide explains how to set up GitHub Secrets for automated CI/CD deployment to Azure.

## 🔐 Overview

GitHub Actions workflows use **Azure Federated Identity (OIDC)** for authentication, which is more secure than storing passwords or service principal secrets. This method uses short-lived tokens instead of long-lived credentials.

> **Infrastructure provisioning:** Azure resources are now provisioned declaratively using Bicep IaC. See `infrastructure/README.md` for prerequisites, validation, and deployment instructions. The legacy PowerShell setup scripts (`azure-setup.ps1`, `azure-container-apps-setup.ps1`, and related one-time fix scripts) have been removed — they are replaced by `infrastructure/main.bicep` and its modules.

## 📋 Prerequisites

1. Azure resources provisioned via Bicep IaC (`infrastructure/deploy.ps1`) — see `infrastructure/README.md`
2. GitHub repository: [sandropetterle/AIEnterprisePatterns](https://github.com/sandropetterle/AIEnterprisePatterns)
3. Azure CLI installed and logged in
4. Owner or Contributor role on Azure subscription

## 🚀 Step-by-Step Setup

### Step 1: Create Azure AD Application

Run these commands in PowerShell:

```powershell
# Set variables (update these to match your setup)
$APP_NAME = "github-aipatterns-deploy"
$RESOURCE_GROUP = "rg-aipatterns-prod"
$SUBSCRIPTION_ID = (az account show --query id --output tsv)
$REPO_OWNER = "sandropetterle"
$REPO_NAME = "AIEnterprisePatterns"

# Create Azure AD application
az ad app create --display-name $APP_NAME

# Get the Application (client) ID
$APP_ID = az ad app list --display-name $APP_NAME --query "[0].appId" --output tsv
Write-Host "Application ID: $APP_ID"

# Create service principal
az ad sp create --id $APP_ID

# Get Service Principal Object ID
$SP_OBJECT_ID = az ad sp list --display-name $APP_NAME --query "[0].id" --output tsv
Write-Host "Service Principal Object ID: $SP_OBJECT_ID"

# Get Tenant ID
$TENANT_ID = az account show --query tenantId --output tsv
Write-Host "Tenant ID: $TENANT_ID"
```

### Step 2: Assign Azure Permissions

```powershell
# Assign Contributor role to the service principal for the resource group
az role assignment create `
    --assignee $SP_OBJECT_ID `
    --role Contributor `
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

Write-Host "✓ Contributor role assigned"
```

### Step 3: Configure Federated Credentials

This allows GitHub Actions to authenticate using OIDC tokens. You can also run the canonical OIDC setup script: `deployment/setup-github-oidc.ps1`.

```powershell
# Create federated credential for main branch
az ad app federated-credential create `
    --id $APP_ID `
    --parameters @- << EOF
{
    "name": "github-main-branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main",
    "description": "GitHub Actions - main branch",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
EOF

Write-Host "✓ Federated credential created for main branch"

# Optional: Create federated credential for Pull Requests
az ad app federated-credential create `
    --id $APP_ID `
    --parameters @- << EOF
{
    "name": "github-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:$REPO_OWNER/$REPO_NAME:pull_request",
    "description": "GitHub Actions - pull requests",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
EOF

Write-Host "✓ Federated credential created for pull requests"
```

### Step 4: Display Values for GitHub Secrets

```powershell
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "GitHub Secrets Configuration" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "  Settings → Secrets and variables → Actions → New repository secret" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: AZURE_CLIENT_ID" -ForegroundColor Green
Write-Host "Value: $APP_ID" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: AZURE_TENANT_ID" -ForegroundColor Green
Write-Host "Value: $TENANT_ID" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: AZURE_SUBSCRIPTION_ID" -ForegroundColor Green
Write-Host "Value: $SUBSCRIPTION_ID" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
```

## 🔧 Manual GitHub Secrets Setup

If you prefer to set up secrets manually through the GitHub web interface:

### Navigate to Repository Settings

1. Go to [https://github.com/sandropetterle/AIEnterprisePatterns](https://github.com/sandropetterle/AIEnterprisePatterns)
2. Click **Settings** (repository settings, not your profile)
3. In the left sidebar, expand **Secrets and variables**
4. Click **Actions**

### Add Required Secrets

Click **New repository secret** for each of these:

#### 1. AZURE_CLIENT_ID
- **Name:** `AZURE_CLIENT_ID`
- **Value:** The Application (client) ID from Step 1
- **Description:** Azure AD App Registration client ID for GitHub OIDC authentication

#### 2. AZURE_TENANT_ID
- **Name:** `AZURE_TENANT_ID`
- **Value:** Your Azure AD Tenant ID
- **Description:** Azure Active Directory tenant identifier

#### 3. AZURE_SUBSCRIPTION_ID
- **Name:** `AZURE_SUBSCRIPTION_ID`
- **Value:** Your Azure Subscription ID
- **Description:** Azure subscription where resources are deployed

### Find Azure IDs

If you need to look up these values:

```powershell
# Get Subscription ID
az account show --query id --output tsv

# Get Tenant ID
az account show --query tenantId --output tsv

# Get Application (Client) ID
az ad app list --display-name "github-aipatterns-deploy" --query "[0].appId" --output tsv
```

## ✅ Verify Setup

### Test with PowerShell

```powershell
# Verify the service principal has correct permissions
az role assignment list `
    --assignee $SP_OBJECT_ID `
    --resource-group $RESOURCE_GROUP `
    --output table

# List federated credentials
az ad app federated-credential list --id $APP_ID --output table
```

### Expected Output

You should see:
- ✓ Role assignment with **Contributor** role
- ✓ Two federated credentials (main branch + pull requests)

## 🧪 Test the Deployment

### Option 1: Trigger with Git Push

```bash
git add .
git commit -m "test: trigger deployment"
git push origin main
```

### Option 2: Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Backend API - Build and Deploy** or **Frontend Web - Build and Deploy**
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow**

### Monitor Deployment

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the logs for each job (build, deploy, healthcheck)

### Deployment Status

After successful deployment:
- Backend: [https://app-aipatterns-api-prod.azurewebsites.net/swagger](https://app-aipatterns-api-prod.azurewebsites.net/swagger)
- Frontend: [https://app-aipatterns-web-prod.azurewebsites.net](https://app-aipatterns-web-prod.azurewebsites.net)

## 🔍 Troubleshooting

### Error: "AADSTS70021: No matching federated identity record found"

**Problem:** Federated credential not configured correctly.

**Solution:**
1. Verify the `subject` in federated credential matches: `repo:{owner}/{repo}:ref:refs/heads/main`
2. Check that the issuer is: `https://token.actions.githubusercontent.com`
3. Recreate the federated credential if needed

### Error: "AuthorizationFailed: The client does not have authorization"

**Problem:** Service principal doesn't have Contributor role.

**Solution:**
```powershell
az role assignment create `
    --assignee $SP_OBJECT_ID `
    --role Contributor `
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP
```

### Error: "Login failed with Error: No subscriptions found"

**Problem:** Service principal isn't assigned to any subscription.

**Solution:** Verify the subscription ID in GitHub secrets matches your Azure subscription.

### Error: "Resource group not found"

**Problem:** Trying to deploy before provisioning Azure infrastructure.

**Solution:** Provision infrastructure first using `infrastructure/deploy.ps1` (Bicep IaC). See `infrastructure/README.md`.

## 🔒 Security Best Practices

### ✅ DO
- Use federated identity (OIDC) instead of service principal secrets
- Limit service principal permissions to specific resource group
- Use environment-specific secrets for staging/production
- Rotate credentials regularly (federated credentials auto-expire)
- Use GitHub Environment protection rules

### ❌ DON'T
- Store passwords or connection strings in GitHub secrets
- Grant service principal Owner role (use Contributor instead)
- Share secrets between multiple repositories
- Commit secrets to code (even in .env.example)

## 🌍 Environment-Specific Deployments (Optional)

For staging + production environments:

### Create Separate Resource Groups
```powershell
$RESOURCE_GROUP_STAGING = "rg-aipatterns-staging"
$RESOURCE_GROUP_PROD = "rg-aipatterns-prod"
```

### Create Separate Federated Credentials
```powershell
# Staging (develop branch)
az ad app federated-credential create --id $APP_ID --parameters '{
    "name": "github-develop-branch",
    "subject": "repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/develop",
    "issuer": "https://token.actions.githubusercontent.com",
    "audiences": ["api://AzureADTokenExchange"]
}'

# Production (main branch)
az ad app federated-credential create --id $APP_ID --parameters '{
    "name": "github-main-branch",
    "subject": "repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/main",
    "issuer": "https://token.actions.githubusercontent.com",
    "audiences": ["api://AzureADTokenExchange"]
}'
```

### Configure GitHub Environments

1. Go to **Settings → Environments**
2. Create **Staging** and **Production** environments
3. Add environment-specific secrets
4. Set up protection rules (required reviewers for production)

## 📚 References

- [Azure Federated Identity Documentation](https://docs.microsoft.com/azure/active-directory/develop/workload-identity-federation)
- [GitHub Actions OIDC with Azure](https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure Login Action](https://github.com/marketplace/actions/azure-login)
- [Azure WebApps Deploy Action](https://github.com/marketplace/actions/azure-webapp)

---

**Last Updated:** 2026-03-17
**Phase:** 6.8 - Infrastructure as Code (Bicep IaC)
