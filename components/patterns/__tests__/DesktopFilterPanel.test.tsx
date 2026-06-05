import { render, screen, act } from '@testing-library/react'
import { DesktopFilterPanel } from '../DesktopFilterPanel'

// Mock FilterPanel to avoid its dependencies (next/navigation, Radix, hooks)
jest.mock('../FilterPanel', () => ({
  FilterPanel: ({ categories, tags }: { categories: string[]; tags: string[]; labels?: unknown }) => (
    <div data-testid="filter-panel" data-categories={categories.join(',')} data-tags={tags.join(',')} />
  ),
}))

type MediaQueryChangeListener = (event: { matches: boolean }) => void

/**
 * Install a controllable matchMedia mock. Returns a trigger that simulates
 * the media query flipping (e.g. viewport resize across the lg breakpoint).
 */
function mockMatchMedia(matches: boolean) {
  const listeners: MediaQueryChangeListener[] = []
  const mql = {
    matches,
    media: '(min-width: 1024px)',
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn((_: string, cb: MediaQueryChangeListener) => {
      listeners.push(cb)
    }),
    removeEventListener: jest.fn((_: string, cb: MediaQueryChangeListener) => {
      const i = listeners.indexOf(cb)
      if (i >= 0) listeners.splice(i, 1)
    }),
    dispatchEvent: jest.fn(),
  }
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: jest.fn().mockImplementation(() => mql),
  })
  return {
    mql,
    fireChange(nextMatches: boolean) {
      mql.matches = nextMatches
      listeners.forEach((cb) => cb({ matches: nextMatches }))
    },
  }
}

describe('DesktopFilterPanel', () => {
  const props = { categories: ['Architecture'], tags: ['Tag1'] }

  it('mounts FilterPanel when the desktop media query matches', () => {
    mockMatchMedia(true)
    render(<DesktopFilterPanel {...props} />)

    expect(screen.getByTestId('filter-panel')).toBeInTheDocument()
  })

  it('renders nothing (no FilterPanel) when the media query does not match', () => {
    mockMatchMedia(false)
    render(<DesktopFilterPanel {...props} />)

    expect(screen.queryByTestId('filter-panel')).not.toBeInTheDocument()
  })

  it('passes categories and tags through to FilterPanel', () => {
    mockMatchMedia(true)
    render(<DesktopFilterPanel {...props} />)

    const panel = screen.getByTestId('filter-panel')
    expect(panel).toHaveAttribute('data-categories', 'Architecture')
    expect(panel).toHaveAttribute('data-tags', 'Tag1')
  })

  it('mounts FilterPanel when the viewport grows across the breakpoint', () => {
    const media = mockMatchMedia(false)
    render(<DesktopFilterPanel {...props} />)
    expect(screen.queryByTestId('filter-panel')).not.toBeInTheDocument()

    act(() => media.fireChange(true))

    expect(screen.getByTestId('filter-panel')).toBeInTheDocument()
  })

  it('unmounts FilterPanel when the viewport shrinks below the breakpoint', () => {
    const media = mockMatchMedia(true)
    render(<DesktopFilterPanel {...props} />)
    expect(screen.getByTestId('filter-panel')).toBeInTheDocument()

    act(() => media.fireChange(false))

    expect(screen.queryByTestId('filter-panel')).not.toBeInTheDocument()
  })

  it('removes the media query listener on unmount', () => {
    const media = mockMatchMedia(true)
    const { unmount } = render(<DesktopFilterPanel {...props} />)

    unmount()

    expect(media.mql.removeEventListener).toHaveBeenCalled()
  })
})
