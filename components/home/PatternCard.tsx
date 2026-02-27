import { memo } from 'react'
import Link from 'next/link'
import { ThumbsUp } from 'lucide-react'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Pattern } from '@/lib/types/pattern'

const MAX_DISPLAY_TAGS = 3
const MAX_DESCRIPTION_LENGTH = 120

type PatternCardProps = {
  pattern: Pattern
}

function PatternCardComponent({ pattern }: PatternCardProps) {
  const displayTags = pattern.tags.slice(0, MAX_DISPLAY_TAGS)
  const truncatedDescription = pattern.shortDescription.length > MAX_DESCRIPTION_LENGTH
    ? pattern.shortDescription.substring(0, MAX_DESCRIPTION_LENGTH) + '...'
    : pattern.shortDescription

  return (
    <Link
      href={`/patterns/${pattern.slug}`}
      className="block h-full"
      aria-label={`View pattern: ${pattern.title}`}
    >
      <Card className="h-full transition-all duration-200 hover:shadow-lg hover:border-primary/50 hover:-translate-y-0.5">
        <CardHeader>
          <div className="flex items-start justify-between gap-2 mb-2">
            <Badge variant="default" aria-label={`Category: ${pattern.category}`}>
              {pattern.category}
            </Badge>
          </div>
          <CardTitle className="text-xl line-clamp-2">{pattern.title}</CardTitle>
          <CardDescription className="line-clamp-3">
            {truncatedDescription}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2" aria-label="Tags">
            {displayTags.map((tag) => (
              <Badge key={tag} variant="secondary" className="text-xs">
                {tag}
              </Badge>
            ))}
          </div>
        </CardContent>
        <CardFooter className="flex items-center justify-between text-sm text-muted-foreground">
          <span
            className="flex items-center gap-1"
            aria-label={`${pattern.voteCount} votes`}
          >
            <ThumbsUp className="h-4 w-4" aria-hidden="true" />
            <span>{pattern.voteCount}</span>
          </span>
          {pattern.author && (
            <span className="truncate">by {pattern.author}</span>
          )}
        </CardFooter>
      </Card>
    </Link>
  )
}

export const PatternCard = memo(PatternCardComponent)
