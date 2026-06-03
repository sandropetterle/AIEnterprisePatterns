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
| RUN-20260603 | 2026-06-03 | 9 (`/`, `/patterns`, `/patterns/[slug]`, `/about`, `/docs`, `/login`, 404 bad-slug, `/patterns/new`, `/patterns/[slug]/edit`) | 1 (1 minor) | | | |

---

## Open

Candidates awaiting triage, plus accepted-but-not-yet-fixed (with a remediation note + owner). Status ∈ `candidate` / `accepted`.

| ID | Run | Surface | Auth | Severity | Status | Observed → Expected | Oracle cite | Signature |
|----|-----|---------|------|----------|--------|---------------------|-------------|-----------|
| BSW-0001 | RUN-20260603 | `/about` (systemic: also `/docs`, `/patterns/new`, `/patterns/[slug]`) | none | minor | candidate | Document `<title>` doubled — e.g. `About \| AI Enterprise Patterns \| AI Enterprise Patterns` (same on `/docs`, `/patterns/new`, `/patterns/[slug]`) → expected single suffix `About \| AI Enterprise Patterns`. Root layout `title.template '%s \| AI Enterprise Patterns'` (`app/layout.tsx:17`) appends the suffix once; affected pages hardcode `\| AI Enterprise Patterns` into their own `title` (`app/about/page.tsx:10`, `app/docs/page.tsx:23`, `app/patterns/new/page.tsx:10`, `app/patterns/[slug]/page.tsx:55`), so it doubles. e2e title tests miss it (assert via `toContain`). | FUNCTIONAL_REQUIREMENTS.md §1 (Basic SEO) + `app/layout.tsx` `title.template` convention | page-title-suffix-doubled |

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
