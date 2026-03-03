import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useSession } from 'next-auth/react'
import { PatternForm } from '../PatternForm'

const mockPush = jest.fn()
const mockBack = jest.fn()

jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush, back: mockBack }),
}))

jest.mock('sonner', () => ({
  toast: { success: jest.fn(), error: jest.fn() },
}))

jest.mock('@/lib/api/patterns', () => ({
  createPattern: jest.fn(),
  updatePattern: jest.fn(),
}))

// Mock Radix UI Select — use a context-based approach so SelectTrigger
// can render a native <select> with id + value bound to the parent Select.
jest.mock('@/components/ui/select', () => {
  const React = require('react')
  const Ctx = React.createContext({ value: '' as string, onValueChange: (() => {}) as (v: string) => void })

  return {
    Select: ({
      value,
      onValueChange,
      children,
    }: {
      value: string
      onValueChange: (v: string) => void
      children: React.ReactNode
    }) => <Ctx.Provider value={{ value, onValueChange }}>{children}</Ctx.Provider>,

    SelectTrigger: ({ id, children }: { id?: string; children: React.ReactNode }) => {
      const ctx = React.useContext(Ctx)
      return (
        <select
          id={id}
          value={ctx.value}
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) =>
            ctx.onValueChange(e.target.value)
          }
          data-testid="category-select"
        >
          {children}
        </select>
      )
    },

    SelectValue: () => null,
    SelectContent: ({ children }: { children: React.ReactNode }) => <>{children}</>,
    SelectItem: ({ value, children }: { value: string; children: React.ReactNode }) => (
      <option value={value}>{children}</option>
    ),
  }
})

import { createPattern, updatePattern } from '@/lib/api/patterns'
import { toast } from 'sonner'

const mockCreatePattern = createPattern as jest.MockedFunction<typeof createPattern>
const mockUpdatePattern = updatePattern as jest.MockedFunction<typeof updatePattern>

const editorSession = {
  data: {
    accessToken: 'test-token',
    user: { roles: ['Editor'], name: 'Test User', email: 'test@test.com' },
    expires: '2099-01-01',
  },
  status: 'authenticated' as const,
}

const adminSession = {
  data: {
    accessToken: 'admin-token',
    user: { roles: ['Admin'], name: 'Admin User', email: 'admin@test.com' },
    expires: '2099-01-01',
  },
  status: 'authenticated' as const,
}

const mockPattern = {
  id: 'pattern-id-1',
  title: 'CQRS Pattern',
  slug: 'cqrs-pattern',
  shortDescription: 'A command/query separation pattern',
  fullContent: '# CQRS\n\nContent here',
  category: 'Architecture' as const,
  tags: ['cqrs', 'event-sourcing'],
  author: 'Jane Doe',
  createdDate: '2024-01-01T00:00:00Z',
  updatedDate: '2024-01-01T00:00:00Z',
  voteCount: 5,
  status: 'published' as const,
  isFeatured: false,
  isTrending: false,
}

