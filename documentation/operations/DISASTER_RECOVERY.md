# Disaster Recovery Plan - AI Enterprise Patterns Library

**Document Version:** 1.0
**Last Updated:** 2026-03-19
**Audience:** DevOps Engineers, Site Reliability Engineers, IT Management

---

## 1. Executive Summary

This Disaster Recovery (DR) Plan outlines the procedures for recovering the AI Enterprise Patterns Library application in the event of a catastrophic failure, data loss, or regional outage. The plan defines Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO), backup strategies, and step-by-step recovery procedures.

**Key Objectives:**
- Minimize downtime and data loss
- Ensure business continuity
- Protect against data corruption and loss
- Meet compliance requirements

---

## 2. Disaster Recovery Metrics

### 2.1 Recovery Time Objective (RTO)

**RTO:** 4 hours
- Maximum acceptable downtime from disaster declaration to service restoration
- Measured from the time the disaster is identified

**RTO Breakdown:**
- Assessment and decision: 30 minutes
- Backup identification: 15 minutes
- Restore execution: 2 hours
- Validation and testing: 1 hour
- DNS/routing updates: 15 minutes

### 2.2 Recovery Point Objective (RPO)

**RPO:** 24 hours
- Maximum acceptable data loss measured in time
- Determined by backup frequency

**Current Backup Strategy:**
- Database: Automated daily backups (Azure SQL)
- Configuration: Version-controlled in Git (no data loss)
- Application code: Version-controlled in Git (no data loss)

---

## 3. Backup Strategy

### 3.1 Database Backups (Azure SQL)

**Automated Backups:**
- **Full backups:** Weekly (Sunday 02:00 UTC)
- **Differential backups:** Daily (02:00 UTC)
- **Transaction log backups:** Every 10 minutes
- **Retention:** 30 days (default Azure SQL policy)
- **Geo-redundant:** Enabled (backup replicated to paired region)

**Backup Location:**
- Primary: Central US (production region)
- Secondary: East US 2 (Azure paired region)

**Access Backups:**
```bash
# List available backups
az sql db list-backups \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --database sqldb-aipatterns-prod

# View backup details
az sql db show-backup-long-term-retention-policy \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --database sqldb-aipatterns-prod
```

### 3.2 Application & Configuration Backups

**Version Control (Git):**
- **Repository:** https://github.com/sandropetterle/AIEnterprisePatterns
- **Branches:** main (production), develop (staging)
- **Backup:** GitHub provides redundancy, no additional backup needed

**Container Images:**
- **Registry:** Azure Container Registry (ACR)
- **Images:** Tagged with commit SHA and "latest"
- **Retention:** 90 days (automated cleanup of old images)
- **Location:** rg-aipatterns-prod / acr<uniquename>prod

**Secrets & Configuration:**
- **Azure Key Vault:** appi-aipatterns-prod-kv
- **Backup:** Soft-delete enabled (90-day recovery window)
- **Export:** Manually export secrets to secure location quarterly

### 3.3 Backup Verification

**Monthly Backup Test:**
- First Monday of every month
- Restore latest backup to test environment
- Verify data integrity and completeness
- Document results in `documentation/operations/backup_test_YYYY-MM.md`

**Last Tested:** TBD (schedule starting Phase 4.5 completion)

---

## 4. Disaster Scenarios

### 4.1 Scenario 1: Application Failure (Container Apps)

**Examples:**
- Container crash or won't start
- Deployment of bad code
- Configuration error

**Impact:** High (service unavailable)
**RTO:** 1 hour
**RPO:** 0 (no data loss)

**Recovery Procedure:** See Section 5.1

### 4.2 Scenario 2: Database Corruption or Data Loss

**Examples:**
- Accidental data deletion
- Database corruption
- SQL injection attack

**Impact:** Critical (data loss)
**RTO:** 4 hours
**RPO:** 24 hours (last daily backup)

**Recovery Procedure:** See Section 5.2

