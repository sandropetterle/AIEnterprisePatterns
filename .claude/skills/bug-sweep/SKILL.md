---
name: bug-sweep
description: Use when you want to exercise the entire AI Enterprise Patterns platform in a real browser to surface regressions and defects — pre-release QA, "sweep the whole app for bugs", verifying routes/flows still work after a change — or when triaging (accept/reject) browser findings a previous sweep surfaced. Modes — run (default) / triage. Design doc — documentation/testing/BUG_SWEEP_DESIGN.md
---

# bug-sweep skill

You are executing the `bug-sweep` skill — the on-demand browser bug-finder for the AI Enterprise Patterns platform. Goal: converge toward **0 open bugs** over repeated runs. The sweep is **hybrid** — it runs the CI-proven Playwright e2e suite as a regression baseline, then explores beyond it live via Playwright MCP. Full methodology + rationale: [`documentation/testing/BUG_SWEEP_DESIGN.md`](../../../documentation/testing/BUG_SWEEP_DESIGN.md). Follow this script precisely.

**Core principles (load-bearing — do not soften):**
- **The auditor is the only browser-driver.** This skill resolves scope, dispatches the `bug-sweep-auditor`, and edits the ledger. It never drives Playwright itself.
- **Evidence bar.** A finding requires a concrete `observed ≠ expected` delta **and** an oracle cite. Anything else is a hunch — it never reaches the ledger.
- **Reward-zero.** A run reporting few or zero findings is a **success** — it is the convergence target, not a failure. Never tell the auditor to "find more"; never lower the bar to fill the budget.
- **Never write a finding the auditor did not return.** Every `BSW-NNNN` row comes from a returned `findings[]` entry — never from your own anticipation of what an auditor will probably find.
- **Never `git add` / `git commit`.** Leave staging to the operator.

**Canonical state file** (rooted at the repo root, `C:\Projects\AIEnterprisePatterns`):
- `documentation/testing/BUG_SWEEP_FINDINGS.md` — the living ledger (`Run log` + `Open` / `Fixed` / `Rejected` + suppression memory).

---

## Step 0 — Mode detection

Parse `$ARGUMENTS`:
- `triage` → **Triage mode**.
- anything else / empty → **Run mode**.

Announce the chosen mode before any action.

---

## Surface inventory (canonical scope — pass this to the auditor)

Each surface is `{route, auth, oracle_refs[], checks[]}`. `auth: none` drives unauthenticated; `auth: editor` loads the synthetic session storage state (`e2e/.auth/admin.json` — its **Admin** role satisfies the `RequireEditor` gate).

**Public:**
| route | auth | oracle_refs | checks |
|---|---|---|---|
| `/` | none | `FUNCTIONAL_REQUIREMENTS.md §1`; `CLAUDE.md` (revalidation 5min) | hero/featured/stats/CTA render; nav links resolve; theme toggle persists across nav |
| `/patterns` | none | `FUNCTIONAL_REQUIREMENTS.md §2` | search `q`; filter `category`, `tags`+`tagMode`, `sort`, `dateFrom/dateTo`; `page`; saved searches + recently-viewed (localStorage); empty-result state is sensible, not a crash |
| `/patterns/[slug]` | none | `FUNCTIONAL_REQUIREMENTS.md §3`; `CLAUDE.md` (optimistic-vote revert-on-error, slug routing) | markdown renders; vote optimistic update + revert-on-error; breadcrumb; related patterns; edit/delete buttons gated by role |
| `/about` | none | `FUNCTIONAL_REQUIREMENTS.md` | renders; nav/images resolve |
| `/docs` | none | `FUNCTIONAL_REQUIREMENTS.md` | renders; nav/images resolve |
| `/login` | none | `FUNCTIONAL_REQUIREMENTS.md §5` | renders; redirects to `/` when already authed; error param surfaces a message |
| 404 (non-existent slug) | none | `app/not-found.tsx` (root boundary `[slug]/page.tsx` falls through to) | a bad slug renders `not-found`, not `error.tsx` / a crash |

**Protected (Editor):**
| route | auth | oracle_refs | checks |
|---|---|---|---|
| `/patterns/new` | editor | `FUNCTIONAL_REQUIREMENTS.md §4`; `auth.ts` + page guard | unauth → redirect `/login?callbackUrl=...`; with Editor session the create form renders + validates on blur/submit |
| `/patterns/[slug]/edit` | editor | `FUNCTIONAL_REQUIREMENTS.md §4`; `auth.ts` + page guard | unauth → redirect `/login?callbackUrl=...`; with Editor session the form renders pre-filled |

**Cross-cutting invariants (apply to every surface — each maps to an oracle cite):**
1. No `console.error` / uncaught exception / React hydration mismatch (oracle: clean-render invariant, `BUG_SWEEP_DESIGN.md §invariants`).
2. No failed network request (4xx/5xx) the page issues, **except** an expected unauth 401.
3. A surface that should render does **not** show `app/error.tsx` / `app/patterns/error.tsx` / an unexpected 404.
4. Auth gating holds: protected route unauth → redirect to `/login`; renders for Editor (`auth.ts` + page guards).
5. Nav links + images resolve; theme toggle persists across navigation (`localStorage`).
6. Empty / loading states resolve sensibly, not a crash (`loading.tsx`, empty filter results).

**Severity:** `block` / `major` / `minor`. **Oracle sources** (one indirection max): the surface's documented behavior in this table, `CLAUDE.md` conventions (category mapping, slug routing, optimistic-vote revert, revalidation), and `documentation/requirements/FUNCTIONAL_REQUIREMENTS.md`.

