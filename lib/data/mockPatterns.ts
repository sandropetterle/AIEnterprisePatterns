import { Pattern } from '@/lib/types/pattern'

export const mockPatterns: Pattern[] = [
  {
    id: '1',
    title: 'Clean Architecture with AI-Assisted Refactoring',
    slug: 'clean-architecture-ai-refactoring',
    shortDescription: 'Learn how to leverage AI tools to refactor legacy code into clean architecture patterns, including layered separation and dependency injection.',
    category: 'Architecture',
    tags: ['Clean Architecture', 'Refactoring', 'AI-Assisted'],
    author: 'John Doe',
    createdDate: '2024-01-15T10:00:00Z',
    updatedDate: '2024-01-20T14:30:00Z',
    voteCount: 42,
    status: 'published',
    isFeatured: true,
  },
  {
    id: '2',
    title: 'Repository Pattern with Entity Framework Core',
    slug: 'repository-pattern-ef-core',
    shortDescription: 'Implement the Repository pattern using EF Core with best practices for unit testing, async operations, and generic repositories.',
    category: 'Design Patterns',
    tags: ['Repository', 'EF Core', 'Testing'],
    author: 'Jane Smith',
    createdDate: '2024-01-18T09:00:00Z',
    updatedDate: '2024-01-18T09:00:00Z',
    voteCount: 38,
    status: 'published',
    isTrending: true,
  },
  {
    id: '3',
    title: 'AI Prompt Engineering for Code Review',
    slug: 'ai-prompt-code-review',
    shortDescription: 'Curated prompts for AI-assisted code reviews covering SOLID principles, security vulnerabilities, and performance optimization.',
    category: 'AI Prompts',
    tags: ['Code Review', 'Prompts', 'SOLID'],
    author: 'Alice Johnson',
    createdDate: '2024-01-22T11:00:00Z',
    updatedDate: '2024-01-25T16:45:00Z',
    voteCount: 56,
    status: 'published',
    isFeatured: true,
    isTrending: true,
  },
  {
    id: '4',
    title: 'CQRS Pattern Implementation Guide',
    slug: 'cqrs-pattern-implementation',
    shortDescription: 'Complete guide to implementing Command Query Responsibility Segregation in .NET applications with MediatR and event sourcing.',
    category: 'Architecture',
    tags: ['CQRS', 'MediatR', 'Event Sourcing'],
    author: 'Bob Williams',
    createdDate: '2024-01-10T08:00:00Z',
    updatedDate: '2024-01-10T08:00:00Z',
    voteCount: 34,
    status: 'published',
    isFeatured: true,
  },
  {
    id: '5',
    title: 'Microservices Security Best Practices',
    slug: 'microservices-security-practices',
    shortDescription: 'Essential security patterns for microservices including service-to-service authentication, API gateway security, and secret management.',
    category: 'Security',
    tags: ['Microservices', 'Security', 'API Gateway'],
    author: 'Carol Davis',
    createdDate: '2024-01-12T13:00:00Z',
    updatedDate: '2024-01-16T10:20:00Z',
    voteCount: 29,
    status: 'published',
    isTrending: true,
  },
  {
    id: '6',
    title: 'Performance Optimization with AI Analysis',
    slug: 'performance-optimization-ai',
    shortDescription: 'Use AI tools to identify performance bottlenecks, optimize database queries, and improve application response times.',
    category: 'Performance',
    tags: ['Performance', 'Optimization', 'AI Tools'],
    author: 'David Lee',
    createdDate: '2024-01-20T15:00:00Z',
    updatedDate: '2024-01-20T15:00:00Z',
    voteCount: 23,
    status: 'published',
  },
]

export function getFeaturedPatterns(): Pattern[] {
  return mockPatterns.filter(p => p.isFeatured && p.status === 'published')
}

export function getTrendingPatterns(): Pattern[] {
  return mockPatterns.filter(p => p.isTrending && p.status === 'published')
}

export function getAllCategories(): string[] {
  return Array.from(new Set(mockPatterns.map(p => p.category)))
}

export function getPatternStats() {
  return {
    totalPatterns: mockPatterns.filter(p => p.status === 'published').length,
    totalCategories: getAllCategories().length,
    totalContributors: '15+',
  }
}
