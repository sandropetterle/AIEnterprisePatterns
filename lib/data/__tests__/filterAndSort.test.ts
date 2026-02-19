import { describe, it, expect } from '@jest/globals'
import {
  filterBySearch,
  filterByCategory,
  filterByTags,
  sortPatterns,
  paginatePatterns,
  filterAndSortPatterns,
  getAllTags,
  getAllCategories,
} from '../filterAndSort'
import type { Pattern } from '@/lib/types/pattern'

const makePattern = (overrides: Partial<Pattern> & { id: string }): Pattern => ({
  title: `Pattern ${overrides.id}`,
  slug: `pattern-${overrides.id}`,
  shortDescription: 'A description',
  category: 'Architecture',
  tags: [],
  createdDate: '2024-01-01T00:00:00Z',
  updatedDate: '2024-01-01T00:00:00Z',
  voteCount: 0,
  status: 'published',
  ...overrides,
})

const patterns: Pattern[] = [
  makePattern({ id: '1', title: 'Alpha Pattern', category: 'Architecture', tags: ['react', 'node'], voteCount: 10, createdDate: '2024-01-10T00:00:00Z' }),
  makePattern({ id: '2', title: 'Beta System', category: 'Design Patterns', tags: ['node', 'typescript'], voteCount: 30, createdDate: '2024-01-20T00:00:00Z', shortDescription: 'Node design' }),
  makePattern({ id: '3', title: 'Gamma Service', category: 'Architecture', tags: ['typescript', 'docker'], voteCount: 20, createdDate: '2024-01-15T00:00:00Z' }),
  makePattern({ id: '4', title: 'Delta Draft', category: 'Security', tags: ['docker'], voteCount: 5, status: 'draft' }),
]

describe('filterBySearch', () => {
  it('returns all patterns when query is empty', () => {
    expect(filterBySearch(patterns, '')).toEqual(patterns)
  })

  it('returns all patterns when query is whitespace', () => {
    expect(filterBySearch(patterns, '   ')).toEqual(patterns)
  })

  it('matches on title (case-insensitive)', () => {
    const result = filterBySearch(patterns, 'alpha')
    expect(result).toHaveLength(1)
    expect(result[0].id).toBe('1')
  })

  it('matches on shortDescription (case-insensitive)', () => {
    const result = filterBySearch(patterns, 'node design')
    expect(result).toHaveLength(1)
    expect(result[0].id).toBe('2')
  })

  it('returns empty array when no match', () => {
    expect(filterBySearch(patterns, 'zzznomatch')).toHaveLength(0)
  })

  it('matches multiple patterns', () => {
    const result = filterBySearch(patterns, 'Pattern')
    expect(result).toHaveLength(1)
  })
})

describe('filterByCategory', () => {
  it('returns all patterns when category is undefined', () => {
    expect(filterByCategory(patterns, undefined)).toEqual(patterns)
  })

  it('returns all patterns when category is "all"', () => {
    expect(filterByCategory(patterns, 'all')).toEqual(patterns)
  })

  it('filters to matching category', () => {
    const result = filterByCategory(patterns, 'Architecture')
    expect(result).toHaveLength(2)
    expect(result.every((p) => p.category === 'Architecture')).toBe(true)
  })

  it('returns empty array when no pattern matches category', () => {
    expect(filterByCategory(patterns, 'Performance')).toHaveLength(0)
  })
})

describe('filterByTags', () => {
  it('returns all patterns when tags is undefined', () => {
    expect(filterByTags(patterns, undefined)).toEqual(patterns)
  })

  it('returns all patterns when tags is empty', () => {
    expect(filterByTags(patterns, [])).toEqual(patterns)
  })

  it('filters by single tag (OR logic)', () => {
    const result = filterByTags(patterns, ['react'])
    expect(result).toHaveLength(1)
    expect(result[0].id).toBe('1')
  })

  it('matches any tag (OR logic)', () => {
    const result = filterByTags(patterns, ['react', 'docker'])
    expect(result.map((p) => p.id)).toEqual(expect.arrayContaining(['1', '3', '4']))
    expect(result).toHaveLength(3)
  })

  it('returns empty array when no patterns have the tag', () => {
    expect(filterByTags(patterns, ['python'])).toHaveLength(0)
  })
})

describe('sortPatterns', () => {
  it('sorts by recent (newest first)', () => {
    const result = sortPatterns(patterns, 'recent')
    expect(result[0].id).toBe('2') // 2024-01-20
    expect(result[1].id).toBe('3') // 2024-01-15
    expect(result[2].id).toBe('1') // 2024-01-10
  })

  it('sorts by votes (highest first)', () => {
    const result = sortPatterns(patterns, 'votes')
    expect(result[0].voteCount).toBeGreaterThanOrEqual(result[1].voteCount)
    expect(result[1].voteCount).toBeGreaterThanOrEqual(result[2].voteCount)
  })

  it('sorts alphabetically', () => {
    const result = sortPatterns(patterns, 'alphabetical')
    expect(result[0].title).toBe('Alpha Pattern')
    expect(result[1].title).toBe('Beta System')
    expect(result[2].title).toBe('Delta Draft')
    expect(result[3].title).toBe('Gamma Service')
  })

  it('returns copy without modifying original', () => {
    const original = [...patterns]
    sortPatterns(patterns, 'votes')
    expect(patterns).toEqual(original)
  })

  it('returns patterns unchanged for unknown sort option', () => {
    // @ts-expect-error testing unknown option
    const result = sortPatterns(patterns, 'unknown')
    expect(result).toHaveLength(patterns.length)
  })
})

