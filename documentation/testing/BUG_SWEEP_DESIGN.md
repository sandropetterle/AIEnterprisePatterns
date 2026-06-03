# Design — On-demand Browser Bug-Sweep (hybrid, convergent)

**Last Updated:** 2026-06-03
**Audience:** Sandro; developers running or extending `/bug-sweep`
**Purpose:** Methodology, rationale, and scope boundary for the on-demand browser bug-sweep — what the auditor checks, the evidence bar that keeps it honest, the reward-zero principle, and how findings converge to zero across runs. Operational script: [`.claude/skills/bug-sweep/SKILL.md`](../../.claude/skills/bug-sweep/SKILL.md). Decision: TECHNICAL_DECISIONS_LOG.md #72.

---

## 1. Purpose & non-goals

### 1.1 Purpose

An on-demand, locally-run agent that drives the AI Enterprise Patterns platform in a real browser, finds **genuine** defects against the project's documented behavior, and writes confirmed candidates to [`BUG_SWEEP_FINDINGS.md`](./BUG_SWEEP_FINDINGS.md) for human triage. The objective is **convergence toward 0 open bugs** over repeated runs — not a one-off audit.

It is **hybrid** by design: it runs the CI-proven Playwright e2e suite (`npm run test:e2e`) as a deterministic **regression baseline**, then **explores beyond it** live via Playwright MCP — model-in-the-loop, adapting to what each surface actually shows. The baseline catches encoded regressions; the live exploration finds the *unencoded* (the defect class that assertion-bound testing structurally cannot surface).

### 1.2 Non-goals

| | What |
|---|---|
| Deferred | Accessibility (axe/WCAG) and brand/visual-fidelity tiers — a future opt-in, not built now (see §9). Wiring the sweep into CI (it is on-demand). |
| Never | Driving destructive flows against production. Writing the fix (the auditor reports; remediation is the normal dev workflow). Auto-committing. |

The sweep **discovers and files**; it does not yet **guard** (a found-and-fixed bug becomes a permanent regression only when someone encodes it as a new e2e spec — the "harden" step, §9).

---

## 2. Scope model — what counts as a bug

A bug exists only relative to an oracle of "correct." This system's oracle is layered:

| Layer | Oracle | Status |
|---|---|---|
| **Functional correctness** | The surface's documented behavior in `SKILL.md`'s surface inventory + `documentation/requirements/FUNCTIONAL_REQUIREMENTS.md` + the `CLAUDE.md` conventions (category enum mapping, slug routing, optimistic-vote revert-on-error, revalidation windows). Broken/missing flows, wrong states, absent error handling, broken navigation. | **Active** |
| **Cross-cutting invariants** | The numbered checklist in §4 — clean render, no unexpected 4xx/5xx, no stray `error.tsx`/404, auth gating, nav/images + theme persistence, sane empty/loading states. | **Active** |
| **Accessibility** | WCAG 2.1 AA (`FUNCTIONAL_REQUIREMENTS.md §6`) — axe violations, focus, tab order. | **Staged** |
| **Brand / visual fidelity** | Copy quality + shipped-vs-design visual comparison. | **Staged** |

The starting set is the two layers with **already-written-down** oracles — which keeps the false-positive rate low, and a low FP-rate is the load-bearing property for the anti-padding goal (§3). The staged layers carry more judgment and switch on only once the signal is trusted (§8).

---

## 3. Anti-padding contract (the crux)

The one failure mode that kills this is an LLM padding weak findings to look productive. The contract:

- **Evidence bar, enforced.** Every finding carries `{surface, auth, severity, repro[], observed (concrete), expected (concrete), oracle_cite, signature}`. A candidate missing `oracle_cite`, or lacking a concrete `observed ≠ expected` delta, is a **hunch** — dropped before it reaches the ledger.
- **Reward-zero.** Returning 0 findings on a clean surface is the **goal**, not a failure. The 10-finding budget is a **ceiling, never a quota.** Padding toward it is a contract violation.
- **Self-review pass.** After collecting candidates, the auditor re-screens each ("would a maintainer reject this as speculative?") and drops the weak ones before reporting.
- **False-positive rate is the health metric.** `rejected-as-false-positive ÷ reported`, recorded per run in the `Run log`. **Convergence *is* that number trending to ~0.** If it doesn't trend down, the evidence bar or an oracle is wrong — not the codebase.

This mirrors the project's verification discipline: no claim without concrete evidence.

---

## 4. Cross-cutting invariants

Applied to every surface; each maps to an oracle the auditor cites:

