/**
 * Pattern API Functions Tests
 * Tests both async API functions and client-side utility helpers
 */

import { describe, it, expect, jest, beforeEach, afterEach } from '@jest/globals'
import type { Pattern } from '@/lib/types/pattern'
import type { PatternDetailDto, PaginatedResponse, PatternListDto } from '../types'
import { apiClient } from '../client'
import { ApiError } from '../error'
import {
  getAllCategories,
  getAllTags,
  getPatternStats,
  getPatterns,
  getFeaturedPatterns,
  getTrendingPatterns,
  getPatternBySlug,
  voteForPattern,
  getRelatedPatterns,
} from '../patterns'

// Typed spies set up in beforeEach
let getSpy: ReturnType<typeof jest.spyOn>
let postSpy: ReturnType<typeof jest.spyOn>

const makeDetailDto = (overrides: Partial<PatternDetailDto> = {}): PatternDetailDto => ({
  id: 'test-id',
  title: 'Test Pattern',
  slug: 'test-pattern',
  shortDescription: 'A test pattern',
  fullContent: null,
  category: 'Architecture',
  tags: ['react'],
  author: null,
  createdDate: '2024-01-15T00:00:00Z',
  updatedDate: '2024-01-15T00:00:00Z',
  voteCount: 5,
  status: 'published',
  isFeatured: false,
  isTrending: false,
  ...overrides,
})

const makePaginatedResponse = (dtos: PatternListDto[]): PaginatedResponse<PatternListDto> => ({
  patterns: dtos,
  totalCount: dtos.length,
  currentPage: 1,
  pageSize: 9,
  totalPages: 1,
})

describe('Async Pattern API Functions', () => {
  beforeEach(() => {
    getSpy = jest.spyOn(apiClient, 'get')
    postSpy = jest.spyOn(apiClient, 'post')
  })

  afterEach(() => {
    jest.restoreAllMocks()
  })

  describe('getPatterns', () => {
    it('calls GET /patterns with default params', async () => {
      const dto = makeDetailDto() as unknown as PatternListDto
      getSpy.mockResolvedValueOnce(makePaginatedResponse([dto]))

      const result = await getPatterns()

      expect(getSpy).toHaveBeenCalledWith(
        expect.stringContaining('/patterns?')
      )
      expect(result.currentPage).toBe(1)
      expect(result.patterns).toHaveLength(1)
    })

    it('passes category param mapped to backend format', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ category: 'Design Patterns' })

      expect(getSpy).toHaveBeenCalledWith(
        expect.stringContaining('category=DesignPatterns')
      )
    })

    it('passes tags as comma-separated string', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ tags: ['react', 'node'] })

      const url = getSpy.mock.calls[0][0] as string
      expect(url).toContain('tags=')
      expect(url).toContain('react')
      expect(url).toContain('node')
    })

    it('passes search param', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ search: 'my query' })

      expect(getSpy).toHaveBeenCalledWith(
        expect.stringContaining('search=')
      )
    })

    it('does not append category param when not provided', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ sortBy: 'votes' })

      const url = getSpy.mock.calls[0][0] as string
      expect(url).not.toContain('category=')
    })

    it('does not append tags param when tags is empty', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ tags: [] })

      const url = getSpy.mock.calls[0][0] as string
      expect(url).not.toContain('tags=')
    })

    it('does not append search param when not provided', async () => {
      getSpy.mockResolvedValueOnce(makePaginatedResponse([]))

      await getPatterns({ page: 2 })

      const url = getSpy.mock.calls[0][0] as string
      expect(url).not.toContain('search=')
    })
  })

  describe('getFeaturedPatterns', () => {
    it('calls GET /patterns/featured', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto({ isFeatured: true })])

      const result = await getFeaturedPatterns()

      expect(getSpy).toHaveBeenCalledWith('/patterns/featured')
      expect(result).toHaveLength(1)
    })

    it('returns mapped Pattern objects', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto({ title: 'Featured One' })])

      const result = await getFeaturedPatterns()

      expect(result[0].title).toBe('Featured One')
    })

    it('returns empty array when no featured patterns', async () => {
      getSpy.mockResolvedValueOnce([])

      const result = await getFeaturedPatterns()

      expect(result).toHaveLength(0)
    })
  })

  describe('getTrendingPatterns', () => {
    it('calls GET /patterns/trending', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto({ isTrending: true })])

      const result = await getTrendingPatterns()

      expect(getSpy).toHaveBeenCalledWith('/patterns/trending')
      expect(result).toHaveLength(1)
    })

    it('maps trending pattern fields correctly', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto({ title: 'Trending', voteCount: 99 })])

      const result = await getTrendingPatterns()

      expect(result[0].voteCount).toBe(99)
    })
  })

  describe('getPatternBySlug', () => {
    it('returns a mapped pattern on success', async () => {
      getSpy.mockResolvedValueOnce(makeDetailDto({ slug: 'test-slug' }))

      const result = await getPatternBySlug('test-slug')

      expect(getSpy).toHaveBeenCalledWith('/patterns/test-slug')
      expect(result).not.toBeNull()
      expect(result?.slug).toBe('test-slug')
    })

    it('returns null when API returns 404 error', async () => {
      getSpy.mockRejectedValueOnce(new ApiError('Not Found', 404, '/patterns/missing-slug'))

      const result = await getPatternBySlug('missing-slug')

      expect(result).toBeNull()
    })

    it('re-throws non-404 errors', async () => {
      getSpy.mockRejectedValueOnce(new Error('500 Internal Server Error'))

      await expect(getPatternBySlug('any-slug')).rejects.toThrow('500')
    })
  })

  describe('voteForPattern', () => {
    it('calls POST /patterns/{id}/vote', async () => {
      postSpy.mockResolvedValueOnce({ patternId: 'abc', voteCount: 11 })

      const result = await voteForPattern('abc')

      expect(postSpy).toHaveBeenCalledWith('/patterns/abc/vote')
      expect(result.voteCount).toBe(11)
    })
  })

  describe('getRelatedPatterns', () => {
    it('calls GET /patterns/{slug}/related', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto()])

      const result = await getRelatedPatterns('test-slug')

      expect(getSpy).toHaveBeenCalledWith('/patterns/test-slug/related')
      expect(result).toHaveLength(1)
    })

    it('returns mapped Pattern objects', async () => {
      getSpy.mockResolvedValueOnce([makeDetailDto({ title: 'Related Pattern', voteCount: 7 })])

      const result = await getRelatedPatterns('test-slug')

      expect(result[0].title).toBe('Related Pattern')
      expect(result[0].voteCount).toBe(7)
    })

    it('returns empty array on error', async () => {
      getSpy.mockRejectedValueOnce(new Error('Network error'))

      const result = await getRelatedPatterns('test-slug')

      expect(result).toEqual([])
    })

    it('returns empty array when API returns no related patterns', async () => {
      getSpy.mockResolvedValueOnce([])

      const result = await getRelatedPatterns('test-slug')

      expect(result).toHaveLength(0)
    })
  })
})

