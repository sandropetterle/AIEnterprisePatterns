# Technical Decisions Log

**Last Updated:** 2026-06-05 (Home-page startup cost: idle-mounted Toaster + transform-only hero animation — Decision 78)
**Audience:** Solutions Architects, Senior Developers
**Purpose:** Capture significant technical design decisions — what was decided, why, and what alternatives were evaluated. Preserves architectural knowledge across sessions and team members.

**78 active decisions | 0 archived**

For the decision format, see [DECISION_TEMPLATE.md](DECISION_TEMPLATE.md).
For archived/superseded decisions, see [DECISIONS_ARCHIVE.md](DECISIONS_ARCHIVE.md).
For compaction rules, see [../GOVERNANCE.md](../GOVERNANCE.md) Section 6.

---

This document captures significant technical design decisions made during the development and deployment of the AI Enterprise Patterns application.

---

## Decision 78: Home-page startup cost — idle-mounted Toaster + transform-only hero animation

**Date:** 2026-06-05
**Title:** Defer sonner to browser idle via `LazyToaster` and make the hero `slide-up` animation transform-only so the hero is LCP-eligible
**Category:** Performance / Frontend
**Status:** Active

### Context / Problem

Issue #71 (Lighthouse LCP gate) prompted a trace-level investigation of the home page on constrained CPUs (real 4× CDP throttle + Lantern simulation, `lighthouse --throttling-method=devtools --save-assets`):

