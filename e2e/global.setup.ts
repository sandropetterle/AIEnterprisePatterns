import { chromium, FullConfig } from '@playwright/test'
import path from 'path'
import fs from 'fs'

/**
 * Path to the persisted Playwright storageState file for the Admin account.
 * Imported by authenticated-flows.spec.ts so both files reference the same path.
 *
 * Admin users have all Editor permissions, so a single set of credentials
 * covers all authenticated tests. Configure only:
 *   E2E_ADMIN_EMAIL    — email of an Entra user with the Admin app role
 *   E2E_ADMIN_PASSWORD — their password
 */
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
    // Let the SPA-style login page finish its initial render
    await page.waitForLoadState('domcontentloaded')
    console.log(`  → Entra login page: ${page.url()}`)

    // --- Step 1: Email ---
    // Entra External ID CIAM shows an "Email address" input and a "Next" button.
    // The input does NOT use type="email" or name="signInName" — match by placeholder.
    const emailInput = page.locator(
      'input[placeholder="Email address"], input[placeholder*="email" i], ' +
      '#email, input[name="signInName"], input[type="email"]'
    ).first()
    await emailInput.waitFor({ state: 'visible', timeout: 30_000 })
    await emailInput.fill(email)
    // Button text is "Next" on the CIAM page (not "Continue")
    await page.locator('button:has-text("Next"), #continue, button[type="submit"]').first().click()

    // --- Step 2: Password (same page or a new page after email submission) ---
    const passwordInput = page
      .locator(
        'input[placeholder="Password"], input[placeholder*="password" i], ' +
        '#password, input[name="password"], input[type="password"]'
      )
      .first()
    await passwordInput.waitFor({ state: 'visible', timeout: 20_000 })
    await passwordInput.fill(password)
    await page.locator('button:has-text("Sign in"), button:has-text("Next"), #continue, button[type="submit"]').first().click()

    // Wait for redirect back to the application
    await page.waitForURL(BASE_URL + '**', { timeout: 30_000 })

    // Persist the authenticated session
    fs.mkdirSync(path.dirname(storagePath), { recursive: true })
    await context.storageState({ path: storagePath })

    console.log(`  ✓ Auth state saved: ${path.relative(process.cwd(), storagePath)}`)
  } catch (err) {
    // Capture a screenshot so the CI artifact shows exactly what Entra rendered
    const screenshotDir = path.resolve(process.cwd(), 'e2e/.auth')
    fs.mkdirSync(screenshotDir, { recursive: true })
    await page.screenshot({ path: path.join(screenshotDir, 'login-failure.png'), fullPage: true }).catch(() => {})
    console.log(`  ⚠  Login failed at URL: ${page.url()}`)
    console.log(`  ⚠  Page title: ${await page.title().catch(() => 'n/a')}`)
    throw err
  } finally {
    await browser.close()
  }
}

export default async function globalSetup(_config: FullConfig) {
  // Always ensure the .auth/ directory and placeholder file exist so
  // test.use({ storageState }) never throws a file-not-found error
  // even when credentials are not configured.
  fs.mkdirSync(path.dirname(ADMIN_STORAGE), { recursive: true })
  const empty = JSON.stringify({ cookies: [], origins: [] })
  if (!fs.existsSync(ADMIN_STORAGE)) fs.writeFileSync(ADMIN_STORAGE, empty)

  const adminEmail = process.env.E2E_ADMIN_EMAIL
  const adminPassword = process.env.E2E_ADMIN_PASSWORD

  if (!adminEmail || !adminPassword) {
    console.log(
      '  ⚠  E2E_ADMIN_EMAIL / E2E_ADMIN_PASSWORD not set — authenticated tests will be skipped'
    )
    return
  }

  // AUTH_SECRET is required by Auth.js to generate the OIDC state/CSRF parameter
  // for signIn(). Without it the /api/auth/signin endpoint fails silently and
  // the browser never redirects to Entra's login page.
  if (!process.env.AUTH_SECRET) {
    console.log(
      '  ⚠  AUTH_SECRET not set — authenticated tests will be skipped'
    )
    return
  }

  console.log('  → Logging in as Admin…')
  try {
    await saveAuthState(adminEmail, adminPassword, ADMIN_STORAGE)
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    console.log(`  ⚠  Admin login failed (${msg}) — authenticated tests will be skipped`)
    // Reset to empty so storageState: ADMIN_STORAGE doesn't inject stale cookies
    fs.writeFileSync(ADMIN_STORAGE, JSON.stringify({ cookies: [], origins: [] }))
  }
}
