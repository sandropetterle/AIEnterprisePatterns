/**
 * Mapper Tests - CRITICAL
 * Tests bidirectional category mapping between backend (PascalCase) and frontend (spaced strings)
 */

import { describe, it, expect } from '@jest/globals'
import {
  mapCategoryFromApi,
  mapCategoryToApi,
  mapPatternListDto,
  mapPatternDetailDto,
  mapPaginatedResponse,
  normalizeSortOption,
} from '../mappers'
import type { PatternListDto, PatternDetailDto, PaginatedResponse } from '../types'
import type { PatternCategory } from '@/lib/types/pattern'

describe('Category Mapping', () => {
  describe('mapCategoryFromApi', () => {
    it('should map Architecture correctly', () => {
      expect(mapCategoryFromApi('Architecture')).toBe('Architecture')
    })

    it('should map DesignPatterns to "Design Patterns"', () => {
      expect(mapCategoryFromApi('DesignPatterns')).toBe('Design Patterns')
    })

    it('should map AIPrompts to "AI Prompts"', () => {
      expect(mapCategoryFromApi('AIPrompts')).toBe('AI Prompts')
    })

    it('should map BestPractices to "Best Practices"', () => {
      expect(mapCategoryFromApi('BestPractices')).toBe('Best Practices')
    })

    it('should map CodeGeneration to "Code Generation"', () => {
      expect(mapCategoryFromApi('CodeGeneration')).toBe('Code Generation')
    })

    it('should map Testing correctly', () => {
      expect(mapCategoryFromApi('Testing')).toBe('Testing')
    })

    it('should map Security correctly', () => {
      expect(mapCategoryFromApi('Security')).toBe('Security')
    })

    it('should map Performance correctly', () => {
      expect(mapCategoryFromApi('Performance')).toBe('Performance')
    })

    it('should default to Architecture for unknown categories', () => {
      expect(mapCategoryFromApi('Unknown')).toBe('Architecture')
    })
  })

  describe('mapCategoryToApi', () => {
    it('should map Architecture correctly', () => {
      expect(mapCategoryToApi('Architecture')).toBe('Architecture')
    })

    it('should map "Design Patterns" to DesignPatterns', () => {
      expect(mapCategoryToApi('Design Patterns')).toBe('DesignPatterns')
    })

    it('should map "AI Prompts" to AIPrompts', () => {
      expect(mapCategoryToApi('AI Prompts')).toBe('AIPrompts')
    })

    it('should map "Best Practices" to BestPractices', () => {
      expect(mapCategoryToApi('Best Practices')).toBe('BestPractices')
    })

    it('should map "Code Generation" to CodeGeneration', () => {
      expect(mapCategoryToApi('Code Generation')).toBe('CodeGeneration')
    })

    it('should map Testing correctly', () => {
      expect(mapCategoryToApi('Testing')).toBe('Testing')
    })

    it('should map Security correctly', () => {
      expect(mapCategoryToApi('Security')).toBe('Security')
    })

    it('should map Performance correctly', () => {
      expect(mapCategoryToApi('Performance')).toBe('Performance')
    })

    it('should default to Architecture for unknown categories', () => {
      expect(mapCategoryToApi('Unknown' as PatternCategory)).toBe('Architecture')
    })
  })

  describe('Bidirectional Mapping', () => {
    const apiCategories = [
      'Architecture',
      'DesignPatterns',
      'AIPrompts',
      'BestPractices',
      'CodeGeneration',
      'Testing',
      'Security',
      'Performance',
    ]

    it('should be reversible for all categories', () => {
      apiCategories.forEach((apiCat) => {
        const uiCat = mapCategoryFromApi(apiCat)
        const backToApi = mapCategoryToApi(uiCat)
        expect(backToApi).toBe(apiCat)
      })
    })
  })
})

