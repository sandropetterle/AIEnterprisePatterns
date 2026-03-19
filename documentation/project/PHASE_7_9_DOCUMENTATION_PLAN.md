# Phase 7.9: Documentation Completeness & Accuracy — Implementation Plan

**Created:** 2026-03-18
**Status:** Evaluated — ready for implementation
**Parent:** Phase 7 — Quality & Hardening Evaluation ([PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md))

---

## Context

Phase 7.9 audits all project documentation for completeness, accuracy, currency, and governance compliance. The documentation foundation is **strong** — `DOCUMENTATION_INDEX.md` is current, the Technical Decisions Log is healthy (52 decisions), API docs are complete (4 files, all endpoints with examples), CMS component docs are comprehensive (26 components with dependency map), all 14 Mermaid diagrams are embedded with consistent color palette, and `GOVERNANCE.md` is authoritative (10 sections). Four MEDIUM findings and two LOW accepted risks were identified. Three lightweight tracks address the MEDIUM findings. This is a **docs-only phase** with no code changes.

**Audit findings:** 4 MEDIUM, 2 LOW (accepted). ~65 minutes total effort.

---

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | `COMPREHENSIVE_TEST_RESULTS.md` severely stale (dated 2026-02-10, Pre-Phase 4 snapshot) | MEDIUM | Track 1 |
| 2 | 4 operations docs stale relative to Phase 6.8 Bicep IaC (all dated 2026-02-13) | MEDIUM | Track 2 |
| 3 | `CMS_ARCHITECTURE.md` Phase 2 status says "upcoming" but completed 2026-03-03 | MEDIUM | Track 3 |
| 4 | `AUTH_SETUP_GUIDE.md` missing required governance header (Last Updated, Audience, Purpose) | MEDIUM | Track 3 |
| 5 | `TESTING_STRATEGY.md` + `MANUAL_TEST_EXECUTION_GUIDE.md` reference non-existent `COMPREHENSIVE_TEST_PLAN.md` (8 occurrences across 2 files) | LOW | Accept |
| 6 | `SYSTEM_OVERVIEW.md` doesn't mention Phase 6.8 IaC layer | LOW | Accept |

---

## Accepted Risks

**Finding 5 (LOW): Dead links to `COMPREHENSIVE_TEST_PLAN.md`.** 5 references in `TESTING_STRATEGY.md` (lines 57, 78, 143, 170, 454) and 3 in `MANUAL_TEST_EXECUTION_GUIDE.md` (lines 11, 68, 292) point to `documentation/COMPREHENSIVE_TEST_PLAN.md` which doesn't exist — correct path is `documentation/testing/MANUAL_TEST_PLAN.md`. Trivial find-and-replace; can be bundled with any track if effort allows.

**Finding 6 (LOW): `SYSTEM_OVERVIEW.md` missing IaC reference.** Dated 2026-02-27, doesn't mention the `infrastructure/` Bicep layer (Phase 6.8). High-level overview remains architecturally accurate; `INFRASTRUCTURE_MANAGEMENT.md` is the single source of truth for IaC per GOVERNANCE.md Section 4.

---

## Track 1: Archive COMPREHENSIVE_TEST_RESULTS.md

**Files:** `documentation/test_results/COMPREHENSIVE_TEST_RESULTS.md`, `DOCUMENTATION_INDEX.md`
**Effort:** ~15 min

### Problem

`COMPREHENSIVE_TEST_RESULTS.md` is dated 2026-02-10 (Pre-Phase 4). It reports "PASSING WITH ISSUES" with outdated metrics (20 E2E tests vs actual 42, 8 test categories vs the current multi-layer infrastructure). Per GOVERNANCE.md Section 5 it's "exempt from retention (ongoing summary)" but hasn't been maintained as such — it's a frozen Phase 3 snapshot.

Phase 7.8 Track 1 already creates `phase6_test_results.md` and `phase7_8_testing_baseline.md` as the new current baselines. Updating COMPREHENSIVE_TEST_RESULTS.md would duplicate 7.8's work. Archive it instead.

### Implementation

1. Add archive banner at top of `COMPREHENSIVE_TEST_RESULTS.md`:
   ```markdown
   > **Archived:** 2026-03-18 (Phase 7.9). This file is a Pre-Phase 4 snapshot and no longer reflects current test metrics.
   > For current baselines, see `phase7_8_testing_baseline.md` (Phase 7.8 Track 1).
   > For Phase 6 additions, see `phase6_test_results.md`.
   ```
2. Update "Executive Summary" status from "PASSING WITH ISSUES" to "ARCHIVED — see current baselines above"
3. Update `DOCUMENTATION_INDEX.md` test_results table row to mark as "Archived (Pre-Phase 4 snapshot)"

