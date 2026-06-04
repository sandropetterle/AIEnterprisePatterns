import { render, screen, fireEvent } from '@testing-library/react'
import { RecentlyViewedSidebar } from '../RecentlyViewedSidebar'
import type { RecentPattern } from '@/hooks/useRecentlyViewed'

const mockClearRecentPatterns = jest.fn()
let mockRecentPatterns: RecentPattern[] = []

jest.mock('@/hooks/useRecentlyViewed', () => ({
  useRecentlyViewed: () => ({
    recentPatterns: mockRecentPatterns,
    addRecentPattern: jest.fn(),
    clearRecentPatterns: mockClearRecentPatterns,
  }),
}))

jest.mock('next/link', () => {
  return function MockLink({ children, href }: { children: React.ReactNode; href: string }) {
    return <a href={href}>{children}</a>
  }
})

beforeEach(() => {
  mockClearRecentPatterns.mockClear()
  mockRecentPatterns = []
})

describe('RecentlyViewedSidebar', () => {
  it('renders nothing when list is empty', () => {
    const { container } = render(<RecentlyViewedSidebar />)
    expect(container.firstChild).toBeNull()
  })

  it('renders patterns when list is not empty', () => {
    mockRecentPatterns = [
      { slug: 'clean-arch', title: 'Clean Architecture', category: 'Architecture', visitedAt: new Date().toISOString() },
    ]
    render(<RecentlyViewedSidebar />)
    expect(screen.getByText('Clean Architecture')).toBeInTheDocument()
  })

  it('renders links to pattern pages', () => {
    mockRecentPatterns = [
      { slug: 'my-pattern', title: 'My Pattern', category: 'Security', visitedAt: new Date().toISOString() },
    ]
    render(<RecentlyViewedSidebar />)
    const link = screen.getByRole('link', { name: /my pattern/i })
    expect(link).toHaveAttribute('href', '/patterns/my-pattern')
  })

  it('shows category badge for each pattern', () => {
    mockRecentPatterns = [
      { slug: 'arch-pattern', title: 'Arch Pattern', category: 'Architecture', visitedAt: new Date().toISOString() },
    ]
    render(<RecentlyViewedSidebar />)
    expect(screen.getByText('Architecture')).toBeInTheDocument()
  })

  it('renders clear button', () => {
    mockRecentPatterns = [
      { slug: 'p1', title: 'P1', category: 'Security', visitedAt: new Date().toISOString() },
    ]
    render(<RecentlyViewedSidebar />)
    expect(screen.getByRole('button', { name: /clear/i })).toBeInTheDocument()
  })

  it('calls clearRecentPatterns when clear button is clicked', () => {
    mockRecentPatterns = [
      { slug: 'p1', title: 'P1', category: 'Security', visitedAt: new Date().toISOString() },
    ]
    render(<RecentlyViewedSidebar />)
    fireEvent.click(screen.getByRole('button', { name: /clear/i }))
    expect(mockClearRecentPatterns).toHaveBeenCalledTimes(1)
  })

  it('renders up to 5 patterns', () => {
    mockRecentPatterns = Array.from({ length: 5 }, (_, i) => ({
      slug: `p${i}`,
      title: `Pattern ${i}`,
      category: 'Architecture' as const,
      visitedAt: new Date().toISOString(),
    }))
    render(<RecentlyViewedSidebar />)
    const links = screen.getAllByRole('link')
    expect(links).toHaveLength(5)
  })
})
