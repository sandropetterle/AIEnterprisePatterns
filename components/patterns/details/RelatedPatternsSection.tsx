import Link from 'next/link'
import { Pattern } from '@/lib/types/pattern'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Heart } from 'lucide-react'

type RelatedPatternsSectionProps = {
  patterns: Pattern[]
}

export function RelatedPatternsSection({
  patterns,
}: RelatedPatternsSectionProps) {
  if (patterns.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Related Patterns</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            No related patterns found
          </p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">Related Patterns</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {patterns.map((pattern) => (
          <Link
            key={pattern.id}
            href={`/patterns/${pattern.slug}`}
            className="block group"
          >
            <div className="space-y-2">
              <h4 className="font-medium leading-tight group-hover:text-primary transition-colors">
                {pattern.title}
              </h4>
              <div className="flex items-center gap-2">
                <Badge variant="secondary" className="text-xs">
                  {pattern.category}
                </Badge>
                <div className="flex items-center gap-1 text-xs text-muted-foreground">
                  <Heart className="h-3 w-3" />
                  <span>{pattern.voteCount}</span>
                </div>
              </div>
            </div>
          </Link>
        ))}
      </CardContent>
    </Card>
  )
}
