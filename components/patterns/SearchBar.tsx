'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Search, X } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { useTransition, useState, useEffect } from 'react'

export function SearchBar() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [isPending, startTransition] = useTransition()

  const [searchValue, setSearchValue] = useState(searchParams.get('q') || '')

  useEffect(() => {
    setSearchValue(searchParams.get('q') || '')
  }, [searchParams])

  const handleSearch = (value: string) => {
    const params = new URLSearchParams(searchParams.toString())

    if (value.trim()) {
      params.set('q', value.trim())
    } else {
      params.delete('q')
    }

    // Reset to page 1 on new search
    params.delete('page')

    startTransition(() => {
      router.push(`/patterns?${params.toString()}`)
    })
  }

  const handleClear = () => {
    setSearchValue('')
    handleSearch('')
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleSearch(searchValue)
    }
  }

  return (
    <div className="relative w-full">
      <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        type="text"
        placeholder="Search patterns..."
        value={searchValue}
        onChange={(e) => setSearchValue(e.target.value)}
        onKeyDown={handleKeyDown}
        className="pl-9 pr-9"
        disabled={isPending}
      />
      {searchValue && (
        <Button
          variant="ghost"
          size="icon"
          className="absolute right-1 top-1/2 h-7 w-7 -translate-y-1/2"
          onClick={handleClear}
        >
          <X className="h-4 w-4" />
          <span className="sr-only">Clear search</span>
        </Button>
      )}
    </div>
  )
}
