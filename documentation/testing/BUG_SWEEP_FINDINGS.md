# Bug-Sweep Run Log

**Last Updated:** 2026-06-05
**Audience:** Sandro; anyone running `/bug-sweep`
**Purpose:** Run context for the on-demand browser bug-sweep — one row per run with the FP-rate convergence metric. **Findings themselves live on GitHub Issues** (label `bug-sweep`), not in this file. Methodology: [BUG_SWEEP_DESIGN.md](./BUG_SWEEP_DESIGN.md).

> **Who writes this file:** only the `bug-sweep` skill (run mode appends a `Run log` row; triage mode fills its `Accepted` / `Rejected (FP)` / `FP-rate` columns). Findings are filed as GitHub issues by the skill, only ever from a returned auditor finding — never speculatively.

---

## Where the findings live

| State | GitHub query |
|---|---|
| Awaiting triage | `gh issue list --label bug-sweep --label "triage:candidate" --state open` |
| Accepted, fix pending | `gh issue list --label bug-sweep --label "triage:accepted" --state open` |
| Fixed | `gh issue list --label bug-sweep --state closed --search "reason:completed"` |
| Rejected (= suppression memory) | `gh issue list --label bug-sweep --state closed --search "reason:\"not planned\""` |

Each issue body carries a `<!-- bug-sweep:meta -->` block with `{surface, signature, run}` — the cross-run suppression key. Never strip it.

Pre-GitHub ledger IDs were backfilled 2026-06-05: BSW-0001 → [#73](https://github.com/sandropetterle/AIEnterprisePatterns/issues/73), BSW-0002 → [#74](https://github.com/sandropetterle/AIEnterprisePatterns/issues/74), BSW-0003 → [#75](https://github.com/sandropetterle/AIEnterprisePatterns/issues/75).

---

## Run log

Each `/bug-sweep` run appends one row. `Accepted` / `Rejected (FP)` / `FP-rate` are filled at triage. FP-rate = rejected-as-false-positive ÷ reported; trending to ~0 across runs **is** convergence.

| Run | Date | Surfaces audited | Reported | Issues | Accepted | Rejected (FP) | FP-rate |
|-----|------|------------------|----------|--------|----------|---------------|---------|
| RUN-20260603 | 2026-06-03 | 9 (`/`, `/patterns`, `/patterns/[slug]`, `/about`, `/docs`, `/login`, 404 bad-slug, `/patterns/new`, `/patterns/[slug]/edit`) | 1 (1 minor) | #73 (backfilled) | 1 | 0 | 0% |
| RUN-20260603b | 2026-06-03 | 9 (`/`, `/patterns`, `/patterns/[slug]`, `/about`, `/docs`, `/login`, 404 bad-slug, `/patterns/new`, `/patterns/[slug]/edit`) | 2 (1 major, 1 minor) | #74, #75 (backfilled) | 2 | 0 | 0% |
