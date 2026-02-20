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

  // Inject a MutationObserver that automatically dismisses Entra's "Stay signed in?"
  // (KMSI) prompt the instant the "No" button appears in the DOM.
  //
  // Why not use Playwright's waitFor / click here instead:
  //   • Entra's KMSI dialog renders inside a position:fixed container whose
  //     buttons have offsetParent===null while loading — Playwright's visibility
  //     checks time out waiting for a non-zero bounding box.
  //   • addInitScript bypasses CSP and fires before page JS runs, so the
  //     MutationObserver is active before the SPA has a chance to insert KMSI.
  await page.addInitScript(() => {
    const observer = new MutationObserver(() => {
      const btn = Array.from(document.querySelectorAll('button'))
        .find(b => b.textContent?.trim() === 'No')
      if (btn) {
        btn.click()
        observer.disconnect()
      }
    })
    observer.observe(document.documentElement, { childList: true, subtree: true })
  })

  try {
    // Navigate to the app login page and trigger the OIDC redirect
    await page.goto(`${BASE_URL}/login`)
    await page.getByRole('button', { name: /Continue with Microsoft/i }).click()

    // Wait for Entra's hosted login page
    await page.waitForURL(/ciamlogin\.com|login\.microsoftonline\.com/, { timeout: 30_000 })
    await page.waitForLoadState('domcontentloaded')
    console.log(`  → Entra login page: ${page.url()}`)

    // --- Step 1: Email ---
    const emailInput = page.locator(
      'input[placeholder="Email address"], input[placeholder*="email" i], ' +
      '#email, input[name="signInName"], input[type="email"]'
    ).first()
    await emailInput.waitFor({ state: 'visible', timeout: 30_000 })
    await emailInput.fill(email)
    await page.locator('button:has-text("Next"), #continue, button[type="submit"]').first().click()

    // --- Step 2: Password ---
    const passwordInput = page
      .locator(
        'input[placeholder="Password"], input[placeholder*="password" i], ' +
        '#password, input[name="password"], input[type="password"]'
      )
      .first()
    await passwordInput.waitFor({ state: 'visible', timeout: 20_000 })
    await passwordInput.fill(password)
    await page.locator('button:has-text("Sign in"), button:has-text("Next"), #continue, button[type="submit"]').first().click()

    // The MutationObserver (injected above) will auto-click "No" on KMSI as soon as
    // the button appears in the DOM — no explicit KMSI handling needed here.
    // Use a generous timeout: Entra credential processing + KMSI render can take 30-45 s.
    await page.waitForURL(BASE_URL + '**', { timeout: 60_000 })
    console.log(`  → Redirected to app: ${page.url()}`)

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
