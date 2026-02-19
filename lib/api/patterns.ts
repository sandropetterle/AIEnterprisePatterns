/**
 * Pattern API Functions
 * All pattern-related API calls and helper functions
 */

import type { Pattern, PatternCategory } from '@/lib/types/pattern'
import type { PatternDetailDto, PatternListDto, PaginatedResponse, VoteResponse, CreatePatternDto, UpdatePatternDto } from './types'
import { apiClient } from './client'
import { ApiError } from './error'
import {
  mapPatternDetailDto,
  mapPaginatedResponse,
  mapCategoryToApi,
} from './mappers'

/**
 * Paginated result type for frontend
 */
type PaginatedResult = {
  patterns: Pattern[]
  totalCount: number
  currentPage: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

/**
 * Parameters for getPatterns query
 */
type GetPatternsParams = {
  page?: number
  pageSize?: number
  sortBy?: 'recent' | 'votes' | 'alphabetical'
  category?: PatternCategory
  tags?: string[]
  search?: string
}

/**
 * GET /api/patterns - Retrieve paginated list of patterns with filtering and sorting
 */
export async function getPatterns(
  params: GetPatternsParams = {}
): Promise<PaginatedResult> {
  const {
    page = 1,
    pageSize = 9,
    sortBy = 'recent',
    category,
    tags,
    search,
  } = params

  // Build query string
  const queryParams = new URLSearchParams({
    page: page.toString(),
    pageSize: pageSize.toString(),
    sortBy,
  })

  if (category) {
    queryParams.append('category', mapCategoryToApi(category))
  }

  if (tags && tags.length > 0) {
    queryParams.append('tags', tags.join(','))
  }

  if (search) {
    queryParams.append('search', search)
  }

  const response = await apiClient.get<PaginatedResponse<PatternListDto>>(
    `/patterns?${queryParams.toString()}`
  )

  return mapPaginatedResponse(response)
}

/**
 * GET /api/patterns/featured - Get all featured patterns
 */
export async function getFeaturedPatterns(): Promise<Pattern[]> {
  const patterns = await apiClient.get<PatternDetailDto[]>('/patterns/featured')
  return patterns.map(mapPatternDetailDto)
}

/**
 * GET /api/patterns/trending - Get all trending patterns
 */
export async function getTrendingPatterns(): Promise<Pattern[]> {
  const patterns = await apiClient.get<PatternDetailDto[]>('/patterns/trending')
  return patterns.map(mapPatternDetailDto)
}

/**
 * GET /api/patterns/{slug} - Get detailed information about a specific pattern
 */
export async function getPatternBySlug(slug: string): Promise<Pattern | null> {
  try {
    const pattern = await apiClient.get<PatternDetailDto>(`/patterns/${slug}`)
    return mapPatternDetailDto(pattern)
  } catch (error) {
    // Return null for 404 errors (pattern not found)
    if (error instanceof ApiError && error.statusCode === 404) {
      return null
    }
    throw error
  }
}

/**
 * POST /api/patterns/{id}/vote - Increment vote count for a pattern
 */
export async function voteForPattern(id: string): Promise<VoteResponse> {
  return await apiClient.post<VoteResponse>(`/patterns/${id}/vote`)
}

/**
 * POST /api/patterns - Create a new pattern (requires Editor role)
 */
export async function createPattern(
  data: {
    title: string
    shortDescription: string
    fullContent?: string
    category: PatternCategory
    tags: string[]
    author?: string
  },
  token?: string
): Promise<Pattern> {
  const dto: CreatePatternDto = {
    title: data.title,
    shortDescription: data.shortDescription,
    fullContent: data.fullContent,
    category: mapCategoryToApi(data.category),
    tags: data.tags,
    author: data.author,
  }
  const response = await apiClient.post<PatternDetailDto>('/patterns', dto, { token })
  return mapPatternDetailDto(response)
}

/**
 * PUT /api/patterns/{id} - Update an existing pattern (requires Editor role)
 */
export async function updatePattern(
  id: string,
  data: {
    title: string
    shortDescription: string
    fullContent?: string
    category: PatternCategory
    tags: string[]
    author?: string
    isFeatured: boolean
    isTrending: boolean
  },
  token?: string
): Promise<Pattern> {
  const dto: UpdatePatternDto = {
    title: data.title,
    shortDescription: data.shortDescription,
    fullContent: data.fullContent,
    category: mapCategoryToApi(data.category),
    tags: data.tags,
    author: data.author,
    isFeatured: data.isFeatured,
    isTrending: data.isTrending,
  }
  const response = await apiClient.put<PatternDetailDto>(`/patterns/${id}`, dto, { token })
  return mapPatternDetailDto(response)
}

/**
 * DELETE /api/patterns/{id} - Delete a pattern (requires Admin role)
 */
export async function deletePattern(id: string, token?: string): Promise<void> {
  await apiClient.delete(`/patterns/${id}`, { token })
}

// ============================================================================
// Helper Functions (client-side utilities)
// ============================================================================

/**
 * Extract unique categories from a patterns array
 */
export function getAllCategories(patterns: Pattern[]): PatternCategory[] {
  const categories = new Set<PatternCategory>()
  patterns.forEach((pattern) => categories.add(pattern.category))
  return Array.from(categories).sort()
}

/**
 * Extract unique tags from a patterns array
 */
export function getAllTags(patterns: Pattern[]): string[] {
  const tags = new Set<string>()
  patterns.forEach((pattern) => {
    pattern.tags.forEach((tag) => tags.add(tag))
  })
  return Array.from(tags).sort()
}

/**
 * Calculate statistics from patterns array
 */
export function getPatternStats(patterns: Pattern[]): {
  totalPatterns: number
  totalCategories: number
  totalContributors: string
} {
  const categories = getAllCategories(patterns)
  const authors = new Set<string>()

  patterns.forEach((pattern) => {
    if (pattern.author) {
      authors.add(pattern.author)
    }
  })

  return {
    totalPatterns: patterns.length,
    totalCategories: categories.length,
    totalContributors: authors.size > 0 ? `${authors.size}+` : '15+',
  }
}
