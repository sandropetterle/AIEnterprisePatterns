'use client'

import { useSyncExternalStore } from 'react'
import { FilterPanel } from './FilterPanel'
import type { CmsPatternListingLabels } from '@/lib/cms/types'

// Tailwind `lg` breakpoint — must match the parent's `hidden lg:block` wrapper.
const DESKTOP_MEDIA_QUERY = '(min-width: 1024px)'

function subscribe(onStoreChange: () => void): () => void {
  const mediaQuery = window.matchMedia(DESKTOP_MEDIA_QUERY)
  mediaQuery.addEventListener('change', onStoreChange)
  return () => mediaQuery.removeEventListener('change', onStoreChange)
}

function getSnapshot(): 'desktop' | 'mobile' {
  return window.matchMedia(DESKTOP_MEDIA_QUERY).matches ? 'desktop' : 'mobile'
}

// Server render (and the hydration pass that must match it) cannot know the
// viewport, so it renders the layout-stable placeholder below.
function getServerSnapshot(): 'unknown' {
  return 'unknown'
}

type DesktopFilterPanelProps = {
  categories: string[]
  tags: string[]
  labels?: CmsPatternListingLabels
}

/**
 * Mounts FilterPanel only when the viewport is at the lg breakpoint.
 *
 * The desktop filter rail is CSS-hidden on mobile (`hidden lg:block`), but a
 * CSS-hidden client component still hydrates — the rail's 18 Radix checkboxes,
 * SavedSearches dialog, and date-range filter cost ~120ms of mobile TBT for UI
 * a phone user can never see (issue #72). Gating the mount on matchMedia skips
 * that hydration entirely on mobile; on desktop the panel mounts in the render
 * right after hydration, which is also the earliest moment it could become
 * interactive before this change (see the data-hydrated e2e contract in
 * FilterPanel). The animate-pulse placeholder preserves the rail's footprint
 * during SSR/hydration, so desktop sees no layout shift.
 */
export function DesktopFilterPanel(props: DesktopFilterPanelProps) {
  const viewport = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)

  if (viewport === 'unknown') {
    // Placeholder is CSS-hidden on mobile by the parent wrapper, so only
    // desktop ever paints it — and only for the instant before hydration.
    return <div className="w-64 h-96 bg-muted animate-pulse rounded" aria-hidden="true" />
  }

  return viewport === 'desktop' ? <FilterPanel {...props} /> : null
}
