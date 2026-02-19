import { renderHook, act } from '@testing-library/react'
import { useSearchSuggestions } from '../useSearchSuggestions'
import type { PatternListItem } from '@/lib/types/pattern'

const mockPatterns: PatternListItem[] = [
  {
    id: '1', title: 'Clean Architecture Guide', slug: 'clean-arch',
    shortDescription: 'desc', category: 'Architecture', tags: ['CQRS', 'DDD'],
    createdDate: '', updatedDate: '', voteCount: 0, status: 'published',
  },
  {
    id: '2', title: 'CQRS Pattern', slug: 'cqrs',
    shortDescription: 'desc', category: 'Design Patterns', tags: ['CQRS', 'Events'],
    createdDate: '', updatedDate: '', voteCount: 0, status: 'published',
  },
  {
    id: '3', title: 'Security Best Practices', slug: 'security',
    shortDescription: 'desc', category: 'Security', tags: ['OAuth', 'JWT'],
    createdDate: '', updatedDate: '', voteCount: 0, status: 'published',
  },
]

const allTags = ['CQRS', 'DDD', 'Events', 'OAuth', 'JWT', 'Testing']

jest.useFakeTimers()

describe('useSearchSuggestions', () => {
  it('returns empty array when query is too short', () => {
    const { result } = renderHook(() =>
      useSearchSuggestions('c', mockPatterns, allTags)
    )
    expect(result.current.suggestions).toEqual([])
  })

  it('returns empty array for empty query', () => {
    const { result } = renderHook(() =>
      useSearchSuggestions('', mockPatterns, allTags)
    )
    expect(result.current.suggestions).toEqual([])
  })

  it('filters pattern titles matching query after debounce', () => {
    const { result } = renderHook(() =>
      useSearchSuggestions('cqrs', mockPatterns, allTags)
    )
    act(() => {
      jest.advanceTimersByTime(200)
    })
    expect(result.current.suggestions).toContain('CQRS Pattern')
  })

  it('includes tag matches in suggestions', () => {
    const { result } = renderHook(() =>
      useSearchSuggestions('oau', mockPatterns, allTags)
    )
    act(() => {
      jest.advanceTimersByTime(200)
    })
    expect(result.current.suggestions).toContain('OAuth')
  })

  it('deduplicates results (title matches not repeated in tags)', () => {
    // "CQRS Pattern" is a title; "CQRS" is also a tag
    const { result } = renderHook(() =>
      useSearchSuggestions('CQRS', mockPatterns, allTags)
    )
    act(() => {
      jest.advanceTimersByTime(200)
    })
    const seen = new Set(result.current.suggestions)
    expect(seen.size).toBe(result.current.suggestions.length)
  })

  it('limits suggestions to 8', () => {
    const manyPatterns: PatternListItem[] = Array.from({ length: 20 }, (_, i) => ({
      id: String(i), title: `Pattern ${i} test`, slug: `pattern-${i}`,
      shortDescription: '', category: 'Architecture', tags: [],
      createdDate: '', updatedDate: '', voteCount: 0, status: 'published' as const,
    }))
    const { result } = renderHook(() =>
      useSearchSuggestions('test', manyPatterns, [])
    )
    act(() => {
      jest.advanceTimersByTime(200)
    })
    expect(result.current.suggestions.length).toBeLessThanOrEqual(8)
  })

  it('is not loading after debounce resolves', () => {
    const { result } = renderHook(() =>
      useSearchSuggestions('clean', mockPatterns, allTags)
    )
    // Initially loading
    expect(result.current.isLoading).toBe(true)
    act(() => {
      jest.advanceTimersByTime(200)
    })
    expect(result.current.isLoading).toBe(false)
  })

  it('prioritises title matches over tag matches', () => {
    // "CQRS Pattern" is a title match; "CQRS" is a tag match
    const { result } = renderHook(() =>
      useSearchSuggestions('cqrs', mockPatterns, allTags)
    )
    act(() => {
      jest.advanceTimersByTime(200)
    })
    const idx = result.current.suggestions.indexOf('CQRS Pattern')
    const tagIdx = result.current.suggestions.indexOf('CQRS')
    if (idx >= 0 && tagIdx >= 0) {
      expect(idx).toBeLessThan(tagIdx)
    }
  })
})
