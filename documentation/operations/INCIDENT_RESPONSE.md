# Incident Response Plan - AI Enterprise Patterns Library

**Document Version:** 1.0
**Last Updated:** 2026-03-19
**Audience:** Security Team, DevOps Engineers, Development Team, IT Management

---

## 1. Overview

This Incident Response Plan defines procedures for identifying, responding to, and recovering from security incidents affecting the AI Enterprise Patterns Library. It covers classification, escalation, containment, eradication, and post-incident activities.

---

## 2. Incident Severity Classification

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| **P0 - Critical** | Complete service outage or active security breach | Immediate (< 15 min) | Service down, active attack, data breach |
| **P1 - High** | Major security vulnerability or partial outage | 1 hour | Authentication bypass, critical CVE, major feature down |
| **P2 - Medium** | Moderate security issue or degraded service | 4 hours | Exposed sensitive data, slow performance, minor vulnerability |
| **P3 - Low** | Minor security concern or isolated issue | 1 business day | Suspicious activity, low-impact bug |
| **P4 - Informational** | Security improvement or advisory | 1 week | Security recommendations, updates |

---

## 3. Incident Response Team

| Role | Responsibilities | Contact |
|------|-----------------|---------|
| **Incident Commander** | Overall response coordination | devops@example.com |
| **Security Lead** | Security analysis, forensics | security@example.com |
| **Technical Lead** | Technical investigation, remediation | techlead@example.com |
| **Communications Lead** | Stakeholder communication | comms@example.com |
| **Legal/Compliance** | Legal guidance, regulatory compliance | legal@example.com |

---

## 4. Incident Response Process

### Phase 1: Detection & Identification (0-15 minutes)

**Triggers:**
- Azure Application Insights alerts
- Security monitoring alerts
- User reports
- Penetration test findings
- Vulnerability disclosures

**Actions:**
1. **Confirm the incident** - Is this a false positive?
2. **Classify severity** - Use classification table (Section 2)
3. **Assign Incident Commander** - Declare incident
4. **Activate response team** - Page on-call personnel
5. **Start incident log** - Document all actions with timestamps

**Documentation:** Create `documentation/operations/incidents/YYYY-MM-DD-incident.md`

---

### Phase 2: Containment (15 min - 1 hour)

**Objective:** Stop the incident from spreading

**Short-term Containment (Immediate):**
```bash
# If active attack detected, block IP address (example)
az network nsg rule create \
  --resource-group rg-aipatterns-prod \
  --nsg-name nsg-aipatterns \
  --name DenyMaliciousIP \
  --priority 100 \
  --source-address-prefixes <malicious-ip> \
  --access Deny

# If credentials compromised, rotate immediately
az keyvault secret set \
  --vault-name appi-aipatterns-prod-kv \
  --name db-connection-string \
  --value "<new-secure-value>"

# Restart applications to pick up new secrets
az containerapp revision restart \
  --name ca-aipatterns-api-prod \
  --resource-group rg-aipatterns-prod
```

**Long-term Containment:**
- Isolate affected systems (if needed)
- Apply temporary security controls
- Preserve evidence for forensics

---

### Phase 3: Eradication (1-4 hours)

**Objective:** Remove the threat

**Actions:**
1. **Identify root cause** - How did the breach occur?
2. **Remove malicious code** - Scan and clean affected systems
3. **Patch vulnerabilities** - Apply security updates
4. **Restore from clean backups** - If data compromised (see DISASTER_RECOVERY.md)
5. **Infrastructure forensics** - Review Bicep module structure for misconfigured resources (open firewall rules, missing Key Vault restrictions, over-permissioned managed identities). See [INFRASTRUCTURE_MANAGEMENT.md](INFRASTRUCTURE_MANAGEMENT.md) for the full module inventory. Harden in Bicep and redeploy rather than patching manually in the portal.

**Example: SQL Injection Vulnerability**
```csharp
// BAD - Vulnerable code
var query = $"SELECT * FROM Patterns WHERE Title = '{userInput}'";

// GOOD - Parameterized query (EF Core does this by default)
var pattern = await _context.Patterns
    .FirstOrDefaultAsync(p => p.Title == userInput);
```

---

### Phase 4: Recovery (2-8 hours)

**Objective:** Restore normal operations securely

**Actions:**
1. **Verify threat eliminated** - Re-scan systems
2. **Restore services** - Bring systems back online
3. **Monitor closely** - Watch for recurrence
4. **Validate functionality** - Test critical flows
5. **Update security controls** - Implement permanent fixes

