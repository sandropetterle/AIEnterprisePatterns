import type { Meta, StoryObj } from '@storybook/react'
import { Hero } from './Hero'
import { MOCK_CTA_PRIMARY, MOCK_CTA_SECONDARY } from '../../.storybook/fixtures'

const meta: Meta<typeof Hero> = {
  title: 'Home/Hero',
  component: Hero,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
  argTypes: {
    heading: { control: 'text' },
    subheading: { control: 'text' },
  },
}

export default meta
type Story = StoryObj<typeof Hero>

export const Default: Story = {}

export const WithCmsContent: Story = {
  args: {
    heading: 'AI Enterprise Patterns Library',
    subheading:
      'Discover battle-tested AI patterns and architectural blueprints for building enterprise-grade AI systems.',
    primaryCTA: MOCK_CTA_PRIMARY,
    secondaryCTA: MOCK_CTA_SECONDARY,
  },
}

export const CustomHeading: Story = {
  args: {
    heading: 'Build Smarter Enterprise Software',
    subheading:
      'A curated collection of AI patterns, architectural blueprints, and best practices for modern enterprise development.',
  },
}
