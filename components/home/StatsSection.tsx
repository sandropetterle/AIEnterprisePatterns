import { BookOpen, Folder, Users } from 'lucide-react'

type StatsSectionProps = {
  totalPatterns: number
  totalCategories: number
  totalContributors: string
}

export function StatsSection({ totalPatterns, totalCategories, totalContributors }: StatsSectionProps) {
  return (
    <section className="py-16 sm:py-20 lg:py-24">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="flex flex-col items-center text-center p-6 rounded-lg bg-card border">
            <div className="mb-4 p-3 rounded-full bg-primary/10">
              <BookOpen className="h-8 w-8 text-primary" />
            </div>
            <div className="text-4xl font-bold mb-2">{totalPatterns}</div>
            <div className="text-muted-foreground">Patterns Available</div>
          </div>
          <div className="flex flex-col items-center text-center p-6 rounded-lg bg-card border">
            <div className="mb-4 p-3 rounded-full bg-primary/10">
              <Folder className="h-8 w-8 text-primary" />
            </div>
            <div className="text-4xl font-bold mb-2">{totalCategories}</div>
            <div className="text-muted-foreground">Categories</div>
          </div>
          <div className="flex flex-col items-center text-center p-6 rounded-lg bg-card border">
            <div className="mb-4 p-3 rounded-full bg-primary/10">
              <Users className="h-8 w-8 text-primary" />
            </div>
            <div className="text-4xl font-bold mb-2">{totalContributors}</div>
            <div className="text-muted-foreground">Contributors</div>
          </div>
        </div>
      </div>
    </section>
  )
}
