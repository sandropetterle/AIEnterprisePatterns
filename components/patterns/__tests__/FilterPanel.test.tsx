/**
 * FilterPanel Component Tests
 * Tests the category and tag filtering component
 */

import { render, screen, fireEvent } from '@testing-library/react'
import { FilterPanel } from '../FilterPanel'

// Mock Next.js navigation
const mockPush = jest.fn()
const mockSearchParams = new URLSearchParams()

jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: mockPush,
  }),
  useSearchParams: () => mockSearchParams,
}))

describe('FilterPanel', () => {
  const mockCategories = ['Architecture', 'Design Patterns', 'AI Prompts']
  const mockTags = ['Tag1', 'Tag2', 'Tag3']

  beforeEach(() => {
    jest.clearAllMocks()
    Array.from(mockSearchParams.keys()).forEach(key => mockSearchParams.delete(key))
  })

  it('should render filters heading', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('Filters')).toBeInTheDocument()
  })

  it('should render all categories', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('All Categories')).toBeInTheDocument()
    expect(screen.getByText('Architecture')).toBeInTheDocument()
    expect(screen.getByText('Design Patterns')).toBeInTheDocument()
    expect(screen.getByText('AI Prompts')).toBeInTheDocument()
  })

  it('should render all tags with checkboxes', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('Tag1')).toBeInTheDocument()
    expect(screen.getByText('Tag2')).toBeInTheDocument()
    expect(screen.getByText('Tag3')).toBeInTheDocument()

    expect(screen.getByLabelText('Tag1')).toBeInTheDocument()
    expect(screen.getByLabelText('Tag2')).toBeInTheDocument()
    expect(screen.getByLabelText('Tag3')).toBeInTheDocument()
  })

  it('should navigate with category filter when category is clicked', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const architectureButton = screen.getByText('Architecture')
    fireEvent.click(architectureButton)

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining('category=Architecture')
    )
  })

  it('should remove category filter when "All Categories" is clicked', () => {
    mockSearchParams.set('category', 'Architecture')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const allCategoriesButton = screen.getByText('All Categories')
    fireEvent.click(allCategoriesButton)

    expect(mockPush).toHaveBeenCalledWith(
      expect.not.stringContaining('category=')
    )
  })

  it('should toggle tag when tag checkbox is clicked', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const tag1Checkbox = screen.getByLabelText('Tag1')
    fireEvent.click(tag1Checkbox)

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining('tags=Tag1')
    )
  })

  it('should allow multiple tags to be selected', () => {
    const { rerender } = render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const tag1Checkbox = screen.getByLabelText('Tag1')
    fireEvent.click(tag1Checkbox)
    jest.clearAllMocks()

    // Update params and re-render so component sees Tag1 as selected
    mockSearchParams.set('tags', 'Tag1')
    rerender(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const tag2Checkbox = screen.getByLabelText('Tag2')
    fireEvent.click(tag2Checkbox)

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining('tags=Tag1%2CTag2')
    )
  })

  it('should remove tag when unchecking', () => {
    mockSearchParams.set('tags', 'Tag1,Tag2')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const tag1Checkbox = screen.getByLabelText('Tag1')
    fireEvent.click(tag1Checkbox)

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining('tags=Tag2')
    )
    expect(mockPush).toHaveBeenCalledWith(
      expect.not.stringContaining('Tag1')
    )
  })

  it('should show "Clear all" button when filters are active', () => {
    mockSearchParams.set('category', 'Architecture')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('Clear all')).toBeInTheDocument()
  })

  it('should not show "Clear all" button when no filters are active', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.queryByText('Clear all')).not.toBeInTheDocument()
  })

  it('should clear all filters when "Clear all" is clicked', () => {
    mockSearchParams.set('category', 'Architecture')
    mockSearchParams.set('tags', 'Tag1,Tag2')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const clearButton = screen.getByText('Clear all')
    fireEvent.click(clearButton)

    expect(mockPush).toHaveBeenCalledWith(
      expect.not.stringContaining('category=')
    )
    expect(mockPush).toHaveBeenCalledWith(
      expect.not.stringContaining('tags=')
    )
  })

  it('should show active category filter in Active Filters section', () => {
    mockSearchParams.set('category', 'Architecture')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('Active Filters')).toBeInTheDocument()
    // Architecture appears twice: once in the category list, once in active filters
    expect(screen.getAllByText('Architecture').length).toBeGreaterThan(1)
  })

  it('should show active tag filters in Active Filters section', () => {
    mockSearchParams.set('tags', 'Tag1,Tag2')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.getByText('Active Filters')).toBeInTheDocument()
    // Each tag appears twice: once in the tag list, once in active filters
    expect(screen.getAllByText('Tag1').length).toBeGreaterThan(1)
    expect(screen.getAllByText('Tag2').length).toBeGreaterThan(1)
  })

  it('should not show Active Filters section when no filters are active', () => {
    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    expect(screen.queryByText('Active Filters')).not.toBeInTheDocument()
  })

  it('should reset to page 1 when filter changes', () => {
    mockSearchParams.set('page', '3')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const architectureButton = screen.getByText('Architecture')
    fireEvent.click(architectureButton)

    expect(mockPush).toHaveBeenCalledWith(
      expect.not.stringContaining('page=')
    )
  })

  it('should preserve other params when changing filters', () => {
    mockSearchParams.set('search', 'test query')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    const architectureButton = screen.getByText('Architecture')
    fireEvent.click(architectureButton)

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringMatching(/search=test\+query/)
    )
  })

  it('should handle empty categories array', () => {
    render(<FilterPanel categories={[]} tags={mockTags} />)

    expect(screen.getByText('All Categories')).toBeInTheDocument()
    expect(screen.getByText('Category')).toBeInTheDocument()
  })

  it('should handle empty tags array', () => {
    render(<FilterPanel categories={mockCategories} tags={[]} />)

    expect(screen.getByText('Tags')).toBeInTheDocument()
    // No tag checkboxes should be rendered
    expect(screen.queryByRole('checkbox')).not.toBeInTheDocument()
  })

  it('should highlight selected category', () => {
    mockSearchParams.set('category', 'Architecture')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    // When category is active, 'Architecture' appears in both the button and
    // the Active Filters badge — use getByRole to target the button specifically
    const architectureButton = screen.getByRole('button', { name: 'Architecture' })
    expect(architectureButton).toHaveAttribute('aria-pressed', 'true')
  })

  it('should check selected tags', () => {
    mockSearchParams.set('tags', 'Tag1')

    render(<FilterPanel categories={mockCategories} tags={mockTags} />)

    // Radix UI Checkbox renders as <button role="checkbox" aria-checked="true">
    // so use toBeChecked() which handles both native inputs and ARIA checkboxes
    const tag1Checkbox = screen.getByLabelText('Tag1')
    expect(tag1Checkbox).toBeChecked()
  })

  // Issue #68: hardcoded id="tag-{tag}" produced duplicate ids when FilterPanel
  // is mounted twice (desktop panel + mobile FilterSheet) — invalid HTML and
  // ambiguous <label htmlFor> association.
  it('should generate unique tag checkbox ids across multiple instances', () => {
    const { container } = render(
      <>
        <FilterPanel categories={mockCategories} tags={mockTags} />
        <FilterPanel categories={mockCategories} tags={mockTags} />
      </>
    )
    const ids = Array.from(
      container.querySelectorAll('[role="checkbox"]')
    ).map((el) => el.id)

    expect(ids).toHaveLength(mockTags.length * 2)
    ids.forEach((id) => expect(id).not.toBe(''))
    expect(new Set(ids).size).toBe(mockTags.length * 2)
  })

  // Issue #68: e2e tests need a deterministic hydration signal — visibility of
  // server-rendered HTML fires before React attaches event handlers, so clicks
  // were silently lost. The marker is set in an effect, which only runs once
  // the component is mounted and interactive.
  it('should mark the panel as hydrated after mount', () => {
    const { container } = render(
      <FilterPanel categories={mockCategories} tags={mockTags} />
    )

    expect(container.querySelector('aside')).toHaveAttribute(
      'data-hydrated',
      'true'
    )
  })
})
