import type { MetadataRoute } from 'next'

const PRODUCTION_URL = 'https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/', '/login/'],
    },
    sitemap: `${PRODUCTION_URL}/sitemap.xml`,
  }
}
