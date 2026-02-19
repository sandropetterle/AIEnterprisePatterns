import { renderHook, act } from '@testing-library/react'
import { useRecentlyViewed } from '../useRecentlyViewed'

const STORAGE_KEY = 'recently-viewed-patterns'

const pattern1 = { slug: 'pattern-1', title: 'Pattern One', category: 'Architecture' as const }
const pattern2 = { slug: 'pattern-2', title: 'Pattern Two', category: 'Security' as const }
const pattern3 = { slug: 'pattern-3', title: 'Pattern Three', category: 'Design Patterns' as const }
const pattern4 = { slug: 'pattern-4', title: 'Pattern Four', category: 'Architecture' as const }
const pattern5 = { slug: 'pattern-5', title: 'Pattern Five', category: 'Performance' as const }
const pattern6 = { slug: 'pattern-6', title: 'Pattern Six', category: 'Security' as const }

beforeEach(() => {
  localStorage.clear()
})

describe('useRecentlyViewed', () => {
  it('starts with empty list', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    expect(result.current.recentPatterns).toEqual([])
  })

  it('adds a pattern to the list', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
    })
    expect(result.current.recentPatterns).toHaveLength(1)
    expect(result.current.recentPatterns[0].slug).toBe('pattern-1')
  })

  it('prepends new patterns (most recent first)', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
      result.current.addRecentPattern(pattern2)
    })
    expect(result.current.recentPatterns[0].slug).toBe('pattern-2')
    expect(result.current.recentPatterns[1].slug).toBe('pattern-1')
  })

  it('deduplicates by slug (moves to front)', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
      result.current.addRecentPattern(pattern2)
      result.current.addRecentPattern(pattern1) // revisit pattern1
    })
    expect(result.current.recentPatterns[0].slug).toBe('pattern-1')
    expect(result.current.recentPatterns).toHaveLength(2)
  })

  it('trims to max 5 entries', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
      result.current.addRecentPattern(pattern2)
      result.current.addRecentPattern(pattern3)
      result.current.addRecentPattern(pattern4)
      result.current.addRecentPattern(pattern5)
      result.current.addRecentPattern(pattern6) // 6th — should drop oldest
    })
    expect(result.current.recentPatterns).toHaveLength(5)
    expect(result.current.recentPatterns[0].slug).toBe('pattern-6')
    // pattern-1 was the oldest and should be dropped
    expect(result.current.recentPatterns.map((p) => p.slug)).not.toContain('pattern-1')
  })

  it('persists to localStorage', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
    })
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]')
    expect(stored).toHaveLength(1)
    expect(stored[0].slug).toBe('pattern-1')
  })

  it('clears all patterns', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
      result.current.addRecentPattern(pattern2)
    })
    act(() => {
      result.current.clearRecentPatterns()
    })
    expect(result.current.recentPatterns).toEqual([])
    expect(localStorage.getItem(STORAGE_KEY)).toBe('[]')
  })

  it('attaches visitedAt ISO timestamp', () => {
    const { result } = renderHook(() => useRecentlyViewed())
    act(() => {
      result.current.addRecentPattern(pattern1)
    })
    const { visitedAt } = result.current.recentPatterns[0]
    expect(visitedAt).toBeTruthy()
    expect(() => new Date(visitedAt)).not.toThrow()
  })
})
