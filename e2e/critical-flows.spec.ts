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

import { test, expect, type Page, type Locator } from '@playwright/test'

/**
 * Set a date input value in a way that reliably triggers React's synthetic
 * onChange across all browsers, including webkit.
 *
 * webkit's native date-picker widget can intercept page.fill() and prevent
 * the synthetic change event from firing. Using the native HTMLInputElement
 * value setter + manual event dispatch bypasses that and correctly signals
 * React that the controlled value changed.
 */
async function fillDateInput(input: Locator, value: string) {
  await input.evaluate((el, val: string) => {
    Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')!.set!.call(el, val)
    el.dispatchEvent(new Event('input', { bubbles: true }))
    el.dispatchEvent(new Event('change', { bubbles: true }))
  }, value)
}

/**
 * The desktop FilterPanel wrapper, filtered to the visible instance.
 *
 * During Next.js soft navigations the outgoing and incoming page subtrees can
 * briefly coexist in the DOM (the old one hidden), so an unfiltered locator
 * may resolve to two elements and trip Playwright's strict mode — observed in
 * CI webkit as "#date-to resolved to 2 elements" (issue #68).
 */
function desktopFilterPanel(page: Page): Locator {
  return page
    .locator('[data-testid="desktop-filter-panel"]')
    .filter({ visible: true })
}

/**
 * Wait until the desktop FilterPanel is hydrated and interactive.
 *
 * Server-rendered HTML is visible before React attaches event handlers, so
 * interactions fired on a merely *visible* panel are silently lost — the root
 * cause of the deterministic local failures in issue #68. FilterPanel sets
 * data-hydrated="true" in an effect, which only runs after hydration, making
 * it a reliable readiness signal. Call this after every goto() before
 * interacting with the panel.
 */
async function waitForFilterPanelHydrated(page: Page): Promise<Locator> {
  const panel = desktopFilterPanel(page)
  await expect(panel.locator('[data-hydrated="true"]')).toBeVisible({
    timeout: 15_000,
  })
  return panel
}

/**
 * Click a FilterPanel tag checkbox until the selection sticks.
 *
 * Next.js streams the RSC payload of the previous filter navigation after the
 * URL has already updated; a click that lands while that payload is still
 * committing can hit a subtree that is about to be swapped and be silently
 * dropped (issue #68). Retry until the checkbox reflects the selection — the
 * isChecked() guard prevents a retry from toggling the tag back off.
 */