---

## Run mode

### 1. Load state + suppression memory
`Read` `BUG_SWEEP_FINDINGS.md`. Build `suppressions[]` as `{surface, signature}` from every row in the `Rejected` section.

### 2. Stack preflight — HARD gate
Check the frontend (port **4000**) and backend are reachable (PowerShell):
```powershell
try { $null = Invoke-WebRequest http://localhost:4000 -UseBasicParsing -TimeoutSec 5; $null = Invoke-WebRequest http://localhost:5255/health -UseBasicParsing -TimeoutSec 5; "preflight-ok" } catch { "preflight-fail: $($_.Exception.Message)" }
```
If the result is not `preflight-ok`, **halt** and print verbatim:

> Bug-sweep needs the local stack up. In one shell (repo root): `npm run dev -- -p 4000`. In another: `dotnet run --project backend/src/AIEnterprisePatterns.Api`. Set `AUTH_SECRET` (`openssl rand -base64 32`) before starting the frontend so `e2e/global.setup.ts` writes the synthetic session used for protected surfaces. Data-dependent flows (patterns list, detail, vote) need the backend's seeded SQLite (6 patterns / 18 tags). Then re-run `/bug-sweep`.

Do not proceed past a failed preflight. The frontend port is **4000** by deliberate operator choice; the committed `playwright.config.ts` webServer default is `3000` (CI-coupled — left unchanged), so the e2e baseline is pointed at 4000 via `PLAYWRIGHT_BASE_URL` (Step 3).

### 3. Dispatch the auditor
`findings_budget = 10`. Dispatch `bug-sweep-auditor` via the `Agent` tool over the surface inventory in batches of **≤6 surfaces**. Pass each batch `{surfaces[], suppressions[], findings_budget, base_url: "http://localhost:4000", auth_storage_state: "e2e/.auth/admin.json", e2e_baseline}`. Set `e2e_baseline: true` **only on the first batch** (the suite runs once, via `PLAYWRIGHT_BASE_URL=http://localhost:4000 npm run test:e2e -- --project=chromium`); `false` on every later batch.

**Dispatch SEQUENTIALLY — one batch, read its return, then decide the next.** After each batch returns, subtract its `findings.length` from `findings_budget`. Stop dispatching when `findings_budget` reaches 0 OR the queue is exhausted. On a subagent `result: halt`, surface it verbatim and stop. Do **not** fire all batches in one parallel block — the budget drawdown and the stop-on-halt rule are between-batch control flow that only work with each result in hand before the next dispatch. Do **not** write any `BSW-NNNN` row until Step 4, and only from a *returned* `findings[]` entry.

### 4. Write the ledger
- Append each returned finding to the `Open` section as a new `BSW-NNNN` row (status `candidate`), filling `{Run, Surface, Auth, Severity, Observed → Expected, Oracle cite, Signature}`. Keep the auditor's `signature` with the row so triage can write it to `Rejected` on reject.
- Append a `Run log` row `{Run = RUN-YYYYMMDD, Date, Surfaces audited, Reported = total findings, Accepted/Rejected/FP-rate left blank — filled at triage}`.

### 5. Report
Print: surfaces audited, findings reported (by severity), clean surfaces, budget remaining. End with: *"Run `/bug-sweep triage` to accept/reject."* **If zero findings across all batches, say so plainly — that is the convergence target, not a failure.** Do not stage or commit.

---

## Triage mode

### 1. Walk Open candidates
`Read` the `Open` candidates. For each, present `{surface, severity, observed → expected, oracle_cite, repro}` and ask the human to **accept** or **reject (reason)**. Reason ∈ `by-design` / `false-positive` / `wont-fix` / `duplicate` / `deferred`.

### 2. Accept
Set the row `accepted` with a one-line remediation note + owner. It stays in `Open` until the fix lands, then moves to `Fixed` (with date). (No fix-prompt authoring — accepted findings are remediated through the normal dev workflow.)

### 3. Reject (reason) → suppression + durable action
Move the row from `Open` to `Rejected`, recording `{ID, Surface, Signature, Finding (1-line), reject_reason, Rejected on, Durable action}`. The `Rejected` section **is** the suppression memory loaded at Run-mode Step 1. Durable action by reason:
- `by-design` → note which doc/oracle to amend so the auditor does not re-derive the same "violation" next run.
- `false-positive` → note the evidence-bar gap (what let it slip through) for the next auditor-contract tune.
- `wont-fix` / `duplicate` → suppression only (for `duplicate`, link the canonical row).
- `deferred` → note that the surface/check is out of scope for now.

### 4. Close the run-log row
Fill the most-recent open `Run log` row's `Accepted`, `Rejected (FP)` (= count rejected as `false-positive`), and `FP-rate` (= rejected-as-false-positive ÷ reported). FP-rate trending to ~0 across runs **is** convergence; a rising FP-rate means the evidence bar or an oracle is wrong — not the codebase. Do not stage or commit.

---

## Safety rules (always enforced)

- **Never `git commit` / `git add`.** Report what changed; let the operator commit.
- **The auditor is the only browser-driver.** This skill never drives Playwright itself.
- **Reward-zero.** Few or zero findings is success. Never instruct the auditor to "find more"; never lower the evidence bar to fill the queue.
- **Stack-gated.** Run mode does nothing useful without the local stack up on port 4000 + 5255; the Step-2 preflight halt is load-bearing, not advisory.
- **No speculative rows.** Every ledger row traces to a returned auditor finding.
