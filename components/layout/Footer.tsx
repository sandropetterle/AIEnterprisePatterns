import Link from 'next/link'
import { Github } from 'lucide-react'

export function Footer() {
  return (
    <footer className="border-t bg-muted/50">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="text-sm text-muted-foreground">
            © {new Date().getFullYear()} AI Enterprise Patterns. All rights reserved.
          </div>
          <div className="flex items-center gap-6">
            <Link
              href="https://github.com/sandropetterle/AIEnterprisePatterns"
              className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-2"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Github className="h-4 w-4" />
              GitHub
            </Link>
            <Link
              href="/docs"
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Documentation
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}
