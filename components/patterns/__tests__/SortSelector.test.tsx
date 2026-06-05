import { render, screen, fireEvent } from '@testing-library/react'
import { SortSelector } from '../SortSelector'

const mockPush = jest.fn()
const mockSearchParams = new URLSearchParams()

jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
  useSearchParams: () => mockSearchParams,
}))

describe('SortSelector', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    Array.from(mockSearchParams.keys()).forEach((k) => mockSearchParams.delete(k))
  })

  it('renders the sort label', () => {
    render(<SortSelector />)
    expect(screen.getByText('Sort by:')).toBeInTheDocument()
  })

  it('renders all sort options', () => {
    render(<SortSelector />)
    // The trigger shows the current value
    expect(screen.getByRole('combobox')).toBeInTheDocument()
  })

  it('defaults to Most Recent when no sort param', () => {
    render(<SortSelector />)
    // The select trigger should show the current value
    expect(screen.getByText('Most Recent')).toBeInTheDocument()
  })

  it('renders the sort select with correct id', () => {
    render(<SortSelector />)
    const trigger = screen.getByRole('combobox')
    expect(trigger).toHaveAttribute('id', 'sort-select')
  })

  it('renders all three sort options', () => {
    render(<SortSelector />)
    const options = screen.getAllByRole('option')
    expect(options.map((o) => o.textContent)).toEqual([
      'Most Recent',
      'Most Voted',
      'Alphabetical',
    ])
  })

  it('pushes the selected sort to the URL on change', () => {
    render(<SortSelector />)

    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'votes' } })

    expect(mockPush).toHaveBeenCalledWith('/patterns?sort=votes')
  })

  it('resets the page param when the sort changes', () => {
    mockSearchParams.set('page', '3')
    render(<SortSelector />)

    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'alphabetical' } })

    expect(mockPush).toHaveBeenCalledWith('/patterns?sort=alphabetical')
  })

  it('reflects the sort param from the URL as the selected value', () => {
    mockSearchParams.set('sort', 'votes')
    render(<SortSelector />)

    expect(screen.getByRole('combobox')).toHaveValue('votes')
  })

  it('renders custom sort options from CMS labels', () => {
    render(
      <SortSelector
        sortByLabel="Order by:"
        sortOptions={[
          { value: 'recent', label: 'Newest' },
          { value: 'votes', label: 'Top Voted' },
        ]}
      />
    )

    expect(screen.getByText('Order by:')).toBeInTheDocument()
    const options = screen.getAllByRole('option')
    expect(options.map((o) => o.textContent)).toEqual(['Newest', 'Top Voted'])
  })
})
