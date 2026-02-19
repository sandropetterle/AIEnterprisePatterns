/**
 * E2E Tests — Critical User Flows
 *
 * Covers the core journeys a real user takes through the app.
 * Selectors use semantic HTML (role, label, placeholder, text) because no
 * data-testid attributes exist in the production components.
 *
 * Prerequisites (handled by the CI workflow):
 *   - Backend running on http://localhost:5255
 *   - Frontend running on http://localhost:3000
 */

import { test, expect } from '@playwright/test'

// ---------------------------------------------------------------------------
// Home Page
// ---------------------------------------------------------------------------

test.describe('Home Page', () => {
  test('loads with hero heading', async ({ page }) => {
    await page.goto('/')

    await expect(
      page.getByRole('heading', { name: 'AI Enterprise Patterns Library', level: 1 })
    ).toBeVisible()
  })

  test('displays featured pattern cards', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // PatternCard renders as <Link href="/patterns/[slug]"> → <a>
    const patternLinks = page.locator('a[href^="/patterns/"]')
    await expect(patternLinks.first()).toBeVisible({ timeout: 15_000 })
  })

  test('"Browse Patterns" CTA navigates to the listing page', async ({ page }) => {
    await page.goto('/')

    // Hero renders a "Browse Patterns" link button
    await page.getByRole('link', { name: /Browse Patterns/i }).first().click()

    // Wait for heading rather than URL — Turbopack may take a moment to compile the
    // /patterns route the first time, so allow a generous timeout.
    await expect(
      page.getByRole('heading', { name: 'Browse Patterns', level: 1 })
    ).toBeVisible({ timeout: 60_000 })
  })
})

// ---------------------------------------------------------------------------
// Browse Patterns Page
// ---------------------------------------------------------------------------

test.describe('Browse Patterns Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/patterns')
    await page.waitForLoadState('networkidle')
  })

  test('displays heading, search bar and pattern cards', async ({ page }) => {
    await expect(
      page.getByRole('heading', { name: 'Browse Patterns', level: 1 })
    ).toBeVisible()

    await expect(page.getByPlaceholder('Search patterns...')).toBeVisible()

    await expect(page.locator('a[href^="/patterns/"]').first()).toBeVisible({
      timeout: 10_000,
    })
  })

  test('search updates the URL with the q parameter', async ({ page }) => {
    const searchInput = page.getByPlaceholder('Search patterns...')
    await searchInput.fill('architecture')
    await searchInput.press('Enter')

    // SearchBar uses `q` — NOT `search`
    await page.waitForURL(/\/patterns\?.*q=architecture/)
    expect(page.url()).toContain('q=architecture')
  })

  test('clearing the search removes the q parameter', async ({ page }) => {
    await page.goto('/patterns?q=architecture')
    await page.waitForLoadState('networkidle')

    // SearchBar renders a ghost button with "Clear search" sr-only text
    const clearButton = page.getByRole('button', { name: /Clear search/i })
    await expect(clearButton).toBeVisible()
    await clearButton.click()

    await page.waitForURL((url) => !url.href.includes('q='))
    expect(page.url()).not.toContain('q=')
  })

  test('category filter button updates URL with category parameter', async ({ page }) => {
    // FilterPanel is visible only on lg screens (Desktop Chrome viewport is wide enough).
    // Buttons use aria-pressed to indicate active state.
    const architectureBtn = page
      .locator('button[aria-pressed]')
      .filter({ hasText: 'Architecture' })
      .first()

    await expect(architectureBtn).toBeVisible({ timeout: 5_000 })
    await architectureBtn.click()

    await page.waitForURL(/\/patterns\?.*category=Architecture/)
    expect(page.url()).toContain('category=Architecture')
  })

  test('active category filter can be cleared', async ({ page }) => {
    await page.goto('/patterns?category=Architecture')
    await page.waitForLoadState('networkidle')

    // FilterPanel shows a "Clear all" button when filters are active
    const clearAll = page.getByRole('button', { name: 'Clear all' })
    await expect(clearAll).toBeVisible()
    await clearAll.click()

    await page.waitForURL((url) => !url.href.includes('category='))
    expect(page.url()).not.toContain('category=')
  })

  test('tag checkbox toggles a tags parameter in the URL', async ({ page }) => {
    // Tags are rendered as labelled checkboxes: <Checkbox id="tag-{tag}"> + <label>
    const cleanArchLabel = page.getByLabel('Clean Architecture')

    await expect(cleanArchLabel).toBeVisible({ timeout: 5_000 })
    await cleanArchLabel.click()

    await page.waitForURL(/\/patterns\?.*tags=/)
    expect(page.url()).toContain('tags=')
  })
})

// ---------------------------------------------------------------------------
// Pattern Detail Page
// ---------------------------------------------------------------------------

