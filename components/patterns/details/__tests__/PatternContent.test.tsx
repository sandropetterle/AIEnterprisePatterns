// react-markdown and its plugins use ESM, so mock them for Jest compatibility
jest.mock('react-markdown', () => {
  return function ReactMarkdown({ children }: { children: string }) {
    return <div data-testid="markdown-content">{children}</div>
  }
})
jest.mock('remark-gfm', () => () => ({}))
jest.mock('rehype-sanitize', () => () => ({}))

import { render, screen } from '@testing-library/react'
import { PatternContent } from '../PatternContent'

describe('PatternContent', () => {
  it('renders the content inside the prose wrapper', () => {
    render(<PatternContent content="Hello world" />)
    expect(screen.getByTestId('markdown-content')).toBeInTheDocument()
  })

  it('passes content string to ReactMarkdown', () => {
    render(<PatternContent content="# My Heading" />)
    expect(screen.getByText('# My Heading')).toBeInTheDocument()
  })

  it('renders the prose container div', () => {
    const { container } = render(<PatternContent content="test" />)
    const wrapper = container.firstChild as HTMLElement
    expect(wrapper.classList.contains('prose')).toBe(true)
  })

  it('renders without crashing for empty content', () => {
    const { container } = render(<PatternContent content="" />)
    expect(container).toBeTruthy()
  })

  it('renders multi-line markdown content', () => {
    render(<PatternContent content={'Line one\nLine two'} />)
    expect(screen.getByTestId('markdown-content')).toBeInTheDocument()
  })
})
