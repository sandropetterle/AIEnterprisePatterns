import { chromium, FullConfig } from '@playwright/test'
import path from 'path'
import fs from 'fs'

/**
 * Paths to persisted Playwright storageState files.
 * Imported by authenticated-flows.spec.ts so both files reference the same paths.
 */
export const EDITOR_STORAGE = path.resolve(process.cwd(), 'e2e/.auth/editor.json')
export const ADMIN_STORAGE = path.resolve(process.cwd(), 'e2e/.auth/admin.json')

const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:3000'

/**
 * Signs in via Entra External ID's hosted CIAM login page and persists the
 * resulting cookies + localStorage as a storageState JSON file.
 *
 * Entra External ID uses a two-step hosted login flow:
 *   1. Enter email  → click "Continue"  (page/step may change)
 *   2. Enter password → click the submit button
 *
 * Selectors target the standard Entra CIAM page elements; adjust the
 * locator strings if the tenant uses a customised login UI.
 */
async function saveAuthState(email: string, password: string, storagePath: string) {
  const browser = await chromium.launch()
  const context = await browser.newContext()
  const page = await context.newPage()

  try {
    // Navigate to the app login page and trigger the OIDC redirect
    await page.goto(`${BASE_URL}/login`)
    await page.getByRole('button', { name: /Continue with Microsoft/i }).click()

    // Wait for Entra's hosted login page
    await page.waitForURL(/ciamlogin\.com|login\.microsoftonline\.com/, { timeout: 30_000 })

    // --- Step 1: Email ---
    // Common Entra CIAM selectors (try id="email" first, then name, then type)
    await page
      .locator('#email, input[name="signInName"], input[type="email"]')
      .first()
      .fill(email)
    await page.locator('#continue, button[type="submit"]').first().click()

    // --- Step 2: Password (same page or a new page after email submission) ---
    const passwordInput = page
      .locator('#password, input[name="password"], input[type="password"]')
      .first()
    await passwordInput.waitFor({ timeout: 20_000 })
    await passwordInput.fill(password)
    await page.locator('#continue, button[type="submit"]').first().click()

    // Wait for redirect back to the application
    await page.waitForURL(BASE_URL + '**', { timeout: 30_000 })

    // Persist the authenticated session
    fs.mkdirSync(path.dirname(storagePath), { recursive: true })
    await context.storageState({ path: storagePath })

    console.log(`  ✓ Auth state saved: ${path.relative(process.cwd(), storagePath)}`)
  } finally {
    await browser.close()
  }
}

export default async function globalSetup(_config: FullConfig) {
  // Always ensure the .auth/ directory and placeholder files exist so
  // test.use({ storageState }) never throws a file-not-found error
  // even when credentials are not configured.
  fs.mkdirSync(path.dirname(EDITOR_STORAGE), { recursive: true })
  const empty = JSON.stringify({ cookies: [], origins: [] })
  if (!fs.existsSync(EDITOR_STORAGE)) fs.writeFileSync(EDITOR_STORAGE, empty)
  if (!fs.existsSync(ADMIN_STORAGE)) fs.writeFileSync(ADMIN_STORAGE, empty)

  const editorEmail = process.env.E2E_EDITOR_EMAIL
  const editorPassword = process.env.E2E_EDITOR_PASSWORD
  const adminEmail = process.env.E2E_ADMIN_EMAIL
  const adminPassword = process.env.E2E_ADMIN_PASSWORD

  if (!editorEmail || !editorPassword) {
    console.log(
      '  ⚠  E2E_EDITOR_EMAIL / E2E_EDITOR_PASSWORD not set — authenticated tests will be skipped'
    )
    return
  }

  console.log('  → Logging in as Editor…')
  await saveAuthState(editorEmail, editorPassword, EDITOR_STORAGE)

  if (adminEmail && adminPassword) {
    console.log('  → Logging in as Admin…')
    await saveAuthState(adminEmail, adminPassword, ADMIN_STORAGE)
  } else {
    console.log(
      '  ⚠  E2E_ADMIN_EMAIL / E2E_ADMIN_PASSWORD not set — Admin tests will be skipped'
    )
    fs.writeFileSync(ADMIN_STORAGE, empty)
  }
}
