/**
 * CMS Query Function Tests
 * Tests each query function returns correctly shaped data and falls back to
 * hardcoded defaults when Strapi is unavailable.
 *
 * Mocking strategy: mock `global.fetch` (same pattern as lib/api/__tests__/client.test.ts).
 * This works because `fetchStrapi` internally calls `fetch()`, and `global.fetch` is
 * always writable — unlike SWC-compiled ES module named exports which are non-configurable.
 * Testing at this level exercises the full pipeline:
 *   getXxx() → safeFetch() → fetchStrapi() → fetch()
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals'

import {
  getGlobal,
  getHomePage,
  getAboutPage,
  getDocsPage,
  getLoginPage,
  getNotFoundPage,
  getErrorPage,
  getPatternListingLabels,
  getPatternDetailLabels,
  getPatternFormLabels,
} from '../queries'

// Mock global.fetch — Strapi 5 wraps responses as { data: <payload> }
global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>
const mockFetch = global.fetch as jest.MockedFunction<typeof fetch>

/** Simulate a successful Strapi response */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function mockStrapiOk(payload: any) {
  mockFetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ data: payload }),
  } as Response)
}

/** Simulate a network error (ECONNREFUSED) → CmsUnavailableError in safeFetch */
function mockStrapiNetworkError() {
  mockFetch.mockRejectedValueOnce(new Error('fetch failed: ECONNREFUSED'))
}

/** Simulate a non-ok HTTP response (e.g. 500) → CmsUnavailableError in safeFetch */
function mockStrapiHttpError(status = 500) {
  mockFetch.mockResolvedValueOnce({ ok: false, status } as Response)
}

