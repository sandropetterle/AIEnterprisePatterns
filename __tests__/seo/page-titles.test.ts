/**
 * Page Title Suffix Tests (BSW-0001: page-title-suffix-doubled)
 *
 * The root layout (`app/layout.tsx`) declares `title.template: '%s | AI Enterprise
 * Patterns'`, which appends the site suffix to every page's document title exactly
 * once. Pages must therefore export a *bare* title (e.g. `About`) — hardcoding the
 * suffix into a page's own `title` doubles it in the rendered <title>
 * (e.g. `About | AI Enterprise Patterns | AI Enterprise Patterns`).
 *
 * Heavy server-only / client-component imports are mocked so the page modules can
 * be loaded in jsdom just to read their metadata exports.
 */

jest.mock('@/lib/cms/queries', () => ({
  getAboutPage: jest.fn(),
  getDocsPage: jest.fn(),
  getPatternFormLabels: jest.fn(),
  getPatternDetailLabels: jest.fn(),
}))
jest.mock('@/lib/cms/components', () => ({ DynamicZone: () => null }))
jest.mock('@/auth', () => ({ auth: jest.fn() }))
jest.mock('@/lib/api/patterns', () => ({
  getPatternBySlug: jest.fn(),
  getPatterns: jest.fn(),
  getRelatedPatterns: jest.fn(),
}))
jest.mock('@/components/patterns/PatternForm', () => ({ PatternForm: () => null }))
jest.mock('@/components/patterns/details/Breadcrumb', () => ({ Breadcrumb: () => null }))
jest.mock('@/components/patterns/details/VotingButton', () => ({ VotingButton: () => null }))
jest.mock('@/components/patterns/details/RelatedPatternsSection', () => ({
  RelatedPatternsSection: () => null,
}))
jest.mock('@/components/patterns/details/PatternActions', () => ({ PatternActions: () => null }))
jest.mock('@/components/patterns/RecentlyViewedTracker', () => ({
  RecentlyViewedTracker: () => null,
}))
jest.mock('@/components/shared/JsonLd', () => ({ JsonLd: () => null }))
jest.mock('@/components/shared/ErrorBoundary', () => ({ ErrorBoundary: () => null }))

import { generateMetadata as generateAboutMetadata } from '@/app/about/page'
import { generateMetadata as generateDocsMetadata } from '@/app/docs/page'
import { metadata as newPatternMetadata } from '@/app/patterns/new/page'
import { generateMetadata as generateDetailMetadata } from '@/app/patterns/[slug]/page'
import { generateMetadata as generateEditMetadata } from '@/app/patterns/[slug]/edit/page'
import { getAboutPage, getDocsPage } from '@/lib/cms/queries'
import { getPatternBySlug } from '@/lib/api/patterns'

const SUFFIX = /\| AI Enterprise Patterns/

describe('Page document titles (layout template appends the site suffix once)', () => {
  it('/about default metadata title is bare "About"', async () => {
    ;(getAboutPage as jest.Mock).mockReturnValue(Promise.resolve({}))

    const metadata = await generateAboutMetadata()

    expect(metadata.title).toBe('About')
    expect(String(metadata.title)).not.toMatch(SUFFIX)
  })

  it('/docs default metadata title is bare "Documentation"', async () => {
    ;(getDocsPage as jest.Mock).mockReturnValue(Promise.resolve({}))

    const metadata = await generateDocsMetadata()

    expect(metadata.title).toBe('Documentation')
    expect(String(metadata.title)).not.toMatch(SUFFIX)
  })

  it('/patterns/new metadata title is bare "New Pattern"', () => {
    expect(newPatternMetadata.title).toBe('New Pattern')
    expect(String(newPatternMetadata.title)).not.toMatch(SUFFIX)
  })

  it('/patterns/[slug] metadata title is the bare pattern title', async () => {
    ;(getPatternBySlug as jest.Mock).mockReturnValue(
      Promise.resolve({
        title: 'Clean Architecture AI Refactoring',
        shortDescription: 'Refactor legacy code with AI assistance.',
        category: 'Architecture',
        tags: ['clean-architecture'],
        createdDate: '2026-01-01T00:00:00Z',
        updatedDate: '2026-01-02T00:00:00Z',
      })
    )

    const metadata = await generateDetailMetadata({
      params: Promise.resolve({ slug: 'clean-architecture-ai-refactoring' }),
    })

    expect(metadata.title).toBe('Clean Architecture AI Refactoring')
    expect(String(metadata.title)).not.toMatch(SUFFIX)
  })

  it('/patterns/[slug]/edit metadata title is bare "Edit Pattern"', async () => {
    const metadata = await generateEditMetadata({
      params: Promise.resolve({ slug: 'clean-architecture-ai-refactoring' }),
    })

    expect(metadata.title).toBe('Edit Pattern')
    expect(String(metadata.title)).not.toMatch(SUFFIX)
  })
})
