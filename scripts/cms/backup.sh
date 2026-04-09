#!/usr/bin/env bash
# scripts/cms/backup.sh
#
# Backs up a running local Strapi into a dated bundle under backups/cms/YYYY-MM-DD/.
# Can also target a remote Strapi via STRAPI_URL env var.
#
# Usage:
#   bash scripts/cms/backup.sh                         # local Strapi (default)
#   STRAPI_URL=https://... bash scripts/cms/backup.sh  # remote Strapi
#   DATE=2026-04-09 bash scripts/cms/backup.sh         # force a specific date label
#
# Required env:
#   STRAPI_API_TOKEN  — read-only (or full-access) API token
#
# Optional env:
#   STRAPI_URL        — default: http://localhost:1337
#   DATE              — override today's date (YYYY-MM-DD)
#   MYSQL_CONTAINER   — docker container name for mysqldump (default: aipatterns-mysql)
#   SKIP_SQL_DUMP     — set to "1" to skip MySQL dump (e.g. when targeting remote Strapi only)
#   UPLOADS_VOLUME    — docker volume for strapi uploads (default: aipatterns_strapi-uploads)

set -euo pipefail

STRAPI_URL="${STRAPI_URL:-http://localhost:1337}"
DATE_LABEL="${DATE:-$(date +%Y-%m-%d)}"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-aipatterns-mysql}"
SKIP_SQL_DUMP="${SKIP_SQL_DUMP:-0}"
UPLOADS_VOLUME="${UPLOADS_VOLUME:-aipatterns_strapi-uploads}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUNDLE_DIR="${REPO_ROOT}/backups/cms/${DATE_LABEL}"

# Single-type UIDs matching cms/data/seed.ts
SINGLE_TYPES=(
  global
  home-page
  about-page
  docs-page
  login-page
  not-found-page
  error-page
  pattern-listing-labels
  pattern-detail-labels
  pattern-form-labels
)

# Populate params per type (mirrors queries.ts POPULATE presets)
declare -A POPULATE_PARAMS
POPULATE_PARAMS["global"]="populate[navigation]=*&populate[footer][populate][links]=*"
POPULATE_PARAMS["home-page"]="populate[content][populate]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription"
POPULATE_PARAMS["about-page"]="populate[content][populate]=*&populate[header]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription"
POPULATE_PARAMS["docs-page"]="populate[content][populate]=*&populate[header]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription"
POPULATE_PARAMS["login-page"]="populate=*"
POPULATE_PARAMS["not-found-page"]="populate=*"
POPULATE_PARAMS["error-page"]="populate=*"
POPULATE_PARAMS["pattern-listing-labels"]="populate=*"
POPULATE_PARAMS["pattern-detail-labels"]="populate=*"
POPULATE_PARAMS["pattern-form-labels"]="populate=*"

echo ""
echo "=== CMS Backup ==="
echo "Strapi URL : ${STRAPI_URL}"
echo "Bundle dir : ${BUNDLE_DIR}"
echo "Date label : ${DATE_LABEL}"
echo ""

# ── Guard: STRAPI_API_TOKEN required ──────────────────────────────────────────
if [[ -z "${STRAPI_API_TOKEN:-}" ]]; then
  echo "ERROR: STRAPI_API_TOKEN is not set." >&2
  exit 1
fi

# ── 0. Create bundle directory ────────────────────────────────────────────────
mkdir -p "${BUNDLE_DIR}"

# ── 1. MySQL dump (local only, skippable) ────────────────────────────────────
if [[ "${SKIP_SQL_DUMP}" == "1" ]]; then
  echo "[skip] MySQL dump skipped (SKIP_SQL_DUMP=1)"
else
  echo "[1/4] MySQL dump..."
  if docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
    docker exec "${MYSQL_CONTAINER}" \
      mysqldump \
        --user=strapi \
        --password=strapi \
        --single-transaction \
        --routines \
        --triggers \
        strapi_cms \
      > "${BUNDLE_DIR}/dump.sql"
    echo "      → dump.sql written"
  else
    echo "WARNING: Container '${MYSQL_CONTAINER}' not running — skipping SQL dump." >&2
    # Write an empty marker so metadata can still reference the file
    echo "-- dump skipped: container not running" > "${BUNDLE_DIR}/dump.sql"
  fi
fi

# ── 2. Strapi uploads volume ──────────────────────────────────────────────────
echo "[2/4] Uploads volume..."
if docker volume ls --format '{{.Name}}' | grep -q "^${UPLOADS_VOLUME}$"; then
  docker run --rm \
    -v "${UPLOADS_VOLUME}:/uploads:ro" \
    -v "${BUNDLE_DIR}:/out" \
    alpine \
    tar czf /out/uploads.tar.gz -C /uploads .
  echo "      → uploads.tar.gz written"
else
  echo "WARNING: Volume '${UPLOADS_VOLUME}' not found — creating empty archive." >&2
  tar czf "${BUNDLE_DIR}/uploads.tar.gz" -T /dev/null 2>/dev/null || \
    touch "${BUNDLE_DIR}/uploads.tar.gz"
fi

# ── 3. Content JSON via Strapi REST API ───────────────────────────────────────
echo "[3/4] Fetching content JSON..."
CONTENT_JSON="{}"