**Validation Checklist:**
- [ ] All security patches applied
- [ ] Credentials rotated
- [ ] Vulnerability scanned
- [ ] Monitoring alerts configured
- [ ] Application health verified
- [ ] User access tested

---

### Phase 5: Post-Incident Activities (1-5 business days)

**Immediate (Day 1):**
- [ ] Document full timeline
- [ ] Notify affected users (if data breach)
- [ ] File regulatory reports (if required - GDPR, etc.)

**Short-term (Days 2-5):**
- [ ] Conduct post-mortem meeting
- [ ] Create incident report
- [ ] Identify lessons learned
- [ ] Create action items for improvement

**Post-Mortem Template:** `documentation/operations/incidents/YYYY-MM-DD-postmortem.md`

---

## 5. Incident Types & Specific Procedures

### 5.1 Compromised Credentials

**Indicators:**
- Unusual login activity
- Access from unexpected locations
- Multiple failed login attempts

**Immediate Actions:**
1. Revoke compromised credentials
2. Force logout all sessions
3. Rotate all application secrets
4. Review access logs for unauthorized actions
5. Enable MFA (if not already enabled)

**Prevention:**
- Enforce strong password policies
- Implement MFA for all accounts
- Monitor for credential stuffing attacks

---

### 5.2 SQL Injection Attack

**Indicators:**
- Unusual database queries in logs
- Errors related to SQL syntax
- Unexpected data modifications

**Immediate Actions:**
1. Block attacker IP address
2. Review database audit logs
3. Identify affected data
4. Verify EF Core parameterized queries (should prevent this)
5. If data compromised, restore from backup

**Prevention:**
- Always use EF Core (parameterized queries)
- Never construct raw SQL with user input
- Enable database auditing
- Implement input validation (FluentValidation)

---

### 5.3 XSS (Cross-Site Scripting)

**Indicators:**
- Malicious JavaScript in pattern content
- User reports of unexpected behavior
- CSP violation reports

**Immediate Actions:**
1. Identify affected patterns
2. Sanitize content (rehype-sanitize should prevent this)
3. Remove malicious scripts
4. Verify CSP headers are active

**Prevention:**
- Always use rehype-sanitize for markdown rendering
- Implement Content Security Policy headers
- Validate and sanitize all user input
- Never use dangerouslySetInnerHTML

---

### 5.4 DDoS Attack

**Indicators:**
- Sudden spike in traffic
- Application slowness or unavailability
- High error rates

**Immediate Actions:**
1. Verify attack vs legitimate traffic spike
2. Enable Azure DDoS Protection (if not already enabled)
3. Implement rate limiting (already configured for vote endpoint)
4. Scale up Container Apps resources temporarily
5. Work with Azure Support for mitigation

**Prevention:**
- Azure DDoS Protection Standard (Phase 6+)
- Rate limiting on all endpoints
- CDN with DDoS protection (Phase 6+)

---

### 5.5 Data Breach

**Indicators:**
- Unauthorized data export
- Database dump found online
- User data in breach notification services

**Immediate Actions:**
1. **STOP** - Do not delete evidence
2. Activate legal/compliance team
3. Preserve logs and forensic evidence
4. Identify scope (what data, how many users)
5. Notify affected users (within 72 hours if GDPR applies)
6. File regulatory reports (if required)

**Legal Requirements:**
- GDPR: Notify users within 72 hours if EU users affected
- State breach notification laws (if US users affected)
- Document breach details for compliance

---

## 6. Communication Templates

### 6.1 Internal Incident Declaration

```
TO: Incident Response Team
SUBJECT: [P1] Security Incident Declared - AI Patterns Library

An incident has been declared:

Severity: P1 - High
Incident Type: [Compromised credentials / SQL injection / XSS / etc.]
Detected: [YYYY-MM-DD HH:MM UTC]
Incident Commander: [Name]

Initial Assessment:
- [Brief description of what happened]
- [Current impact]
- [Immediate actions taken]

Next Steps:
- [What's being done now]

War Room: [Slack channel / Teams meeting link]
Incident Log: documentation/operations/incidents/YYYY-MM-DD-incident.md
```

### 6.2 User Notification (Data Breach)

```
SUBJECT: Important Security Notice - AI Enterprise Patterns Library

Dear User,

We are writing to inform you of a security incident affecting the AI Enterprise Patterns Library.

What Happened:
On [Date], we discovered [brief description of incident]. We immediately took action to secure our systems and are working with security experts to investigate.

What Information Was Involved:
[Specific data types affected: names, emails, etc.]

What We Are Doing:
- We have [containment actions taken]
- We have [security improvements implemented]
- We are working with [law enforcement / security consultants]

What You Should Do:
- [Specific recommendations: change password, monitor accounts, etc.]

Additional Information:
For questions, please contact security@example.com or visit [status page URL]

We sincerely apologize for this incident and any inconvenience it may cause.

Sincerely,
[Name, Title]
AI Enterprise Patterns Library Team
```

