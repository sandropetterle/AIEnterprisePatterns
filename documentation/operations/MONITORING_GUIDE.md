# Monitoring Guide - AI Enterprise Patterns Library

**Document Version:** 1.0
**Last Updated:** 2026-02-13
**Audience:** DevOps Engineers, Site Reliability Engineers, Support Team

---

## Overview

This guide explains how to monitor the AI Enterprise Patterns Library application using Azure Application Insights and Azure Portal. It covers key metrics, dashboards, alerts, and common troubleshooting queries.

---

## 1. Accessing Monitoring Tools

### 1.1 Azure Application Insights

**Production Environment:**
```
Resource Group: rg-aipatterns-prod
Application Insights: appi-aipatterns-prod
Location: Central US
```

**Access via Azure Portal:**
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for "Application Insights"
3. Select `appi-aipatterns-prod`
4. View metrics, logs, and dashboards

**Access via Application Insights URL:**
- https://portal.azure.com/#@yourtenant.com/resource/subscriptions/{subscription-id}/resourceGroups/rg-aipatterns-prod/providers/microsoft.insights/components/appi-aipatterns-prod

### 1.2 Azure Monitoring Dashboard

**Direct Link:** [Monitoring Dashboard](https://portal.azure.com/#dashboard)

Dashboard contains:
- Request rate and response time
- Error rate and availability
- Top slowest requests
- Recent exceptions

---

## 2. Key Metrics

### 2.1 Request Metrics

**Request Rate (requests/min)**
- **What it measures:** Number of HTTP requests per minute
- **Normal range:** 10-100 requests/min (varies by traffic)
- **Alert threshold:** N/A (informational)
- **How to access:** Application Insights → Metrics → Server requests

**Response Time**
- **What it measures:** Server-side request processing time
- **Normal range:** < 500ms (average), < 2000ms (P95)
- **Alert threshold:** P95 > 2000ms over 10 minutes
- **How to access:** Application Insights → Performance → Response time

### 2.2 Error Metrics

**Error Rate (%)**
- **What it measures:** Percentage of requests that result in 4xx or 5xx errors
- **Normal range:** < 1%
- **Alert threshold:** > 5% over 5 minutes
- **How to access:** Application Insights → Failures → Failed requests

**Exception Count**
- **What it measures:** Number of unhandled exceptions
- **Normal range:** 0-5 exceptions/hour
- **Alert threshold:** > 10 exceptions over 5 minutes
- **How to access:** Application Insights → Failures → Exceptions

### 2.3 Availability

**Availability (%)**
- **What it measures:** Percentage of successful health check responses
- **Normal range:** > 99%
- **Alert threshold:** < 99% over 5 minutes
- **How to access:** Application Insights → Availability → Test results

**Health Check Endpoint:**
- Frontend: https://<frontend-url>/
- Backend: https://<backend-url>/health

---

## 3. Dashboards

### 3.1 Operations Dashboard

**Access:** Azure Portal → Dashboards → "AIPatterns Prod Operations"

**Tiles:**
1. **Request Rate** - Line chart showing requests/min over 24 hours
2. **Response Time** - Line chart showing avg, P95, P99 over 24 hours
3. **Error Rate** - Line chart showing error percentage over 24 hours
4. **Availability** - Line chart showing uptime percentage
5. **Top 5 Slowest Requests** - Table with operation names and durations
6. **Recent Exceptions** - Table with exception types and timestamps

**How to Customize:**
1. Click "Edit" in dashboard toolbar
2. Add/remove tiles from Application Insights
3. Resize and reposition tiles
4. Click "Done editing" to save

### 3.2 Custom Queries

**Access:** Application Insights → Logs → New Query

**Common Queries:**

#### Query 1: Requests by Status Code (Last Hour)
```kql
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| order by count_ desc
```

#### Query 2: Top 10 Slowest Requests
```kql
requests
| where timestamp > ago(1h)
| top 10 by duration desc
| project timestamp, name, url, duration, resultCode
```

#### Query 3: Exception Breakdown
```kql
exceptions
| where timestamp > ago(1h)
| summarize count() by type, outerMessage
| order by count_ desc
```

#### Query 4: Failed Requests with Details
```kql
requests
| where resultCode >= 400
| where timestamp > ago(1h)
| project timestamp, name, url, resultCode, duration
| order by timestamp desc
```

#### Query 5: Request Rate Per Minute
```kql
requests
| where timestamp > ago(1h)
| summarize count() by bin(timestamp, 1m)
| render timechart
```

---

## 4. Alerts

### 4.1 Configured Alerts

**Alert 1: High Error Rate**
- **Condition:** Failed requests > 5% (over 5 minutes)
- **Severity:** High (Sev 2)
- **Action:** Email notification to devops@example.com
- **What to do:** Check Application Insights → Failures for root cause

**Alert 2: Slow Response Time**
- **Condition:** P95 response time > 2000ms (over 10 minutes)
- **Severity:** Medium (Sev 3)
- **Action:** Email notification to devops@example.com
- **What to do:** Check Application Insights → Performance → Slowest operations

**Alert 3: Availability Drop**
- **Condition:** Availability < 99% (over 5 minutes)
- **Severity:** Critical (Sev 1)
- **Action:** Email notification to devops@example.com
- **What to do:** Check health endpoints, verify Container Apps status

**Alert 4: Exception Spike**
- **Condition:** > 10 exceptions (over 5 minutes)
- **Severity:** High (Sev 2)
- **Action:** Email notification to devops@example.com
- **What to do:** Check Application Insights → Failures → Exceptions for stack traces

### 4.2 Alert Response Procedures

When you receive an alert:

1. **Acknowledge the alert** - Reply to email or update incident ticket
2. **Check the dashboard** - Verify if the issue persists
3. **Investigate root cause** - Use KQL queries to drill down
4. **Check recent deployments** - Was there a deployment in the last hour?
5. **Verify external dependencies** - Database, Azure services
6. **Take action** - Rollback, scale up, fix bug
7. **Document** - Log findings in incident response doc

---

## 5. Investigating Common Issues

### 5.1 High Error Rate

**Symptoms:**
- Error rate > 5%
- Many 4xx or 5xx responses

**Investigation Steps:**
1. Run query to identify failing endpoints:
   ```kql
   requests
   | where resultCode >= 400
   | where timestamp > ago(15m)
   | summarize count() by url, resultCode
   | order by count_ desc
   ```

2. Check for pattern:
   - Is it one endpoint or multiple?
   - Is it 404 (not found) or 500 (server error)?
   - Is it affecting all users or specific requests?

3. Check recent changes:
   - Was there a deployment?
   - Was there a configuration change?

**Common Causes:**
- **404 errors:** Broken links, missing patterns, incorrect slugs
- **500 errors:** Database connection issues, unhandled exceptions, bug in code

**Resolution:**
- If 404: Check frontend routes and backend API paths
- If 500: Check Application Insights → Exceptions for stack trace
- If deployment-related: Rollback to previous version (see RUNBOOK.md)

### 5.2 Slow Response Time

**Symptoms:**
- P95 response time > 2000ms
- Users report slow page loads

**Investigation Steps:**
1. Identify slowest operations:
   ```kql
   requests
   | where timestamp > ago(15m)
   | summarize avg(duration), percentiles(duration, 50, 95, 99) by name
   | where percentile_duration_95 > 2000
   | order by percentile_duration_95 desc
   ```

2. Check dependencies:
   ```kql
   dependencies
   | where timestamp > ago(15m)
   | summarize avg(duration), count() by target
   | order by avg_duration desc
   ```

3. Check database performance:
   - Azure SQL → Query Performance Insight
   - Look for long-running queries

**Common Causes:**
- Slow database queries (missing indexes, large result sets)
- External API timeouts
- Insufficient resources (CPU, memory)
- Cold start (Container Apps scale from zero)

**Resolution:**
- Optimize slow queries (add indexes, pagination)
- Increase Container App resources (CPU/memory)
- Adjust scale-to-zero settings (increase min-replicas)
- Add caching for frequently accessed data

### 5.3 Availability Drop

**Symptoms:**
- Health endpoint returns non-200 status
- Availability < 99%

**Investigation Steps:**
1. Check health endpoints manually:
   ```bash
   curl https://<backend-url>/health
   curl https://<frontend-url>/
   ```

2. Check Container Apps status:
   ```bash
   az containerapp list --resource-group rg-aipatterns-prod --output table
   ```

3. Check application logs:
   ```bash
   az containerapp logs show --name ca-aipatterns-api-prod --resource-group rg-aipatterns-prod --follow
   ```

**Common Causes:**
- Container Apps scaled to zero (cold start)
- Database connection failure
- Application crash/restart
- Azure platform issue

**Resolution:**
- If scaled to zero: Wait for warm-up (30-60 seconds)
- If database issue: Check connection string, verify SQL Server is running
- If app crash: Check logs for errors, rollback if needed
- If Azure issue: Check Azure Service Health dashboard

### 5.4 Exception Spike

**Symptoms:**
- > 10 exceptions in 5 minutes
- Error messages in Application Insights

**Investigation Steps:**
1. Identify exception types:
   ```kql
   exceptions
   | where timestamp > ago(15m)
   | summarize count() by type, outerMessage
   | order by count_ desc
   ```

2. Get stack traces:
   ```kql
   exceptions
   | where timestamp > ago(15m)
   | where type == "SpecificExceptionType"
   | project timestamp, outerMessage, innermostMessage, details
   | order by timestamp desc
   ```

3. Check correlation with requests:
   ```kql
   requests
   | where timestamp > ago(15m)
   | join kind=inner (exceptions) on operation_Id
   | project timestamp, url, resultCode, exceptionType = type, exceptionMessage = outerMessage
   ```

**Common Causes:**
- Null reference exceptions (missing data validation)
- Database connection exceptions (transient failures)
- Timeout exceptions (slow operations)
- Validation exceptions (invalid user input)

**Resolution:**
- Add null checks and validation
- Implement retry logic for transient failures
- Increase timeouts if appropriate
- Log detailed error information for debugging

---

## 6. Performance Baselines

**Established:** 2026-02-13 (Phase 4.5)
**Review Schedule:** Monthly

| Metric | Baseline | Target | Alert Threshold |
|--------|----------|--------|-----------------|
| Request Rate (avg) | 30 req/min | 100 req/min | N/A |
| Response Time (avg) | 250ms | < 500ms | P95 > 2000ms |
| Response Time (P95) | 800ms | < 1500ms | > 2000ms |
| Error Rate | 0.5% | < 1% | > 5% |
| Availability | 99.8% | > 99.5% | < 99% |
| Exception Rate | 2/hour | < 5/hour | > 10/5min |

**How to Update Baselines:**
1. Run queries over 7-day period
2. Calculate averages and percentiles
3. Update this section
4. Adjust alert thresholds if needed

---

## 7. Log Analysis

### 7.1 Application Logs

**Access:** Application Insights → Logs → traces table

**Query: Application Logs (Last Hour)**
```kql
traces
| where timestamp > ago(1h)
| order by timestamp desc
| project timestamp, severityLevel, message
```

**Query: Error Logs Only**
```kql
traces
| where severityLevel >= 3  // 3 = Error, 4 = Critical
| where timestamp > ago(1h)
| order by timestamp desc
```

### 7.2 Dependency Tracking

**Query: Database Call Performance**
```kql
dependencies
| where type == "SQL"
| where timestamp > ago(1h)
| summarize avg(duration), count() by name
| order by avg_duration desc
```

**Query: External API Calls**
```kql
dependencies
| where type == "HTTP"
| where timestamp > ago(1h)
| summarize count(), avg(duration) by target
```

---

## 8. Reporting

### 8.1 Daily Monitoring Report

**Generated automatically:** No (manual for now)
**Frequency:** Daily
**Recipients:** DevOps team

**Metrics to Include:**
- Total requests (last 24h)
- Average response time
- Error rate
- Availability
- Top 3 errors
- Performance vs baseline

### 8.2 Weekly Operations Review

**Frequency:** Weekly (Monday morning)
**Attendees:** DevOps, Development Team

**Agenda:**
- Review alerts triggered
- Discuss incidents
- Review performance trends
- Plan optimization work

---

## 9. Escalation

### 9.1 Severity Levels

| Severity | Description | Response Time | Example |
|----------|-------------|---------------|---------|
| **P0** | Service down | Immediate | Application completely unavailable |
| **P1** | Critical feature broken | 1 hour | Authentication not working |
| **P2** | Major feature degraded | 4 hours | Slow response times affecting users |
| **P3** | Minor issue | 1 business day | Occasional errors, no user impact |
| **P4** | Cosmetic/enhancement | 1 week | Dashboard formatting issue |

### 9.2 Contact List

| Role | Name | Email | Phone | Timezone |
|------|------|-------|-------|----------|
| Primary On-Call | TBD | devops@example.com | +1-XXX-XXX-XXXX | UTC-6 |
| Secondary On-Call | TBD | devops2@example.com | +1-XXX-XXX-XXXX | UTC-6 |
| Escalation Manager | TBD | manager@example.com | +1-XXX-XXX-XXXX | UTC-6 |
| Azure Support | N/A | N/A | Azure Portal | 24/7 |

---

## 10. Continuous Improvement

### 10.1 Monitoring Enhancements (Future)

**Phase 6 (Planned):**
- [ ] Set up Lighthouse CI for performance budgets
- [ ] Add synthetic monitoring (uptime checks)
- [ ] Create automated daily reports
- [ ] Add custom metrics (business KPIs)

**Phase 7 (Planned):**
- [ ] Implement distributed tracing
- [ ] Add user session monitoring
- [ ] Create SLA dashboards
- [ ] Integrate with PagerDuty/Slack

**Phase 8 (Planned):**
- [ ] AI-powered anomaly detection
- [ ] Predictive alerts
- [ ] Multi-region monitoring
- [ ] Custom telemetry for enterprise features

---

## 11. Additional Resources

**Azure Documentation:**
- [Application Insights Overview](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [KQL Query Language](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Azure Monitor Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)

**Project Documentation:**
- [RUNBOOK.md](RUNBOOK.md) - Operational procedures
- [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md) - Backup and restore procedures
- [INCIDENT_RESPONSE.md](INCIDENT_RESPONSE.md) - Security incident procedures

---

**Document Owner:** DevOps Team
**Review Schedule:** Quarterly
**Last Reviewed:** 2026-02-13
**Next Review:** 2026-05-13
