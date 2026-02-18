/**
 * PatternCard Component Tests
 * Tests the pattern card display component
 */

import { render, screen } from '@testing-library/react'
import { PatternCard } from '../PatternCard'
import type { Pattern } from '@/lib/types/pattern'

// Mock Next.js Link
jest.mock('next/link', () => {
  return ({ children, href }: { children: React.ReactNode; href: string }) => {
    return <a href={href}>{children}</a>
  }
})

describe('PatternCard', () => {
  const mockPattern: Pattern = {
    id: '1',
    title: 'Test Pattern',
    slug: 'test-pattern',
    shortDescription: 'This is a test pattern description',
    category: 'Architecture',
    tags: ['Tag1', 'Tag2', 'Tag3', 'Tag4'],
    author: 'John Doe',
    createdDate: '2024-01-15T10:00:00Z',
    updatedDate: '2024-01-15T10:00:00Z',
    voteCount: 42,
    status: 'published',
    isFeatured: false,
    isTrending: false,
  }

  it('should render pattern title', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(screen.getByText('Test Pattern')).toBeInTheDocument()
  })

  it('should render pattern category', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(screen.getByText('Architecture')).toBeInTheDocument()
  })

  it('should render pattern description', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(
      screen.getByText('This is a test pattern description')
    ).toBeInTheDocument()
  })

  it('should render vote count', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(screen.getByText('42')).toBeInTheDocument()
  })

  it('should render author name', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(screen.getByText(/by John Doe/)).toBeInTheDocument()
  })

  it('should limit tags to max of 3', () => {
    render(<PatternCard pattern={mockPattern} />)

    expect(screen.getByText('Tag1')).toBeInTheDocument()
    expect(screen.getByText('Tag2')).toBeInTheDocument()
    expect(screen.getByText('Tag3')).toBeInTheDocument()
    expect(screen.queryByText('Tag4')).not.toBeInTheDocument()
  })

  it('should show all tags if less than max', () => {
    const patternWithFewTags = {
      ...mockPattern,
      tags: ['Tag1', 'Tag2'],
    }
    render(<PatternCard pattern={patternWithFewTags} />)

    expect(screen.getByText('Tag1')).toBeInTheDocument()
    expect(screen.getByText('Tag2')).toBeInTheDocument()
  })

  it('should truncate long descriptions', () => {
    const longDescription = 'A'.repeat(150)
    const patternWithLongDesc = {
      ...mockPattern,
      shortDescription: longDescription,
    }

    render(<PatternCard pattern={patternWithLongDesc} />)

    const description = screen.getByText(/\.\.\./)
    expect(description.textContent?.length).toBeLessThan(150)
  })

  it('should not truncate short descriptions', () => {
    const shortDescription = 'Short description'
    const patternWithShortDesc = {
      ...mockPattern,
      shortDescription: shortDescription,
    }

    render(<PatternCard pattern={patternWithShortDesc} />)

    expect(screen.getByText(shortDescription)).toBeInTheDocument()
    expect(screen.queryByText(/\.\.\./)).not.toBeInTheDocument()
  })

  it('should link to pattern detail page', () => {
    const { container } = render(<PatternCard pattern={mockPattern} />)

    const link = container.querySelector('a[href="/patterns/test-pattern"]')
    expect(link).toBeInTheDocument()
  })

  it('should not render author if not provided', () => {
    const patternWithoutAuthor = {
      ...mockPattern,
      author: undefined,
    }

    render(<PatternCard pattern={patternWithoutAuthor} />)

    expect(screen.queryByText(/by/)).not.toBeInTheDocument()
  })

  it('should handle patterns with no tags', () => {
    const patternWithoutTags = {
      ...mockPattern,
      tags: [],
    }

    render(<PatternCard pattern={patternWithoutTags} />)

    // Card should still render
    expect(screen.getByText('Test Pattern')).toBeInTheDocument()
  })

  it('should display zero vote count', () => {
    const patternWithZeroVotes = {
      ...mockPattern,
      voteCount: 0,
    }

    render(<PatternCard pattern={patternWithZeroVotes} />)

    expect(screen.getByText('0')).toBeInTheDocument()
  })
})