### 4.3 Scenario 3: Regional Outage (Azure Datacenter)

**Examples:**
- Azure region unavailable
- Natural disaster
- Major infrastructure failure

**Impact:** Critical (service unavailable, potential data loss)
**RTO:** 4 hours (failover to secondary region)
**RPO:** 24 hours (last geo-replicated backup)

**Recovery Procedure:** See Section 5.3

### 4.4 Scenario 4: Security Breach / Ransomware

**Examples:**
- Compromised credentials
- Ransomware attack
- Unauthorized data access

**Impact:** Critical (service compromised, data integrity unknown)
**RTO:** 8 hours (includes investigation time)
**RPO:** 24 hours (restore from clean backup)

**Recovery Procedure:** See Section 5.4 + INCIDENT_RESPONSE.md

---

## 5. Recovery Procedures

### 5.1 Application Rollback (Container Apps)

**When to Use:**
- Deployment of bad code
- Configuration error causing crashes
- Performance degradation after deployment

**Prerequisites:**
- Access to Azure Portal or Azure CLI
- Previous working Container App revision identified

**Steps:**

1. **Identify Last Known Good Revision:**
   ```bash
   az containerapp revision list \
     --name ca-aipatterns-api-prod \
     --resource-group rg-aipatterns-prod \
     --output table
   ```

2. **Activate Previous Revision:**
   ```bash
   az containerapp revision activate \
     --resource-group rg-aipatterns-prod \
     --name ca-aipatterns-api-prod \
     --revision <previous-revision-name>
   ```

3. **Deactivate Current Revision:**
   ```bash
   az containerapp revision deactivate \
     --resource-group rg-aipatterns-prod \
     --name ca-aipatterns-api-prod \
     --revision <current-bad-revision>
   ```

4. **Verify Application Health:**
   ```bash
   curl https://ca-aipatterns-api-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/health
   ```

5. **Repeat for Frontend:**
   ```bash
   az containerapp revision activate \
     --resource-group rg-aipatterns-prod \
     --name ca-aipatterns-web-prod \
     --revision <previous-revision-name>
   ```

**Estimated Time:** 15-30 minutes
**Rollback Impact:** Brief downtime during revision switch (< 1 minute)

### 5.2 Database Point-in-Time Restore

**When to Use:**
- Accidental data deletion
- Data corruption
- Need to recover to specific point before incident

**Prerequisites:**
- Access to Azure Portal or Azure CLI
- Incident timestamp identified
- Restore point within 30-day retention window

**Steps:**

1. **Identify Restore Point:**
   - Determine exact time before incident occurred
   - Example: 2026-02-13T10:30:00Z

2. **Create Restore Point (Azure Portal):**
   - Navigate to Azure SQL Database: sqldb-aipatterns-prod
   - Click "Restore" button
   - Select "Point in time"
   - Choose restore point: 2026-02-13 10:30:00 UTC
   - New database name: sqldb-aipatterns-prod-restore-YYYYMMDD
   - Click "Review + create" → "Create"

3. **Restore via Azure CLI:**
   ```bash
   az sql db restore \
     --dest-name sqldb-aipatterns-prod-restore-20260213 \
     --resource-group rg-aipatterns-prod \
     --server sql-aipatterns-sandr-1770754196 \
     --name sqldb-aipatterns-prod \
     --time "2026-02-13T10:30:00Z"
   ```

4. **Verify Restored Data:**
   ```bash
   # Connect to restored database
   sqlcmd -S sql-aipatterns-sandr-1770754196.database.windows.net \
          -d sqldb-aipatterns-prod-restore-20260213 \
          -U aipatterns-admin \
          -P <password>

   # Verify row counts
   SELECT COUNT(*) FROM Patterns;
   SELECT COUNT(*) FROM Tags;

   # Verify specific data that was lost
   SELECT * FROM Patterns WHERE Id = '<guid>';
   ```

