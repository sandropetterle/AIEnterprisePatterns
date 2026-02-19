import { render, screen } from '@testing-library/react'
import { RelatedPatternsSection } from '../RelatedPatternsSection'
import type { Pattern } from '@/lib/types/pattern'

jest.mock('next/link', () => {
  return ({ children, href }: { children: React.ReactNode; href: string }) => (
    <a href={href}>{children}</a>
  )
})

const makePattern = (id: string, title: string): Pattern => ({
  id,
  title,
  slug: `pattern-${id}`,
  shortDescription: 'A description',
  category: 'Architecture',
  tags: [],
  createdDate: '2024-01-01T00:00:00Z',
  updatedDate: '2024-01-01T00:00:00Z',
  voteCount: 10,
  status: 'published',
})

describe('RelatedPatternsSection', () => {
  it('renders heading', () => {
    render(<RelatedPatternsSection patterns={[]} />)
    expect(screen.getByText('Related Patterns')).toBeInTheDocument()
  })

  it('shows empty message when no patterns', () => {
    render(<RelatedPatternsSection patterns={[]} />)
    expect(screen.getByText('No related patterns found')).toBeInTheDocument()
  })

  it('renders each related pattern', () => {
    const patterns = [
      makePattern('1', 'Alpha Pattern'),
      makePattern('2', 'Beta Pattern'),
    ]
    render(<RelatedPatternsSection patterns={patterns} />)
    expect(screen.getByText('Alpha Pattern')).toBeInTheDocument()
    expect(screen.getByText('Beta Pattern')).toBeInTheDocument()
  })

  it('links each pattern to its slug', () => {
    const patterns = [makePattern('1', 'Alpha Pattern')]
    render(<RelatedPatternsSection patterns={patterns} />)
    expect(screen.getByRole('link', { name: /Alpha Pattern/i })).toHaveAttribute(
      'href',
      '/patterns/pattern-1'
    )
  })

  it('shows category badge for each pattern', () => {
    const patterns = [makePattern('1', 'Alpha')]
    render(<RelatedPatternsSection patterns={patterns} />)
    expect(screen.getByText('Architecture')).toBeInTheDocument()
  })

  it('shows vote count for each pattern', () => {
    const patterns = [makePattern('1', 'Alpha')]
    render(<RelatedPatternsSection patterns={patterns} />)
    expect(screen.getByText('10')).toBeInTheDocument()
  })
})
