/**
 * Pattern API Helper Functions Tests
 * Tests client-side utility functions for pattern data manipulation
 */

import { describe, it, expect } from '@jest/globals'
import {
  getAllCategories,
  getAllTags,
  getPatternStats,
} from '../patterns'
import type { Pattern } from '@/lib/types/pattern'

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
