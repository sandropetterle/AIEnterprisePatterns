import { render } from '@testing-library/react'
import { RecentlyViewedTracker } from '../RecentlyViewedTracker'

const mockAddRecentPattern = jest.fn()

jest.mock('@/hooks/useRecentlyViewed', () => ({
  useRecentlyViewed: () => ({
    recentPatterns: [],
    addRecentPattern: mockAddRecentPattern,
    clearRecentPatterns: jest.fn(),
  }),
}))

beforeEach(() => {
  mockAddRecentPattern.mockClear()
})

describe('RecentlyViewedTracker', () => {
  it('renders nothing (null)', () => {
    const { container } = render(
      <RecentlyViewedTracker
        slug="test-pattern"
        title="Test Pattern"
        category="Architecture"
      />
    )
    expect(container.firstChild).toBeNull()
  })

  it('calls addRecentPattern on mount with correct data', () => {
    render(
      <RecentlyViewedTracker
        slug="test-pattern"
        title="Test Pattern"
        category="Architecture"
      />
    )
    expect(mockAddRecentPattern).toHaveBeenCalledWith({
      slug: 'test-pattern',
      title: 'Test Pattern',
      category: 'Architecture',
    })
  })

  it('calls addRecentPattern once on initial render', () => {
    render(
      <RecentlyViewedTracker
        slug="cqrs-pattern"
        title="CQRS Pattern"
        category="Design Patterns"
      />
    )
    expect(mockAddRecentPattern).toHaveBeenCalledTimes(1)
  })
})