**Verify:**
- [ ] Archive banner present at top of file
- [ ] DOCUMENTATION_INDEX.md reflects archived status
- [ ] No other docs reference COMPREHENSIVE_TEST_RESULTS.md as a current source

**Commit:** `docs: archive stale COMPREHENSIVE_TEST_RESULTS.md (Phase 7.9)`

---

## Track 2: Operations Docs — Add IaC Cross-References

**Files:**
- `documentation/operations/RUNBOOK.md`
- `documentation/operations/DISASTER_RECOVERY.md`
- `documentation/operations/INCIDENT_RESPONSE.md`
- `documentation/operations/MONITORING_GUIDE.md`

**Effort:** ~30 min

### Problem

All four operations docs are dated 2026-02-13, written before Phase 6.8 introduced Bicep IaC (`infrastructure/` directory) and the dedicated `INFRASTRUCTURE_MANAGEMENT.md`. The RUNBOOK has manual `az containerapp update` commands but no mention that infrastructure changes should go through Bicep. MONITORING_GUIDE describes Application Insights but not the 4 metric alerts defined in `monitoring.bicep`. DR plan references manual CLI recovery but not Bicep redeployment.

Per GOVERNANCE.md Section 4 (Single Source of Truth), operations docs should **link to** `INFRASTRUCTURE_MANAGEMENT.md` rather than duplicating its content.

### Implementation

1. **RUNBOOK.md:**
   - Update `Last Updated` to current date
   - Add new section after "Common Tasks" titled **"Infrastructure Changes"**:
     > All Azure infrastructure is managed via Bicep IaC. Do not create or modify Azure resources manually. See [INFRASTRUCTURE_MANAGEMENT.md](INFRASTRUCTURE_MANAGEMENT.md) for module structure, validate/what-if/deploy workflow, and secret management.
   - In "Deployment Procedures" section, add note that infrastructure-level changes (scaling, env vars in Bicep) require Bicep redeployment, not ad-hoc `az containerapp update`

2. **DISASTER_RECOVERY.md:**
   - Update `Last Updated` to current date
   - In recovery procedures, add Bicep redeployment as recovery strategy:
     > For full environment rebuild, use `./infrastructure/deploy.ps1` to redeploy all Azure resources from Bicep templates. See [INFRASTRUCTURE_MANAGEMENT.md](INFRASTRUCTURE_MANAGEMENT.md).

3. **INCIDENT_RESPONSE.md:**
   - Update `Last Updated` to current date
   - In containment/eradication section, add note that infrastructure forensics and hardening should reference `INFRASTRUCTURE_MANAGEMENT.md` for Bicep module structure

4. **MONITORING_GUIDE.md:**
   - Update `Last Updated` to current date
   - Add note in alerts section that 4 metric alerts (CPU, memory, HTTP 5xx, exception count) are defined declaratively in `infrastructure/modules/monitoring.bicep` — modify there, not via Azure Portal. Link to `INFRASTRUCTURE_MANAGEMENT.md`

**Verify:**
- [ ] All 4 files have updated `Last Updated` dates
- [ ] All 4 files link to `INFRASTRUCTURE_MANAGEMENT.md`
- [ ] No content duplication — cross-references only, per GOVERNANCE.md Section 4

**Commit:** `docs: add IaC cross-references to operations docs (Phase 7.9)`

---

## Track 3: CMS Architecture, Auth Guide, Decision Log