- The LCP element was the **header logo span** (168×56px), not the hero. The hero's `animate-slide-up` keyframes animated `opacity: 0→1`, and Chrome excludes elements animated in from opacity 0 from LCP candidacy entirely. The header span also re-emitted LCP candidates during hydration (3.0s/3.9s/5.5s/10.3s in trace) — a plausible source of the CI gate's 2924-vs-4433ms run-to-run spread.
- Under Lantern (CI's method), the observed unthrottled LCP timestamp (1528ms) sat behind ~1.3s of startup script evaluation, so Lantern folded that CPU into its LCP estimate (FCP 962ms passed / LCP 4026ms failed — exactly the CI signature). Sonner (~50KB raw) loaded eagerly via the root layout's `<Toaster>` despite only being needed after user interaction.
- Exonerated by the trace: TTFB (58ms), font loading (next/font preload, done at 109ms), HTML parse (44ms), legacy JS (13.7KB). A single 683ms throttled layout pass (98 objects) remains unexplained — A/B bisection (system font, no animations, no smooth-scroll, blocked webfont) showed no single CSS culprit; parked.

### Decision

1. **`components/providers/LazyToaster.tsx`** — idle-mounted (`requestIdleCallback`, `setTimeout` fallback for Safari) dynamic `import('sonner')`; replaces the static `<Toaster>` in the root layout. Sonner moves to a lazy chunk loaded after idle (~3s on a throttled run, measured).
2. **`tailwind.config.ts`** — `slide-up` keyframes are transform-only (`translateY(20px)→0`, no opacity), so the hero paints at first paint and is a valid, stable LCP candidate. `fade-in` (FeaturedPatterns/StatsSection) untouched — below the fold, and the eligible hero dominates LCP on all form factors.

### Measured results (dev machine, medians of 3; CI runners are slower in absolute terms)

| Metric | Before | After |
|---|---|---|
| TBT (devtools 4×) | 2799ms | ~1038ms |
| TBT (Lantern) | 644ms | ~319ms |
| LCP (Lantern) | 4026ms | ~3519ms |
| Perf score (Lantern) | 0.71 | ~0.83 |
| LCP element | header logo span | hero paragraph |
| LCP (devtools 4×) | 2483ms | ~2735ms (unchanged within noise — floored by CSS fetch + layout, not JS) |

The CI LCP gate calibration (issue #71, `aggregationMethod: median` + realistic budget) remains a separate, still-open fix; this change attacks the page cost itself.

### Verification notes (important for future toast work)

A mid-implementation scare suggested toasts were broken by chunk-splitting (three sonner copies in chunks). Module-ID inspection proved Turbopack registers all copies under **one module ID** (single runtime instance), and a live end-to-end check (fetch override → failing vote → `MutationObserver` on the Notifications region) rendered the error toast correctly. The earlier "missing toast" observations were instrumentation errors: clicks lost to pre-hydration timing, and observation latency exceeding sonner's ~4s auto-dismiss. See the CLAUDE.md e2e gotcha added with this change.

### Alternatives Evaluated

- **Defer `SessionProvider` / next-auth** — rejected: `useSession` is statically imported by Header components (UserMenu, NewPatternButton), so next-auth stays in the startup graph regardless of provider mount timing; the session fetch is async I/O, not main-thread cost. A custom session-context shim would remove next-auth/react from the bundle but touches 4 components + global test mocks for ~10KB gz — poor risk/benefit.
- **`ToasterClient` static-import indirection** (briefly implemented) — reverted: justified only by a module-duplication theory that module-ID inspection disproved.
- **browserslist modern targets (legacy JS)** — rejected: 13.7KB potential savings, noise.
- **Layout-cost micro-optimization** — parked: 683ms throttled initial layout has no attributable single cause (font/animations/smooth-scroll all exonerated by bisection).

---

## Decision 77: No secrets on GitHub — secret-scanning PreToolUse hook gates all gh writes

**Date:** 2026-06-05
**Title:** Enforce "no keys/passwords/tokens on GitHub issues or PRs" with a blocking secret-scan hook on every GitHub-writing `gh` command, plus instructional scrub rules in the bug-sweep skill and auditor
**Category:** Security / Tooling
**Status:** Active

### Context / Problem

With bug-sweep findings now filed as GitHub issues (Decision 76), agent-authored content flows to GitHub routinely. Findings quote network requests, console output, and env-var-driven behavior — exactly the material that can accidentally embed a JWT, an `Authorization` header, or a connection string. The operator's policy: credential material must **never** appear on GitHub. An audit of all existing issues, issue/PR comments, and PR bodies (2026-06-05) found zero leaks; the goal is keeping it that way structurally, not by vigilance. The same audit *did* find live-looking secrets committed in `.claude/settings.json` / `.claude/settings.local.json` permission entries (Strapi API tokens, an expired admin JWT, the deleted Azure MySQL password) — removed in the same change.

### Decision

Three layers, with the hook as the enforcement backstop:

1. **Blocking hook (enforcement).** `.claude/hooks/gh-secret-scan.ps1` + a `PreToolUse` entry in `.claude/settings.json` (matcher `Bash|PowerShell`, `if: Bash(gh *)` / `PowerShell(gh *)`). It gates GitHub-writing `gh` invocations (`issue|pr create/comment/edit/close/...`, `gh api` with POST/PATCH/PUT/fields, `release|gist create`), scanning the command text **and** the contents of any referenced body file (`--body-file`, `--input`, `field=@file`). On a match it exits 2, blocking the call with actionable stderr. Patterns: JWTs, 48+-char hex (commit SHAs at 40 and `sha256:`-prefixed digests are allowed), `Bearer` tokens, GitHub `gh*_` tokens, private-key blocks, Azure `AccountKey=`/SAS `sig=`, credential assignments (`password=…`, `secret=…`, etc. — placeholder values like `<token>`/`$VAR` are allowed), and known env names with values. Fail-open on script error (a broken hook must not wedge every gh call); read-only `gh` commands are untouched.
2. **Skill rule (primary control).** Bug-sweep Step 4 gains a mandatory pre-post secret scrub (redact to `[REDACTED]`, env vars by name only) and a "No secrets on GitHub — ever" safety rule; `gh` must be invoked directly, never inside compound commands, so the hook's prefix filter always sees it.
3. **Auditor rule (source control).** Strict rule 8: findings must contain no credential material — auth headers/cookie values stripped when quoting network captures.

Verified: 9 pipe-tests (JWT, password, 62-hex body-file blocked; clean writes, commit SHAs, docker digests, all three real backfilled issue bodies pass) + live end-to-end (fake-JWT comment blocked by the hook; clean comment reached gh).

### Rationale

- Instructions alone are vigilance; the hook is structural — the `gh` call never executes with a secret in it.
- Scanning at the `gh` boundary (not at finding-time) also covers every future ad-hoc `gh issue/pr` write in any session, not just bug-sweep.
- `if`-filtered hooks cost nothing on non-`gh` commands (no process spawn).

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Instructional rules only | The failure mode is accidental inclusion; a rule cannot catch what the author didn't notice. |
| Hook on every Bash call (no `if` filter) | ~hundreds of ms of powershell spawn on every command in every session for no added coverage on the paths that matter. |
| GitHub push protection / secret scanning | Operates on repo pushes and known provider patterns, not issue/comment bodies via gh CLI; complementary, not sufficient. |
| Server-side GitHub Action auditing new issues | Detects after the secret is already published (and notified/cached); prevention must be client-side. |

### Consequences

- Compound commands (`cd x && gh …`) bypass the `if` prefix filter — mitigated by the skill rule to invoke `gh` directly; acceptable for an accidental-leak guard.
- Possible rare false positives (e.g. a bare 64-char hex that is genuinely content) — the block message says how to rephrase; patterns live in one script.
- Hook config changes load at session start / via `/hooks`; editing the script takes effect immediately.
- `.claude/settings.local.json` untracked + gitignored (was committed, contained a password). **Residual:** removed secrets remain in git history; the Strapi tokens should be rotated at the next CMS session (Azure MySQL password is moot — server deleted).

### Files Changed

- `.claude/hooks/gh-secret-scan.ps1` — new scanner (PS 5.1).
- `.claude/settings.json` — `hooks.PreToolUse` entry; removed 12 stale permission entries containing literal secrets.
- `.claude/settings.local.json` — removed the mysqldump-with-password entry; untracked via `git rm --cached`.
- `.gitignore` — ignore `.claude/settings.local.json`.
- `.claude/skills/bug-sweep/SKILL.md` — Step-4 secret scrub + safety rule.
- `.claude/agents/bug-sweep-auditor.md` — strict rule 8 (no credential material in findings).

### Tests Added

- None automated (hook tooling). Verification: the 9 stdin pipe-tests + the live blocked/clean `gh issue comment` pair described above; re-run the pipe-tests after any pattern change.

---

## Decision 76: Bug-sweep findings tracked as GitHub Issues (MD file reduced to run log)

**Date:** 2026-06-05
**Title:** Move `/bug-sweep` findings state (candidates, accepted, fixed, rejected/suppression memory) from `BUG_SWEEP_FINDINGS.md` to GitHub Issues; the MD file keeps only the run log
**Category:** Testing / Tooling
**Status:** Active (supersedes the "living ledger" portion of Decision 72)

### Context / Problem

Decision 72 put all bug-sweep findings state in a single MD ledger. Meanwhile real bugs in this repo are tracked as GitHub issues (#66–#71), so defects lived in two places with different lifecycles: a ledger row could not be closed by a fix PR, was invisible in the GitHub UI, and duplicated state GitHub already models natively (open/closed, close reasons, labels, comments). The operator wants one place for bugs.

### Decision

GitHub Issues (label `bug-sweep`) become the findings system of record; the issue lifecycle is the triage state machine:

- **Filing (run mode).** Each returned auditor finding → one issue: labels `bug` + `bug-sweep` + `severity:<block|major|minor>` + `triage:candidate`; body carries human-readable sections plus a machine-readable `<!-- bug-sweep:meta -->` block with `{surface, signature, run}` — the cross-run identity key. Bodies pass via `--body-file` (PS 5.1 quoting). Run mode's only GitHub write is `issue create`.
- **Triage accept** → swap `triage:candidate` for `triage:accepted` + remediation comment; the fix PR closes it as *completed* (`Fixes #NN`).
- **Triage reject** → closing comment (`Rejected: <reason>. Durable action: ...`; reason ∈ by-design/false-positive/wont-fix/duplicate/deferred) + close as *not planned*. **The closed-as-not-planned set is the suppression memory** the skill loads each run (`gh issue list --label bug-sweep --state closed --json number,body,stateReason`, filter `NOT_PLANNED`, parse the meta block).
- **Fixed ≠ suppressed.** Issues closed as *completed* are not suppressed; a recurring `{surface, signature}` is re-filed flagged "possible regression of #NN".
- **Preflight.** `gh auth status` joins the run-mode hard gate (filing needs an authenticated CLI).
- **MD file.** `BUG_SWEEP_FINDINGS.md` keeps only the `Run log` convergence table (now with an `Issues` column) + canned `gh` queries. Historical findings BSW-0001..0003 backfilled as closed-completed issues #73/#74/#75.
- Six labels created: `bug-sweep`, `severity:block|major|minor`, `triage:candidate`, `triage:accepted`. Reject reasons live in closing comments, not labels (operator's choice — less label sprawl).

The structural anti-padding guarantee is unchanged: the auditor is read-only (and barred from `gh`); only the skill files issues, and only from returned `findings[]` entries.

### Rationale

- One queryable place for all defects; bug-sweep findings sit beside organically-filed bugs and close automatically via `Fixes #NN`.
- GitHub natively models the triage lifecycle (labels, close reasons, comments) the MD ledger re-implemented by hand; `stateReason` cleanly separates fixed (completed) from suppressed (not planned).
- The FP-rate convergence metric is per-run aggregate context, not per-finding state — it stays in the MD run log, which is what MD is still good at.

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Keep the MD ledger (status quo) | Two sources of truth for bugs; no PR auto-close; invisible in the GitHub UI. |
| GitHub Projects board | Adds a board on top of issues without removing the need for issues; gh CLI support for Projects is clunkier; overkill for one repo. |
| Per-reason reject labels (`bsw:by-design`, …) | 5 extra labels for information a closing comment carries fine; operator chose comment-only. |
| Run log as a pinned GitHub issue | Append-only comments model a table poorly; the MD table diffs cleanly in git and is already the convergence artifact. |

### Consequences

- Run mode now requires network + authenticated `gh` (preflight-gated); the sweep no longer works fully offline.
- Suppression matching depends on the `<!-- bug-sweep:meta -->` block surviving in issue bodies — triage never strips it; humans editing issue bodies must leave it intact.
- The 200-issue `--limit` on the suppression query is a soft ceiling; revisit if rejected findings ever approach it.
- BSW-NNNN IDs are retired; issue numbers are the canonical finding IDs.

### Files Changed

- `.claude/skills/bug-sweep/SKILL.md` — suppression load from gh, gh preflight, Step 4 files issues, triage via gh, safety rules scoped to GitHub writes.
- `.claude/agents/bug-sweep-auditor.md` — contract-version note; "ledger" wording → issues; explicit no-`gh` rule. Output contract unchanged.
- `documentation/testing/BUG_SWEEP_FINDINGS.md` — reduced to run log + queries + backfill mapping.
- `documentation/testing/BUG_SWEEP_DESIGN.md` — §1.1/§5/§6/§10 reworked to the issue lifecycle.

### Tests Added

- None (tooling/documentation change). Verified: 6 labels exist; issues #73–#75 backfilled closed-completed with meta blocks; the suppression query returns empty without erroring (no not-planned issues yet).

---

## Decision 75: Per-IP partitioned rate limiting with no request queueing

**Date:** 2026-06-04
**Title:** Partition all API rate limit policies per client IP, raise the `api` budget to 300/min, and reject (429) instead of queueing
**Category:** Infrastructure / Performance
**Status:** Active

### Context / Problem

Issue #68: the Advanced Search e2e family (date-range, tag-mode, saved-search) failed deterministically in parallel local runs and was chronically flaky in CI. Root-cause tracing (Playwright traces) showed RSC navigation requests to the Next server that **never completed** — the SSR render behind them was stuck waiting on the backend API. The `"api"` limiter (`AddSlidingWindowLimiter`) was a **single global bucket** — 50 permits/min shared by *every* client, despite code comments claiming "per IP" — with `QueueLimit = 5, OldestFirst`. Measured behavior: requests 1–50 in a minute returned in ~4ms; request 51 **silently sat in the limiter queue for 55.3s** before returning 200. Every `/patterns` listing render issues 2 API calls, so one parallel e2e run — or roughly **3 concurrent production users** — exhausted the budget, after which every SSR render hung for up to a minute. The `"fixed"` and `"vote"` limiters had the same global-bucket defect.

### Decision

In `AddInfrastructure()` (`InfrastructureServiceCollectionExtensions.cs`):

1. **Partition per client IP** — all three policies now use `options.AddPolicy(name, partitioner)` with `RateLimitPartition.Get*WindowLimiter(ClientKey(ctx), ...)` keyed on `Connection.RemoteIpAddress` (fallback `"unknown"` for in-memory TestServer). Policy names are unchanged, so `RequireRateLimiting("api")` / `[EnableRateLimiting("vote")]` call sites are untouched.
2. **`api`: 50 → 300 permits/min per IP** (sliding window, 4 segments) — ~5 rps sustained per client covers SSR-driven browsing (2 calls per listing render) and e2e runs while remaining a meaningful abuse ceiling.
3. **`QueueLimit = 0` everywhere** — over-budget requests now fail fast with 429 instead of silently stalling the caller for up to a window roll. `fixed` stays 100/min per IP; `vote` stays 10/min per IP (now actually per IP, as always documented).

Regression guard: `RateLimitingTests.GetPatterns_BurstAboveOldGlobalBudget_IsNeitherQueuedNorRejected` — 60 rapid GETs must all be 200 in <10s (red on the old config at 1m 0.4s; green at ~3s).

### Rationale

- The intent was always per-client limiting (comments and CLAUDE.md said "per IP"); `AddFixedWindowLimiter`/`AddSlidingWindowLimiter` simply don't partition — that requires `AddPolicy` + `RateLimitPartition`.
- Queueing GETs for tens of seconds is strictly worse than rejecting: the caller (Next SSR `fetch`) has no timeout and wedges the whole page render, which surfaced as "URL never updates / `goto` hangs / browser context won't close" in Playwright — maximally misleading symptoms. A prompt 429 is visible, diagnosable, and the frontend already falls back gracefully.
- 429s remain observable in App Insights; the `RejectionStatusCode` wiring is unchanged.

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Keep global buckets, raise limits | Still couples unrelated clients; any one noisy client starves everyone. The "per IP" intent stays unimplemented. |
| Keep queueing (small queue) with per-IP partitions | Queued requests still stall SSR renders for up to a window segment (15–60s) with zero signal; fail-fast 429 is debuggable. |
| Config-driven limits (appsettings per environment) | Solves the e2e symptom but ships the global-bucket production bug; per-IP partitioning fixes both with the same effort. |
| Disable rate limiting in dev/test | Hides the production defect (~3 concurrent users exhaust 50/min global) and lets CI diverge from prod behavior. |

### Consequences

- e2e: the issue #68 family passes 4-way parallel against both dev and prod builds; CI's chronic per-browser flake annotations in this family should disappear.
- Production: concurrent users no longer share one 50/min budget; a single abusive IP is still capped (300/min api, 100/min fixed, 10/min vote).
- Behavior change: bursts above per-IP budget now receive 429 immediately (previously: hidden queueing, then 429). Clients relying on the silent queue (none known) would see faster failures.
- CLAUDE.md rate-limit numbers updated to match.

---

## Decision 74: ESLint flat config (FlatCompat-free) + scoped ajv overrides for the eslint subtree

**Date:** 2026-06-04
**Title:** Migrate lint to ESLint flat config using eslint-config-next's native flat presets, run `eslint` directly, and scope the repo-wide ajv@8 override so eslint/@eslint/eslintrc keep ajv@6
**Category:** Tooling
**Status:** Active

### Context / Problem

Issue #69: both lint entry points were broken on `main`. Next.js 16 removed the `next lint` command, so `npm run lint` failed parsing `lint` as a project directory. And `npx eslint` crashed before linting anything: the repo-wide `overrides: { "ajv": "^8.8.2" }` (added for Storybook's ajv-keywords@5 peer requirement, commit 993e4d2) forces ajv@8 into `eslint` and `@eslint/eslintrc`, both of which require ajv@6 APIs (`missingRefs` option, `ajv/lib/refs/json-schema-draft-04.json`) — `eslint/lib/linter/linter.js` requires `@eslint/eslintrc/universal` unconditionally even in flat-config mode, so ESLint could not even start. Lint regressions landed silently (the Test Suite workflow ran no lint), and `cms-sync-fallbacks.yml`'s `npm run lint` verify step was a time bomb.

### Decision

1. **`eslint.config.mjs` (flat config)** composing `eslint-config-next/core-web-vitals` + `eslint-config-next/typescript` (both flat-native in v16) + the existing `eslint-plugin-security` rule set carried over from `.eslintrc.json` (deleted). The config is deliberately **FlatCompat-free** — `FlatCompat` lives in `@eslint/eslintrc`, which is broken by the ajv override.
2. **`lint` script → `eslint app components lib`** — the same surface `next lint` covered by default (`pages`/`src` don't exist here).
3. **Scoped npm overrides**: keep the blanket `ajv@^8.8.2` (Storybook still needs it) but add nested exceptions `"eslint": { "ajv": "^6.12.6" }` and `"@eslint/eslintrc": { "ajv": "^6.12.6" }` so the eslint subtree resolves a patched ajv@6 (≥6.12.3, prototype-pollution-safe).
4. **Lint step added to the Test Suite workflow** (frontend-tests job) so the toolchain can't silently rot again.
5. Fixed the 15 lint errors that accumulated while lint was broken (unescaped entities, anonymous `next/link` mocks missing display names, a `require()` import → `jest.requireActual`, an `<a>`→`<Link>` in a story). The two `react-hooks/set-state-in-effect` hits in `ThemeProvider` are targeted disables with justification — setState there is the standard SSR-safe hydration pattern (localStorage/matchMedia are client-only; initialising state from them would cause hydration mismatches).

### Rationale

- eslint-config-next@16 ships flat-config arrays natively; composing them directly avoids the broken eslintrc bridge entirely instead of working around it.
- Scoping the ajv exception to the eslint subtree preserves the original security intent of the blanket override (everything else stays on ajv@8) while restoring the ajv@6 that eslint's own dependency tree declares.
- Matching the old `next lint` directory surface keeps the migration behavior-preserving; widening lint coverage (e2e/, scripts/, hooks/) can be a deliberate follow-up.

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| `FlatCompat` bridge (the Next 15-era migration path) | Crashes at load — `@eslint/eslintrc` is ajv@6-only and the repo forces ajv@8; also keeps a legacy layer Next 16 no longer needs. |
| Drop the blanket ajv@8 override entirely | It was added for Storybook's ajv-keywords@5 peer requirement; removing it re-opens that install conflict. Scoped exceptions are strictly narrower. |
| Refactor `ThemeProvider` to satisfy `react-hooks/set-state-in-effect` | Reading localStorage/matchMedia in initializers breaks SSR hydration; a `useSyncExternalStore` rewrite is out of scope for a lint-tooling fix and risks behavior changes in theming. |
| `eslint .` with a long ignore list | Would newly lint e2e/, scripts/, cms/, backups/ etc. — large new error surface unrelated to restoring the broken tooling. |

### Consequences

- `npm run lint` works again (0 errors, 8 pre-existing warnings) and gates both `cms-sync-fallbacks.yml` and the Test Suite workflow.
- `npm ls ajv` now shows ajv@6 under `eslint`/`@eslint/eslintrc` and ajv@8 everywhere else; `npm audit --omit=dev --audit-level=high` unaffected (eslint is dev-only, and ajv ≥6.12.3 is patched).
- react-hooks v7 rules (via eslint-config-next 16) are now enforced — stricter than the pre-breakage config.

---

## Decision 73: CSP `connect-src` derives the API origin from `NEXT_PUBLIC_API_BASE_URL`

**Date:** 2026-06-04
**Title:** Derive the API origin into the CSP `connect-src` allow-list from `NEXT_PUBLIC_API_BASE_URL` — unconditionally, not NODE_ENV-gated
**Category:** Security
**Status:** Active

### Context / Problem

Bug-sweep finding **BSW-0002** (major): the CSP in `next.config.mjs` allow-listed only the production API origins (`*.azurecontainerapps.io`, `*.azurewebsites.net`) plus the Entra endpoints in `connect-src`. But client components call whatever `NEXT_PUBLIC_API_BASE_URL` points at — `http://localhost:5255/api` in local dev, prod-build E2E, and Lighthouse CI. The vote button's `POST /api/patterns/{id}/vote` was blocked by the browser with `console.error` CSP violations; the count never updated and no revert toast fired (the request never left the page). The ledger's accepted remediation said "add the local API origin to `connect-src` in non-prod".

### Decision

`headers()` in `next.config.mjs` now builds `connect-src` from the static prod allow-list **plus** `new URL(process.env.NEXT_PUBLIC_API_BASE_URL).origin` whenever the variable is set — deduped, with unparseable values ignored (try/catch falls back to the static list). The derivation is **unconditional**, not gated on `NODE_ENV !== 'production'`.

### Rationale

- **NODE_ENV cannot express "non-prod" here:** `next build` always forces `NODE_ENV=production`, so a NODE_ENV gate would have left prod-build local runs, the CI E2E job (`npm run build` + `npm run start` against `http://localhost:5255/api`), and Lighthouse CI still CSP-blocked — only `next dev` would have been fixed.
- **Unconditional derivation does not loosen prod CSP:** in production the derived origin is the Azure API host, already covered by the `*.azurecontainerapps.io` wildcard; the only origin ever added is the one the app is configured to call.
- Hardened by `__tests__/config/csp.test.ts` (derived origin present with path stripped, static allow-list intact, dedup, unset/unparseable fallback).

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Hardcode `http://localhost:5255` into `connect-src` | Drifts if the local API port/origin changes; ships a localhost origin in the prod header for no reason. |
| Gate the derivation on `NODE_ENV !== 'production'` | `next build` forces `NODE_ENV=production`, so prod-build E2E/LHCI runs against a local backend would remain broken — the exact class of run that caught nothing here. |
| Skip adding when a wildcard already covers the origin | Requires CSP wildcard-matching logic for zero practical benefit; exact-string dedup is sufficient. |

### Consequences

- The prod CSP header now also names the API origin explicitly (harmless — within the existing wildcard).
- A misconfigured `NEXT_PUBLIC_API_BASE_URL` surfaces as a CSP block again by design — the header only ever allows the *configured* origin.
- Verified live: vote POST → 200 OK, optimistic count update 42→43, zero console errors.

---

## Decision 72: On-demand browser bug-sweep (hybrid e2e + Playwright-MCP, Opus auditor, living ledger + triage)

**Date:** 2026-06-03
**Title:** Adopt an on-demand, convergent browser bug-sweep that pairs the CI-proven e2e suite with live Playwright-MCP exploration, driven by a read-only Opus auditor, with a living findings ledger and a human triage loop
**Category:** Testing
**Status:** Active (findings-ledger portion superseded by Decision 76)

### Context / Problem

The project's automated tests (Jest, xUnit, the Playwright e2e suite) are all **assertion-bound** — they only fail on behavior someone already encoded. Nothing in the toolchain *exercises the whole platform in a browser to surface the unexpected* — regressions and defects in flows that have no dedicated assertion. We wanted an on-demand way to "sweep the whole app for bugs" before a release, without standing up roadmap/session machinery the project doesn't have. A capable version existed in a sibling project (Allegrow) but was heavily coupled to that project's roadmap, session-discipline files, per-surface git-SHA prioritization, and a custom browser tool — none of which applies here.

### Decision

Add a `/bug-sweep` skill + a `bug-sweep-auditor` subagent + a living ledger, adapting only the valuable, project-agnostic core:

- **Hybrid browser driver.** Run `npm run test:e2e` (Chromium) once per run as a deterministic regression baseline, then explore beyond it **live via Playwright MCP** (model-in-the-loop, adaptive). The baseline catches encoded regressions; live exploration finds the unencoded.
- **Read-only Opus auditor as the only browser-driver.** The auditor (`model: opus`, tools `Read/Bash/Grep/Glob` + `mcp__playwright__browser_*`, **no** `Edit`/`Write`) drives the browser and returns schema-valid candidate findings. Opus because the delegation risk is *judgment* — not padding the budget, and not mistaking a correct redirect for a defect.
- **Evidence bar + reward-zero.** A finding requires a concrete `observed ≠ expected` delta **and** an oracle cite, or it is dropped as a hunch. Zero findings on a clean run is an explicit success; the 10-finding budget is a ceiling, never a quota. FP-rate (rejected-as-false-positive ÷ reported) is the convergence metric.
- **Living ledger + triage.** A single `BUG_SWEEP_FINDINGS.md` holds `Run log` + `Open`/`Fixed`/`Rejected`; the `Rejected` section is the suppression memory the auditor loads each run. A `triage` mode accepts/rejects candidates. Only the skill writes the ledger; rows trace 1:1 to returned auditor findings (no speculative rows). *(Superseded in part by Decision 76, 2026-06-05: findings state moved to GitHub Issues; the MD file retains only the run log.)*
- **Auth scope.** Public + protected surfaces. The live MCP context is unauthenticated (the Auth.js cookie is `httpOnly`), so it verifies the unauth→`/login` redirect invariant directly; the authenticated render is covered by the e2e baseline (`authenticated-flows.spec.ts` loads `e2e/.auth/admin.json`).
- **Port.** Frontend on **3000** — matching the CI-coupled `playwright.config.ts` webServer default, so the e2e baseline reuses the running dev server (`reuseExistingServer: true`) with no `PLAYWRIGHT_BASE_URL` override. Backend on 5255. *(Revised 2026-06-03: originally 4000 per operator preference; the first run showed the 4000/3000 split made Playwright's `reuseExistingServer` probe the wrong port and collide with the running dev server, so the port was aligned to 3000.)*

### Rationale

The two halves cover complementary defect classes: the e2e baseline is reproducible and CI-proven but can only fail on existing assertions; MCP adds adaptive, model-in-the-loop discovery of the unexpected. Making the auditor read-only and the skill the sole writer makes speculative findings structurally impossible. The evidence bar + reward-zero keep the false-positive rate — the load-bearing health metric — low.

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Full port of the Allegrow bug-sweep | Coupled to that project's roadmap/session machinery (parallelism-map cross-checks, per-surface `Last SHA`, `next_prompts.md` fix-prompt authoring, custom `observe.ts`) — none applies here. |
| e2e-runner only (no MCP) | Assertion-bound: can only fail on behavior already encoded; loses the exploratory discovery that is the whole point. |
| Playwright-MCP only (no e2e baseline) | Loses the CI-proven, deterministic regression baseline; exploration alone has no reproducible floor. |
| CLI + model-authored throwaway probe scripts | Recovers some observation richness but loses the live adaptive loop and adds plumbing/latency for less than MCP gives. |

### Consequences

- On-demand only (not wired into CI) — a deliberate non-goal this iteration.
- Requires the local stack up (frontend 3000 + backend 5255) and `AUTH_SECRET` set for protected-surface coverage; a Step-2 preflight halts otherwise.
- Accessibility and brand/visual oracle layers are staged, not built — a future opt-in.
- A found-and-fixed bug becomes a permanent regression guard only when someone encodes it as a new e2e spec (the "harden" follow-up).
- The frontend dev port (3000) matches the `playwright.config.ts` webServer default, so the e2e baseline reuses the running dev server (`reuseExistingServer: true`) — no redundant server, no `PLAYWRIGHT_BASE_URL` override.

### Files Changed

- `.claude/skills/bug-sweep/SKILL.md` — new orchestrator skill (run / triage modes, canonical surface inventory, preflight gate, ledger writes).
- `.claude/agents/bug-sweep-auditor.md` — new read-only Opus auditor subagent (e2e baseline + live MCP exploration, output contract).
- `documentation/testing/BUG_SWEEP_FINDINGS.md` — new living ledger (Run log + Open/Fixed/Rejected + suppression memory).
- `documentation/testing/BUG_SWEEP_DESIGN.md` — new methodology + rationale + scope boundary.
- `.claude/settings.json` — allow the e2e baseline + preflight commands so a run doesn't prompt mid-flight.

### Tests Added

- None (tooling/documentation change). Verification is the skill's own discipline: skill discovery resolves `/bug-sweep`; the preflight halts with servers down; a smoke run produces schema-valid auditor JSON and a ledger row; reward-zero holds on a clean surface; the triage round-trip moves a finding to `Rejected` + suppresses it on the next run. Live-stack verification steps require the operator to bring up the frontend (3000) + backend (5255) with `AUTH_SECRET` set.

---

## Decision 71: Install ICU on the Alpine backend image (fix Azure SQL globalization-invariant failure)

**Date:** 2026-06-02
**Title:** Backend Alpine runtime must ship ICU and disable globalization-invariant mode for Microsoft.Data.SqlClient
**Category:** Infrastructure
**Status:** Active

### Context / Problem

The **Backend API – Build and Deploy (Container Apps)** workflow failed its post-deploy health check on **every run from 2026-03-19 onward**; the last green deploy was 2026-03-17 (commit `9b425e5`). Build, push, and deploy all succeeded, but `/health` returned `503 Unhealthy`, so the workflow auto-rolled-back to the previous `:latest` image. **Net effect: production served stale 2026-03-17 backend code** — none of the backend changes since were live.

The only registered health check is `AddDbContextCheck<ApplicationDbContext>`, so the 503 meant new revisions could not reach the database — while the rolled-back (old) revision connected fine. Because the deploy step only runs `az containerapp update --image …` (never touching env/secrets), the connection string, firewall, and serverless DB were proven identical and working by the healthy old revision; the regression had to be in the new **image**.

Container console logs (Log Analytics `ContainerAppConsoleLogs_CL`) showed the real exception, swallowed by the health check as `message '(null)'` but surfaced on API requests:

```
System.Globalization.CultureNotFoundException: Only the invariant culture is supported in
globalization-invariant mode. … 'en-us' is an invalid culture identifier.
   at System.Globalization.CultureInfo.GetCultureInfo(String name)
   at Microsoft.Data.SqlClient.SqlConnection.TryOpen(…)
```

Root cause: Phase 7.7 (commit `215232a`) switched the runtime base image from Debian `aspnet:8.0` to **`aspnet:8.0-alpine`**. The Alpine .NET images run in **globalization-invariant mode** (`DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true`, ICU absent — verified directly against the pinned digest). `Microsoft.Data.SqlClient` calls `CultureInfo.GetCultureInfo("en-us")` inside `SqlConnection.Open()`, which throws in invariant mode — so **every** Azure SQL connection failed instantly (the ~1 ms health-check failures), independent of network/TLS/config. The Debian image bundled ICU and never hit this. `Microsoft.Data.SqlClient` does not support invariant globalization mode.

### Decision

In the Dockerfile runtime stage, install ICU and disable invariant mode:

```dockerfile
RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
```

This restores the globalization behaviour of the previous Debian image while keeping the Alpine base (small image, no `curl`/`apt-get` layer). `icu-libs` alone resolves `en-US` (LCID 1033) — `icu-data-full` is not required.

Verified locally before deploy (no prod churn):
- A minimal probe calling `CultureInfo.GetCultureInfo("en-us")` in the pinned Alpine image reproduced the exact `CultureNotFoundException`; with `icu-libs` + `INVARIANT=false` it returned `'en-US' (LCID 1033)`.
- The rebuilt backend image, run against an unreachable SQL endpoint, no longer throws `CultureNotFoundException` — it now fails with an ordinary `SqlException` (TCP Provider, error 35), i.e. the connection code path proceeds to real network I/O. Against the reachable production Azure SQL it connects → `Healthy`.

PR #66 (health-check retry loop, 12 × 15 s) was **kept**: it never fixed this bug (a 1 ms culture failure never recovers), but it is a sound safety net for the serverless Azure SQL auto-pause (15 min) resume window and Container App cold-start on healthy deploys.

### Rationale

Adding ICU is the minimal, targeted fix that preserves the deliberate Alpine migration (Decision/Phase 7.7) and its supply-chain/size benefits, versus reverting the whole base image to Debian. It matches Microsoft's documented guidance for running `Microsoft.Data.SqlClient` on Alpine.

### Alternatives Evaluated

| Alternative | Why Rejected |
|------------|-------------|
| Revert runtime to Debian `aspnet:8.0` | Throws away the intentional Alpine migration (smaller image, no curl/apt layer, SHA-pinned supply chain). Larger change than necessary. |
| Set `InvariantGlobalization=false` in csproj only | The base image still lacks ICU; without `icu-libs` the runtime cannot load any culture and still fails. |
| Add `icu-libs` + `icu-data-full` | `icu-data-full` (~30 MB) is unnecessary — `icu-libs` alone resolves `en-US`, proven by the probe. Keeps the image smaller. |

### Consequences

- Runtime image grows by ~25–30 MB (ICU libraries/data). Still far smaller than the Debian image; acceptable.
- Globalization is now culture-aware (not invariant). Behaviour matches the pre-Alpine Debian image, so no string-comparison/formatting regressions are expected.
- First deploy after this fix re-tags `:latest` to the new SHA (via the `tag-latest` job), so future rollbacks restore the fixed image, not the 2026-03-17 one.

### Files Changed

- `backend/Dockerfile` — runtime stage: `RUN apk add --no-cache icu-libs` and `ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false`, with an explanatory comment.

### Tests Added

- No unit tests (Docker/runtime-only change; backend unit tests use SQLite/InMemory and do not exercise the Alpine SqlClient path).
- Verification was via container-level reproduction: a globalization probe and the rebuilt backend image (see Decision body). The authoritative regression gate is the deploy's own Health Check job going green without rollback.

---

## Decision 70: Group react and react-dom in Dependabot

**Date:** 2026-06-02
**Title:** Bump react and react-dom together to prevent version-mismatch CI failures
**Category:** Frontend / Dependency Management

### What Was Decided

Added a `react` group to the npm (root) config in [.github/dependabot.yml](../../.github/dependabot.yml) that bundles `react` and `react-dom` into a single PR:

```yaml
react:
  patterns:
    - "react"
    - "react-dom"
```

### Why

React requires `react` and `react-dom` to be on the **exact same version**. Dependabot PR #56 bumped `react` 19.2.5 → 19.2.6 but left `react-dom` at 19.2.5; `react-dom`'s client entry throws `Incompatible React versions` at import time, so **all 41 Jest suites failed to run** before a single assertion executed — the whole Frontend Tests job went red, not individual tests. The fix on #56 was to bump `react-dom` to match (both resolved to 19.2.7). Grouping the two ensures the split cannot recur: Dependabot always raises the pair in one PR with a consistent lockfile.

### Alternatives Evaluated

- **Leave ungrouped, patch manually each time**: The mismatch passes Dependabot's own checks and only fails in our Jest run; relying on a human to notice and fix every react bump is error-prone. Rejected.
- **Pin both to exact versions (drop the caret)**: Stops `npm install` from floating to a newer patch, but does not stop Dependabot raising the two as separate PRs — the mismatch window still exists between the two merges. Rejected.
- **Fold `react-dom` into the existing `types` group**: `@types/*` packages version independently of the react runtime; mixing them produces noisy, unrelated grouped PRs. Kept the group tight to the two runtime packages. Rejected.

### Trade-offs

Grouped PRs bump both packages at once, so a regression in either lands together — acceptable, since they must move in lockstep regardless. Patch/minor react releases are low-risk and remain gated by the full Jest + cross-browser E2E suite.

---

## Decision 69: Defer lucide-react v1 — brand icons removed

**Date:** 2026-05-19
**Title:** Pin lucide-react to 0.x; ignore semver-major bumps in Dependabot
**Category:** Frontend / Dependency Management

### What Was Decided

Closed Dependabot PR #42 (lucide-react 0.577.0 → 1.16.0). Added a `version-update:semver-major` ignore rule for `lucide-react` in [.github/dependabot.yml](../../.github/dependabot.yml) so Dependabot stops re-raising v1 PRs. lucide-react stays on the 0.x line.

### Why

lucide-react 1.0 removed all **brand icons** (Github, LinkedIn, Twitter/X, YouTube, TikTok, Facebook, etc.). Bumping the package broke the build immediately on `import { Github } from 'lucide-react'`, which we use in 3 component files ([components/layout/Footer.tsx](../../components/layout/Footer.tsx), [components/home/CTASection.tsx](../../components/home/CTASection.tsx), [app/about/page.tsx](../../app/about/page.tsx)) — and which the CMS seed/fallbacks reference as a string. Brand icons are a deliberate v1 removal in lucide upstream, not a rename — they will not return.

### Alternatives Evaluated

- **Inline-SVG replacement of `Github`**: Workable but adds a one-off component. If lucide adds more brand removals in 1.x, we'd grow more inline SVGs. Rejected as the wrong direction.
- **Substitute with a non-brand icon** (`Code2`, `ExternalLink`): Loses visual identity of the GitHub link affordance. Rejected.
- **Bring in a brand-icon library** (`react-icons`, `simple-icons`): Adds a second icon dependency for one logo. Rejected as overkill.
- **Take v1 today, defer the brand-icon fix**: Build would not pass. Rejected.

### Trade-offs

- (+) Build stays green; no code changes needed
- (+) Keeps the recognizable GitHub brand mark across the UI
- (−) lucide-react 0.x is on minor/patch releases only; we miss future icon additions until we re-evaluate
- (−) Adds another deferred-major entry to the dependency policy

---

## Decision 68: Next.js Bumped to 16.2.6 (second CVE wave)

**Date:** 2026-05-19
**Title:** Patch — Next.js 16.2.6 to clear 13 high-severity advisories published 2026-04-21 → 2026-05-18
**Category:** Security / Dependency Management

### What Was Decided

Bumped `next` from `^16.2.4` to `^16.2.6` in `package.json`, re-resolving `package-lock.json`. No code changes required. After the bump, `npm audit --omit=dev --audit-level=high` exits 0 (only 2 moderate transitive postcss issues remain, below the gate).

### Why

Between 2026-04-21 (Decision 67) and 2026-05-18, **13 additional high-severity Next.js advisories** were published — cache poisoning via Server Component responses, middleware/proxy bypasses (multiple variants — App Router segment-prefetch, Pages Router i18n, dynamic route param injection), XSS in beforeInteractive scripts and CSP-nonce App Router, SSRF via WebSocket upgrades, DoS in Cache Components and Image Optimization API, and others. The `npm audit --omit=dev --audit-level=high` gate in [.github/workflows/test.yml:88](../../.github/workflows/test.yml#L88) exits 1 on HIGH+, which blocked all four 2026-05-18 Dependabot PRs (#44 better-sqlite3, #45 dotnet-servicing, #46 ef-core, #47 test-infrastructure) — none of which touch frontend code. The audit failure was a CI-level blocker for the entire queue.

### Alternatives Evaluated

- **Wait for Dependabot to propose the bump**: Dependabot hadn't raised a Next.js PR — the existing PRs were on other dependencies. Manual bump was faster than waiting for the next scheduled run.
- **Lower the audit gate to `--audit-level=critical`**: Permanently weakens supply-chain posture for a one-shot CI blocker. Rejected.
- **Override the `next` version via `overrides:`**: Adds indirection where a straight bump suffices.

---

## Decision 67: Next.js Bumped to 16.2.4 (CVE GHSA-q4gf-8mx6-v5v3)

**Date:** 2026-04-21
**Title:** Emergency patch — Next.js 16.2.4 to fix HIGH-severity Denial of Service via Server Components
**Category:** Security / Dependency Management

### What Was Decided

Bumped `next` from `^16.2.0` to `^16.2.4` and `eslint-config-next` to `^16.2.4` in `package.json`, with `package-lock.json` resolved to `16.2.4`. Dependabot PRs #16 and #17 (both targeting `16.2.1`, which is still within the vulnerable range) were closed rather than merged.

### Why

CVE GHSA-q4gf-8mx6-v5v3 ("Next.js has a Denial of Service with Server Components") affects all `next` versions `16.0.0-beta.0 – 16.2.2` with **HIGH** severity. The `npm audit --omit=dev --audit-level=high` gate in `test.yml` exits non-zero for HIGH+ vulnerabilities, which caused CI to fail on all branches (blocking the Dependabot sweep). Merging the existing Dependabot PRs would have downgraded security — `16.2.1` is still vulnerable. `16.2.3` is the first patched release; `16.2.4` (latest at the time) was chosen.

### Alternatives Evaluated

- **Merge Dependabot PR #17 (16.2.1)**: Still within the vulnerable range — would reintroduce the CVE. Rejected.
- **Suppress the audit check (`--audit-level=critical`)**: Lowers the security bar permanently. Rejected.
- **Pin to `16.2.3`**: Also patched, but `16.2.4` is the latest patch and includes all fixes from `.3`. No reason to not take `.4`.

---

## Decision 66: Dependabot Pinned to LTS / Current-Major Lines

**Date:** 2026-04-21
**Title:** Pin Dependabot to LTS/current major lines (Node 20, .NET 8, TypeScript 5, Swashbuckle 6)
**Category:** Infrastructure / Dependency Management

### What Was Decided

Added explicit `ignore` rules to `.github/dependabot.yml` to block major-version bumps that conflict with current LTS commitments or the Phase 8 deferral policy (Decision 35):

- **Node Docker images** (root + cms): ignore major bumps beyond Node 20 — Node 25 is odd-numbered STS (non-LTS); Node 22 LTS is the planned next target
- **.NET Docker images** (backend): ignore major bumps beyond .NET 8 — .NET 8 LTS runs until Nov 2026; .NET 10 migration is its own project
- **TypeScript** (root npm + cms npm): ignore major bumps beyond TS 5 — TS 6 deferred to Phase 8 per Decision 35
- **Swashbuckle.AspNetCore** (nuget): ignore major bumps beyond 6.x — explicitly deferred in Decision 35

21 accumulated Dependabot PRs (2026-03-19 to 2026-04-20) triggered this sweep. 7 PRs were Batch A (closed — major/non-LTS), 12 were Batch B (merged — patch/minor), 2 were Batch C (CMS-local, local verification required).

### Why

Without explicit ignore rules, Dependabot re-raises the same deferred-major PRs every weekly schedule run. The ignore rules make the deferral policy durable in the repo rather than relying on humans to re-close PRs manually each month.

### Alternatives Evaluated

- **`open-pull-requests-limit: 0`**: Would suppress all updates including valuable patch coverage — rejected
- **Auto-merge action**: Low PR volume makes manual review preferable; CI gates already catch regressions — rejected
- **`@dependabot ignore` comments**: Creates hidden state outside the repo; explicit `dependabot.yml` rules are the authoritative source of truth — rejected

---

## Decision 65: CMS Cold Storage Architecture

**Date:** 2026-04-10
**Title:** Move Strapi CMS from Live Azure Hosting to Local-Only with Git-Committed Backups
**Category:** Infrastructure / Cost

### What Was Decided

Moved Strapi CMS from live-hosted (Azure MySQL Flexible Server + Container App) to a cold storage model:
- **Local-only Strapi** for content authoring (`docker compose --profile cms`)
- **Git-committed backups** (`backups/cms/YYYY-MM-DD/`) as the authoritative content archive
- **Compile-time fallback objects** in `lib/cms/queries.ts` as the production content source (delimited regions refreshed via `scripts/cms/generate-fallbacks.ts`)
- **GitHub Actions workflows** (`cms-backup.yml`, `cms-restore-bundle.yml`, `cms-sync-fallbacks.yml`) for operator-driven content lifecycle
- **All Azure CMS resources deleted** — MySQL Flexible Server (`mysql-aipatterns-cms`), Strapi Container App (`ca-aipatterns-cms-prod`), 8 KV secrets
- **Storage Account retained** (`staipatternsmedia`) for historical media references

### Why

The frontend already had a complete `safeFetch()` fallback mechanism — production renders identically with or without a live Strapi instance. The live Azure MySQL was costing ~€14-16/mo for content that is almost entirely static UI labels. The runtime dependency on Strapi was notional: live Strapi was unreachable during Docker builds and all 10 query functions already returned hardcoded fallbacks on `CmsUnavailableError`.

### Alternatives Evaluated

- **Keep live MySQL:** Rejected — ongoing cost with no runtime benefit; frontend functioned entirely on fallback content.
- **Static JSON files in repo:** Rejected — loses the structured Strapi authoring experience (Dynamic Zones, content type admin UI).
- **Serverless/free-tier MySQL:** Rejected — Azure MySQL Flexible Server has no free tier; serverless tiers would be more expensive per-transaction for near-zero traffic.
- **PlanetScale / Neon (external free MySQL):** Not evaluated — adds external dependency and security surface without meaningful benefit over git-committed backups.

### Trade-offs

- (+) ~€14-16/mo cost savings (MySQL line item drops to €0)
- (+) Versioned, reviewable content — `git blame` on fallback changes; PR-based content review
- (+) Zero runtime external dependency — production has no live CMS network calls
- (+) Backup bundles are portable and restorable locally in minutes
- (−) Content updates require a local workflow + PR cycle (minutes instead of seconds in Strapi admin)
- (−) Media uploads limited — no live blob upload path; media handled manually into `staipatternsmedia`

### Rollback

Backup bundles in git are authoritative. To restore live cloud CMS: restore `infrastructure/modules/cms.bicep` from git history, restore `module cms` call and `mysqlAdminPassword` param in `main.bicep`, recreate KV secrets, run `az deployment group create`, run `scripts/cms/restore.sh` against new Azure MySQL, re-add `STRAPI_URL`/`STRAPI_API_TOKEN` env on web Container App. Expected time: ~2-3 hours (dominated by MySQL provisioning).

---

## Decision 64: E2E SSR Duplicate DOM — Scope Filter Interactions to Desktop Panel

**Date:** 2026-04-10
**Title:** Scope E2E Locators to `data-testid="desktop-filter-panel"` to Avoid SSR Duplicate ID Violations
**Category:** Testing / CI

### Problem

Next.js SSR renders both the desktop `FilterPanel` (always visible at `lg:block`) and the `FilterSheet`'s inner `FilterPanel` into the initial HTML. Even though the Sheet panel is hidden via CSS and its React portal would reposition the DOM post-hydration, Playwright evaluates locators against the full server-rendered HTML before hydration completes. This produces:

- **Strict-mode violations** on `#date-from` / `#date-to` — two `<input>` elements with the same `id` in the DOM
- **Wrong-target clicks** on tag checkboxes — clicking the hidden Sheet instance leaves the URL unchanged (handler runs against a stale, uninteractive component)

Symptoms: `E2E Tests (webkit)` failing with "strict mode violation: locator('#date-to') resolved to 2 elements"; `E2E Tests (chromium)` flaky with `tags=` URL never updating after tag checkbox click.

### Decision

1. Add `data-testid="desktop-filter-panel"` to the desktop wrapper `<div>` in `app/patterns/page.tsx`.
2. Scope all date filter and tag toggle E2E locators to `page.locator('[data-testid="desktop-filter-panel"]')`.
3. Update `fillDateInput()` signature to accept `Page | Locator` so it can be called with the scoped container.
4. Between sequential tag checkbox clicks, wait for `toBeChecked` on the first checkbox — confirms React has re-rendered with the updated URL params before the second click fires.

### Rationale

- The `data-testid` attribute is a non-behavioral, zero-cost production change. It makes tests semantically correct (they should target the visible interactive panel) and eliminates the flakiness root cause.
- Waiting for `toBeChecked` is the correct Playwright idiom for confirming state propagation between interactions — it replaces brittle timing assumptions with an observable state signal.

### Alternatives Evaluated

- **`.first()` on duplicate locators** — rejected: relies on DOM order (Sheet renders before desktop panel in source), which is fragile and may invert across environments.
- **`waitForLoadState('networkidle')`** — rejected: Next.js production prefetching prevents `networkidle` from ever resolving in CI.
- **Disable SSR for FilterSheet** — rejected: over-engineering; the testid approach is the minimal correct fix.

---

## Decision 63: Phase 7.11 — Infrastructure Drift Resolution & Live Hardening

**Date:** 2026-03-23
**Title:** Phase 7.11 Infrastructure Drift — 30 Drift Items Resolved Across 6 Tracks
**Category:** Infrastructure / Security / IaC

### Summary

A comprehensive audit comparing the live Azure subscription against the Bicep IaC definitions (written in Phase 6.8 but never fully applied) revealed 30 drift items. This phase resolves all actionable drift via Bicep corrections, IaC hardening additions, and documentation. Critical security gaps addressed: KV RBAC mode, KV purge protection, Storage TLS 1.2, MySQL SSL enforcement, CMS managed identity for ACR pull.

### Decisions Made

**Track 1 — Fix Bicep to Match Live Reality:**
Corrected 6 Bicep drift items that would cause destructive conflicts on redeploy:
- `sql.bicep`: `sqlAdminLogin` changed from `sqladmin` → `aipatterns-admin` (matches live SQL Server admin)
- `sql.bicep`: `maxSizeBytes` changed from 32 GiB → 1 GiB (matches live database; increase when approaching limit)
- `cms.bicep`: `mysqlAdminLogin` changed from `mysqladmin` → `strapiAdmin` (matches live MySQL admin and provision-cms.ps1)
- `cms.bicep`: `storageLocation` param added (defaults `centralus`) so Storage Account deploys to correct region
- `cms.bicep`: `autoGrow` changed from `Enabled` → `Disabled` (matches live MySQL server config)
- `containerApps.bicep`: `DATABASE_USERNAME` corrected to `strapiAdmin`; `maxReplicas` on API and Web raised from 5 → 10; 7 missing CMS secrets added (API token salt, transfer token salt, JWT secret, storage account key) with KV references; missing CMS env vars added (`API_TOKEN_SALT`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET`, `AZURE_STORAGE_ACCOUNT`, `AZURE_STORAGE_ACCOUNT_KEY`, `AZURE_STORAGE_CONTAINER`, `AZURE_STORAGE_URL`, `PUBLIC_URL`)

**Track 2 — Security Hardening:**
- Key Vault RBAC mode (`enableRbacAuthorization: true`) and purge protection (`enablePurgeProtection: true`) were already correctly set in `keyvault.bicep` — confirmed no change needed
- `cms.bicep` already has `minimumTlsVersion: 'TLS1_2'` on Storage Account — live fix (TLS 1.0 → 1.2) is an operational step
- Added MySQL SSL enforcement: `require_secure_transport = ON` configuration resource in `cms.bicep`
- CMS Container App already uses `identity: 'system'` for ACR pull in Bicep — live drift (using admin creds) is operational

**Track 3 — IaC Hardening (New Additions):**
- `keyvault.bicep`: Added `logAnalyticsId` param; added `AuditEvent` diagnostic settings resource (conditional on Log Analytics ID); added `CanNotDelete` resource lock
- `sql.bicep`: Added `backupShortTermRetentionPolicies` (7 days, 24h diff backup interval); added `CanNotDelete` resource lock on SQL Server
- `cms.bicep`: Added `CanNotDelete` resource locks on MySQL Server and Storage Account; backup retention raised from 7 → 14 days
- `main.bicep`: Wired `logAnalyticsId` into `keyvault` module; updated dependency comment

**Track 4 — Tags + Cleanup:**
Tags (`project: AIEnterprisePatterns`, `environment`, `managedBy: bicep`) already defined in `main.bicep` and passed to all modules. Applied via Bicep redeploy resolves D3, D5, D9, D12–D14, D27. Orphaned `mysql-aipatterns-cms-test` server (D28) must be deleted manually: `az mysql flexible-server delete --name mysql-aipatterns-cms-test -g rg-aipatterns-prod --yes`.

**Track 5 — Documentation + GitHub Community Files:**
- This decision entry
- Created `.github/CODEOWNERS` (frontend → web team, backend → backend team)
- Created `.github/SECURITY.md` (private vulnerability disclosure via GitHub Security Advisories)

**Track 6 — Alert Email:**
Added `alertEmail` parameter with value `sandropetterle@hotmail.com` to `infrastructure/main.parameters.prod.json`. This activates the alert action group and wires all 4 metric alerts to send email notifications.

### Alternatives Evaluated

- **Full Bicep redeploy to fix live drift:** Too risky without careful parameter alignment first. Incremental approach — fix Bicep, then apply operational fixes via `az` CLI — is safer.
- **VNet integration to address public SQL/MySQL:** Cost prohibitive at this scale (Premium CAE ~$150+/month). Azure services firewall rule + TLS + SSL enforcement accepted as sufficient.
- **Container image signing / SBOM:** Deferred to Phase 8. ACR Basic lacks scanning; upgrade path exists.

### Accepted Risks

| # | Risk | Rationale |
|---|------|-----------|
| 1 | Public SQL/MySQL endpoints | Azure services firewall, TLS 1.2, SQL minTLS, MySQL SSL — sufficient at this scale; VNet deferred to Phase 8+ |
| 2 | ACR Basic (no vulnerability scanning) | Accepted in Phase 7.5; upgrade deferred |
| 3 | Full Bicep redeploy not executed | IaC corrections applied; operational live fixes documented but not automated — requires manual `az` CLI steps |
| 4 | Orphaned MySQL test server not deleted in code | Must be deleted manually; cannot be represented in Bicep without risk of unintended deletion |

---

## Decision 62: Phase 7.10 — Production Readiness & Observability Hardening

**Date:** 2026-03-19
**Title:** Phase 7.10 Production Readiness — Five Tracks Address All MEDIUM Findings
**Category:** Operations / Infrastructure / Observability

### Summary

Phase 7.10 is a systematic audit of production readiness and observability. The system was in good shape overall (fundamentals solid: App Insights wired, health endpoints, security headers, ISR caching). Six MEDIUM findings and five LOW accepted risks were identified. Five implementation tracks address all actionable items.

### Decisions Made

**Track 1 — Alert Action Group:** Already implemented in Phase 7.5. Alert action group with email receiver conditional on `alertEmail` parameter is wired into all 4 metric alerts in `monitoring.bicep`. No further action required.

**Track 2 — SEO Essentials:** Created `app/robots.ts` (Next.js Metadata API, disallows `/api/` and `/login/`) and `app/sitemap.ts` (fetches all patterns dynamically, falls back to static routes if API unavailable). Updated `metadataBase` and OpenGraph `url` in `app/layout.tsx` from placeholder `ai-patterns.example.com` to the production Container Apps URL.

**Track 3 — IaC Health Probes & Env Parity:** Added startup/liveness/readiness HTTP probes to both API (port 8080, `/health` / `/health/ready`) and web (port 3000, `/`) container apps in `containerApps.bicep`. Added 6 missing web container env vars (`AUTH_ENTRA_ISSUER`, `AUTH_ENTRA_CLIENT_ID`, `AUTH_API_SCOPE_READ`, `AUTH_API_SCOPE_WRITE`, `STRAPI_URL`, `STRAPI_API_TOKEN`). `STRAPI_API_TOKEN` is a Key Vault secret reference. All new params threaded through `main.bicep` with production defaults.

**Track 4 — Business Telemetry:** Injected `TelemetryClient` into `PatternService` (auto-registered by `AddApplicationInsightsTelemetry()`). Added `TrackEvent()` calls: `PatternViewed` (slug, category), `PatternVoted` (patternId), `PatternSearched` (search, category, tagCount — only when filter applied), `PatternCreated` (slug, category), `PatternUpdated` (slug, category). Added `TrackMetric()` for featured/trending cache hit/miss. Added `Microsoft.ApplicationInsights` package to Core project. Added 5 unit tests verifying telemetry assertions via `FakeTelemetryChannel`.

**Track 5 — Documentation & CI:** Updated `MONITORING_GUIDE.md` performance baselines to reflect IaC and CMS integration; updated continuous improvement section with completed/deferred items. Added `categories:accessibility: warn, minScore: 0.90` to `lighthouserc.yml`.

### Alternatives Evaluated

- **TelemetryClient in Infrastructure layer:** Would avoid adding `Microsoft.ApplicationInsights` to Core. Rejected — Core already has `IMemoryCache` from Microsoft.Extensions; App Insights base package is a stable, low-risk addition. Placing tracking in the service layer keeps business intent visible where business logic lives.
- **Separate liveness endpoint (`/health/live`):** Would allow probes to differentiate container alive vs. DB ready. Accepted risk — DB check is the only meaningful health signal; Container Apps probes with `/health` / `/health/ready` are the real fix over the TCP default.
- **Frontend App Insights JS SDK:** Would give client-side RUM and session tracking. Deferred — requires `'use client'` instrumentation wrapper, increases bundle size; server-side API calls already tracked by backend App Insights.

### Accepted Risks

| # | Risk | Rationale |
|---|------|-----------|
| 1 | Unstructured frontend logging | Container Apps captures console output; structured logging library adds complexity for minimal gain at this scale |
| 2 | No frontend App Insights SDK | Bundle cost; server-side tracking covers the critical path |
| 3 | No explicit Cache-Control on API responses | ISR handles frontend caching; browser-level API caching not needed |
| 4 | No bundle size budget in CI | Lighthouse performance ≥ 0.80 implicitly gates egregious bundle growth |
| 5 | `/health` and `/health/ready` identical | DB check is the only dependency; Container Apps probes are the real fix |

---

## Decision 61: Phase 7.9 — Documentation Completeness & Accuracy Audit

**Date:** 2026-03-19
**Title:** Phase 7.9 Documentation Audit — Strong Foundation Confirmed; Four MEDIUM Findings Remediated
**Category:** Documentation / Governance

### Summary

Phase 7.9 is a systematic audit of all project documentation for completeness, accuracy, currency, and governance compliance. The documentation foundation is strong overall. Four MEDIUM findings and two LOW accepted risks were identified. Three lightweight tracks address all MEDIUM findings. This is a docs-only phase with no code changes.

### Decisions Made

**Track 1 — Archive Stale Test Results:**
`documentation/test_results/COMPREHENSIVE_TEST_RESULTS.md` (dated 2026-02-10, Pre-Phase 4 snapshot) was archived rather than updated. Phase 7.8 Track 1 already created the replacement baselines (`phase7_8_testing_baseline.md` and `phase6_test_results.md`). Updating the old file would duplicate that work. An archive banner was added to the top, the Executive Summary status was changed from "PASSING WITH ISSUES" to "ARCHIVED", and `DOCUMENTATION_INDEX.md` was updated to reflect the archived status.

**Track 2 — IaC Cross-References in Operations Docs:**
All four operations docs (`RUNBOOK.md`, `DISASTER_RECOVERY.md`, `INCIDENT_RESPONSE.md`, `MONITORING_GUIDE.md`) were written in February 2026 before Phase 6.8 introduced Bicep IaC. Added cross-references to `INFRASTRUCTURE_MANAGEMENT.md` per GOVERNANCE.md Section 4 (Single Source of Truth):
- RUNBOOK: Added "Infrastructure Changes" section — do not use ad-hoc `az containerapp update` for permanent config; changes must go through Bicep
- DISASTER_RECOVERY: Added Bicep redeployment as a full environment rebuild strategy (Section 5.2a)
- INCIDENT_RESPONSE: Added infrastructure forensics step in Eradication phase — review Bicep modules, harden in code, redeploy
- MONITORING_GUIDE: Added Section 4.0 noting the 4 metric alerts are defined in `monitoring.bicep` — modify there, not via Azure Portal
Updated `Last Updated` dates on all four docs to 2026-03-19.

**Track 3 — CMS Phase Status, Auth Guide Header, Decision Log:**
- `CMS_ARCHITECTURE.md` line 15: Changed Phase 2 status from "🔜 ... upcoming" to "✅ ... complete (2026-03-03)". Updated `Last Updated` to 2026-03-19.
- `AUTH_SETUP_GUIDE.md`: Added required GOVERNANCE.md Section 3 header (`Last Updated`, `Audience`, `Purpose`) which was missing.
- This entry.

**Accepted Risks (unchanged from evaluation):**
- Dead links to `COMPREHENSIVE_TEST_PLAN.md` (8 occurrences in TESTING_STRATEGY.md and MANUAL_TEST_EXECUTION_GUIDE.md) — fixed as part of this phase (optional track)
- `SYSTEM_OVERVIEW.md` missing IaC reference — still architecturally accurate; `INFRASTRUCTURE_MANAGEMENT.md` is the single source of truth per GOVERNANCE.md Section 4

### Alternatives Evaluated

- **Update COMPREHENSIVE_TEST_RESULTS.md instead of archiving:** Would duplicate Phase 7.8's baseline work. Archive is cleaner and the two 7.8 docs are the correct ongoing baselines.
- **Full rewrite of operations docs to incorporate IaC detail:** Rejected — would violate GOVERNANCE.md Section 4 (single source of truth). Cross-references to `INFRASTRUCTURE_MANAGEMENT.md` are sufficient and avoid duplication drift.

---

## Decision 60: Phase 7.8 — Testing Coverage & Quality Evaluation

**Date:** 2026-03-19
**Title:** Phase 7.8 Testing Audit — Enterprise-Grade Baseline Confirmed; Three Lightweight Tracks Implemented
**Category:** Testing / Quality Assurance / CI/CD

### Summary

Phase 7.8 is a systematic audit of all test layers: frontend unit, backend unit, E2E, performance, visual regression, and accessibility. The evaluation confirms the testing infrastructure is enterprise-grade. Five MEDIUM findings were identified; all are addressed (three lightweight tracks implemented in Phase 7.8, two deferred).

### Decisions Made

**Track 1 — Test Results Documentation:**
Created two new test result documents to close the documentation gap since Phase 5.1:
- `documentation/test_results/phase6_test_results.md` — snapshot of testing additions across Phases 6.3–6.8 (Lighthouse CI, Chromatic, cross-browser E2E, CMS query tests, auth E2E)
- `documentation/test_results/phase7_8_testing_baseline.md` — full metrics snapshot at Phase 7.8 evaluation (all six test layers, CI architecture, deferred capabilities)

**Track 2 — Backend CI Coverage Reporting:**
Backend coverage collection was already in place (added in an earlier phase): `coverlet.collector` v6.0.4 is referenced in all three test `.csproj` files; `dotnet test --collect:"XPlat Code Coverage" --settings coverlet.runsettings` runs in CI; Codecov upload (`flag: backend`) is configured in `test.yml`. No CI changes required.

The `backend/coverlet.runsettings` file excludes test assemblies and EF Core migrations, includes the three source projects (Api, Core, Data). A formal coverage **threshold** (e.g., 70% matching frontend) is not yet enforced — accepted risk for Phase 7.8; backend structure is stable and threshold enforcement is a Phase 8 item.

**Track 3 — E2E API Write Test Strategy Documentation:**
Added Section 9.1 ("E2E Auth Test Strategy") to `documentation/testing/TESTING_STRATEGY.md` explaining the three-tier auth test split:
- Unauthenticated guards — always run
- Authenticated UI — always run when `AUTH_SECRET` is set (synthetic session cookie via `@auth/core/jwt`)
- Authenticated API writes — **intentionally skipped in CI** (`E2E_API_WRITES=true` opt-in)

Documented the rationale (backend JWKS validation rejects synthetic tokens), what would be required to enable in CI (test Entra user + GitHub Secrets + protected environment), and how to run locally.

**Track 4 — Decision Log:**
This entry.

### Deferred

| Finding | Tool | Effort | Phase |
|---------|------|--------|-------|
| No mutation testing (assertion quality unverified) | Stryker + Stryker.NET | 4-6 weeks | 8 |
| No load/stress testing (rate limiters unverified under concurrency) | k6 | 3-4 weeks | 8 |
| No contract testing (frontend/backend DTO drift) | Pact | 4-5 weeks | 9+ |

### Accepted Risks

| Risk | Rationale |
|------|-----------|
| `OperationCanceledException` not unit-tested | Rare edge case; logged correctly; Application Insights monitors production |
| SkeletonCard + LoadingAnnouncer at 0% Jest coverage | Pure presentational; no logic; covered by E2E when loading states appear |
| Radix UI mocked in Jest (jsdom portal limitation) | Documented pattern; mocks are comprehensive; real components validated in E2E |
| Chromatic `exit-zero-on-changes` still active | Intentional — baseline acceptance in progress |
| No backend CI coverage threshold | Backend structure is stable; threshold enforcement is a Phase 8 item |

### Alternatives Evaluated

- **Stryker mutation testing now** — rejected for Phase 7.8: significant effort (4-6 weeks); 70%+ frontend and ~85% backend coverage thresholds are adequate for current scale and team size
- **k6 load testing now** — rejected: needs a staging environment with a larger dataset; Lighthouse CI validates single-user performance adequately
- **Pact contract testing now** — rejected: single monorepo with tightly coupled frontend/backend; most valuable when APIs serve multiple consumers or services live in separate repos

---

## Decision 59: Phase 7.7 — Docker & Container Security Hardening

**Date:** 2026-03-19
**Category:** Security / Infrastructure / Performance

**Decision:** Four implementation tracks for Docker and container security hardening: (1) SHA pinning — all 7 `FROM` lines across 3 Dockerfiles pinned to immutable digest references (`@sha256:<64-char-hex>`), keeping the mutable tag as a human-readable comment; (2) Backend Alpine migration — `aspnet:8.0` (Debian) replaced with `aspnet:8.0-alpine`, eliminating the `apt-get install curl` layer (~150 MB → ~90 MB, ~63% smaller), switching `groupadd`/`useradd` to Alpine's `addgroup -S`/`adduser -S`, and replacing `curl -f` healthcheck with BusyBox `wget -qO-` (pre-installed in Alpine); (3) Compose cleanup — removed deprecated `version: '3.8'` field from `docker-compose.yml`; (4) CMS .dockerignore hardening — added `.git/`, IDE dirs (`.vscode/`, `.idea/`), OS files (`.DS_Store`, `Thumbs.db`), and `*.md` exclusions. Track 3 (`npm ci` in CMS Dockerfile) deferred: `cms/package-lock.json` is gitignored by Strapi convention — `npm ci` without a committed lockfile fails; would require removing `package-lock.json` from `cms/.gitignore` as a prerequisite.

**Why:** SHA pinning eliminates supply-chain risk where a re-published mutable tag silently introduces a compromised upstream image. Alpine runtime removes an unnecessary `apt-get` layer (attack surface reduction + 63% image size reduction). Compose `version:` field emits deprecation warnings in Compose v2. `.dockerignore` gaps caused unnecessary build context transfer. `npm ci` (reproducibility) blocked by gitignored lockfile — deferred.

**Alternatives evaluated:**
- Distroless base for backend — rejected; no shell available for healthcheck debugging in production incidents
- Chainguard images — rejected; over-engineering at current scale, no material benefit over SHA-pinned official Microsoft images
- Committing `cms/package-lock.json` to enable `npm ci` — deferred; requires explicit decision to change Strapi project convention; not blocking Phase 7.7

---

## Decision 58: Phase 7.3 — Frontend Code Quality & Security Hardening

**Date:** 2026-03-19
**Category:** Security / Code Quality

**Decision:** Five implementation tracks for frontend code quality and security hardening: (1) CMS HTML sanitization — install `isomorphic-dompurify` and wrap all 3 `dangerouslySetInnerHTML` calls in `lib/cms/components.tsx` (RichTextRenderer, DocSectionRenderer, ContributingRenderer) with `sanitizeCmsHtml()` from new `lib/cms/sanitize.ts`; (2) CSP hardening — add `base-uri 'self'` and `object-src 'none'` directives to `next.config.mjs`, narrow `img-src` from `https:` (any HTTPS origin) to the specific CMS media hostname `https://staipatternsmedia.blob.core.windows.net`; (3) 429 rate-limit handling — add `response.status === 429` case to `handleApiError()` in `lib/api/error.ts` with user-friendly message; (4) ESLint security plugin — install `eslint-plugin-security` and enable 4 rules (`detect-eval-with-expression`, `detect-unsafe-regex`, `detect-non-literal-regexp`, `detect-possible-timing-attacks`) with `detect-object-injection` off due to false positives; (5) source maps verification — confirmed no `.map` files present in `.next/static/` production output; no config change needed.

**Why:** Defense-in-depth: even admin-only CMS content should be sanitized (a compromised CMS account or Strapi vulnerability could inject XSS). CSP gaps (`base-uri`, `object-src` missing; wide `img-src`) were identified by OWASP CSP Cheat Sheet. 429 errors displayed as generic errors rather than actionable user messages. No static analysis for `eval()` or unsafe regex patterns.

**Alternatives evaluated:**
- `DOMPurify` directly (browser-only) — rejected; `isomorphic-dompurify` wraps it with JSDOM for server component compatibility
- `unsafe-eval` removal from CSP — tested; retained with comment since Next.js 16 build tooling may require it; documented as accepted risk per plan
- `moduleNameMapper` for isomorphic-dompurify in Jest — rejected; mocking the module at test level is cleaner than fighting nested ESM node_modules in transform config

---

## Decision 57: Phase 7.5 — IaC & Azure Security Hardening

**Date:** 2026-03-19
**Category:** Infrastructure / Security

**Decision:** Four implementation tracks for Bicep IaC and Azure security hardening: (1) Governance & parameterization — add `var tags = { project, environment, managedBy: 'bicep' }` propagated to every resource in all 7 modules; convert hardcoded `var` resource names to `param` with production defaults (acrName, kvName, sqlServerName, mysqlServerName, storageAccountName), enabling future staging environment overrides; parameterize `NEXT_PUBLIC_API_BASE_URL` in containerApps.bicep; add `@allowed(['centralus','eastus','eastus2','westus2'])` on location, `@allowed(['prod','staging','dev'])` on environment, and `@minLength(12)` on both password params; (2) Monitoring & observability — add conditional `Microsoft.Insights/actionGroups` resource (only created when `alertEmail` param is non-empty, keeping template deployable without email config); wire `actionGroupId` into all 4 metric alert `actions` arrays; add conditional `Microsoft.Insights/diagnosticSettings` on SQL database (only when `logAnalyticsId` param provided, creating an explicit dependency edge from sql → monitoring); lower exception spike threshold from 20 → 10; (3) Key Vault & secrets hardening — enable `enablePurgeProtection: true` (irreversible one-way setting, intentional) and raise `softDeleteRetentionInDays` from 7 → 90; move App Insights connection string from inline `value: appInsightsConnectionString` secret to `keyVaultUrl` + `identity: 'system'` KV reference, removing the `appInsightsConnectionString` param from both containerApps.bicep and main.bicep; add post-deploy step to deploy.ps1 and infrastructure/README.md to store the connection string in KV; (4) Documentation — Decision 57, ACR cleanup commands in infrastructure/README.md.

**Why:** The Phase 7.5 audit found the IaC foundation solid overall (RBAC KV, managed identities, admin-disabled ACR, TLS 1.2, CI validation all present) with 10 MEDIUM findings that were hardening improvements rather than critical vulnerabilities. The 4 highest-value items: (a) absence of resource tags made cost attribution and environment filtering impossible in Azure Portal; (b) hardcoded resource names prevented staging environment reuse of the same templates; (c) alert action groups not configured meant all 4 metric alerts fired silently with no notification path; (d) App Insights connection string visible in ARM deployment history is a security hygiene issue — KV references eliminate it from the history.

**Alternatives evaluated:**
- Tags as module-level `var` vs passed from main.bicep — chose passed-from-main so the `environment` tag reflects the actual param value, not a hardcoded string per module
- Always-on action group (no conditional) — rejected; would require an email param with no default, breaking existing deployments; conditional resource keeps the template deployable in CI validation without alert config
- `enablePurgeProtection` opt-in via param — rejected; purge protection is a one-way security control, not a preference; always enabling it is the correct security posture and the plan explicitly accepts this is irreversible

## Decision 56: Phase 7.4 — Backend Code Quality & Security Hardening

**Date:** 2026-03-19
**Category:** Security / Code Quality

**Decision:** Five implementation tracks for backend code quality and security hardening: (1) CORS/HSTS/DB provider — wrap `localhost:3000` in `IsDevelopment()` guard so production CORS only allows configured `FrontendUrl`/`FrontendUrls`; add `Strict-Transport-Security: max-age=31536000; includeSubDomains` in non-development environments; simplify DB provider selection to connection-string-based (`null/empty` → SQLite, non-empty → SQL Server), removing fragile `Contains("localhost,1433")` check; (2) vote race condition — replace load-modify-save with `ExecuteUpdateAsync` atomic SQL `UPDATE` for relational providers, with InMemory fallback for tests; (3) exception middleware — add `catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)` before the general catch, logging at `Information` rather than `Error` to reduce noise from normal client disconnects; (4) validation cleanup — remove redundant `Enum.TryParse` + `BadRequest` in `CreatePattern`/`UpdatePattern` (FluentValidation already rejects invalid categories before the action executes), replace with `Enum.Parse` (safe after validation); add `Must(!IsNullOrWhiteSpace)` to tag validators to reject whitespace-only strings; (5) template cleanup — fix `launchSettings.json` `launchUrl` from `"weatherforecast"` to `"swagger"` in all three profiles.

**Why:** The Phase 7.4 audit found the backend in strong shape with no critical vulnerabilities. The 4 MEDIUM findings were all hardening opportunities: CORS unconditionally exposed `localhost:3000` in production (attack surface expansion), HSTS absence allowed SSL stripping on repeat visits, the vote endpoint had a classic lost-update race condition under load, and client disconnects logged as Error created alert noise masking real failures. The 4 LOW findings were code quality improvements with no security impact.

**Alternatives evaluated:**
- HSTS `preload` directive — deferred; requires stable production domain + HSTS preload list submission application; `includeSubDomains` without preload is the correct incremental step
- `TransactionScope` for vote atomicity — rejected; `ExecuteUpdateAsync` generates a single `UPDATE` statement with no round-trips, superior to read-then-write-in-transaction
- Remove `OperationCanceledException` catch entirely — rejected; we still want `LogInformation` confirmation for observability; the `when` guard correctly scopes to client-initiated cancellations only
- Keep `Enum.TryParse` in controller as defense-in-depth — rejected; FluentValidationAutoValidation runs before action methods, making the controller check unreachable dead code

**Accepted risks:** Unused `UnitOfWork` injection (`PatternService` calls `repository.SaveAsync()` directly; removing requires larger architectural refactor with no security benefit); exception details in server logs (generic message returned to clients — intentional for server-side debugging); no CSP/Permissions-Policy on API (not applicable to JSON APIs).

---

## Decision 55: Phase 7.2 — Backend Dependency Hardening

**Date:** 2026-03-19
**Category:** Security / Dependencies

**Decision:** Five implementation tracks for backend dependency hardening: (1) patch CVE-2024-43483 — upgrade `Microsoft.Extensions.Caching.Memory` 8.0.0 → 8.0.1 in the Core.Tests project (DoS via hash flooding, test-only); (2) update all production packages to latest .NET 8.x servicing: `Asp.Versioning.Mvc/ApiExplorer` 8.1.0→8.1.1, `FluentValidation.AspNetCore` 11.3.0→11.3.1, `JwtBearer` 8.0.0→8.0.25, `EF Core Design` 8.0.0→8.0.25, `Swashbuckle.AspNetCore` 6.5.0→6.9.0, all 4 EF Core packages 8.0.0→8.0.25, `ApplicationInsights.AspNetCore` 2.22.0→2.23.0, `HealthChecks.EntityFrameworkCore` 8.0.0→8.0.25; (3) update test infrastructure: `FluentAssertions` 8.8.0→8.9.0, `Microsoft.NET.Test.Sdk` 17.8.0→17.14.1, `xunit` 2.5.3→2.9.3, `xunit.runner.visualstudio` 2.5.3→2.8.2, `Mvc.Testing` and `EF InMemory` 8.0.0→8.0.25; (4) add NuGet vulnerability gate (`dotnet list package --vulnerable --include-transitive` with grep-based gating) to both CI workflows; (5) enhance `.github/dependabot.yml` NuGet entry with groups and ignore rules.

**Why:** The Phase 7.2 audit found 1 HIGH CVE (CVE-2024-43483), 19 outdated packages (all within .NET 8 LTS), no CI vulnerability scanning, and incomplete Dependabot config for NuGet. All package updates stay within .NET 8.x — no TFM change needed. The `dotnet list package --vulnerable` command always exits 0, so grep-based gating is required to block CI on detected vulnerabilities. Swashbuckle 6.9.0 is a 4-minor jump but dev-only (gated behind `IsDevelopment()`), zero production risk. Not updating: Moq 4.20.72 (already latest 4.x; no 5.x due to SponsorLink controversy), coverlet.collector 6.0.4 (8.x aligned with .NET 10), xunit 3.x (major API rewrite, evaluate separately).

**Alternatives evaluated:**
- Skip Swashbuckle update (stay at 6.5.0) — dev-only tooling, no risk; updating to 6.9.0 gets 4 minor version improvements with no breaking API changes observed
- Update coverlet to 8.x — rejected, 8.x is a major version change aligned with .NET 10; staying on 6.x until .NET 10 migration
- Add `--exit-code` flag to `dotnet list package --vulnerable` — this flag does not exist; grep-based approach is the only supported pattern
- Future: Replace Swashbuckle with `Microsoft.AspNetCore.OpenApi` — deferred to .NET 9/10 migration (Swashbuckle deprecated for .NET 9+)

---

## Decision 54: Phase 7.1 — Frontend Dependency Hardening

**Date:** 2026-03-19
**Category:** Security / Dependencies

**Decision:** Four implementation tracks for frontend dependency hardening: (1) add `overrides` in `package.json` for `flatted >=3.4.0`, `serialize-javascript >=7.0.3` (in addition to existing `ajv ^8.8.2`) to resolve transitive vulnerabilities; the `minimatch` HIGH was resolved by the `next` 16.2.0 upgrade and does not require an override (a `minimatch >=9.x` override breaks `test-exclude`/`babel-plugin-istanbul` which use the legacy default export API); (2) update all production and dev dependencies to latest minor/patch versions (`next` 16.1.6→16.2.0, Storybook 10.2.14→10.3.0, Jest 30.2→30.3, etc.); (3) update CMS packages: all `@strapi/*` 5.36.1→5.40.0 together, `mysql2` 3.11.0→3.20.0; (4) add `npm audit --omit=dev --audit-level=high` step to both CI workflows and create `.github/dependabot.yml` with weekly Monday automation for npm (root + cms), NuGet (backend), and GitHub Actions.

**Why:** The Phase 7.1 audit found 14 npm vulnerabilities (10 low, 4 high — all in devDependencies transitive chains) and 18 outdated packages, with no automated dependency management. Production deps were already clean. The `--omit=dev` audit flag is deliberate: remaining HIGH vulnerabilities (`elliptic` via Storybook→crypto-browserify, `tmp` via LHCI→inquirer) have no upstream patches and only affect dev-time tooling — production users are never exposed to these code paths.

**Alternatives evaluated:**
- `npm audit fix --force` — would downgrade `@storybook/nextjs` to 7.x or `@lhci/cli` to 0.1.0, both breaking changes with significant regression risk
- Skip `overrides` for `minimatch` — already resolved by the `next` 16.2.0 upgrade which pulled in a patched version; override added defensively
- Major version updates (tailwindcss v4, eslint v10, next-auth v5 stable) — out of scope; tailwindcss v4 is a configuration rewrite, eslint v10 has breaking plugin changes, next-auth is intentionally on v5 beta

**Accepted risks:** `elliptic` (Storybook→crypto-browserify — no patched version available), `tmp` (LHCI→inquirer — no patched version available). Both are dev-only with no production exposure. Accepted until upstream maintainers release fixes.

**Implementation plan:** Deleted per governance (1 phase after completion).

---

## Decision 53: Phase 7.10 — Production Readiness & Observability

**Date:** 2026-03-19
**Category:** Observability / Infrastructure

**Decision:** Five implementation tracks for cross-cutting production readiness: (1) wire alert action groups into all 4 metric alerts in `monitoring.bicep` with email notification and lower exception threshold from 20 to 10; (2) add `robots.txt` and XML sitemap via Next.js Metadata API, fix placeholder `metadataBase` URL; (3) add Container Apps liveness/readiness/startup health probes in `containerApps.bicep` and declare 6 missing web container env vars in IaC; (4) inject `TelemetryClient` into `PatternService` for custom business telemetry (PatternViewed, PatternVoted, PatternSearched, cache hit/miss); (5) add Lighthouse accessibility assertion to CI and update stale monitoring baselines.

**Why:** The Phase 7.10 audit evaluated 9 cross-cutting production concerns (health probes, logging, telemetry, alerting, performance baselines, SEO, accessibility, caching, environment parity). The system is in good production shape overall — Application Insights connected, health endpoints present, JSON-LD structured data on all key pages, ISR caching configured, 4 accessibility test suites. Six MEDIUM findings were identified:
- Alert action groups not wired — all 4 metric alerts fire into the void; nobody gets notified of outages or error spikes
- No `robots.txt` or XML sitemap; `metadataBase` uses placeholder `ai-patterns.example.com`
- No Container Apps health probes in IaC — Azure uses default TCP-only probes
- Web container missing 6 env vars in Bicep (auth, CMS) — likely set via `az containerapp update` but not declared in IaC
- Zero custom business telemetry — no visibility into pattern views, votes, searches, or cache effectiveness

**Alternatives evaluated:**
- Frontend Application Insights JavaScript SDK — adds client-side telemetry but increases bundle size and requires `'use client'` wrapper; deferred to Phase 8+
- Synthetic availability tests — scale-to-zero makes these noisy with cold start false positives
- CDN / Azure Front Door — adds $35+/month, not justified at current traffic levels
- Structured frontend logging (pino/winston) — Container Apps already captures console output; complexity not justified at this scale

**Accepted risks:** Unstructured frontend console logging (captured by Container Apps), no frontend App Insights SDK (server calls tracked by backend), no explicit Cache-Control headers on API (ISR handles caching), no bundle size budget (Lighthouse score gates growth), identical `/health` and `/health/ready` endpoints (health probes are the real fix).

**Implementation plan:** Deleted per governance (1 phase after completion).

---

## Decision 52: Phase 7.6 — CI/CD Pipeline Hardening

**Date:** 2026-03-18
**Category:** Infrastructure

**Decision:** Five hardening tracks for all 4 GitHub Actions workflows: (1) pin all 6 unique actions (~36 `uses:` references) to full commit SHAs for supply chain security; (2) add least-privilege `permissions: {}` to `test.yml`, concurrency groups to all workflows, and fix a rollback bug where `:latest` is overwritten before healthcheck (defer `:latest` tag to post-healthcheck `tag-latest` job); (3) create `.github/dependabot.yml` for npm, NuGet, GitHub Actions, and Docker ecosystems; (4) include `e2e-tests` in `test-summary` gate (handle `"skipped"` on PRs); (5) documentation.

**Why:** The Phase 7.6 audit found the CI/CD foundation solid (OIDC auth, path-filtered deploys, healthcheck gates, Lighthouse/Chromatic quality gates, cross-browser E2E matrix). Six MEDIUM findings and one rollback correctness bug were identified:
- Tag-based action references (`@v4`) are mutable — a compromised action can silently change behavior
- `test.yml` has no `permissions` block, defaulting to broad read/write on push events
- No `concurrency:` groups means overlapping deploys on rapid pushes can cause race conditions
- All 3 deploy workflows push `:latest` at build time, then rollback uses `:latest` — deploying the same broken image
- No Dependabot means no automated dependency update PRs
- E2E failures on main don't block the `test-summary` gate

**Alternatives evaluated:**
- Tag-only references (`@v4`) — mutable, supply chain risk; SHA pinning is GitHub's recommended practice
- Renovate instead of Dependabot — heavier setup, external service; Dependabot is native to GitHub
- Repository variables for Azure names — adds Settings dependency, reduces readability; accept as-is for single-environment project
- `cancel-in-progress: true` on deploys — could cancel mid-push to ACR, leaving registry inconsistent; queue instead
- Production approval gates — single developer; `environment: 'Production'` already declared; can enable GitHub environment protection rules without workflow changes

**Accepted risks:** Hardcoded Azure resource names (low, rarely change), CMS has no test gate (managed CMS), E2E tests skip PRs (by design), fixed healthcheck delays (works reliably), `fail_ci_if_error: false` on Codecov (Jest enforces thresholds), Azure CLI via curl-pipe-bash (ephemeral runner).

**Implementation plan:** Deleted per governance (1 phase after completion).

---

## Decision 51: Phase 7.3 — Frontend Code & Security Hardening

**Date:** 2026-03-18
**Category:** Security

**Decision:** Five hardening tracks for the frontend codebase: (1) sanitize CMS rich text HTML via `isomorphic-dompurify` before `dangerouslySetInnerHTML` (3 sites in `lib/cms/components.tsx`); (2) harden CSP — add `base-uri 'self'`, `object-src 'none'`, whitelist `img-src` to known domains, test removing `'unsafe-eval'`; (3) add 429 rate-limit error handling in `lib/api/error.ts`; (4) add `eslint-plugin-security` for static security analysis; (5) verify production source maps are not exposed.

**Why:** The Phase 7.3 audit found the frontend in strong shape (strict TypeScript, rehype-sanitize for markdown, proper security headers, secure Auth.js OIDC, no secrets in git). These five MEDIUM findings add defense-in-depth layers:
- CMS HTML is rendered via `dangerouslySetInnerHTML` without sanitization — if a CMS admin account is compromised or Strapi has a vulnerability, XSS is possible
- CSP includes `'unsafe-eval'` (may not be needed in Next.js 16) and allows all HTTPS images
- API client gives generic errors for rate-limited requests instead of user-friendly guidance
- No ESLint security rules to catch dangerous patterns at lint time
- Source maps may expose code structure in production

**Alternatives evaluated:**
- `sanitize-html` instead of `isomorphic-dompurify` — less battle-tested, smaller community
- Nonce-based CSP to eliminate `'unsafe-inline'` — too complex for current phase (requires Next.js middleware + nonce propagation); deferred to Phase 8+
- `eslint-plugin-no-unsanitized` (Mozilla) — more narrow, less community adoption than `eslint-plugin-security`
- Auth `middleware.ts` for centralized routing — per-page `auth()` + `redirect()` is equally secure; middleware adds complexity without security benefit

**Accepted risks:** `'unsafe-inline'` in CSP (Next.js requirement), no `middleware.ts` auth centralization, `console.warn` in mappers (non-sensitive, useful for debugging), CMS `href` values without `javascript:` URL filtering (same trust boundary as CMS HTML content).

**Implementation plan:** Deleted per governance (1 phase after completion).

---

## Decision 50: Adopt Azure Bicep for Declarative Infrastructure as Code

**Date:** 2026-03-17
**Category:** Infrastructure

**Decision:** Manage all Azure infrastructure via declarative Bicep templates in `infrastructure/` with CI validation on every PR (`az bicep build`), always deploying with `--mode Incremental`. Concurrently, extracted cross-cutting service registrations (AppInsights, MemoryCache, TimeProvider, HealthChecks, RateLimiter) from `Program.cs` into `AddInfrastructure()` in the `AIEnterprisePatterns.Infrastructure` project.

**Why:** The previous approach was entirely imperative (PowerShell scripts). This meant:
- No drift detection — manual changes to Azure were invisible until next deploy
- No what-if preview — impossible to audit changes before applying
- No CI validation — broken infrastructure config was only caught at deploy time
- Messy `deployment/` folder — 7+ redundant/superseded scripts and plaintext credential files on disk

Bicep provides: drift detection via what-if, CI validation via local compile (`az bicep build` needs no Azure login), readable declarative syntax vs verbose ARM JSON, and a clear module structure that mirrors the resource hierarchy.

The `AddInfrastructure()` refactor moves 5 cross-cutting concerns out of the composition root into the Infrastructure layer, aligning with Clean Architecture: infrastructure configuration belongs in the Infrastructure project, not in the API startup file.

**Alternatives evaluated:**
- **Terraform**: Requires external state file management (S3/Azure Blob backend), separate CLI binary, HCL learning curve. Bicep is native to Azure, requires no state file, and integrates directly with ARM.
- **ARM JSON**: Identical capability to Bicep but verbose, non-readable, no comments, no type safety. Bicep compiles to ARM JSON — it's strictly better.
- **Keep PowerShell scripts**: No validation, no drift detection, no what-if. Scripts had already accumulated cruft (7 one-time fix scripts, redundant variants). Not sustainable as infrastructure grows.
- **Pulumi**: General-purpose IaC with TypeScript/Python. Powerful but adds state management complexity similar to Terraform. Overkill for a single-environment deployment.

**Key implementation details:**
- `deploy.ps1` enforces `--mode Incremental` to prevent accidental resource deletion
- Image tags are **not** managed by Bicep — CI updates them via `az containerapp update --image`
- Secrets are **never** in Bicep or parameter files — Key Vault references only
- Role assignments for KV Secrets User are in `main.bicep` (not `keyvault.bicep`) to avoid circular module dependencies

---

## Decision 49: CMS Query Test Strategy — Mock `global.fetch` Instead of Named Exports

**Date:** 2026-03-04
**Category:** Testing

**Decision:** Unit tests for `lib/cms/queries.ts` mock `global.fetch` (the same pattern used in `lib/api/__tests__/client.test.ts`) rather than attempting to mock `fetchStrapi` directly.

**Why:** `fetchStrapi` is a named export from `lib/cms/client.ts`. SWC (the Jest transform used by Next.js) compiles ES module named exports to `Object.defineProperty` with `configurable: false`. This makes three standard mocking approaches non-viable:
- `jest.spyOn(cmsClient, 'fetchStrapi')` → throws "Cannot redefine property"
- `jest.mock('../client')` auto-mock → `jest.isMockFunction(fetchStrapi)` returns `false` (SWC doesn't auto-create jest.fn() for async named exports)
- `jest.mock('../client', factory)` with a factory → the test file receives the mocked module, but `queries.ts` (which imports `./client` from a different relative path) still binds to the real `fetchStrapi` at module resolution time

Mocking `global.fetch` bypasses the non-configurable export problem entirely because `global.fetch` is a plain property of `globalThis`, always writable. It also tests the full pipeline: `getXxx()` → `safeFetch()` → `fetchStrapi()` → `fetch()`, exercising the Strapi 5 response unwrapping (`json.data`) and `CmsUnavailableError` creation on network/HTTP errors.

**Test coverage:** 36 tests across 10 query functions. Each function tests: happy path (returns Strapi data), network error fallback, HTTP error fallback (where applicable), and ISR revalidation TTL value.

**ISR TTL values confirmed:** GLOBAL=600s, PAGE=300s, STATIC=3600s, LABELS=3600s.

**Alternatives evaluated:**
- `jest.spyOn` — fails with non-configurable export (see above)
- `jest.mock` auto-mock — doesn't create jest.fn() for SWC-compiled async functions
- Manual `__mocks__/client.ts` file — would work but adds maintenance overhead; `global.fetch` mock is simpler and consistent with existing test patterns
- `jest.mock` factory with `globalThis` shared state — factory runs before variable declarations (SWC hoisting), making state sharing unreliable even with `globalThis`

---

## Decision 48: Docker Compose Profiles and WSL2 Memory Cap for Local CMS Containers

**Date:** 2026-03-03
**Category:** Infrastructure / Developer Experience

**Decision:** Assign MySQL and Strapi to a `cms` Docker Compose profile so they do not start by default. Cap WSL2 at 2.5 GB via `~/.wslconfig`. Apply per-container memory limits and MySQL/Node.js tuning in `docker-compose.yml`.

**Why:** MySQL (8.0) and Strapi (Node.js dev server) together consumed ~1–1.5 GB RAM even when idle. WSL2 by default claims up to 50% of system RAM and does not release it, leaving the host with limited memory during normal development work when the CMS is not needed.

**Configuration applied:**
- `~/.wslconfig`: `memory=2560MB`, `swap=1GB`
- `docker-compose.yml`: `mem_limit` — sqlserver 1 GB, mysql 512 MB, strapi 512 MB
- MySQL: `--innodb-buffer-pool-size=64M --innodb-log-file-size=16M --max-connections=20`
- Strapi: `NODE_OPTIONS=--max-old-space-size=384`
- CMS profile: `docker compose --profile cms up -d` to start MySQL + Strapi; plain `docker compose up -d` starts SQL Server only

**Alternatives evaluated:**
- Reducing buffer pool inside running containers (no persistence across restarts; harder to manage)
- Running MySQL/Strapi natively without Docker (lose isolation and healthcheck dependency chain)
- Increasing WSL2 swap instead of capping RAM (swap is slow; doesn't free host RAM for Windows)

---

## Decision 47: Use `expect(page).toHaveURL()` for Playwright Soft-Navigation Assertions

**Date:** 2026-03-03
**Title:** Assert URL Changes with `toHaveURL` Not `waitForURL` for Next.js App Router Navigation
**Category:** Testing / E2E

### Problem

E2E tests for filter interactions (tag selection, category filter) used `page.waitForURL(pattern, { timeout })` to wait for URL updates after clicking filter checkboxes. Next.js App Router uses `history.pushState` for client-side navigation, which does not fire the Playwright navigation `load` event that `waitForURL` awaits by default. This caused consistent `TimeoutError` failures in WebKit (which is stricter about navigation event semantics) and intermittent failures in Chromium.

A secondary issue: when matching comma-separated values in query params, WebKit URL-encodes `,` as `%2C` while Chromium preserves the literal comma. A regex like `/tags=[^&]*,/` matched Chromium's `tags=A,B` but never matched WebKit's `tags=A%2CB`.

### Decision

1. Replace all `page.waitForURL(pattern)` calls in `e2e/critical-flows.spec.ts` with `expect(page).toHaveURL(pattern)` for soft-navigation URL checks. `toHaveURL` uses Playwright's assertion retry loop and polls the current URL — it is not tied to navigation lifecycle events.

2. Write regex patterns for comma-separated query params as `/param=[^&]*(%2C|,)/i` to accept both literal commas (Chromium) and percent-encoded commas (WebKit).

3. Add an explicit URL sync assertion after the second tag click to ensure `FilterPanel` has re-rendered with `selectedTags.length >= 2` before asserting on elements that only appear in that state.

### Rationale

- `toHaveURL` is the idiomatic Playwright approach for soft-navigation — it is documented as the preferred way to check URL state without coupling to navigation lifecycle events.
- WebKit's stricter navigation event model is the root cause of the browser-specific failures; the fix is browser-agnostic.
- The explicit URL sync before element assertions eliminates the race condition between the URL update and the conditional render of the Any/All toggle.

### Alternatives Evaluated

- **Increase `waitForURL` timeout** — rejected: the URL was already in the final state; the timeout was never the bottleneck. Increasing it would hide the real failure.
- **Add `waitUntil: 'commit'` to `waitForURL`** — partially effective but not documented as stable across browsers; `toHaveURL` is the canonical solution.

---

## Decision 46: Parallelize Independent Server Component Data Fetches for LCP

**Date:** 2026-03-03
**Title:** Use Promise.all for Independent Server-Side Fetches to Eliminate Waterfall Latency
**Category:** Performance / Frontend Architecture

### Problem

`app/patterns/page.tsx` made two sequential `getPatterns` API calls: the first fetched the paginated result for the current page; the second fetched all 100 patterns to populate filter panel category and tag options. Because each was `await`-ed independently, the total server response time was `T1 + T2` (typically 1–2s in CI where requests cross the internet to Azure). This was the primary driver of LCP exceeding the 2500ms threshold.

### Decision

Replace sequential awaits with `Promise.all` so all independent server-side fetches start in parallel:

```ts
const [fetchedResult, allPatterns] = await Promise.all([
  getPatterns({ page, pageSize: 9, ...filters }),
  getPatterns({ pageSize: 100 }),           // for filter panel options
])
```

The CMS `getPatternListingLabels()` call had already been started as a parallel promise earlier in the function; `await labelsPromise` runs after `Promise.all` and typically resolves immediately (CMS falls back fast in CI).

Additionally added `warmupRuns: 1` to `lighthouserc.yml` to eliminate the cold-start outlier (first Lighthouse run ~40% slower due to Node.js JIT and Next.js fetch-cache warming).

### Rationale

- Halves effective server response time: `max(T1, T2)` instead of `T1 + T2`.
- All three fetches (paginated result, all patterns, CMS labels) are fully independent — no data dependency between them.
- No error-handling regression: both `getPatterns` calls remain inside the existing `try/catch`; if either fails, the catch returns empty state (same behaviour as before).
- `warmupRuns: 1` removes a systematic measurement bias in CI without changing the LCP threshold, preserving the real performance gate.

### Alternatives Evaluated

- **Raise the LCP threshold** — rejected: masking CI environment variance while the actual performance issue (sequential fetches) remained.
- **Cache the "all patterns" result** — considered but redundant: ISR (120s revalidation) already caches server responses; parallelisation is both simpler and more impactful.

---

## Decision 45: Phase 6.6 — CMS Pattern UI Labels via Server-Side Prop Threading

**Date:** 2026-03-03
**Title:** Thread CMS Pattern UI Labels from Server Pages to Client Components via Props
**Category:** Frontend / CMS Integration / Architecture

### Problem

Patterns listing, detail, and form pages contained 70+ hardcoded UI label strings spread across 13 components (SearchBar, SortSelector, FilterPanel, FilterSheet, DateRangeFilter, SavedSearches, RecentlyViewedSidebar, VotingButton, Breadcrumb, PatternForm, PatternActions, RelatedPatternsSection, EmptyState/Pagination). These could not be changed without a code deployment.

### Decision

Fetch CMS label Single Types (`pattern-listing-labels`, `pattern-detail-labels`, `pattern-form-labels`) at the server page level and pass labels down to child components as optional props. Each component retains hardcoded defaults matching the previous values so no behaviour changes occur when CMS is unavailable.

**Architecture:**
- Server pages (`app/patterns/page.tsx`, `app/patterns/[slug]/page.tsx`, `app/patterns/new/page.tsx`, `app/patterns/[slug]/edit/page.tsx`) call `getPatternListingLabels()`, `getPatternDetailLabels()`, `getPatternFormLabels()` — already fetched in parallel with API data.
- `FilterPanel` and `FilterSheet` accept `labels?: CmsPatternListingLabels` (full labels object). FilterPanel threads sub-labels to `DateRangeFilter`, `SavedSearches`, `RecentlyViewedSidebar`.
- Leaf components (`SearchBar`, `SortSelector`, `DateRangeFilter`, `SavedSearches`, `RecentlyViewedSidebar`, `VotingButton`, `Breadcrumb`) accept individual optional label props with sensible defaults.
- Template strings use `{placeholder}` replacement (e.g. `voteAriaTemplate.replace('{count}', voteCount)`) so editors can reword without understanding code.
- `CmsPatternListingLabels` type is imported directly in `FilterPanel`/`FilterSheet` to avoid creating a parallel duplicate type.

### Rationale

- **Server-side fetch** maintains ISR benefits: labels are embedded in HTML at build time, not fetched client-side.
- **Prop threading** keeps client components pure (no CMS imports, no `useEffect` fetches). The 1-hour ISR TTL for labels means changes appear within 1 hour without a redeploy.
- **Defaults = current hardcoded values** ensures zero risk: if Strapi is unreachable, the app renders identically to before this phase.
- **Full labels object on FilterPanel/FilterSheet** avoids 20+ individual prop declarations per component; CMS type reuse eliminates duplication.

### Alternatives Evaluated

- **React Context for labels** — rejected: adds unnecessary complexity for a static prop threading pattern; context crosses RSC/Client boundary unnecessarily.
- **Client-side fetch in each component** — rejected: breaks ISR, adds waterfall fetching, creates loading states for labels.
- **Hardcoded strings remain** — rejected: defeats the CMS content management goal.

### sortOptions fallback fix

The `queries.ts` fallback for `pattern-listing-labels.sortOptions` contained incorrect values (`'newest'`, `'popular'`, `'title'`) that did not match the backend `SortOption` enum (`'recent'`, `'votes'`, `'alphabetical'`). Fixed to use correct values.

---

## Decision 44: Phase 6.5 — CMS Error Page Labels via Root Layout Context

**Date:** 2026-03-03
**Title:** Inject CMS Error Page Content via CmsErrorPageProvider Context (Root Layout → error.tsx)
**Category:** Frontend / CMS Integration / Error Handling

### Problem

`app/error.tsx` is the global Next.js error boundary and **must** be a Client Component (Next.js requirement for error boundaries). This makes it impossible to call server-side CMS query functions (`getErrorPage()`) directly inside it. The file previously displayed fully hardcoded strings ("Something went wrong", "Try again", "Go home").

### Decision

Inject CMS error page labels at the root layout (server component) and make them available to `error.tsx` via a React Context:

1. **`components/providers/CmsErrorPageProvider.tsx`** — new client context provider:
   - `CmsErrorPageContext` with defaults for all four label fields
   - `useCmsErrorPage()` hook consumed by `error.tsx`
   - `CmsErrorPageProvider` wraps children, merging CMS labels with defaults

2. **`app/layout.tsx`** — fetches `getErrorPage()` in parallel with `getGlobal()` using `Promise.all`; wraps children in `CmsErrorPageProvider`; also passes `global.siteName` to `Header`

3. **`app/error.tsx`** — uses `useCmsErrorPage()` instead of hardcoded strings; context default values (`createContext(DEFAULT)`) ensure the component renders correctly even if rendered outside the provider tree

4. **`components/shared/Logo.tsx`** — added optional `siteName` prop (default: `'AI Enterprise Patterns'`); `Header.tsx` receives and threads it through

### Why Context Over Alternatives

| Alternative | Rejected Because |
|-------------|-----------------|
| Server component wrapper around error.tsx | Next.js error boundaries must be Client Components — cannot be wrapped in a server fetch |
| Client-side `useEffect` fetch inside error.tsx | Fetches during error state are unreliable; adds latency; CMS unavailability worsens the user experience when something is already broken |
| Hardcoded strings forever | Violates the CMS-first strategy established in Phase 5.5; content editors cannot update error messages |
| `global.d.ts` window property injection | Anti-pattern; bypasses React's data flow model |

### Fallback Strategy

`createContext(DEFAULT)` ensures that if `error.tsx` is somehow rendered outside the provider tree (e.g., in tests or `global-error.tsx`), it still displays sensible hardcoded defaults without throwing. This makes the error boundary itself fail-safe.

### Tests

- 4 new tests added for `CmsErrorPageProvider`: default labels, CMS labels, partial override, outside-provider default
- Test count: 350 → 354; all four coverage metrics remain ≥ 70%

---

## Decision 43: Phase 6.4 — Testing Infrastructure (Lighthouse CI, Chromatic, Cross-Browser Playwright)

**Date:** 2026-03-03
**Title:** Add Lighthouse CI Performance Gates, Chromatic Visual Regression, and Playwright Cross-Browser Matrix
**Category:** Testing / CI/CD / Quality

### Decision

Implement three additional testing layers to block deployments on quality regressions:

1. **Lighthouse CI (`@lhci/cli`)** — performance assertion gate in `frontend-container-deploy.yml`
2. **Chromatic** — visual regression testing against the existing 38 Storybook stories
3. **Playwright cross-browser matrix** — run all E2E tests against Chromium, Firefox, and WebKit in `test.yml`

### Why

Phase 6.3 established a comprehensive Storybook catalog (38 stories). Chromatic directly integrates with Storybook — no additional story authoring needed. The existing E2E suite covers critical user flows; extending to Firefox and WebKit proves that the ARIA-based selectors and browser-agnostic test strategies work beyond Chromium. Lighthouse CI catches performance regressions before they reach production users.

### Architecture

**Lighthouse CI job** (in `frontend-container-deploy.yml`):
- Runs in parallel with `build-and-push` after `run-tests`
- Builds Next.js with production API URL (`LHCI_API_BASE_URL` secret)
- Starts Next.js server, runs `npx lhci autorun` against `/` and `/patterns`
- Thresholds: LCP < 2500 ms, FCP < 1800 ms, TTI < 5000 ms, Performance ≥ 0.80
- Results uploaded to `temporary-public-storage`; optional GitHub status check via `LHCI_GITHUB_APP_TOKEN`

**Chromatic job** (in `frontend-container-deploy.yml`):
- Runs in parallel with `build-and-push` and `lhci` after `run-tests`
- Uses `fetch-depth: 0` so Chromatic can identify baseline commits
- `--exit-zero-on-changes` set initially to allow baseline approval in dashboard
- `continue-on-error: true` until `CHROMATIC_PROJECT_TOKEN` is configured; remove both flags to harden into a gate

**Playwright matrix** (in `test.yml`):
- Converts single `e2e-tests` job to a `strategy.matrix` with `browser: [chromium, firefox, webkit]`
- `fail-fast: false` — all three browsers run even if one fails, providing full cross-browser visibility
- Each browser job installs its own browser via `npx playwright install --with-deps ${{ matrix.browser }}`
- Each browser uploads its own report artifact (`playwright-report-{browser}`)
- `playwright.config.ts` updated to enable all three browser projects

**Deploy gate**:
- `deploy` job now requires `needs: [build-and-push, lhci, chromatic]`
- Once Chromatic token is configured and `continue-on-error` removed, all three block deployment

### Alternatives Evaluated

| Alternative | Rejected Because |
|-------------|-----------------|
| Shared build artifact for E2E matrix | Complex artifact passing between jobs; each job needs running processes (backend+frontend) that can't be shared — simple per-browser setup is more reliable |
| Percy for visual regression | Requires separate Storybook integration; Chromatic has native Storybook support and simpler setup |
| Single "all browsers" Playwright job | Sequential browser runs in one job are slower and harder to parallelize; matrix approach shows per-browser failure clearly |
| Running LHCI against production URL | Coupling deploy gate to production availability; build+start approach is self-contained |

### Required GitHub Secrets

| Secret | Used By | Notes |
|--------|---------|-------|
| `LHCI_API_BASE_URL` | `lhci` job — Next.js build | Production backend URL; omit to test UI shell only |
| `LHCI_GITHUB_APP_TOKEN` | `lhci` job — GitHub status check | Optional; Lighthouse runs without it |
| `CHROMATIC_PROJECT_TOKEN` | `chromatic` job | Required; from https://www.chromatic.com |

---

## Decision 42: Phase 6.3 — Documentation Reuse & Storybook UI Catalog

**Date:** 2026-03-02
**Title:** Four-Pillar Documentation and Component Reuse Infrastructure
**Category:** Documentation / Developer Experience / Testing

### Decision

Implement four interconnected documentation layers as Phase 6.3:

1. **API Reference** (`documentation/api/`) — structured endpoint documentation with request/response examples
2. **CMS Component Reference** (`documentation/cms-components/`) — field tables, dependency diagram, and "Used By" maps for all 26 Strapi components
3. **Storybook UI Catalog** — 38 stories colocated with components, `@storybook/nextjs` with a11y and themes addons
4. **Governance** — `GOVERNANCE.md`, `DOCUMENTATION_INDEX.md`, and `CLAUDE.md` updates to enforce single-source-of-truth

### Why

Prior to 6.3, documentation was fragmented across ad-hoc files with no enforcement of where content belongs. The CMS component model (26 components across 4 namespaces) had no machine-readable reference. API endpoints were scattered in architecture docs rather than a dedicated reference. Without Storybook, component development required running the full Next.js app.

### Architecture

- Storybook stories are **colocated** (`*.stories.tsx` alongside component files) — easier to find and maintain
- Shared fixtures in `.storybook/fixtures.ts` — single source for mock data across stories
- `next-auth/react` mock in `.storybook/mocks/` — stories for authenticated components work without Entra
- CMS dependency diagram (Mermaid, diagram #14) embedded in `COMPONENT_INDEX.md`
- Governance rules specify exactly which folder owns each content type — eliminates duplication decisions

---

## Decision 41: Phase 6.2 — Related Patterns Backend Endpoint

**Date:** 2026-02-27
**Title:** Move Related Patterns Logic from Client-Side to Backend API Endpoint
**Category:** Architecture / Performance

### Decision Details

Replaced the MVP client-side "fetch 100 patterns + compute related" approach with a dedicated backend endpoint `GET /api/patterns/{slug}/related`.

**Algorithm (category-first, tag-fallback, vote-sorted):**
1. Look up the current pattern by slug (published only)
2. Query published patterns excluding the current slug
3. Filter: same category OR any overlapping tag
4. Order: same-category patterns first (CASE WHEN), then by VoteCount DESC
5. Take limit (default 3)

**Caching:** `IMemoryCache` with key `related_patterns_{slug}`, 5-minute TTL (same as featured/trending). No explicit invalidation on vote — 5-min staleness is acceptable for a "you might also like" sidebar.

**Changes:**
- `IPatternRepository` + `PatternRepository`: `GetRelatedPatternsAsync(slug, limit=3, ct)` — two EF Core queries (lookup current, then query related); `AsNoTracking()` for read-only
- `IPatternService` + `PatternService`: `GetRelatedPatternsAsync(slug, limit=3, ct)` with cache
- `PatternsController`: `GET /patterns/{slug}/related` → `IEnumerable<PatternListDto>`
- `lib/api/patterns.ts`: `getRelatedPatterns(slug)` with graceful `[]` fallback on error
- `app/patterns/[slug]/page.tsx`: replaced `getPatterns({ pageSize: 100 }) + client-side compute` with parallel `Promise.all` including `getRelatedPatterns(slug)`
- Deleted: `lib/data/relatedPatterns.ts`, `lib/data/filterAndSort.ts`, their test files

**Why not keep client-side?**
- Fetching 100 patterns on every detail page view is O(n) and doesn't scale
- Backend can index/cache the query; frontend gets 3 items in one focused request
- Ranking logic belongs with the data layer

**Tests added:** 6 repository tests, 3 service tests, 2 integration tests (+11 backend total → 105)
**Frontend tests:** 341 (deleted 50 obsolete client-side tests for relatedPatterns + filterAndSort)

---

## Decision 40: Phase 6.1 — Dark Mode, Animations, Skeleton Loaders, next/image

**Date:** 2026-02-27
**Title:** UI/UX Improvements — Dark Mode Toggle, CSS Animations, Enhanced Skeleton Loaders, next/image Setup
**Category:** Frontend / UX

### Decision Details

Four UI/UX improvements implemented as Phase 6.1:

**1. Dark Mode (system preference detection)**
- `ThemeProvider` client component manages a three-way toggle: `system | light | dark`
- On mount: reads `localStorage('theme')`; falls back to `window.matchMedia('prefers-color-scheme: dark')`
- Applies `dark` class to `<html>` via `document.documentElement.classList.toggle('dark', ...)`
- In `system` mode, registers a `change` listener on the media query so the theme tracks the OS in real time
- Inline `<script>` in `<head>` applies the class synchronously before first paint → no flash of wrong theme
- `suppressHydrationWarning` on `<html>` suppresses the React hydration mismatch warning (class differs server/client)
- `ThemeToggle` button in `Header.tsx` is visible on both mobile and desktop; cycles system → light → dark → system
- Tailwind `darkMode: ["class"]` was already configured; all CSS variables for `.dark` were already defined

**2. CSS Animations / Micro-interactions**
- Added `fade-in` (opacity 0→1, 0.4s ease-out) and `slide-up` (opacity+translateY, 0.5s ease-out) keyframes to `tailwind.config.ts`
- Applied `animate-slide-up` to the Hero content block on the home page
- Applied `animate-fade-in` to FeaturedPatterns and StatsSection sections
- Added `hover:-translate-y-0.5` + `duration-200` to PatternCard for a subtle lift on hover
- Added `scroll-behavior: smooth` to `html` in `globals.css`

**3. Skeleton Loaders (enhanced)**
- Created `components/ui/SkeletonCard.tsx`: a card-shaped skeleton matching PatternCard dimensions (category badge, title lines, description lines, tags, footer)
- Updated `app/loading.tsx` and `app/patterns/loading.tsx` to use `SkeletonCard` instead of plain filled rectangles
- Hero skeleton in `app/loading.tsx` now matches the actual Hero layout (centered text + two CTA buttons)

**4. next/image Setup**
- Added `images.remotePatterns` to `next.config.mjs`: Strapi Azure Blob Storage (`staipatternsmedia.blob.core.windows.net`) + localhost:1337 for local dev
- Added `img` renderer to `PatternContent.tsx`: uses `next/image` with `fill` layout for Strapi/local images; falls back to lazy-loaded native `<img>` for external URLs

### Rationale
- Dark mode is a standard user expectation; the CSS variable infrastructure was already in place
- Anti-flash inline script is the industry standard pattern (used by next-themes, Radix Themes, etc.) to prevent FOUC
- Skeleton loaders matching component structure reduce layout shift during hydration
- next/image remotePatterns establishes the infrastructure for CMS media in later phases

### Alternatives Evaluated
- **next-themes package** — not used; ThemeProvider from scratch is simpler for three-state cycle, avoids extra dependency, and gives full control
- **Framer Motion for animations** — not used; Tailwind keyframes are sufficient for simple fade/slide, zero runtime cost
- **next/image with `unoptimized` for all markdown images** — rejected; opted for domain-specific optimization + native img fallback to avoid incorrect behaviour for external URLs

### Files Changed
- `tailwind.config.ts` — fade-in/slide-up keyframes + animations
- `app/globals.css` — scroll-behavior: smooth
- `components/providers/ThemeProvider.tsx` — new
- `components/layout/ThemeToggle.tsx` — new
- `components/ui/SkeletonCard.tsx` — new
- `app/layout.tsx` — ThemeProvider, suppressHydrationWarning, anti-flash script
- `components/layout/Header.tsx` — ThemeToggle
- `app/loading.tsx`, `app/patterns/loading.tsx` — SkeletonCard
- `components/home/PatternCard.tsx` — hover lift
- `components/home/Hero.tsx`, `FeaturedPatterns.tsx`, `StatsSection.tsx` — animations
- `next.config.mjs` — images.remotePatterns
- `components/patterns/details/PatternContent.tsx` — img renderer with next/image

---

## Decision 30: Strapi On-Demand Revalidation Webhook

**Date:** 2026-02-26
**Title:** Strapi → Next.js On-Demand ISR Revalidation via Webhook
**Category:** CMS / Performance

### Decision Details
Added a Next.js POST route handler at `app/api/revalidate/route.ts` that Strapi calls whenever CMS content is published, updated, unpublished, or deleted. The handler calls `revalidatePath()` to immediately purge the ISR cache for the affected pages rather than waiting for the TTL to expire.

**Content-type → path mapping:**
- `global` → `revalidatePath('/', 'layout')` — purges all pages (nav/footer affect every route)
- `home-page` → `/`
- `about-page` → `/about`
- `docs-page` → `/docs`
- `login-page` → `/login`
- `not-found-page`, `error-page` → `/`
- `pattern-*-labels` → `revalidatePath('/patterns', 'layout')` — purges listing, detail, and form pages

**Security:** A `REVALIDATE_SECRET` environment variable is required as a query param (`?secret=...`) to prevent unauthorized cache busting. Returns 401 if missing or wrong.

### Rationale
- ISR TTLs (5–60 min) are acceptable for low-traffic sites but introduce unnecessary staleness after a content editor publishes a change
- On-demand revalidation brings content live immediately without a full redeploy
- Webhook approach keeps CMS and frontend decoupled — Strapi only needs the URL + secret

### Strapi Webhook Setup
Settings → Webhooks → Create webhook:
- URL: `https://<domain>/api/revalidate?secret=<REVALIDATE_SECRET>`
- Events: Entry (Create, Update, Publish, Unpublish, Delete)

### Alternatives Evaluated
- **Time-based ISR only** — simple but up to 60 min delay after publish
- **Full redeploy on content change** — instant but overkill; breaks scale-to-zero cost model

---

## Decision 29: Azure SQL — Storage Reduced to 1 GB & Auto-Pause Shortened to 15 Minutes

**Date:** 2026-02-23
**Title:** Further Reduce Azure SQL Storage (2 GB → 1 GB) and Auto-Pause Delay (60 min → 15 min)
**Category:** Infrastructure / Cost Optimisation

### Decision Details
Two configuration changes applied to the production Azure SQL Serverless database (`sqldb-aipatterns-prod`) via the Azure Portal:

1. **Storage: 2 GB → 1 GB** — the previous reduction (Decision 13) went from 32 GB to 2 GB. With actual data still well under 100 MB, 1 GB is more than sufficient and uses the Azure General Purpose minimum.
2. **Auto-pause delay: 60 min → 15 min** — the database now pauses after just 15 minutes of inactivity instead of 60, significantly reducing billed compute time for a low-traffic application.

### Rationale
- The application has 6 patterns, 18 tags, and minimal text content — nowhere near 1 GB
- Most traffic is sporadic; a 60-minute auto-pause window kept the database running (and billing) long after the last request
- 15 minutes is the minimum auto-pause delay Azure allows, maximising cost savings for bursty/low-traffic workloads

### Savings
| | Before | After |
|---|---|---|
| Provisioned storage | 2 GB | 1 GB |
| Monthly storage cost | ~$0.23 | ~$0.12 |
| Auto-pause delay | 60 min | 15 min |
| Estimated active hours/day | ~4-6h | ~1-2h |

The auto-pause change has the larger impact — reducing billed compute hours by up to 75% for idle periods.

### Pros
- Further cost reduction with zero functional impact
- 15-minute pause means the database sleeps sooner during low-traffic periods
- Storage and auto-pause can be increased again at any time if needed

### Cons
- More frequent cold starts (~1-2s resume time) when the database has been paused
- If traffic patterns change to sustained load, the frequent pause/resume cycle could cause intermittent latency

### Alternatives Evaluated
1. **Keep 2 GB / 60 min** (rejected) — unnecessarily over-provisioned for current workload
2. **Disable auto-pause entirely** (rejected) — would increase cost significantly for a low-traffic app

---

## Decision 28: Strapi 5 Headless CMS for Static Content Management

**Date:** 2026-02-20
**Title:** Adopt Strapi 5 as Headless CMS for All Static Frontend Content
**Category:** Architecture / Content Management

### Decision Details

Adopt Strapi 5 as a headless CMS to manage all static frontend content (300+ items across 28 components and 10 pages). The content model uses Dynamic Zones for flexible page composition, 10 Single Types for pages and UI labels, and 4 component categories (seo, layout, sections, shared) with 15+ reusable Dynamic Zone blocks.

### Content Model Summary

**Single Types (10):**
- `global` — site-wide settings (navigation, footer, sign-in/out labels, SEO defaults)
- `home-page`, `about-page`, `docs-page` — page content with Dynamic Zones for flexible layouts
- `login-page`, `not-found-page`, `error-page` — fixed-structure page content
- `pattern-listing-labels`, `pattern-detail-labels`, `pattern-form-labels` — UI string labels

**Component Categories (4):**
- `seo/` — metadata component reused on every page
- `layout/` — nav-link, cta-button, footer-config
- `sections/` — 15 Dynamic Zone blocks (hero, cta-banner, stats-bar, feature-grid, tech-stack, doc-section, api-reference, etc.)
- `shared/` — atomic components (text-item, stat-item, feature-card, key-value, etc.)

### Infrastructure

- **Database:** Azure Database for MySQL Flexible Server (B1ms Burstable, **20 GiB storage**, auto-grow/auto-IO disabled — see Decision 39)
- **Hosting:** Azure Container App for Strapi (scale-to-zero, ~$5-10/month)
- **Media:** Azure Blob Storage (~$0.02/month) via `@strapi/provider-upload-azure-storage`
- **Total cost:** ~$23-28/month (MySQL ~$13/mo + Container App ~$5-10/mo + Storage ~$0.02/mo)

### Frontend Integration Pattern

- Server-side fetch in Server Components → pass CMS data as props to client components
- ISR caching: 5-60 min per content type (global 10min, pages 5min, labels 1hr)
- Fallback to hardcoded defaults when Strapi is unreachable
- Dynamic Zone renderer maps Strapi `__component` field → React components

### Rationale

- SRS already specifies Strapi CMS integration (Phase 3.2, Section 4.4)
- Enables non-developer content editing without code deployments
- Content versioning and draft/publish workflows built into Strapi
- Future i18n readiness (Phase 8.1) — Strapi has native i18n plugin
- Dynamic Zones allow content editors to compose pages from reusable blocks

### Pros
- **Non-developer friendly**: Visual admin panel for content editing
- **Flexible layouts**: Dynamic Zones allow page composition without code changes
- **Cost effective**: MySQL free tier + scale-to-zero Container App = ~$10-15/month
- **TypeScript support**: Strapi 5 has native TypeScript and auto-generated types
- **i18n ready**: Strapi i18n plugin provides multi-language content management
- **Incremental migration**: Fallback pattern ensures zero downtime during rollout

### Cons / Trade-offs
- **Added complexity**: New service to maintain (Strapi + MySQL + Blob Storage)
- **Build dependency**: Next.js ISR depends on Strapi being available at build time (mitigated by fallbacks)
- **Content model maintenance**: Schema changes require Strapi admin + frontend code updates
- **Additional infrastructure cost**: ~$10-15/month ongoing

### Alternatives Evaluated
1. **Contentful** — More expensive at scale ($489/month for Team tier), vendor lock-in
2. **Sanity** — Complex pricing model (pay per API call beyond free tier), less familiar to team
3. **Hardcoded with i18n JSON files** — No visual editing for non-developers, no draft/publish workflow
4. **WordPress headless** — Heavier infrastructure, PHP runtime, more attack surface
5. **Keep hardcoded** — No content governance, requires developer for every text change

### Reference
- Full implementation plan: `documentation/project/PHASE_CMS_IMPLEMENTATION_PLAN.md`
- Phase definition: `documentation/project/ROADMAP.md`

---

## Decision 27: E2E Authentication — Direct Session Injection Replaces Entra Browser Login

**Date:** 2026-02-20
**Title:** Use `@auth/core/jwt` `encode()` to Synthesise Auth.js Session Cookies in Playwright globalSetup
**Category:** Testing / Authentication

### Decision Details

Replaced the Playwright browser-based Entra CIAM login flow in `e2e/global.setup.ts` with direct session cookie creation using Auth.js's own `encode()` function from `@auth/core/jwt`.

New files/changes:
- **`e2e/auth-helpers.ts`** (new): `createSessionCookie({ roles })` encrypts a JWT payload with `AUTH_SECRET` using JWE A256CBC-HS512 (Auth.js's native format); `buildStorageState()` wraps the cookie in the Playwright storageState JSON structure.
- **`e2e/global.setup.ts`**: The entire 120-line headless Chromium login flow is replaced by a single `createSessionCookie()` call. Setup takes <100ms and requires only `AUTH_SECRET` (already a CI secret).
- **`e2e/authenticated-flows.spec.ts`**: Tests split into three describe blocks — `Unauthenticated guards` (always run), `Authenticated — UI` (always run, synthetic session sufficient), `Authenticated — API writes` (skipped by default; needs real Entra JWKS-valid token, opt-in via `E2E_API_WRITES=true`).

### Rationale

The browser-based approach failed in CI headless Chrome across 9 consecutive commits. Root cause: Entra External ID's "Stay signed in?" (KMSI) prompt renders inside a `position:fixed` container whose buttons have `offsetParent === null`. Playwright's visibility checks (waitFor, click) time out because they require a non-zero bounding box. Approaches tried:

1. Direct `click({ timeout: 25s })` — timed out before KMSI rendered
2. `waitForURL('/login')` then click — URL resolved before Entra's JS rendered KMSI content
3. `waitFor({ state: 'visible', timeout: 30s })` — still timed out (offsetParent===null)
4. `page.addInitScript()` with `MutationObserver` to auto-click "No" on DOM insertion — executed, but page navigated to `ciamlogin.com/login` 4 times without redirecting to `localhost:3000`

The fundamental issue is that Entra's hosted CIAM UI behaviour differs between headed/headless, local/CI, with/without existing Entra session cookies, and may change at any time. Testing authenticated flows via the real IdP in CI is inherently fragile.

### Pros
- **Deterministic**: same `AUTH_SECRET` always produces a valid session; no external network call
- **Fast**: <100ms vs 45-60s for the full OIDC browser flow
- **Stable**: does not depend on Entra UI structure, KMSI prompt behaviour, or network latency
- **Minimal CI surface**: only `AUTH_SECRET` required; no `E2E_ADMIN_EMAIL`/`PASSWORD` secrets needed for UI tests
- **Uses public Auth.js API**: `encode()` is the documented export from `@auth/core/jwt`

### Cons / Trade-offs
- The injected `accessToken` is a placeholder (`e2e-placeholder-token`), rejected by the ASP.NET Core API's JWKS validation. Tests that call protected API endpoints (POST/PUT/DELETE `/api/patterns`) must be skipped or run with `E2E_API_WRITES=true` and a real token.
- Does not exercise the actual Entra OIDC login flow — that flow is untested end-to-end in CI.

### Alternatives Evaluated
- **Persist a real token from a one-time manual login**: Would expire (Entra tokens last 1 hour); cannot be refreshed without user interaction in a CIAM tenant.
- **ROPC (Resource Owner Password Credential) grant**: Not supported by Entra External ID CIAM tenants.
- **Client credentials grant**: Gets an app token (no user context); doesn't carry user roles in the same way.
- **Test-only auth bypass endpoint**: Adds a `/api/auth/test-session` route gated by a secret; increases attack surface and adds application complexity.
- **Continue fixing the MutationObserver approach**: All viable dismissal strategies exhausted; the Entra CIAM UI is a moving target.

---

## Decision 26: Playwright E2E Test Locator — Role-Based Checkbox Selection

**Date:** 2026-02-20
**Title:** Use `getByRole('checkbox')` Instead of `getByLabel()` for Tag Checkboxes
**Category:** Testing

### Decision Details

Changed the E2E test locator for tag filter checkboxes from `page.getByLabel('Clean Architecture')` to `page.getByRole('checkbox', { name: 'Clean Architecture' })` in `e2e/critical-flows.spec.ts`.

### Rationale

Phase 5.4 accessibility work added `aria-label` attributes to `PatternCard` link elements (e.g., `aria-label="Clean Architecture with AI-Assisted Refactoring — Architecture"`). The `getByLabel()` locator matches any element with an `aria-label` containing the text, so it now matched both the tag checkbox label *and* the PatternCard link, causing a Playwright strict mode violation (`resolved to 2 elements`).

`getByRole('checkbox', { name: '...' })` is strictly scoped to checkbox-role elements, eliminating the ambiguity.

### Alternatives Evaluated
- Scope `getByLabel` to a container: more fragile, depends on DOM structure
- Use `getByTestId`: avoids semantic HTML; we don't use data-testid attributes
- Role-based query: semantically precise, resistant to future aria-label additions elsewhere

---

## Decision 25: Jest Coverage — Exclude Next.js Server Components from Collection

**Date:** 2026-02-20
**Title:** Exclude App Router Page/Layout Files from Jest Coverage Collection
**Category:** Testing

### Decision Details

Added exclusion patterns to `collectCoverageFrom` in `jest.config.mjs` for Next.js App Router server component files:

```javascript
'!app/**/page.tsx',
'!app/**/layout.tsx',
'!app/**/not-found.tsx',
'!app/api/**',
```

### Rationale

Next.js App Router `page.tsx` / `layout.tsx` files are `async` React Server Components. They cannot be imported or rendered in the jsdom environment used by Jest — doing so produces 0% coverage for every statement/function/line, which dragged the global coverage below the 70% threshold even though all testable client-side code was well-covered.

These files are covered by Playwright E2E tests instead, which run the full server + client stack. Including them in the Jest coverage metric is misleading and causes false CI failures.

### Alternatives Evaluated
- Lower the global threshold to ~65%: honest but hides genuine gaps in testable code
- Add unit tests for server components: not feasible — they require a real Next.js server runtime, not jsdom
- Per-file threshold overrides: more complex config with no material benefit

---

## Decision 24: Global `*:focus-visible` Override for Consistent Focus Rings

**Date:** 2026-02-19
**Title:** Global Focus-Visible Styles in globals.css
**Category:** Accessibility

### Decision Details

Added a global `*:focus-visible` rule to `app/globals.css` using the CSS custom property `--ring` (already defined by shadcn/ui) to provide a consistent focus ring across all interactive elements.

```css
*:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
  border-radius: 4px;
}
```

### Rationale

shadcn/ui components have their own focus styles via Tailwind utilities (e.g., `focus-visible:ring-2`). But non-shadcn interactive elements (native `<a>`, `<button>`, custom `<input>`) may rely on the browser's default `:focus` outline, which varies across browsers and themes.

A global `*:focus-visible` rule:
- Uses `focus-visible` (not `focus`), so it only applies during keyboard navigation — mouse clicks do not trigger the ring
- References `--ring` from the shadcn theme, so it respects light/dark mode
- Applies `border-radius: 4px` to avoid sharp corners on rounded elements

### Alternatives Evaluated

- **Per-component `focus-visible:ring` utility classes** — comprehensive but requires touching every component and easy to miss in future additions
- **Removing browser defaults via `outline: none` and relying on shadcn** — leaves non-shadcn elements without visible focus, a WCAG 2.1 AA violation
- **Global `*:focus` (not `focus-visible`)** — would show rings on mouse clicks too, visually distracting

---

## Decision 23: jest-axe for Automated Accessibility Regression Testing

**Date:** 2026-02-19
**Title:** jest-axe Integration for WCAG Violation Detection
**Category:** Testing

### Decision Details

Installed `jest-axe` and `@types/jest-axe` and extended Jest matchers in `jest.setup.ts` with `import 'jest-axe/extend-expect'`. Created four accessibility test files under `__tests__/accessibility/`:

- `patterns-listing.a11y.test.tsx` — FilterPanel, EmptyState, Pagination
- `pattern-detail.a11y.test.tsx` — VotingButton
- `pattern-form.a11y.test.tsx` — PatternForm (create mode)
- `layout.a11y.test.tsx` — PatternCard

Tests use `axe(container)` and assert with `expect(results).toHaveNoViolations()`.

### Rationale

jest-axe runs axe-core (the industry-standard accessibility engine) in the Jest/jsdom environment. It catches common WCAG violations (missing labels, invalid ARIA, contrast issues) automatically during unit test runs — before code reaches a browser or manual audit.

**Benefits:**
- Runs in CI with no browser required
- Catches regressions when components are modified
- Lightweight — no additional tooling or browser setup
- Integrates naturally with existing React Testing Library tests

### Limitations

- jsdom doesn't compute CSS, so colour-contrast violations are not detected
- Some complex ARIA patterns require a real browser (e.g., focus traps, live region timing)
- Supplements but does not replace manual keyboard testing

---

## Decision 22: AlertDialog for Delete Confirmation (Replacing window.confirm)

**Date:** 2026-02-19
**Title:** Accessible Delete Confirmation via shadcn AlertDialog
**Category:** Accessibility & UX

### Decision Details

Replaced the `window.confirm()` call in `PatternActions` with a shadcn `AlertDialog` component. The AlertDialog is always rendered in the component tree; the trigger button opens it.

```tsx
<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="destructive">Delete</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogTitle>Delete Pattern?</AlertDialogTitle>
    <AlertDialogDescription>This action cannot be undone.</AlertDialogDescription>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

### Rationale

`window.confirm()` is not accessible:
- The browser dialog is not announced by screen readers in a standard ARIA way
- Focus is not managed — no focus trap within the dialog
- Cannot be styled or localized
- Blocked by some browser popup-blockers in certain contexts

shadcn `AlertDialog` (built on Radix UI Dialog primitive) provides:
- **Focus trap** — keyboard users cannot Tab out of the dialog while it is open
- **Escape to close** — standard keyboard interaction
- **ARIA roles** — `role="alertdialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby` set automatically by Radix
- **Screen reader announcement** — dialog title and description are announced on open
- **Consistent styling** — matches the app's design system

### Test Impact

The 9 existing `PatternActions` tests were updated to mock `@/components/ui/alert-dialog` inline (same pattern as DropdownMenu — avoids Radix portal issues in jsdom). The mock always renders all dialog content, so confirm/cancel buttons are always accessible in tests without needing to open the dialog.

---

## Decision 21: localStorage for Recently Viewed and Saved Searches

**Date:** 2026-02-19
**Title:** Client-Side localStorage Persistence for User-Specific UX State
**Category:** Architecture & Data Storage

### Decision Details

`useRecentlyViewed` (max 5 entries, key `recently-viewed-patterns`) and `useSavedSearches` (max 10 entries, key `saved-searches`) both persist to `localStorage`. No backend API or database storage is involved.

Both hooks are SSR-safe: the initial state is always `[]` (empty array), and localStorage is only read after mount via `useEffect`, preventing hydration mismatches.

### Rationale

- **No backend needed** — recently viewed and saved search state is purely presentational and user-agent specific; it does not need to be shared across devices or users
- **Zero latency** — reads from localStorage are synchronous and instant; no network round-trip
- **No authentication required** — works for anonymous users too
- **Simple implementation** — no API endpoints, no database migrations, no backend changes

### Trade-offs

| Pro | Con |
|-----|-----|
| Zero infrastructure cost | Data lost if user clears browser storage |
| Works offline | Not synced across devices/browsers |
| Anonymous-user friendly | 5-10 MB localStorage quota shared across origin |
| No backend changes | No server-side search analytics |

### Limits

- Recently Viewed: **5 patterns** — prevents stale list becoming noise; most recent replaces oldest
- Saved Searches: **10 searches** — balances utility vs localStorage clutter; 11th would require deleting old (currently rejected with toast)

---

## Decision 20: Client-Side Search Suggestions (No Dedicated API Endpoint)

**Date:** 2026-02-19
**Title:** Search Autocomplete Sourced from Page Data, Not a Dedicated Endpoint
**Category:** Architecture & Performance

### Decision Details

The `useSearchSuggestions` hook generates autocomplete suggestions client-side by filtering the `allPatterns` and `allTags` arrays already passed as props to `SearchBar`. No new API endpoint was added.

- Debounce: 200ms
- Minimum query length: 2 characters
- Max suggestions: 8
- Priority: pattern title matches first, then tag matches
- Case-insensitive substring matching

### Rationale

The patterns listing page already fetches the full (paginated) pattern list on the server. Passing pattern titles and tag names to `SearchBar` via props costs negligible extra bytes (strings only — no content bodies). Client-side filtering avoids a network round-trip for every keystroke.

**Compared to a dedicated `/api/patterns/suggest?q=...` endpoint:**

| | Client-side | Dedicated endpoint |
|-|-------------|-------------------|
| Latency | ~0ms (local filter) | ~50-200ms (network) |
| Infrastructure | None | New controller action + caching |
| Freshness | Reflects current page data | Could be independently cached |
| Scale | Degrades with >1000 patterns | Stays fast at any scale |
| Offline | Works | Fails |

At the current scale (<100 patterns), client-side is the right trade-off. If the pattern library grows beyond ~500 entries, a dedicated suggest endpoint with server-side prefix indexing should be evaluated.

---

## Decision 19: Radix UI Select Mock Pattern for Jest

**Date:** 2026-02-19
**Title:** Context-Based Mock for Radix Select to Support id/value Wiring
**Category:** Testing

### Decision Details

Radix UI `Select` component cannot be used directly in jsdom tests because it relies on browser-native pointer event APIs. A context-based mock was created inside the `jest.mock()` factory:

```typescript
jest.mock('@/components/ui/select', () => {
  const React = require('react')
  const SelectCtx = React.createContext<{ value: string; onChange: (v: string) => void }>({
    value: '', onChange: () => {},
  })
  return {
    Select: ({ value, onValueChange, children }: any) => (
      <SelectCtx.Provider value={{ value, onChange: onValueChange }}>
        <div>{children}</div>
      </SelectCtx.Provider>
    ),
    SelectTrigger: ({ id, children }: any) => {
      const { value, onChange } = React.useContext(SelectCtx)
      return <select id={id} value={value} onChange={e => onChange(e.target.value)}>{children}</select>
    },
    SelectValue: ({ placeholder }: any) => <option value="">{placeholder}</option>,
    SelectContent: ({ children }: any) => <>{children}</>,
    SelectItem: ({ value, children }: any) => <option value={value}>{children}</option>,
  }
})
```

The `SelectTrigger` renders a native `<select>` element with the `id` from the parent `Select`'s context, making `getByLabelText` work in tests via `htmlFor`/`id` linkage.

### Alternatives Evaluated

- **`@testing-library/user-event` with real Radix** — fails because jsdom lacks pointer events and focus APIs
- **Flat mock with no context** — `SelectTrigger` cannot access parent `Select`'s `value`/`onValueChange` without context
- **`data-testid` selectors** — works but bypasses label/role accessibility checks

---

## Decision 18: Entra External ID OIDC Issuer Uses Tenant-ID Subdomain

**Date:** 2026-02-19
**Title:** OIDC Issuer Format for Azure Entra External ID CIAM Tenants
**Category:** Security & Authentication

### Decision Details

The `AUTH_ENTRA_ISSUER` (and backend `Authentication:Authority`) must use the **tenant ID** as the `ciamlogin.com` subdomain, not the friendly tenant name.

**Correct format:**
```
https://<tenant-id>.ciamlogin.com/<tenant-id>/v2.0
```
**Incorrect format (causes Auth.js "server configuration" error):**
```
https://<tenant-name>.ciamlogin.com/<tenant-id>/v2.0
```

### Root Cause

Auth.js v5 performs strict OIDC issuer validation per RFC 8414: after fetching the OIDC discovery document, it compares the configured `issuer` value to the `issuer` field returned in the document. For Entra External ID CIAM tenants, the discovery document's `issuer` field always uses the tenant ID as the subdomain — even when the discovery endpoint is accessed via the friendly name subdomain. Any mismatch causes Auth.js to throw "There is a problem with the server configuration."

### How to Verify

```bash
curl https://<tenant-name>.ciamlogin.com/<tenant-id>/v2.0/.well-known/openid-configuration \
  | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).issuer))"
```

The printed value is the exact string that must be used for `AUTH_ENTRA_ISSUER`.

---

## Decision 1: OIDC Federated Identity Authentication

**Date/Time:** 2026-02-12 09:00-10:00 UTC
**Title:** OIDC Federated Identity vs Service Principal with Secrets
**Category:** Security & Authentication

### Decision Details
Implemented OpenID Connect (OIDC) workload identity federation for GitHub Actions to authenticate with Azure, using federated identity credentials instead of storing service principal credentials as GitHub secrets.

Created two federated credentials:
1. Main branch credential: `repo:sandropetterle/AIEnterprisePatterns:ref:refs/heads/main`
2. Production environment credential: `repo:sandropetterle/AIEnterprisePatterns:environment:Production`

### Pros
- **No secrets to manage**: Eliminates need to store and rotate Azure credentials in GitHub
- **Enhanced security**: No long-lived credentials that could be compromised
- **Automatic credential rotation**: Azure AD handles token lifecycle
- **Principle of least privilege**: Each credential scoped to specific branch/environment
- **Audit trail**: Better tracking of authentication attempts

### Cons
- **Complex initial setup**: Requires understanding of Azure AD federated credentials
- **Multiple credentials needed**: Each branch and environment requires separate credential
- **Debugging challenges**: OIDC errors can be cryptic and harder to troubleshoot
- **Azure AD dependency**: Requires Azure AD application registration

### Impact
- Eliminated `AZURE_CLIENT_SECRET` from GitHub secrets
- Required adding `permissions: id-token: write` to all workflow jobs using Azure authentication
- Improved security posture by removing credential storage
- Set precedent for all future Azure deployments in the project

### Compromises
- Had to create two separate federated credentials (main branch + Production environment) instead of one
- Initial deployment delayed due to troubleshooting malformed credential subjects
- Required creating PowerShell scripts (`fix-creds.ps1`, `add-environment-cred.ps1`) for credential management

### Alternatives Evaluated
1. **Service Principal with Client Secret** (rejected)
   - Simpler setup but requires secret storage
   - Manual credential rotation needed
   - Higher security risk

2. **Azure CLI with Service Principal** (rejected)
   - Similar security concerns as above
   - No benefit over OIDC approach

3. **Managed Identity** (not applicable)
   - Only works for Azure-hosted runners, not GitHub-hosted

---

## Decision 2: System-Assigned Managed Identity for ACR Access

**Date/Time:** 2026-02-12 09:40 UTC
**Title:** Managed Identity for Container Registry Access
**Category:** Security & Container Registry

### Decision Details
Configured Azure Container Apps with system-assigned managed identities and assigned AcrPull role for accessing Azure Container Registry, eliminating need for ACR admin credentials or connection strings.

Implementation via `configure-acr-access.ps1`:
```powershell
az containerapp identity assign --system-assigned
az role assignment create --role AcrPull --scope $acrId
az containerapp registry set --identity "system"
```

### Pros
- **No credential management**: No passwords or connection strings to store
- **Automatic authentication**: Azure handles token exchange automatically
- **Azure best practice**: Recommended approach by Microsoft
- **Granular permissions**: Can assign specific roles (AcrPull) without full registry access
- **Audit compliance**: Better tracking of who/what accesses registry

### Cons
- **Additional provisioning step**: Not automatic with Container App creation
- **Delayed implementation**: Had to retroactively add after initial deployment
- **Propagation delay**: Role assignments can take time to become effective
- **Troubleshooting complexity**: UNAUTHORIZED errors don't clearly indicate missing managed identity

### Impact
- Both Container Apps (frontend and backend) can pull images without stored credentials
- Removed ACR admin username/password from deployment scripts
- Improved security compliance for production environment
- Standardized authentication pattern for all Azure container workloads

### Compromises
- Required creating separate PowerShell script for post-deployment configuration
- Had to enable managed identity on both Container Apps individually
- Temporary deployment failure until managed identity configured

### Alternatives Evaluated
1. **ACR Admin Credentials** (rejected)
   - Simple but insecure
   - Admin credentials have full registry access (over-privileged)
   - Credentials stored in Container App secrets

2. **Service Principal with AcrPull** (rejected)
   - Still requires credential storage
   - More complex than managed identity
   - Manual credential rotation needed

3. **Azure Key Vault Integration** (rejected)
   - Adds unnecessary complexity
   - Managed identity is more direct approach

---

## Decision 3: Build-Time API Fallback Strategy

**Date/Time:** 2026-02-12 09:45-10:05 UTC
**Title:** Graceful Degradation for Build-Time API Calls
**Category:** Frontend Build Strategy

### Decision Details
Implemented try/catch blocks around all build-time API calls in Next.js with fallback to empty state, allowing Docker builds to succeed even when backend API is unavailable. Relies on Incremental Static Regeneration (ISR) to generate pages on-demand.

Modified files:
- `app/patterns/[slug]/page.tsx` - generateStaticParams
- `app/page.tsx` - Featured patterns and stats
- `app/patterns/page.tsx` - Pattern listing with filters

### Pros
- **Resilient builds**: Docker builds succeed regardless of API availability
- **ISR compatibility**: Pages generate on first request with actual data
- **No build dependencies**: Frontend can build independently of backend
- **Graceful degradation**: Users see empty state initially, then real data
- **Faster builds**: No need to wait for API responses during build

### Cons
- **Multiple files to maintain**: Had to update 3 separate page files
- **Potential missed API calls**: Risk of forgetting to wrap new API calls in future
- **Initial empty state**: First visitors may see loading indicators
- **Type safety complexity**: Required explicit type annotations for fallback objects
- **Debugging confusion**: Build-time errors logged as warnings, may be overlooked

### Impact
- Docker builds complete successfully without running backend
- GitHub Actions workflows can build frontend and backend in parallel
- Reduced build time by ~30-60 seconds (no API wait time)
- Pages use ISR to populate with real data after first request

### Compromises
- Had to create properly typed fallback objects matching API response structure
- Multiple iterations to fix TypeScript type errors in fallback data
- Can't pre-generate static pages at build time (rely on on-demand generation)
- Console warnings during every Docker build (may mask real issues)

### Alternatives Evaluated
1. **Disable Static Generation Entirely** (rejected)
   - Would lose SEO benefits
   - All pages would be dynamic (slower)
   - No pre-rendering benefits

2. **Require API During Build** (rejected)
   - Creates build dependency
   - Docker builds would need running backend
   - More complex CI/CD orchestration

3. **Use Mock Data at Build Time** (rejected)
   - Would show stale/fake data initially
   - Confusing user experience
   - Maintenance burden for mock data

4. **Skip ISR, Make All Routes Dynamic** (rejected)
   - Loses performance benefits of static generation
   - Increased server load
   - Slower page loads for users

---

## Decision 4: Empty Public Folder Handling in Docker

**Date/Time:** 2026-02-12 10:10 UTC
**Title:** Ensure Public Directory Exists in Docker Build
**Category:** Docker Build Configuration

### Decision Details
Added `mkdir -p public` command in Dockerfile builder stage and used trailing slashes in COPY commands to handle empty public folder scenario.

```dockerfile
# Ensure public directory exists (even if empty)
RUN mkdir -p public

# Copy with trailing slashes for directories
COPY --from=builder --chown=nextjs:nodejs /app/public/ ./public/
```

### Pros
- **Build reliability**: Eliminates "not found" errors during Docker build
- **Follows Docker best practices**: Explicit directory creation
- **No conditional logic needed**: Simple, declarative approach
- **Works with any public folder state**: Empty or with files
- **Minimal overhead**: Single RUN command, negligible build time impact

### Cons
- **Extra build step**: Adds one RUN command to Dockerfile
- **Not strictly necessary**: Only needed when public folder is empty
- **Masks potential issues**: Build succeeds even if public assets missing

### Impact
- Docker builds no longer fail when public folder is empty
- More reliable CI/CD pipeline (no random failures)
- Aligned with Next.js standalone build expectations
- Set pattern for handling optional directories in Docker

### Compromises
- None significant - this is a standard Docker practice

### Alternatives Evaluated
1. **Copy public from Source in Runner Stage** (rejected)
   - Failed: No build context in runner stage
   - Would require keeping source files

2. **Conditional COPY** (rejected)
   - Not supported in Dockerfile syntax
   - Would require shell scripting

3. **Ignore Missing Directory** (rejected)
   - Build would still fail with COPY errors
   - Not a solution to the problem

---

## Decision 5: Enable Scale-to-Zero for Container Apps

**Date/Time:** 2026-02-12 (inherited from Phase 4 planning)
**Title:** Cost Optimization via Scale-to-Zero Configuration
**Category:** Cost Optimization & Infrastructure

### Decision Details
Configured Azure Container Apps with `minReplicas: 0`, allowing containers to scale down completely when idle, paying only for actual usage.

Configuration:
```yaml
scale:
  minReplicas: 0
  maxReplicas: 10
```

### Pros
- **Significant cost savings**: 60-80% reduction vs always-on App Services ($5-12/month vs $18-24/month)
- **Pay per use**: Only charged for actual compute time
- **Automatic scaling**: Handles traffic spikes without manual intervention
- **Environment friendly**: Zero compute resources when idle
- **Azure Container Apps feature**: Designed for this use case

### Cons
- **Cold start latency**: 10-30 seconds delay on first request after idle period
- **Inconsistent response times**: First request slow, subsequent requests fast
- **WebSocket limitations**: Connections dropped when scaling to zero
- **Monitoring gaps**: No metrics when scaled to zero
- **User experience impact**: Noticeable delay for first visitor after idle

### Impact
- Monthly production costs reduced from $18-24 to $5-12
- Annual savings: ~$150-200
- Acceptable for demo/portfolio application with sporadic traffic
- May need to revisit for high-traffic production workloads

### Compromises
- Accepted cold start latency for cost savings
- Not suitable for applications requiring consistent sub-second response times
- First visitor after idle period experiences degraded performance
- Can't maintain persistent connections or background jobs

### Alternatives Evaluated
1. **Always-On App Services** (rejected for cost)
   - $18-24/month
   - No cold starts
   - Better for production workloads
   - Not cost-effective for demo application

2. **Min Replicas = 1** (rejected for cost)
   - ~$10-15/month
   - Eliminates cold starts
   - Still more expensive than scale-to-zero

3. **Azure Functions Consumption Plan** (rejected for architecture)
   - Similar cost model
   - Doesn't support full containerized applications
   - Would require application restructuring

---

## Decision 6: Ingress Target Port Configuration

**Date/Time:** 2026-02-12 10:30 UTC
**Title:** Correct Port Mapping for Container Ingress
**Category:** Container Configuration & Networking

### Decision Details
Configured Container Apps ingress with correct target ports matching application listening ports:
- Backend API: `targetPort: 5255` (ASP.NET Core default)
- Frontend: `targetPort: 3000` (Next.js standalone default)

Initially misconfigured as port 80, causing Azure to route traffic to wrong port and display welcome page.

### Pros
- **Correct routing**: Traffic reaches application listeners
- **No application changes**: Uses default ports from frameworks
- **Standard practice**: Matches local development ports
- **Clear debugging**: Port mismatch obvious in logs

### Cons
- **Not immediately obvious**: Initial deployment succeeded but served wrong content
- **Azure defaults misleading**: Portal defaults to port 80
- **Delayed discovery**: Only caught after full deployment

### Impact
- Fixed apps showing Azure welcome page instead of application
- Aligned container configuration with application runtime expectations
- Established verification checklist for future Container App deployments

### Compromises
- Required post-deployment configuration update
- Temporary period where apps appeared deployed but weren't serving correct content

### Alternatives Evaluated
1. **Change Application Ports to 80** (rejected)
   - Would require Dockerfile changes
   - Non-standard for development
   - Unnecessary modification

2. **Use Port Mapping in Dockerfile** (rejected)
   - Adds complexity
   - Target port configuration is cleaner approach

---

## Decision 7: Multi-Stage Docker Build for Next.js

**Date/Time:** 2026-02-12 (inherited from Phase 4 planning)
**Title:** Optimize Frontend Docker Image Size and Security
**Category:** Docker Build Strategy & Security

### Decision Details
Implemented 3-stage Docker build for Next.js:
1. **deps stage**: Install all dependencies including devDependencies
2. **builder stage**: Build Next.js application
3. **runner stage**: Minimal production image with non-root user

### Pros
- **Smaller image size**: Only production artifacts in final image
- **Security hardening**: Non-root user (nextjs:nodejs), minimal attack surface
- **Build caching**: Dependencies cached separately from source
- **Best practice**: Follows Next.js official Dockerfile recommendations
- **Layer optimization**: Separate layers for dependencies, source, and build output

### Cons
- **Complex Dockerfile**: Three stages vs single-stage build
- **Longer initial builds**: More layers to build (mitigated by caching)
- **Troubleshooting harder**: Need to understand which stage has issues

### Impact
- Final image size: ~200MB vs ~1GB for non-optimized build
- Improved security posture with non-root execution
- Faster subsequent builds due to layer caching
- Production-ready container following Docker best practices

### Compromises
- Initially used `npm ci --only=production` which broke build (missing devDependencies)
- Changed to `npm ci` in deps stage to install all dependencies
- Slightly larger deps layer but necessary for build to succeed

### Alternatives Evaluated
1. **Single-Stage Build** (rejected)
   - Simpler but much larger image
   - Includes build tools in production
   - Poor security practice

2. **Two-Stage Build** (rejected)
   - Combines deps and builder
   - Less caching optimization

3. **Build on Host, Copy Artifacts** (rejected)
   - Doesn't work with GitHub Actions
   - Not reproducible across environments

---

## Decision 8: Port 8080 for Non-Root Container Security

**Date/Time:** 2026-02-13 11:45 UTC
**Title:** Change Backend Port from 80 to 8080 for Non-Root User
**Category:** Security & Container Configuration

### Decision Details
Changed ASP.NET Core backend to listen on port 8080 instead of port 80 to allow running as non-root user in Docker container.

**Root Cause of Change:**
Container was crashing with `SocketException (13): Permission denied` because:
- Dockerfile configured `USER appuser` (non-root) for security
- But set `ASPNETCORE_URLS=http://+:80`
- Ports below 1024 require root privileges on Linux

**Fix Applied:**
```dockerfile
# Changed from:
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# To:
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
```

### Pros
- **Container starts successfully**: No permission errors
- **Maintains security**: Continues running as non-root user
- **Standard practice**: Port 8080 is conventional for non-privileged HTTP services
- **Azure compatible**: Container Apps ingress can map any target port
- **No application changes**: Only infrastructure configuration updated

### Cons
- **Non-standard HTTP port**: Not the default port 80
- **Required ingress update**: Had to update Container App targetPort configuration
- **Documentation overhead**: Need to remember 8080 in all deployment docs
- **Delayed discovery**: Took multiple deployment attempts to identify root cause

### Impact
- Backend containers now start and serve traffic successfully
- Fixed 100% crash rate on Container Apps deployment
- Established pattern for all future ASP.NET Core containerized services
- Deployment time increased by ~2 hours due to troubleshooting
- Container App ingress targetPort updated to 8080

### Compromises
- Not using standard HTTP port 80
- External traffic still uses port 443 (HTTPS), so end-users unaffected
- Internal architecture documentation must specify port 8080

### Alternatives Evaluated
1. **Run container as root** (rejected)
   - Major security risk
   - Violates container best practices
   - Could allow container escape vulnerabilities

2. **Use port 80 with capabilities** (rejected)
   - Requires NET_BIND_SERVICE capability
   - More complex Dockerfile
   - Still less secure than non-privileged ports

3. **Change to port 5000 (Kestrel default)** (rejected)
   - Port 8080 more conventional for containerized apps
   - 8080 clearly indicates HTTP service

---

## Decision 9: Content-Verified Health Checks in CI/CD

**Date/Time:** 2026-02-13 12:00 UTC
**Title:** Verify Actual Application Content in Deployment Health Checks
**Category:** CI/CD & Quality Assurance

### Decision Details
Enhanced all GitHub Actions deployment workflows to verify actual application content instead of just HTTP status codes.

**Problem Identified:**
Health checks returned success (✓) when Azure welcome page was served because:
- Welcome page returns HTTP 200
- Workflow only checked `curl -w "%{http_code}"`
- False positive: Deployment "succeeded" but wrong content served

**Solution Implemented:**

**Backend API:**
```bash
response=$(curl -s /health)
if [ "$response" = "Healthy" ]; then
  echo "✓ Health check passed"
else
  echo "✗ Expected 'Healthy', got '$response'"
  exit 1
fi
```

**Frontend:**
```bash
response=$(curl -s /)
if echo "$response" | grep -q "next-size-adjust"; then
  echo "✓ Next.js content detected"
else
  echo "✗ Azure welcome page detected"
  exit 1
fi
```

### Pros
- **No false positives**: Fails when wrong content served
- **Earlier failure detection**: Catches misconfigurations immediately
- **Clear error messages**: Shows expected vs actual response
- **Simple implementation**: Uses grep for pattern matching
- **Comprehensive coverage**: Applied to all 4 workflows (Container Apps + App Services)

### Cons
- **Brittle checks**: May break if Next.js meta tag name changes
- **Extra network call**: Two curl requests instead of one (status + content)
- **String matching fragility**: Could fail on valid but unexpected responses
- **No semantic validation**: Doesn't check if API actually works, just if it returns expected string

### Impact
- Prevented future false positive deployments
- Saved debugging time by failing fast
- Increased confidence in deployment success indicators
- Set pattern for all future health check implementations
- Applied to 4 workflows: backend-deploy, frontend-deploy, backend-container-deploy, frontend-container-deploy

### Compromises
- Used simple string/pattern matching instead of full integration tests
- Chose specific marker (next-size-adjust) that could change in Next.js updates
- Two sequential curl calls instead of single optimized check

### Alternatives Evaluated
1. **Full integration tests** (deferred)
   - Would be more comprehensive
   - Too slow for deployment health checks
   - Better suited for separate E2E test suite

2. **Check for specific JSON structure** (considered)
   - More robust for API
   - Overkill for simple health endpoint
   - "Healthy" string check is sufficient

3. **Use regex for flexible matching** (rejected)
   - More complex to maintain
   - Simple string/grep matching adequate

4. **Parse HTML DOM** (rejected)
   - Would require additional tools (jq, xmllint)
   - Adds dependencies to GitHub Actions runner

---

## Summary

This log now covers **12 major technical decisions** across deployment and testing phases:
- **Security** (OIDC, Managed Identity, non-root containers, port privileges)
- **Cost Optimization** (scale-to-zero)
- **Build Reliability** (API fallback, public folder handling)
- **Deployment Configuration** (port mapping, multi-stage builds)
- **Quality Assurance** (content-verified health checks)
- **Testing** (Jest mocking strategy, ESM dependencies, Playwright E2E fetch interception)

### Key Themes
1. **Security-first approach**: Eliminated credential storage wherever possible, maintained non-root container execution
2. **Cost consciousness**: Prioritized cost savings for demo/portfolio application
3. **Resilience**: Built fault tolerance into build and deployment processes
4. **Best practices**: Followed Azure and Docker recommended patterns
5. **Fail-fast principle**: Enhanced CI/CD to catch misconfigurations early

### Lessons Learned
- OIDC setup requires careful attention to subject format
- Managed identities should be configured during initial provisioning
- Next.js build-time API calls need error handling for containerized builds
- Azure Container Apps port configuration must match application listeners
- Scale-to-zero trades latency for cost (acceptable for low-traffic apps)
- **Non-root containers cannot bind to privileged ports (<1024)** - use port 8080 for HTTP
- **HTTP 200 doesn't guarantee correct content** - verify actual application responses in health checks
- Stack traces with SocketException (13) indicate Linux permission issues, often port-related
- Azure welcome pages can mask deployment failures by returning HTTP 200

### Future Considerations
- Monitor cold start latency in production usage
- Consider min replicas = 1 if traffic increases
- Evaluate Azure Functions for truly serverless architecture
- Document all federated credential subjects for maintenance

---

## Decision 10: Jest Module Mocking Strategy — spyOn vs Factory Pattern

**Date:** 2026-02-19
**Title:** Use `jest.spyOn` for module-level mocking instead of `jest.mock` factory with `jest.fn()`
**Category:** Testing

### Decision Details

When writing tests for `lib/api/patterns.ts` (which calls `apiClient.get/post`), the initial approach used `jest.mock('../client', () => ({ apiClient: { get: jest.fn(), post: jest.fn() } }))`. This caused `TypeError: mockedGet.mockResolvedValueOnce is not a function` at runtime under Jest 30 with the Next.js SWC transformer.

The fix: import the module directly and use `jest.spyOn(apiClient, 'get').mockResolvedValueOnce(...)` within `beforeEach`, restoring with `jest.restoreAllMocks()` in `afterEach`.

### Why It Works
`apiClient` is a plain object (`export const apiClient = { get, post, put, delete: del }`). Jest's `spyOn` wraps the object property directly, meaning the spy intercepts calls made by any code that imported the same module instance — including the module under test.

### Pros
- Works reliably with SWC transformer (no hoist/factory scoping issue)
- Type-safe with `ReturnType<typeof jest.spyOn>`
- Per-test return values via `mockResolvedValueOnce`
- Clean restoration via `jest.restoreAllMocks()`

### Cons
- Requires the real module to be imported (not isolated)
- spyOn won't work if the export is a frozen object or primitive

### Alternatives Evaluated
1. **`jest.mock` with factory** (rejected) — `jest.fn()` inside factory unreliable with SWC
2. **Manual mock file** (`__mocks__/client.ts`) — heavier, more maintenance
3. **Auto-mock** (`jest.mock('../client')` no factory) — relies on Jest inferring mock shape, less explicit

---

## Decision 11: Mock ESM Dependencies in Component Tests (react-markdown)

**Date:** 2026-02-19
**Title:** Mock `react-markdown` and its plugins rather than adding SWC transform exceptions
**Category:** Testing

### Decision Details

`PatternContent.tsx` imports `react-markdown`, `remark-gfm`, and `rehype-sanitize`, all of which publish ES modules (`export {}`). Jest's default `transformIgnorePatterns` excludes `node_modules`, causing `SyntaxError: Unexpected token 'export'` when the test file is loaded.

Chose to mock the ESM packages at the test-file level rather than modifying `transformIgnorePatterns` to include a long list of transitive ESM dependencies.

```ts
jest.mock('react-markdown', () => function ReactMarkdown({ children }) {
  return <div data-testid="markdown-content">{children}</div>
})
jest.mock('remark-gfm', () => () => ({}))
jest.mock('rehype-sanitize', () => () => ({}))
```

### Pros
- Zero changes to shared jest config — no risk of breaking other tests
- Simpler: one mock per file, no need to enumerate all transitive ESM deps
- Tests `PatternContent`'s render logic (prose wrapper, content passing) without testing `react-markdown` internals

### Cons
- Custom component renderers (h2, h3, code, blockquote, etc.) defined in `PatternContent` are not exercised
- Any bugs in those renderers are invisible to unit tests — covered by E2E instead

### Alternatives Evaluated
1. **Modify `transformIgnorePatterns`** (rejected) — requires enumerating ~15 transitive ESM packages; brittle across package updates
2. **Use `jest.config.ts` `moduleNameMapper`** — could map to stub, but same trade-off as mocking
3. **E2E-only for PatternContent** — deferred; unit coverage gap would persist until Playwright E2E are fixed

---

## Decision 12: Playwright Vote Mocking — `page.addInitScript` vs `page.route`

**Date:** 2026-02-19
**Title:** Override `window.fetch` via `page.addInitScript` instead of using `page.route` for cross-origin vote API interception
**Category:** Testing / E2E

### Decision Details

The VotingButton E2E tests need to intercept `POST /api/patterns/{id}/vote` (cross-origin: frontend port 3000 → backend port 5255) and return a controlled 201 response. The initial implementation used `page.route(/\/patterns\/[^/]+\/vote/, handler)` — a standard Playwright network interception pattern.

**Problem:** `page.route` silently failed to intercept requests. `page.waitForRequest(regex)` timed out with no request fired, even after verifying React hydration was complete. The `apiClient.post` call uses `credentials: 'include'`, which triggers a CORS preflight (OPTIONS). When Playwright fulfills the OPTIONS request with a plain JSON response (no CORS headers), the browser's CORS policy blocks the subsequent POST — and Playwright's CDP-level interception doesn't inject the correct `Access-Control-Allow-*` headers automatically for pre-flight responses in cross-origin dev scenarios.

**Solution:** Use `page.addInitScript` to replace `window.fetch` in the browser's JavaScript runtime before the app bundle loads. This intercepts the vote fetch at the JS level, bypassing CORS entirely.

```typescript
await page.addInitScript(() => {
  const orig = window.fetch.bind(window)
  window.fetch = async function (input, init) {
    const url = typeof input === 'string' ? input : (input as Request).url
    if (url.includes('/vote')) {
      await new Promise<void>(r => setTimeout(r, 500)) // delay for optimistic UI
      return new Response(
        JSON.stringify({ voteCount: 99, patternId: 'mocked' }),
        { status: 201, headers: { 'Content-Type': 'application/json' } }
      )
    }
    return orig(input, init)
  }
})
```

`page.addInitScript` runs in the browser context before any page scripts, so the override is in place when `handleVote` calls `voteForPattern`. Only `/vote` URLs are intercepted, leaving all data-fetching requests (`/patterns`, `/patterns/{slug}`) intact.

### Pros
- Bypasses CORS completely — no preflight issues
- Guaranteed to run before app scripts (addInitScript ordering)
- Works regardless of `NEXT_PUBLIC_API_BASE_URL` value or backend availability
- Simpler test assertions — no `waitForRequest`, just check DOM state
- Captures optimistic UI behavior accurately: `setHasVoted(true)` is synchronous, so button disables immediately on click

### Cons
- `page.addInitScript` must be called before `page.goto` (not re-usable if page is already open)
- Overriding `window.fetch` could in theory conflict with Next.js's patched fetch; filtered by URL to minimize risk
- Does not test that a real network request is actually made (network-level verification traded for reliability)

### Alternatives Evaluated
1. **`page.route` with regex** (rejected) — CORS preflight issue silently prevented POST from firing; `waitForRequest` timed out reliably
2. **`page.route` with `route.fulfill()` including explicit CORS headers** (rejected) — complex and brittle; depends on Playwright correctly proxying the OPTIONS response
3. **`page.evaluate` post-navigation** — works but runs after the initial page scripts; `addInitScript` is cleaner and more reliable
4. **Disable CORS in backend for tests** (rejected) — changes production code behaviour; test should adapt to production config

---

## Decision 13: Azure SQL Storage Reduction — 32 GB → 2 GB

**Date:** 2026-02-19
**Title:** Reduce Azure SQL Database Max Storage from Default 32 GB to 2 GB
**Category:** Infrastructure / Cost Optimisation

### Decision Details
The Azure SQL Serverless database (`sqldb-aipatterns-prod`) was created without an explicit `--max-size`, so it defaulted to **32 GB** of provisioned storage. For a small-scale application with 6 seeded patterns and minimal data growth expected, 32 GB is heavily over-provisioned.

Changed via:
```bash
az sql db update \
  --resource-group rg-aipatterns-prod \
  --server sql-aipatterns-sandr-1770754196 \
  --name sqldb-aipatterns-prod \
  --max-size 2GB
```

### Rationale
- Application data footprint is tiny (6 patterns, 18 tags, text content)
- 2 GB is a comfortable upper bound — would require tens of thousands of patterns to approach the limit
- Azure General Purpose storage is billed at $0.115/GB/month regardless of actual usage; provisioned size determines the charge

### Savings
| | Before | After |
|---|---|---|
| Provisioned storage | 32 GB | 2 GB |
| Monthly storage cost | ~$3.68 | ~$0.23 |
| **Monthly saving** | | **~$3.45** |

This is significant relative to total infrastructure cost ($5–12/month) and represents ~30–50% of the idle monthly bill.

### Pros
- Immediate ~$3.45/month saving with zero functional impact
- Storage can be increased again at any time via the same command or Azure Portal
- Backup storage allocation also shrinks proportionally

### Cons
- If data grows unexpectedly beyond 2 GB, an explicit resize will be required (non-disruptive, takes ~seconds)

### Alternatives Evaluated
1. **Leave at 32 GB default** (rejected) — unnecessary cost, no benefit for this workload
2. **1 GB minimum** (not chosen at the time) — later adopted in Decision 29 after confirming data footprint remained tiny

---

## Decision 14: Azure Entra External ID over Azure AD B2C

**Date:** 2026-02-19
**Title:** Use Azure Entra External ID (not Azure AD B2C) for Customer Authentication
**Category:** Security & Authentication

### Decision Details
Phase 5 requires authentication for CRUD operations. We evaluated Azure AD B2C (the original plan) versus Azure Entra External ID (B2C's successor).

Azure AD B2C is **no longer available for new customers as of May 2025**. Microsoft has replaced it with Entra External ID, which uses standard OIDC protocols and is free for up to 50,000 MAU.

Chosen: **Azure Entra External ID** with standard OIDC Authorization Code flow (PKCE).

### Pros
- **$0/month** for <50,000 MAU — no cost for our <10 users
- **Standard OIDC** — works with any OIDC client library; no Microsoft-specific SDK required
- **Free email OTP MFA** — secure multi-factor auth at no cost
- **Custom branding** — full CSS customization to match site design
- **App Roles** — built-in role assignment per user (Admin, Editor, Viewer)
- **Active product** — B2C is sunset; Entra External ID is the strategic direction

### Cons
- **ciamlogin.com domain** — slightly unusual (not login.microsoftonline.com)
- **External tenant required** — separate tenant from corporate directory
- **Setup complexity** — multiple Azure portal steps (documented in AUTH_SETUP_GUIDE.md)

### Alternatives Evaluated
1. **Azure AD B2C** (rejected) — no longer available for new registrations as of May 2025
2. **Auth0** — viable, free tier available; rejected as unnecessary complexity when Entra External ID is $0 and provides equivalent features
3. **Keycloak self-hosted** (rejected) — adds operational overhead (hosting, backups, updates) with no cost benefit at this scale
4. **ASP.NET Core Identity** (rejected) — requires database tables for users, sessions, and password hashes; introduces credential management risk

---

## Decision 15: Auth.js (NextAuth v5) over MSAL.js for Frontend Authentication

**Date:** 2026-02-19
**Title:** Use Auth.js Generic OIDC Provider Instead of Microsoft MSAL.js
**Category:** Architecture & Technology Selection

### Decision Details
The frontend required an authentication library to handle OIDC login redirects, token acquisition, session management, and token refresh.

Chosen: **Auth.js v5 (NextAuth beta)** with a generic `type: "oidc"` provider configured for Entra External ID.

Key configuration in `auth.ts`:
- `type: "oidc"` — generic, works with any OIDC provider
- `issuer: process.env.AUTH_ENTRA_ISSUER` — single env var to change provider
- JWT session strategy — no database tables needed
- `pages: { signIn: '/login' }` — branded login page

### Pros
- **Provider-agnostic**: Swapping to Auth0 or Keycloak = changing 4 env vars, zero code changes
- **App Router native**: Auth.js v5 designed for Next.js Server Components
- **JWT sessions**: No database table for sessions; encrypted cookie
- **Built-in CSRF protection**: Handled automatically
- **Server-side token access**: `auth()` function in server components

### Cons
- **Beta library**: Auth.js v5 is still beta; occasional breaking changes
- **ESM in tests**: Requires `transformIgnorePatterns` update in Jest config for SWC compatibility

### Alternatives Evaluated
1. **@azure/msal-react** (rejected) — Microsoft-specific, couples frontend to Azure AD; swapping providers would require full library replacement
2. **next-auth v4** (rejected) — older version without App Router support; v5 is the supported path
3. **Custom OAuth implementation** (rejected) — significant security risk; PKCE, state, nonce handling is complex to implement correctly

---

## Decision 16: Standard ASP.NET Core JwtBearer over Microsoft.Identity.Web

**Date:** 2026-02-19
**Title:** Use Standard JwtBearer Middleware, Not Microsoft.Identity.Web
**Category:** Architecture & Technology Selection

### Decision Details
The backend API needs to validate JWT access tokens issued by the OIDC provider. Two packages were evaluated:

Chosen: **`Microsoft.AspNetCore.Authentication.JwtBearer`** (standard ASP.NET Core package).

Configuration in `Program.cs`:
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Authentication:Authority"];
        options.Audience = builder.Configuration["Authentication:Audience"];
        options.TokenValidationParameters = new TokenValidationParameters
        {
            RoleClaimType = "roles",  // Entra uses "roles" claim
            NameClaimType = "name"
        };
    });
```

The `Authority` URL causes the middleware to auto-discover signing keys from the OIDC discovery document — no key management needed.

### Pros
- **Provider-agnostic**: Any OIDC provider can be used; change Authority + Audience config only
- **Standard package**: Ships with ASP.NET Core SDK, no additional dependency
- **Auto key rotation**: Discovery document enables automatic signing key refresh
- **Minimal surface area**: Does exactly one thing — validate JWT tokens

### Cons
- **Role claim type varies by provider**: Entra uses `roles`; Auth0 uses a custom claim; requires 1-line config change when switching providers
- **No Microsoft Graph integration**: Microsoft.Identity.Web includes Graph client helpers; these are not needed here

### Alternatives Evaluated
1. **Microsoft.Identity.Web** (rejected) — wraps JwtBearer with Microsoft-specific configuration; couples backend to Azure AD; harder to swap to Auth0/Keycloak
2. **Manual JWT validation** (rejected) — high complexity, error-prone; standard middleware handles all edge cases (key rotation, clock skew, audience validation)

---

## Decision 17: Auth Guard Clause + Always-Register Authorization Policies

**Date:** 2026-02-19
**Title:** Register Authorization Policies Unconditionally; Guard JwtBearer Registration
**Category:** Testing & Architecture

### Decision Details
A subtle ordering issue arose when adding `[Authorize(Policy = "RequireEditor")]` attributes:

**Problem:** `AddAuthorizationBuilder()` was initially inside the auth guard clause (only when `Authority` is set). In test environments without a real Entra tenant, no Authority is configured → `AddAuthorizationBuilder()` never ran → authorization policies didn't exist → ASP.NET returned 500 instead of 401/403 → existing integration tests started failing.

**Solution:**
```csharp
// Authorization policies — always registered (enables [Authorize] attributes in tests)
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"))
    .AddPolicy("RequireEditor", policy => policy.RequireRole("Admin", "Editor"))
    .AddPolicy("RequireViewer", policy => policy.RequireRole("Admin", "Editor", "Viewer"));

// JwtBearer — only registered when Authority is configured (opt-in)
var authAuthority = builder.Configuration["Authentication:Authority"];
if (!string.IsNullOrEmpty(authAuthority))
{
    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options => { ... });
}
```

For integration tests, a `TestAuthHandler` reads the `X-Test-Roles` request header and authenticates the request with those roles — no real token needed.

### Pros
- **Existing 83 tests continue passing** without auth config
- **New auth boundary tests** (401/403) work correctly via TestAuthHandler
- **Docker/CI builds** succeed without Entra secrets
- **Local development** works without tenant setup
- **Clean separation**: Policies (always needed) vs. token validation (env-specific)

### Cons
- **Two-step mental model**: Policies always registered, scheme conditionally registered
- **TestAuthHandler complexity**: A small custom class required for test auth

### Alternatives Evaluated
1. **Always require auth config** (rejected) — breaks CI builds and local dev without Entra setup
2. **Skip [Authorize] in tests via mock middleware** (rejected) — hides real authorization behavior; tests wouldn't catch missing policies
3. **Separate test appsettings** (considered) — viable but adds file proliferation; TestAuthHandler is more explicit

---

## Decision 18: Client-Side Auth Checks for Conditional UI in Pattern Management

**Date:** 2026-02-19
**Title:** Use Client-Side Session Checks for Edit/Delete/New Buttons; Server-Side Auth Only for Form Pages
**Category:** Architecture & Security

### Decision Details
Phase 5.2 added CRUD UI (create/edit/delete patterns). Two approaches were evaluated for showing auth-gated UI elements (Edit button, Delete button, "New Pattern" button):

**Approach A (chosen for conditional UI):** Client components check `useSession()` and return `null` when not authorized. This is the same pattern used by the existing `UserMenu` component.

**Approach B (chosen for form pages):** Server components call `auth()` (Auth.js server-side) and `redirect()` for hard access control gates.

**Decision:** Use *both* in appropriate contexts:
- `PatternActions` (edit/delete buttons on detail page): client-side `useSession()` check → returns `null` for non-editors. Page stays ISR-cacheable.
- `NewPatternButton` (on listings page): client-side `useSession()` check → renders `null` for non-editors. Page stays ISR-cacheable.
- `/patterns/new` and `/patterns/[slug]/edit` pages: server-side `auth()` check → `redirect('/login')` or `redirect('/patterns')`. Prevents unauthorized users from even loading the form.

This dual approach avoids a "flash of unauthorized content" on form pages while keeping the read-heavy listing/detail pages in ISR cache.

### Pros
- **ISR caching preserved** for listing/detail pages (no dynamic auth call on the server)
- **Hard gate on write pages** — unauthenticated users redirected before form loads
- **Consistent with existing pattern** — UserMenu already uses client-side session check
- **No flash on form pages** — server redirect happens before any HTML is returned

### Cons
- **Brief null state** while session loads on listing/detail pages (same as UserMenu behavior; acceptable)
- **Two mental models**: conditional UI vs. access control gates behave differently

### Alternatives Evaluated
1. **Server-side auth on all pages** (rejected for listing/detail) — makes ISR-cached pages dynamic, losing caching benefits
2. **Client-side only everywhere** (rejected for form pages) — allows brief render of form HTML before redirect; form submits would still fail at API but UX is confusing

---

## Decision 19: Context-Based Radix UI Select Mock for Jest Tests

**Date:** 2026-02-19
**Title:** Use React.createContext in Jest Mock Factory for Radix UI Select
**Category:** Testing

### Decision Details
The `PatternForm` component uses the shadcn/ui `Select` (Radix UI `@radix-ui/react-select`). Radix UI Select uses portals which don't render in jsdom. The component structure separates `Select` (value/onChange owner), `SelectTrigger` (renders the trigger element with `id`), and `SelectContent`/`SelectItem` (render options).

**Problem:** A naïve mock that renders a native `<select>` inside the `Select` component caused:
1. HTML nesting errors (`<span>` inside `<select>` from `SelectValue`)
2. `getByLabelText` failures because the native select lacked the `id` that was on `SelectTrigger`

**Solution:** A context-based mock factory using `React.createContext`:
```typescript
jest.mock('@/components/ui/select', () => {
  const React = require('react')
  const Ctx = React.createContext({ value: '', onValueChange: () => {} })
  return {
    Select: ({ value, onValueChange, children }) =>
      <Ctx.Provider value={{ value, onValueChange }}>{children}</Ctx.Provider>,
    SelectTrigger: ({ id, children }) => {
      const ctx = React.useContext(Ctx)
      return <select id={id} value={ctx.value} onChange={e => ctx.onValueChange(e.target.value)}>{children}</select>
    },
    SelectValue: () => null,  // prevents <span> inside <select>
    SelectContent: ({ children }) => <>{children}</>,
    SelectItem: ({ value, children }) => <option value={value}>{children}</option>,
  }
})
```

This correctly:
- Links the `<Label htmlFor="category">` to the `<select id="category">` for `getByLabelText`
- Propagates `value` and `onValueChange` from `Select` to `SelectTrigger` via context
- Renders valid HTML (`<option>` elements only inside `<select>`)

### Pros
- **Semantically correct**: `getByLabelText` works; `userEvent.selectOptions` works
- **Valid HTML**: No hydration-style console errors in tests
- **Reusable pattern**: Same approach works for any Radix-style compound component

### Cons
- **Mock complexity**: Requires `React.createContext` inside mock factory
- **Fragile to component prop changes**: If `id` moves from `SelectTrigger` to `Select`, mock breaks

### Alternatives Evaluated
1. **Skip category field in tests** (rejected) — hides real validation logic
2. **Use `data-testid`** (rejected) — breaks `getByLabelText` accessibility-first testing pattern
3. **Mock entire component file** with simpler structure (rejected) — loses label association


---

## Decision 32: Strapi 5 Populate Syntax — Per-Query Bracket Notation

**Date:** 2026-02-25
**Title:** Replace `populate=deep` with Strapi 5 Bracket Notation Per Query
**Category:** Architecture / CMS Integration

### Decision Details

Strapi 5 does NOT support `populate=deep` without the community `strapi-plugin-populate-deep` plugin. The original `safeFetch()` in `lib/cms/queries.ts` sent `{ populate: 'deep' }` for all queries, which returned HTTP 400. Because `fetchStrapi()` wraps non-OK responses as `CmsUnavailableError`, the 400 was silently caught and all queries fell back to hardcoded data — meaning CMS integration appeared to work but never actually served CMS content.

### Fix

Replaced the single `populate=deep` with per-query populate presets using Strapi 5's bracket notation:

| Preset | Syntax | Used By |
|--------|--------|---------|
| `FLAT` | `populate=*` | login, not-found, error, all label types |
| `GLOBAL` | `populate[navigation]=*&populate[footer][populate][links]=*` | global config |
| `DYNAMIC_ZONE` | `populate[content][populate]=*&populate[seo]=*` | home page |
| `DYNAMIC_ZONE_WITH_HEADER` | `populate[content][populate]=*&populate[header]=*&populate[seo]=*` | about, docs pages |

### Why Not Install `strapi-plugin-populate-deep`

- Adds a dependency for something achievable with built-in syntax
- Plugin must be version-compatible with each Strapi upgrade
- Explicit populate is more predictable (no unexpected deep fetches that return excessive data)

---

## Decision 31: Strapi 5 Local Docker Development — Multiple Build Fixes

**Date:** 2026-02-25
**Title:** Strapi 5 Docker Setup Fixes (tsconfig JSON, MySQL Dialect, Multi-Stage Build, esbuild)
**Category:** Infrastructure / CMS

### Decision Details

Getting Strapi 5 running locally in Docker required four separate fixes:

1. **tsconfig.json — Include JSON schemas**: Strapi loads content-type schemas from `dist/`, not `src/`. TypeScript compiler only emits `.ts→.js` files. Schema `.json` files were NOT being copied to `dist/`, causing `TypeError: Cannot read properties of undefined (reading 'kind')` at startup with empty content-type registry. **Fix:** Added `"./src/**/*.json"` to `cms/tsconfig.json` `include` array.

2. **MySQL dialect name**: Strapi 5 uses `mysql` as the dialect key, not `mysql2`. Using `mysql2` caused `Unknown dialect mysql2` at startup. **Fix:** Changed `DATABASE_CLIENT` env var and `database.ts` connection key from `mysql2` to `mysql`.

3. **Multi-stage Dockerfile**: `strapi build` requires `APP_KEYS` and other secrets as env vars at build time. For local dev, building is unnecessary (Strapi auto-builds in dev mode). **Fix:** Restructured Dockerfile with 4 stages (deps → dev → build → production); docker-compose targets `dev` stage which skips the build step.

4. **esbuild dependency**: Strapi's startup auto-installs `react@^18`, `react-dom@^18`, `react-router-dom@^6`, and `styled-components@^6`. This `npm install` side-effect removes `esbuild` from `node_modules`, causing `Cannot find module 'esbuild'`. **Fix:** Added `esbuild`, `react`, `react-dom`, `react-router-dom`, and `styled-components` as explicit dependencies in `cms/package.json` to prevent Strapi's auto-install from disrupting the dependency tree.

### Files Modified
- `cms/tsconfig.json` — added `"./src/**/*.json"` to include
- `cms/config/database.ts` — changed `mysql2` key to `mysql`
- `cms/Dockerfile` — 4-stage build (deps/dev/build/production)
- `cms/package.json` — added esbuild + React deps explicitly
- `docker-compose.yml` — target `dev`, DATABASE_CLIENT `mysql`

---

## Decision 30: Strapi 5 Headless CMS Integration (Phase 5.5)

**Date:** 2026-02-25
**Title:** Strapi 5 as Headless CMS for Static Frontend Content
**Category:** Architecture / Content Management

### Decision Details

Integrated Strapi 5 as a headless CMS to manage the 300+ hardcoded static content items across the frontend (headings, descriptions, CTAs, form labels, nav links, SEO metadata, etc.).

### What Was Built

**CMS Project (`cms/`):**
- Strapi 5 TypeScript project with SQLite (dev) / MySQL (production) database support
- 10 Single Types: `global`, `home-page`, `about-page`, `docs-page`, `login-page`, `not-found-page`, `error-page`, `pattern-listing-labels`, `pattern-detail-labels`, `pattern-form-labels`
- 15 Section components (Dynamic Zone blocks): hero, cta-banner, stats-bar, featured-patterns, rich-text, feature-grid, tech-stack, mission-block, open-source-info, page-header, doc-section, api-reference, quick-nav, contributing, support-links
- 12 Shared/Layout components: nav-link, cta-button, footer-config, text-item, stat-item, key-value, feature-card, tech-group, api-endpoint, quick-nav-item, support-item, metadata (SEO)
- Azure Blob Storage upload provider (production media uploads)
- Comprehensive seed script (`data/seed.ts`) with all current hardcoded content

**Infrastructure (`deployment/scripts/provision-cms.ps1`, `.github/workflows/cms-container-deploy.yml`):**
- Azure MySQL Flexible Server (Burstable B1ms, free tier for 12 months)
- Azure Blob Storage (`strapi-media` container)
- Azure Container App for Strapi (0.25 vCPU, 0.5 GiB RAM, scale-to-zero)
- Updated `docker-compose.yml` for local dev (MySQL + Strapi services)
- Estimated cost: ~$10-15/month (free MySQL for 12 months, then ~$23-28/month)

**Frontend CMS Layer (`lib/cms/`):**
- `client.ts`: `fetchStrapi()` with ISR revalidation + `CmsUnavailableError` for graceful fallback
- `types.ts`: Full TypeScript types for all Strapi response shapes
- `queries.ts`: One function per Single Type, with hardcoded fallbacks when CMS unavailable
- `components.tsx`: `DynamicZone` renderer mapping `__component` to React components

**Frontend Integration (Phase 1 — fallback-safe):**
- `app/layout.tsx` → fetches `global` → passes nav/footer/labels to Header and Footer
- `app/page.tsx` → fetches `home-page` → passes CMS block data to Hero, FeaturedPatterns, StatsSection, CTASection
- `components/layout/Header.tsx`, `Footer.tsx`, `Navigation.tsx`, `UserMenu.tsx` → accept optional CMS props with hardcoded fallbacks
- `components/home/Hero.tsx`, `CTASection.tsx`, `FeaturedPatterns.tsx`, `StatsSection.tsx` → accept optional CMS props with hardcoded fallbacks
- `app/login/page.tsx` + `LoginForm.tsx` → fetches `login-page` → CMS-driven labels
- `app/not-found.tsx` → fetches `not-found-page` → CMS-driven 404 content

### Rationale
- Non-developer content editing without code deployments (marketing, labels, CTAs)
- A/B testing of copy and page layouts in future
- Content versioning and draft/publish workflows
- Future i18n readiness (Phase 8)
- SRS already specified CMS integration (Phase 3.2, Section 4.4)

### Incremental Integration Strategy
- **Phase 1 (current):** Server-side fetch with hardcoded fallbacks → zero downtime
- **Phase 2:** Replace remaining hardcoded content (about/docs pages, pattern label props) one component at a time
- **Phase 3:** Remove fallbacks once CMS is stable and seeded

### Alternatives Considered
- **Contentful** — paid above free tier, vendor lock-in for content model
- **Sanity.io** — excellent DX but more complex and higher cost
- **Directus** — great but less mature ecosystem
- **Custom DB tables** — rejected (adds schema complexity without editorial UX)

### Key Technical Notes
- `cms/` directory excluded from root `tsconfig.json` (Strapi has its own tsconfig)
- Strapi single types use `PUT /api/{singular-name}` for upserts
- ISR revalidation: 600s (global), 300s (pages), 3600s (labels), 3600s (static error pages)
- CMS data fetched only in Server Components (no `NEXT_PUBLIC_` prefix for `STRAPI_URL` / `STRAPI_API_TOKEN`)
- `error.tsx` stays client-side (Next.js requirement) — no CMS integration possible

### Status
- ✅ CMS.1: Content model design (all schemas defined)
- ✅ CMS.2: Infrastructure (docker-compose, Dockerfile, provisioning script, CI/CD)
- ✅ CMS.3: Strapi project setup (schemas, seed script)
- ✅ CMS.4: Frontend integration — Phase 1 (lib/cms/, layout, home, login, 404)
- ✅ CMS.5: Production deployment (Azure MySQL + Blob Storage + Container App, seeded, live)

---

## Decision 33: Strapi 5 Production Dockerfile — tsconfig.json + config/ Required at Runtime

**Date:** 2026-02-26
**Title:** Strapi 5 Production Image Must Include tsconfig.json and config/ Source Files
**Category:** Infrastructure / Docker / CMS

### Decision Details

Strapi 5's TypeScript production mode requires both `tsconfig.json` and the `config/` source TypeScript files to be present at runtime, even though the app runs from compiled `dist/`. This is a non-obvious requirement that caused repeated container crashes during initial production deployment.

### Root Cause

Strapi 5 uses `tsUtils.resolveOutDirSync()` to locate the compiled output directory by reading `outDir` from `tsconfig.json`. Without `tsconfig.json`, this function returns `null` and Strapi falls back to loading raw config from `config/` (source), which doesn't exist in a production image that only contains `dist/`. Result: `db.config.connection` is undefined → crash.

If only `tsconfig.json` is present (without `config/` source files), Strapi attempts to recompile TypeScript at startup and fails with `TS18003: No inputs were found in config file` because no `.ts` source files are in the image.

### Fix Applied (cms/Dockerfile production stage)

```dockerfile
# Strapi 5 requires tsconfig.json + config/ source at runtime to resolve compiled config paths
COPY --from=build --chown=strapi:strapi /app/tsconfig.json ./tsconfig.json
COPY --from=build --chown=strapi:strapi /app/config ./config

# Create writable directories required at runtime (non-root user cannot mkdir)
RUN mkdir -p /app/public/uploads /app/database/migrations && \
    chown -R strapi:strapi /app/public /app/database
```

### Why This Matters

- Omitting `tsconfig.json` → silent crash, misleading error about `db.config.connection`
- Omitting `config/` → TS compilation error at startup (not a build error)
- The pre-created `/app/database/migrations` directory is required because the non-root `strapi` user cannot `mkdir` at runtime

### Alternatives Considered

- **Patch tsconfig.json** to point `outDir` to `.` (no subdirectory) — would break the build stage
- **Use `node:alpine` without TypeScript support** — Strapi 5 does not support plain JavaScript projects at production time
- **Custom entrypoint that skips TS resolution** — too fragile, depends on internal Strapi internals

---

## Decision 34: Azure MySQL Flexible Server — francecentral Region Required

**Date:** 2026-02-26
**Title:** MySQL Flexible Server Unavailable in centralus; francecentral Used
**Category:** Infrastructure / Azure / Database

### Decision Details

Azure MySQL Flexible Server (Burstable B1ms SKU) is not available in `centralus` or `eastus2` for this subscription tier. `francecentral` was confirmed as the closest available region.

### Impact

- MySQL server located in `francecentral`, Container App environment in `centralus`
- Cross-region latency is negligible for a low-traffic CMS (Strapi reads happen at Next.js build/ISR time, not per user request)
- `provision-cms.ps1` has explicit `$MysqlLocation = "francecentral"` parameter

### Provider Registration

Both `Microsoft.DBforMySQL` and `Microsoft.Storage` resource providers required explicit registration before provisioning:

```bash
az provider register --namespace Microsoft.DBforMySQL --wait
az provider register --namespace Microsoft.Storage --wait
```

These are not auto-registered for all subscription types. The provisioning script now documents this as a prerequisite step.

---

## Decision 35: Azure Blob Storage — strapi-provider-upload-azure-storage-v5 for Strapi 5

**Date:** 2026-02-26
**Title:** Community Provider strapi-provider-upload-azure-storage-v5 Used for Azure Blob Media Uploads
**Category:** Infrastructure / Storage / CMS

### Decision Details

The official Strapi upload provider `@strapi/provider-upload-azure-storage` does not exist on npm (despite being referenced in some Strapi documentation). The community package `strapi-provider-upload-azure-storage-v5` (v1.1.0, peer dep `@strapi/strapi: ^5.0.0`) is the correct Strapi 5 compatible provider.

### Configuration

Provider only activated when `AZURE_STORAGE_ACCOUNT` env var is set — falls back to local filesystem in dev:

```typescript
// cms/config/plugins.ts
if (env('AZURE_STORAGE_ACCOUNT')) {
  config.upload = {
    config: {
      provider: 'strapi-provider-upload-azure-storage-v5',
      providerOptions: {
        account: env('AZURE_STORAGE_ACCOUNT'),
        accountKey: env('AZURE_STORAGE_ACCOUNT_KEY'),
        containerName: env('AZURE_STORAGE_CONTAINER'),
        ...
      }
    }
  };
}
```

### Blob Container Access

Container set to `--public-access blob` (individual blob public read, container listing private). This allows CMS media URLs to work in the Next.js frontend without authentication, while preventing directory browsing.

### Env Var Naming

Must use `AZURE_STORAGE_*` prefix (not `STORAGE_*`) to match provider expectations:
- `AZURE_STORAGE_ACCOUNT`
- `AZURE_STORAGE_ACCOUNT_KEY`
- `AZURE_STORAGE_CONTAINER`
- `AZURE_STORAGE_URL`

---

## Decision 36: Strapi Production Deployment — Azure Container Apps with Image Digest Pinning

**Date:** 2026-02-26
**Title:** Pin Strapi Container App to Specific Image Digest to Avoid Stale Cache
**Category:** Infrastructure / Deployment / Container Apps

### Decision Details

Azure Container Apps with `:latest` tag can serve stale images even after a new push because the platform may cache the previous layer locally. During initial Strapi production deployment, `az containerapp update --image ...latest` did not consistently pull the newly pushed image.

### Fix

Use explicit SHA256 digest when deploying a new image:

```bash
# Get the digest after push
DIGEST=$(az acr repository show --name craipatternssp54426 --image aipatterns-cms:latest --query digest -o tsv)

# Deploy with digest instead of :latest tag
az containerapp update \
  --name ca-aipatterns-cms-prod \
  --resource-group rg-aipatterns-prod \
  --image "craipatternssp54426.azurecr.io/aipatterns-cms@$DIGEST"
```

### CI/CD Implication

The `cms-container-deploy.yml` workflow should be updated to retrieve the digest post-push and deploy with it, rather than relying on `:latest`. This ensures each deployment uses the exact image that was built.

### Subscription Constraint

ACR Tasks (`az acr build`) are not available on this subscription tier (`TasksOperationsNotAllowed`). All Docker builds must be done locally or in GitHub Actions runners, then pushed to ACR with `docker push`.
- 🔲 CMS.4 Phase 2: about/docs pages, pattern label props propagation

---

## Decision 37: CMS Client — Catch Network Errors for Build-Time Fallback

**Date:** 2026-02-26
**Title:** Wrap `fetch()` in try/catch in `fetchStrapi` to Handle Network Failures During Docker Build
**Category:** Architecture / CMS / Build

### Problem

`lib/cms/client.ts::fetchStrapi` only threw `CmsUnavailableError` on HTTP-level failures (`res.ok === false`). Network-level errors — `TypeError: fetch failed` with `AggregateError` (ECONNREFUSED, DNS failure) — propagated unhandled. The `safeFetch` wrapper in `queries.ts` only catches `CmsUnavailableError`, so network errors crashed the build.

This caused 3 consecutive CI failures: the Docker `npm run build` step pre-renders `/_not-found`, which calls `getNotFoundPage()` → `safeFetch` → `fetchStrapi`. With `STRAPI_URL` not reachable at build time (it's a runtime env var, not a build arg), `fetch()` throws `TypeError`, which bypassed the fallback entirely.

### Fix

```typescript
let res: Response;
try {
  res = await fetch(url.toString(), { headers, next: { revalidate } });
} catch {
  // Network error (ECONNREFUSED, DNS failure, etc.) — treat as CMS unavailable
  throw new CmsUnavailableError(path);
}
```

Both network errors and HTTP errors now surface as `CmsUnavailableError`, which `safeFetch` catches and replaces with the hardcoded fallback object. The frontend renders with fallback content during Docker build when Strapi is unreachable, then fetches live content at request time via ISR.

### Alternative Considered

Pass `STRAPI_URL` as a Docker `--build-arg` so the build can reach Strapi. Rejected: Strapi is not guaranteed reachable from the CI runner, it couples the build to runtime infrastructure, and the fallback pattern is the correct abstraction.

---

## Decision 38: Strapi On-Demand ISR Webhook — Production Setup

**Date:** 2026-02-26
**Title:** `REVALIDATE_SECRET` as Container App Secret; CI Workflow Deploys All CMS Env Vars
**Category:** Infrastructure / CMS / Security

### Problem

After deploying `app/api/revalidate/route.ts`, two infrastructure gaps prevented it from working:

1. `REVALIDATE_SECRET` was not set in the production Container App — all webhook calls returned 401.
2. `STRAPI_URL`, `STRAPI_API_TOKEN`, `REVALIDATE_SECRET`, `AUTH_URL` were absent from `frontend-container-deploy.yml` `--set-env-vars` — each CI deployment would silently clear them.
3. The Strapi webhook had never been created (0 webhooks configured).

### Resolution

**Container App secrets** (via `az containerapp secret set`):
- `strapi-api-token` — read-only Strapi API token
- `revalidate-secret` — webhook shared secret

**CI workflow** (`frontend-container-deploy.yml`):
- Added `CMS_CONTAINER_APP: 'ca-aipatterns-cms-prod'` to env block
- "Get Service URLs" step now resolves backend FQDN, CMS FQDN (`strapi_url`), and frontend FQDN (`auth_url`) from Azure at deploy time
- Deploy step now sets: `AUTH_URL`, `STRAPI_URL`, `STRAPI_API_TOKEN=secretref:strapi-api-token`, `REVALIDATE_SECRET=secretref:revalidate-secret`

**Strapi webhook** (Settings → Webhooks → "ISR Revalidation"):
- URL: `https://<frontend-fqdn>/api/revalidate?secret=<REVALIDATE_SECRET>`
- Events: all 5 entry events (create, update, delete, publish, unpublish)

### Validation

| Scenario | Result |
|----------|--------|
| Wrong/missing secret | 401 ✅ |
| Valid secret + known model (`home-page/entry.update`) | 200 `{revalidated:true, paths:["/"]}` ✅ |
| Valid secret + unknown model | 200 `{message:"Model not handled"}` ✅ |
| Strapi Trigger button | Success ✅ |
| Real save+publish — `entry.update` + `entry.publish` both fired | Confirmed via network log ✅ |

---

## Decision 39: Azure MySQL Flexible Server — Storage Reduced to 20 GB Minimum

**Date:** 2026-02-26
**Title:** Rebuild MySQL with 20 GB (minimum) Storage, Auto-Grow and Auto-IO Scaling Disabled
**Category:** Infrastructure / Database / Cost Optimisation

### Problem

The original MySQL Flexible Server was provisioned with 32 GB storage (`--storage-size 32`), auto-grow enabled, and auto-IO scaling enabled. For a small Strapi CMS with a 572 KB database, this was heavily over-provisioned and created risk of silent cost escalation via auto-grow and auto-IOPS triggers.

Azure does not support in-place storage reduction — a full delete-and-recreate was required.

### Resolution

1. Dumped `strapi_cms` database via Docker (`mysql:8.0 mysqldump`, 572 KB / 3154 lines).
2. Deleted `mysql-aipatterns-cms` server.
3. Recreated with minimum configuration:
   - `--storage-size 20` (20 GB — Azure Flexible Server minimum)
   - `--storage-auto-grow Disabled`
   - `--auto-scale-iops Disabled`
   - SKU remains `Standard_B1ms` (`Standard_B1s` is listed in `list-skus` but rejected at create time with `OperationNotSupportedStandardB1s`)
4. Restored dump; verified Strapi admin panel returns HTTP 200.

`provision-cms.ps1` updated to reflect all three flags.

### Before / After

| Setting | Before | After |
|---------|--------|-------|
| Storage | 32 GB | **20 GB** |
| Auto-grow | Enabled | **Disabled** |
| Auto-IO scaling | Enabled | **Disabled** |
| SKU | Standard_B1ms | Standard_B1ms (unchanged) |

### Alternatives Evaluated

- **`Standard_B1s` SKU** — listed in `az mysql flexible-server list-skus` for francecentral 8.0.21, but Azure rejects creation with `OperationNotSupportedStandardB1s`. Not available on this subscription tier.
- **In-place resize** — Azure MySQL Flexible Server only allows storage increases, not reductions. Delete-recreate is the only path.
