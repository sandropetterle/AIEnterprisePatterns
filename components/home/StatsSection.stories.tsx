import type { Meta, StoryObj } from '@storybook/react'
import { StatsSection } from './StatsSection'
import { MOCK_STAT_ITEMS } from '../../.storybook/fixtures'

const meta: Meta<typeof StatsSection> = {
  title: 'Home/StatsSection',
  component: StatsSection,
  tags: ['autodocs'],
  parameters: { layout: 'fullscreen' },
  argTypes: {
    totalPatterns: { control: 'number' },
    totalCategories: { control: 'number' },
    totalContributors: { control: 'text' },
  },
}

export default meta
type Story = StoryObj<typeof StatsSection>

export const Default: Story = {
  args: {
    totalPatterns: 42,
    totalCategories: 8,
    totalContributors: '120+',
  },
}

export const WithCmsLabels: Story = {
  args: {
    totalPatterns: 42,
    totalCategories: 8,
    totalContributors: '120+',
    statLabels: MOCK_STAT_ITEMS,
  },
}

export const LargeNumbers: Story = {
  args: {
    totalPatterns: 1200,
    totalCategories: 24,
    totalContributors: '5,000+',
  },
}