describe('normalizeSortOption', () => {
  it('passes through canonical SortOption values unchanged', () => {
    expect(normalizeSortOption('recent')).toBe('recent')
    expect(normalizeSortOption('votes')).toBe('votes')
    expect(normalizeSortOption('alphabetical')).toBe('alphabetical')
  })

  it('maps the CMS-fallback alias "newest" to "recent" (issue #76)', () => {
    expect(normalizeSortOption('newest')).toBe('recent')
  })

  it('maps the CMS-fallback alias "popular" to "votes" (issue #76)', () => {
    expect(normalizeSortOption('popular')).toBe('votes')
  })

  it('maps the CMS-fallback alias "title" to "alphabetical" (issue #76)', () => {
    expect(normalizeSortOption('title')).toBe('alphabetical')
  })

  it('falls back to "recent" for unknown values instead of forwarding them (issue #77)', () => {
    expect(normalizeSortOption('garbage-invalid-value')).toBe('recent')
  })

  it('falls back to "recent" for undefined and empty string', () => {
    expect(normalizeSortOption(undefined)).toBe('recent')
    expect(normalizeSortOption('')).toBe('recent')
  })
})

describe('mapPatternListDto', () => {
  const createMockDto = (): PatternListDto => ({
    id: '123e4567-e89b-12d3-a456-426614174000',
    title: 'Test Pattern',
    slug: 'test-pattern',
    shortDescription: 'A test pattern',
    category: 'DesignPatterns',
    tags: ['Testing', 'Sample'],
    author: 'Test Author',
    createdDate: '2024-01-15T10:00:00Z',
    updatedDate: '2024-01-20T14:30:00Z',
    voteCount: 42,
    status: 'published',
    isFeatured: true,
    isTrending: false,
  })

  it('should map all fields correctly', () => {
    const dto = createMockDto()
    const result = mapPatternListDto(dto)

    expect(result.id).toBe(dto.id)
    expect(result.title).toBe(dto.title)
    expect(result.slug).toBe(dto.slug)
    expect(result.shortDescription).toBe(dto.shortDescription)
    expect(result.tags).toEqual(dto.tags)
    expect(result.author).toBe(dto.author)
    expect(result.createdDate).toBe(dto.createdDate)
    expect(result.updatedDate).toBe(dto.updatedDate)
    expect(result.voteCount).toBe(dto.voteCount)
    expect(result.status).toBe(dto.status)
    expect(result.isFeatured).toBe(dto.isFeatured)
    expect(result.isTrending).toBe(dto.isTrending)
  })

  it('should map category from PascalCase to spaced format', () => {
    const dto = createMockDto()
    dto.category = 'DesignPatterns'

    const result = mapPatternListDto(dto)

    expect(result.category).toBe('Design Patterns')
  })

  it('should handle null author', () => {
    const dto = createMockDto()
    dto.author = null

    const result = mapPatternListDto(dto)

    expect(result.author).toBeUndefined()
  })

  it('should map all category types correctly', () => {
    const dto = createMockDto()

    const categoryMappings = [
      { api: 'Architecture', ui: 'Architecture' },
      { api: 'DesignPatterns', ui: 'Design Patterns' },
      { api: 'AIPrompts', ui: 'AI Prompts' },
      { api: 'Security', ui: 'Security' },
      { api: 'Performance', ui: 'Performance' },
    ]

    categoryMappings.forEach(({ api, ui }) => {
      dto.category = api
      const result = mapPatternListDto(dto)
      expect(result.category).toBe(ui)
    })
  })
})

