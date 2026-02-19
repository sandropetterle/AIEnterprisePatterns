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

// Mock AlertDialog inline to avoid Radix portal issues in jsdom
jest.mock('@/components/ui/alert-dialog', () => ({
  AlertDialog: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogTrigger: ({ children, asChild }: { children: React.ReactNode; asChild?: boolean }) =>
    asChild ? <>{children}</> : <div>{children}</div>,
  AlertDialogContent: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="alert-dialog-content">{children}</div>
  ),
  AlertDialogHeader: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogTitle: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogDescription: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogFooter: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogCancel: ({
    children,
    disabled,
    onClick,
  }: {
    children: React.ReactNode
    disabled?: boolean
    onClick?: () => void
  }) => (
    <button onClick={onClick} disabled={disabled}>
      {children}
    </button>
  ),
  AlertDialogAction: ({
    children,
    disabled,
    onClick,
    className,
  }: {
    children: React.ReactNode
    disabled?: boolean
    onClick?: () => void
    className?: string
  }) => (
    <button onClick={onClick} disabled={disabled} className={className}>
      {children}
    </button>
  ),
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
    // Multiple Delete buttons: trigger + dialog action — check at least one exists
    expect(screen.getAllByRole('button', { name: /delete/i }).length).toBeGreaterThan(0)
  })

  it('shows confirmation dialog content (AlertDialog always rendered)', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    // AlertDialog is mocked to always render content
    expect(screen.getByText('Delete Pattern?')).toBeInTheDocument()
  })

  it('renders Cancel button in dialog', () => {
    render(<PatternActions slug="test-pattern" patternId="pattern-id-1" />)
    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument()
  })

  it('calls deletePattern with patternId and token, then redirects', async () => {
    mockDeletePattern.mockResolvedValueOnce(undefined)
    render(<PatternActions slug="my-pattern" patternId="pattern-abc-123" />)
    // The dialog action button is inside the alert-dialog-content
    const dialogContent = screen.getByTestId('alert-dialog-content')
    const confirmBtn = dialogContent.querySelector('button:last-child') as HTMLElement
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
    const dialogContent = screen.getByTestId('alert-dialog-content')
    const confirmBtn = dialogContent.querySelector('button:last-child') as HTMLElement
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
