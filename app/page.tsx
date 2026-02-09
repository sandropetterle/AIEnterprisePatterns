import type { Metadata } from 'next'
import { Hero } from '@/components/home/Hero'
import { FeaturedPatterns } from '@/components/home/FeaturedPatterns'
import { StatsSection } from '@/components/home/StatsSection'
import { CTASection } from '@/components/home/CTASection'
import { getFeaturedPatterns, getPatternStats } from '@/lib/data/mockPatterns'

export const metadata: Metadata = {
  title: 'Home',
  description: 'Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',
}

export default function HomePage() {
  const featuredPatterns = getFeaturedPatterns()
  const stats = getPatternStats()

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
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
    </>
  )
}
