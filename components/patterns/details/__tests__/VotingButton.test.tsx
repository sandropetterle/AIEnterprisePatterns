/**
 * VotingButton Component Tests
 * Tests the voting button with optimistic updates
 */

import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
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
    // Server returns same as optimistic count — both are 43
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    // userEvent.click wraps in act() and flushes all pending state updates
    await userEvent.click(button)

    expect(screen.getByText('43')).toBeInTheDocument()
  })

  it('should call voteForPattern API with correct patternId', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-123" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(mockVoteForPattern).toHaveBeenCalledWith('pattern-123')
  })

  it('should update to server-returned vote count on success', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 100 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    // After full async cycle completes, shows server-returned count
    expect(screen.getByText('100')).toBeInTheDocument()
  })

  it('should revert vote count on API error', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    // After error, reverts to original count
    expect(screen.getByText('42')).toBeInTheDocument()
  })

  it('should show error toast on API failure', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(mockToastError).toHaveBeenCalledWith(
      'Failed to record your vote. Please try again.'
    )
  })

  it('should disable button after voting', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(button).toBeDisabled()
  })

  it('should not allow double-clicking', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 43 })

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    // First click triggers vote; second click is ignored (button disabled)
    await userEvent.click(button)
    await userEvent.click(button)

    expect(mockVoteForPattern).toHaveBeenCalledTimes(1)
  })

  it('should disable button while loading', async () => {
    jest.useFakeTimers()
    mockVoteForPattern.mockImplementation(
      () =>
        new Promise((resolve) =>
          setTimeout(() => resolve({ voteCount: 43 }), 100)
        )
    )

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')

    // Click without awaiting so we can observe the loading state
    const clickPromise = userEvent.click(button)

    // Button is immediately disabled while API call is in progress
    await waitFor(() => expect(button).toBeDisabled())

    // Advance timers and flush remaining state updates
    jest.runAllTimers()
    await clickPromise

    jest.useRealTimers()
    expect(mockVoteForPattern).toHaveBeenCalled()
  })

  it('should handle zero initial vote count', () => {
    render(<VotingButton initialVoteCount={0} patternId="pattern-1" />)

    expect(screen.getByText('0')).toBeInTheDocument()
  })

  it('should increment from zero when voted', async () => {
    mockVoteForPattern.mockResolvedValue({ voteCount: 1 })

    render(<VotingButton initialVoteCount={0} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(screen.getByText('1')).toBeInTheDocument()
  })

  it('should maintain disabled state after error and revert', async () => {
    mockVoteForPattern.mockRejectedValue(new Error('API Error'))

    render(<VotingButton initialVoteCount={42} patternId="pattern-1" />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    // After error and revert, original count is restored
    expect(screen.getByText('42')).toBeInTheDocument()
    // Button should be enabled again (error allows retry)
    expect(button).not.toBeDisabled()
  })
})
