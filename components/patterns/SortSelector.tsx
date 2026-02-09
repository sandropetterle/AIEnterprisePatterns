'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { SortOption } from '@/lib/data/filterAndSort'

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
      <span className="text-sm text-muted-foreground whitespace-nowrap">
        Sort by:
      </span>
      <Select value={currentSort} onValueChange={handleSortChange}>
        <SelectTrigger className="w-[180px]">
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