5. **Update Connection Strings:**
   - **Option A:** Point application to restored database (faster, keeps backup)
   - **Option B:** Copy data back to production database (safer, more time)

   **Option A - Update Connection String:**
   ```bash
   # Update Container Apps environment variable
   az containerapp update \
     --name ca-aipatterns-api-prod \
     --resource-group rg-aipatterns-prod \
     --set-env-vars "ConnectionStrings__DefaultConnection=Server=tcp:sql-aipatterns-sandr-1770754196.database.windows.net,1433;Initial Catalog=sqldb-aipatterns-prod-restore-20260213;User ID=aipatterns-admin;Password=<password>;Encrypt=True;"
   ```

6. **Validate Application:**
   - Test health endpoint
   - Verify data appears correctly in UI
   - Check recent patterns exist
   - Test CRUD operations

7. **Document Incident:**
   - Record in `documentation/operations/incidents/YYYY-MM-DD-data-recovery.md`
   - Include root cause, impact, restoration steps

**Estimated Time:** 2-3 hours (depending on database size)
**Data Loss:** Data between restore point and incident time

### 5.2a Full Environment Rebuild via IaC

For scenarios requiring a complete environment rebuild (e.g., full regional failover, catastrophic resource deletion), use the Bicep IaC rather than manually recreating resources:

```powershell
# Redeploy all Azure resources from Bicep templates
./infrastructure/deploy.ps1 -ResourceGroup rg-aipatterns-prod -Location centralus
```

This redeploys all modules: Container Apps Environment, Container Apps, SQL Server, Key Vault, ACR, and Application Insights. See [INFRASTRUCTURE_MANAGEMENT.md](INFRASTRUCTURE_MANAGEMENT.md) for the full validate/what-if/deploy workflow and required parameters.

> **Note:** CMS resources (`cms.bicep`) are intentionally excluded as of Phase CMS Cold Storage — Strapi is local-only. See §5.5 for CMS content recovery.

### 5.5 CMS Content Recovery (Cold Storage Mode)

**When to Use:**
- CMS content fallbacks in `lib/cms/queries.ts` need to be restored or re-derived
- Local Strapi database is lost or corrupted and needs rebuilding from a backup
- You want to restore Strapi to a known-good state for content editing

**Recovery path: git backup bundle → local Strapi**

```bash
# 1. List available backup bundles
ls backups/cms/

# 2. Verify bundle integrity
cd backups/cms/<date>
sha256sum -c <(python3 -c "import json,sys; [print(v['sha256']+'  '+k) for k,v in json.load(sys.stdin)['files'].items()]" < metadata.json)

# 3. Start local Strapi stack
docker compose --profile cms up -d

# 4. Restore the bundle
bash scripts/cms/restore.sh backups/cms/<date>

# 5. Verify in Strapi admin
open http://localhost:1337/admin
```

**To regenerate compile-time fallbacks from the restored Strapi:**
```bash
STRAPI_API_TOKEN=<read-token> npx tsx scripts/cms/generate-fallbacks.ts
git diff lib/cms/queries.ts   # review the diff
```

**To restore live Azure CMS (only if reverting cold storage):**
1. Restore `infrastructure/modules/cms.bicep` from git history
2. Restore the `module cms` call in `infrastructure/main.bicep`
3. Re-create the 8 KV secrets manually
4. `./infrastructure/deploy.ps1`
5. Run `scripts/cms/restore.sh` against the new Azure MySQL
6. Re-add `STRAPI_URL` / `STRAPI_API_TOKEN` env vars to the web Container App

**Estimated Time:** 30 minutes (local restore) / 2-3 hours (full Azure re-provision)
**Content Loss:** None — backup bundles in git are the authoritative archive

---

### 5.3 Regional Failover (Geo-Restore)

**When to Use:**
- Primary Azure region unavailable
- Natural disaster affecting datacenter
- Extended regional outage

**Prerequisites:**
- Access to Azure subscription
- Geo-redundant backups enabled (default for Azure SQL)
- Secondary region identified: East US 2 (Azure paired region)

