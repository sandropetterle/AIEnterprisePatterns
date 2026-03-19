# Phase 7.4: Backend Code Quality & Security — Implementation Plan

**Created:** 2026-03-18
**Status:** Evaluated — ready for implementation
**Parent:** [Phase 7 — Quality & Hardening Evaluation](PHASE_QUALITY_HARDENING_PLAN.md)

## Context

Phase 7 is a systematic 10-area quality and hardening audit. Phases 7.1 (frontend deps), 7.2 (backend deps), and 7.3 (frontend code/security) are evaluated with implementation plans ready. Phase 7.4 audits the ASP.NET Core backend for code quality issues, security gaps, and hardening opportunities.

**Overall assessment:** The backend is in strong shape — EF Core parameterizes all queries (no SQL injection), FluentValidation covers all input DTOs, role-based auth policies are correctly configured, and security headers are present. Findings are hardening improvements, not critical vulnerabilities.

**Findings:** 4 MEDIUM, 4 LOW, 5 accepted risks.

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | CORS hardcodes `localhost:3000` in production | MEDIUM | Track 1 |
| 2 | Missing HSTS header | MEDIUM | Track 1 |
| 3 | Vote endpoint race condition (load-modify-save) | MEDIUM | Track 2 |
| 4 | `OperationCanceledException` logged as Error | MEDIUM | Track 3 |
| 5 | Redundant `Enum.TryParse` in controller after FluentValidation | LOW | Track 4 |
| 6 | Tag validation allows whitespace-only strings | LOW | Track 4 |
| 7 | DB provider selection uses fragile `Contains("localhost,1433")` | LOW | Track 1 |
| 8 | `launchSettings.json` has `weatherforecast` leftover | LOW | Track 5 |
| 9 | Unused UnitOfWork injection | LOW | Accept |
| 10 | Exception details in production logs | LOW | Accept |

---

## Track 1: Security Headers & CORS Hardening

**Files:** `backend/src/AIEnterprisePatterns.Api/Program.cs`

### Problem A — CORS
Line 92 unconditionally adds `http://localhost:3000` to allowed origins, even in production. This expands the attack surface by allowing cross-origin requests from any machine's port 3000.

### Problem B — HSTS
Lines 187-194 set X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy but omit `Strict-Transport-Security`. Without HSTS, browsers won't enforce HTTPS on repeat visits, leaving the production API vulnerable to SSL stripping.

### Problem C — DB provider selection
Line 78 uses `connectionString.Contains("localhost,1433")` — fragile string matching. Simplify to: empty connection string = SQLite, non-empty = SQL Server.

### Implementation

1. **CORS** — Wrap localhost in environment check (line 92):
   ```csharp
   var frontendUrls = new List<string>();
   if (builder.Environment.IsDevelopment())
   {
       frontendUrls.Add("http://localhost:3000");
   }
   ```
   Production origins via `FrontendUrl`/`FrontendUrls` config are unchanged.

2. **HSTS** — Add inside existing security headers middleware (after line 192):
   ```csharp
   if (!app.Environment.IsDevelopment())
   {
       context.Response.Headers.Append("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
   }
   ```
   No `preload` directive (requires HSTS preload list submission — future scope).

3. **DB provider** — Simplify to connection-string-based decision (line 78):
   ```csharp
   if (string.IsNullOrEmpty(connectionString))
   {
       // SQLite for local dev without Docker
       var dbPath = Path.Combine(AppContext.BaseDirectory, "aipatterns.db");
       builder.Services.AddDbContext<ApplicationDbContext>(options =>
           options.UseSqlite($"Data Source={dbPath}"));
   }
   else
   {
       builder.Services.AddDbContext<ApplicationDbContext>(options =>
           options.UseSqlServer(connectionString,
               sqlOptions => sqlOptions.EnableRetryOnFailure()));
   }
   ```

**Verify:** `dotnet build && dotnet test` — 105/105 pass
**Commit:** `fix: harden CORS origins, add HSTS header, simplify DB provider selection (Phase 7.4)`

