import type { Meta, StoryObj } from '@storybook/react'
import { RelatedPatternsSection } from './RelatedPatternsSection'
import { MOCK_PATTERNS } from '../../../.storybook/fixtures'

const meta: Meta<typeof RelatedPatternsSection> = {
  title: 'Patterns/RelatedPatternsSection',
  component: RelatedPatternsSection,
  tags: ['autodocs'],
  parameters: { layout: 'fullscreen' },
}

export default meta
type Story = StoryObj<typeof RelatedPatternsSection>

export const WithRelated: Story = {
  args: { patterns: MOCK_PATTERNS },
}

export const Empty: Story = {
  args: { patterns: [] },
}

export const Single: Story = {
  args: { patterns: [MOCK_PATTERNS[0]] },
}
