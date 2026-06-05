'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { ChevronDown } from 'lucide-react'
import type { SortOption } from '@/lib/types/pattern'

const DEFAULT_SORT_OPTIONS: { value: SortOption; label: string }[] = [
  { value: 'recent', label: 'Most Recent' },
  { value: 'votes', label: 'Most Voted' },
  { value: 'alphabetical', label: 'Alphabetical' },
]

type SortSelectorProps = {
  sortByLabel?: string
  sortOptions?: Array<{ value: string; label: string }>
}

/**
 * Sort dropdown for the patterns listing.
 *
 * Deliberately a native <select> rather than the Radix Select used elsewhere:
 * hydrating Radix Select (popper, focus scope, dismissable layer, portal)
 * cost ~260ms of mobile TBT on /patterns for a three-option dropdown — the
 * single largest main-thread contributor found in issue #72. The native
 * element needs no hydration work, is keyboard/screen-reader accessible out
 * of the box, and opens the platform picker on mobile.
 */
export function SortSelector({ sortByLabel = 'Sort by:', sortOptions }: SortSelectorProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const currentSort = (searchParams.get('sort') as SortOption) || 'recent'
  const effectiveSortOptions = sortOptions ?? DEFAULT_SORT_OPTIONS

  const handleSortChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const params = new URLSearchParams(searchParams.toString())
    params.set('sort', event.target.value)

    // Reset to page 1 on sort change
    params.delete('page')

    router.push(`/patterns?${params.toString()}`)
  }

  return (
    <div className="flex items-center gap-2">
      <label htmlFor="sort-select" className="text-sm text-muted-foreground whitespace-nowrap">
        {sortByLabel}
      </label>
      <div className="relative">
        <select
          id="sort-select"
          value={currentSort}
          onChange={handleSortChange}
          className="h-10 w-[180px] appearance-none rounded-md border border-input bg-background px-3 py-2 pr-8 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {effectiveSortOptions.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        <ChevronDown
          className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 opacity-50"
          aria-hidden="true"
        />
      </div>
    </div>
  )
}
