import { Pattern } from '@/lib/types/pattern'

export type SortOption = 'recent' | 'votes' | 'alphabetical'

export type FilterOptions = {
  searchQuery?: string
  category?: string
  tags?: string[]
  sortBy?: SortOption
  page?: number
  pageSize?: number
}

export type PaginatedResult = {
  patterns: Pattern[]
  totalCount: number
  currentPage: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

/**
 * Filters patterns based on search query (title + description)
 */
export function filterBySearch(patterns: Pattern[], query: string): Pattern[] {
  if (!query || query.trim() === '') return patterns

  const lowerQuery = query.toLowerCase().trim()
  return patterns.filter(
    (p) =>
      p.title.toLowerCase().includes(lowerQuery) ||
      p.shortDescription.toLowerCase().includes(lowerQuery)
  )
}

/**
 * Filters patterns by category
 */
export function filterByCategory(
  patterns: Pattern[],
  category?: string
): Pattern[] {
  if (!category || category === 'all') return patterns
  return patterns.filter((p) => p.category === category)
}

/**
 * Filters patterns by tags (OR logic - matches any tag)
 */
export function filterByTags(patterns: Pattern[], tags?: string[]): Pattern[] {
  if (!tags || tags.length === 0) return patterns
  return patterns.filter((p) => p.tags.some((tag) => tags.includes(tag)))
}

/**
 * Sorts patterns based on sort option
 */
export function sortPatterns(
  patterns: Pattern[],
  sortBy: SortOption
): Pattern[] {
  const sorted = [...patterns]

  switch (sortBy) {
    case 'recent':
      return sorted.sort(
        (a, b) =>
          new Date(b.createdDate).getTime() - new Date(a.createdDate).getTime()
      )
    case 'votes':
      return sorted.sort((a, b) => b.voteCount - a.voteCount)
    case 'alphabetical':
      return sorted.sort((a, b) => a.title.localeCompare(b.title))
    default:
      return sorted
  }
}

/**
 * Paginates an array of patterns
 */
export function paginatePatterns(
  patterns: Pattern[],
  page: number = 1,
  pageSize: number = 9
): PaginatedResult {
  const totalCount = patterns.length
  const totalPages = Math.ceil(totalCount / pageSize) || 1
  const currentPage = Math.max(1, Math.min(page, totalPages))

  const startIndex = (currentPage - 1) * pageSize
  const endIndex = startIndex + pageSize
  const paginatedPatterns = patterns.slice(startIndex, endIndex)

  return {
    patterns: paginatedPatterns,
    totalCount,
    currentPage,
    totalPages,
    hasNextPage: currentPage < totalPages,
    hasPreviousPage: currentPage > 1,
  }
}

/**
 * Main function to filter, sort, and paginate patterns
 */
export function filterAndSortPatterns(
  allPatterns: Pattern[],
  options: FilterOptions = {}
): PaginatedResult {
  const {
    searchQuery,
    category,
    tags,
    sortBy = 'recent',
    page = 1,
    pageSize = 9,
  } = options

  // Only include published patterns
  let filtered = allPatterns.filter((p) => p.status === 'published')

  // Apply filters
  filtered = filterBySearch(filtered, searchQuery || '')
  filtered = filterByCategory(filtered, category)
  filtered = filterByTags(filtered, tags)

  // Sort
  const sorted = sortPatterns(filtered, sortBy)

  // Paginate
  return paginatePatterns(sorted, page, pageSize)
}

/**
 * Gets all unique tags from patterns
 */
export function getAllTags(patterns: Pattern[]): string[] {
  const tagSet = new Set<string>()
  patterns.forEach((p) => {
    p.tags.forEach((tag) => tagSet.add(tag))
  })
  return Array.from(tagSet).sort()
}

/**
 * Gets all unique categories from patterns
 */
export function getAllCategories(patterns: Pattern[]): string[] {
  const categorySet = new Set<string>()
  patterns.forEach((p) => categorySet.add(p.category))
  return Array.from(categorySet).sort()
}
