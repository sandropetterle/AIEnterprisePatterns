import type { MetadataRoute } from 'next'
import { getPatterns } from '@/lib/api/patterns'

const PRODUCTION_URL = 'https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io'

const STATIC_ROUTES: MetadataRoute.Sitemap = [
  {
    url: PRODUCTION_URL,
    lastModified: new Date(),
    changeFrequency: 'daily',
    priority: 1,
  },
  {
    url: `${PRODUCTION_URL}/patterns`,
    lastModified: new Date(),
    changeFrequency: 'daily',
    priority: 0.9,
  },
]

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  try {
    const result = await getPatterns({ pageSize: 100 })
    const patternRoutes: MetadataRoute.Sitemap = result.patterns.map((pattern) => ({
      url: `${PRODUCTION_URL}/patterns/${pattern.slug}`,
      lastModified: pattern.updatedDate ? new Date(pattern.updatedDate) : new Date(),
      changeFrequency: 'weekly' as const,
      priority: 0.7,
    }))
    return [...STATIC_ROUTES, ...patternRoutes]
  } catch {
    // API unavailable — return static routes only
    return STATIC_ROUTES
  }
}
