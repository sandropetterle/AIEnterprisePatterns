import type { Meta, StoryObj } from '@storybook/react'
import { FeaturedPatterns } from './FeaturedPatterns'
import { MOCK_PATTERNS } from '../../.storybook/fixtures'

const meta: Meta<typeof FeaturedPatterns> = {
  title: 'Home/FeaturedPatterns',
  component: FeaturedPatterns,
  tags: ['autodocs'],
  parameters: { layout: 'fullscreen' },
}

export default meta
type Story = StoryObj<typeof FeaturedPatterns>

export const Default: Story = {
  args: { patterns: MOCK_PATTERNS },
}

export const WithCmsLabels: Story = {
  args: {
    patterns: MOCK_PATTERNS,
    heading: 'Featured Patterns',
    subheading: 'Curated patterns from our community of enterprise architects.',
    viewAllLabel: 'View All Patterns',
    mobileViewAllLabel: 'View All',
  },
}

export const Empty: Story = {
  args: { patterns: [] },
}