describe('mapPatternDetailDto', () => {
  const createMockDetailDto = (): PatternDetailDto => ({
    id: '123e4567-e89b-12d3-a456-426614174000',
    title: 'Test Pattern',
    slug: 'test-pattern',
    shortDescription: 'A test pattern',
    fullContent: '# Full Content\n\nDetailed markdown content here.',
    category: 'Architecture',
    tags: ['Testing', 'Sample'],
    author: 'Test Author',
    createdDate: '2024-01-15T10:00:00Z',
    updatedDate: '2024-01-20T14:30:00Z',
    voteCount: 42,
    status: 'published',
    isFeatured: true,
    isTrending: false,
  })

  it('should map all fields including fullContent', () => {
    const dto = createMockDetailDto()
    const result = mapPatternDetailDto(dto)

    expect(result.id).toBe(dto.id)
    expect(result.title).toBe(dto.title)
    expect(result.slug).toBe(dto.slug)
    expect(result.shortDescription).toBe(dto.shortDescription)
    expect(result.fullContent).toBe(dto.fullContent)
    expect(result.tags).toEqual(dto.tags)
    expect(result.author).toBe(dto.author)
    expect(result.createdDate).toBe(dto.createdDate)
    expect(result.updatedDate).toBe(dto.updatedDate)
    expect(result.voteCount).toBe(dto.voteCount)
    expect(result.status).toBe(dto.status)
    expect(result.isFeatured).toBe(dto.isFeatured)
    expect(result.isTrending).toBe(dto.isTrending)
  })

  it('should map category correctly', () => {
    const dto = createMockDetailDto()
    dto.category = 'AIPrompts'

    const result = mapPatternDetailDto(dto)

    expect(result.category).toBe('AI Prompts')
  })

  it('should handle null fullContent', () => {
    const dto = createMockDetailDto()
    dto.fullContent = null

    const result = mapPatternDetailDto(dto)

    expect(result.fullContent).toBeUndefined()
  })

  it('should handle null author', () => {
    const dto = createMockDetailDto()
    dto.author = null

    const result = mapPatternDetailDto(dto)

    expect(result.author).toBeUndefined()
  })
})

describe('mapPaginatedResponse', () => {
  const createMockResponse = (): PaginatedResponse<PatternListDto> => ({
    patterns: [
      {
        id: '123e4567-e89b-12d3-a456-426614174001',
        title: 'Pattern 1',
        slug: 'pattern-1',
        shortDescription: 'First pattern',
        category: 'Architecture',
        tags: ['Tag1'],
        author: 'Author 1',
        createdDate: '2024-01-15T10:00:00Z',
        updatedDate: '2024-01-15T10:00:00Z',
        voteCount: 10,
        status: 'published',
        isFeatured: false,
        isTrending: false,
      },
      {
        id: '123e4567-e89b-12d3-a456-426614174002',
        title: 'Pattern 2',
        slug: 'pattern-2',
        shortDescription: 'Second pattern',
        category: 'DesignPatterns',
        tags: ['Tag2'],
        author: 'Author 2',
        createdDate: '2024-01-16T10:00:00Z',
        updatedDate: '2024-01-16T10:00:00Z',
        voteCount: 20,
        status: 'published',
        isFeatured: true,
        isTrending: false,
      },
    ],
    totalCount: 50,
    currentPage: 2,
    pageSize: 2,
    totalPages: 25,
  })

  it('should map all pagination fields', () => {
    const response = createMockResponse()
    const result = mapPaginatedResponse(response)

    expect(result.patterns).toHaveLength(2)
    expect(result.totalCount).toBe(50)
    expect(result.currentPage).toBe(2)
    expect(result.totalPages).toBe(25)
  })

  it('should map all patterns with correct category transformation', () => {
    const response = createMockResponse()
    const result = mapPaginatedResponse(response)

    expect(result.patterns[0].category).toBe('Architecture')
    expect(result.patterns[1].category).toBe('Design Patterns')
  })

  it('should calculate hasNextPage correctly', () => {
    const response = createMockResponse()

    // Page 2 of 25 should have next page
    response.currentPage = 2
    response.totalPages = 25
    expect(mapPaginatedResponse(response).hasNextPage).toBe(true)

    // Last page should not have next page
    response.currentPage = 25
    expect(mapPaginatedResponse(response).hasNextPage).toBe(false)
  })

  it('should calculate hasPreviousPage correctly', () => {
    const response = createMockResponse()

    // First page should not have previous page
    response.currentPage = 1
    expect(mapPaginatedResponse(response).hasPreviousPage).toBe(false)

    // Page 2 should have previous page
    response.currentPage = 2
    expect(mapPaginatedResponse(response).hasPreviousPage).toBe(true)
  })

  it('should handle empty patterns array', () => {
    const response = createMockResponse()
    response.patterns = []
    response.totalCount = 0
    response.currentPage = 1
    response.totalPages = 0

    const result = mapPaginatedResponse(response)

    expect(result.patterns).toHaveLength(0)
    expect(result.totalCount).toBe(0)
    expect(result.hasNextPage).toBe(false)
    expect(result.hasPreviousPage).toBe(false)
  })
})
