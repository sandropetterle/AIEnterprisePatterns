import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getPatternBySlug, getPatterns, getRelatedPatterns } from '@/lib/api/patterns'
import { formatDate } from '@/lib/utils/dateFormat'
import dynamic from 'next/dynamic'
import { Breadcrumb } from '@/components/patterns/details/Breadcrumb'
import { VotingButton } from '@/components/patterns/details/VotingButton'

const PatternContent = dynamic(
  () => import('@/components/patterns/details/PatternContent').then(mod => ({ default: mod.PatternContent })),
  { loading: () => <div className="h-64 animate-pulse rounded bg-muted" /> }
)
import { RelatedPatternsSection } from '@/components/patterns/details/RelatedPatternsSection'
import { PatternActions } from '@/components/patterns/details/PatternActions'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { JsonLd } from '@/components/shared/JsonLd'
import { ErrorBoundary } from '@/components/shared/ErrorBoundary'
import { RecentlyViewedTracker } from '@/components/patterns/RecentlyViewedTracker'
import { getPatternDetailLabels } from '@/lib/cms/queries'

type PageProps = {
  params: Promise<{ slug: string }>
}

// Revalidate every 10 minutes
export const revalidate = 600

export async function generateStaticParams() {
  try {
    const response = await getPatterns({ pageSize: 100 })
    return response.patterns.map((pattern) => ({
      slug: pattern.slug,
    }))
  } catch (error) {
    // API not available during build (e.g., Docker build) - return empty array
    // Pages will be generated on-demand via ISR
    console.warn('Failed to fetch patterns for static generation:', error)
    return []
  }
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params
  const pattern = await getPatternBySlug(slug)

  if (!pattern) {
    return {
      title: 'Pattern Not Found',
      description: 'The requested pattern could not be found.',
    }
  }

  return {
    // Bare title — app/layout.tsx title.template appends "| AI Enterprise Patterns"
    title: pattern.title,
    description: pattern.shortDescription,
    keywords: [pattern.category, ...pattern.tags],
    openGraph: {
      title: pattern.title,
      description: pattern.shortDescription,
      type: 'article',
      publishedTime: pattern.createdDate,
      modifiedTime: pattern.updatedDate,
      tags: pattern.tags,
    },
    twitter: {
      card: 'summary_large_image',
      title: pattern.title,
      description: pattern.shortDescription,
    },
  }
}

export default async function PatternDetailPage({ params }: PageProps) {
  const { slug } = await params
  const [pattern, labels, relatedPatterns] = await Promise.all([
    getPatternBySlug(slug),
    getPatternDetailLabels(),
    getRelatedPatterns(slug),
  ])

  if (!pattern) {
    notFound()
  }

  const breadcrumbs = [
    { label: 'Home', href: '/' },
    { label: 'Patterns', href: '/patterns' },
    { label: pattern.title, href: `/patterns/${pattern.slug}` },
  ]

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: pattern.title,
    description: pattern.shortDescription,
    author: {
      '@type': 'Person',
      name: pattern.author || 'Anonymous',
    },
    datePublished: pattern.createdDate,
    dateModified: pattern.updatedDate,
    keywords: pattern.tags.join(', '),
  }

  return (
    <>
      <RecentlyViewedTracker
        slug={pattern.slug}
        title={pattern.title}
        category={pattern.category}
      />
      <Breadcrumb items={breadcrumbs} ariaLabel={labels.breadcrumbAriaLabel} />

      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content - 2/3 width */}
          <div className="lg:col-span-2">
            {/* Header */}
            <div className="mb-6">
              <Badge className="mb-3">{pattern.category}</Badge>
              <h1 className="text-3xl sm:text-4xl font-bold tracking-tight mb-3">
                {pattern.title}
              </h1>
              <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                <span>By {pattern.author || 'Anonymous'}</span>
                <span>•</span>
                <span>{formatDate(pattern.createdDate)}</span>
                {pattern.updatedDate !== pattern.createdDate && (
                  <>
                    <span>•</span>
                    <span>Updated {formatDate(pattern.updatedDate)}</span>
                  </>
                )}
              </div>
            </div>

            {/* Voting and Actions */}
            <div className="flex items-center gap-3 mb-6">
              <ErrorBoundary>
                <VotingButton
                  initialVoteCount={pattern.voteCount}
                  patternId={pattern.id}
                  votesLabel={labels.votesLabel}
                  voteAriaTemplate={labels.voteAriaTemplate}
                  voteAnnouncementTemplate={labels.voteAnnouncementTemplate}
                />
              </ErrorBoundary>
              <PatternActions
                slug={pattern.slug}
                patternId={pattern.id}
                editLabel={labels.editLabel}
                deleteLabel={labels.deleteLabel}
                deleteDialogTitle={labels.deleteDialogTitle}
                deleteDialogDescription={labels.deleteDialogDescription}
                cancelLabel={labels.cancelLabel}
                deleteConfirmLabel={labels.deleteConfirmLabel}
                deletingLabel={labels.deletingLabel}
              />
            </div>

            {/* Full Content (Markdown) */}
            <Card>
              <CardContent className="pt-6">
                <ErrorBoundary>
                  {pattern.fullContent ? (
                    <PatternContent content={pattern.fullContent} />
                  ) : (
                    <p className="text-muted-foreground">
                      {labels.noContentMessage ?? 'No content available for this pattern.'}
                    </p>
                  )}
                </ErrorBoundary>
              </CardContent>
            </Card>

            {/* Tags */}
            {pattern.tags.length > 0 && (
              <div className="mt-6 flex flex-wrap gap-2">
                {pattern.tags.map((tag) => (
                  <Badge key={tag} variant="outline">
                    {tag}
                  </Badge>
                ))}
              </div>
            )}
          </div>

          {/* Sidebar - 1/3 width */}
          <aside className="lg:col-span-1">
            <div className="lg:sticky lg:top-8">
              <RelatedPatternsSection
                patterns={relatedPatterns}
                title={labels.relatedPatternsTitle}
                noRelatedMessage={labels.noRelatedMessage}
              />
            </div>
          </aside>
        </div>
      </div>

      {/* JSON-LD for SEO */}
      <JsonLd data={jsonLd} />
    </>
  )
}
