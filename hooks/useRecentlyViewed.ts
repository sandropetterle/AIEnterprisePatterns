'use client'

import { useState, useCallback, useEffect } from 'react'
import type { PatternCategory } from '@/lib/types/pattern'

const MAX_RECENT = 5
const STORAGE_KEY = 'recently-viewed-patterns'

export type RecentPattern = {
  slug: string
  title: string
  category: PatternCategory
  visitedAt: string // ISO date
}

type UseRecentlyViewedResult = {
  recentPatterns: RecentPattern[]
  addRecentPattern: (pattern: Omit<RecentPattern, 'visitedAt'>) => void
  clearRecentPatterns: () => void
}

function readFromStorage(): RecentPattern[] {
  if (typeof window === 'undefined') return []
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? (JSON.parse(raw) as RecentPattern[]) : []
  } catch {
    return []
  }
}

function writeToStorage(patterns: RecentPattern[]): void {
  if (typeof window === 'undefined') return
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(patterns))
  } catch {
    // ignore storage errors
  }
}

export function useRecentlyViewed(): UseRecentlyViewedResult {
  const [recentPatterns, setRecentPatterns] = useState<RecentPattern[]>([])

  // Hydrate from localStorage after mount
  useEffect(() => {
    setRecentPatterns(readFromStorage())
  }, [])

  const addRecentPattern = useCallback(
    (pattern: Omit<RecentPattern, 'visitedAt'>) => {
      setRecentPatterns((prev) => {
        // Deduplicate by slug, prepend, trim to max
        const filtered = prev.filter((p) => p.slug !== pattern.slug)
        const updated = [
          { ...pattern, visitedAt: new Date().toISOString() },
          ...filtered,
        ].slice(0, MAX_RECENT)
        writeToStorage(updated)
        return updated
      })
    },
    []
  )

  const clearRecentPatterns = useCallback(() => {
    setRecentPatterns([])
    writeToStorage([])
  }, [])

  return { recentPatterns, addRecentPattern, clearRecentPatterns }
}
