import Link from 'next/link'
import { ThumbsUp } from 'lucide-react'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Pattern } from '@/lib/types/pattern'

type PatternCardProps = {
  pattern: Pattern
}

export function PatternCard({ pattern }: PatternCardProps) {
  const displayTags = pattern.tags.slice(0, 3)
  const truncatedDescription = pattern.shortDescription.length > 120
    ? pattern.shortDescription.substring(0, 120) + '...'
    : pattern.shortDescription

  return (
    <Link href={`/patterns/${pattern.slug}`} className="block h-full">
      <Card className="h-full transition-all hover:shadow-lg hover:border-primary/50">
        <CardHeader>
          <div className="flex items-start justify-between gap-2 mb-2">
            <Badge variant="default">{pattern.category}</Badge>
          </div>
          <CardTitle className="text-xl line-clamp-2">{pattern.title}</CardTitle>
          <CardDescription className="line-clamp-3">
            {truncatedDescription}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {displayTags.map((tag) => (
              <Badge key={tag} variant="secondary" className="text-xs">
                {tag}
              </Badge>
            ))}
          </div>
        </CardContent>
        <CardFooter className="flex items-center justify-between text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <ThumbsUp className="h-4 w-4" />
            <span>{pattern.voteCount}</span>
          </div>
          {pattern.author && (
            <span className="truncate">by {pattern.author}</span>
          )}
        </CardFooter>
      </Card>
    </Link>
  )
}
