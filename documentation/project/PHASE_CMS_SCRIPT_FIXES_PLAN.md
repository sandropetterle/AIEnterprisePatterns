# Phase — CMS Cold Storage Script Fixes

**Status:** Planned
**Priority:** HIGH (blocks Phase 7 verification)
**Created:** 2026-04-10
**Context:** Phase 7 (verification) of the CMS Cold Storage plan exposed 6 bugs in `scripts/cms/backup.sh` and `scripts/cms/restore.sh`. The scripts were written targeting a Linux/GHA runner but never tested end-to-end on the local Windows + Git Bash + Docker Desktop environment. This plan catalogues every issue found and defines the fix for each, plus a post-restore token-minting step that the scripts currently lack.

---

## Bugs Found During Phase 7.3 (Backup Round-Trip)

### Bug 1 — Wrong MySQL password in both scripts

**Symptom:** `ERROR 1045 (28000): Access denied for user 'strapi'@'localhost'`

**Root cause:** Both `backup.sh` and `restore.sh` used `--password=strapi` but `docker-compose.yml` sets `MYSQL_PASSWORD: strapiPassword123`.

**Status:** Already fixed in working tree (uncommitted).

**Fix:**
- `backup.sh`: `--password=strapi` → `--password=strapiPassword123`
- `restore.sh`: `--password=strapi` → `--password=strapiPassword123` (two occurrences: DROP/CREATE and import)

---

### Bug 2 — Wrong default Docker volume name

**Symptom:** `docker run -v aipatterns_strapi-uploads:/uploads` fails silently or references wrong volume.

**Root cause:** Both scripts defaulted to `UPLOADS_VOLUME=aipatterns_strapi-uploads` but Docker Compose prefixes volumes with the project directory name: the real volume is `aienterprisepatterns_strapi-uploads`.

**Status:** Already fixed in working tree (uncommitted).

**Fix:**
- `backup.sh`: default → `aienterprisepatterns_strapi-uploads`
- `restore.sh`: default → `aienterprisepatterns_strapi-uploads`

---

### Bug 3 — Git Bash MSYS path conversion mangles Docker volume mount paths

**Symptom:** `tar: can't open 'C:/Program Files/Git/out/uploads.tar.gz'` — Git Bash on Windows rewrites `/out` to `C:/Program Files/Git/out` inside `docker run -v ... alpine tar czf /out/...` commands.

**Root cause:** MSYS2 (the POSIX layer under Git Bash) automatically converts any argument that looks like a Unix absolute path to a Windows path before passing it to the program. Docker Desktop on Windows expects Unix-style paths inside the container, so the conversion breaks the mount.

**Status:** Already fixed in working tree (uncommitted) by prefixing `docker run` calls with `MSYS_NO_PATHCONV=1`.

**Fix:**
- `backup.sh`: `MSYS_NO_PATHCONV=1 docker run --rm -v ...`
- `restore.sh`: `MSYS_NO_PATHCONV=1 docker run --rm -v ...`

**Note for GHA:** `MSYS_NO_PATHCONV=1` is harmless on Linux — the env var is simply ignored.

---

### Bug 4 — `mysqldump` warning contaminates `dump.sql`

**Symptom:** `ERROR 1064 (42000) at line 1: ... 'mysqldump: [Warning] Using a password ...'` during restore.

**Root cause:** `backup.sh` ran `docker exec mysqldump ... > dump.sql` which redirected both stdout (the SQL) and the mysqldump warning from stderr into the file. The `2>/dev/null` was either missing or placed after the `>` redirect in the wrong order.

**Status:** Partially fixed in working tree.

**Fix — `backup.sh`:**
```bash
docker exec "${MYSQL_CONTAINER}" \
  mysqldump ... strapi_cms \
  2>/dev/null \
  > "${BUNDLE_DIR}/dump.sql"
```
`2>/dev/null` discards stderr from the docker exec (which includes the mysqldump warning forwarded by the container). The `> file` captures only stdout (the SQL).

