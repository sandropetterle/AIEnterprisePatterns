# Phase 7.2: Backend Dependency Audit — Implementation Plan

**Created:** 2026-03-17
**Status:** Evaluated — ready for implementation
**Parent:** Phase 7 — Quality & Hardening Evaluation (`PHASE_QUALITY_HARDENING_PLAN.md`)

## Context

Phase 7 is a 10-area quality hardening audit. Area 7.2 audits all 7 backend `.csproj` files for vulnerabilities, outdated packages, and CI automation gaps. Audit found: **1 HIGH CVE** (DoS in Caching.Memory), **19 outdated packages** (all within .NET 8.x), **no vulnerability scanning in CI**, and **no Dependabot for NuGet**.

---

## Track 1: Security Fix (CVE-2024-43483)

**File:** `backend/tests/AIEnterprisePatterns.Core.Tests/AIEnterprisePatterns.Core.Tests.csproj`

| Package | From | To | Severity |
|---------|------|----|----------|
| Microsoft.Extensions.Caching.Memory | 8.0.0 | 8.0.1 | HIGH (DoS via hash flooding) |

- Test-only dependency, minimal risk
- **Verify:** `dotnet list package --vulnerable --include-transitive` → zero vulnerabilities, 105/105 tests pass
- **Commit:** `fix: patch CVE-2024-43483 in Caching.Memory test dependency (Phase 7.2)`

---

## Track 2: Production Dependency Updates

All within .NET 8 LTS servicing — no TFM change needed.

### Api project (`backend/src/AIEnterprisePatterns.Api/`)

| Package | From | To |
|---------|------|----|
| Asp.Versioning.Mvc | 8.1.0 | 8.1.1 |
| Asp.Versioning.Mvc.ApiExplorer | 8.1.0 | 8.1.1 |
| FluentValidation.AspNetCore | 11.3.0 | 11.3.1 |
| JwtBearer | 8.0.0 | 8.0.25 |
| EF Core Design | 8.0.0 | 8.0.25 |
| Swashbuckle.AspNetCore | 6.5.0 | 6.9.0 |

### Data project (`backend/src/AIEnterprisePatterns.Data/`)

| Package | From | To |
|---------|------|----|
| EF Core (all 4 packages) | 8.0.0 | 8.0.25 |

### Infrastructure project (`backend/src/AIEnterprisePatterns.Infrastructure/`)

| Package | From | To |
|---------|------|----|
| ApplicationInsights.AspNetCore | 2.22.0 | 2.23.0 |
| HealthChecks.EF Core | 8.0.0 | 8.0.25 |

**Swashbuckle 6.5.0 → 6.9.0 note:** 4-minor jump; dev-only (guarded by `IsDevelopment()`), zero production risk. Verify Swagger UI loads at `/swagger`. Swashbuckle is deprecated for .NET 9+ in favor of `Microsoft.AspNetCore.OpenApi` — document as future consideration, not actionable on .NET 8.

- **Verify:** Clean build, 105/105 tests, Swagger loads, `/health` returns "Healthy"
- **Commit:** `chore: update backend production dependencies to latest .NET 8.x (Phase 7.2)`

---

## Track 3: Test Infrastructure Updates

**Files:** All 3 test `.csproj` files

### Common updates (all 3 test projects):

| Package | From | To |
|---------|------|----|
| FluentAssertions | 8.8.0 | 8.9.0 |
| Microsoft.NET.Test.Sdk | 17.8.0 | 17.14.1 |
| xunit | 2.5.3 | 2.9.3 |
| xunit.runner.visualstudio | 2.5.3 | 2.8.2 |

### Per-project updates:

| Package | From | To | Project |
|---------|------|----|---------|
| Mvc.Testing | 8.0.0 | 8.0.25 | Api.Tests |
| EF InMemory | 8.0.0 | 8.0.25 | Api.Tests, Data.Tests |

