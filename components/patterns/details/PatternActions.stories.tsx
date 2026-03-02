import type { Meta, StoryObj } from '@storybook/react'
import { PatternActions } from './PatternActions'
import {
  withSession,
  MOCK_ADMIN_SESSION,
  MOCK_EDITOR_SESSION,
} from '../../../.storybook/mocks/next-auth-react'

const meta: Meta<typeof PatternActions> = {
  title: 'Patterns/PatternActions',
  component: PatternActions,
  tags: ['autodocs'],
}

export default meta
type Story = StoryObj<typeof PatternActions>

export const EditorView: Story = {
  decorators: [withSession(MOCK_EDITOR_SESSION)],
  args: {
    slug: 'chain-of-thought-prompting',
    patternId: 'b0000000-0000-0000-0000-000000000001',
  },
}

export const AdminView: Story = {
  decorators: [withSession(MOCK_ADMIN_SESSION)],
  args: {
    slug: 'chain-of-thought-prompting',
    patternId: 'b0000000-0000-0000-0000-000000000001',
  },
}

export const UnauthenticatedHidden: Story = {
  args: {
    slug: 'chain-of-thought-prompting',
    patternId: 'b0000000-0000-0000-0000-000000000001',
  },
  render: (args) => (
    <div>
      <p className="text-sm text-muted-foreground mb-2">
        No session — component renders nothing (by design).
      </p>
      <PatternActions {...args} />
    </div>
  ),
}

export const CustomLabels: Story = {
  decorators: [withSession(MOCK_ADMIN_SESSION)],
  args: {
    slug: 'chain-of-thought-prompting',
    patternId: 'b0000000-0000-0000-0000-000000000001',
    editLabel: 'Modify',
    deleteLabel: 'Remove',
    deleteDialogTitle: 'Permanently remove this pattern?',
    deleteDialogDescription: 'This cannot be undone.',
    deleteConfirmLabel: 'Yes, remove it',
  },
}
