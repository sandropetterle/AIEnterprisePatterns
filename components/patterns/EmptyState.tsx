import { Search } from 'lucide-react'
import { Button } from '@/components/ui/button'
import Link from 'next/link'

type EmptyStateProps = {
  hasFilters: boolean
}

export function EmptyState({ hasFilters }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      <div className="rounded-full bg-muted p-6 mb-4">
        <Search className="h-12 w-12 text-muted-foreground" />
      </div>
      <h3 className="text-2xl font-semibold mb-2">
        {hasFilters ? 'No patterns found' : 'No patterns available'}
      </h3>
      <p className="text-muted-foreground mb-6 max-w-md">
        {hasFilters
          ? "Try adjusting your filters or search query to find what you're looking for."
          : 'There are no patterns in the library yet. Check back soon!'}
      </p>
      {hasFilters && (
        <Button asChild variant="default">
          <Link href="/patterns">Clear all filters</Link>
        </Button>
      )}
    </div>
  )
}
