import { render, screen } from '@testing-library/react'
import { Logo } from '../Logo'

jest.mock('next/link', () => {
  return function MockLink({ children, href }: { children: React.ReactNode; href: string }) {
    return <a href={href}>{children}</a>
  }
})

describe('Logo', () => {
  it('renders the brand text', () => {
    render(<Logo />)
    expect(screen.getByText('AI Enterprise Patterns')).toBeInTheDocument()
  })

  it('links to the homepage', () => {
    render(<Logo />)
    const link = screen.getByRole('link')
    expect(link).toHaveAttribute('href', '/')
  })
})
