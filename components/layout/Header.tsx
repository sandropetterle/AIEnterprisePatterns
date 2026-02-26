import Link from 'next/link'
import { Logo } from '@/components/shared/Logo'
import { Navigation } from '@/components/layout/Navigation'
import { UserMenu } from '@/components/layout/UserMenu'
import type { CmsNavLink } from '@/lib/cms/types'

type HeaderProps = {
  navLinks?: CmsNavLink[]
  mobileMenuTitle?: string
  signInLabel?: string
  signOutLabel?: string
  userMenuLabel?: string
  newPatternButtonLabel?: string
}

const DEFAULT_NAV: CmsNavLink[] = [
  { href: '/', label: 'Home' },
  { href: '/patterns', label: 'Patterns' },
  { href: '/about', label: 'About' },
]

export function Header({
  navLinks = DEFAULT_NAV,
  mobileMenuTitle = 'Menu',
  signInLabel = 'Sign In',
  signOutLabel = 'Sign Out',
  userMenuLabel = 'User menu',
  newPatternButtonLabel = '+ New Pattern',
}: HeaderProps) {
  return (
    <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 flex h-16 items-center justify-between">
        <div className="flex items-center gap-6">
          <Navigation navLinks={navLinks} mobileMenuTitle={mobileMenuTitle} />
          <Logo />
        </div>
        <nav className="hidden md:flex items-center gap-6">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors first:text-foreground"
              target={link.isExternal ? '_blank' : undefined}
              rel={link.isExternal ? 'noopener noreferrer' : undefined}
            >
              {link.label}
            </Link>
          ))}
          <UserMenu
            signInLabel={signInLabel}
            signOutLabel={signOutLabel}
            userMenuLabel={userMenuLabel}
            newPatternButtonLabel={newPatternButtonLabel}
          />
        </nav>
      </div>
    </header>
  )
}
