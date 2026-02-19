import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { PatternActions } from '../PatternActions'
import { useSession } from 'next-auth/react'

const mockPush = jest.fn()

jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}))

jest.mock('next/link', () => {
  return ({ children, href }: { children: React.ReactNode; href: string }) => (
    <a href={href}>{children}</a>
  )
})

jest.mock('sonner', () => ({
  toast: { error: jest.fn() },
}))

jest.mock('@/lib/api/patterns', () => ({
  deletePattern: jest.fn(),
}))

import { deletePattern } from '@/lib/api/patterns'
import { toast } from 'sonner'

const mockDeletePattern = deletePattern as jest.MockedFunction<typeof deletePattern>

const editorSession = {
  data: {
    accessToken: 'test-token',
    user: { roles: ['Editor'], name: 'Test User', email: 'test@test.com' },
    expires: '2099-01-01',
  },
  status: 'authenticated' as const,
}

describe('PatternActions', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    ;(useSession as jest.Mock).mockReturnValue(editorSession)
  })

  it('renders Edit button linking to edit page', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    const editLink = screen.getByRole('link', { name: /edit/i })
    expect(editLink).toHaveAttribute('href', '/patterns/test-pattern/edit')
  })

  it('renders Delete button', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    expect(screen.getByRole('button', { name: /delete/i })).toBeInTheDocument()
  })

  it('does not show confirmation sheet initially', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    expect(screen.queryByText('Delete Pattern?')).not.toBeInTheDocument()
  })

  it('shows confirmation dialog when Delete is clicked', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    expect(screen.getByText('Delete Pattern?')).toBeInTheDocument()
  })

  it('hides confirmation dialog when Cancel is clicked', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }))
    expect(screen.queryByText('Delete Pattern?')).not.toBeInTheDocument()
  })

  it('calls deletePattern with patternId and token, then redirects', async () => {
    mockDeletePattern.mockResolvedValueOnce(undefined)
    render(<PatternActions slug="my-pattern" patternId="pattern-abc-123" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    const confirmBtn = screen.getByRole('button', { name: /^delete$/i })
    fireEvent.click(confirmBtn)

    await waitFor(() => {
      expect(mockDeletePattern).toHaveBeenCalledWith('pattern-abc-123', 'test-token')
    })
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/patterns')
    })
  })

  it('shows error toast when delete fails', async () => {
    mockDeletePattern.mockRejectedValueOnce(new Error('Network error'))
    const { toast } = await import('sonner')

    render(<PatternActions slug="my-pattern" patternId="pattern-abc-123" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    const confirmBtn = screen.getByRole('button', { name: /^delete$/i })
    fireEvent.click(confirmBtn)

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith(
        'Failed to delete pattern. Please try again.'
      )
    })
  })

  it('returns null when session is loading', () => {
    ;(useSession as jest.Mock).mockReturnValue({ data: null, status: 'loading' })
    const { container } = render(
      <PatternActions slug="test-pattern" patternId="pattern-id-1" />
    )
    expect(container.firstChild).toBeNull()
  })

  it('returns null when user is not an editor', () => {
    ;(useSession as jest.Mock).mockReturnValue({
      data: {
        user: { roles: [], name: 'Test', email: 'test@test.com' },
        accessToken: null,
        expires: '2099-01-01',
      },
      status: 'authenticated',
    })
    const { container } = render(
      <PatternActions slug="test-pattern" patternId="pattern-id-1" />
    )
    expect(container.firstChild).toBeNull()
  })

  it('returns null when unauthenticated', () => {
    ;(useSession as jest.Mock).mockReturnValue({ data: null, status: 'unauthenticated' })
    const { container } = render(
      <PatternActions slug="test-pattern" patternId="pattern-id-1" />
    )
    expect(container.firstChild).toBeNull()
  })
})
