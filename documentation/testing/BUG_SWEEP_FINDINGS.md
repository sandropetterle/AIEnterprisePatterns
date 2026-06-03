# Bug-Sweep Findings Ledger

**Last Updated:** 2026-06-03
**Audience:** Sandro; anyone running `/bug-sweep`
**Purpose:** Living ledger for the on-demand browser bug-sweep. Records every run, the open candidates awaiting triage, accepted-and-fixed findings, and the rejected findings that form the suppression memory. Methodology: [BUG_SWEEP_DESIGN.md](./BUG_SWEEP_DESIGN.md).

> **Who writes this file:** only the `bug-sweep` skill (run mode appends `Open` + `Run log` rows; triage mode moves rows between sections and fills the run-log columns). The `bug-sweep-auditor` never writes here. Findings rows (`BSW-NNNN`) only ever come from a returned auditor finding — never speculatively.

---

## Run log

Each `/bug-sweep` run appends one row. `Accepted` / `Rejected (FP)` / `FP-rate` are filled at triage. FP-rate = rejected-as-false-positive ÷ reported; trending to ~0 across runs **is** convergence.

| Run | Date | Surfaces audited | Reported | Accepted | Rejected (FP) | FP-rate |
|-----|------|------------------|----------|----------|---------------|---------|
| RUN-20260603 | 2026-06-03 | 9 (`/`, `/patterns`, `/patterns/[slug]`, `/about`, `/docs`, `/login`, 404 bad-slug, `/patterns/new`, `/patterns/[slug]/edit`) | 1 (1 minor) | 1 | 0 | 0% |
| RUN-20260603b | 2026-06-03 | 9 (`/`, `/patterns`, `/patterns/[slug]`, `/about`, `/docs`, `/login`, 404 bad-slug, `/patterns/new`, `/patterns/[slug]/edit`) | 2 (1 major, 1 minor) | 2 | 0 | 0% |

---

## Open

Candidates awaiting triage, plus accepted-but-not-yet-fixed (with a remediation note + owner). Status ∈ `candidate` / `accepted`.

| ID | Run | Surface | Auth | Severity | Status | Observed → Expected | Oracle cite | Signature |
|----|-----|---------|------|----------|--------|---------------------|-------------|-----------|
| BSW-0001 | RUN-20260603 | `/about` (systemic: also `/docs`, `/patterns/new`, `/patterns/[slug]`) | none | minor | accepted — drop the hardcoded `\| AI Enterprise Patterns` suffix from each page's own `title`; let `app/layout.tsx` `title.template` append it once; owner: frontend | Document `<title>` doubled — e.g. `About \| AI Enterprise Patterns \| AI Enterprise Patterns` (same on `/docs`, `/patterns/new`, `/patterns/[slug]`) → expected single suffix `About \| AI Enterprise Patterns`. Root layout `title.template '%s \| AI Enterprise Patterns'` (`app/layout.tsx:17`) appends the suffix once; affected pages hardcode `\| AI Enterprise Patterns` into their own `title` (`app/about/page.tsx:10`, `app/docs/page.tsx:23`, `app/patterns/new/page.tsx:10`, `app/patterns/[slug]/page.tsx:55`), so it doubles. e2e title tests miss it (assert via `toContain`). | FUNCTIONAL_REQUIREMENTS.md §1 (Basic SEO) + `app/layout.tsx` `title.template` convention | page-title-suffix-doubled |
| BSW-0002 | RUN-20260603b | `/patterns/[slug]` (repro: `/patterns/clean-architecture-ai-refactoring`) | none | major | accepted — add the local API origin (`http://localhost:5255`, derived from `NEXT_PUBLIC_API_BASE_URL` in non-prod) to `connect-src` in `next.config.mjs:41`; owner: frontend | Clicking the vote button fires `POST http://localhost:5255/api/patterns/{id}/vote`, blocked by the CSP `connect-src` directive (`next.config.mjs:41` allow-lists `*.azurecontainerapps.io`/`*.azurewebsites.net`/`*.ciamlogin.com` but not the configured local API origin); 2 `console.error` "Refused to connect … violates Content Security Policy" emitted, vote count stays 42 — no optimistic update, no revert toast → expected the vote POST reaches the API and the count updates optimistically with revert-on-error, with no console.error and no CSP-blocked request. | FUNCTIONAL_REQUIREMENTS.md §3 (Voting: optimistic UI + revert-on-error) + CLAUDE.md (VotingButton optimistic UI) + cross-cutting invariants 1 (no console.error) & 2 (no blocked request); `next.config.mjs:41` | vote-csp-connect-src-blocked |
| BSW-0003 | RUN-20260603b | `/patterns` | none | minor | accepted — clamp an out-of-range `page` to the last valid page (or show a per-page "no results" state, not the empty-corpus message); owner: frontend | `/patterns?page=50` (or `?page=999`) renders the status live region "6 patterns found" while the body simultaneously shows "No patterns available — There are no patterns yet. Check back later."; the out-of-range page is not clamped and the empty-corpus message is factually false (6 patterns exist) → expected an out-of-range page clamps to a valid page (showing results), or at minimum does not announce "6 patterns found" alongside a false "no patterns yet" empty state. | FUNCTIONAL_REQUIREMENTS.md §2 (Pagination) + cross-cutting invariant 5 (empty/loading states resolve sensibly, not contradictory) | patterns-out-of-range-page-contradicts-count |

---

## Fixed

Accepted findings whose fix has landed.

| ID | Surface | Severity | Finding | Fixed on |
|----|---------|----------|---------|----------|
| _(none yet)_ | | | | |

---

## Rejected (suppression memory)

This section **is** the suppression list the auditor loads at the start of every run — a `{surface, signature}` here is never re-reported. `reject_reason` ∈ `by-design` / `false-positive` / `wont-fix` / `duplicate` / `deferred`.

| ID | Surface | Signature | Finding (1-line) | Reason | Rejected on | Durable action |
|----|---------|-----------|------------------|--------|-------------|----------------|
| _(none yet)_ | | | | | | |
