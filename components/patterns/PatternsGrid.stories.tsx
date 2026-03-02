import type { Meta, StoryObj } from '@storybook/react'
import { PatternsGrid } from './PatternsGrid'
import { MOCK_PATTERNS } from '../../.storybook/fixtures'

const meta: Meta<typeof PatternsGrid> = {
  title: 'Patterns/PatternsGrid',
  component: PatternsGrid,
  tags: ['autodocs'],
  parameters: { layout: 'fullscreen' },
}

export default meta
type Story = StoryObj<typeof PatternsGrid>

export const Default: Story = {
  args: { patterns: MOCK_PATTERNS },
}

export const SinglePattern: Story = {
  args: { patterns: [MOCK_PATTERNS[0]] },
}

export const Empty: Story = {
  args: { patterns: [] },
}
