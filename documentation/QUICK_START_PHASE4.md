# 🚀 AI Enterprise Patterns - Phase 4 Quick Start

## ✅ Status: Infrastructure Deployed, Awaiting Final Steps

**Deployed:** 2026-02-10 | **Cost:** $0-5/month | **Savings:** 60-80% vs App Services

---

## 📍 Current State

```
Infrastructure: ✅ Deployed (Azure Container Apps, SQL Serverless, ACR)
Code: ✅ Pushed to GitHub (commit 1a1fe2b)
Next: ⏳ Configure GitHub secrets + Run DB migration
```

---

## ⚡ Next 2 Steps (10 minutes)

### Step 1: GitHub Secrets (5 min)
```powershell
cd deployment
.\setup-github-secrets.ps1
```
Add 3 secrets: https://github.com/sandropetterle/AIEnterprisePatterns/settings/secrets/actions

### Step 2: Database Migration (2 min)
```powershell
$env:CONNECTION_STRING = "Server=tcp:sql-aipatterns-sandr-1770754196.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=AIPatt3rnsTAnORmEYbr2026!;Encrypt=True;"

cd backend
dotnet ef database update --project src/AIEnterprisePatterns.Api --connection "$env:CONNECTION_STRING"
```

### Step 3: Watch Deployment
https://github.com/sandropetterle/AIEnterprisePatterns/actions

---

## 🌐 Deployed URLs

**Backend:** https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/swagger
**Frontend:** https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io

*(Currently placeholder images - will update after GitHub Actions runs)*

---

## 📁 Key Files

**Credentials:** `deployment/DEPLOYMENT_SUMMARY.txt` (all passwords & URLs)
**Full Context:** `documentation/SESSION_CONTEXT_2026-02-10_PHASE4.md`
**Deployment Guide:** `deployment/CONTAINER_APPS_GUIDE.md`
**Cost Analysis:** `deployment/COST_COMPARISON.md`

---

## 💰 Cost Breakdown

| When | Monthly Cost |
|------|-------------|
| Idle (scaled to zero) | $5 |
| Low traffic (2 hrs/day) | $6-8 |
| Medium traffic (8 hrs/day) | $10-12 |
| **vs App Services** | **$18-24** |

---

## 🆘 Quick Commands

**View logs:**
```powershell
az containerapp logs show --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod --follow
```

**Check scaling:**
```powershell
az containerapp revision list --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod
```

**Monitor costs:**
Azure Portal → Cost Management → rg-aipatterns-prod

---

**Ready?** Run Step 1 above to complete deployment! 🎉