---

## Track 2: Vote Endpoint Race Condition

**Files:** `backend/src/AIEnterprisePatterns.Data/Repositories/PatternRepository.cs`

### Problem
`IncrementVoteCountAsync` (lines 204-214) loads the pattern, increments `VoteCount` in memory, then saves. Two concurrent requests both read `VoteCount=10`, both write `11`, losing a vote. The comment notes `ExecuteUpdateAsync` doesn't work with InMemory provider (used by tests).

### Implementation

Use `ExecuteUpdateAsync` for relational providers with InMemory fallback:

```csharp
public async Task<int> IncrementVoteCountAsync(Guid id, CancellationToken ct = default)
{
    if (_context.Database.IsRelational())
    {
        // Atomic SQL: UPDATE Patterns SET VoteCount = VoteCount + 1 WHERE Id = @id
        var rowsAffected = await _context.Patterns
            .Where(p => p.Id == id)
            .ExecuteUpdateAsync(s => s.SetProperty(
                p => p.VoteCount, p => p.VoteCount + 1), ct);

        if (rowsAffected == 0) return -1;

        return await _context.Patterns
            .Where(p => p.Id == id)
            .Select(p => p.VoteCount)
            .FirstAsync(ct);
    }

    // Fallback for InMemory provider (tests)
    var pattern = await _context.Patterns.FindAsync(new object[] { id }, ct);
    if (pattern == null) return -1;

    pattern.VoteCount++;
    await _context.SaveChangesAsync(ct);
    return pattern.VoteCount;
}
```

Existing tests use InMemory -> fallback path -> no test changes needed. Production uses SQLite/SQL Server -> atomic path.

**Verify:** `dotnet build && dotnet test` — 105/105 pass
**Commit:** `fix: use atomic SQL UPDATE for vote increment to prevent race condition (Phase 7.4)`

---

## Track 3: Exception Middleware Differentiation

**Files:** `backend/src/AIEnterprisePatterns.Api/Middleware/ExceptionHandlingMiddleware.cs`

### Problem
Line 23 catches all `Exception` including `OperationCanceledException`. Client disconnects (normal behavior) log as Error, creating noise in Application Insights and making real errors harder to spot.

### Implementation

Add specific catch before the general one:

```csharp
public async Task InvokeAsync(HttpContext context)
{
    try
    {
        await _next(context);
    }
    catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
    {
        _logger.LogInformation("Request cancelled by client: {Method} {Path}",
            context.Request.Method, context.Request.Path);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "An unhandled exception occurred");
        await HandleExceptionAsync(context);
    }
}
```

The `when` guard ensures only client-initiated cancellations are suppressed. Server-side `OperationCanceledException` from bugs still falls through to the general catch.

**Verify:** `dotnet build && dotnet test` — 105/105 pass
**Commit:** `fix: handle OperationCanceledException separately in exception middleware (Phase 7.4)`

---

## Track 4: Validation Cleanup

**Files:**
- `backend/src/AIEnterprisePatterns.Api/Controllers/PatternsController.cs`
- `backend/src/AIEnterprisePatterns.Api/Validators/CreatePatternDtoValidator.cs`
- `backend/src/AIEnterprisePatterns.Api/Validators/UpdatePatternDtoValidator.cs`

### Problem A — Redundant enum parsing
`PatternsController.cs` lines 90-91 and 112-113 do `Enum.TryParse` + `BadRequest` for invalid categories. But `FluentValidationAutoValidation` runs the validators first, which already reject invalid categories with a 400 before the action method executes. The controller code is dead.

### Problem B — Whitespace tags
`NotEmpty()` on tags (line 32) does NOT reject whitespace-only strings like `"   "`. Tags should be trimmed or rejected.

### Implementation

1. **Remove redundant enum validation** from `CreatePattern` and `UpdatePattern` actions. Replace `Enum.TryParse` + `BadRequest` with `Enum.Parse` (FluentValidation guarantees validity):
   ```csharp
   var category = Enum.Parse<PatternCategory>(dto.Category, true);
   ```