---

## 7. Evidence Collection

### 7.1 What to Preserve

**Application Logs:**
```bash
# Export Application Insights logs
# Via Azure Portal: Application Insights → Logs → Export
# Time range: 24 hours before incident to present

# Query for suspicious activity
requests
| where timestamp > ago(24h)
| where resultCode >= 400
| project timestamp, url, resultCode, clientIP

# Export exceptions
exceptions
| where timestamp > ago(24h)
| project timestamp, type, outerMessage, details
```

**Database Logs:**
- Azure SQL audit logs
- Query performance logs
- Connection logs

**System Logs:**
- Container Apps logs
- Azure Activity Log
- Key Vault access logs

### 7.2 Chain of Custody

**Document:**
- Who collected the evidence
- When it was collected
- Where it's stored
- Who has access

**Storage:**
- Secure Azure Storage Account (encrypted)
- Access restricted to incident response team
- Retention: 1 year minimum

---

## 8. Regulatory & Legal Considerations

### 8.1 Notification Requirements

**GDPR (if EU users affected):**
- Notify supervisory authority within 72 hours
- Notify affected users "without undue delay"
- Document breach in internal register

**U.S. State Laws:**
- Varies by state (California, New York, etc.)
- Generally: Notify affected residents "without unreasonable delay"
- May require notification to state attorney general

### 8.2 Legal Consultation

**When to Involve Legal:**
- Any data breach affecting user data
- Potential regulatory violations
- Litigation risk
- Law enforcement involvement

**Legal Contact:** legal@example.com

---

## 9. Lessons Learned & Continuous Improvement

### 9.1 Post-Incident Review Meeting

**Schedule:** Within 5 business days of incident resolution

**Attendees:**
- Incident Response Team
- Development Team
- IT Management
- Legal (if applicable)

**Agenda:**
1. Incident timeline review
2. What went well
3. What could be improved
4. Root cause analysis
5. Action items for improvement

### 9.2 Action Items

**Track in:** GitHub Issues with label "security"

**Examples:**
- Implement additional monitoring
- Update security controls
- Improve documentation
- Conduct security training
- Patch identified vulnerabilities

---

## 10. Security Hardening Checklist

Based on Phase 4 remediation (completed), these controls are in place:

- [x] Input validation (FluentValidation)
- [x] XSS protection (rehype-sanitize, CSP headers)
- [x] Rate limiting (vote endpoint)
- [x] Secure password generation (cryptographically secure)
- [x] Secrets in Key Vault (not in code)
- [x] CORS restricted
- [x] HTTPS enforced
- [x] Swagger disabled in production
- [x] No exception details to clients

**Future Enhancements (Phase 5+):**
- [ ] Authentication & authorization
- [ ] Role-based access control
- [ ] Audit logging for sensitive operations
- [ ] Multi-factor authentication
- [ ] Security headers (HSTS, X-Frame-Options) ✅ Already implemented
- [ ] Content Security Policy ✅ Already implemented
- [ ] Regular security scanning (SAST/DAST)
- [ ] Penetration testing (annual)

---

## 11. Training & Awareness

### 11.1 Incident Response Training

**Frequency:** Quarterly
**Attendees:** Incident Response Team, Development Team
**Format:** Tabletop exercises, simulated incidents

**Topics:**
- Incident classification
- Containment procedures
- Communication protocols
- Evidence preservation

### 11.2 Security Awareness (All Staff)

**Frequency:** Annually
**Topics:**
- Phishing awareness
- Password security
- Social engineering
- Reporting suspicious activity

---

## 12. Useful Resources

**NIST Incident Response Guide:**
- https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf

**OWASP Top 10:**
- https://owasp.org/www-project-top-ten/

**Azure Security Best Practices:**
- https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns

**Project Documentation:**
- [MONITORING_GUIDE.md](MONITORING_GUIDE.md)
- [DISASTER_RECOVERY.md](DISASTER_RECOVERY.md)
- [RUNBOOK.md](RUNBOOK.md)

---

**Document Owner:** Security Lead
**Approval:** IT Management, Legal
**Review Schedule:** Quarterly
**Last Reviewed:** 2026-02-13
**Next Review:** 2026-05-13
