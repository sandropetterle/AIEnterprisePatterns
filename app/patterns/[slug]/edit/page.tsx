import { Metadata } from 'next'
import { redirect, notFound } from 'next/navigation'
import { auth } from '@/auth'
import { hasRole } from '@/lib/types/auth'
import { getPatternBySlug } from '@/lib/api/patterns'
import { PatternForm } from '@/components/patterns/PatternForm'
import { Breadcrumb } from '@/components/patterns/details/Breadcrumb'
import { getPatternFormLabels } from '@/lib/cms/queries'

type PageProps = {
  params: Promise<{ slug: string }>
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params
  return {
    title: `Edit Pattern | AI Enterprise Patterns`,
    description: `Edit the pattern: ${slug}`,
  }
}

export default async function EditPatternPage({ params }: PageProps) {
  const [session, { slug }] = await Promise.all([auth(), params])

  if (!session) {
    redirect('/login')
  }

  if (!hasRole(session.user.roles, 'Editor')) {
    redirect('/patterns')
  }

  const [pattern, labels] = await Promise.all([
    getPatternBySlug(slug),
    getPatternFormLabels(),
  ])

  if (!pattern) {
    notFound()
  }

  const breadcrumbs = [
    { label: 'Home', href: '/' },
    { label: 'Patterns', href: '/patterns' },
    { label: pattern.title, href: `/patterns/${pattern.slug}` },
    { label: 'Edit', href: `/patterns/${pattern.slug}/edit` },
  ]

  return (
    <>
      <Breadcrumb items={breadcrumbs} />
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 max-w-3xl">
        <PatternForm mode="edit" initialData={pattern} labels={labels} />
      </div>
    </>
  )
}
