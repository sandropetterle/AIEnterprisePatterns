'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Heart } from 'lucide-react'
import { voteForPattern } from '@/lib/api/patterns'

type VotingButtonProps = {
  initialVoteCount: number
  patternId: string
}

export function VotingButton({
  initialVoteCount,
  patternId,
}: VotingButtonProps) {
  const [voteCount, setVoteCount] = useState(initialVoteCount)
  const [hasVoted, setHasVoted] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleVote = async () => {
    if (isLoading || hasVoted) return

    // Optimistic update
    setVoteCount((prev) => prev + 1)
    setHasVoted(true)
    setIsLoading(true)

    try {
      const response = await voteForPattern(patternId)
      setVoteCount(response.voteCount) // Use actual count from backend
    } catch (error) {
      // Revert on error
      setVoteCount((prev) => prev - 1)
      setHasVoted(false)
      console.error('Failed to vote:', error)
      // TODO: Add toast notification for error feedback
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <Button
      onClick={handleVote}
      variant="outline"
      size="sm"
      className="gap-2"
      disabled={isLoading || hasVoted}
    >
      <Heart
        className={`h-4 w-4 transition-all ${
          hasVoted ? 'fill-red-500 text-red-500 scale-125' : ''
        }`}
      />
      <span className="font-medium">{voteCount}</span>
      <span className="text-muted-foreground">votes</span>
    </Button>
  )
}
