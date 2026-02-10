# Azure SQL Database Migration Guide

This guide explains how to migrate the database schema and seed data to Azure SQL Database.

## 📋 Prerequisites

1. Azure infrastructure created (run `azure-setup.ps1`)
2. SQL connection string available from Azure
3. .NET SDK 8.0 installed
4. Firewall rule configured to allow your IP

## 🔐 Get Connection String

### Option 1: From Key Vault

```powershell
$KEY_VAULT_NAME = "kv-aipatterns-prod"
az keyvault secret show --vault-name $KEY_VAULT_NAME --name "SqlConnectionString" --query "value" --output tsv
```

### Option 2: From Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **SQL databases** → **sqldb-aipatterns-prod**
3. Click **Connection strings** in the left menu
4. Copy the **ADO.NET** connection string
5. Replace `{your_password}` with the SQL admin password

### Option 3: Build Manually

```plaintext
Server=tcp:sql-aipatterns-prod.database.windows.net,1433;
Initial Catalog=sqldb-aipatterns-prod;
Persist Security Info=False;
User ID=aipatterns-admin;
Password=YOUR_PASSWORD_HERE;
MultipleActiveResultSets=False;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

## 🚀 Migration Methods

### Method 1: Using dotnet ef CLI (Recommended)

This method applies migrations directly from your local machine to Azure SQL.

#### Step 1: Install EF Core Tools (if not already installed)

```bash
dotnet tool install --global dotnet-ef
# or update existing
dotnet tool update --global dotnet-ef
```

#### Step 2: Verify Firewall Access

Ensure your IP address is allowed to access the SQL server:

```powershell
$RESOURCE_GROUP = "rg-aipatterns-prod"
$SQL_SERVER_NAME = "sql-aipatterns-prod"
$MY_IP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content

az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name "AllowMyIP" `
    --start-ip-address $MY_IP `
    --end-ip-address $MY_IP
