#!/usr/bin/env bash
# scripts/cms/mint-token.sh
#
# Resets the local Strapi admin password and mints a fresh read-only API token.
# Called automatically by restore.sh after every restore, or standalone.
#
# Usage:
#   bash scripts/cms/mint-token.sh                        # reset password + restart + mint
#   bash scripts/cms/mint-token.sh --no-reset-password    # skip password reset (already known-good)
#   bash scripts/cms/mint-token.sh --no-restart           # skip docker restart
#
# Outputs:
#   - Token printed as the LAST line of stdout (capture with $(...) or tail -1)
#   - Token also written to scripts/cms/.env.local-token (gitignored)
#
# Env:
#   MYSQL_CONTAINER      — docker container name for MySQL (default: aipatterns-mysql)
#   STRAPI_CONTAINER     — docker container name for Strapi (default: aipatterns-strapi)
#   STRAPI_ADMIN_URL     — base URL for Strapi admin API (default: http://localhost:1337)
#   STRAPI_HEALTH_URL    — health endpoint (default: http://localhost:1337/_health)
#   HEALTH_TIMEOUT       — seconds to wait for Strapi ready (default: 120)
#   ADMIN_EMAIL          — admin email (default: admin@aipatterns.dev)
#   ADMIN_PASSWORD       — admin password to set/use (default: Admin12345)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-aipatterns-mysql}"
STRAPI_CONTAINER="${STRAPI_CONTAINER:-aipatterns-strapi}"
STRAPI_ADMIN_URL="${STRAPI_ADMIN_URL:-http://localhost:1337}"
STRAPI_HEALTH_URL="${STRAPI_HEALTH_URL:-http://localhost:1337/_health}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@aipatterns.dev}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin12345}"
TOKEN_FILE="${REPO_ROOT}/scripts/cms/.env.local-token"

RESET_PASSWORD=1
DO_RESTART=1

for arg in "$@"; do
  case "${arg}" in
    --no-reset-password) RESET_PASSWORD=0 ;;
    --no-restart)        DO_RESTART=0 ;;
  esac
done

echo "[mint-token] Starting..." >&2

# ── Step 1: Reset admin password in MySQL ─────────────────────────────────────
if [[ "${RESET_PASSWORD}" == "1" ]]; then
  echo "[mint-token] Resetting admin password via bcrypt..." >&2

  # Generate bcrypt hash of Admin12345 using bcryptjs from cms/node_modules
  CMS_BCRYPT_PATH="${REPO_ROOT}/cms/node_modules/bcryptjs"
  BCRYPT_HASH=$(CMS_BCRYPT_PATH="${CMS_BCRYPT_PATH}" ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
    node -e "
const bcrypt = require(process.env.CMS_BCRYPT_PATH);
const hash = bcrypt.hashSync(process.env.ADMIN_PASSWORD, 10);
process.stdout.write(hash);
")

  # Pipe the SQL via stdin to avoid shell expansion of '$' characters in bcrypt hashes
  printf "UPDATE admin_users SET password='%s' WHERE email='%s';\n" \
    "${BCRYPT_HASH}" "${ADMIN_EMAIL}" | \
  docker exec -i "${MYSQL_CONTAINER}" \
    mysql \
      --user=strapi \
      --password=strapiPassword123 \
      strapi_cms >&2

  echo "[mint-token] Admin password reset." >&2
fi

# ── Step 2: Restart Strapi so it picks up fresh DB state ─────────────────────
if [[ "${DO_RESTART}" == "1" ]]; then
  echo "[mint-token] Restarting Strapi container..." >&2
  docker restart "${STRAPI_CONTAINER}" >&2
  echo "[mint-token] Waiting for Strapi at ${STRAPI_HEALTH_URL}..." >&2
  elapsed=0
  until curl --silent --fail "${STRAPI_HEALTH_URL}" > /dev/null 2>&1; do
    if [[ ${elapsed} -ge ${HEALTH_TIMEOUT} ]]; then
      echo "ERROR: Strapi did not become healthy after ${HEALTH_TIMEOUT}s." >&2
      exit 1
    fi
    printf "." >&2
    sleep 3
    elapsed=$((elapsed + 3))
  done
  echo " ready (${elapsed}s)" >&2
fi

# ── Step 3: Log in via admin API to get JWT ───────────────────────────────────
echo "[mint-token] Logging in as ${ADMIN_EMAIL}..." >&2

LOGIN_RESPONSE=$(curl --silent --show-error \
  --request POST \
  --header "Content-Type: application/json" \
  --data "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" \
  "${STRAPI_ADMIN_URL}/admin/login")

HTTP_STATUS=$(echo "${LOGIN_RESPONSE}" | node -e "
let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
  const r=JSON.parse(d);
  process.stdout.write(r.data ? '200' : String(r.statusCode ?? r.error?.status ?? 'error'));
});" 2>/dev/null || echo "error")

if [[ "${HTTP_STATUS}" == "429" ]]; then
  echo "ERROR: Admin login rate-limited (429). Restart Strapi to reset the limit." >&2
  exit 1
fi

ADMIN_JWT=$(echo "${LOGIN_RESPONSE}" | node -e "
let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
  const r=JSON.parse(d);
  if (!r.data?.token) { process.stderr.write('Login failed: ' + JSON.stringify(r) + '\n'); process.exit(1); }
  process.stdout.write(r.data.token);
});")

echo "[mint-token] Login successful." >&2

# ── Step 4: Create a read-only API token ─────────────────────────────────────
DATE_LABEL="$(date +%Y-%m-%d)"
TOKEN_NAME="local-${DATE_LABEL}"

echo "[mint-token] Creating API token '${TOKEN_NAME}'..." >&2

TOKEN_RESPONSE=$(curl --silent --show-error \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${ADMIN_JWT}" \
  --data "{\"name\":\"${TOKEN_NAME}\",\"type\":\"full-access\",\"description\":\"Minted by mint-token.sh for local backup.sh use\"}" \
  "${STRAPI_ADMIN_URL}/admin/api-tokens")

API_TOKEN=$(echo "${TOKEN_RESPONSE}" | node -e "
let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
  const r=JSON.parse(d);
  if (!r.data?.accessKey) { process.stderr.write('Token creation failed: ' + JSON.stringify(r) + '\n'); process.exit(1); }
  process.stdout.write(r.data.accessKey);
});")

echo "[mint-token] API token created." >&2

# ── Step 5: Persist token to .env.local-token ─────────────────────────────────
printf "STRAPI_API_TOKEN=%s\n" "${API_TOKEN}" > "${TOKEN_FILE}"
echo "[mint-token] Token written to ${TOKEN_FILE}" >&2

# Output the token as the last line of stdout (for capture by callers)
echo "${API_TOKEN}"
