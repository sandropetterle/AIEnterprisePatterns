import { render, screen } from '@testing-library/react'
import { Breadcrumb } from '../Breadcrumb'

jest.mock('next/link', () => {
  return function MockLink({ children, href }: { children: React.ReactNode; href: string }) {
    return <a href={href}>{children}</a>
  }
})

describe('Breadcrumb', () => {
  const items = [
    { label: 'Home', href: '/' },
    { label: 'Patterns', href: '/patterns' },
    { label: 'Chain of Thought', href: '/patterns/chain-of-thought' },
  ]

  it('renders navigation landmark', () => {
    render(<Breadcrumb items={items} />)
    expect(screen.getByRole('navigation', { name: /breadcrumb/i })).toBeInTheDocument()
  })

  it('renders all items', () => {
    render(<Breadcrumb items={items} />)
    expect(screen.getByText('Home')).toBeInTheDocument()
    expect(screen.getByText('Patterns')).toBeInTheDocument()
    expect(screen.getByText('Chain of Thought')).toBeInTheDocument()
  })

  it('renders non-last items as links', () => {
    render(<Breadcrumb items={items} />)
    expect(screen.getByRole('link', { name: 'Home' })).toHaveAttribute('href', '/')
    expect(screen.getByRole('link', { name: 'Patterns' })).toHaveAttribute('href', '/patterns')
  })

  it('renders last item as plain text, not a link', () => {
    render(<Breadcrumb items={items} />)
    expect(screen.queryByRole('link', { name: 'Chain of Thought' })).not.toBeInTheDocument()
    expect(screen.getByText('Chain of Thought')).toBeInTheDocument()
  })

  it('renders single item as plain text', () => {
    render(<Breadcrumb items={[{ label: 'Home', href: '/' }]} />)
    expect(screen.queryByRole('link', { name: 'Home' })).not.toBeInTheDocument()
    expect(screen.getByText('Home')).toBeInTheDocument()
  })

  it('renders empty list without crashing', () => {
    const { container } = render(<Breadcrumb items={[]} />)
    expect(container.querySelector('ol')).toBeInTheDocument()
  })
})