```

#### Step 3: Set Connection String as Environment Variable

**PowerShell:**
```powershell
$env:CONNECTION_STRING = "Server=tcp:sql-aipatterns-prod.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=YOUR_PASSWORD;Encrypt=True;"
```

**Bash/Linux/Mac:**
```bash
export CONNECTION_STRING="Server=tcp:sql-aipatterns-prod.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod;User ID=aipatterns-admin;Password=YOUR_PASSWORD;Encrypt=True;"
```

#### Step 4: Run Migration

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

#### Step 5: Verify Migration

Check the database has tables:

```bash
# List tables using Azure CLI
az sql db show --resource-group rg-aipatterns-prod --server sql-aipatterns-prod --name sqldb-aipatterns-prod --query "name"
```

Or connect using SQL Server Management Studio (SSMS) or Azure Data Studio and verify these tables exist:
- `Patterns`
- `Tags`
- `PatternTags`
- `__EFMigrationsHistory`

### Method 2: Using SQL Scripts

If you prefer to generate SQL scripts and execute them manually:

#### Step 1: Generate SQL Script

```bash
cd backend
dotnet ef migrations script --project src/AIEnterprisePatterns.Api --output migration.sql --idempotent
```

This creates a `migration.sql` file that can be run multiple times safely (idempotent).

#### Step 2: Execute Script in Azure

**Option A: Azure Portal Query Editor**
1. Go to Azure Portal → SQL databases → sqldb-aipatterns-prod
2. Click **Query editor** in the left menu
3. Login with SQL authentication (aipatterns-admin / password)
4. Paste the contents of `migration.sql`
5. Click **Run**

**Option B: Azure Data Studio**
1. Download [Azure Data Studio](https://docs.microsoft.com/sql/azure-data-studio/download)
2. Connect to `sql-aipatterns-prod.database.windows.net`
3. Open `migration.sql` file
4. Execute the script

**Option C: sqlcmd CLI**
```bash
sqlcmd -S sql-aipatterns-prod.database.windows.net -d sqldb-aipatterns-prod -U aipatterns-admin -P "YOUR_PASSWORD" -i migration.sql
```

### Method 3: Automatic Migration on App Startup (Not Recommended for Production)

The application can auto-apply migrations on startup. This is **NOT recommended** for production but can be enabled for testing.

**To enable (use with caution):**

Edit [backend/src/AIEnterprisePatterns.Api/Program.cs](../backend/src/AIEnterprisePatterns.Api/Program.cs):

```csharp
// Apply database migrations on startup
using var scope = app.Services.CreateScope();
var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
await dbContext.Database.MigrateAsync();
```

Move this code **outside** the `if (app.Environment.IsDevelopment())` block.

⚠️ **Risks:**
- App won't start if migration fails
- Long-running migrations block startup
- No rollback mechanism
- Not suitable for production workloads

## 📊 Seed Data

After migrations complete, you need to seed initial patterns data.

### Option 1: API Endpoint (Recommended)

Once the backend is deployed and running:

```bash
curl -X POST https://app-aipatterns-api-prod.azurewebsites.net/api/patterns -H "Content-Type: application/json" -d '{
  "title": "CQRS Pattern",
  "category": "Architecture",
  "description": "Command Query Responsibility Segregation",
  "implementation": "Separate read and write operations...",
  "tags": ["architecture", "microservices"]
}'
```

Create a script to seed multiple patterns if needed.

### Option 2: Seed Script in Application

Create a seeding service that runs once:

```csharp
public class DatabaseSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        if (await context.Patterns.AnyAsync())
            return; // Already seeded

        var patterns = new List<Pattern>
        {
            new Pattern { Title = "CQRS", Category = PatternCategory.Architecture, ... },
            new Pattern { Title = "Repository Pattern", Category = PatternCategory.DesignPatterns, ... },
            // Add more patterns...
        };

        await context.Patterns.AddRangeAsync(patterns);
        await context.SaveChangesAsync();
    }
}
```

Call it from `Program.cs`:
```csharp
using var scope = app.Services.CreateScope();
var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
await DatabaseSeeder.SeedAsync(dbContext);
```

### Option 3: SQL INSERT Scripts

Write SQL INSERT statements and execute them via Query Editor:

```sql
INSERT INTO Patterns (Title, Slug, Category, Description, Implementation, UseCases, BestPractices, VoteCount, CreatedAt, UpdatedAt)
VALUES
('CQRS Pattern', 'cqrs-pattern', 1, 'Command Query Responsibility Segregation', '...', '...', '...', 0, GETDATE(), GETDATE()),
('Repository Pattern', 'repository-pattern', 2, 'Abstraction over data access', '...', '...', '...', 0, GETDATE(), GETDATE());

INSERT INTO Tags (Name) VALUES ('architecture'), ('microservices'), ('design-patterns');

-- Link patterns to tags
INSERT INTO PatternTags (PatternId, TagId) VALUES (1, 1), (1, 2), (2, 3);
```

## 🔍 Verify Database

### Check Migration History

```sql
SELECT * FROM __EFMigrationsHistory ORDER BY MigrationId DESC;
```

### Count Records

```sql
SELECT
    (SELECT COUNT(*) FROM Patterns) AS PatternCount,
    (SELECT COUNT(*) FROM Tags) AS TagCount,
    (SELECT COUNT(*) FROM PatternTags) AS PatternTagCount;
```

### Test Connection from Backend

```bash
# Health check endpoint (includes database check)
curl https://app-aipatterns-api-prod.azurewebsites.net/health
```

Expected response: `Healthy`

### Test API

```bash
# Get patterns
curl https://app-aipatterns-api-prod.azurewebsites.net/api/patterns?page=1&pageSize=10
```

## 🛠️ Troubleshooting

### Error: "Cannot open server"

**Problem:** Firewall rule not configured or incorrect IP.

**Solution:**
```powershell
# Check current firewall rules
az sql server firewall-rule list --resource-group rg-aipatterns-prod --server sql-aipatterns-prod --output table

