'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import type { SortOption } from '@/lib/types/pattern'

const sortOptions: { value: SortOption; label: string }[] = [
  { value: 'recent', label: 'Most Recent' },
  { value: 'votes', label: 'Most Voted' },
  { value: 'alphabetical', label: 'Alphabetical' },
]

export function SortSelector() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const currentSort = (searchParams.get('sort') as SortOption) || 'recent'

  const handleSortChange = (value: SortOption) => {
    const params = new URLSearchParams(searchParams.toString())
    params.set('sort', value)

    // Reset to page 1 on sort change
    params.delete('page')

    router.push(`/patterns?${params.toString()}`)
  }

  return (
    <div className="flex items-center gap-2">
      <label htmlFor="sort-select" className="text-sm text-muted-foreground whitespace-nowrap">
        Sort by:
      </label>
      <Select value={currentSort} onValueChange={handleSortChange}>
        <SelectTrigger id="sort-select" className="w-[180px]">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          {sortOptions.map((option) => (
            <SelectItem key={option.value} value={option.value}>
              {option.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}
