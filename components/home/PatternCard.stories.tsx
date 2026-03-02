import type { Meta, StoryObj } from '@storybook/react'
import { PatternCard } from './PatternCard'
import {
  MOCK_PATTERN,
  MOCK_PATTERN_ARCHITECTURE,
  MOCK_PATTERN_SECURITY,
} from '../../.storybook/fixtures'

const meta: Meta<typeof PatternCard> = {
  title: 'Home/PatternCard',
  component: PatternCard,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="w-80">
        <Story />
      </div>
    ),
  ],
}

export default meta
type Story = StoryObj<typeof PatternCard>

export const AiPrompt: Story = {
  args: { pattern: MOCK_PATTERN },
}

export const Architecture: Story = {
  args: { pattern: MOCK_PATTERN_ARCHITECTURE },
}

export const Security: Story = {
  args: { pattern: MOCK_PATTERN_SECURITY },
}

export const NoAuthor: Story = {
  args: {
    pattern: {
      ...MOCK_PATTERN,
      author: undefined,
    },
  },
}

export const ManyTags: Story = {
  args: {
    pattern: {
      ...MOCK_PATTERN,
      tags: ['prompting', 'reasoning', 'llm', 'accuracy', 'chain-of-thought', 'step-by-step'],
    },
  },
}

export const LongTitle: Story = {
  args: {
    pattern: {
      ...MOCK_PATTERN,
      title:
        'A Very Long Pattern Title That Should Be Clamped at Two Lines in the Card Header Component',
    },
  },
}

export const Grid: Story = {
  render: () => (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 w-full">
      <PatternCard pattern={MOCK_PATTERN} />
      <PatternCard pattern={MOCK_PATTERN_ARCHITECTURE} />
      <PatternCard pattern={MOCK_PATTERN_SECURITY} />
    </div>
  ),
  decorators: [],
}