async function selectTag(checkbox: Locator) {
  // Inner timeout must exceed the worst-case navigation commit (~8s under
  // parallel-worker load) — a faster retry re-pushes the same navigation and
  // restarts it, starving the commit indefinitely.
  await expect(async () => {
    if (!(await checkbox.isChecked())) {
      await checkbox.click()
    }
    await expect(checkbox).toBeChecked({ timeout: 8_000 })
  }).toPass({ timeout: 32_000 })
}

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

    // Wait for the clear button directly — proves the page loaded with the
    // query applied. Avoids waitForLoadState('networkidle') which times out
    // in CI because Next.js production builds prefetch link targets
    // indefinitely, preventing the idle state from ever being reached.
    const clearButton = page.getByRole('button', { name: /Clear search/i })
    await expect(clearButton).toBeVisible({ timeout: 15_000 })
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

    // Wait for "Clear all" directly — proves the filter is active and the
    // FilterPanel rendered. Avoids waitForLoadState('networkidle') timeout
    // caused by Next.js production prefetching.
    const clearAll = page.getByRole('button', { name: 'Clear all' })
    await expect(clearAll).toBeVisible({ timeout: 15_000 })
    await clearAll.click()

    await page.waitForURL((url) => !url.href.includes('category='))
    expect(page.url()).not.toContain('category=')
  })

  test('tag checkbox toggles a tags parameter in the URL', async ({ page }) => {
    // Tags are rendered as labelled checkboxes: <Checkbox id="tag-{tag}"> + <label>
    // Use getByRole('checkbox') to avoid ambiguity with PatternCard aria-labels
    // added in Phase 5.4 accessibility work.
    const cleanArchCheckbox = page.getByRole('checkbox', { name: 'Clean Architecture' })

    await expect(cleanArchCheckbox).toBeVisible({ timeout: 5_000 })
    await cleanArchCheckbox.click()

    await page.waitForURL(/\/patterns\?.*tags=/)
    expect(page.url()).toContain('tags=')
  })

  test('out-of-range page is clamped to a valid page, not a false empty state (BSW-0003)', async ({ page }) => {
    await page.goto('/patterns?page=999')

    // Clamped to the last valid page: pattern cards render instead of the
    // contradictory "6 patterns found" + empty-corpus message.
    await expect(page.locator('a[href^="/patterns/"]').first()).toBeVisible({
      timeout: 15_000,
    })
    await expect(page.getByText('No patterns available')).toHaveCount(0)
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
// Advanced Search — Date Range Filter (Phase 5.3)
// ---------------------------------------------------------------------------

test.describe('Advanced Search — Date Range Filter', () => {
  // DateRangeFilter lives inside FilterPanel which is desktop-only (lg:block).
  // Desktop Chrome viewport (1280×720) satisfies the lg breakpoint.
  //
  // Date input ids are useId()-generated since issue #68, so lookups go through
  // the accessible label, scoped to the visible desktop panel.
  //
  // Interactions retry until their effect is observable (see selectTag docs for
  // the swallowed-interaction mechanism), so allow extra headroom on top of the
  // default 30s when the machine is under parallel-worker load.
  test.describe.configure({ timeout: 60_000 })

  test.beforeEach(async ({ page }) => {
    await page.goto('/patterns')
    // Wait for hydration, not just visibility — interactions fired before React
    // attaches handlers are silently lost (issue #68).
    await waitForFilterPanelHydrated(page)
  })

  test('setting a From date updates the URL with dateFrom parameter', async ({ page }) => {
    const desktopPanel = desktopFilterPanel(page)
    const fromInput = desktopPanel.getByLabel('From', { exact: true })

    // Retry the fill until the URL reflects it — the synthetic change event can
    // be swallowed by an in-flight RSC commit (issue #68); re-filling the same
    // value is idempotent. toHaveURL (assertion-based polling) — waitForURL can
    // miss Next.js pushState soft navigations. The inner timeout must exceed
    // the worst-case navigation commit (~8s under parallel-worker load); a
    // faster retry re-pushes and restarts the navigation, starving the commit.
    await expect(async () => {
      await fillDateInput(fromInput, '2024-01-01')
      await expect(page).toHaveURL(/dateFrom=2024-01-01/, { timeout: 8_000 })
    }).toPass({ timeout: 32_000 })
  })

  test('setting a To date updates the URL with dateTo parameter', async ({ page }) => {
    // Pre-navigate with dateFrom set so the "To" input has a valid min attribute.
    // Without a valid min, Chromium silently rejects fill() on type="date" inputs
    // and the React onChange never fires.
    await page.goto('/patterns?dateFrom=2024-01-01')
    const desktopPanel = await waitForFilterPanelHydrated(page)
    const toInput = desktopPanel.getByLabel('To', { exact: true })

    await expect(async () => {
      await fillDateInput(toInput, '2024-12-31')
      await expect(page).toHaveURL(/dateTo=2024-12-31/, { timeout: 8_000 })
    }).toPass({ timeout: 32_000 })
  })

  test('Clear dates button removes date parameters from URL', async ({ page }) => {
    // Navigate directly with both params pre-set — avoids relying on fill()
    // to set up state; only tests the Clear button interaction itself.
    await page.goto('/patterns?dateFrom=2024-01-01&dateTo=2024-12-31')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    const clearDatesBtn = desktopPanel.getByRole('button', { name: /Clear dates/i })
    await expect(clearDatesBtn).toBeVisible({ timeout: 5_000 })

    // Retry until the URL is clean — the visibility guard prevents re-clicking
    // once the first click registered (the button unmounts with the params).
    // Inner timeout must exceed the worst-case navigation commit (~8s under
    // parallel-worker load) so retries don't restart the navigation.
    await expect(async () => {
      if (await clearDatesBtn.isVisible()) {
        await clearDatesBtn.click()
      }
      await expect(page).not.toHaveURL(/dateFrom=/, { timeout: 8_000 })
    }).toPass({ timeout: 32_000 })
    expect(page.url()).not.toContain('dateTo=')
  })
})

// ---------------------------------------------------------------------------
// Advanced Search — Tag AND/OR Mode Toggle (Phase 5.3)
// ---------------------------------------------------------------------------

test.describe('Advanced Search — Tag Mode Toggle', () => {
  // Scope all interactions to the visible desktop panel, wait for hydration
  // before clicking, and retry interactions until their effect is observable —
  // see selectTag docs for the swallowed-interaction mechanism (issue #68).
  test.describe.configure({ timeout: 60_000 })

  test('selecting two tags reveals the Any / All toggle', async ({ page }) => {
    await page.goto('/patterns')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    // Select first tag (Clean Architecture); selectTag waits for the checked
    // state, which confirms FilterPanel re-rendered with the new URL's
    // selectedTags before we click the second tag. Without that, the second
    // click would fire while selectedTags is still [], setting tags=CQRS only.
    const firstTag = desktopPanel.getByRole('checkbox', { name: 'Clean Architecture' })
    await expect(firstTag).toBeVisible({ timeout: 5_000 })
    await selectTag(firstTag)
    await expect(page).toHaveURL(/tags=/, { timeout: 10_000 })

    // Select a second tag (CQRS) — toggles comma-separated tags list
    const secondTag = desktopPanel.getByRole('checkbox', { name: 'CQRS' })
    await expect(secondTag).toBeVisible({ timeout: 5_000 })
    await selectTag(secondTag)
    // Wait for URL to reflect both tags before checking toggle
    // — comma may be URL-encoded as %2C (WebKit encodes it; Chromium uses literal comma)
    // — FilterPanel only renders the Any/All toggle when selectedTags.length >= 2
    await expect(page).toHaveURL(/tags=[^&]*(%2C|,)/i, { timeout: 10_000 })

    // With 2+ tags the Any / All buttons should appear
    await expect(
      desktopPanel.getByRole('button', { name: 'Any', exact: true })
    ).toBeVisible({ timeout: 5_000 })
    await expect(
      desktopPanel.getByRole('button', { name: 'All', exact: true })
    ).toBeVisible({ timeout: 5_000 })
  })

  test('clicking "All" sets tagMode=all in the URL', async ({ page }) => {
    await page.goto('/patterns')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    // Pre-select two tags then switch to All mode
    const firstTag = desktopPanel.getByRole('checkbox', { name: 'Clean Architecture' })
    await expect(firstTag).toBeVisible({ timeout: 5_000 })
    await selectTag(firstTag)
    await expect(page).toHaveURL(/tags=/, { timeout: 10_000 })

    const secondTag = desktopPanel.getByRole('checkbox', { name: 'CQRS' })
    await expect(secondTag).toBeVisible({ timeout: 5_000 })
    await selectTag(secondTag)
    await expect(page).toHaveURL(/tags=[^&]*(%2C|,)/i, { timeout: 10_000 })

    const allBtn = desktopPanel.getByRole('button', { name: 'All', exact: true })
    await expect(allBtn).toBeVisible({ timeout: 5_000 })
    // Retry until the URL reflects the mode — the aria-pressed guard prevents a
    // retry from re-pushing after the first click registered. Inner timeout
    // must exceed the worst-case navigation commit (~8s under load).
    await expect(async () => {
      if ((await allBtn.getAttribute('aria-pressed')) !== 'true') {
        await allBtn.click()
      }
      await expect(page).toHaveURL(/tagMode=all/, { timeout: 8_000 })
    }).toPass({ timeout: 32_000 })
  })
})

// ---------------------------------------------------------------------------
// Recently Viewed Patterns (Phase 5.3)
// ---------------------------------------------------------------------------

test.describe('Recently Viewed Patterns', () => {
  test('visiting a pattern then browsing shows it in the Recently Viewed sidebar', async ({
    page,
  }) => {
    // Visit the pattern detail page — RecentlyViewedTracker records it in localStorage.
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    // Navigate to the patterns listing.
    await page.goto('/patterns')
    await expect(
      page.getByRole('heading', { name: 'Filters' })
    ).toBeVisible({ timeout: 10_000 })

    // The "Recently viewed patterns" list should be visible in the sidebar.
    const recentList = page.getByRole('list', { name: 'Recently viewed patterns' })
    await expect(recentList).toBeVisible({ timeout: 5_000 })

    // The visited pattern should appear as a link.
    await expect(
      recentList.getByRole('link', { name: /Clean Architecture/i })
    ).toBeVisible()
  })

  test('Clear recently viewed button removes entries and hides the sidebar section', async ({
    page,
  }) => {
    await page.goto('/patterns/clean-architecture-ai-refactoring')
    await page.waitForLoadState('networkidle')

    await page.goto('/patterns')

    const recentList = page.getByRole('list', { name: 'Recently viewed patterns' })
    await expect(recentList).toBeVisible({ timeout: 10_000 })

    await page.getByRole('button', { name: 'Clear recently viewed history' }).click()

    // Once cleared the list disappears (component renders nothing when empty).
    await expect(recentList).not.toBeVisible({ timeout: 5_000 })
  })
})

// ---------------------------------------------------------------------------
// Saved Searches (Phase 5.3)
// ---------------------------------------------------------------------------

test.describe('Saved Searches', () => {
  // SavedSearches lives inside FilterPanel — wait for hydration before
  // interacting and retry interactions until their effect is observable (see
  // selectTag docs for the swallowed-interaction mechanism, issue #68). The
  // save dialog renders in a portal outside the panel, so dialog locators stay
  // page-scoped.
  test.describe.configure({ timeout: 60_000 })

  /** Open the save dialog and save the current search under `name`. */
  async function saveCurrentSearch(page: Page, desktopPanel: Locator, name: string) {
    const nameInput = page.locator('#search-name')

    // Open the save dialog — guard prevents re-clicking once it is open.
    await expect(async () => {
      if (!(await nameInput.isVisible())) {
        await desktopPanel.getByRole('button', { name: 'Save current' }).click()
      }
      await expect(nameInput).toBeVisible({ timeout: 2_000 })
    }).toPass({ timeout: 20_000 })

    // Fill in the name and confirm — retried as a unit; once the save lands
    // the dialog closes (guard) and the entry appears in the saved list.
    const savedList = desktopPanel.getByRole('list', { name: 'Saved searches' })
    await expect(async () => {
      if (await nameInput.isVisible()) {
        await nameInput.fill(name)
        await page.getByRole('button', { name: 'Save', exact: true }).click()
      }
      await expect(savedList.getByText(name)).toBeVisible({ timeout: 2_000 })
    }).toPass({ timeout: 20_000 })
  }

  test('active filters reveal the "Save current" button', async ({ page }) => {
    // Navigate with a pre-applied category filter.
    await page.goto('/patterns?category=Architecture')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    await expect(
      desktopPanel.getByRole('button', { name: 'Save current' })
    ).toBeVisible({ timeout: 5_000 })
  })

  test('saving a named search persists it in the saved list', async ({ page }) => {
    await page.goto('/patterns?category=Architecture')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    await saveCurrentSearch(page, desktopPanel, 'Architecture searches')
  })

  test('applying a saved search updates the URL with the saved filters', async ({ page }) => {
    // Step 1: save a search while filters are active.
    await page.goto('/patterns?category=Architecture')
    let desktopPanel = await waitForFilterPanelHydrated(page)

    await saveCurrentSearch(page, desktopPanel, 'My Architecture')

    // Step 2: navigate away to clear all URL params.
    await page.goto('/patterns')
    desktopPanel = await waitForFilterPanelHydrated(page)

    // Step 3: apply the saved search from the sidebar.
    const savedList = desktopPanel.getByRole('list', { name: 'Saved searches' })
    await expect(savedList).toBeVisible({ timeout: 5_000 })
    // exact: true prevents matching the delete button whose aria-label is
    // "Delete saved search: My Architecture" (contains the name as substring).
    // Applying is idempotent, so the retry needs no guard. Inner timeout must
    // exceed the worst-case navigation commit (~8s under load).
    await expect(async () => {
      await savedList
        .getByRole('button', { name: 'My Architecture', exact: true })
        .click()
      await expect(page).toHaveURL(/category=Architecture/, { timeout: 8_000 })
    }).toPass({ timeout: 32_000 })
  })

  test('deleting a saved search removes it from the list', async ({ page }) => {
    // Save a search first.
    await page.goto('/patterns?category=Architecture')
    const desktopPanel = await waitForFilterPanelHydrated(page)

    await saveCurrentSearch(page, desktopPanel, 'Delete Me')

    // Delete it — guard prevents re-clicking once the entry is gone (the list
    // itself unmounts when the last saved search is removed).
    const savedList = desktopPanel.getByRole('list', { name: 'Saved searches' })
    const deleteBtn = desktopPanel.getByRole('button', {
      name: 'Delete saved search: Delete Me',
    })
    await expect(async () => {
      if (await deleteBtn.isVisible()) {
        await deleteBtn.click()
      }
      await expect(savedList.getByText('Delete Me')).not.toBeVisible({ timeout: 2_000 })
    }).toPass({ timeout: 20_000 })
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

  // BSW-0001 regression guard: pages must not hardcode the site suffix into
  // their own metadata title — the root layout's title.template appends it,
  // which doubled it (e.g. "About | AI Enterprise Patterns | AI Enterprise Patterns").
  for (const route of [
    '/',
    '/patterns',
    '/about',
    '/docs',
    '/patterns/clean-architecture-ai-refactoring',
  ]) {
    test(`document title applies the site suffix at most once: ${route}`, async ({ page }) => {
      await page.goto(route)
      const title = await page.title()
      const suffixCount = (title.match(/\| AI Enterprise Patterns/g) ?? []).length
      expect(suffixCount, `${route} rendered <title>: "${title}"`).toBeLessThanOrEqual(1)
    })
  }
})