describe('PatternForm — create mode', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    ;(useSession as jest.Mock).mockReturnValue(editorSession)
  })

  it('renders the form with create heading', () => {
    render(<PatternForm mode="create" />)
    expect(screen.getByText('New Pattern')).toBeInTheDocument()
  })

  it('renders all required form fields', () => {
    render(<PatternForm mode="create" />)
    expect(screen.getByLabelText(/title/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/short description/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/category/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/tags/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/full content/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/author/i)).toBeInTheDocument()
  })

  it('renders Create Pattern submit button', () => {
    render(<PatternForm mode="create" />)
    expect(screen.getByRole('button', { name: /create pattern/i })).toBeInTheDocument()
  })

  it('renders Cancel button', () => {
    render(<PatternForm mode="create" />)
    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument()
  })

  it('shows slug preview when title is typed', async () => {
    render(<PatternForm mode="create" />)
    await userEvent.type(screen.getByLabelText(/title \*/i), 'My New Pattern')
    expect(screen.getByText(/slug preview: my-new-pattern/i)).toBeInTheDocument()
  })

  it('shows title validation error when submitting empty title', async () => {
    render(<PatternForm mode="create" />)
    fireEvent.click(screen.getByRole('button', { name: /create pattern/i }))
    expect(await screen.findByText('Title is required')).toBeInTheDocument()
  })

  it('shows short description validation error when empty', async () => {
    render(<PatternForm mode="create" />)
    await userEvent.type(screen.getByLabelText(/title \*/i), 'Some Title')
    fireEvent.click(screen.getByRole('button', { name: /create pattern/i }))
    expect(await screen.findByText('Short description is required')).toBeInTheDocument()
  })

  it('shows title error on blur when empty', async () => {
    render(<PatternForm mode="create" />)
    const titleInput = screen.getByLabelText(/title \*/i)
    fireEvent.focus(titleInput)
    fireEvent.blur(titleInput)
    expect(await screen.findByText('Title is required')).toBeInTheDocument()
  })

  it('shows short description error on blur when empty', async () => {
    render(<PatternForm mode="create" />)
    const descInput = screen.getByLabelText(/short description \*/i)
    fireEvent.focus(descInput)
    fireEvent.blur(descInput)
    expect(await screen.findByText('Short description is required')).toBeInTheDocument()
  })

  it('can add a tag via Enter key', async () => {
    render(<PatternForm mode="create" />)
    const tagInput = screen.getByPlaceholderText(/add a tag and press enter/i)
    await userEvent.type(tagInput, 'my-tag{Enter}')
    expect(screen.getByText('my-tag')).toBeInTheDocument()
  })

  it('can add a tag via Add button', async () => {
    render(<PatternForm mode="create" />)
    const tagInput = screen.getByPlaceholderText(/add a tag and press enter/i)
    await userEvent.type(tagInput, 'cool-tag')
    fireEvent.click(screen.getByRole('button', { name: /^add$/i }))
    expect(screen.getByText('cool-tag')).toBeInTheDocument()
  })

  it('can remove a tag', async () => {
    render(<PatternForm mode="create" />)
    const tagInput = screen.getByPlaceholderText(/add a tag and press enter/i)
    await userEvent.type(tagInput, 'removable{Enter}')
    expect(screen.getByText('removable')).toBeInTheDocument()
    fireEvent.click(screen.getByRole('button', { name: /remove tag removable/i }))
    expect(screen.queryByText('removable')).not.toBeInTheDocument()
  })

  it('does not add duplicate tags', async () => {
    render(<PatternForm mode="create" />)
    const tagInput = screen.getByPlaceholderText(/add a tag and press enter/i)
    await userEvent.type(tagInput, 'duplicate{Enter}')
    await userEvent.type(tagInput, 'duplicate{Enter}')
    expect(screen.getAllByText('duplicate')).toHaveLength(1)
  })

  it('shows error when tag limit is exceeded', async () => {
    render(<PatternForm mode="create" />)
    const tagInput = screen.getByPlaceholderText(/add a tag and press enter/i)
    for (let i = 1; i <= 10; i++) {
      await userEvent.type(tagInput, `tag${i}{Enter}`)
    }
    await userEvent.type(tagInput, 'one-too-many{Enter}')
    expect(await screen.findByText(/maximum 10 tags allowed/i)).toBeInTheDocument()
  })

  it('calls createPattern with correct data on valid submit', async () => {
    const createdPattern = { ...mockPattern, id: 'new-id', slug: 'test-title' }
    mockCreatePattern.mockResolvedValueOnce(createdPattern)

    render(<PatternForm mode="create" />)
    await userEvent.type(screen.getByLabelText(/title \*/i), 'Test Title')
    await userEvent.type(
      screen.getByLabelText(/short description \*/i),
      'A test description'
    )
    fireEvent.click(screen.getByRole('button', { name: /create pattern/i }))

    await waitFor(() => {
      expect(mockCreatePattern).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Test Title',
          shortDescription: 'A test description',
          category: 'Architecture',
          tags: [],
        }),
        'test-token'
      )
    })
  })

  it('shows success toast and redirects after create', async () => {
    const createdPattern = { ...mockPattern, slug: 'test-title' }
    mockCreatePattern.mockResolvedValueOnce(createdPattern)

    render(<PatternForm mode="create" />)
    await userEvent.type(screen.getByLabelText(/title \*/i), 'Test Title')
    await userEvent.type(
      screen.getByLabelText(/short description \*/i),
      'A test description'
    )
    fireEvent.click(screen.getByRole('button', { name: /create pattern/i }))

    await waitFor(() => {
      expect(toast.success).toHaveBeenCalledWith('Pattern created successfully')
      expect(mockPush).toHaveBeenCalledWith('/patterns/test-title')
    })
  })

  it('shows error toast when createPattern fails', async () => {
    mockCreatePattern.mockRejectedValueOnce(new Error('Server error'))

    render(<PatternForm mode="create" />)
    await userEvent.type(screen.getByLabelText(/title \*/i), 'Test Title')
    await userEvent.type(
      screen.getByLabelText(/short description \*/i),
      'A test description'
    )
    fireEvent.click(screen.getByRole('button', { name: /create pattern/i }))

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith('Server error')
    })
  })

  it('calls router.back when Cancel is clicked', () => {
    render(<PatternForm mode="create" />)
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }))
    expect(mockBack).toHaveBeenCalled()
  })

  it('does not show admin settings in create mode', () => {
    ;(useSession as jest.Mock).mockReturnValue(adminSession)
    render(<PatternForm mode="create" />)
    expect(screen.queryByText('Admin Settings')).not.toBeInTheDocument()
  })
})