describe('CMS Query Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  // ─── getGlobal ────────────────────────────────────────────────────────────

  describe('getGlobal', () => {
    it('returns CMS data when Strapi is available', async () => {
      const payload = {
        siteName: 'CMS Site Name',
        navigation: [{ label: 'Home', href: '/' }],
        footer: { copyrightTemplate: '© {year} CMS', links: [] },
      }
      mockStrapiOk(payload)

      const result = await getGlobal()

      expect(mockFetch).toHaveBeenCalledTimes(1)
      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/global')
      expect(result).toEqual(payload)
    })

    it('uses 600s ISR revalidate (GLOBAL TTL)', async () => {
      mockStrapiOk({ siteName: 'X' })
      await getGlobal()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getGlobal()

      expect(result.siteName).toBe('AI Enterprise Patterns Library')
      expect(result.navigation).toHaveLength(3)
      expect(result.navigation?.[0]).toEqual({ label: 'Home', href: '/' })
      expect(result.navigation?.[1]).toEqual({ label: 'Patterns', href: '/patterns' })
      expect(result.navigation?.[2]).toEqual({ label: 'About', href: '/about' })
      expect(result.mobileMenuTitle).toBe('Menu')
      expect(result.skipToContentLabel).toBe('Skip to main content')
      expect(result.signInLabel).toBe('Sign In')
      expect(result.signOutLabel).toBe('Sign Out')
      expect(result.userMenuLabel).toBe('User menu')
      expect(result.newPatternButtonLabel).toBe('+ New Pattern')
      expect(result.footer?.copyrightTemplate).toContain('{year}')
      expect(result.footer?.links).toHaveLength(2)
    })

    it('falls back to hardcoded defaults on HTTP error', async () => {
      mockStrapiHttpError(503)

      const result = await getGlobal()

      expect(result.siteName).toBe('AI Enterprise Patterns Library')
    })
  })

  // ─── getHomePage ──────────────────────────────────────────────────────────

  describe('getHomePage', () => {
    it('returns CMS data when available', async () => {
      const payload = { seo: { title: 'Home' }, content: [] }
      mockStrapiOk(payload)

      const result = await getHomePage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/home-page')
      expect(result).toEqual(payload)
    })

    it('uses 300s ISR revalidate (PAGE TTL)', async () => {
      mockStrapiOk({})
      await getHomePage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(300)
    })

    it('falls back to production content on network error', async () => {
      mockStrapiNetworkError()
      const result = await getHomePage()
      expect(result.seo?.title).toBe('Home')
      expect(result.content).toHaveLength(4)
      expect(result.content?.[0].__component).toBe('sections.hero')
    })

    it('falls back to production content on HTTP error', async () => {
      mockStrapiHttpError()
      const result = await getHomePage()
      expect(result.content?.[0].__component).toBe('sections.hero')
    })
  })

  // ─── getAboutPage ─────────────────────────────────────────────────────────

  describe('getAboutPage', () => {
    it('returns CMS data when available', async () => {
      const payload = { header: { title: 'About Us' }, content: [] }
      mockStrapiOk(payload)

      const result = await getAboutPage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/about-page')
      expect(result).toEqual(payload)
    })

    it('uses 300s ISR revalidate (PAGE TTL)', async () => {
      mockStrapiOk({})
      await getAboutPage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(300)
    })

    it('falls back to production content on network error', async () => {
      mockStrapiNetworkError()
      const result = await getAboutPage()
      expect(result.header?.title).toBe('AI Enterprise Patterns Library')
      expect(result.content).toHaveLength(4)
    })
  })

  // ─── getDocsPage ──────────────────────────────────────────────────────────

  describe('getDocsPage', () => {
    it('returns CMS data when available', async () => {
      const payload = { header: { title: 'Docs' }, content: [] }
      mockStrapiOk(payload)

      const result = await getDocsPage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/docs-page')
      expect(result).toEqual(payload)
    })

    it('uses 300s ISR revalidate (PAGE TTL)', async () => {
      mockStrapiOk({})
      await getDocsPage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(300)
    })

    it('falls back to empty object on network error', async () => {
      mockStrapiNetworkError()
      expect(await getDocsPage()).toEqual({})
    })
  })

  // ─── getLoginPage ─────────────────────────────────────────────────────────

  describe('getLoginPage', () => {
    it('returns CMS data when available', async () => {
      const payload = {
        cardTitle: 'CMS Sign In',
        cardDescription: 'CMS Description',
        signInButtonLabel: 'Sign In with CMS',
      }
      mockStrapiOk(payload)

      const result = await getLoginPage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/login-page')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (STATIC TTL)', async () => {
      mockStrapiOk({})
      await getLoginPage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getLoginPage()

      expect(result.cardTitle).toBe('Sign in')
      expect(result.cardDescription).toBe('Access the AI Enterprise Patterns Library')
      expect(result.signInButtonLabel).toBe('Continue with Microsoft')
      expect(result.signInLoadingLabel).toBe('Redirecting...')
      expect(result.footerNotice).toContain('Microsoft Entra')
      expect(result.errorMessages?.['OAuthSignin']).toBeDefined()
      expect(result.errorMessages?.['OAuthCallback']).toBeDefined()
      expect(result.errorMessages?.['AccessDenied']).toBeDefined()
      expect(result.errorMessages?.['Default']).toBeDefined()
    })

    it('falls back to hardcoded defaults on HTTP error', async () => {
      mockStrapiHttpError()
      const result = await getLoginPage()
      expect(result.cardTitle).toBe('Sign in')
    })
  })

  // ─── getNotFoundPage ──────────────────────────────────────────────────────

  describe('getNotFoundPage', () => {
    it('returns CMS data when available', async () => {
      const payload = { errorCode: '404', heading: 'CMS Not Found', message: 'CMS msg' }
      mockStrapiOk(payload)

      const result = await getNotFoundPage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/not-found-page')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (STATIC TTL)', async () => {
      mockStrapiOk({})
      await getNotFoundPage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getNotFoundPage()

      expect(result.errorCode).toBe('404')
      expect(result.heading).toBe('Page Not Found')
      expect(result.message).toContain('does not exist')
      expect(result.backButton?.label).toBe('Back to Home')
      expect(result.backButton?.href).toBe('/')
    })
  })

  // ─── getErrorPage ─────────────────────────────────────────────────────────

  describe('getErrorPage', () => {
    it('returns CMS data when available', async () => {
      const payload = { title: 'CMS Error', description: 'CMS desc', retryButtonLabel: 'Retry', homeButtonLabel: 'Home' }
      mockStrapiOk(payload)

      const result = await getErrorPage()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/error-page')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (STATIC TTL)', async () => {
      mockStrapiOk({})
      await getErrorPage()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getErrorPage()

      expect(result.title).toBe('Something went wrong')
      expect(result.description).toContain('error')
      expect(result.retryButtonLabel).toBe('Try again')
      expect(result.homeButtonLabel).toBe('Go home')
    })

    it('falls back to hardcoded defaults on HTTP error', async () => {
      mockStrapiHttpError()
      const result = await getErrorPage()
      expect(result.title).toBe('Something went wrong')
    })
  })

  // ─── getPatternListingLabels ──────────────────────────────────────────────

  describe('getPatternListingLabels', () => {
    it('returns CMS data when available', async () => {
      const payload = { pageTitle: 'CMS Patterns', searchPlaceholder: 'CMS search...' }
      mockStrapiOk(payload)

      const result = await getPatternListingLabels()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/pattern-listing-labels')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (LABELS TTL)', async () => {
      mockStrapiOk({})
      await getPatternListingLabels()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getPatternListingLabels()

      expect(result.pageTitle).toBe('Browse Patterns')
      expect(result.searchPlaceholder).toBe('Search patterns...')
      expect(result.sortByLabel).toBe('Sort by:')
      expect(result.sortOptions).toHaveLength(3)
      expect(result.sortOptions?.[0]).toEqual({ value: 'newest', label: 'Most Recent' })
      expect(result.sortOptions?.[1]).toEqual({ value: 'popular', label: 'Most Popular' })
      expect(result.sortOptions?.[2]).toEqual({ value: 'title', label: 'Title A-Z' })
      expect(result.filterSectionHeader).toBe('Filters')
      expect(result.clearAllLabel).toBe('Clear all')
      expect(result.categoryLabel).toBe('Category')
      expect(result.allCategoriesLabel).toBe('All Categories')
      expect(result.tagsLabel).toBe('Tags')
      expect(result.tagModeLabel).toBe('Match:')
      expect(result.anyLabel).toBe('Any')
      expect(result.allLabel).toBe('All')
      expect(result.dateRangeHeader).toBe('Date Range')
      expect(result.clearDatesLabel).toBe('Clear dates')
      expect(result.fromLabel).toBe('From')
      expect(result.toLabel).toBe('To')
      expect(result.activeFiltersLabel).toBe('Active Filters')
      expect(result.filtersButtonLabel).toBe('Filters')
      expect(result.filterSheetTitle).toBe('Filter Patterns')
      expect(result.filterSheetDescription).toContain('category')
      expect(result.savedSearchesHeader).toBe('Saved Searches')
      expect(result.saveCurrentLabel).toBe('Save current')
      expect(result.saveDialogTitle).toBe('Save Search')
      expect(result.searchNameLabel).toBe('Search name')
      expect(result.cancelLabel).toBe('Cancel')
      expect(result.saveLabel).toBe('Save')
      expect(result.recentlyViewedHeader).toBe('Recently Viewed')
      expect(result.clearLabel).toBe('Clear')
      expect(result.previousLabel).toBe('Previous')
      expect(result.nextLabel).toBe('Next')
      expect(result.emptyFilteredHeading).toBe('No patterns found')
      expect(result.emptyUnfilteredHeading).toBe('No patterns available')
      expect(result.emptyFilteredDescription).toBeDefined()
      expect(result.emptyUnfilteredDescription).toBeDefined()
      expect(result.clearFiltersLabel).toBe('Clear all filters')
    })

    it('falls back to hardcoded defaults on HTTP error', async () => {
      mockStrapiHttpError()
      const result = await getPatternListingLabels()
      expect(result.pageTitle).toBe('Browse Patterns')
    })
  })

  // ─── getPatternDetailLabels ───────────────────────────────────────────────

  describe('getPatternDetailLabels', () => {
    it('returns CMS data when available', async () => {
      const payload = { breadcrumbAriaLabel: 'CMS Breadcrumb', votesLabel: 'upvotes' }
      mockStrapiOk(payload)

      const result = await getPatternDetailLabels()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/pattern-detail-labels')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (LABELS TTL)', async () => {
      mockStrapiOk({})
      await getPatternDetailLabels()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getPatternDetailLabels()

      expect(result.breadcrumbAriaLabel).toBe('Breadcrumb')
      expect(result.voteAriaTemplate).toContain('{count}')
      expect(result.votesLabel).toBe('votes')
      expect(result.voteAnnouncementTemplate).toContain('{count}')
      expect(result.noContentMessage).toBeDefined()
      expect(result.relatedPatternsTitle).toBe('Related Patterns')
      expect(result.noRelatedMessage).toBeDefined()
      expect(result.editLabel).toBe('Edit')
      expect(result.deleteLabel).toBe('Delete')
      expect(result.deleteDialogTitle).toBeDefined()
      expect(result.deleteDialogDescription).toBeDefined()
      expect(result.cancelLabel).toBe('Cancel')
      expect(result.deleteConfirmLabel).toBe('Delete')
      expect(result.deletingLabel).toBe('Deleting...')
    })
  })

  // ─── getPatternFormLabels ─────────────────────────────────────────────────

  describe('getPatternFormLabels', () => {
    it('returns CMS data when available', async () => {
      const payload = { createTitle: 'CMS Create', editTitle: 'CMS Edit' }
      mockStrapiOk(payload)

      const result = await getPatternFormLabels()

      expect((mockFetch.mock.calls[0][0] as string)).toContain('/api/pattern-form-labels')
      expect(result).toEqual(payload)
    })

    it('uses 3600s ISR revalidate (LABELS TTL)', async () => {
      mockStrapiOk({})
      await getPatternFormLabels()
      const fetchOptions = mockFetch.mock.calls[0][1] as RequestInit
      expect((fetchOptions?.next as { revalidate?: number })?.revalidate).toBe(3600)
    })

    it('falls back to hardcoded defaults on network error', async () => {
      mockStrapiNetworkError()

      const result = await getPatternFormLabels()

      expect(result.createTitle).toBe('New Pattern')
      expect(result.editTitle).toBe('Edit Pattern')
      expect(result.titleLabel).toBe('Title *')
      expect(result.titlePlaceholder).toBeDefined()
      expect(result.slugPreviewTemplate).toContain('{slug}')
      expect(result.shortDescLabel).toBe('Short Description *')
      expect(result.categoryLabel).toBe('Category *')
      expect(result.tagsLabel).toBe('Tags')
      expect(result.tagCountTemplate).toContain('{count}')
      expect(result.tagCountTemplate).toContain('{max}')
      expect(result.contentLabel).toContain('Markdown')
      expect(result.cancelLabel).toBe('Cancel')
      expect(result.createLabel).toBe('Create Pattern')
      expect(result.creatingLabel).toBe('Creating...')
      expect(result.saveLabel).toBe('Save Changes')
      expect(result.savingLabel).toBe('Saving...')
    })

    it('falls back to hardcoded defaults on HTTP error', async () => {
      mockStrapiHttpError()
      const result = await getPatternFormLabels()
      expect(result.createTitle).toBe('New Pattern')
    })
  })
})
