import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { PatternActions } from '../PatternActions'

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

describe('PatternActions', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    global.fetch = jest.fn()
  })

  it('renders Edit button linking to edit page', () => {
    render(<PatternActions slug="test-pattern" />)
    const editLink = screen.getByRole('link', { name: /edit/i })
    expect(editLink).toHaveAttribute('href', '/patterns/test-pattern/edit')
  })

  it('renders Delete button', () => {
    render(<PatternActions slug="test-pattern" />)
    expect(screen.getByRole('button', { name: /delete/i })).toBeInTheDocument()
  })

  it('does not show confirmation sheet initially', () => {
    render(<PatternActions slug="test-pattern" />)
    expect(screen.queryByText('Delete Pattern?')).not.toBeInTheDocument()
  })

  it('shows confirmation dialog when Delete is clicked', () => {
    render(<PatternActions slug="test-pattern" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    expect(screen.getByText('Delete Pattern?')).toBeInTheDocument()
  })

  it('hides confirmation dialog when Cancel is clicked', () => {
    render(<PatternActions slug="test-pattern" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }))
    expect(screen.queryByText('Delete Pattern?')).not.toBeInTheDocument()
  })

  it('calls DELETE endpoint and redirects on confirm', async () => {
    ;(global.fetch as jest.Mock).mockResolvedValueOnce({ ok: true })
    render(<PatternActions slug="my-pattern" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    const confirmBtn = screen.getByRole('button', { name: /^delete$/i })
    fireEvent.click(confirmBtn)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        '/api/patterns/my-pattern',
        { method: 'DELETE' }
      )
    })
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/patterns')
    })
  })

  it('shows error toast when delete fails', async () => {
    ;(global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'))
    const { toast } = await import('sonner')

    render(<PatternActions slug="my-pattern" />)
    fireEvent.click(screen.getByRole('button', { name: /delete/i }))
    const confirmBtn = screen.getByRole('button', { name: /^delete$/i })
    fireEvent.click(confirmBtn)

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith(
        'Failed to delete pattern. Please try again.'
      )
    })
  })
})
