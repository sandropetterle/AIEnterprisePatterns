import { Pattern } from '@/lib/types/pattern'
import { filterByCategory, sortPatterns } from './filterAndSort'

export function getRelatedPatterns(
  currentPattern: Pattern,
  allPatterns: Pattern[],
  limit: number = 3
): Pattern[] {
  // Exclude current pattern
  const otherPatterns = allPatterns.filter(
    (p) => p.id !== currentPattern.id && p.status === 'published'
  )

  // Primary: Same category
  let related = filterByCategory(otherPatterns, currentPattern.category)

  // Fallback: If < limit, add tag-based matches
  if (related.length < limit) {
    const tagMatches = otherPatterns.filter(
      (p) =>
        p.tags.some((tag) => currentPattern.tags.includes(tag)) &&
        !related.some((r) => r.id === p.id)
    )
    related = [...related, ...tagMatches]
  }

  // Sort by votes and limit
  return sortPatterns(related, 'votes').slice(0, limit)
}
