import { Metadata } from 'next'
import { Suspense } from 'react'
import {
  getPatterns,
  getAllCategories,
  getAllTags,
} from '@/lib/api/patterns'
import type { SortOption } from '@/lib/types/pattern'
import { JsonLd } from '@/components/shared/JsonLd'
import type { PatternCategory } from '@/lib/types/pattern'
import { SearchBar } from '@/components/patterns/SearchBar'
import { SortSelector } from '@/components/patterns/SortSelector'
import { FilterPanel } from '@/components/patterns/FilterPanel'
import { FilterSheet } from '@/components/patterns/FilterSheet'
import { PatternsGrid } from '@/components/patterns/PatternsGrid'
import { EmptyState } from '@/components/patterns/EmptyState'
import { Pagination } from '@/components/patterns/Pagination'
import { NewPatternButton } from '@/components/patterns/NewPatternButton'

type SearchParams = Promise<{
  q?: string
  category?: string
  tags?: string
  sort?: SortOption
  page?: string
  dateFrom?: string
  dateTo?: string
  tagMode?: string
}>

export const metadata: Metadata = {
  title: 'Browse Patterns',
  description:
    'Browse our curated collection of AI-driven enterprise patterns, prompts, and architectural blueprints. Filter by category, search by keyword, and discover solutions for your projects.',
  keywords: [
    'AI patterns',
    'enterprise architecture',
    'design patterns',
    'software patterns',
    'AI prompts',
    'CQRS',
    'clean architecture',
    'microservices',
  ],
  openGraph: {
    title: 'Browse Patterns | AI Enterprise Patterns',
    description:
      'Browse our curated collection of AI-driven enterprise patterns, prompts, and architectural blueprints.',
    url: 'https://ai-patterns.example.com/patterns',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Browse Patterns | AI Enterprise Patterns',
    description:
      'Browse our curated collection of AI-driven enterprise patterns.',
  },
}

// Revalidate every 2 minutes
export const revalidate = 120

export default async function PatternsPage(props: {
  searchParams: SearchParams
}) {
  const searchParams = await props.searchParams

  // Parse search params
  const searchQuery = searchParams.q
  const category = searchParams.category
  const tags = searchParams.tags?.split(',').filter(Boolean)
  const sortBy = (searchParams.sort as SortOption) || 'recent'
  const page = parseInt(searchParams.page || '1', 10)
  const dateFrom = searchParams.dateFrom
  const dateTo = searchParams.dateTo
  const tagMode = searchParams.tagMode as 'any' | 'all' | undefined

  // Fetch patterns from API with server-side filtering, sorting, and pagination
  // Handle API unavailable during build (e.g., Docker build)
  let result: Awaited<ReturnType<typeof getPatterns>> = {
    patterns: [],
    totalCount: 0,
    currentPage: 1,
    totalPages: 0,
    hasNextPage: false,
    hasPreviousPage: false
  }
  let allCategories: PatternCategory[] = []
  let allTags: string[] = []

  try {
    result = await getPatterns({
      page,
      pageSize: 9,
      category: category as PatternCategory | undefined,
      tags,
      search: searchQuery,
      sortBy,
      dateFrom,
      dateTo,
      tagMode,
    })

    // Get all patterns for filter options and suggestions
    const allPatterns = await getPatterns({ pageSize: 100 })
    allCategories = getAllCategories(allPatterns.patterns)
    allTags = getAllTags(allPatterns.patterns)
  } catch (error) {
    console.warn('Failed to fetch patterns for listing page build:', error)
    // Will show empty state, page will be generated on-demand
  }

  const hasActiveFilters = !!(searchQuery || category || tags?.length || dateFrom || dateTo)

  // JSON-LD for SEO
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    name: 'AI Enterprise Patterns Library',
    description:
      'Browse curated AI-driven enterprise patterns and architectural blueprints',
    url: 'https://ai-patterns.example.com/patterns',
    numberOfItems: result.totalCount,
  }

  return (
    <>
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        {/* Page Header */}
        <div className="mb-8 flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight mb-2">
              Browse Patterns
            </h1>
            <p className="text-muted-foreground">
              Discover {result.totalCount}{' '}
              {result.totalCount === 1 ? 'pattern' : 'patterns'} in our library
            </p>
          </div>
          <NewPatternButton />
        </div>

        {/* Search and Sort Controls */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="flex-1">
            <Suspense
              fallback={
                <div className="h-10 bg-muted animate-pulse rounded" />
              }
            >
              <SearchBar allPatterns={result.patterns} allTags={allTags} />
            </Suspense>
          </div>
          <div className="flex gap-2">
            <div className="lg:hidden">
              <FilterSheet categories={allCategories} tags={allTags} />
            </div>
            <Suspense
              fallback={
                <div className="h-10 w-[200px] bg-muted animate-pulse rounded" />
              }
            >
              <SortSelector />
            </Suspense>
          </div>
        </div>

        {/* Main Content Grid */}
        <div className="flex gap-8">
          {/* Desktop Filter Panel */}
          <div className="hidden lg:block">
            <Suspense
              fallback={
                <div className="w-64 h-96 bg-muted animate-pulse rounded" />
              }
            >
              <FilterPanel categories={allCategories} tags={allTags} />
            </Suspense>
          </div>

          {/* Patterns Grid */}
          <div className="flex-1">
            {/* SR live region for results count */}
            <p role="status" aria-live="polite" className="sr-only">
              {result.totalCount === 0
                ? 'No patterns found'
                : `${result.totalCount} pattern${result.totalCount === 1 ? '' : 's'} found`}
            </p>

            {result.patterns.length > 0 ? (
              <>
                <PatternsGrid patterns={result.patterns} />
                <Suspense
                  fallback={
                    <div className="h-12 bg-muted animate-pulse rounded mt-8" />
                  }
                >
                  <Pagination
                    currentPage={result.currentPage}
                    totalPages={result.totalPages}
                    hasNextPage={result.hasNextPage}
                    hasPreviousPage={result.hasPreviousPage}
                  />
                </Suspense>
              </>
            ) : (
              <EmptyState hasFilters={hasActiveFilters} />
            )}
          </div>
        </div>
      </div>

      <JsonLd data={jsonLd} />
    </>
  )
}