describe('PatternForm — edit mode', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    ;(useSession as jest.Mock).mockReturnValue(editorSession)
  })

  it('renders the form with edit heading', () => {
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.getByText('Edit Pattern')).toBeInTheDocument()
  })

  it('renders Save Changes submit button', () => {
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.getByRole('button', { name: /save changes/i })).toBeInTheDocument()
  })

  it('pre-fills form fields with initialData', () => {
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.getByLabelText(/title \*/i)).toHaveValue('CQRS Pattern')
    expect(screen.getByLabelText(/short description \*/i)).toHaveValue(
      'A command/query separation pattern'
    )
    expect(screen.getByLabelText(/author/i)).toHaveValue('Jane Doe')
  })

  it('pre-fills existing tags', () => {
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.getByText('cqrs')).toBeInTheDocument()
    expect(screen.getByText('event-sourcing')).toBeInTheDocument()
  })

  it('calls updatePattern with correct data on valid submit', async () => {
    const updatedPattern = { ...mockPattern, title: 'CQRS Pattern Updated' }
    mockUpdatePattern.mockResolvedValueOnce(updatedPattern)

    render(<PatternForm mode="edit" initialData={mockPattern} />)
    fireEvent.click(screen.getByRole('button', { name: /save changes/i }))

    await waitFor(() => {
      expect(mockUpdatePattern).toHaveBeenCalledWith(
        'pattern-id-1',
        expect.objectContaining({
          title: 'CQRS Pattern',
          shortDescription: 'A command/query separation pattern',
        }),
        'test-token'
      )
    })
  })

  it('shows success toast and redirects after update', async () => {
    const updatedPattern = { ...mockPattern, slug: 'cqrs-pattern' }
    mockUpdatePattern.mockResolvedValueOnce(updatedPattern)

    render(<PatternForm mode="edit" initialData={mockPattern} />)
    fireEvent.click(screen.getByRole('button', { name: /save changes/i }))

    await waitFor(() => {
      expect(toast.success).toHaveBeenCalledWith('Pattern updated successfully')
      expect(mockPush).toHaveBeenCalledWith('/patterns/cqrs-pattern')
    })
  })

  it('shows admin settings for admin users in edit mode', () => {
    ;(useSession as jest.Mock).mockReturnValue(adminSession)
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.getByText('Admin Settings')).toBeInTheDocument()
    expect(screen.getByLabelText(/featured pattern/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/trending pattern/i)).toBeInTheDocument()
  })

  it('does not show admin settings for non-admin editors', () => {
    render(<PatternForm mode="edit" initialData={mockPattern} />)
    expect(screen.queryByText('Admin Settings')).not.toBeInTheDocument()
  })

  it('reflects isFeatured initial state in checkbox', () => {
    ;(useSession as jest.Mock).mockReturnValue(adminSession)
    render(
      <PatternForm
        mode="edit"
        initialData={{ ...mockPattern, isFeatured: true }}
      />
    )
    const featuredCheckbox = screen.getByLabelText(/featured pattern/i)
    expect(featuredCheckbox).toBeChecked()
  })
})
