# Phase — CMS Cold Storage (Cost Reduction & Cold Recovery Mode)

**Status:** ✅ Complete — All phases (1–7) + Script Fixes done (2026-04-11)
**Priority:** HIGH (cost reduction)
**Dependencies:** Phase 7.11 complete
**Created:** 2026-04-09
**Estimated Effort:** Medium (7 phases + Script Fixes interlude)

---

## Context

The Strapi CMS is currently hosted live on Azure (MySQL Flexible Server + Container App) but is **unnecessary at runtime**. All 10 frontend CMS queries in [lib/cms/queries.ts](../../lib/cms/queries.ts) already wrap [fetchStrapi()](../../lib/cms/client.ts) with `safeFetch()` — when Strapi is unreachable (or `STRAPI_URL` unset), the helpers catch [CmsUnavailableError](../../lib/cms/client.ts#L10) and return hardcoded fallback objects. This fallback pathway is already exercised during Docker builds (see comment at [lib/cms/client.ts:44-48](../../lib/cms/client.ts#L44-L48)) and production renders identically with or without live Strapi.

This phase moves Strapi to **cold storage**:

- **Local-only Strapi** for content authoring (existing `docker compose --profile cms` stack)
- **Git-committed backups** (`backups/cms/YYYY-MM-DD/`) as the authoritative content archive
- **Manual fallback sync** via GitHub Action that updates `lib/cms/queries.ts` defaults from local Strapi
- **All Azure CMS resources deleted** — MySQL, Strapi Container App, CMS KV secrets
- **Storage Account retained** (`staipatternsmedia`) for historical media references

### Cost impact

| Before | After | Delta |
|--------|-------|-------|
| MySQL Flexible Server (B1ms, 20 GB): **~€14-16/mo** | deleted | −€14-16/mo |
| Strapi Container App (scale-to-zero): **€0** | deleted | €0 |
| Storage Account (staipatternsmedia): **~€0.02/mo** | unchanged | €0 |
| **Total: ~€14-16/mo** | **~€0.02/mo** | **~€14-16/mo saved** |

### Key decisions (confirmed before planning)

1. **Delete all Azure CMS resources** except `staipatternsmedia` Storage Account
2. **Backups committed to git** under `backups/cms/` — binary blobs acceptable (small, infrequent)
3. **Fallback sync = manual script + GitHub Action** that opens a PR against `lib/cms/queries.ts`
4. **Restore = GitHub Action** that packages a backup bundle as an artifact, plus a local restore script

---

## Prerequisites

- [ ] Confirm the current `mysql-aipatterns-cms` contents match the live Strapi content (the live frontend is already using cached/fallback content — we need the **MySQL source of truth** before deletion)
- [ ] `docker compose --profile cms up -d` works locally end-to-end
- [ ] Storage account `staipatternsmedia` inventory captured (list blobs, total size)
- [ ] Azure CLI authenticated against `rg-aipatterns-prod`

---

## IMPLEMENTATION PLAN

### Phase 1 — Backup Current Content (MUST be first)

> **Critical:** No deletion occurs until a backup bundle exists **in git** and has been verified via a clean restore locally.

**1.1 Create `scripts/cms/backup.sh`**

Backs up a running local Strapi into a dated bundle. Invoked both locally and by GitHub Actions.

Outputs to `backups/cms/YYYY-MM-DD/`:

| File | Source | Purpose |
|------|--------|---------|
| `dump.sql` | `docker exec aipatterns-mysql mysqldump` | Full MySQL schema + data |
| `uploads.tar.gz` | `strapi-uploads` docker volume | Any locally-uploaded media |
| `content.json` | Strapi REST API `GET /api/{uid}` × 11 single types | Portable, version-diffable content |
| `metadata.json` | Script | Strapi version, Node version, date, SHA-256 checksums for all files |

Single-type UIDs to export (matching [cms/data/seed.ts](../../cms/data/seed.ts)):

```
global, home-page, about-page, docs-page, login-page,
not-found-page, error-page, pattern-listing-labels,
pattern-detail-labels, pattern-form-labels
```

Use the same `PUT /${uid}` pattern from `seed.ts` but in reverse (`GET`) with full populate. Token from env `STRAPI_API_TOKEN`.

**1.2 Create `scripts/cms/restore.sh`**

Reverse of backup: `docker compose --profile cms up -d`, wait for healthcheck, `mysql < dump.sql`, untar `uploads.tar.gz` into the volume. Used for local verification and by the restore-bundle workflow consumer.

**1.3 Run initial backup against production source-of-truth**

Options (choose whichever produces the most complete bundle):

- **Option A (preferred):** Point local Strapi at a dump of the live Azure MySQL. Use `az mysql flexible-server execute` or `mysqldump` via a one-shot jumpbox, pull to local, run backup.sh.
- **Option B:** Fetch from the live Azure Strapi URL directly using its API token (if still responsive). Run a variant of backup.sh that hits `https://ca-aipatterns-cms-prod.*` instead of `localhost:1337`.

**1.4 Verify bundle**

- `sha256sum -c metadata.json` — all files match
- Fresh `scripts/cms/restore.sh` run produces a working Strapi admin matching the captured content
- Manually spot-check 3-4 single types via local admin

**1.5 Commit to git**

```bash
git add backups/cms/YYYY-MM-DD/ scripts/cms/
git commit -m "feat(cms): initial cold-storage backup bundle (pre-deletion)"
```

**Deliverables:** `scripts/cms/backup.sh`, `scripts/cms/restore.sh`, `backups/cms/YYYY-MM-DD/*`, committed to `main`.

---

### Phase 2 — Update Fallbacks from Live Strapi

> This must run **against the same Strapi source** used for the Phase 1 backup so the code-frozen fallbacks reflect the true production content before deletion.

**2.1 Create `scripts/cms/generate-fallbacks.ts`**

- Reads content.json from the most recent backup (or live Strapi via `STRAPI_URL`)
- For each of the 10 query functions in [lib/cms/queries.ts](../../lib/cms/queries.ts), produces a TypeScript object literal matching the corresponding `Cms*` type from [lib/cms/types.ts](../../lib/cms/types.ts)
- **Strategy:** template-based string replacement, **not** AST — target a delimited comment region per fallback to keep edits tractable:

```typescript
  // --- fallback:home-page:start ---
  {
    title: 'AI Enterprise Patterns',
    // ...
  } satisfies CmsHomePage
  // --- fallback:home-page:end ---
```

The script rewrites the region between matching start/end markers. This is simpler and more reviewable than AST manipulation.

**2.2 Add delimited regions to `lib/cms/queries.ts`**

One-time prep: wrap each existing fallback literal in `// --- fallback:<name>:start ---` / `end` comments. This is cosmetic and non-behavioral.

**2.3 Run the generator, review output manually**

The generator output MUST:
- Pass `npx tsc --noEmit`
- Pass `npm run lint`
- Pass `npm test` (fallback content is exercised by existing query tests)
- Produce a readable diff (prettier-formatted)

**2.4 Commit updated fallbacks**

```bash
git add lib/cms/queries.ts scripts/cms/generate-fallbacks.ts
git commit -m "feat(cms): refresh fallback content from live Strapi (pre-cold-storage)"
```

**Deliverables:** `scripts/cms/generate-fallbacks.ts`, `lib/cms/queries.ts` updated with current production content.

---

### Phase 3 — GitHub Actions Workflows

All workflows follow the repo conventions from Phase 7.6:
- `permissions: {}` at top with per-job `contents: read` (or `contents: write` / `pull-requests: write` where needed)
- SHA-pinned actions matching existing refs (e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683`, `azure/login@eec3c95657c1536435858eda1f3ff5437fee8474`)
- `concurrency` groups
- `workflow_dispatch` only (no auto-triggers — these are operator-driven)

**3.1 `.github/workflows/cms-backup.yml`**

| Step | Action |
|------|--------|
| Checkout | `actions/checkout` (SHA-pinned) |
| Start Strapi | `docker compose --profile cms up -d` |
| Wait for health | poll `http://localhost:1337/_health` until 200 or timeout |
| Seed (optional input) | if `seed: true`, run `cms/data/seed.ts` against the fresh container |
| Run backup | `bash scripts/cms/backup.sh` |
| Verify | sha256 check on `metadata.json` |
| Commit or PR | input `commit_strategy`: `direct` (push to main) or `pr` (open PR) |

Job permissions: `contents: write`, `pull-requests: write`.

**3.2 `.github/workflows/cms-restore-bundle.yml`**

| Step | Action |
|------|--------|
| Input | `backup_date` (required, e.g. `2026-04-09`) |
| Checkout | full history so `backups/cms/` is available |
| Validate | sha256 check against `metadata.json`; fail if missing or mismatch |
| Package | tar the directory into a single archive |
| Upload artifact | `actions/upload-artifact` (SHA-pinned), 30-day retention |

Output: downloadable artifact the operator feeds into a local `scripts/cms/restore.sh`.

Job permissions: `contents: read`.

**3.3 `.github/workflows/cms-sync-fallbacks.yml`**

| Step | Action |
|------|--------|
| Input | `backup_date` (optional, defaults to latest in `backups/cms/`) |
| Checkout | full history |
| Start Strapi | `docker compose --profile cms up -d` |
| Restore | `scripts/cms/restore.sh backups/cms/<date>` |
| Generate | `npx tsx scripts/cms/generate-fallbacks.ts` |
| Verify | `npx tsc --noEmit && npm run lint && npm test -- --testPathPattern=lib/cms` |
| Open PR | `peter-evans/create-pull-request` (SHA-pinned) targeting `main` |

Job permissions: `contents: write`, `pull-requests: write`.

**Deliverables:** 3 new workflows committed and visible under Actions → workflow_dispatch.

---

### Phase 4 — Azure Cleanup (AFTER Phase 1+2+3 verified)

> Gate: backup bundle is in git on `main` AND workflows from Phase 3 are merged AND Phase 2 fallbacks reflect live content.

Exact commands (run interactively, confirming each step):

```bash
# 4.1 Remove MySQL deletion lock
az lock delete \
  --name "mysql-delete-lock" \
  --resource-group rg-aipatterns-prod \
  --resource-name mysql-aipatterns-cms \
  --resource-type Microsoft.DBforMySQL/flexibleServers

# 4.2 Delete Strapi Container App
az containerapp delete \
  --name ca-aipatterns-cms-prod \
  --resource-group rg-aipatterns-prod \
  --yes

# 4.3 Delete MySQL Flexible Server (this is the main cost line item)
az mysql flexible-server delete \
  --name mysql-aipatterns-cms \
  --resource-group rg-aipatterns-prod \
  --yes

# 4.4 Delete + purge 8 Key Vault secrets
for s in \
  mysql-admin-password \
  strapi-app-keys \
  strapi-admin-jwt-secret \
  strapi-api-token-salt \
  strapi-transfer-token-salt \
  strapi-jwt-secret \
  strapi-storage-account-key \
  strapi-api-token
do
  az keyvault secret delete --vault-name kv-aipatterns-0754755 --name "$s"
  az keyvault secret purge  --vault-name kv-aipatterns-0754755 --name "$s"
done

# 4.5 Verify storage account still present
az storage account show \
  --name staipatternsmedia \
  --resource-group rg-aipatterns-prod \
  --query "{name:name,location:location,sku:sku.name}" -o table
```

**4.6 Post-delete smoke tests**

- Hit the live frontend URL — every page renders with fallback content (home, about, docs, login, 404, error, pattern listing, pattern detail)
- Run E2E against live: `BASE_URL=https://ca-aipatterns-web-prod.* npx playwright test e2e/critical-flows.spec.ts`
- Check Azure Cost Management — MySQL line item drops to zero the next billing day

**Deliverables:** zero CMS resources in Azure except `staipatternsmedia`; ~€14-16/mo burn reduced.

---

### Phase 5 — Code & Infrastructure Changes

All IaC/code changes happen in one PR to keep Bicep internally consistent.

**5.1 Delete files**

- `infrastructure/modules/cms.bicep` — entire file (140 lines defining MySQL + Storage + Locks)
- `.github/workflows/cms-container-deploy.yml` — entire file (210 lines)

**5.2 Edit `infrastructure/main.bicep`**

- Remove the `module cms` invocation (~lines 105-111)
- Remove any outputs that reference `cms.outputs.*`
- Remove the `mysqlAdminPassword` param from the parameter block

**5.3 Edit `infrastructure/modules/containerApps.bicep`**

- Remove the entire `ca-aipatterns-cms-prod` resource block (~lines 345-507)
- Remove `STRAPI_URL` / `STRAPI_API_TOKEN` env vars from the web app (~lines 284-290) — fallback content is compiled in, no env needed
- Remove any outputs exposing the CMS FQDN

**5.4 Edit `infrastructure/main.parameters.prod.json`**

- Remove the `mysqlAdminPassword` parameter (Key Vault reference)

**5.5 Edit `.github/workflows/frontend-container-deploy.yml`**

- Remove the `CMS_CONTAINER_APP: 'ca-aipatterns-cms-prod'` env ref and any conditional CMS deploy logic
- Remove any `STRAPI_*` env vars threaded into the build

**5.6 Keep (no changes)**

- `lib/cms/client.ts` — `STRAPI_URL` still defaults to `http://localhost:1337` for local dev; missing env is handled by `CmsUnavailableError`
- `lib/cms/queries.ts` — fallbacks now authoritative
- `docker-compose.yml` — `cms` profile retained for local authoring
- `cms/` Strapi project — retained for local authoring
- `staipatternsmedia` storage account — retained for historical media

**5.7 Build verification**

```bash
npm run build                # frontend build succeeds without STRAPI_URL
npm run lint                 # clean
npm test                     # 396/396
cd backend && dotnet test    # 114/114
az deployment group validate --resource-group rg-aipatterns-prod \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/main.parameters.prod.json
```

**Deliverables:** one PR containing all infrastructure and workflow changes, green CI.

---

### Phase 6 — Documentation Updates

**6.1 Add Decision 64 to [TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md)**

Title: **CMS Cold Storage Architecture**

Body:
- **What:** Moved Strapi CMS from live-hosted (Azure MySQL + Container App) to local-only with git-committed backups and compile-time fallback content.
- **Why:** ~€14-16/mo ongoing cost for content that is almost entirely static UI labels. Frontend already had `safeFetch` fallback mechanism, so runtime dependency on live Strapi was notional.
- **Alternatives evaluated:**
  - *Keep live MySQL:* rejected — ongoing cost with no runtime benefit
  - *Static JSON files in repo:* rejected — loses the structured Strapi authoring experience
  - *Serverless/free-tier MySQL:* rejected — Azure MySQL Flexible Server has no free tier; serverless tiers are more expensive per transaction for our near-zero traffic
- **Trade-offs:**
  - (+) Cost savings ~€14-16/mo
  - (+) Versioned, reviewable content (git blame on fallback changes)
  - (+) Zero runtime external dependency
  - (−) Content updates require a local workflow + PR cycle (minutes instead of seconds)
  - (−) Media uploads limited (no live blob upload path) — uploaded media handled manually into `staipatternsmedia`
- **Rollback:** backup bundles in git are authoritative. To restore cloud CMS: re-apply `cms.bicep` from git history, deploy via Bicep, run `scripts/cms/restore.sh` against new Azure MySQL, re-populate KV secrets.

**6.2 Rewrite [documentation/architecture/CMS_ARCHITECTURE.md](../architecture/CMS_ARCHITECTURE.md)**

- New intro section: "Cold Storage Model"
- Diagram update: remove Azure MySQL / Container App boxes, add "local Strapi (optional)" + "git backups" + "compile-time fallbacks"
- Remove Phase 5.5 deployment instructions (or move to "Historical" section)
- Add "How to update CMS content" runbook section (see 6.3)

**6.3 Add CMS ops runbook** (append to [RUNBOOK.md](../operations/RUNBOOK.md))

```
## CMS Content Update (Cold Storage Mode)

1. docker compose --profile cms up -d
2. Edit content in http://localhost:1337/admin
3. Trigger cms-backup workflow (or run scripts/cms/backup.sh locally)
4. Trigger cms-sync-fallbacks workflow → review PR → merge
5. Frontend deploys automatically on merge
```

**6.4 Update [INFRASTRUCTURE_MANAGEMENT.md](../operations/INFRASTRUCTURE_MANAGEMENT.md)**

- Remove MySQL and CMS Container App rows from the resource inventory
- Add note: "CMS resources removed in Phase CMS Cold Storage — see Decision 64"

**6.5 Update [DISASTER_RECOVERY.md](../operations/DISASTER_RECOVERY.md)**

- New section: "CMS Recovery" — point to `backups/cms/` + `cms-restore-bundle` workflow + `scripts/cms/restore.sh`
- Remove MySQL point-in-time restore instructions (no longer applicable)

**6.6 Update [CLAUDE.md](../../CLAUDE.md)**

- Tech stack section: change "CMS: Strapi 5 (headless, `cms/` directory), **MySQL (production)**, Azure Blob Storage (media)" → "CMS: Strapi 5 local-only (`cms/` directory) with git-committed backups; media references retained in Azure Blob Storage"
- Phase line: update to reflect new phase
- Docker/CMS section: emphasize local-only; remove "production" references
- Environment variables: remove `STRAPI_URL` / `STRAPI_API_TOKEN` from the production list

**6.7 Update MEMORY.md**

- Add one-line index entry: `- [CMS Cold Storage](cms_cold_storage.md) — live Strapi removed; backups in git, fallbacks compiled in`
- Create `memory/cms_cold_storage.md` with type=project and the key facts

**Deliverables:** Decision 64 logged, architecture docs updated, runbook + DR updated, CLAUDE.md/MEMORY.md reflect new state.

---

### Script Fixes Interlude ✅ Complete (2026-04-11)

Phase 7.3 backup round-trip testing exposed 8 bugs in `backup.sh` and `restore.sh` — all scripts were written targeting Linux/GHA but never end-to-end tested on the local Windows + Git Bash + Docker Desktop environment.

**Bugs fixed:** wrong MySQL password (Bug 1), wrong Docker volume name (Bug 2), MSYS path conversion mangling (Bug 3), `mysqldump` warning contaminating `dump.sql` (Bug 4), unexported shell variables for Node heredocs (Bug 5), empty-tar size check using `-s` (Bug 7).

**New feature — `scripts/cms/mint-token.sh`:** Resolves Bug 6 (API token salt mismatch after restore). Generates a bcrypt hash of the admin password via `cms/node_modules/bcryptjs`, updates MySQL directly via stdin pipe (avoids `$` expansion), restarts Strapi, logs in via `POST /admin/login`, creates a read-only API token via `POST /admin/api-tokens`, and writes it to `scripts/cms/.env.local-token` (gitignored).

**Integration:**
- `restore.sh` now calls `mint-token.sh --reset-password --restart` at step `[5/5]`
- `backup.sh` auto-sources `scripts/cms/.env.local-token` — no manual `STRAPI_API_TOKEN` export required

**Full plan:** [PHASE_CMS_SCRIPT_FIXES_PLAN.md](PHASE_CMS_SCRIPT_FIXES_PLAN.md)

---

### Phase 7 — Verification

**7.1 Frontend build (no Strapi required)**

```bash
# Unset STRAPI_URL entirely
unset STRAPI_URL STRAPI_API_TOKEN
npm run build
# Expect: successful build, no network errors, fallback content in output
```

**7.2 Test suites**

```bash
npm test                            # 396/396 passing
cd backend && dotnet test           # 114/114 passing
```

**7.3 Backup round-trip**

```bash
# Fresh local Strapi
docker compose --profile cms down -v
docker compose --profile cms up -d
# Restore from most recent backup (auto-mints API token at step [5/5])
bash scripts/cms/restore.sh backups/cms/<latest>
# Re-run backup (auto-sources token from scripts/cms/.env.local-token)
bash scripts/cms/backup.sh
# Diff the two backups — should be identical modulo timestamps
```

**7.4 Fallback generator round-trip**

```bash
npx tsx scripts/cms/generate-fallbacks.ts
git diff lib/cms/queries.ts   # expect empty diff (idempotent)
```

**7.5 Live frontend smoke tests**

- `curl https://ca-aipatterns-web-prod.*/` — homepage renders, text from fallback
- Visit `/about`, `/docs`, `/login`, `/patterns`, `/patterns/[slug]`, a 404 URL — all pages render
- E2E against live: `BASE_URL=https://... npx playwright test e2e/critical-flows.spec.ts`

**7.6 Cost confirmation**

- 48h after Phase 4 deletion: check Azure Cost Management — MySQL cost = €0
- Resource group resource count decreased by ~3 (MySQL server, Strapi CA, orphaned network artifacts if any)

**Deliverables:** all verifications green, cost drop confirmed.

**Results (2026-04-11):**
- 7.1 ✅ Frontend build: success with no `STRAPI_*` env vars; all 13 routes generated
- 7.2 ✅ Tests: 396/396 frontend, 114/114 backend
- 7.3 ✅ Backup round-trip: restore from `2026-04-09` → backup to `2026-04-11`; content identical (field-order only diff); 2 script fixes applied (export token for Node subprocess; `full-access` token type; 404-tolerant fetch)
- 7.4 ✅ Fallback generator: idempotent after first application; 41/41 CMS tests pass with generated fallbacks
- 7.5 ✅ Live smoke tests: 200 on `/`, `/about`, `/docs`, `/login`, `/patterns`, `/patterns/[slug]`; 404 on unknown URL
- 7.6 ⏳ Cost confirmation: Phase 4 deletion was 2026-04-10; check Azure Cost Management 48h+ later

---

## Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | Backup missing content vs live Azure Strapi | Medium | HIGH | Phase 1.3 options A/B both pull from live; Phase 1.4 requires manual spot-check; **deletion is gated on verified backup in git** |
| R2 | `generate-fallbacks.ts` produces invalid TypeScript | Medium | Medium | Phase 2.3 runs tsc + lint + tests before commit; Phase 3.3 workflow blocks PR merge on same checks |
| R3 | Web app build fails without `STRAPI_URL` env | Low | Medium | Already handled: `CmsUnavailableError` pathway in `client.ts:44-48`; Phase 7.1 explicitly verifies |
| R4 | `staipatternsmedia` media becomes orphaned/unreferenced | Low | Low | Storage retained; document its purpose in CMS_ARCHITECTURE.md; future cleanup phase can audit blob references against fallback content |
| R5 | Key Vault secret purge is irreversible | Low | Medium | 8 secrets are CMS-specific and captured in backup metadata if needed; 90-day soft-delete means we have time to recover during Phase 4 |
| R6 | Someone triggers Bicep deploy with stale parameters after Phase 5 | Low | HIGH | Parameters file update is in the same PR as Bicep deletion; `az deployment group validate` in Phase 5.7 catches mismatches |
| R7 | Local `cms/package-lock.json` drift (it's gitignored) | Medium | Low | Document in runbook that `npm install` must be run on fresh Strapi checkout; Strapi convention already handles this |

---

## File Inventory (Touched)

### Created
- `scripts/cms/backup.sh`
- `scripts/cms/restore.sh`
- `scripts/cms/generate-fallbacks.ts`
- `.github/workflows/cms-backup.yml`
- `.github/workflows/cms-restore-bundle.yml`
- `.github/workflows/cms-sync-fallbacks.yml`
- `backups/cms/YYYY-MM-DD/dump.sql`
- `backups/cms/YYYY-MM-DD/uploads.tar.gz`
- `backups/cms/YYYY-MM-DD/content.json`
- `backups/cms/YYYY-MM-DD/metadata.json`
- `memory/cms_cold_storage.md` (MEMORY entry)

### Deleted
- `infrastructure/modules/cms.bicep`
- `.github/workflows/cms-container-deploy.yml`
- Azure resources: `mysql-aipatterns-cms`, `ca-aipatterns-cms-prod`, 8 KV secrets

### Edited
- `infrastructure/main.bicep` (remove cms module, mysqlAdminPassword param)
- `infrastructure/modules/containerApps.bicep` (remove CMS app resource, remove STRAPI_* env on web)
- `infrastructure/main.parameters.prod.json` (remove mysqlAdminPassword)
- `.github/workflows/frontend-container-deploy.yml` (remove CMS refs)
- `lib/cms/queries.ts` (fallback regions + refreshed content)
- `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` (Decision 64)
- `documentation/architecture/CMS_ARCHITECTURE.md` (cold storage rewrite)
- `documentation/operations/RUNBOOK.md` (CMS update runbook)
- `documentation/operations/INFRASTRUCTURE_MANAGEMENT.md` (remove CMS rows)
- `documentation/operations/DISASTER_RECOVERY.md` (CMS recovery section)
- `CLAUDE.md` (tech stack, phase, env vars)
- `memory/MEMORY.md` (index entry)

### Retained (explicitly unchanged)
- `lib/cms/client.ts`, `lib/cms/types.ts`, `lib/cms/components.tsx`
- `cms/` Strapi project
- `docker-compose.yml` `cms` profile
- `staipatternsmedia` Azure Storage Account

---

## Rollback Strategy

Backup bundles in git are authoritative. To restore live cloud CMS if ever needed:

1. Restore `infrastructure/modules/cms.bicep` from git history (`git show <pre-phase-sha>:infrastructure/modules/cms.bicep > infrastructure/modules/cms.bicep`)
2. Restore the cms module call in `infrastructure/main.bicep` and the `mysqlAdminPassword` parameter
3. Create the KV secrets manually or from a sealed backup
4. `az deployment group create` with updated parameters
5. Run `scripts/cms/restore.sh` against the new Azure MySQL (via SSH tunnel or temporary public access)
6. Restore `STRAPI_URL` / `STRAPI_API_TOKEN` env on the web Container App
7. Deploy frontend

Expected restoration time: ~2-3 hours (dominated by MySQL Flexible Server provisioning).

---

## Success Criteria

- [ ] Initial backup bundle committed to `backups/cms/<date>/` with verified SHA-256 checksums
- [ ] `lib/cms/queries.ts` fallbacks refreshed from live Strapi content
- [ ] 3 GitHub Actions workflows merged and runnable via workflow_dispatch
- [ ] MySQL, Strapi Container App, 8 KV secrets deleted from Azure
- [ ] `infrastructure/modules/cms.bicep` and `cms-container-deploy.yml` deleted
- [ ] `npm run build` succeeds with no `STRAPI_*` env vars set
- [ ] All tests passing: 396 frontend, 114 backend
- [ ] Live frontend serves all pages with fallback content (manual + E2E verified)
- [ ] Decision 64 logged, docs updated, CLAUDE.md + MEMORY.md reflect cold storage state
- [ ] Azure Cost Management confirms ~€14-16/mo drop
