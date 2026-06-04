import { render, screen } from '@testing-library/react'
import { PatternsGrid } from '../PatternsGrid'
import type { Pattern } from '@/lib/types/pattern'

jest.mock('next/link', () => {
  return function MockLink({ children, href }: { children: React.ReactNode; href: string }) {
    return <a href={href}>{children}</a>
  }
})

const makePattern = (id: string, title: string): Pattern => ({
  id,
  title,
  slug: `pattern-${id}`,
  shortDescription: 'Description',
  category: 'Architecture',
  tags: ['tag1'],
  createdDate: '2024-01-01T00:00:00Z',
  updatedDate: '2024-01-01T00:00:00Z',
  voteCount: 5,
  status: 'published',
})

describe('PatternsGrid', () => {
  it('renders a card for each pattern', () => {
    const patterns = [
      makePattern('1', 'Alpha Pattern'),
      makePattern('2', 'Beta Pattern'),
      makePattern('3', 'Gamma Pattern'),
    ]

    render(<PatternsGrid patterns={patterns} />)

    expect(screen.getByText('Alpha Pattern')).toBeInTheDocument()
    expect(screen.getByText('Beta Pattern')).toBeInTheDocument()
    expect(screen.getByText('Gamma Pattern')).toBeInTheDocument()
  })

  it('renders empty grid when patterns is empty', () => {
    const { container } = render(<PatternsGrid patterns={[]} />)
    const grid = container.firstChild as HTMLElement
    expect(grid.children).toHaveLength(0)
  })

  it('renders single pattern', () => {
    render(<PatternsGrid patterns={[makePattern('1', 'Solo Pattern')]} />)
    expect(screen.getByText('Solo Pattern')).toBeInTheDocument()
  })
})
