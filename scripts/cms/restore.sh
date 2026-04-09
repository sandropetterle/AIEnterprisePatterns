#!/usr/bin/env bash
# scripts/cms/restore.sh
#
# Restores a CMS backup bundle into a running local Strapi.
#
# Usage:
#   bash scripts/cms/restore.sh backups/cms/2026-04-09
#   bash scripts/cms/restore.sh                        # uses most recent bundle
#
# Optional env:
#   MYSQL_CONTAINER   — docker container name (default: aipatterns-mysql)
#   UPLOADS_VOLUME    — docker volume for strapi uploads (default: aipatterns_strapi-uploads)
#   STRAPI_HEALTH_URL — health endpoint (default: http://localhost:1337/_health)
#   HEALTH_TIMEOUT    — seconds to wait for Strapi ready (default: 120)
#   SKIP_SQL_RESTORE  — set to "1" to skip MySQL restore

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-aipatterns-mysql}"
UPLOADS_VOLUME="${UPLOADS_VOLUME:-aipatterns_strapi-uploads}"
STRAPI_HEALTH_URL="${STRAPI_HEALTH_URL:-http://localhost:1337/_health}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"
SKIP_SQL_RESTORE="${SKIP_SQL_RESTORE:-0}"

# ── Resolve bundle directory ──────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
  BUNDLE_DIR="$1"
  # Handle relative paths
  if [[ "${BUNDLE_DIR}" != /* ]]; then
    BUNDLE_DIR="${REPO_ROOT}/${BUNDLE_DIR}"
  fi
else
  # Find most recent bundle
  BUNDLE_DIR=$(ls -1d "${REPO_ROOT}/backups/cms"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] 2>/dev/null | sort | tail -1)
  if [[ -z "${BUNDLE_DIR}" ]]; then
    echo "ERROR: No backup bundle found under backups/cms/. Pass a path explicitly." >&2
    exit 1
  fi
fi

echo ""
echo "=== CMS Restore ==="
echo "Bundle dir : ${BUNDLE_DIR}"
echo ""

# ── Guard: bundle exists ──────────────────────────────────────────────────────
if [[ ! -d "${BUNDLE_DIR}" ]]; then
  echo "ERROR: Bundle directory not found: ${BUNDLE_DIR}" >&2
  exit 1
fi

# ── 0. Verify checksums ───────────────────────────────────────────────────────
echo "[0/4] Verifying checksums..."
if [[ ! -f "${BUNDLE_DIR}/metadata.json" ]]; then
  echo "ERROR: metadata.json not found in bundle." >&2
  exit 1
fi

node - <<'NODESCRIPT'
const fs     = require('fs');
const path   = require('path');
const crypto = require('crypto');

const bundleDir = process.env.BUNDLE_DIR;
const meta      = JSON.parse(fs.readFileSync(path.join(bundleDir, 'metadata.json'), 'utf8'));
let allOk       = true;

for (const [file, expected] of Object.entries(meta.checksums ?? {})) {
  if (!expected) { console.log(`  SKIP  ${file} (no checksum recorded)`); continue; }
  const fp = path.join(bundleDir, file);
  if (!fs.existsSync(fp)) {
    console.error(`  FAIL  ${file} — file missing`);
    allOk = false;
    continue;
  }
  const actual = crypto.createHash('sha256').update(fs.readFileSync(fp)).digest('hex');
  if (actual !== expected) {
    console.error(`  FAIL  ${file}\n       expected: ${expected}\n       got:      ${actual}`);
    allOk = false;
  } else {
    console.log(`  OK    ${file}`);
  }
}

if (!allOk) { console.error('\nChecksum verification FAILED.'); process.exit(1); }
console.log('\nAll checksums verified.');
NODESCRIPT

# ── 1. Ensure docker compose CMS stack is up ─────────────────────────────────
echo ""
echo "[1/4] Ensuring CMS docker stack is running..."
(cd "${REPO_ROOT}" && docker compose --profile cms up -d)

# ── 2. Wait for Strapi healthcheck ────────────────────────────────────────────
echo "[2/4] Waiting for Strapi at ${STRAPI_HEALTH_URL}..."
elapsed=0
until curl --silent --fail "${STRAPI_HEALTH_URL}" > /dev/null 2>&1; do
  if [[ ${elapsed} -ge ${HEALTH_TIMEOUT} ]]; then
    echo "ERROR: Strapi did not become healthy after ${HEALTH_TIMEOUT}s." >&2
    exit 1
  fi
  printf "."
  sleep 3
  elapsed=$((elapsed + 3))
done
echo " ready (${elapsed}s)"

# ── 3. MySQL restore ──────────────────────────────────────────────────────────
if [[ "${SKIP_SQL_RESTORE}" == "1" ]]; then
  echo "[3/4] MySQL restore skipped (SKIP_SQL_RESTORE=1)"
else
  echo "[3/4] Restoring MySQL dump..."
  DUMP_FILE="${BUNDLE_DIR}/dump.sql"

  if [[ ! -f "${DUMP_FILE}" ]]; then
    echo "WARNING: dump.sql not found in bundle — skipping MySQL restore." >&2
  elif grep -q "^-- dump skipped" "${DUMP_FILE}"; then
    echo "WARNING: dump.sql was not captured — skipping MySQL restore." >&2
  else
    # Drop and recreate the database, then import
    docker exec "${MYSQL_CONTAINER}" \
      mysql \
        --user=strapi \
        --password=strapi \
        -e "DROP DATABASE IF EXISTS strapi_cms; CREATE DATABASE strapi_cms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

    docker exec -i "${MYSQL_CONTAINER}" \
      mysql \
        --user=strapi \
        --password=strapi \
        strapi_cms \
      < "${DUMP_FILE}"

    echo "      → MySQL restored"
  fi
fi

# ── 4. Restore uploads volume ─────────────────────────────────────────────────
echo "[4/4] Restoring uploads volume..."
UPLOADS_FILE="${BUNDLE_DIR}/uploads.tar.gz"

if [[ ! -f "${UPLOADS_FILE}" ]]; then
  echo "WARNING: uploads.tar.gz not found — skipping uploads restore." >&2
elif [[ ! -s "${UPLOADS_FILE}" ]]; then
  echo "      → uploads.tar.gz is empty — nothing to restore"
else
  docker run --rm \
    -v "${UPLOADS_VOLUME}:/uploads" \
    -v "${BUNDLE_DIR}:/bundle:ro" \
    alpine \
    sh -c "rm -rf /uploads/* && tar xzf /bundle/uploads.tar.gz -C /uploads"
  echo "      → uploads restored"
fi

echo ""
echo "=== Restore complete from: ${BUNDLE_DIR} ==="
echo ""
echo "Local Strapi admin: http://localhost:1337/admin"
echo ""