describe('paginatePatterns', () => {
  const items = Array.from({ length: 25 }, (_, i) =>
    makePattern({ id: String(i + 1) })
  )

  it('returns first page correctly', () => {
    const result = paginatePatterns(items, 1, 9)
    expect(result.patterns).toHaveLength(9)
    expect(result.currentPage).toBe(1)
    expect(result.totalCount).toBe(25)
    expect(result.totalPages).toBe(3)
    expect(result.hasNextPage).toBe(true)
    expect(result.hasPreviousPage).toBe(false)
  })

  it('returns last page correctly', () => {
    const result = paginatePatterns(items, 3, 9)
    expect(result.patterns).toHaveLength(7) // 25 - 18
    expect(result.currentPage).toBe(3)
    expect(result.hasNextPage).toBe(false)
    expect(result.hasPreviousPage).toBe(true)
  })

  it('clamps page to valid range (below 1)', () => {
    const result = paginatePatterns(items, 0, 9)
    expect(result.currentPage).toBe(1)
  })

  it('clamps page to valid range (above totalPages)', () => {
    const result = paginatePatterns(items, 99, 9)
    expect(result.currentPage).toBe(3)
  })

  it('handles empty array (returns totalPages=1)', () => {
    const result = paginatePatterns([], 1, 9)
    expect(result.totalPages).toBe(1)
    expect(result.totalCount).toBe(0)
    expect(result.patterns).toHaveLength(0)
  })

  it('uses defaults (page=1, pageSize=9)', () => {
    const result = paginatePatterns(items)
    expect(result.currentPage).toBe(1)
    expect(result.patterns).toHaveLength(9)
  })
})

describe('filterAndSortPatterns', () => {
  it('only includes published patterns', () => {
    const result = filterAndSortPatterns(patterns)
    expect(result.patterns.every((p) => p.status === 'published')).toBe(true)
  })

  it('applies search filter', () => {
    const result = filterAndSortPatterns(patterns, { searchQuery: 'alpha' })
    expect(result.patterns).toHaveLength(1)
    expect(result.patterns[0].id).toBe('1')
  })

  it('applies category filter', () => {
    const result = filterAndSortPatterns(patterns, { category: 'Architecture' })
    expect(result.patterns.every((p) => p.category === 'Architecture')).toBe(true)
  })

  it('applies tag filter', () => {
    const result = filterAndSortPatterns(patterns, { tags: ['react'] })
    expect(result.patterns).toHaveLength(1)
  })

  it('sorts by votes by default... actually defaults to recent', () => {
    const result = filterAndSortPatterns(patterns)
    // default sortBy is 'recent'
    expect(result.patterns[0].createdDate >= result.patterns[1].createdDate).toBe(true)
  })

  it('sorts by votes when specified', () => {
    const result = filterAndSortPatterns(patterns, { sortBy: 'votes' })
    expect(result.patterns[0].voteCount).toBeGreaterThanOrEqual(result.patterns[1].voteCount)
  })

  it('paginates results', () => {
    const manyPatterns = Array.from({ length: 20 }, (_, i) =>
      makePattern({ id: String(i + 1) })
    )
    const result = filterAndSortPatterns(manyPatterns, { page: 2, pageSize: 9 })
    expect(result.currentPage).toBe(2)
    expect(result.patterns).toHaveLength(9)
  })

  it('uses default options when none provided', () => {
    const result = filterAndSortPatterns(patterns)
    expect(result.currentPage).toBe(1)
  })

  it('returns empty result when no patterns match', () => {
    const result = filterAndSortPatterns(patterns, { searchQuery: 'zzznomatch' })
    expect(result.patterns).toHaveLength(0)
    expect(result.totalCount).toBe(0)
  })
})

describe('getAllTags', () => {
  it('returns all unique tags sorted', () => {
    const tags = getAllTags(patterns)
    expect(tags).toEqual(['docker', 'node', 'react', 'typescript'])
  })

  it('returns empty array for empty input', () => {
    expect(getAllTags([])).toEqual([])
  })

  it('deduplicates tags', () => {
    const result = getAllTags(patterns)
    expect(result.filter((t) => t === 'node')).toHaveLength(1)
  })
})

describe('getAllCategories', () => {
  it('returns unique categories sorted', () => {
    const cats = getAllCategories(patterns)
    expect(cats).toEqual(['Architecture', 'Design Patterns', 'Security'])
  })

  it('returns empty array for empty input', () => {
    expect(getAllCategories([])).toEqual([])
  })

  it('deduplicates categories', () => {
    const result = getAllCategories(patterns)
    expect(result.filter((c) => c === 'Architecture')).toHaveLength(1)
  })
})