**Fix — `restore.sh` (defensive):**
```bash
grep -v "^mysqldump:" "${DUMP_FILE}" | \
docker exec -i "${MYSQL_CONTAINER}" mysql ...
```
This strips any `mysqldump:` lines before feeding to mysql, making restore robust against existing contaminated dumps.

**Fix — existing backup (`backups/cms/2026-04-09/dump.sql`):**
The committed dump.sql has the warning on line 1. After all script fixes are committed, regenerate `dump.sql` from a clean backup cycle and update the checksums in `metadata.json`. (Phase 3 below.)

---

### Bug 5 — Shell variables not exported for Node heredocs

**Symptom:** `Failed to parse URL from undefined/api/global?...` — the Node heredoc reads `process.env.BUNDLE_DIR` / `process.env.STRAPI_URL` but these were regular shell variables, not exported.

**Root cause:** `backup.sh` set `STRAPI_URL=...`, `BUNDLE_DIR=...`, `DATE_LABEL=...` as plain shell variables. The `node - <<'NODESCRIPT'` heredoc starts a child process that only inherits *exported* env vars. `STRAPI_API_TOKEN` works because it was passed in by the caller as an env var (inherited), but the three script-internal variables were not exported.

**Status:** Already fixed in working tree (uncommitted) — added `export` to `STRAPI_URL`, `BUNDLE_DIR`, `DATE_LABEL` in `backup.sh` and `BUNDLE_DIR` in `restore.sh`.

---

### Bug 6 — API token from production dump doesn't work after restore

**Symptom:** `HTTP 401` on all `/api/*` endpoints using the token from `.env.local`.

**Root cause:** Strapi hashes API tokens using the `API_TOKEN_SALT` environment variable before storing them in MySQL. The existing dump was captured from Azure production where the salt was a Key Vault secret (now purged). The local Docker Strapi uses `API_TOKEN_SALT: "localDevApiTokenSalt"` (from `docker-compose.yml`). After restoring the production dump into local MySQL, the token hashes in `strapi_api_tokens` don't match any bearer token hashed with the local salt — every token is invalid.

**Impact:** After `restore.sh` completes, the Strapi REST API is inaccessible for content reads. `backup.sh` (which needs a valid token) cannot run against the restored instance. The GitHub Actions workflows (`cms-backup.yml`, `cms-sync-fallbacks.yml`) work around this by minting fresh tokens via the admin API, but the *local* `restore.sh` + `backup.sh` workflow has no such step.

**Fix — add post-restore token minting to `restore.sh`:**

After the MySQL restore and Strapi restart, `restore.sh` should:
1. Reset the admin password in MySQL to the known local default (`Admin12345`) using bcrypt hash generated via `cms/node_modules/bcryptjs`.
2. Restart Strapi (`docker restart aipatterns-strapi`) so it picks up the new password.
3. Wait for health.
4. Log in via `POST /admin/login` to get an admin JWT.
5. Create a read-only API token via `POST /admin/api-tokens`.
6. Print the token to stdout and optionally write it to a `.env.cms-local` file for subsequent `backup.sh` use.

This mirrors exactly what `cms-backup.yml` and `cms-sync-fallbacks.yml` already do in their "Create Strapi API tokens" step.

**Alternatively (simpler):** Add a small companion script `scripts/cms/mint-token.sh` that does steps 1-6, and have `restore.sh` call it at the end. `backup.sh` would either accept `STRAPI_API_TOKEN` from the caller or call `mint-token.sh` if not set.

---

### Bug 7 (secondary) — `uploads.tar.gz` size check uses `-s` instead of content check

**Symptom:** `tar: can't open '/bundle/uploads.tar.gz'` — restore tries to unpack an archive that is a valid `.tar.gz` with no files (20 bytes for the empty tar header + gzip wrapper).

