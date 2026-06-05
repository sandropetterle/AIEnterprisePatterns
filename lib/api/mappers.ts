/**
 * Data Transformation Layer
 * Bidirectional mapping between backend DTOs and frontend types
 */

import type { Pattern, PatternListItem, PatternCategory, SortOption } from '@/lib/types/pattern'
import type { PatternListDto, PatternDetailDto, PaginatedResponse } from './types'

/**
 * Category mapping: API (PascalCase) → UI (spaced)
 */
const CATEGORY_API_TO_UI: Record<string, PatternCategory> = {
  Architecture: 'Architecture',
  DesignPatterns: 'Design Patterns',
  AIPrompts: 'AI Prompts',
  BestPractices: 'Best Practices',
  CodeGeneration: 'Code Generation',
  Testing: 'Testing',
  Security: 'Security',
  Performance: 'Performance',
}

/**
 * Category mapping: UI (spaced) → API (PascalCase)
 */
const CATEGORY_UI_TO_API: Record<PatternCategory, string> = {
  Architecture: 'Architecture',
  'Design Patterns': 'DesignPatterns',
  'AI Prompts': 'AIPrompts',
  'Best Practices': 'BestPractices',
  'Code Generation': 'CodeGeneration',
  Testing: 'Testing',
  Security: 'Security',
  Performance: 'Performance',
}

/**
 * Maps category from API format to UI format
 */
export function mapCategoryFromApi(apiCategory: string): PatternCategory {
  const mapped = CATEGORY_API_TO_UI[apiCategory]
  if (!mapped) {
    console.warn(`Unknown API category: ${apiCategory}, defaulting to Architecture`)
    return 'Architecture'
  }
  return mapped
}

/**
 * Maps category from UI format to API format
 */
export function mapCategoryToApi(uiCategory: PatternCategory): string {
  const mapped = CATEGORY_UI_TO_API[uiCategory]
  if (!mapped) {
    console.warn(`Unknown UI category: ${uiCategory}, defaulting to Architecture`)
    return 'Architecture'
  }
  return mapped
}

/**
 * Sort normalization: URL/CMS sort values → API SortOption contract
 * Canonical values pass through; CMS-fallback labels map to their API
 * equivalent (issue #76); anything else falls back to the default sort
 * instead of being forwarded to the backend (issue #77).
 */
const SORT_VALUE_TO_API: Record<string, SortOption> = {
  recent: 'recent',
  votes: 'votes',
  alphabetical: 'alphabetical',
  newest: 'recent',
  popular: 'votes',
  title: 'alphabetical',
}

/**
 * Normalizes an untrusted sort value (URL param, CMS label) to a valid SortOption
 */
export function normalizeSortOption(value: string | undefined): SortOption {
  if (!value) {
    return 'recent'
  }
  const mapped = SORT_VALUE_TO_API[value]
  if (!mapped) {
    console.warn(`Unknown sort option: ${value}, defaulting to recent`)
    return 'recent'
  }
  return mapped
}

/**
 * Maps backend PatternListDto to frontend PatternListItem
 */
export function mapPatternListDto(dto: PatternListDto): PatternListItem {
  return {
    id: dto.id,
    title: dto.title,
    slug: dto.slug,
    shortDescription: dto.shortDescription,
    category: mapCategoryFromApi(dto.category),
    tags: dto.tags,
    author: dto.author ?? undefined,
    createdDate: dto.createdDate,
    updatedDate: dto.updatedDate,
    voteCount: dto.voteCount,
    status: dto.status as 'draft' | 'published',
    isFeatured: dto.isFeatured,
    isTrending: dto.isTrending,
  }
}

/**
 * Maps backend PatternDetailDto to frontend Pattern
 */
export function mapPatternDetailDto(dto: PatternDetailDto): Pattern {
  return {
    id: dto.id,
    title: dto.title,
    slug: dto.slug,
    shortDescription: dto.shortDescription,
    fullContent: dto.fullContent ?? undefined,
    category: mapCategoryFromApi(dto.category),
    tags: dto.tags,
    author: dto.author ?? undefined,
    createdDate: dto.createdDate,
    updatedDate: dto.updatedDate,
    voteCount: dto.voteCount,
    status: dto.status as 'draft' | 'published',
    isFeatured: dto.isFeatured,
    isTrending: dto.isTrending,
  }
}

/**
 * Maps backend PaginatedResponse to frontend format
 * Adds hasNextPage and hasPreviousPage for convenience
 */
export function mapPaginatedResponse(
  response: PaginatedResponse<PatternListDto>
): {
  patterns: PatternListItem[]
  totalCount: number
  currentPage: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
} {
  return {
    patterns: response.patterns.map(mapPatternListDto),
    totalCount: response.totalCount,
    currentPage: response.currentPage,
    totalPages: response.totalPages,
    hasNextPage: response.currentPage < response.totalPages,
    hasPreviousPage: response.currentPage > 1,
  }
}
