'use client'

import { useMemo, useState, useEffect } from 'react'
import type { PatternListItem } from '@/lib/types/pattern'

const MAX_SUGGESTIONS = 8
const MIN_QUERY_LENGTH = 2
const DEBOUNCE_MS = 200

type UseSearchSuggestionsResult = {
  suggestions: string[]
  isLoading: boolean
}

export function useSearchSuggestions(
  query: string,
  allPatterns: PatternListItem[],
  allTags: string[]
): UseSearchSuggestionsResult {
  const [debouncedQuery, setDebouncedQuery] = useState(query)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (query.length < MIN_QUERY_LENGTH) {
      setDebouncedQuery('')
      setIsLoading(false)
      return
    }

    setIsLoading(true)
    const timer = setTimeout(() => {
      setDebouncedQuery(query)
      setIsLoading(false)
    }, DEBOUNCE_MS)

    return () => clearTimeout(timer)
  }, [query])

  const suggestions = useMemo(() => {
    if (debouncedQuery.length < MIN_QUERY_LENGTH) return []

    const q = debouncedQuery.toLowerCase()

    // Title matches (higher priority)
    const titleMatches = allPatterns
      .map((p) => p.title)
      .filter((title) => title.toLowerCase().includes(q))

    // Tag matches (lower priority)
    const tagMatches = allTags.filter(
      (tag) => tag.toLowerCase().includes(q) && !titleMatches.includes(tag)
    )

    // Deduplicate and limit
    const combined = [...new Set([...titleMatches, ...tagMatches])]
    return combined.slice(0, MAX_SUGGESTIONS)
  }, [debouncedQuery, allPatterns, allTags])

  return { suggestions, isLoading }
}
