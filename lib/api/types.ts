/**
 * Backend DTO Types
 * TypeScript definitions matching C# DTOs from the backend API
 * These use backend conventions (PascalCase categories, lowercase status)
 */

/**
 * Pattern list DTO - excludes fullContent for performance
 * Matches: AIEnterprisePatterns.Api.DTOs.PatternListDto
 */
export type PatternListDto = {
  id: string
  title: string
  slug: string
  shortDescription: string
  category: string // Backend uses PascalCase: "DesignPatterns", "AIPrompts", etc.
  tags: string[]
  author: string | null
  createdDate: string // ISO 8601 format
  updatedDate: string // ISO 8601 format
  voteCount: number
  status: string // "draft" or "published" (lowercase)
  isFeatured: boolean
  isTrending: boolean
}

/**
 * Pattern detail DTO - includes fullContent
 * Matches: AIEnterprisePatterns.Api.DTOs.PatternDetailDto
 */
export type PatternDetailDto = {
  id: string
  title: string
  slug: string
  shortDescription: string
  fullContent: string | null
  category: string // Backend uses PascalCase: "DesignPatterns", "AIPrompts", etc.
  tags: string[]
  author: string | null
  createdDate: string // ISO 8601 format
  updatedDate: string // ISO 8601 format
  voteCount: number
  status: string // "draft" or "published" (lowercase)
  isFeatured: boolean
  isTrending: boolean
}

/**
 * Paginated response wrapper
 * Matches: AIEnterprisePatterns.Api.DTOs.PaginatedResponse<T>
 */
export type PaginatedResponse<T> = {
  patterns: T[]
  totalCount: number
  currentPage: number
  pageSize: number
  totalPages: number
}

/**
 * Vote response
 * Matches: AIEnterprisePatterns.Api.DTOs.VoteResponse
 */
export type VoteResponse = {
  patternId: string
  voteCount: number
}

/**
 * Create pattern DTO
 * Matches: AIEnterprisePatterns.Api.DTOs.CreatePatternDto
 */
export type CreatePatternDto = {
  title: string
  shortDescription: string
  fullContent?: string
  category: string // Backend PascalCase format
  tags: string[]
  author?: string
}

/**
 * Update pattern DTO
 * Matches: AIEnterprisePatterns.Api.DTOs.UpdatePatternDto
 */
export type UpdatePatternDto = {
  title: string
  shortDescription: string
  fullContent?: string
  category: string // Backend PascalCase format
  tags: string[]
  author?: string
  isFeatured: boolean
  isTrending: boolean
}
