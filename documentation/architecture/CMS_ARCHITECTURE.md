# CMS Architecture

**Last Updated:** 2026-04-09
**Audience:** Frontend Developers, Solutions Architects, Infrastructure Engineers
**Purpose:** Document the Strapi 5 CMS integration — content model, cold storage model, backup/restore workflow, and known operational gotchas.

---

## 1. Overview

Strapi 5 (headless CMS) manages all **static site content** — page copy, labels, navigation text, and marketing sections. Pattern data (the application's core domain entities) is stored in Azure SQL and managed via the API, not Strapi.

### Cold Storage Model (current)

As of Phase CMS Cold Storage (2026-04-09), Strapi runs **local-only**. Azure CMS resources (MySQL, Container App) are being removed for cost savings (~€14-16/mo). The frontend already had a full fallback pathway — production renders identically with or without a live Strapi instance.

| Concern | Before | After |
|---------|--------|-------|
| Strapi hosting | Azure Container App (live) | Local Docker only (`--profile cms`) |
| Content database | Azure MySQL Flexible Server | Local MySQL (Docker), backed up to git |
| Content source (production) | Live Strapi REST API | Compile-time fallback objects in `lib/cms/queries.ts` |
| Content archive | Not committed | `backups/cms/YYYY-MM-DD/` in git |
| Media storage | Azure Blob Storage (`staipatternsmedia`) | Retained — historical references |
| Monthly cost | ~€14-16 | ~€0.02 (storage only) |

**How content updates work in cold storage mode:**
1. `docker compose --profile cms up -d` — start local Strapi
2. Edit content in http://localhost:1337/admin
3. Run `scripts/cms/backup.sh` — creates dated bundle in `backups/cms/`
4. Run `scripts/cms/generate-fallbacks.ts` — updates compile-time fallbacks in `lib/cms/queries.ts`
5. Open PR → merge → frontend deploys automatically

**CMS Phase Status:**
- ✅ Phase 5.5: CMS Infrastructure deployed to Azure (2026-02-26)
- ✅ Phase 6.4–6.7: All 10 Single Types seeded and integrated (2026-03-03)
- 🔄 Phase CMS Cold Storage: Phases 1–5 complete — backup/restore scripts, initial bundle, generate-fallbacks, 3 GHA workflows, Azure MySQL + Container App deleted, IaC/code cleanup done (2026-04-10)

---

## 2. Content Model

Strapi content types and their purpose:

| Content Type | Purpose |
|-------------|---------|
| `global` | Shared navigation, footer, site-wide labels |
| `home-page` | Home page content (Dynamic Zone: hero, featured patterns, stats) |
| `about-page` | About page Dynamic Zone |
| `docs-page` | Documentation page Dynamic Zone |
| `login-page` | Login page labels |
| `error-page` | Error page content with fallback |
| `not-found-page` | 404 page content |
| `pattern-listing-labels` | Labels for SearchBar, FilterPanel, SortSelector, EmptyState, Pagination |
| `pattern-detail-labels` | Labels for all pattern detail sub-components |
| `pattern-form-labels` | Labels for PatternForm create/edit |

**Dynamic Zones** allow page-specific component sections to be managed from the CMS without code changes.

> **Note:** `docs-page` was never seeded in the production Strapi instance. Its fallback in `lib/cms/queries.ts` (empty object `{}`) is the production source of truth.

For the full component schema reference (field tables, dependency map, reuse guide), see [documentation/cms-components/COMPONENT_INDEX.md](../cms-components/COMPONENT_INDEX.md).

---

## 3. Infrastructure

### Current (Cold Storage — active)

| Component | Value |
|-----------|-------|
| Local CMS | `docker compose --profile cms up -d` → http://localhost:1337/admin |
| Local DB | MySQL (Docker, `aipatterns-mysql` container) |
| Content backups | `backups/cms/YYYY-MM-DD/` committed to git |
| Media references | Azure Blob Storage (`staipatternsmedia.blob.core.windows.net`, `strapi-media` container) — retained |
| Azure CMS hosting | Deleted (Phase CMS Cold Storage, 2026-04-10) |

### Historical (was live until Phase CMS Cold Storage)

| Component | Value |
|-----------|-------|
| CMS Framework | Strapi 5 |
| CMS Database | Azure MySQL Flexible Server (`mysql-aipatterns-cms.mysql.database.azure.com`), francecentral, B1ms, 20 GB |
| Hosting | Azure Container App (`ca-aipatterns-cms-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io`) |
| Media Storage | Azure Blob Storage (`staipatternsmedia.blob.core.windows.net`, `strapi-media` container, public read) |

---

## 4. Local Development

```bash
# Start Strapi + MySQL locally (requires --profile cms; they don't start by default)
docker compose --profile cms up -d

# Stop CMS containers when not in use
docker compose --profile cms down

# Access admin panel
http://localhost:1337/admin
# Credentials: admin@aipatterns.dev / Admin12345

# Seed content from scratch
STRAPI_API_TOKEN=<full-access-token> npx tsx cms/data/seed.ts
# Note: use full-access token for seeding (read-only token can't PUT); revoke after seeding

# Restore from most recent git backup
bash scripts/cms/restore.sh                     # auto-picks latest bundle
bash scripts/cms/restore.sh backups/cms/2026-04-09  # specific date
```

> **WSL2 memory cap:** `~/.wslconfig` — `memory=2560MB`, `swap=1GB`; container limits: sqlserver 1 GB, mysql 512 MB, strapi 512 MB. Only start `--profile cms` when actively working on CMS content.

---

## 5. Backup & Restore

### Bundle structure (`backups/cms/YYYY-MM-DD/`)

| File | Source | Purpose |
|------|--------|---------|
| `dump.sql` | `docker exec aipatterns-mysql mysqldump` | Full MySQL schema + data |
| `uploads.tar.gz` | `strapi-uploads` docker volume | Locally-uploaded media |
| `content.json` | Strapi REST API `GET /api/{uid}` × 10 single types | Portable, version-diffable content |
| `metadata.json` | Script | Strapi URL, Node version, date, SHA-256 checksums |

### Scripts

```bash
# Create a backup of the running local Strapi
STRAPI_API_TOKEN=<token> bash scripts/cms/backup.sh

# Restore from a backup bundle
bash scripts/cms/restore.sh backups/cms/2026-04-09

# Backup against remote Strapi (e.g. during initial capture)
STRAPI_URL=https://... STRAPI_API_TOKEN=<token> SKIP_SQL_DUMP=1 bash scripts/cms/backup.sh

# Refresh compile-time fallbacks in lib/cms/queries.ts from latest backup
npx tsx scripts/cms/generate-fallbacks.ts

# Refresh from a specific backup date
BACKUP_DATE=2026-04-09 npx tsx scripts/cms/generate-fallbacks.ts
```

The `generate-fallbacks.ts` script reads `content.json` from the backup, strips Strapi internal fields (id, documentId, timestamps), and rewrites the delimited `// --- fallback:<name>:start/end ---` regions in `lib/cms/queries.ts`. After running, review the diff, run `npx tsc --noEmit && npm test`, then commit.

### Initial production backup (committed)

The `backups/cms/2026-04-09/` bundle was captured from the live Azure production Strapi before deletion:
- `dump.sql`: 3,159 lines, 96 tables — authoritative MySQL dump from `mysql-aipatterns-cms`
- `content.json`: 9/10 single types (docs-page absent — never seeded in production)
- `uploads.tar.gz`: empty — no media was uploaded to Azure Blob Storage
- All SHA-256 checksums verified in `metadata.json`

---

## 6. Frontend CMS Client

**`lib/cms/client.ts`** — `fetchStrapi(path, options)`:
- Wraps `fetch()` with error handling
- Network errors (ECONNREFUSED, AggregateError) throw `CmsUnavailableError`
- Enables graceful fallback to hardcoded defaults when Strapi is unavailable

**`lib/cms/queries.ts`** — Content type query functions:
- `getHomePage()`, `getGlobal()`, etc.
- Each uses `safeFetch()` which catches `CmsUnavailableError` and returns a fallback object
- **In cold storage mode:** the fallback objects are the authoritative production content
- Uses `populate` parameters to include nested components (see §9 for quirks)

**`lib/cms/types.ts`** — TypeScript types for all Strapi responses

**`lib/cms/components.tsx`** — Dynamic Zone component renderers mapped by `__component` field

---

## 7. ISR Revalidation

> **Note:** ISR on-demand revalidation applies only when a live Strapi instance is running (local dev or future cloud restore). In cold storage mode, content changes flow through `lib/cms/queries.ts` fallbacks and deploy on PR merge.

On-demand revalidation ensures Next.js ISR cache is cleared when content changes in Strapi.

**Webhook:** Strapi fires a POST to `https://<frontend>/api/revalidate?secret=<REVALIDATE_SECRET>` on every entry event (create, update, delete, publish, unpublish).

**Route handler:** `app/api/revalidate/route.ts`
- Validates the `secret` query parameter
- Calls `revalidatePath()` for the affected page(s)
- Returns `{revalidated: true, paths: [...]}` on success

**ISR revalidation times:**
| Route | Time-based TTL | On-demand |
|-------|---------------|-----------|
| Home (`/`) | 300s | ✅ |
| Global layout | 3600s | ✅ |
| Pattern listings | 120s | — |
| Pattern details | 600s | — |

---

## 8. Populate API Quirks

> ⚠️ **Known gotcha:** `populate[component]=*` fails with HTTP 400 if the component has a Media relation field (e.g., `seo.ogImage`). Use explicit field selection instead:

```
# ❌ Fails when component has media relation:
populate[seo]=*

# ✅ Use explicit field selection:
populate[seo][fields][0]=title&populate[seo][fields][1]=description
```

Wildcard `*` only works for scalar fields within a component.

---

## 9. Deployment Gotchas

These are hard-won lessons from the CMS deployment. Ignoring them will cause cryptic failures.

1. **`@strapi/provider-upload-azure-storage` does not exist on npm.** Use `strapi-provider-upload-azure-storage-v5` (v1.1.0).

2. **Production Dockerfile must include `tsconfig.json` + `config/` source files.** Strapi 5 needs both at runtime to resolve compiled config paths via `tsUtils.resolveOutDirSync`. Without them: crash with `Cannot destructure property 'client' of 'db.config.connection'`.

3. **Pre-create `/app/database/migrations` in Dockerfile** with non-root ownership. The `strapi` user can't `mkdir` at runtime.

4. **Azure Container Apps `:latest` tag can serve stale images.** Use explicit `@sha256:DIGEST` when deploying to force-pull the new image.

5. **ACR Tasks not available** on this subscription tier. Build locally and push: `docker buildx build --platform linux/amd64`.

6. **Use `npm install` not `npm ci`** in the Dockerfile (no lockfile in Strapi).

7. **`DATABASE_CLIENT` must be `mysql`** not `mysql2` (Strapi 5 dialect names changed).

8. **`tsconfig.json` must include `"./src/**/*.json"`** so JSON schema files are copied to `dist/`.

9. **`docker compose restart` doesn't pick up env var changes.** Use `docker compose up -d --force-recreate`.

10. **On-demand revalidation webhook local URL** uses `host.docker.internal:3000`, not `localhost:3000`.

11. **`az provider register --namespace Microsoft.Storage --wait`** required before first provisioning run.

12. **Docker dev stage (`target: dev`) skips `strapi build`** — `npm run develop` handles build+watch automatically.

13. **Admin user creation (first time only):** `POST /admin/register-admin` with initial credentials.

14. **API token creation:** `POST /admin/api-tokens` with an admin JWT in the Authorization header. `lifespan` must be one of `null`, `604800000`, `2592000000`, or `7776000000` (not arbitrary ms values).

---

## 10. Key Files

| File | Purpose |
|------|---------|
| `cms/` | Strapi 5 project root (retained for local authoring) |
| `cms/data/seed.ts` | Seeds all hardcoded content into Strapi |
| `cms/Dockerfile` | Production container build (retained; used for local dev) |
| `scripts/cms/backup.sh` | Creates a dated backup bundle from a running local Strapi |
| `scripts/cms/restore.sh` | Restores a backup bundle into a running local Strapi |
| `scripts/cms/generate-fallbacks.ts` | Refreshes compile-time fallbacks in `lib/cms/queries.ts` from a backup's `content.json` |
| `backups/cms/` | Git-committed backup bundles (authoritative content archive) |
| `lib/cms/client.ts` | Frontend CMS HTTP client |
| `lib/cms/queries.ts` | Content type query functions with delimited compile-time fallback regions |

---

## 11. Rollback to Live CMS

If the cold storage model needs to be reversed:

1. Restore `infrastructure/modules/cms.bicep` from git history
2. Restore the `module cms` call in `infrastructure/main.bicep` and `mysqlAdminPassword` parameter
3. Recreate KV secrets (from backup metadata or manually)
4. `az deployment group create` with updated parameters
5. Run `bash scripts/cms/restore.sh` against new Azure MySQL (SSH tunnel or temporary public access)
6. Restore `STRAPI_URL` / `STRAPI_API_TOKEN` env on the web Container App
7. Deploy frontend

Expected restoration time: ~2-3 hours (dominated by MySQL Flexible Server provisioning).

---

## 12. Related Decisions

See [../decisions/TECHNICAL_DECISIONS_LOG.md](../decisions/TECHNICAL_DECISIONS_LOG.md):
- Decisions 28–39: CMS implementation history (provider choice, MySQL region constraints, storage sizing, image deployment, webhook setup)
- Decision 65: CMS Cold Storage Architecture (cost reduction rationale, alternatives evaluated, trade-offs)
