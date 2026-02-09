export type PatternStatus = 'draft' | 'published'

export type PatternCategory =
  | 'Architecture'
  | 'Design Patterns'
  | 'AI Prompts'
  | 'Best Practices'
  | 'Code Generation'
  | 'Testing'
  | 'Security'
  | 'Performance'

export type Pattern = {
  id: string
  title: string
  slug: string
  shortDescription: string
  fullContent?: string
  category: PatternCategory
  tags: string[]
  author?: string
  createdDate: string
  updatedDate: string
  voteCount: number
  status: PatternStatus
  isFeatured?: boolean
  isTrending?: boolean
}

export type PatternListItem = Omit<Pattern, 'fullContent'>
