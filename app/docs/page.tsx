import { Metadata } from 'next'
import Link from 'next/link'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  BookOpen,
  Code2,
  Search,
  Filter,
  ThumbsUp,
  Share2,
  FileCode,
  GitBranch,
  ExternalLink,
  Layers,
  Tag,
  ArrowRight,
} from 'lucide-react'

export const metadata: Metadata = {
  title: 'Documentation | AI Enterprise Patterns',
  description:
    'Complete documentation for the AI Enterprise Patterns Library. Learn how to use the platform, search patterns, integrate the API, and contribute to the community.',
  keywords: [
    'documentation',
    'user guide',
    'API docs',
    'contribution guide',
    'AI patterns',
    'how to use',
  ],
  openGraph: {
    title: 'Documentation | AI Enterprise Patterns',
    description:
      'Complete guide to using and contributing to the AI Enterprise Patterns Library.',
    url: 'https://ai-patterns.example.com/docs',
  },
}

export default function DocsPage() {
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
      {/* Header */}
      <div className="max-w-3xl mx-auto text-center mb-16">
        <Badge className="mb-4">Documentation</Badge>
        <h1 className="text-4xl sm:text-5xl font-bold tracking-tight mb-6">
          Platform Documentation
        </h1>
        <p className="text-xl text-muted-foreground">
          Everything you need to know about using and contributing to the AI Enterprise Patterns
          Library
        </p>
      </div>

      {/* Quick Links */}
      <div className="max-w-5xl mx-auto mb-16">
        <h2 className="text-2xl font-bold mb-6">Quick Navigation</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <Link href="#getting-started">
            <Card className="hover:bg-accent transition-colors cursor-pointer h-full">
              <CardHeader>
                <BookOpen className="h-6 w-6 text-primary mb-2" />
                <CardTitle className="text-lg">Getting Started</CardTitle>
                <CardDescription>Learn the basics</CardDescription>
              </CardHeader>
            </Card>
          </Link>
          <Link href="#browsing-patterns">
            <Card className="hover:bg-accent transition-colors cursor-pointer h-full">
              <CardHeader>
                <Search className="h-6 w-6 text-primary mb-2" />
                <CardTitle className="text-lg">Browsing Patterns</CardTitle>
                <CardDescription>Search and filter</CardDescription>
              </CardHeader>
            </Card>
          </Link>
          <Link href="#api-reference">
            <Card className="hover:bg-accent transition-colors cursor-pointer h-full">
              <CardHeader>
                <Code2 className="h-6 w-6 text-primary mb-2" />
                <CardTitle className="text-lg">API Reference</CardTitle>
                <CardDescription>Integrate our API</CardDescription>
              </CardHeader>
            </Card>
          </Link>
        </div>
      </div>

      {/* Getting Started */}
      <div id="getting-started" className="max-w-5xl mx-auto mb-16">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-3 text-2xl">
              <BookOpen className="h-7 w-7 text-primary" />
              Getting Started
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-3">What is AI Enterprise Patterns?</h3>
              <p className="text-muted-foreground mb-4">
                AI Enterprise Patterns is a curated collection of implementation patterns, AI
                prompts, and architectural blueprints for modern enterprise software development.
                Each pattern includes:
              </p>
              <ul className="space-y-2 text-muted-foreground ml-6">
                <li>• Detailed problem statement and context</li>
                <li>• Proposed solution with step-by-step implementation</li>
                <li>• Real-world code examples</li>
                <li>• AI prompt examples for assisted development</li>
                <li>• Trade-offs and considerations</li>
                <li>• Related patterns and further reading</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3">Pattern Categories</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <Layers className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">Architecture</h4>
                    <p className="text-sm text-muted-foreground">
                      High-level architectural patterns and system design strategies
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <Code2 className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">Design Patterns</h4>
                    <p className="text-sm text-muted-foreground">
                      Implementation patterns for common software problems
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <FileCode className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">AI Prompts</h4>
                    <p className="text-sm text-muted-foreground">
                      Curated prompts for AI-assisted coding and code reviews
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <Tag className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">Best Practices</h4>
                    <p className="text-sm text-muted-foreground">
                      Industry standards for security, performance, and quality
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <Share2 className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">Code Generation</h4>
                    <p className="text-sm text-muted-foreground">
                      Patterns for AI-assisted code generation and scaffolding
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <ThumbsUp className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium mb-1">Testing</h4>
                    <p className="text-sm text-muted-foreground">
                      Testing strategies, patterns, and AI-assisted test generation
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Browsing Patterns */}
      <div id="browsing-patterns" className="max-w-5xl mx-auto mb-16">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-3 text-2xl">
              <Search className="h-7 w-7 text-primary" />
              Browsing and Searching Patterns
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                <Search className="h-5 w-5" />
                Search Functionality
              </h3>
              <p className="text-muted-foreground mb-4">
                Use the search bar to find patterns by title or description. The search is
                real-time and case-insensitive.
              </p>
              <div className="bg-muted p-4 rounded-lg">
                <p className="text-sm font-mono">
                  Example: Search for "repository" to find repository pattern implementations
                </p>
              </div>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                <Filter className="h-5 w-5" />
                Filtering
              </h3>
              <p className="text-muted-foreground mb-4">
                Filter patterns by category to narrow down results:
              </p>
              <ul className="space-y-2 text-muted-foreground ml-6">
                <li>• Click a category badge to filter by that category</li>
                <li>• Use the "All" button to show all patterns</li>
                <li>• Combine filters with search for precise results</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                <ArrowRight className="h-5 w-5" />
                Sorting
              </h3>
              <p className="text-muted-foreground mb-4">Sort patterns by:</p>
              <ul className="space-y-2 text-muted-foreground ml-6">
                <li>• <strong>Most Voted:</strong> Patterns with the highest community votes</li>
                <li>• <strong>Newest:</strong> Recently added patterns (default)</li>
                <li>
                  • <strong>Recently Updated:</strong> Patterns with recent modifications
                </li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                <ThumbsUp className="h-5 w-5" />
                Voting
              </h3>
              <p className="text-muted-foreground">
                Vote for patterns you find useful to help others discover valuable content. Your
                votes help surface the most helpful patterns to the community.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* API Reference */}
      <div id="api-reference" className="max-w-5xl mx-auto mb-16">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-3 text-2xl">
              <Code2 className="h-7 w-7 text-primary" />
              API Reference
            </CardTitle>
            <CardDescription>
              Integrate the AI Enterprise Patterns API into your applications
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-3">Base URL</h3>
              <div className="bg-muted p-4 rounded-lg">
                <code className="text-sm">https://ai-patterns.example.com/api</code>
              </div>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3">Endpoints</h3>
              <div className="space-y-4">
                {/* GET /patterns */}
                <div className="border rounded-lg p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline">GET</Badge>
                    <code className="text-sm">/patterns</code>
                  </div>
                  <p className="text-sm text-muted-foreground mb-3">
                    Retrieve paginated list of patterns with optional filtering and sorting
                  </p>
                  <details className="text-sm">
                    <summary className="cursor-pointer font-medium mb-2">
                      Query Parameters
                    </summary>
                    <div className="bg-muted p-3 rounded">
                      <pre className="text-xs">
                        {`?page=1              // Page number (default: 1)
&pageSize=9          // Items per page (default: 9)
&sortBy=recent       // Sort: recent|votes|alphabetical
&category=Architecture // Filter by category
&tags=CQRS,Testing   // Filter by tags (comma-separated)
&search=repository   // Search query`}
                      </pre>
                    </div>
                  </details>
                </div>

                {/* GET /patterns/featured */}
                <div className="border rounded-lg p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline">GET</Badge>
                    <code className="text-sm">/patterns/featured</code>
                  </div>
                  <p className="text-sm text-muted-foreground">Get all featured patterns</p>
                </div>

                {/* GET /patterns/trending */}
                <div className="border rounded-lg p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline">GET</Badge>
                    <code className="text-sm">/patterns/trending</code>
                  </div>
                  <p className="text-sm text-muted-foreground">Get all trending patterns</p>
                </div>

                {/* GET /patterns/:slug */}
                <div className="border rounded-lg p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline">GET</Badge>
                    <code className="text-sm">/patterns/:slug</code>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Get detailed information about a specific pattern
                  </p>
                </div>

                {/* POST /patterns/:id/vote */}
                <div className="border rounded-lg p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline" className="bg-blue-500/10 text-blue-600">
                      POST
                    </Badge>
                    <code className="text-sm">/patterns/:id/vote</code>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Increment vote count for a pattern
                  </p>
                </div>
              </div>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3">Example Request</h3>
              <div className="bg-muted p-4 rounded-lg">
                <pre className="text-sm overflow-x-auto">
                  {`fetch('https://ai-patterns.example.com/api/patterns?page=1&pageSize=10')
  .then(response => response.json())
  .then(data => console.log(data));`}
                </pre>
              </div>
            </div>

            <div className="flex items-start gap-3 p-4 bg-blue-500/10 rounded-lg border border-blue-500/20">
              <ExternalLink className="h-5 w-5 text-blue-600 mt-0.5 flex-shrink-0" />
              <div>
                <h4 className="font-medium mb-1">Swagger Documentation</h4>
                <p className="text-sm text-muted-foreground mb-2">
                  For complete API documentation with interactive testing, visit our Swagger UI:
                </p>
                <Link
                  href="http://localhost:5255/swagger"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-blue-600 hover:underline inline-flex items-center gap-1"
                >
                  Open Swagger UI
                  <ExternalLink className="h-3 w-3" />
                </Link>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Contributing */}
      <div id="contributing" className="max-w-5xl mx-auto mb-16">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-3 text-2xl">
              <GitBranch className="h-7 w-7 text-primary" />
              Contributing
            </CardTitle>
            <CardDescription>
              Help us improve the AI Enterprise Patterns Library
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-3">How to Contribute</h3>
              <p className="text-muted-foreground mb-4">
                We welcome contributions from the community! Here's how you can help:
              </p>
              <ul className="space-y-3 text-muted-foreground">
                <li className="flex items-start gap-2">
                  <span className="text-primary font-bold">1.</span>
                  <span>
                    <strong>Submit New Patterns:</strong> Share your proven patterns and best
                    practices
                  </span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-primary font-bold">2.</span>
                  <span>
                    <strong>Improve Existing Patterns:</strong> Enhance documentation, add
                    examples, or fix issues
                  </span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-primary font-bold">3.</span>
                  <span>
                    <strong>Report Issues:</strong> Found a bug or have a suggestion? Let us know
                  </span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-primary font-bold">4.</span>
                  <span>
                    <strong>Vote and Engage:</strong> Help surface the best content by voting on
                    patterns
                  </span>
                </li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3">Contribution Guidelines</h3>
              <ul className="space-y-2 text-muted-foreground ml-6">
                <li>• Patterns should be production-tested and proven</li>
                <li>• Include clear problem statements and solutions</li>
                <li>• Provide working code examples where applicable</li>
                <li>• Follow the existing pattern template structure</li>
                <li>• Use clear, professional language</li>
                <li>• Include relevant tags for discoverability</li>
              </ul>
            </div>

            <div className="pt-4">
              <Link
                href="https://github.com/sandropetterle/AIEnterprisePatterns"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 px-6 py-3 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors font-medium"
              >
                <GitBranch className="h-4 w-4" />
                Contribute on GitHub
                <ExternalLink className="h-4 w-4" />
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Support */}
      <div className="max-w-5xl mx-auto">
        <Card className="bg-primary/5 border-primary/20">
          <CardHeader>
            <CardTitle className="text-xl">Need Help?</CardTitle>
            <CardDescription>
              Can't find what you're looking for? Here are some helpful resources:
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Link
                href="/about"
                className="flex items-center gap-3 p-3 rounded-lg border hover:bg-accent transition-colors"
              >
                <BookOpen className="h-5 w-5 text-primary" />
                <div>
                  <div className="font-medium">About the Platform</div>
                  <div className="text-sm text-muted-foreground">Learn about our mission</div>
                </div>
              </Link>
              <Link
                href="https://github.com/sandropetterle/AIEnterprisePatterns/issues"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 p-3 rounded-lg border hover:bg-accent transition-colors"
              >
                <GitBranch className="h-5 w-5 text-primary" />
                <div>
                  <div className="font-medium">GitHub Issues</div>
                  <div className="text-sm text-muted-foreground">Report bugs or request features</div>
                </div>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
