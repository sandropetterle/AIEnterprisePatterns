/**
 * Authenticated E2E Tests — Editor & Admin Flows
 *
 * Tests that exercise pages and actions that require a signed-in user.
 * Auth state is set up once by e2e/global.setup.ts (runs before all tests)
 * and reused here via Playwright storageState to avoid repeated login
 * round-trips to Entra External ID.
 *
 * Required GitHub Secrets / local env vars to enable the authenticated blocks:
 *   E2E_EDITOR_EMAIL     — email of an Entra user with the Editor app role
 *   E2E_EDITOR_PASSWORD  — their password
 *   E2E_ADMIN_EMAIL      — email of an Entra user with the Admin app role
 *   E2E_ADMIN_PASSWORD   — their password
 *
 * When credentials are not set the authenticated describe blocks are skipped
 * automatically. The unauthenticated guard tests always run.
 */

import { test, expect } from '@playwright/test'
import path from 'path'

// Mirror the storage paths from global.setup.ts
const EDITOR_STORAGE = path.resolve(process.cwd(), 'e2e/.auth/editor.json')
const ADMIN_STORAGE = path.resolve(process.cwd(), 'e2e/.auth/admin.json')

const hasEditorCreds = !!process.env.E2E_EDITOR_EMAIL
const hasAdminCreds = !!process.env.E2E_ADMIN_EMAIL

// ---------------------------------------------------------------------------
// Unauthenticated access guards — no credentials required
// ---------------------------------------------------------------------------

test.describe('Unauthenticated access guards', () => {
  test('/patterns/new redirects to /login when not signed in', async ({ page }) => {
    await page.goto('/patterns/new')
    // Auth.js server-side auth() call redirects to /login when there is no session
    await page.waitForURL(/\/login/, { timeout: 10_000 })
    await expect(
      page.getByRole('button', { name: /Continue with Microsoft/i })
    ).toBeVisible()
  })

  test('/patterns/[slug]/edit redirects to /login when not signed in', async ({ page }) => {
    await page.goto('/patterns/cqrs-pattern-implementation/edit')
    await page.waitForURL(/\/login/, { timeout: 10_000 })
    await expect(
      page.getByRole('button', { name: /Continue with Microsoft/i })
    ).toBeVisible()
  })

  test('Edit and Delete buttons are not shown to unauthenticated users', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')
    // PatternActions returns null when session is absent or lacks Editor role
    await expect(page.getByRole('link', { name: 'Edit', exact: true })).not.toBeVisible()
    await expect(page.getByRole('button', { name: 'Delete', exact: true })).not.toBeVisible()
  })

  test('New Pattern button is not shown to unauthenticated users', async ({ page }) => {
    await page.goto('/patterns')
    // Give the client-rendered NewPatternButton time to hydrate
    await page.waitForTimeout(2_000)
    await expect(page.getByRole('link', { name: '+ New Pattern' })).not.toBeVisible()
  })
})

// ---------------------------------------------------------------------------
// Editor flows
// ---------------------------------------------------------------------------

test.describe('Editor — authenticated flows', () => {
  test.skip(!hasEditorCreds, 'Skipped: E2E_EDITOR_EMAIL / E2E_EDITOR_PASSWORD not configured')
  test.use({ storageState: EDITOR_STORAGE })

  test('New Pattern button is visible on the patterns listing', async ({ page }) => {
    await page.goto('/patterns')
    await expect(
      page.getByRole('link', { name: '+ New Pattern' })
    ).toBeVisible({ timeout: 10_000 })
  })

  test('navigating to /patterns/new shows the create form (no redirect)', async ({ page }) => {
    await page.goto('/patterns/new')
    await expect(
      page.getByRole('heading', { name: 'New Pattern' })
    ).toBeVisible({ timeout: 10_000 })
    await expect(page.getByRole('button', { name: /Create Pattern/i })).toBeVisible()
  })

  test('can create a new pattern end-to-end', async ({ page }) => {
    const title = `E2E Test Pattern ${Date.now()}`

    await page.goto('/patterns/new')
    await expect(
      page.getByRole('heading', { name: 'New Pattern' })
    ).toBeVisible({ timeout: 10_000 })

    await page.fill('#title', title)
    await page.fill('#shortDescription', 'Created by Playwright E2E test suite.')
    await page.getByRole('button', { name: /Create Pattern/i }).click()

    // Successful creation redirects to the new pattern's detail page
    await page.waitForURL(/\/patterns\/[a-z0-9-]+$/, { timeout: 20_000 })
    await expect(page.getByRole('heading', { level: 1 })).toContainText(title)
  })

  test('Edit button is visible on pattern detail page for an Editor', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')
    await expect(
      page.getByRole('link', { name: 'Edit', exact: true })
    ).toBeVisible({ timeout: 5_000 })
  })

  test('can edit an existing pattern and save changes', async ({ page }) => {
    await page.goto('/patterns/repository-pattern-ef-core/edit')
    await expect(
      page.getByRole('heading', { name: 'Edit Pattern' })
    ).toBeVisible({ timeout: 10_000 })

    // Update the author field (safe — doesn't affect the slug or break other tests)
    await page.fill('#author', `E2E Edited ${Date.now()}`)
    await page.getByRole('button', { name: /Save Changes/i }).click()

    // Successful edit redirects to the pattern detail page
    await page.waitForURL(/\/patterns\/repository-pattern-ef-core$/, { timeout: 20_000 })
    await expect(page.getByRole('heading', { level: 1 })).toContainText('Repository Pattern')
  })
})

// ---------------------------------------------------------------------------
// Admin flows
// ---------------------------------------------------------------------------

test.describe('Admin — authenticated flows', () => {
  test.skip(!hasAdminCreds, 'Skipped: E2E_ADMIN_EMAIL / E2E_ADMIN_PASSWORD not configured')
  test.use({ storageState: ADMIN_STORAGE })

  test('Delete button is visible on pattern detail page for an Admin', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')
    await expect(
      page.getByRole('button', { name: 'Delete', exact: true })
    ).toBeVisible({ timeout: 5_000 })
  })

  test('can create and immediately delete a pattern end-to-end', async ({ page }) => {
    const title = `E2E Delete Test ${Date.now()}`

    // Step 1: Create a temporary pattern (Admin has Editor role too)
    await page.goto('/patterns/new')
    await expect(
      page.getByRole('heading', { name: 'New Pattern' })
    ).toBeVisible({ timeout: 10_000 })
    await page.fill('#title', title)
    await page.fill('#shortDescription', 'Temporary pattern created for the delete E2E test.')
    await page.getByRole('button', { name: /Create Pattern/i }).click()

    await page.waitForURL(/\/patterns\/[a-z0-9-]+$/, { timeout: 20_000 })
    await expect(page.getByRole('heading', { level: 1 })).toContainText(title)

    // Step 2: Delete the pattern via the AlertDialog
    await page.getByRole('button', { name: 'Delete', exact: true }).click()

    const dialog = page.getByRole('alertdialog')
    await expect(dialog).toBeVisible({ timeout: 5_000 })
    await expect(dialog.getByText('Delete Pattern?')).toBeVisible()

    // The confirm button inside the dialog (distinct from the trigger button)
    await dialog.getByRole('button', { name: 'Delete', exact: true }).click()

    // Deletion redirects to /patterns
    await page.waitForURL(/\/patterns$/, { timeout: 20_000 })
    await expect(
      page.getByRole('heading', { name: 'Browse Patterns', level: 1 })
    ).toBeVisible()
  })
})
