# Bug-Sweep Findings Ledger

**Last Updated:** 2026-06-04
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
| BSW-0003 | RUN-20260603b | `/patterns` | none | minor | accepted — clamp an out-of-range `page` to the last valid page (or show a per-page "no results" state, not the empty-corpus message); owner: frontend | `/patterns?page=50` (or `?page=999`) renders the status live region "6 patterns found" while the body simultaneously shows "No patterns available — There are no patterns yet. Check back later."; the out-of-range page is not clamped and the empty-corpus message is factually false (6 patterns exist) → expected an out-of-range page clamps to a valid page (showing results), or at minimum does not announce "6 patterns found" alongside a false "no patterns yet" empty state. | FUNCTIONAL_REQUIREMENTS.md §2 (Pagination) + cross-cutting invariant 5 (empty/loading states resolve sensibly, not contradictory) | patterns-out-of-range-page-contradicts-count |

---

## Fixed

Accepted findings whose fix has landed.

| ID | Surface | Severity | Finding | Fixed on |
|----|---------|----------|---------|----------|
| BSW-0002 | `/patterns/[slug]` (repro: `/patterns/clean-architecture-ai-refactoring`) | major | Vote POST to the configured local API origin (`http://localhost:5255`) was blocked by the CSP `connect-src` directive — `next.config.mjs` allow-listed only the prod origins (`*.azurecontainerapps.io`/`*.azurewebsites.net`), so clicking vote emitted 2 `console.error` CSP violations and the count never updated. Fix: `connect-src` now derives the API origin from `NEXT_PUBLIC_API_BASE_URL` (`new URL(...).origin`, deduped, unparseable values ignored) — unconditionally, because `next build` forces `NODE_ENV=production`, so a non-prod gate would have left prod-build E2E/Lighthouse runs against a local backend still blocked. Hardened: `__tests__/config/csp.test.ts` (derived origin present + path stripped, static allow-list intact, dedup, unset/unparseable fallback). Verified live: vote POST → 200 OK, count 42→43, zero console errors. | 2026-06-04 |
| BSW-0001 | `/about` (systemic: also `/docs`, `/patterns/new`, `/patterns/[slug]`, `/patterns/[slug]/edit`) | minor | Document `<title>` doubled the site suffix (`About \| AI Enterprise Patterns \| AI Enterprise Patterns`) — pages hardcoded `\| AI Enterprise Patterns` into their own `title` while `app/layout.tsx` `title.template` appends it again. Fix: dropped the suffix from the five page titles + the about-page CMS fallback `seo.title` (`lib/cms/queries.ts`). Hardened: `__tests__/seo/page-titles.test.ts` (per-page bare-title assertions), `lib/cms/__tests__/queries.test.ts` (fallback `seo.title` bare — also gates the `cms-sync-fallbacks` workflow's verify step, blocking a regressing sync PR), and per-route suffix-count e2e tests in `e2e/critical-flows.spec.ts`. Residual: the Strapi backup content (`backups/cms/2026-04-11`) still carries the suffixed title — correct it in Strapi at the next CMS session and re-backup, else a future fallback sync PR will fail its test gate. | 2026-06-04 |

---

## Rejected (suppression memory)

This section **is** the suppression list the auditor loads at the start of every run — a `{surface, signature}` here is never re-reported. `reject_reason` ∈ `by-design` / `false-positive` / `wont-fix` / `duplicate` / `deferred`.

| ID | Surface | Signature | Finding (1-line) | Reason | Rejected on | Durable action |
|----|---------|-----------|------------------|--------|-------------|----------------|
| _(none yet)_ | | | | | | |
