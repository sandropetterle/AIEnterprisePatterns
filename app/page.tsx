import type { Metadata } from 'next'
import { Hero } from '@/components/home/Hero'
import { FeaturedPatterns } from '@/components/home/FeaturedPatterns'
import { StatsSection } from '@/components/home/StatsSection'
import { CTASection } from '@/components/home/CTASection'
import { getFeaturedPatterns, getPatterns, getPatternStats } from '@/lib/api/patterns'
import { JsonLd } from '@/components/shared/JsonLd'
import { getHomePage } from '@/lib/cms/queries'
import type { CmsHeroBlock, CmsCtaBannerBlock, CmsStatsBarBlock, CmsFeaturedPatternsBlock } from '@/lib/cms/types'

export const metadata: Metadata = {
  title: 'Home',
  description: 'Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',
}

// Revalidate every 5 minutes
export const revalidate = 300

export default async function HomePage() {
  // Fetch CMS content and API data in parallel
  const [homePage, featuredPatterns, allPatternsResult] = await Promise.all([
    getHomePage(),
    getFeaturedPatterns().catch(() => []),
    getPatterns({ pageSize: 100 }).catch(() => ({ patterns: [], total: 0 })),
  ])

  const stats = getPatternStats(allPatternsResult.patterns)

  // Extract CMS blocks by type
  const content = homePage.content ?? []
  const heroBlock = content.find((b): b is CmsHeroBlock => b.__component === 'sections.hero')
  const statsBlock = content.find((b): b is CmsStatsBarBlock => b.__component === 'sections.stats-bar')
  const featuredBlock = content.find((b): b is CmsFeaturedPatternsBlock => b.__component === 'sections.featured-patterns')
  const ctaBlock = content.find((b): b is CmsCtaBannerBlock => b.__component === 'sections.cta-banner')

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
      <Hero
        heading={heroBlock?.heading}
        subheading={heroBlock?.subheading}
        primaryCTA={heroBlock?.primaryCTA}
        secondaryCTA={heroBlock?.secondaryCTA}
      />
      <FeaturedPatterns
        patterns={featuredPatterns}
        heading={featuredBlock?.heading}
        subheading={featuredBlock?.subheading}
        viewAllLabel={featuredBlock?.viewAllLabel}
        mobileViewAllLabel={featuredBlock?.mobileViewAllLabel}
      />
      <StatsSection {...stats} statLabels={statsBlock?.stats} />
      <CTASection
        heading={ctaBlock?.heading}
        description={ctaBlock?.description}
        primaryCTA={ctaBlock?.primaryCTA}
        secondaryCTA={ctaBlock?.secondaryCTA}
      />
      <JsonLd data={jsonLd} />
    </>
  )
}
