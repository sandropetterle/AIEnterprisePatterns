import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import { Pattern } from '@/lib/types/pattern'
import { PatternCard } from './PatternCard'

type FeaturedPatternsProps = {
  patterns: Pattern[]
  heading?: string
  subheading?: string
  viewAllLabel?: string
  mobileViewAllLabel?: string
}

export function FeaturedPatterns({
  patterns,
  heading = 'Featured Patterns',
  subheading = 'Top-rated patterns curated by the community',
  viewAllLabel = 'View All',
  mobileViewAllLabel = 'View All Patterns',
}: FeaturedPatternsProps) {
  return (
    <section id="featured" className="py-16 sm:py-20 lg:py-24 bg-muted/50 animate-fade-in">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">{heading}</h2>
            <p className="mt-2 text-muted-foreground">{subheading}</p>
          </div>
          <Link
            href="/patterns"
            className="hidden sm:flex items-center gap-2 text-sm font-medium text-primary hover:underline"
          >
            {viewAllLabel}
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {patterns.map((pattern) => (
            <PatternCard key={pattern.id} pattern={pattern} />
          ))}
        </div>
        <div className="mt-8 text-center sm:hidden">
          <Link
            href="/patterns"
            className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:underline"
          >
            {mobileViewAllLabel}
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </div>
    </section>
  )
}