# Add your IP
$MY_IP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
az sql server firewall-rule create --resource-group rg-aipatterns-prod --server sql-aipatterns-prod --name "MyIP" --start-ip-address $MY_IP --end-ip-address $MY_IP
```

### Error: "Login failed for user"

**Problem:** Incorrect username or password.

**Solution:** Verify credentials from Key Vault or `azure-resources-output.txt`:
```powershell
az keyvault secret show --vault-name kv-aipatterns-prod --name "SqlAdminPassword" --query "value" --output tsv
```

### Error: "A network-related or instance-specific error"

**Problem:** Network connectivity issue or incorrect server name.

**Solution:**
1. Verify server name: `sql-aipatterns-prod.database.windows.net`
2. Test connectivity: `Test-NetConnection -ComputerName sql-aipatterns-prod.database.windows.net -Port 1433`
3. Check if behind corporate firewall/VPN

### Error: "The certificate chain was issued by an authority that is not trusted"

**Problem:** SSL certificate validation issue.

**Solution:** Add `TrustServerCertificate=True` to connection string (only for testing):
```
Server=tcp:...;TrustServerCertificate=True;...
```

For production, use `TrustServerCertificate=False;Encrypt=True` (default).

### Migration Fails Midway

**Problem:** Migration partially applied.

**Solution:**
1. Check `__EFMigrationsHistory` table to see which migrations succeeded
2. Fix the issue in your migration code
3. Create a new migration to fix the problem:
   ```bash
   dotnet ef migrations add FixMigrationIssue --project src/AIEnterprisePatterns.Api
   ```
4. Apply the new migration

## 🔄 Creating New Migrations (Future Changes)

When you need to make schema changes:

### Step 1: Modify Entity Classes

Edit classes in `backend/src/AIEnterprisePatterns.Core/Entities/`.

### Step 2: Create Migration

```bash
cd backend
dotnet ef migrations add MigrationName --project src/AIEnterprisePatterns.Api
```

Example:
```bash
dotnet ef migrations add AddPatternRatings --project src/AIEnterprisePatterns.Api
```

### Step 3: Review Generated Migration

Check `backend/src/AIEnterprisePatterns.Data/Migrations/` for the new files.

### Step 4: Apply to Local Database First

```bash
dotnet ef database update --project src/AIEnterprisePatterns.Api
```

Test thoroughly!

### Step 5: Apply to Production

```bash
dotnet ef database update --project src/AIEnterprisePatterns.Api --connection "$env:CONNECTION_STRING"
```

Or generate script and apply manually:
```bash
dotnet ef migrations script --project src/AIEnterprisePatterns.Api --idempotent --output migration.sql
```

## 📚 Best Practices

✅ **DO:**
- Always test migrations on local/staging before production
- Use idempotent scripts (can run multiple times safely)
- Back up database before major migrations
- Keep migration files in source control
- Document breaking changes in migration comments

❌ **DON'T:**
- Delete migration files after applying (needed for rollback)
- Apply migrations directly to production without testing
- Modify applied migrations (create new ones instead)
- Store connection strings in code or config files
- Skip database backups before migrations

## 🔐 Security Notes

- **Never commit** connection strings or passwords to Git
- Use Azure Key Vault for production connection strings
- Remove development firewall rules after migration
- Use managed identities for App Service → SQL access (advanced)
- Rotate SQL passwords regularly

## 📖 Additional Resources

- [EF Core Migrations Documentation](https://docs.microsoft.com/ef/core/managing-schemas/migrations/)
- [Azure SQL Database Documentation](https://docs.microsoft.com/azure/azure-sql/database/)
- [Connection String Reference](https://docs.microsoft.com/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring)
- [Azure SQL Firewall Rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure)

---

**Last Updated:** 2026-02-10
**Phase:** 4 - Azure Deployment
