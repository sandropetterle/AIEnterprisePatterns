import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Github, ArrowRight } from 'lucide-react'

export function CTASection() {
  return (
    <section className="py-16 sm:py-20 lg:py-24 bg-primary text-primary-foreground">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
            Ready to explore enterprise patterns?
          </h2>
          <p className="mt-4 text-lg text-primary-foreground/90">
            Join our community and discover proven solutions for your next project.
            Contribute your own patterns and help others build better software.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button asChild size="lg" variant="secondary">
              <Link href="/patterns">
                Get Started
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="bg-transparent border-primary-foreground text-primary-foreground hover:bg-primary-foreground/10">
              <Link href="https://github.com/sandropetterle/AIEnterprisePatterns" target="_blank" rel="noopener noreferrer">
                <Github className="mr-2 h-4 w-4" />
                Star on GitHub
              </Link>
            </Button>
          </div>
        </div>
      </div>
    </section>
  )
}
