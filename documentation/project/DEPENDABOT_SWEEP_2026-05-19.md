# Dependabot PR Sweep — 12 Open PRs (2026-05-19)

## Context

12 Dependabot PRs had accumulated since the previous sweep on 2026-04-21 (see [DEPENDABOT_SWEEP_2026-04-21.md](DEPENDABOT_SWEEP_2026-04-21.md)). Date ranges: 1 from 2026-04-06, 7 from 2026-04-27, 4 from 2026-05-18.

CI was misleading: several PRs showed `Frontend Tests ❌` even though they only touched backend or CMS code. Two independent regressions explained that:

1. **13 new high-severity Next.js advisories** published between 2026-04-21 and 2026-05-18 (cache poisoning, App Router / Pages Router middleware bypass variants, XSS via CSP nonces and `beforeInteractive` scripts, SSRF via WebSocket upgrades, DoS in Image Optimization API and Cache Components, dynamic route param injection, more). These broke the `npm audit --omit=dev --audit-level=high` gate in [.github/workflows/test.yml:88](../../.github/workflows/test.yml#L88), failing every PR's frontend job regardless of scope.
2. **PR #41 bumped `react` without `react-dom`**: jest cannot initialize when those two are version-skewed. The same patch lived in #43 as a separate PR.

The sweep first cleared the CI block (Phase A), then merged the queue in dependency order.

---

## Resolution

### Phase A — Unblock CI (#48)
`next` bumped from `^16.2.4` to `^16.2.6` on `chore/next-cve-bump`. Audit gate flips back to EXIT=0 (only 2 moderate transitive `postcss` findings remain, below the gate). Recorded as **Decision 68** in [TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md).

### Phase B — Pair-merge react + react-dom (#49)
`react` and `react-dom` bumped together to `19.2.5` on `chore/react-19.2.5-pair`. Dependabot auto-closed the now-superseded #41 and #43 once main matched.

### Phase C — Sweep low-risk PRs
Merged in this order to avoid lockfile-shift conflicts:
| # | Title | Notes |
|---|-------|-------|
| #37 | codecov/codecov-action SHA bump | CI-only |
| #38 | azure/login 2.3.0 → 3.0.0 | Major bump; workflows already use the v3 OIDC param shape (`client-id`/`tenant-id`/`subscription-id`), so no change required |
| #39 | isomorphic-dompurify 3.9.0 → 3.14.0 | Patch/minor; rebased by Dependabot post-merge |
| #40 | chromatic 15.3.0 → 16.10.1 (dev-only) | Major bump; dev dep, no runtime |
| #23 | esbuild 0.24.2 → 0.28.0 (`cms/`) | CMS-local; no production impact |

### Phase D — Defer lucide-react v1 (#50, closing #42)
lucide-react `1.0` **removed all brand icons** (Github, LinkedIn, Twitter/X, YouTube, TikTok, Facebook, etc.). The bump broke the build immediately on `import { Github } from 'lucide-react'` used in:
- [components/layout/Footer.tsx](../../components/layout/Footer.tsx)
- [components/home/CTASection.tsx](../../components/home/CTASection.tsx)
- [app/about/page.tsx](../../app/about/page.tsx)

Added a `version-update:semver-major` ignore rule for `lucide-react` in [.github/dependabot.yml](../../.github/dependabot.yml). Recorded as **Decision 69**. The 0.x line continues; v1 will be re-evaluated if the brand-icon situation changes upstream or we adopt an inline-SVG strategy.

### Phase E — May-18 batch
After Phase A unblocked the audit gate:
| # | Title | Outcome |
|---|-------|---------|
| #44 | better-sqlite3 11.10.0 → 12.10.0 (`cms/`) | Merged |
| #45 | dotnet-servicing group (9 updates) | Merged |
| #46 | ef-core group (6 updates, 8.0.26 → 8.0.27) | **Auto-closed** — `Microsoft.*` pattern in dotnet-servicing already covered the EF Core packages, so #45's merge made #46 a no-op |
| #47 | test-infrastructure / FluentAssertions 8.9.0 → 8.10.0 | Merged after `close+reopen` to refresh the merge ref |

### Phase F — Verification (final)
Local gauntlet on `main` after the sweep:
- `npm audit --omit=dev --audit-level=high` → **EXIT 0** (2 moderate `postcss` findings remain, below gate)
- `npm run test:ci` → **396/396 pass**, coverage 74.95 / 78.44 / 70.67 / 75.10 (all ≥ 70%)
- `dotnet build && dotnet test` → 0 warnings / 0 errors / **114/114 pass** (29 Core + 38 Data + 47 Api)

---

## Outcome

- 8 PRs merged: #48, #49, #37, #38, #39, #40, #23, #50, #44, #45, #47
- 4 PRs closed without merge: #41, #43 (superseded by #49), #42 (lucide v1 deferred), #46 (no-op)
- 2 new decisions logged: **#68** (Next.js 16.2.6 CVE patch), **#69** (lucide-react v1 deferral)
- 1 ignore rule added to `dependabot.yml` (lucide-react semver-major)

A fresh batch of 6 Dependabot PRs (#51-56) was raised by the Monday weekly schedule mid-sweep; those are out of scope for this sweep and remain open for the next session.

## Surprises / lessons

- The "Frontend Tests fail on backend PRs" pattern is not a flaky test — it's the production `npm audit` gate flagging new Next.js CVEs. When the gate fails on every PR regardless of scope, **diagnose the gate, not the PRs**.
- Dependabot package-group patterns can overlap: `Microsoft.*` in `dotnet-servicing` already matches `Microsoft.EntityFrameworkCore.*` that the `ef-core` group targets. Merging dotnet-servicing made the ef-core PR redundant, and Dependabot correctly auto-closed it.
- `@dependabot rebase` is a no-op if the branch has no merge-base changes that affect the diff. `@dependabot recreate` regenerates the PR from current main. For the .NET PRs whose `main` shifts were in JS-land, only `close+reopen` reliably refreshed the GitHub merge ref so CI re-evaluated against new main.
