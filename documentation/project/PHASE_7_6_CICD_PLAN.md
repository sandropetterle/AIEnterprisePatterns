# Phase 7.6: CI/CD Pipeline Quality — Evaluation & Implementation Plan

**Created:** 2026-03-18
**Status:** Evaluated — ready for implementation
**Parent:** Phase 7 — Quality & Hardening

---

## Context

Phase 7.5 audited IaC and Azure security, explicitly deferring "GitHub Actions SHA pinning" and "production approval gates" to 7.6. This phase audits all 4 GitHub Actions workflows for supply chain security, correctness, and operational robustness.

**Overall assessment:** The CI/CD foundation is solid — OIDC auth (no stored Azure credentials), path-filtered deploys, healthcheck gates with auto-rollback, Lighthouse CI + Chromatic quality gates, cross-browser E2E matrix. Findings are hardening improvements and one rollback correctness bug, not critical vulnerabilities.

**Scope:** `.github/workflows/` (4 files: `test.yml`, `frontend-container-deploy.yml`, `backend-container-deploy.yml`, `cms-container-deploy.yml`)

---

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | GitHub Actions not pinned to SHA — 6 unique actions, ~36 `uses:` references use mutable tags (`@v4`, `@v5`, `@v2`) | MEDIUM | Track 1 |
| 2 | No top-level `permissions` block in `test.yml` — defaults to broad read/write on push | MEDIUM | Track 2 |
| 3 | No `concurrency:` groups on any workflow — overlapping deploys possible on rapid pushes | MEDIUM | Track 2 |
| 4 | Rollback deploys `:latest` which was just overwritten with the broken build (all 3 deploy workflows) | MEDIUM | Track 2 |
| 5 | No `.github/dependabot.yml` — no automated dependency update PRs | MEDIUM | Track 3 |
| 6 | `test-summary` does not include `e2e-tests` — E2E failures on main don't block the summary | MEDIUM | Track 4 |
| 7 | Hardcoded Azure resource names duplicated across 3 deploy `env:` blocks | LOW | Accepted |

### Accepted Risks (LOW — document only)

| # | Finding | Rationale |
|---|---------|-----------|
| 7 | Hardcoded Azure resource names in deploy `env:` blocks | Values rarely change; repository variables add Settings dependency and reduce readability. Revisit if staging environment added. |
| 8 | CMS has no test gate | Strapi is managed CMS with minimal custom code; healthcheck provides adequate safety. |
| 9 | E2E tests don't run on PRs | By design — cost optimization, Entra dependency. Documented in `test.yml` comment. |
| 10 | `sleep 45`/`sleep 60` in healthchecks | Works reliably with scale-to-zero cold start. Polling loop deferred to 8+. |
| 11 | No staging environment | Single-developer project; healthcheck + auto-rollback provides adequate safety. |
| 12 | `fail_ci_if_error: false` on Codecov | Coverage thresholds enforced locally by Jest config. Codecov is convenience, not gate. |
| 13 | Azure CLI installed via curl-pipe-sudo-bash | Ephemeral runner, no persistent state. Common pattern. |
| 14 | Production approval gates | Single developer; `environment: 'Production'` already declared — can enable GitHub environment protection rules if needed without workflow changes. |

### Deferred to Other Phases

| Item | Phase | Rationale |
|------|-------|-----------|
| Docker base image SHA pinning | 7.7 | Container concern, not CI concern |
| Repository variables for Azure names | 8+ | Low risk, works fine as-is |
| Healthcheck polling loop (replace `sleep`) | 8+ | Current approach works reliably |

---

## Track 1: Action Version Pinning (Quick Win)

**Effort:** ~20 min | **Risk:** None — same code, immutable reference

Pin all 6 unique GitHub Actions to full commit SHAs across 4 workflow files (~36 `uses:` references).

**Actions to pin:**

| Action | Current Tag | Files |
|--------|-------------|-------|
| `actions/checkout` | `@v4` | All 4 |
| `actions/setup-node` | `@v4` | test.yml, frontend-deploy |
| `actions/setup-dotnet` | `@v4` | test.yml, backend-deploy |
| `actions/upload-artifact` | `@v4` | test.yml |
| `codecov/codecov-action` | `@v5` | test.yml |
| `azure/login` | `@v2` | All 3 deploy workflows |

**Format:** `uses: actions/checkout@<40-char-sha> # v4.x.x`

**Implementation:** Look up current SHAs at implementation time via `git ls-remote` or use `npx pin-github-action` CLI tool to automate.

**Files to modify:**
- `.github/workflows/test.yml` (~14 refs)
- `.github/workflows/frontend-container-deploy.yml` (~10 refs)
- `.github/workflows/backend-container-deploy.yml` (~7 refs)
- `.github/workflows/cms-container-deploy.yml` (~5 refs)

---

## Track 2: Workflow Security & Correctness Hardening (Quick Win)

**Effort:** ~30 min | **Risk:** Low

### 2a. Least-Privilege Permissions on `test.yml`

Add top-level `permissions: {}` (deny all) with per-job `permissions: { contents: read }` overrides.

```yaml
# Top of test.yml, after triggers
permissions: {}

# Per job:
backend-tests:
  permissions:
    contents: read
# ... same for frontend-tests, e2e-tests, validate-infrastructure
# test-summary needs no permissions (only checks other job results)
```

### 2b. Concurrency Controls (all 4 workflows)

```yaml
# test.yml — safe to cancel in-progress (newer push supersedes)
concurrency:
  group: test-${{ github.ref }}
  cancel-in-progress: true

# Deploy workflows — queue, don't cancel mid-deploy
concurrency:
  group: deploy-frontend-${{ github.ref }}   # or deploy-backend, deploy-cms
  cancel-in-progress: false
```

