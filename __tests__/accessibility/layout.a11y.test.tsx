import { render } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { PatternCard } from '@/components/home/PatternCard'
import type { Pattern } from '@/lib/types/pattern'

expect.extend(toHaveNoViolations)

jest.mock('next/link', () => {
  return ({ children, href, ...rest }: { children: React.ReactNode; href: string; [key: string]: unknown }) => (
    <a href={href} {...rest}>{children}</a>
  )
})

const mockPattern: Pattern = {
  id: 'p1',
  title: 'Clean Architecture',
  slug: 'clean-arch',
  shortDescription: 'A layered architecture approach for enterprise systems',
  category: 'Architecture',
  tags: ['DDD', 'CQRS'],
  createdDate: '2024-01-01T00:00:00Z',
  updatedDate: '2024-01-01T00:00:00Z',
  voteCount: 42,
  status: 'published',
  author: 'Test Author',
}

describe('Layout & Cards — Accessibility', () => {
  it('PatternCard has no axe violations', async () => {
    const { container } = render(<PatternCard pattern={mockPattern} />)
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('PatternCard without author has no axe violations', async () => {
    const patternNoAuthor = { ...mockPattern, author: undefined }
    const { container } = render(<PatternCard pattern={patternNoAuthor} />)
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