**Steps:**

1. **Declare Disaster:**
   - Confirm primary region unavailable via Azure Service Health
   - Notify stakeholders of failover plan
   - Estimated downtime: 3-4 hours

2. **Provision Resources in Secondary Region:**
   ```bash
   # Set variables
   SECONDARY_RG="rg-aipatterns-prod-dr"
   SECONDARY_REGION="eastus2"

   # Create resource group
   az group create --name $SECONDARY_RG --location $SECONDARY_REGION

   # Restore database to secondary region (geo-restore)
   az sql db restore \
     --dest-name sqldb-aipatterns-prod-dr \
     --dest-resource-group $SECONDARY_RG \
     --dest-server sql-aipatterns-dr \
     --resource-group rg-aipatterns-prod \
     --server sql-aipatterns-sandr-1770754196 \
     --name sqldb-aipatterns-prod \
     --time "<latest-available-backup>"
   ```

3. **Deploy Container Apps to Secondary Region:**
   ```bash
   # Deploy backend Container App
   az containerapp create \
     --name ca-aipatterns-api-dr \
     --resource-group $SECONDARY_RG \
     --environment <container-apps-environment-dr> \
     --image <acr-name>.azurecr.io/aipatterns-api:latest \
     --target-port 8080 \
     --ingress external \
     --env-vars "ConnectionStrings__DefaultConnection=<secondary-db-connection-string>"

   # Deploy frontend Container App
   az containerapp create \
     --name ca-aipatterns-web-dr \
     --resource-group $SECONDARY_RG \
     --environment <container-apps-environment-dr> \
     --image <acr-name>.azurecr.io/aipatterns-web:latest \
     --target-port 3000 \
     --ingress external \
     --env-vars "NEXT_PUBLIC_API_BASE_URL=https://<backend-dr-url>/api"
   ```

4. **Update DNS (if using custom domain):**
   - Point DNS A record to secondary region Container Apps URL
   - TTL consideration: Wait for DNS propagation (5-60 minutes)

5. **Validate Application:**
   - Test health endpoints in secondary region
   - Verify data integrity
   - Test critical user flows
   - Monitor Application Insights for errors

6. **Communicate with Users:**
   - Post status update (e.g., status page, email, Slack)
   - Inform users of potential data loss (RPO: 24 hours)
   - Provide new URLs if DNS not updated

**Estimated Time:** 3-4 hours
**Data Loss:** Up to 24 hours (last geo-replicated backup)

**Failback Procedure (When Primary Region Recovers):**
1. Verify primary region stability
2. Sync any new data from DR database back to primary
3. Redeploy to primary region
4. Update DNS back to primary region
5. Decommission DR resources

### 5.4 Security Breach Recovery

**When to Use:**
- Compromised credentials
- Ransomware attack
- Unauthorized data modifications

**Prerequisites:**
- Security incident response team activated (see INCIDENT_RESPONSE.md)
- Forensic investigation initiated
- Clean backup identified (before breach)

**Steps:**

1. **Containment (Immediate):**
   ```bash
   # Disable all user access
   # (If authentication is implemented)

   # Rotate all credentials
   # Update Key Vault secrets
   az keyvault secret set \
     --vault-name appi-aipatterns-prod-kv \
     --name db-connection-string \
     --value "<new-connection-string>"

   # Restart applications to pick up new secrets
   az containerapp revision restart \
     --name ca-aipatterns-api-prod \
     --resource-group rg-aipatterns-prod
   ```

2. **Forensic Analysis:**
   - Export Application Insights logs for investigation
   - Review database audit logs (if enabled)
   - Identify breach timeline and affected data

3. **Identify Clean Backup:**
   ```bash
   # List backups before breach
   az sql db list-backups \
     --resource-group rg-aipatterns-prod \
     --server sql-aipatterns-sandr-1770754196 \
     --database sqldb-aipatterns-prod \
     --query "[?createdDate < '2026-02-13T08:00:00Z']"
   ```

