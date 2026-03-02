import type { Meta, StoryObj } from '@storybook/react'
import { Breadcrumb } from './Breadcrumb'

const meta: Meta<typeof Breadcrumb> = {
  title: 'Patterns/Breadcrumb',
  component: Breadcrumb,
  tags: ['autodocs'],
}

export default meta
type Story = StoryObj<typeof Breadcrumb>

export const PatternDetail: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Patterns', href: '/patterns' },
      { label: 'Chain of Thought Prompting', href: '/patterns/chain-of-thought-prompting' },
    ],
  },
}

export const TwoLevels: Story = {
  args: {
    items: [
      { label: 'Patterns', href: '/patterns' },
      { label: 'Zero Trust Security', href: '/patterns/zero-trust-security' },
    ],
  },
}

export const LongTitle: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Patterns', href: '/patterns' },
      {
        label: 'Event-Driven Architecture with CQRS, Event Sourcing and Saga Pattern',
        href: '/patterns/event-driven-architecture',
      },
    ],
  },
}
