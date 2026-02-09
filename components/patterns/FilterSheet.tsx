'use client'

import { Filter } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet'
import { FilterPanel } from './FilterPanel'

type FilterSheetProps = {
  categories: string[]
  tags: string[]
}

export function FilterSheet({ categories, tags }: FilterSheetProps) {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="outline" size="sm" className="gap-2">
          <Filter className="h-4 w-4" />
          Filters
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-80 overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Filter Patterns</SheetTitle>
          <SheetDescription>
            Refine your search by category and tags
          </SheetDescription>
        </SheetHeader>
        <div className="mt-6">
          <FilterPanel categories={categories} tags={tags} />
        </div>
      </SheetContent>
    </Sheet>
  )
}