4. **Restore from Clean Backup:**
   - Follow Section 5.2 (Point-in-Time Restore)
   - Use backup timestamp before breach

5. **Redeploy Application:**
   - Review code for vulnerabilities
   - Apply security patches
   - Deploy from known good commit

6. **Validation:**
   - Security scan of restored environment
   - Penetration testing (if resources available)
   - Monitor for suspicious activity

7. **Post-Incident:**
   - Document full timeline and root cause
   - Implement additional security controls
   - Update INCIDENT_RESPONSE.md with lessons learned

**Estimated Time:** 8+ hours (includes investigation)
**Data Loss:** Potentially significant (data since last clean backup)

---

## 6. DR Testing Schedule

### 6.1 Regular Testing

**Monthly Backup Verification:**
- **Frequency:** First Monday of every month
- **Duration:** 2 hours
- **Scope:** Restore database backup to test environment
- **Owner:** DevOps Engineer

**Quarterly DR Drill:**
- **Frequency:** Quarterly (January, April, July, October)
- **Duration:** Half day
- **Scope:** Full disaster recovery simulation (database + application)
- **Owner:** DevOps Team + Development Team

**Annual Regional Failover Test:**
- **Frequency:** Annually (October)
- **Duration:** Full day
- **Scope:** Complete failover to secondary region
- **Owner:** DevOps Team + IT Management

### 6.2 Test Documentation

**Template:** `documentation/operations/dr_test_YYYY-MM-DD.md`

**Required Information:**
- Date and time of test
- Scenario tested
- Steps executed
- Issues encountered
- Time to complete
- Success/failure status
- Action items for improvement

**Example:**
```markdown
# DR Test - 2026-03-01

**Test Type:** Monthly Backup Verification
**Scenario:** Database restore to test environment
**Duration:** 1.5 hours
**Status:** ✅ Success

## Steps Executed:
1. Identified latest daily backup
2. Created restore to test database
3. Verified row counts and data integrity
4. Tested application against restored database

## Issues:
- None

## Recommendations:
- Update restore procedure documentation with actual timings
```

---

## 7. Contact Information

### 7.1 Emergency Contacts

| Role | Name | Email | Phone | Availability |
|------|------|-------|-------|--------------|
| DR Coordinator | TBD | devops@example.com | +1-XXX-XXX-XXXX | 24/7 |
| Technical Lead | TBD | techlead@example.com | +1-XXX-XXX-XXXX | 24/7 |
| IT Manager | TBD | manager@example.com | +1-XXX-XXX-XXXX | Business hours |
| Azure Support | N/A | Azure Portal | N/A | 24/7 |

### 7.2 Azure Support

**How to Create Support Ticket:**
1. Navigate to Azure Portal
2. Click "Help + support" (question mark icon)
3. Click "Create a support request"
4. Select severity based on impact:
   - **Severity A (Critical):** Production system down, regional outage
   - **Severity B (High):** Database issues, degraded performance
   - **Severity C (Moderate):** Questions, guidance

**Support Plan:** Standard (included with Azure subscription)

---

## 8. Communication Plan

### 8.1 Disaster Declaration

**Who Declares:**
- DR Coordinator
- Technical Lead
- IT Manager

**Notification Method:**
1. Email to stakeholders (within 15 minutes)
2. Status page update (if available)
3. Slack/Teams announcement

**Template:**
```
SUBJECT: [DISASTER] AI Enterprise Patterns Library - Disaster Declared

Team,

A disaster has been declared for the AI Enterprise Patterns Library application.

Disaster Type: [Database corruption / Regional outage / Security breach]
Impact: [Service unavailable / Data loss / Performance degraded]
Estimated RTO: [4 hours]
Estimated RPO: [24 hours]

Recovery actions:
- [List key actions being taken]

Status updates will be provided every 30 minutes.

DR Coordinator: [Name]
Contact: [Phone/Email]
```

### 8.2 Status Updates

