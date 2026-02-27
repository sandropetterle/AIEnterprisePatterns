# Decisions Archive

**Last Updated:** 2026-02-27
**Audience:** Architects, Senior Developers
**Purpose:** Store full text of compacted/superseded decisions from TECHNICAL_DECISIONS_LOG.md. Active decisions remain in the main log; only fully superseded entries are moved here.

---

## How This Works

When a decision is compacted (see `GOVERNANCE.md` Section 6):
1. The full text is moved here
2. A one-line stub with `[ARCHIVED]` status replaces it in `TECHNICAL_DECISIONS_LOG.md`
3. The architectural insight must be reflected in the relevant `documentation/architecture/` doc before archiving

---

## Archived Decisions

*No decisions archived yet. This file will grow as the project matures and decisions are superseded.*

---

## Next Compaction Candidates

The following decisions should be evaluated for archiving at the next compaction cycle (start of Phase 7):

| Decision | Reason | Propagated To |
|----------|--------|---------------|
| Decisions 1-5 (early architecture choices) | Established patterns now reflected in architecture docs | `BACKEND_ARCHITECTURE.md` |
| Azure infrastructure sizing decisions (13, 29, 39) | Only final state matters (20 GB, B1ms, auto-grow disabled) | `CMS_ARCHITECTURE.md` |
| One-time migration/fix decisions | Resolved permanently; historical context only | — |

Before compacting, verify the insight is documented in the relevant architecture file, then move the full text here and replace with a stub in the main log.