for uid in "${SINGLE_TYPES[@]}"; do
  params="${POPULATE_PARAMS[$uid]:-populate=*}"
  url="${STRAPI_URL}/api/${uid}?${params}"

  echo "      GET /api/${uid}"
  response=$(curl --silent --fail \
    --header "Authorization: Bearer ${STRAPI_API_TOKEN}" \
    "${url}" 2>&1) || {
    echo "WARNING: Failed to fetch ${uid} — response: ${response}" >&2
    continue
  }

  # Strapi 5: response is { data: { ... } }
  data=$(echo "${response}" | python3 -c "import sys,json; r=json.load(sys.stdin); print(json.dumps(r.get('data', r), ensure_ascii=False))" 2>/dev/null || \
         node -e "const r=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(JSON.stringify(r.data ?? r, null, 2))" <<< "${response}" 2>/dev/null || \
         echo "${response}")

  # Merge into content JSON: { uid: data, ... }
  CONTENT_JSON=$(echo "${CONTENT_JSON}" | \
    python3 -c "
import sys, json
content = json.load(sys.stdin)
data = json.loads(sys.stdin.read() if False else '''${data//\'/\'\\\'\'}''')
" 2>/dev/null || echo "${CONTENT_JSON}")
done

# Write content.json using Node (always available alongside Next.js)
node - <<'NODESCRIPT'
const fs = require('fs');
const path = require('path');

const bundleDir = process.env.BUNDLE_DIR;
const strapiUrl = process.env.STRAPI_URL;
const token = process.env.STRAPI_API_TOKEN;

const uids = [
  'global', 'home-page', 'about-page', 'docs-page', 'login-page',
  'not-found-page', 'error-page', 'pattern-listing-labels',
  'pattern-detail-labels', 'pattern-form-labels'
];

const populateParams = {
  'global':                    'populate[navigation]=*&populate[footer][populate][links]=*',
  'home-page':                 'populate[content][populate]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription',
  'about-page':                'populate[content][populate]=*&populate[header]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription',
  'docs-page':                 'populate[content][populate]=*&populate[header]=*&populate[seo][fields][0]=title&populate[seo][fields][1]=description&populate[seo][fields][2]=keywords&populate[seo][fields][3]=ogTitle&populate[seo][fields][4]=ogDescription',
  'login-page':                'populate=*',
  'not-found-page':            'populate=*',
  'error-page':                'populate=*',
  'pattern-listing-labels':    'populate=*',
  'pattern-detail-labels':     'populate=*',
  'pattern-form-labels':       'populate=*',
};

async function fetchUid(uid) {
  const params = populateParams[uid] || 'populate=*';
  const url = `${strapiUrl}/api/${uid}?${params}`;
  const res = await fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (!res.ok) {
    throw new Error(`GET /api/${uid} → HTTP ${res.status}`);
  }
  const json = await res.json();
  // Strapi 5 wraps in { data: { ... } }
  return json.data ?? json;
}

(async () => {
  const content = {};
  let hasError = false;

  for (const uid of uids) {
    try {
      content[uid] = await fetchUid(uid);
      console.log(`      ✓ ${uid}`);
    } catch (err) {
      console.error(`      ✗ ${uid}: ${err.message}`);
      hasError = true;
    }
  }

  fs.writeFileSync(
    path.join(bundleDir, 'content.json'),
    JSON.stringify(content, null, 2) + '\n',
    'utf8'
  );

  if (hasError) {
    console.error('\nWARNING: Some UIDs failed to fetch — content.json may be incomplete.');
    process.exit(1);
  }
})();
NODESCRIPT

echo "      → content.json written"

# ── 4. metadata.json with SHA-256 checksums ───────────────────────────────────
echo "[4/4] Writing metadata.json..."

node - <<'NODESCRIPT'
const fs   = require('fs');
const path = require('path');
const crypto = require('crypto');

const bundleDir  = process.env.BUNDLE_DIR;
const strapiUrl  = process.env.STRAPI_URL;
const dateLabel  = process.env.DATE_LABEL;

function sha256(filePath) {
  const buf = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(buf).digest('hex');
}

const files = ['dump.sql', 'uploads.tar.gz', 'content.json'];
const checksums = {};

for (const f of files) {
  const fp = path.join(bundleDir, f);
  checksums[f] = fs.existsSync(fp) ? sha256(fp) : null;
}

// Detect Strapi version from local cms/package.json if available
let strapiVersion = 'unknown';
const pkgPath = path.join(bundleDir, '../../..', 'cms', 'package.json');
try {
  const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
  strapiVersion = pkg.dependencies?.['@strapi/strapi'] ?? 'unknown';
} catch { /* not available — acceptable for remote backups */ }

const metadata = {
  date:          dateLabel,
  strapiUrl,
  strapiVersion,
  nodeVersion:   process.version,
  createdAt:     new Date().toISOString(),
  checksums,
};

fs.writeFileSync(
  path.join(bundleDir, 'metadata.json'),
  JSON.stringify(metadata, null, 2) + '\n',
  'utf8'
);

console.log('      → metadata.json written');
console.log('');
console.log('Checksums:');
for (const [f, h] of Object.entries(checksums)) {
  console.log(`  ${h ?? '(missing)'}  ${f}`);
}
NODESCRIPT

echo ""
echo "=== Backup complete: ${BUNDLE_DIR} ==="
echo ""
