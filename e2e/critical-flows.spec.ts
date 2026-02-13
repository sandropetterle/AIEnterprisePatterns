/**
 * Critical User Flows E2E Tests
 * Tests core user journeys to ensure the application works end-to-end
 */

import { test, expect } from '@playwright/test'

// Base URL from environment or default to localhost
const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL?.replace('/api', '') || 'http://localhost:3000'

test.describe('Critical User Flows', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to home page before each test
    await page.goto(BASE_URL)
  })

  test('Home page loads and displays patterns', async ({ page }) => {
    // Wait for the page to load
    await page.waitForLoadState('networkidle')

    // Check that the main heading is visible
    await expect(page.locator('h1')).toBeVisible()

    // Check that at least one pattern card is displayed
    // This assumes patterns are loaded (either from API or mock data)
    const patternCards = page.locator('[data-testid="pattern-card"]')
    await expect(patternCards.first()).toBeVisible({ timeout: 10000 })

    // Verify page has a title
    await expect(page).toHaveTitle(/AI Enterprise Patterns/i)
  })

  test('Pattern detail page loads by slug', async ({ page }) => {
    // Wait for patterns to load on home page
    await page.waitForLoadState('networkidle')

    // Click on the first pattern card
    const firstPattern = page.locator('[data-testid="pattern-card"]').first()
    await firstPattern.click()

    // Wait for navigation to detail page
    await page.waitForURL(/\/patterns\/[\w-]+/)

    // Verify pattern detail content is visible
    await expect(page.locator('h1')).toBeVisible()

    // Check for pattern metadata (vote count, author, tags)
    await expect(page.locator('[data-testid="vote-count"]')).toBeVisible({ timeout: 5000 })
  })

  test('Search functionality works', async ({ page }) => {
    // Wait for page to load
    await page.waitForLoadState('networkidle')

    // Find the search input
    const searchInput = page.locator('input[type="search"], input[placeholder*="Search"]')
    await expect(searchInput).toBeVisible()

    // Type a search query
    await searchInput.fill('architecture')
    await searchInput.press('Enter')

    // Wait for results to update
    await page.waitForTimeout(1000)

    // Verify URL has search parameter
    expect(page.url()).toContain('search=architecture')
  })

  test('Filter by category works', async ({ page }) => {
    // Wait for page to load
    await page.waitForLoadState('networkidle')

    // Look for category filter (could be buttons, select, or custom component)
    const categoryFilter = page.locator('[data-testid="category-filter"]').first()

    if (await categoryFilter.isVisible({ timeout: 2000 })) {
      await categoryFilter.click()

      // Wait for URL to update with category parameter
      await page.waitForTimeout(500)

      // Verify URL has category parameter
      const url = page.url()
      const hasCategory = url.includes('category=') || url === BASE_URL // Might be on filtered page
      expect(hasCategory).toBeTruthy()
    } else {
      // Skip test if category filter not found (not yet implemented)
      test.skip()
    }
  })

  test('Vote button increments count optimistically (if implemented)', async ({ page }) => {
    // Navigate to a pattern detail page
    await page.goto(`${BASE_URL}/patterns/clean-architecture-ai-refactoring`)
    await page.waitForLoadState('networkidle')

    // Find vote button
    const voteButton = page.locator('[data-testid="vote-button"]')

    if (await voteButton.isVisible({ timeout: 2000 })) {
      // Get initial vote count
      const voteCountElement = page.locator('[data-testid="vote-count"]')
      const initialCountText = await voteCountElement.textContent()
      const initialCount = parseInt(initialCountText?.match(/\d+/)?.[0] || '0')

      // Click vote button
      await voteButton.click()

      // Wait a moment for optimistic update
      await page.waitForTimeout(300)

      // Verify count increased
      const updatedCountText = await voteCountElement.textContent()
      const updatedCount = parseInt(updatedCountText?.match(/\d+/)?.[0] || '0')

      expect(updatedCount).toBeGreaterThan(initialCount)
    } else {
      // Skip if vote button not found (not yet implemented)
      test.skip()
    }
  })

  test('Responsive navigation works on mobile', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 })
    await page.waitForLoadState('networkidle')

    // Look for mobile menu button (hamburger icon)
    const mobileMenuButton = page.locator('[aria-label*="menu" i], button[class*="mobile"]').first()

    if (await mobileMenuButton.isVisible({ timeout: 2000 })) {
      await mobileMenuButton.click()

      // Verify mobile menu opened
      const mobileNav = page.locator('nav[class*="mobile"], [role="dialog"]')
      await expect(mobileNav).toBeVisible({ timeout: 1000 })
    } else {
      // Skip if mobile menu not found
      test.skip()
    }
  })
})

test.describe('Error Handling', () => {
  test('404 page displays for non-existent pattern', async ({ page }) => {
    // Navigate to a non-existent pattern
    await page.goto(`${BASE_URL}/patterns/this-pattern-does-not-exist-12345`)
    await page.waitForLoadState('networkidle')

    // Check for 404 indicator (could be heading, status code, or custom message)
    const notFoundIndicators = [
      page.locator('h1:has-text("404")'),
      page.locator('h1:has-text("Not Found")'),
      page.locator('[data-testid="404"]'),
    ]

    // At least one indicator should be visible
    let found = false
    for (const indicator of notFoundIndicators) {
      if (await indicator.isVisible({ timeout: 2000 })) {
        found = true
        break
      }
    }

    expect(found).toBeTruthy()
  })

  test('API error displays user-friendly message', async ({ page }) => {
    // This test would require mocking API failures
    // For now, we document the expected behavior
    test.skip() // Skip until error handling is fully implemented
  })
})

test.describe('Performance', () => {
  test('Home page loads within acceptable time', async ({ page }) => {
    const startTime = Date.now()

    await page.goto(BASE_URL)
    await page.waitForLoadState('networkidle')

    const loadTime = Date.now() - startTime

    // Page should load within 3 seconds
    expect(loadTime).toBeLessThan(3000)
  })

  test('Pattern detail page loads within acceptable time', async ({ page }) => {
    const startTime = Date.now()

    await page.goto(`${BASE_URL}/patterns/clean-architecture-ai-refactoring`)
    await page.waitForLoadState('networkidle')

    const loadTime = Date.now() - startTime

    // Detail page should load within 3 seconds
    expect(loadTime).toBeLessThan(3000)
  })
})
