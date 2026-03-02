import type { Meta, StoryObj } from '@storybook/react'
import { NewPatternButton } from './NewPatternButton'
import {
  withSession,
  MOCK_ADMIN_SESSION,
  MOCK_EDITOR_SESSION,
} from '../../.storybook/mocks/next-auth-react'

const meta: Meta<typeof NewPatternButton> = {
  title: 'Patterns/NewPatternButton',
  component: NewPatternButton,
  tags: ['autodocs'],
}

export default meta
type Story = StoryObj<typeof NewPatternButton>

export const Unauthenticated: Story = {}

export const AuthenticatedEditor: Story = {
  decorators: [withSession(MOCK_EDITOR_SESSION)],
}

export const AuthenticatedAdmin: Story = {
  decorators: [withSession(MOCK_ADMIN_SESSION)],
}
