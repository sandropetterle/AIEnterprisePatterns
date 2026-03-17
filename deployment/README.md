# Azure Deployment Guide

**Last Updated:** 2026-03-17
**Audience:** Infrastructure Engineers, DevOps
**Purpose:** Entry point for deploying the AI Enterprise Patterns application to Azure using Container Apps (the recommended approach).

---

## Deployment Method

**Primary:** Azure Container Apps (scale-to-zero, ~$5-12/month)

Container Apps is the current and recommended deployment method. It provides:
- Scale-to-zero — no cost when idle
- Automatic HTTPS and load balancing
- Easy secret management via secret references
- Consumption-based billing

For cost details, see [COST_ANALYSIS.md](COST_ANALYSIS.md).

---

## Prerequisites

- Azure subscription with Contributor role
- Azure CLI installed: [aka.ms/InstallAzureCLI](https://aka.ms/InstallAzureCLI)
- Docker Desktop (for local image builds)
- PowerShell 7+
- GitHub account (for CI/CD)

---

## Quick Start — Container Apps

### 1. Login to Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Provision Infrastructure

All Azure resources are managed via Bicep IaC. See [infrastructure/README.md](../infrastructure/README.md) for the full workflow.

```powershell
# Install Bicep (one-time)
az bicep install

# Preview changes (what-if), then deploy
.\infrastructure\deploy.ps1

# For CMS infrastructure (MySQL, CMS Container App, Blob Storage) — managed by cms.bicep module
# or reprovisioned manually:
.\scripts\provision-cms.ps1
```

### 3. Set Up CI/CD

Configure GitHub Secrets for OIDC-based deployment:

```bash
# See the full guide for step-by-step instructions
```

→ [github-secrets-setup.md](github-secrets-setup.md)

### 4. Configure Database

Apply EF Core migrations to Azure SQL:

→ [database-migration.md](database-migration.md)

### 5. Deploy

Push to `main` branch — GitHub Actions workflows deploy automatically:
- `backend-container-deploy.yml` — builds and deploys ASP.NET Core API
- `frontend-container-deploy.yml` — builds and deploys Next.js frontend
- `cms-container-deploy.yml` — builds and deploys Strapi CMS

---

## Deployed Resources

| Resource | Name / URL |
|---------|-----------|
| Frontend | https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Backend API | https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Strapi CMS | https://ca-aipatterns-cms-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io |
| Resource Group | `rg-aipatterns-prod` (centralus) |
| Container Registry | `craipatterns` |
| Azure SQL | `sql-aipatterns-prod` |
| Key Vault | `kv-aipatterns-prod` |
| Application Insights | `appi-aipatterns-prod` |

---

## Document Map

| Guide | Purpose |
|-------|---------|
| [../infrastructure/README.md](../infrastructure/README.md) | Bicep IaC — validate, what-if, deploy (authoritative provisioning guide) |
| [CONTAINER_APPS_GUIDE.md](CONTAINER_APPS_GUIDE.md) | Full Container Apps configuration reference (historical setup detail) |
| [COST_ANALYSIS.md](COST_ANALYSIS.md) | Cost breakdown: Container Apps vs App Services |
| [database-migration.md](database-migration.md) | Apply EF Core migrations to Azure SQL |
| [github-secrets-setup.md](github-secrets-setup.md) | Configure GitHub OIDC secrets for CI/CD |
| [scripts/README_MONITORING.md](scripts/README_MONITORING.md) | Alert and dashboard PowerShell scripts |

---

## Health Checks

The CI/CD pipelines verify deployment success via:
- Backend: `GET /health` → responds with `"Healthy"`
- Frontend: `GET /` → HTML contains `next-size-adjust`
- Automatic rollback on health check failure

---

## Operational Runbooks

For day-to-day operations, troubleshooting, and incident response:

→ [../documentation/operations/RUNBOOK.md](../documentation/operations/RUNBOOK.md)
→ [../documentation/operations/MONITORING_GUIDE.md](../documentation/operations/MONITORING_GUIDE.md)
→ [../documentation/operations/DISASTER_RECOVERY.md](../documentation/operations/DISASTER_RECOVERY.md)
