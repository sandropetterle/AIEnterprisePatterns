import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Header } from '@/components/layout/Header'
import { Footer } from '@/components/layout/Footer'
import { SessionProvider } from '@/components/providers/SessionProvider'
import { Toaster } from 'sonner'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'AI Enterprise Patterns Library',
    template: '%s | AI Enterprise Patterns',
  },
  description: 'A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.',
  keywords: ['AI patterns', 'enterprise architecture', 'software patterns', 'AI prompts', 'best practices', 'design patterns'],
  authors: [{ name: 'AI Enterprise Patterns' }],
  creator: 'AI Enterprise Patterns',
  publisher: 'AI Enterprise Patterns',
  metadataBase: new URL('https://ai-patterns.example.com'),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://ai-patterns.example.com',
    siteName: 'AI Enterprise Patterns Library',
    title: 'AI Enterprise Patterns Library',
    description: 'Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'AI Enterprise Patterns Library',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'AI Enterprise Patterns Library',
    description: 'Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <SessionProvider>
          <a
            href="#main-content"
            className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-primary-foreground focus:rounded-md focus:ring-2 focus:ring-ring"
          >
            Skip to main content
          </a>
          <div className="flex min-h-screen flex-col">
            <Header />
            <main id="main-content" className="flex-1">{children}</main>
            <Footer />
            <Toaster position="bottom-right" />
          </div>
        </SessionProvider>
      </body>
    </html>
  )
}