test.describe('Pattern Detail Page', () => {
  test('loads the seeded pattern by slug and shows correct heading', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    const heading = page.getByRole('heading', { level: 1 })
    await expect(heading).toBeVisible()
    await expect(heading).toContainText('Clean Architecture')
  })

  test('shows the voting button in an enabled state', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    // VotingButton renders: <Button>…{voteCount} <span>votes</span></Button>
    const voteButton = page.getByRole('button', { name: /votes/i })
    await expect(voteButton).toBeVisible({ timeout: 5_000 })
    await expect(voteButton).toBeEnabled()
  })

  test('voting increments the displayed count optimistically', async ({ page }) => {
    // Intercept the vote fetch at the JavaScript level before any page scripts run.
    // page.addInitScript runs in the browser before the app bundle loads, so it
    // overrides window.fetch for ALL client-side calls including the vote handler.
    // A 500 ms delay lets us observe the optimistic count+1 in the DOM before the
    // mock response arrives (React commits the +1 synchronously in the event handler,
    // before the first await in handleVote).
    await page.addInitScript(() => {
      const orig = window.fetch.bind(window)
      window.fetch = async function (input, init) {
        const url = typeof input === 'string' ? input : (input as Request).url
        if (url.includes('/vote')) {
          await new Promise<void>(r => setTimeout(r, 500))
          return new Response(
            JSON.stringify({ voteCount: 99, patternId: 'mocked' }),
            { status: 201, headers: { 'Content-Type': 'application/json' } }
          )
        }
        return orig(input, init)
      }
    })

    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    const voteButton = page.getByRole('button', { name: /votes/i })
    await expect(voteButton).toBeEnabled({ timeout: 5_000 })

    const initialText = await voteButton.textContent() ?? ''
    const initialCount = parseInt(initialText.match(/(\d+)/)?.[1] ?? '0', 10)

    await voteButton.click()

    // React commits count+1 SYNCHRONOUSLY in the event handler before the
    // first await, so the optimistic value is visible in the DOM immediately
    // after the click (well before the 500 ms mock delay expires).
    await expect(voteButton).toContainText(`${initialCount + 1}`, { timeout: 3_000 })
  })

  test('vote button is disabled after voting to prevent duplicate votes', async ({
    page,
  }) => {
    // Same fetch intercept strategy: override window.fetch before page scripts
    // so the vote call succeeds instantly, keeping hasVoted=true permanently.
    await page.addInitScript(() => {
      const orig = window.fetch.bind(window)
      window.fetch = async function (input, init) {
        const url = typeof input === 'string' ? input : (input as Request).url
        if (url.includes('/vote')) {
          return new Response(
            JSON.stringify({ voteCount: 43, patternId: 'mocked' }),
            { status: 201, headers: { 'Content-Type': 'application/json' } }
          )
        }
        return orig(input, init)
      }
    })

    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    const voteButton = page.getByRole('button', { name: /votes/i })
    await expect(voteButton).toBeEnabled({ timeout: 5_000 })
    await voteButton.click()

    // setHasVoted(true) is synchronous — button becomes disabled immediately.
    // With the mock returning 201 the API call succeeds, so hasVoted stays true
    // and the button remains disabled after the response is processed.
    await expect(voteButton).toBeDisabled({ timeout: 5_000 })
  })

  test('breadcrumb contains links back to Home and Patterns', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    // Breadcrumb renders as <nav> + <ol>
    const nav = page.locator('nav').filter({ has: page.locator('a[href="/"]') }).first()
    await expect(nav).toBeVisible()
    await expect(nav.getByRole('link', { name: 'Home' })).toBeVisible()
    await expect(nav.getByRole('link', { name: 'Patterns' })).toBeVisible()
  })

  test('clicking a pattern card on the listing navigates to its detail page', async ({
    page,
  }) => {
    await page.goto('/patterns')
    await page.waitForLoadState('networkidle')

    const firstLink = page.locator('a[href^="/patterns/"]').first()
    await expect(firstLink).toBeVisible({ timeout: 10_000 })

    const href = await firstLink.getAttribute('href')
    await firstLink.click()

    await page.waitForURL(/\/patterns\/[\w-]+/)
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible()

    if (href) expect(page.url()).toContain(href)
  })
})

// ---------------------------------------------------------------------------
// Error Handling
// ---------------------------------------------------------------------------

test.describe('Error Handling', () => {
  test('navigating to a non-existent pattern slug shows the 404 page', async ({
    page,
  }) => {
    await page.goto('/patterns/this-slug-absolutely-does-not-exist-99999')
    await page.waitForLoadState('networkidle')

    // app/not-found.tsx renders: <h1>404</h1> + <h2>Page Not Found</h2>
    await expect(page.getByRole('heading', { name: '404', level: 1 })).toBeVisible()
    await expect(page.getByText('Page Not Found')).toBeVisible()
  })

  test('404 page has a working "Back to Home" link', async ({ page }) => {
    await page.goto('/patterns/nonexistent-pattern-xyz-abc')
    await page.waitForLoadState('networkidle')

    await page.getByRole('link', { name: /Back to Home/i }).click()
    await page.waitForURL('/')

    await expect(
      page.getByRole('heading', { name: 'AI Enterprise Patterns Library', level: 1 })
    ).toBeVisible()
  })
})

// ---------------------------------------------------------------------------
// Page Titles (Accessibility / SEO)
// ---------------------------------------------------------------------------

test.describe('Page Titles', () => {
  test('home page has the correct document title', async ({ page }) => {
    await page.goto('/')
    // Dev mode may render just "Home"; production builds apply the layout
    // template to produce "Home | AI Enterprise Patterns". Both are acceptable.
    await expect(page).toHaveTitle(/Home/i)
  })

  test('browse page title includes "Browse Patterns"', async ({ page }) => {
    await page.goto('/patterns')
    await expect(page).toHaveTitle(/Browse Patterns/i)
  })

  test('pattern detail title includes the pattern name', async ({ page }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')
    await expect(page).toHaveTitle(/Clean Architecture/i)
  })
})
