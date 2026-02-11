'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { useCallback } from 'react'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { X } from 'lucide-react'

type FilterPanelProps = {
  categories: string[]
  tags: string[]
}

export function FilterPanel({ categories, tags }: FilterPanelProps) {
  const router = useRouter()
  const searchParams = useSearchParams()

  const selectedCategory = searchParams.get('category') || 'all'
  const selectedTags =
    searchParams.get('tags')?.split(',').filter(Boolean) || []

  const hasActiveFilters = selectedCategory !== 'all' || selectedTags.length > 0

  const updateParams = useCallback((updates: Record<string, string | null>) => {
    const params = new URLSearchParams(searchParams.toString())

    Object.entries(updates).forEach(([key, value]) => {
      if (value === null || value === '') {
        params.delete(key)
      } else {
        params.set(key, value)
      }
    })

    // Reset to page 1 on filter change
    params.delete('page')

    router.push(`/patterns?${params.toString()}`)
  }, [searchParams, router])

  const handleCategoryChange = useCallback((category: string) => {
    updateParams({ category: category === 'all' ? null : category })
  }, [updateParams])

  const handleTagToggle = useCallback((tag: string) => {
    const newTags = selectedTags.includes(tag)
      ? selectedTags.filter((t) => t !== tag)
      : [...selectedTags, tag]

    updateParams({ tags: newTags.length > 0 ? newTags.join(',') : null })
  }, [selectedTags, updateParams])

  const handleClearFilters = () => {
    updateParams({ category: null, tags: null })
  }

  return (
    <aside className="w-64 space-y-6">
      {/* Header with clear button */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">Filters</h3>
        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={handleClearFilters}
            className="h-auto p-0 text-sm text-muted-foreground hover:text-foreground"
          >
            Clear all
          </Button>
        )}
      </div>

      {/* Category Filter */}
      <div className="space-y-3">
        <Label className="text-sm font-medium">Category</Label>
        <div className="space-y-2">
          <button
            onClick={() => handleCategoryChange('all')}
            aria-pressed={selectedCategory === 'all'}
            className={`block w-full text-left text-sm px-2 py-1 rounded transition-colors ${
              selectedCategory === 'all'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-muted'
            }`}
          >
            All Categories
          </button>
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => handleCategoryChange(category)}
              aria-pressed={selectedCategory === category}
              className={`block w-full text-left text-sm px-2 py-1 rounded transition-colors ${
                selectedCategory === category
                  ? 'bg-primary text-primary-foreground'
                  : 'hover:bg-muted'
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Tags Filter */}
      <div className="space-y-3">
        <Label className="text-sm font-medium">Tags</Label>
        <div className="space-y-2">
          {tags.map((tag) => (
            <div key={tag} className="flex items-center space-x-2">
              <Checkbox
                id={`tag-${tag}`}
                checked={selectedTags.includes(tag)}
                onCheckedChange={() => handleTagToggle(tag)}
              />
              <label
                htmlFor={`tag-${tag}`}
                className="text-sm cursor-pointer flex-1"
              >
                {tag}
              </label>
            </div>
          ))}
        </div>
      </div>

      {/* Active Filters Display */}
      {hasActiveFilters && (
        <div className="space-y-2 pt-4 border-t">
          <Label className="text-sm font-medium">Active Filters</Label>
          <div className="flex flex-wrap gap-2">
            {selectedCategory !== 'all' && (
              <Badge variant="secondary" className="gap-1">
                {selectedCategory}
                <button
                  onClick={() => handleCategoryChange('all')}
                  className="ml-1 hover:text-foreground"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {selectedTags.map((tag) => (
              <Badge key={tag} variant="secondary" className="gap-1">
                {tag}
                <button
                  onClick={() => handleTagToggle(tag)}
                  className="ml-1 hover:text-foreground"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            ))}
          </div>
        </div>
      )}
    </aside>
  )
}
