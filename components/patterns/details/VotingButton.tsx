'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Heart } from 'lucide-react'

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

  const handleVote = () => {
    // Optimistic update
    setVoteCount((prev) => prev + 1)
    setHasVoted(true)

    // In Phase 3, this will call the backend API:
    // await fetch(`/api/patterns/${patternId}/vote`, { method: 'POST' })

    // Reset hasVoted after animation
    setTimeout(() => setHasVoted(false), 1000)
  }

  return (
    <Button
      onClick={handleVote}
      variant="outline"
      size="sm"
      className="gap-2"
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