**Root cause:** `restore.sh` checked `[[ ! -s "${UPLOADS_FILE}" ]]` which tests for zero-size. An empty tar.gz is 20 bytes (non-zero), so it fell through to the `docker run` extraction step, which then failed due to Bug 3 (MSYS path mangling) or because the archive truly had nothing to extract.

**Status:** Already fixed in working tree (uncommitted) — changed to `tar tf "${UPLOADS_FILE}" | grep -q .` which checks for actual file entries.

---

### Bug 8 (secondary) — Strapi admin login rate limit (5 req/window)

**Symptom:** `429 Too Many Requests` after a few failed login attempts.

**Root cause:** Strapi's admin endpoint has a strict rate limit of 5 attempts per time window. During debugging, multiple login attempts with wrong passwords or bad tokens exhaust the limit. The only recovery is to restart Strapi (resets the in-memory rate limiter).

**Impact on scripts:** Not a script bug per se, but the `mint-token.sh` flow must avoid unnecessary login retries. The script should attempt login exactly once, check the response, and fail fast with a clear message if rate-limited.

**Mitigation in `restore.sh`:** Reset the admin password in MySQL *before* the first login attempt, and restart Strapi *once* after the password reset. This ensures the very first `POST /admin/login` succeeds, using at most 1 of the 5 allowed attempts.

---

## Implementation Plan

### Phase 1 — Fix backup.sh and restore.sh (script bugs 1-5, 7)

These fixes are already in the working tree. Verify they look correct, then commit.

Files touched:
- `scripts/cms/backup.sh` — password, volume name, MSYS_NO_PATHCONV, 2>/dev/null, exports
- `scripts/cms/restore.sh` — password, volume name, MSYS_NO_PATHCONV, grep -v mysqldump, export, tar content check

### Phase 2 — Add post-restore token minting (bug 6)

**2.1 Add `scripts/cms/mint-token.sh`**

A standalone script that:
1. Accepts optional `--reset-password` flag (default: on) and optional `--restart` flag (default: on).
2. If `--reset-password`: generates a bcrypt hash of `Admin12345` via Node + `cms/node_modules/bcryptjs`, runs `docker exec mysql UPDATE admin_users SET password=...`.
3. If `--restart`: runs `docker restart aipatterns-strapi`, waits for `/_health`.
4. Logs in: `POST /admin/login` with `admin@aipatterns.dev` / `Admin12345`. Fails fast on 429 or non-200.
5. Creates a read-only API token: `POST /admin/api-tokens` with name `local-<date>`.
6. Outputs the token on stdout (last line, for capture by caller).
7. Optionally writes `STRAPI_API_TOKEN=<token>` to `scripts/cms/.env.local-token` (gitignored).

**2.2 Update `restore.sh`**

After step [4/4] (uploads restore), add a step [5/5]:
```
[5/5] Minting local API token...
```
Calls `mint-token.sh --reset-password --restart`. Captures the token and prints it.

**2.3 Update `backup.sh`**

Add a fallback near the top: if `STRAPI_API_TOKEN` is not set, check for `scripts/cms/.env.local-token` and source it. If still not set, call `mint-token.sh --no-reset-password --no-restart` (assumes Strapi is already running with a valid admin password).

This makes the workflow:
```bash
bash scripts/cms/restore.sh backups/cms/2026-04-09
# ^ Token is printed at the end and saved to .env.local-token
bash scripts/cms/backup.sh
# ^ Automatically picks up the token from .env.local-token
```

### Phase 3 — Regenerate clean backup bundle

After Phases 1-2 are committed, run the full round-trip:

```bash
docker compose --profile cms down -v
docker compose --profile cms up -d
# Wait for Strapi health
bash scripts/cms/restore.sh backups/cms/2026-04-09
# (restore.sh now mints a token and writes .env.local-token)
bash scripts/cms/backup.sh
# Uses token from .env.local-token
# Writes to backups/cms/2026-04-10/ with clean dump.sql (no warning line)
```