1. **Clean render** — no `console.error`, no uncaught exception, no React hydration mismatch.
2. **No unexpected failed request** — no 4xx/5xx the page issues, *except* an expected unauth 401.
3. **No stray error surface** — a should-render surface does not show `app/error.tsx` / `app/patterns/error.tsx` / an unexpected 404.
4. **Auth gating holds** — a protected route hit unauthenticated redirects to `/login?callbackUrl=...` (never renders its form, never a route-enumeration 404); it renders for an Editor session.
5. **Navigation integrity** — nav links + images resolve; the theme toggle persists across navigation (`localStorage`).
6. **Graceful empty/loading** — `loading.tsx` and empty filter results resolve to a sensible state, not a crash.

---

## 5. State model

One persistent ledger — [`BUG_SWEEP_FINDINGS.md`](./BUG_SWEEP_FINDINGS.md):

- **Run log** — one row per run; reported + (at triage) accepted / rejected-FP / FP-rate.
- **Open** — candidates awaiting triage, plus accepted-but-not-yet-fixed.
- **Fixed** — accepted findings whose fix landed.
- **Rejected** — reason-tagged; **this section *is* the suppression memory** the auditor loads each run. A `{surface, signature}` here is never re-reported.

A rejection usually means the **oracle** is wrong, not just the finding — so each reject reason routes to a durable action (correct the cited doc for `by-design`; tighten the evidence bar for `false-positive`), not just a blocklist entry. Reasons: `by-design` / `false-positive` / `wont-fix` / `duplicate` / `deferred`.

---

## 6. Architecture — two pieces, one browser-driver

- **`bug-sweep` skill** (orchestrator): resolves scope from the canonical surface inventory, runs the stack preflight (HARD gate), dispatches the auditor in sequential batches honouring the 10-finding ceiling + suppression memory, and writes the ledger. **It never drives the browser itself.**
- **`bug-sweep-auditor` subagent** (the only browser-driver): runs the e2e baseline + drives Playwright MCP, returns schema-valid candidate findings. **Read-only re findings** — no `Edit`/`Write`, so it cannot touch the ledger or the codebase.

**Why Opus for the auditor.** The primary delegation risk is *judgment* — not inventing bugs to fill the budget, and correctly distinguishing a real defect from a clean redirect. That is exactly the kind of work where model quality matters most, so the auditor runs on Opus.

**Why the skill is the only writer.** Separating "drive + judge" (auditor, read-only) from "record" (skill) makes speculative findings structurally impossible: a row can only exist if the auditor *returned* it.

---

## 7. Target environment & auth

- **Frontend** on **port 3000** (`npm run dev`) — matching the committed `playwright.config.ts` webServer default and CI, so the e2e baseline reuses the running dev server (`reuseExistingServer: true`) with no `PLAYWRIGHT_BASE_URL` override.
- **Backend** on **port 5255** (`dotnet run --project backend/src/AIEnterprisePatterns.Api`) with its seeded SQLite (6 patterns / 18 tags) — data-dependent flows (listing, detail, vote) need it.
- **Auth.** Set `AUTH_SECRET` in `.env.local`; `playwright.config.ts` loads it (via `@next/env`) so `e2e/global.setup.ts` mints the synthetic session (`e2e/.auth/admin.json`, **Admin** role — which satisfies the `RequireEditor` gate). The live MCP context is **unauthenticated** (the Auth.js cookie is `httpOnly`, not injectable from page JS), so it verifies the **unauth→redirect** invariant directly; the **authenticated render** of protected surfaces is covered by the e2e baseline (`e2e/authenticated-flows.spec.ts`, which loads the storage state via `test.use`). This split avoids the false "blank page" finding on a correctly-gated route.

---

## 8. Convergence & scope expansion

Real bugs get fixed (removed from the surface); rejected noise gets suppressed or corrected at the oracle; so each run is quieter, until the only findings left come from changes made since the last run. The staged layers (accessibility, brand/visual) are a future opt-in — activated only on explicit confirmation, never silently widened.

---

## 9. Future

- Promote each `Fixed` finding into a new Playwright e2e spec (the "harden" half — turning a one-time discovery into a permanent regression guard that CI runs).
- Activate the accessibility / visual layers once the FP-rate is trusted.

---

## 10. References

- `.claude/skills/bug-sweep/SKILL.md` — the operational script (run / triage modes, surface inventory).
- `.claude/agents/bug-sweep-auditor.md` — the read-only auditor contract.
- `documentation/testing/BUG_SWEEP_FINDINGS.md` — the living ledger.
- `documentation/requirements/FUNCTIONAL_REQUIREMENTS.md` — the functional oracle.
- `documentation/testing/TESTING_STRATEGY.md` — the broader test approach this complements.
- `e2e/critical-flows.spec.ts`, `e2e/authenticated-flows.spec.ts` — the regression baseline.
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` #72 — the decision adopting this tooling.