describe('Pattern Helper Functions', () => {
  const mockPatterns: Pattern[] = [
    {
      id: '1',
      title: 'Pattern 1',
      slug: 'pattern-1',
      shortDescription: 'Description',
      category: 'Architecture',
      tags: ['Tag1', 'Tag2'],
      author: 'Author 1',
      createdDate: '2024-01-15T10:00:00Z',
      updatedDate: '2024-01-15T10:00:00Z',
      voteCount: 10,
      status: 'published',
      isFeatured: false,
      isTrending: false,
    },
    {
      id: '2',
      title: 'Pattern 2',
      slug: 'pattern-2',
      shortDescription: 'Description',
      category: 'Design Patterns',
      tags: ['Tag2', 'Tag3'],
      author: 'Author 2',
      createdDate: '2024-01-16T10:00:00Z',
      updatedDate: '2024-01-16T10:00:00Z',
      voteCount: 20,
      status: 'published',
      isFeatured: true,
      isTrending: false,
    },
    {
      id: '3',
      title: 'Pattern 3',
      slug: 'pattern-3',
      shortDescription: 'Description',
      category: 'Architecture',
      tags: ['Tag1', 'Tag4'],
      author: 'Author 1',
      createdDate: '2024-01-17T10:00:00Z',
      updatedDate: '2024-01-17T10:00:00Z',
      voteCount: 30,
      status: 'published',
      isFeatured: false,
      isTrending: true,
    },
  ]

  describe('getAllCategories', () => {
    it('should extract unique categories from patterns', () => {
      const categories = getAllCategories(mockPatterns)

      expect(categories).toHaveLength(2)
      expect(categories).toContain('Architecture')
      expect(categories).toContain('Design Patterns')
    })

    it('should return sorted categories', () => {
      const categories = getAllCategories(mockPatterns)

      expect(categories[0]).toBe('Architecture')
      expect(categories[1]).toBe('Design Patterns')
    })

    it('should handle empty array', () => {
      const categories = getAllCategories([])

      expect(categories).toHaveLength(0)
    })

    it('should handle single pattern', () => {
      const categories = getAllCategories([mockPatterns[0]])

      expect(categories).toHaveLength(1)
      expect(categories[0]).toBe('Architecture')
    })

    it('should handle all patterns with same category', () => {
      const sameCategory = mockPatterns.map((p) => ({
        ...p,
        category: 'Architecture' as const,
      }))
      const categories = getAllCategories(sameCategory)

      expect(categories).toHaveLength(1)
      expect(categories[0]).toBe('Architecture')
    })
  })

  describe('getAllTags', () => {
    it('should extract unique tags from patterns', () => {
      const tags = getAllTags(mockPatterns)

      expect(tags).toHaveLength(4)
      expect(tags).toContain('Tag1')
      expect(tags).toContain('Tag2')
      expect(tags).toContain('Tag3')
      expect(tags).toContain('Tag4')
    })

    it('should return sorted tags', () => {
      const tags = getAllTags(mockPatterns)

      expect(tags[0]).toBe('Tag1')
      expect(tags[1]).toBe('Tag2')
      expect(tags[2]).toBe('Tag3')
      expect(tags[3]).toBe('Tag4')
    })

    it('should handle empty array', () => {
      const tags = getAllTags([])

      expect(tags).toHaveLength(0)
    })

    it('should handle patterns with no tags', () => {
      const patternsWithoutTags = mockPatterns.map((p) => ({ ...p, tags: [] }))
      const tags = getAllTags(patternsWithoutTags)

      expect(tags).toHaveLength(0)
    })

    it('should handle patterns with duplicate tags across patterns', () => {
      const tags = getAllTags(mockPatterns)

      // Tag2 appears in both pattern 1 and 2, but should only appear once
      expect(tags.filter((t) => t === 'Tag2')).toHaveLength(1)
    })

    it('should handle patterns with single tag', () => {
      const singleTagPatterns = mockPatterns.map((p) => ({
        ...p,
        tags: ['CommonTag'],
      }))
      const tags = getAllTags(singleTagPatterns)

      expect(tags).toHaveLength(1)
      expect(tags[0]).toBe('CommonTag')
    })
  })

  describe('getPatternStats', () => {
    it('should calculate correct statistics', () => {
      const stats = getPatternStats(mockPatterns)

      expect(stats.totalPatterns).toBe(3)
      expect(stats.totalCategories).toBe(2)
      expect(stats.totalContributors).toBe('2+') // Author 1 and Author 2
    })

    it('should handle patterns without authors', () => {
      const patternsWithoutAuthors = mockPatterns.map((p) => ({
        ...p,
        author: undefined,
      }))
      const stats = getPatternStats(patternsWithoutAuthors)

      expect(stats.totalPatterns).toBe(3)
      expect(stats.totalCategories).toBe(2)
      expect(stats.totalContributors).toBe('15+') // Default fallback
    })

    it('should handle empty array', () => {
      const stats = getPatternStats([])

      expect(stats.totalPatterns).toBe(0)
      expect(stats.totalCategories).toBe(0)
      expect(stats.totalContributors).toBe('15+')
    })

    it('should count unique authors only', () => {
      const duplicateAuthors = [
        ...mockPatterns,
        { ...mockPatterns[0], id: '4', slug: 'pattern-4' }, // Same author as pattern 1
      ]
      const stats = getPatternStats(duplicateAuthors)

      expect(stats.totalPatterns).toBe(4)
      expect(stats.totalContributors).toBe('2+') // Still only 2 unique authors
    })

    it('should handle single pattern', () => {
      const stats = getPatternStats([mockPatterns[0]])

      expect(stats.totalPatterns).toBe(1)
      expect(stats.totalCategories).toBe(1)
      expect(stats.totalContributors).toBe('1+')
    })

    it('should handle mix of patterns with and without authors', () => {
      const mixedPatterns = [
        mockPatterns[0], // Has author
        { ...mockPatterns[1], author: undefined }, // No author
        mockPatterns[2], // Has author (same as pattern 0)
      ]
      const stats = getPatternStats(mixedPatterns)

      expect(stats.totalPatterns).toBe(3)
      expect(stats.totalContributors).toBe('1+') // Only 1 unique author (Author 1)
    })

    it('should calculate categories from diverse set', () => {
      const diversePatterns: Pattern[] = [
        { ...mockPatterns[0], category: 'Architecture' },
        { ...mockPatterns[1], category: 'Design Patterns' },
        { ...mockPatterns[2], category: 'AI Prompts' },
      ]
      const stats = getPatternStats(diversePatterns)

      expect(stats.totalCategories).toBe(3)
    })
  })
})