Verify:
- `backups/cms/2026-04-10/dump.sql` does NOT start with `mysqldump: [Warning]`
- `metadata.json` checksums all match
- `content.json` contains all 9 (or 10) content types

Then re-run restore + backup a second time and diff:
```bash
bash scripts/cms/restore.sh backups/cms/2026-04-10
DATE=2026-04-10-verify bash scripts/cms/backup.sh
diff <(grep -v "^mysqldump:" backups/cms/2026-04-10/dump.sql) \
     <(grep -v "^mysqldump:" backups/cms/2026-04-10-verify/dump.sql)
# SQL should be identical (modulo timestamp comments)
diff backups/cms/2026-04-10/content.json backups/cms/2026-04-10-verify/content.json
# Content should be identical
```

### Phase 4 — Add `.gitignore` entries

Add to `.gitignore`:
```
scripts/cms/.env.local-token
backups/cms/*-roundtrip/
backups/cms/*-verify/
```

### Phase 5 — Complete remaining Phase 7 verification items

With scripts fixed, complete the original Phase 7 items:
- **7.3** Backup round-trip (should now work end-to-end)
- **7.4** Fallback generator round-trip (`npx tsx scripts/cms/generate-fallbacks.ts` → expect empty diff)
- **7.5** Live frontend smoke tests (curl live URL pages)
- **7.6** Cost confirmation (note: needs 48h after Phase 4 deletion — may already be past)

### Phase 6 — Commit and update docs/memory

- Commit all script fixes + mint-token.sh + updated .gitignore
- Clean up temporary backup bundles (`2026-04-10-roundtrip`, `2026-04-10-verify`)
- Update MEMORY.md with Phase 7 completion status
- Update `PHASE_CMS_COLD_STORAGE_PLAN.md` status markers

---

## Root Cause Summary

| Bug | Category | Why it happened |
|-----|----------|----------------|
| 1. Wrong MySQL password | Config mismatch | Hardcoded placeholder `strapi` instead of reading from docker-compose config |
| 2. Wrong volume name | Config mismatch | Assumed short prefix `aipatterns_` but Docker Compose uses full directory name `aienterprisepatterns_` |
| 3. MSYS path conversion | Windows compat | Scripts were written targeting Linux; MSYS2 rewrites `/out` → `C:/Program Files/Git/out` |
| 4. mysqldump warning in dump | Redirect order | `2>/dev/null` was missing; stderr from container was captured into stdout file |
| 5. Unexported shell vars | Shell semantics | `node -` heredoc runs as a child process; only exported vars are inherited |
| 6. Token salt mismatch | Crypto / env mismatch | Dump contains token hashes from production salt; local Strapi uses a different salt |
| 7. Empty tar size check | Logic error | 20-byte empty `.tar.gz` is non-zero-size, so `-s` test passed; should check for file entries |
| 8. Admin rate limit | Strapi behaviour | 5 login attempts per window; password reset + restart must happen before first attempt |

All 8 issues stem from the scripts never having been tested in a real end-to-end cycle on the target platform. The GitHub Actions workflows partially avoid issues 1-5 because GHA runs on Linux (no MSYS) and the `cms-backup.yml` workflow seeds fresh content rather than restoring a production dump (avoiding bug 6).

---

## File Inventory

### Created
- `scripts/cms/mint-token.sh` — post-restore token minting

### Edited
- `scripts/cms/backup.sh` — bugs 1-5 + auto-token fallback
- `scripts/cms/restore.sh` — bugs 1-5, 7 + calls mint-token.sh
- `.gitignore` — exclude token file and temp backup dirs

### Unmodified
- `.github/workflows/cms-backup.yml` — already handles token minting correctly
- `.github/workflows/cms-sync-fallbacks.yml` — already handles token minting correctly
- `.github/workflows/cms-restore-bundle.yml` — packages a bundle; no restore/token needed
- `scripts/cms/generate-fallbacks.ts` — no changes needed