2. **Add whitespace check** to tag validation in both validators:
   ```csharp
   RuleForEach(x => x.Tags)
       .Must(t => !string.IsNullOrWhiteSpace(t))
       .WithMessage("Tags must not be empty or whitespace.")
       .MaximumLength(50);
   ```

Existing test `CreatePattern_ShouldReturn400ForInvalidCategory` still passes — FluentValidation returns 400 before the action.

**Verify:** `dotnet build && dotnet test` — 105/105 pass
**Commit:** `refactor: remove redundant enum validation, add whitespace tag check (Phase 7.4)`

---

## Track 5: Template Cleanup & Documentation

**Files:**
- `backend/src/AIEnterprisePatterns.Api/Properties/launchSettings.json`
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md`
- `documentation/project/ROADMAP.md`
- `CLAUDE.md`

### Implementation

1. Change `launchUrl` from `"weatherforecast"` to `"swagger"` in all profiles
2. Add Decision 52 to TECHNICAL_DECISIONS_LOG.md (Phase 7.4 summary)
3. Update ROADMAP.md: mark 7.4 as evaluated
4. Update CLAUDE.md vote race condition note (no longer a known issue)

**Commit:** `docs: add Phase 7.4 evaluation decision and update roadmap (Phase 7.4)`

---

## Accepted Risks

| # | Finding | Severity | Rationale |
|---|---------|----------|-----------|
| 9 | Unused UnitOfWork injection | LOW | PatternService uses `_unitOfWork.SaveChangesAsync()` for Create/Update/Delete. The vote path calls repository directly (intentional — atomic operation manages its own transaction). Removing UnitOfWork = larger refactor, no security benefit. |
| 10 | Exception details in production logs | LOW | Middleware returns generic message to clients (line 38). Full exception in server logs is intentional for debugging. Structured logging redaction is over-engineering at this scale. |
| — | Search `.ToLower()` allocations | NONE | EF Core translates to SQL `LOWER()` — no C# string allocations at runtime. Non-issue. |
| — | Missing CSP on backend | NONE | Backend is an API, not serving HTML. CSP is a frontend concern (Phase 7.3). |
| — | Missing Permissions-Policy | NONE | Only relevant for browser-rendered content, not APIs. |

---

## Execution Order

1. **Track 1** — CORS + HSTS + DB provider (highest security impact, production-facing)
2. **Track 3** — Exception middleware (reduces log noise, small change)
3. **Track 2** — Vote race condition (data integrity, slightly more complex)
4. **Track 4** — Validation cleanup (code quality)
5. **Track 5** — Template cleanup + documentation (last)

---

## Final Verification Checklist

- [ ] `dotnet build` — all 4 projects compile without warnings
- [ ] `dotnet test` — 105/105 tests pass
- [ ] CORS: dev includes `localhost:3000`; production does not
- [ ] HSTS: header present in non-development, absent in development
- [ ] Vote: `IncrementVoteCountAsync` uses `ExecuteUpdateAsync` for relational, fallback for InMemory
- [ ] Exception middleware: `OperationCanceledException` caught separately at `LogInformation`
- [ ] No redundant `Enum.TryParse` in controller actions
- [ ] Tag validation rejects whitespace-only strings
- [ ] `launchSettings.json` references `swagger` not `weatherforecast`
- [ ] Decision 52 added to TECHNICAL_DECISIONS_LOG.md
- [ ] ROADMAP.md updated
- [ ] CLAUDE.md vote race condition note updated

## NOT Actionable Now (Future)

| Item | When | Rationale |
|------|------|-----------|
| Docker image SHA pinning | Phase 7.7 | Container-specific concern, evaluated in Docker/containers area |
| Audit logging for CRUD operations | Phase 8+ | Requires design decisions about log storage, retention, access |
| Remove UnitOfWork pattern | Phase 8+ | Larger architectural refactor, no security benefit now |
| HSTS preload submission | Post-launch | Requires stable production domain + preload list application |