**Frequency:** Every 30 minutes during recovery
**Method:** Email + Slack/Teams

**Template:**
```
STATUS UPDATE - [HH:MM UTC]

Current status: [In progress / Restored / Testing]
Progress: [X% complete]
Next steps: [What's happening next]
ETA: [Estimated completion time]
```

### 8.3 Recovery Complete Notification

**Template:**
```
SUBJECT: [RESOLVED] AI Enterprise Patterns Library - Service Restored

Team,

The AI Enterprise Patterns Library has been successfully restored.

Recovery completed: [YYYY-MM-DD HH:MM UTC]
Total downtime: [X hours]
Data loss: [None / X hours of data]

Post-incident review scheduled: [Date/Time]

Thank you for your patience.
```

---

## 9. Post-Disaster Review

### 9.1 Review Process

**Timeline:** Within 5 business days of recovery

**Attendees:**
- DR Coordinator
- Technical Lead
- DevOps Team
- Development Team
- IT Management

**Agenda:**
1. Timeline review (what happened when)
2. Root cause analysis
3. Recovery procedure effectiveness
4. RTO/RPO adherence
5. Communication effectiveness
6. Action items for improvement

### 9.2 Documentation

**Post-Incident Report Template:**
- Incident summary
- Timeline of events
- Root cause
- Recovery actions taken
- Actual RTO vs target RTO
- Actual RPO vs target RPO
- Lessons learned
- Action items for improvement

**Storage Location:** `documentation/operations/incidents/YYYY-MM-DD-postmortem.md`

---

## 10. Continuous Improvement

### 10.1 DR Plan Review Schedule

**Quarterly Review:**
- Review and update contact information
- Update backup retention policies
- Review RTO/RPO targets
- Update recovery procedures based on changes

**Annual Review:**
- Comprehensive DR plan review
- Update based on DR test results
- Incorporate lessons learned from incidents
- Review and update disaster scenarios

### 10.2 Future Enhancements

**Phase 6 (Planned):**
- [ ] Implement automated geo-replication
- [ ] Set up secondary region (always-on)
- [ ] Reduce RPO to < 1 hour (transaction log shipping)

**Phase 7 (Planned):**
- [ ] Automated failover procedures
- [ ] Active-active multi-region deployment
- [ ] Reduce RTO to < 1 hour

**Phase 8 (Planned):**
- [ ] Zero-downtime regional failover
- [ ] RPO = 0 (synchronous replication)
- [ ] Automated DR testing

---

## 11. Compliance & Audit

### 11.1 Compliance Requirements

**Data Residency:**
- Primary: Central US
- Backup: East US 2 (Azure paired region)
- Both within United States (GDPR, data sovereignty considerations)

**Backup Retention:**
- Operational backups: 30 days
- Long-term retention: TBD (if required for compliance)

### 11.2 Audit Trail

**Backup Audit:**
- Monthly verification tests documented
- Quarterly DR drill results documented
- Annual failover test results documented

**Access Audit:**
- Azure Activity Log tracks all restore operations
- Key Vault audit log tracks secret access
- Retention: 90 days (Azure default)

---

## 12. Additional Resources

**Azure Documentation:**
- [Azure SQL Automated Backups](https://docs.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview)
- [Point-in-Time Restore](https://docs.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups)
- [Geo-Restore](https://docs.microsoft.com/en-us/azure/azure-sql/database/recovery-using-backups#geo-restore)
- [Business Continuity](https://docs.microsoft.com/en-us/azure/azure-sql/database/business-continuity-high-availability-disaster-recover-hadr-overview)

**Project Documentation:**
- [MONITORING_GUIDE.md](MONITORING_GUIDE.md) - Monitoring procedures
- [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md) - Security incident procedures
- [RUNBOOK.md](RUNBOOK.md) - Operational procedures

---

**Document Owner:** DR Coordinator
**Approval:** IT Management
**Review Schedule:** Quarterly
**Last Reviewed:** 2026-02-13
**Next Review:** 2026-05-13
