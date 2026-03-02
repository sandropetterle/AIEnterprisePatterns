import type { Meta, StoryObj } from '@storybook/react'
import { SearchBar } from './SearchBar'
import { MOCK_PATTERNS } from '../../.storybook/fixtures'

const ALL_TAGS = ['prompting', 'reasoning', 'llm', 'microservices', 'events', 'kafka', 'security', 'authentication']

const meta: Meta<typeof SearchBar> = {
  title: 'Patterns/SearchBar',
  component: SearchBar,
  tags: ['autodocs'],
  parameters: {
    nextjs: { appDirectory: true },
  },
}

export default meta
type Story = StoryObj<typeof SearchBar>

export const Empty: Story = {
  args: { allPatterns: [], allTags: [] },
}

export const WithSuggestions: Story = {
  args: {
    allPatterns: MOCK_PATTERNS,
    allTags: ALL_TAGS,
  },
}
