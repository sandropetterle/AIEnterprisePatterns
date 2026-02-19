'use client'

import { useState } from 'react'
import { useSearchParams } from 'next/navigation'
import { useSavedSearches } from '@/hooks/useSavedSearches'
import type { SavedSearchParams } from '@/hooks/useSavedSearches'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Bookmark, X, Trash2 } from 'lucide-react'

export function SavedSearches() {
  const searchParams = useSearchParams()
  const { savedSearches, saveSearch, deleteSearch, applySavedSearch } = useSavedSearches()
  const [dialogOpen, setDialogOpen] = useState(false)
  const [searchName, setSearchName] = useState('')

  // Build current search params object
  const currentParams: SavedSearchParams = {
    q: searchParams.get('q') || undefined,
    category: searchParams.get('category') || undefined,
    tags: searchParams.get('tags')?.split(',').filter(Boolean) || undefined,
    sort: searchParams.get('sort') || undefined,
    dateFrom: searchParams.get('dateFrom') || undefined,
    dateTo: searchParams.get('dateTo') || undefined,
    tagMode: searchParams.get('tagMode') || undefined,
  }

  const hasActiveFilters = !!(
    currentParams.q ||
    currentParams.category ||
    currentParams.tags?.length ||
    currentParams.dateFrom ||
    currentParams.dateTo
  )

  const handleSave = () => {
    if (!searchName.trim()) return
    saveSearch(searchName.trim(), currentParams)
    setSearchName('')
    setDialogOpen(false)
  }

  if (!hasActiveFilters && savedSearches.length === 0) return null

  return (
    <div className="space-y-3 pt-4 border-t">
      <div className="flex items-center justify-between">
        <Label className="text-sm font-medium flex items-center gap-1.5">
          <Bookmark className="h-3.5 w-3.5" />
          Saved Searches
        </Label>
        {hasActiveFilters && (
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button
                variant="ghost"
                size="sm"
                className="h-auto p-0 text-xs text-muted-foreground hover:text-foreground"
              >
                Save current
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-sm">
              <DialogHeader>
                <DialogTitle>Save Search</DialogTitle>
                <DialogDescription>
                  Give this search a name to quickly recall it later.
                </DialogDescription>
              </DialogHeader>
              <div className="py-2">
                <Label htmlFor="search-name" className="text-sm">
                  Search name
                </Label>
                <Input
                  id="search-name"
                  value={searchName}
                  onChange={(e) => setSearchName(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSave()}
                  placeholder="e.g. Architecture with CQRS"
                  className="mt-1.5"
                  autoFocus
                />
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setDialogOpen(false)}>
                  Cancel
                </Button>
                <Button onClick={handleSave} disabled={!searchName.trim()}>
                  Save
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {savedSearches.length > 0 && (
        <ul className="space-y-1.5" aria-label="Saved searches">
          {savedSearches.map((search) => (
            <li key={search.id} className="flex items-center gap-1">
              <button
                onClick={() => applySavedSearch(search)}
                className="flex-1 text-left text-sm truncate hover:text-primary transition-colors"
                title={search.name}
              >
                {search.name}
              </button>
              <Button
                variant="ghost"
                size="sm"
                className="h-6 w-6 p-0 flex-shrink-0"
                onClick={() => deleteSearch(search.id)}
                aria-label={`Delete saved search: ${search.name}`}
              >
                <Trash2 className="h-3 w-3" />
              </Button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
