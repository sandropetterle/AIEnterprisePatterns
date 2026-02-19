'use client'

import { useEffect } from 'react'
import { useRecentlyViewed } from '@/hooks/useRecentlyViewed'
import type { PatternCategory } from '@/lib/types/pattern'

type RecentlyViewedTrackerProps = {
  slug: string
  title: string
  category: PatternCategory
}

export function RecentlyViewedTracker({ slug, title, category }: RecentlyViewedTrackerProps) {
  const { addRecentPattern } = useRecentlyViewed()

  useEffect(() => {
    addRecentPattern({ slug, title, category })
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slug]) // Only re-run when slug changes, not on every render

  return null
}
