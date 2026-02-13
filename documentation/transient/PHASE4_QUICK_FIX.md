# Phase 4 - Quick Fix Guide

**Status:** ⏳ Needs your action to complete
**Time Required:** ~15 minutes
**Last Updated:** 2026-02-11

---

## TL;DR - What's Broken?

Your GitHub Actions workflows are failing because **GitHub secrets are not configured**. Additionally, the production database hasn't been initialized yet.

**All 4 workflows failing with:** `"Login failed - Missing client-id and tenant-id"`

---

## Quick Fix Steps (Do These Now)

### Step 1: Configure GitHub Secrets (5 minutes)

```powershell
# Run this command from project root
cd deployment
.\setup-github-secrets.ps1
```

**What this does:**
- Creates Azure AD application for GitHub Actions
- Generates federated credentials for OIDC authentication
- Outputs 3 secret values you need to copy

**After running, you'll see:**
```
AZURE_CLIENT_ID: <some-guid>
AZURE_TENANT_ID: <some-guid>
AZURE_SUBSCRIPTION_ID: <some-guid>
```

**Add these to GitHub:**
1. Go to: https://github.com/sandropetterle/AIEnterprisePatterns/settings/secrets/actions
2. Click "New repository secret" for each:
   - Name: `AZURE_CLIENT_ID` → Value: (paste from script output)
   - Name: `AZURE_TENANT_ID` → Value: (paste from script output)
   - Name: `AZURE_SUBSCRIPTION_ID` → Value: (paste from script output)

3. Add one more secret for App Services frontend:
   - Name: `API_BASE_URL`
   - Value: `https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api`

---

### Step 2: Initialize Production Database (5 minutes)

```powershell
# Set connection string (copy from DEPLOYMENT_SUMMARY.txt)
$env:CONNECTION_STRING = "Server=tcp:sql-aipatterns-sandr-1770754196.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=AIPatt3rnsTAnORmEYbr2026!;Encrypt=True;"

# Run migrations
cd backend
dotnet ef database update --project src/AIEnterprisePatterns.Data --startup-project src/AIEnterprisePatterns.Api --connection "$env:CONNECTION_STRING"
```

**Expected Output:**
```
Applying migration '20XXXXXX_InitialCreate'
Applying migration '20XXXXXX_AddPatternTags'
Done.
```

---

### Step 3: Deploy to Azure (5 minutes)

I've already fixed the Dockerfile issues for you. Now just commit and push:

```bash
git add .
git commit -m "fix: complete Phase 4 deployment - add GitHub secrets support and CORS"
git push origin main
```

**Watch the deployment:**
- Go to: https://github.com/sandropetterle/AIEnterprisePatterns/actions
- You should see 4 workflows start running
- All should succeed in ~5-10 minutes

---

### Step 4: Verify It Works (2 minutes)

**Backend Health Check:**
```bash
curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
```
Should return: `Healthy`

**Frontend:**
Open: https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io

You should see the home page load with patterns.

---

## What I Already Fixed

✅ **Backend Dockerfile** - Added `curl` installation for healthcheck
✅ **Frontend Dockerfile** - Fixed healthcheck to check root path instead of non-existent `/api/health`
✅ **CORS Configuration** - Added Container Apps URL to allowed origins
✅ **Program.cs** - Updated to support array of frontend URLs

---

## Troubleshooting

### "GitHub Actions still failing after adding secrets"

**Possible causes:**
1. Secrets not saved correctly - Check they're at repository level, not environment level
2. Typo in secret names - They must be EXACT: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
3. Need to re-run workflow - Go to Actions tab → Select failed workflow → Re-run jobs

### "Database migration fails"

**Check:**
1. VPN or firewall blocking Azure SQL connection
2. Password correct (check `deployment/DEPLOYMENT_SUMMARY.txt`)
3. .NET 8 SDK installed: `dotnet --version` should show 8.x

**Fix:** Add your IP to Azure SQL firewall:
```powershell
az sql server firewall-rule create --resource-group rg-aipatterns-prod --server sql-aipatterns-sandr-1770754196 --name AllowMyIP --start-ip-address <your-ip> --end-ip-address <your-ip>
```

### "Backend returns 500 errors"

**Likely cause:** Database not migrated (see Step 2)

**Check logs:**
```powershell
az containerapp logs show --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod --follow
```

### "Frontend shows CORS errors"

This should be fixed now (I added Container Apps URL to CORS config). If you still see errors:

1. Check browser console for exact error
2. Verify environment variable: Frontend should have `NEXT_PUBLIC_API_BASE_URL` set to backend URL
3. Clear browser cache and hard refresh (Ctrl+Shift+R)

---

## Files Modified

| File | Change |
|------|--------|
| `backend/Dockerfile` | Added curl installation for healthcheck |
| `Dockerfile` | Fixed healthcheck path from `/api/health` to `/` |
| `backend/src/AIEnterprisePatterns.Api/appsettings.Production.json` | Changed `FrontendUrl` to `FrontendUrls` array with both App Services and Container Apps URLs |
| `backend/src/AIEnterprisePatterns.Api/Program.cs` | Added support for `FrontendUrls` array in CORS configuration |

---

## Next Steps After Phase 4 is Complete

Once everything is working:

1. **Monitor costs:** Azure Portal → Cost Management → rg-aipatterns-prod
2. **Set up monitoring alerts:** Application Insights → Alerts
3. **Review security:** Consider moving secrets to Azure Key Vault
4. **Plan Phase 5:** User authentication, advanced search, versioning

---

## Need More Help?

**Full detailed report:** See `documentation/PHASE4_COMPLETION_REPORT.md`

**Deployment details:** See `deployment/DEPLOYMENT_SUMMARY.txt`

**Phase 4 requirements:** See `documentation/CONTEXT_FOR_PHASE4.md`

---

**Questions?** Check the main [README.md](README.md) or [CLAUDE.md](CLAUDE.md) for troubleshooting.
