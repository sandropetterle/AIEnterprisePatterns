import { describe, it, expect } from '@jest/globals'
import { getRelatedPatterns } from '../relatedPatterns'
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

describe('getRelatedPatterns', () => {
  const current = makePattern({ id: '1', category: 'Architecture', tags: ['react', 'node'], voteCount: 5 })

  const sameCategory = makePattern({ id: '2', category: 'Architecture', tags: ['typescript'], voteCount: 20 })
  const sameCategoryHighVotes = makePattern({ id: '3', category: 'Architecture', tags: ['docker'], voteCount: 50 })
  const diffCategorySameTag = makePattern({ id: '4', category: 'Design Patterns', tags: ['react'], voteCount: 30 })
  const unrelated = makePattern({ id: '5', category: 'Security', tags: ['python'], voteCount: 100 })
  const draft = makePattern({ id: '6', category: 'Architecture', tags: ['react'], voteCount: 999, status: 'draft' })

  const allPatterns = [current, sameCategory, sameCategoryHighVotes, diffCategorySameTag, unrelated, draft]

  it('excludes the current pattern', () => {
    const result = getRelatedPatterns(current, allPatterns)
    expect(result.every((p) => p.id !== current.id)).toBe(true)
  })

  it('excludes draft patterns', () => {
    const result = getRelatedPatterns(current, allPatterns)
    expect(result.every((p) => p.status === 'published')).toBe(true)
  })

  it('prefers same-category patterns', () => {
    const result = getRelatedPatterns(current, allPatterns, 3)
    const ids = result.map((p) => p.id)
    expect(ids).toContain('2')
    expect(ids).toContain('3')
  })

  it('returns up to limit patterns', () => {
    const result = getRelatedPatterns(current, allPatterns, 2)
    expect(result).toHaveLength(2)
  })

  it('falls back to tag-based matches when same-category < limit', () => {
    const smallPool = makePattern({ id: '7', category: 'Performance', tags: ['react', 'node'], voteCount: 10 })
    const otherTagMatch = makePattern({ id: '8', category: 'Testing', tags: ['react'], voteCount: 5 })
    const lonelyPattern = makePattern({ id: '9', category: 'Performance', tags: [], voteCount: 0 })

    const result = getRelatedPatterns(smallPool, [smallPool, otherTagMatch, lonelyPattern, current], 3)
    // same-category: none (only smallPool itself, excluded)
    // tag matches: current (has 'react','node'), otherTagMatch (has 'react')
    const ids = result.map((p) => p.id)
    expect(ids).toContain(current.id)
    expect(ids).toContain(otherTagMatch.id)
  })

  it('sorts results by votes descending', () => {
    const result = getRelatedPatterns(current, allPatterns, 2)
    // sameCategoryHighVotes (50) > sameCategory (20)
    expect(result[0].id).toBe('3')
    expect(result[1].id).toBe('2')
  })

  it('returns empty array when no other published patterns exist', () => {
    const result = getRelatedPatterns(current, [current])
    expect(result).toHaveLength(0)
  })

  it('uses default limit of 3', () => {
    const manyPatterns = Array.from({ length: 10 }, (_, i) =>
      makePattern({ id: String(i + 10), category: 'Architecture', voteCount: i })
    )
    const result = getRelatedPatterns(current, [current, ...manyPatterns])
    expect(result).toHaveLength(3)
  })

  it('does not include tag-based duplicates already in same-category results', () => {
    const overlap = makePattern({ id: '10', category: 'Architecture', tags: ['react'], voteCount: 5 })
    const result = getRelatedPatterns(current, [current, overlap])
    const ids = result.map((p) => p.id)
    // overlap should appear once only
    expect(ids.filter((id) => id === '10')).toHaveLength(1)
  })
})
