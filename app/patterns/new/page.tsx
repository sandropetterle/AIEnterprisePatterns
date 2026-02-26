import { Metadata } from 'next'
import { redirect } from 'next/navigation'
import { auth } from '@/auth'
import { hasRole } from '@/lib/types/auth'
import { PatternForm } from '@/components/patterns/PatternForm'
import { Breadcrumb } from '@/components/patterns/details/Breadcrumb'
import { getPatternFormLabels } from '@/lib/cms/queries'

export const metadata: Metadata = {
  title: 'New Pattern | AI Enterprise Patterns',
  description: 'Create a new AI enterprise pattern.',
}

export default async function NewPatternPage() {
  const session = await auth()

  if (!session) {
    redirect('/login')
  }

  if (!hasRole(session.user.roles, 'Editor')) {
    redirect('/patterns')
  }

  const labels = await getPatternFormLabels()

  const breadcrumbs = [
    { label: 'Home', href: '/' },
    { label: 'Patterns', href: '/patterns' },
    { label: 'New Pattern', href: '/patterns/new' },
  ]

  return (
    <>
      <Breadcrumb items={breadcrumbs} />
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 max-w-3xl">
        <PatternForm mode="create" labels={labels} />
      </div>
    </>
  )
}
