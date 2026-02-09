import Link from 'next/link'
import { Logo } from '@/components/shared/Logo'
import { Navigation } from '@/components/layout/Navigation'

export function Header() {
  return (
    <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 flex h-16 items-center justify-between">
        <div className="flex items-center gap-6">
          <Navigation />
          <Logo />
        </div>
        <nav className="hidden md:flex items-center gap-6">
          <Link
            href="/"
            className="text-sm font-medium hover:text-primary transition-colors"
          >
            Home
          </Link>
          <Link
            href="/patterns"
            className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors"
          >
            Patterns
          </Link>
          <Link
            href="/about"
            className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors"
          >
            About
          </Link>
        </nav>
      </div>
    </header>
  )
}
