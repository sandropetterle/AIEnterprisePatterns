/**
 * VotingButton Component Tests
 * Tests the voting button with optimistic updates
 */

import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { VotingButton } from '../VotingButton'

// Mock the voteForPattern API
jest.mock('@/lib/api/patterns', () => ({
  voteForPattern: jest.fn(),
}))

// Mock sonner toast
jest.mock('sonner', () => ({
  toast: {
    error: jest.fn(),
  },
}))

import { voteForPattern } from '@/lib/api/patterns'
import { toast } from 'sonner'

const mockVoteForPattern = voteForPattern as jest.MockedFunction<
  typeof voteForPattern
>
const mockToastError = toast.error as jest.MockedFunction<typeof toast.error>

describe('VotingButton', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render initial vote count', () => {
    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    expect(screen.getByText('42')).toBeInTheDocument()
  })

  it('should render votes text', () => {
    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    expect(screen.getByText('votes')).toBeInTheDocument()
  })

  it('should render heart icon', () => {
    const { container } = render(
      <VotingButton initialVoteCount={42} patternId="pattern-1" />
    )

    const heartIcon = container.querySelector('svg')
    expect(heartIcon).toBeInTheDocument()
  })

  it('should increment vote count optimistically on click', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    // Should immediately show incremented count
    expect(screen.getByText('43')).toBeInTheDocument()
  })

  it('should call voteForPattern API with correct patternId', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-123" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    await waitFor(() => {
      expect(mockVoteForPattern).toHaveBeenCalledWith('pattern-123')
    })
  })

  it('should update to server-returned vote count on success', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 100 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    // First shows optimistic update
    expect(screen.getByText('43')).toBeInTheDocument()

    // Then updates to server value
    await waitFor(() => {
      expect(screen.getByText('100')).toBeInTheDocument()
    })
  })

  it('should revert vote count on API error', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    // First shows optimistic update
    expect(screen.getByText('43')).toBeInTheDocument()

    // Then reverts to original on error
    await waitFor(() => {
      expect(screen.getByText('42')).toBeInTheDocument()
    })
  })

  it('should show error toast on API failure', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    await waitFor(() => {
      expect(mockToastError).toHaveBeenCalledWith(
        'Failed to record your vote. Please try again.'
      )
    })
  })

  it('should disable button after voting', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    await waitFor(() => {
      expect(button).toBeDisabled()
    })
  })

  it('should not allow double-clicking', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)
    fireEvent.click(button)

    await waitFor(() => {
      // Should only be called once
      expect(mockVoteForPattern).toHaveBeenCalledTimes(1)
    })
  })

  it('should disable button while loading', async () => {
    mockVoteForPattern.mockImplementation(
      () =>
        new Promise((resolve) =>
          setTimeout(() => resolve({ voteCount: 43 }), 100)
        )
    )

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    // Button should be disabled while API call is in progress
    expect(button).toBeDisabled()

    await waitFor(() => {
      // May still be disabled after vote completes (hasVoted state)
      expect(mockVoteForPattern).toHaveBeenCalled()
    })
  })

  it('should handle zero initial vote count', () => {
    render(<VotingButton initialVoteCount={0} patternId="pattern-1" />)

    expect(screen.getByText('0')).toBeInTheDocument()
  })

  it('should increment from zero when voted', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 1 })

    render(<VotingButton initialVoteCount={0} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    expect(screen.getByText('1')).toBeInTheDocument()
  })

  it('should maintain disabled state after error and revert', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    fireEvent.click(button)

    await waitFor(() => {
      expect(screen.getByText('42')).toBeInTheDocument()
    })

    // After error and revert, button should be enabled again
    expect(button).not.toBeDisabled()
  })
})
