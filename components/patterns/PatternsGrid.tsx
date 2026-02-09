import { Pattern } from '@/lib/types/pattern'
import { PatternCard } from '@/components/home/PatternCard'

type PatternsGridProps = {
  patterns: Pattern[]
}

export function PatternsGrid({ patterns }: PatternsGridProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {patterns.map((pattern) => (
        <PatternCard key={pattern.id} pattern={pattern} />
      ))}
    </div>
  )
}
