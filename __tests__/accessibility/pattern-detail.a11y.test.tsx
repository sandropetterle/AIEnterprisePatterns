import { render } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import { VotingButton } from '@/components/patterns/details/VotingButton'

expect.extend(toHaveNoViolations)

jest.mock('@/lib/api/patterns', () => ({
  voteForPattern: jest.fn(),
}))

jest.mock('@/components/ui/alert-dialog', () => ({
  AlertDialog: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogTrigger: ({ children, asChild }: { children: React.ReactNode; asChild?: boolean }) =>
    asChild ? <>{children}</> : <div>{children}</div>,
  AlertDialogContent: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogHeader: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogTitle: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogDescription: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogFooter: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  AlertDialogCancel: ({ children }: { children: React.ReactNode }) => <button>{children}</button>,
  AlertDialogAction: ({ children, onClick }: { children: React.ReactNode; onClick?: () => void }) => (
    <button onClick={onClick}>{children}</button>
  ),
}))

describe('Pattern Detail — Accessibility', () => {
  it('VotingButton has no axe violations (unvoted)', async () => {
    const { container } = render(
      <VotingButton initialVoteCount={42} patternId="pattern-1" />
    )
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