**Files:**
- `documentation/architecture/CMS_ARCHITECTURE.md`
- `documentation/operations/AUTH_SETUP_GUIDE.md`
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`

**Effort:** ~20 min

### Problem

**CMS_ARCHITECTURE.md** (line 15): Phase 2 status says "upcoming" but Phases 6.4–6.6 completed on 2026-03-03. The content type table (lines 23–34) is already correct (all 10 types listed) — only the status line is wrong.

**AUTH_SETUP_GUIDE.md**: Missing required GOVERNANCE.md Section 3 header — no `Last Updated`, `Audience`, or `Purpose` fields. Title goes directly to prose.

### Implementation

1. **CMS_ARCHITECTURE.md:**
   - Update `Last Updated` from 2026-02-27 to current date
   - Change line 15 from:
     `🔜 Phase 2 (6.4–6.6): About, Docs, Login, Error, Not-Found pages + pattern UI labels — upcoming`
     to:
     `✅ Phase 2 (6.4–6.6): About, Docs, Login, Error, Not-Found pages + pattern UI labels — complete (2026-03-03)`

2. **AUTH_SETUP_GUIDE.md:**
   - Add governance header after title (before the introductory paragraph):
     ```markdown
     **Last Updated:** 2026-03-18
     **Audience:** Infrastructure Engineers, Solutions Architects
     **Purpose:** Step-by-step guide for configuring Azure Entra External ID as the OIDC provider for frontend (Auth.js) and backend (JwtBearer) authentication.
     ```

3. **TECHNICAL_DECISIONS_LOG.md:**
   - Add decision (next available number) — "Phase 7.9 — Documentation Completeness & Accuracy Audit"
   - Content: Archived stale test results, added IaC cross-references to 4 operations docs, fixed CMS phase status, added governance headers. Rationale: GOVERNANCE.md mandates accuracy reviews; Phase 7 evaluation surfaced 4 MEDIUM documentation currency findings.

**Verify:**
- [ ] CMS_ARCHITECTURE.md Phase 2 shows "✅ ... complete (2026-03-03)"
- [ ] AUTH_SETUP_GUIDE.md has `Last Updated`, `Audience`, `Purpose` fields
- [ ] Decision added to TECHNICAL_DECISIONS_LOG.md with correct format

**Commit:** `docs: fix CMS phase status, add auth guide header, log decision (Phase 7.9)`

---

## Optional Quick Fix (bundle with any track)

Fix 8 dead links across 2 files — search-and-replace `COMPREHENSIVE_TEST_PLAN.md` → `MANUAL_TEST_PLAN.md`:
- `documentation/testing/TESTING_STRATEGY.md` (lines 57, 78, 143, 170, 454) — also fix path from `documentation/COMPREHENSIVE_TEST_PLAN.md` to `documentation/testing/MANUAL_TEST_PLAN.md`
- `documentation/testing/MANUAL_TEST_EXECUTION_GUIDE.md` (lines 11, 68, 292) — fix relative path from `../COMPREHENSIVE_TEST_PLAN.md` to `MANUAL_TEST_PLAN.md`

~5 min, trivial find-and-replace. Not a dedicated track but worth doing.

---

## Verification Checklist

- [ ] `COMPREHENSIVE_TEST_RESULTS.md` has archive banner; not referenced as current anywhere
- [ ] All 4 operations docs link to `INFRASTRUCTURE_MANAGEMENT.md` with updated dates
- [ ] `CMS_ARCHITECTURE.md` Phase 2 status is "complete (2026-03-03)"
- [ ] `AUTH_SETUP_GUIDE.md` has governance header fields
- [ ] Decision logged in `TECHNICAL_DECISIONS_LOG.md`
- [ ] `DOCUMENTATION_INDEX.md` updated for archived test results
- [ ] No code changes — docs-only phase, no tests to run

---

## Summary

| Track | Item | Files | Effort |
|-------|------|-------|--------|
| 1 | Archive stale COMPREHENSIVE_TEST_RESULTS.md | 2 | ~15 min |
| 2 | Add IaC cross-references to 4 operations docs | 4 | ~30 min |
| 3 | CMS phase status + auth guide header + decision log | 3 | ~20 min |
| Opt. | Fix 8 dead links (COMPREHENSIVE_TEST_PLAN → MANUAL_TEST_PLAN) | 2 | ~5 min |
| **Total** | | **~11 files** | **~70 min** |

### Strengths (no action needed)
- `DOCUMENTATION_INDEX.md` — excellent, current
- `TECHNICAL_DECISIONS_LOG.md` — 52 decisions, no gaps
- API docs — complete (4 files, all endpoints with examples)
- CMS component docs — comprehensive (26 components, dependency map)
- 14 Mermaid diagrams — all embedded, consistent color palette
- `GOVERNANCE.md` — authoritative (10 sections)
- Architecture docs — mostly current (`BACKEND_ARCHITECTURE.md` updated for 6.8)

### Critical files to modify
- `documentation/test_results/COMPREHENSIVE_TEST_RESULTS.md` — Track 1
- `DOCUMENTATION_INDEX.md` — Track 1
- `documentation/operations/RUNBOOK.md` — Track 2
- `documentation/operations/DISASTER_RECOVERY.md` — Track 2
- `documentation/operations/INCIDENT_RESPONSE.md` — Track 2
- `documentation/operations/MONITORING_GUIDE.md` — Track 2
- `documentation/architecture/CMS_ARCHITECTURE.md` — Track 3
- `documentation/operations/AUTH_SETUP_GUIDE.md` — Track 3
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — Track 3
- `documentation/testing/TESTING_STRATEGY.md` — Optional fix
- `documentation/testing/MANUAL_TEST_EXECUTION_GUIDE.md` — Optional fix