### 2c. Fix Rollback Bug (Critical Correctness)

**Bug:** All 3 deploy workflows push `:latest` at build time, before healthcheck. On rollback, `:latest` IS the broken image.

**Fix:** Push only the SHA-tagged image at build time. Add a `tag-latest` job that runs after healthcheck passes:

```yaml
# In build-and-push: only push SHA tag
- name: Push Docker image
  run: |
    docker push ${{ env.CONTAINER_REGISTRY }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}

# New job after healthcheck
tag-latest:
  name: Tag as Latest
  runs-on: ubuntu-latest
  needs: healthcheck
  if: success()
  permissions:
    id-token: write
    contents: read
  steps:
    - name: Login to Azure
      uses: azure/login@<sha> # v2
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    - name: Tag image as latest
      run: |
        az acr import \
          --name ${{ env.CONTAINER_REGISTRY }} \
          --source ${{ env.CONTAINER_REGISTRY }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }} \
          --image ${{ env.IMAGE_NAME }}:latest \
          --force
    - name: Logout from Azure
      run: az logout
      if: always()

# Rollback now correctly uses the PREVIOUS known-good :latest
rollback:
  needs: [healthcheck, tag-latest]
  if: failure()
```

**Files:** All 3 deploy workflows

---

## Track 3: Dependabot Configuration (Quick Win)

**Effort:** ~10 min | **Risk:** None — creates PRs only, never auto-merges

**File to create:** `.github/dependabot.yml`

**Ecosystems:**

| Ecosystem | Directory | Schedule | Grouping |
|-----------|-----------|----------|----------|
| npm | `/` | Weekly (Monday) | Minor + patch grouped |
| npm | `/cms` | Monthly | — |
| nuget | `/backend` | Weekly (Monday) | Minor + patch grouped |
| github-actions | `/` | Weekly | — |
| docker | `/`, `/backend`, `/cms` | Monthly | — |

**Design decisions:**
- Group minor/patch updates to reduce PR noise
- Weekly for npm/NuGet (frequent releases); monthly for Docker/CMS (stable base images)
- GitHub Actions weekly keeps SHA pins current (complements Track 1)
- Labels per ecosystem for filtering

---

## Track 4: Test Summary Improvement (Quick Win)

**Effort:** ~10 min | **Risk:** None

**File:** `.github/workflows/test.yml`

Add `e2e-tests` to `test-summary.needs` and handle `"skipped"` result (E2E only runs on main):

```yaml
test-summary:
  needs: [backend-tests, frontend-tests, validate-infrastructure, e2e-tests]
  if: always()
  steps:
    - name: Check test results
      run: |
        FAILED=false

        if [[ "${{ needs.backend-tests.result }}" == "failure" ]]; then
          echo "backend-tests: FAILED"
          FAILED=true
        fi

        if [[ "${{ needs.frontend-tests.result }}" == "failure" ]]; then
          echo "frontend-tests: FAILED"
          FAILED=true
        fi

        if [[ "${{ needs.validate-infrastructure.result }}" == "failure" ]]; then
          echo "validate-infrastructure: FAILED"
          FAILED=true
        fi

        # E2E: only fail if it ran AND failed (skipped = OK on PRs)
        if [[ "${{ needs.e2e-tests.result }}" == "failure" ]]; then
          echo "e2e-tests: FAILED"
          FAILED=true
        elif [[ "${{ needs.e2e-tests.result }}" == "skipped" ]]; then
          echo "e2e-tests: SKIPPED (PR — main-only)"
        fi

        if [ "$FAILED" = true ]; then
          echo "One or more test suites failed"
          exit 1
        else
          echo "All test suites passed"
        fi
```

When E2E is skipped (on PRs), `needs.e2e-tests.result` is `"skipped"`, not `"failure"`, so the summary still passes.

---

## Track 5: Documentation (Quick Win)

**Effort:** ~15 min

- **Decision 52** in `documentation/decisions/TECHNICAL_DECISIONS_LOG.md` — CI/CD Pipeline Hardening (SHA pinning, concurrency, rollback fix, Dependabot)
- **ROADMAP.md** — mark 7.6 as "Evaluated — implementation plan ready"
- **CLAUDE.md** — no changes needed (CI/CD details not tracked there)

---

## Execution Order

1. **Track 1** — SHA pinning (foundation for Dependabot action updates)
2. **Track 2** — Permissions, concurrency, rollback fix
3. **Track 3** — Dependabot (depends on Track 1 SHA pins being in place)
4. **Track 4** — Test summary e2e inclusion
5. **Track 5** — Decision 52 + roadmap update

Tracks 1-4 can be a single commit (all workflow changes). Track 5 as a separate documentation commit.

---

## Verification

- [ ] All `uses:` in all 4 workflows use 40-char SHA with `# vX.Y.Z` comment
- [ ] `test.yml` has top-level `permissions: {}` with per-job overrides
- [ ] All 4 workflows have `concurrency:` groups
- [ ] Deploy workflows push `:latest` only AFTER healthcheck (new `tag-latest` job)
- [ ] Rollback deploys previous known-good `:latest` (not the broken build)
- [ ] `.github/dependabot.yml` exists with npm, nuget, github-actions, docker ecosystems
- [ ] `test-summary` includes `e2e-tests` in `needs:` and handles `"skipped"` result
- [ ] Push to a test branch triggers `test.yml` successfully
- [ ] Decision 52 logged in TECHNICAL_DECISIONS_LOG.md
- [ ] ROADMAP.md shows 7.6 status updated
