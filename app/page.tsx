import type { Metadata } from 'next'
import { Hero } from '@/components/home/Hero'
import { FeaturedPatterns } from '@/components/home/FeaturedPatterns'
import { StatsSection } from '@/components/home/StatsSection'
import { CTASection } from '@/components/home/CTASection'
import { getFeaturedPatterns, getPatterns, getPatternStats } from '@/lib/api/patterns'
import { JsonLd } from '@/components/shared/JsonLd'

export const metadata: Metadata = {
  title: 'Home',
  description: 'Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',
}

// Revalidate every 5 minutes
export const revalidate = 300

export default async function HomePage() {
  // Fetch featured patterns and all patterns for stats
  // Handle API unavailable during build (e.g., Docker build)
  let featuredPatterns: Awaited<ReturnType<typeof getFeaturedPatterns>> = []
  let stats = { totalPatterns: 0, totalVotes: 0, mostPopularCategory: 'Architecture' as const }

  try {
    featuredPatterns = await getFeaturedPatterns()
    const allPatterns = await getPatterns({ pageSize: 100 })
    stats = getPatternStats(allPatterns.patterns)
  } catch (error) {
    console.warn('Failed to fetch patterns for home page build:', error)
    // Will show empty state, page will be generated on-demand
  }

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'AI Enterprise Patterns Library',
    description: 'A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.',
    url: 'https://ai-patterns.example.com',
    potentialAction: {
      '@type': 'SearchAction',
      target: 'https://ai-patterns.example.com/patterns?q={search_term_string}',
      'query-input': 'required name=search_term_string',
    },
  }

  return (
    <>
      <Hero />
      <FeaturedPatterns patterns={featuredPatterns} />
      <StatsSection {...stats} />
      <CTASection />
      <JsonLd data={jsonLd} />
    </>
  )
}