### NOT updating:
- **Moq 4.20.72** — already latest 4.x (no 5.x due to SponsorLink controversy; package is clean)
- **coverlet.collector 6.0.4** — 8.x is a major jump aligned with .NET 10; stay on 6.x
- **xunit.runner.visualstudio** — stay within 2.x line (3.x is a major rewrite)

- **Verify:** 105/105 tests pass, coverage reports generate correctly, no new analyzer warnings
- **Commit:** `chore: update backend test infrastructure packages (Phase 7.2)`

---

## Track 4: CI Hardening

### 4a. NuGet vulnerability gate

Add after "Restore dependencies" step in both:
- `.github/workflows/test.yml` (line 28, `backend-tests` job)
- `.github/workflows/backend-container-deploy.yml` (line 36, `run-tests` job)

```yaml
- name: Security audit (NuGet vulnerabilities)
  run: |
    dotnet list package --vulnerable --include-transitive 2>&1 | tee vuln-report.txt
    if grep -q "has the following vulnerable packages" vuln-report.txt; then
      echo "::error::Vulnerable NuGet packages detected"
      exit 1
    fi
```

Note: `dotnet list package --vulnerable` always exits 0 — grep-based gating is required.

### 4b. Dependabot for NuGet

Add NuGet ecosystem to `.github/dependabot.yml` (create file if 7.1 hasn't already, or append):

```yaml
- package-ecosystem: "nuget"
  directory: "/backend"
  schedule:
    interval: "weekly"
    day: "monday"
  groups:
    dotnet-servicing:
      patterns: ["Microsoft.*"]
    ef-core:
      patterns: ["Microsoft.EntityFrameworkCore*"]
    test-infrastructure:
      patterns: ["xunit*", "FluentAssertions", "Microsoft.NET.Test.Sdk", "coverlet.*", "Moq"]
  ignore:
    - dependency-name: "Microsoft.*"
      update-types: ["version-update:semver-major"]
    - dependency-name: "coverlet.*"
      update-types: ["version-update:semver-major"]
```

- **Commit:** `ci: add NuGet vulnerability gate and Dependabot config (Phase 7.2)`

---

## Track 5: Documentation

1. **Decision entry** in `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — Backend dependency hardening strategy (CVE patch, .NET 8 servicing, CI gate, Dependabot, future .NET 10 migration path)
2. **Mark 7.2 evaluated** in `documentation/project/PHASE_QUALITY_HARDENING_PLAN.md`
3. **Update** `documentation/project/ROADMAP.md` with 7.2 completion
4. **Update** `CLAUDE.md` if needed (package versions, phase status)

- **Commit:** `docs: document Phase 7.2 backend dependency hardening decision`

---

## Execution Order

1. Track 1 (security fix — highest priority, 1 line change)
2. Track 2 (production deps — verify API works)
3. Track 3 (test deps — verify test runner works)
4. Track 4 (CI hardening — gates future regressions)
5. Track 5 (documentation — captures decisions)

Tracks 1-3 may be combined into one commit if all verifications pass together.

---

## Final Verification

- [ ] `dotnet list package --vulnerable --include-transitive` → zero vulnerabilities
- [ ] `dotnet build --configuration Release` → clean, no warnings
- [ ] `dotnet test --configuration Release` → 105/105 pass
- [ ] Swagger UI loads at `http://localhost:5255/swagger`
- [ ] `/health` returns "Healthy"
- [ ] CI YAML valid (test.yml, backend-container-deploy.yml)
- [ ] `.github/dependabot.yml` includes NuGet ecosystem

---

## NOT Actionable Now (Future)

| Item | When |
|------|------|
| .NET 9/10 upgrade (unlocks latest Microsoft.* packages) | .NET 10 LTS (~Nov 2026) |
| Replace Swashbuckle with Microsoft.AspNetCore.OpenApi | With .NET 9/10 migration |
| coverlet.collector 8.x | With .NET 10 migration |
| xunit 3.x | Evaluate separately (major API changes) |
| Replace Moq with NSubstitute | Only if maintenance stalls |
