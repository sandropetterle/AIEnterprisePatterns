import type { Meta, StoryObj } from '@storybook/react'
import { PatternForm } from './PatternForm'
import { MOCK_PATTERN } from '../../.storybook/fixtures'
import {
  withSession,
  MOCK_ADMIN_SESSION,
  MOCK_EDITOR_SESSION,
} from '../../.storybook/mocks/next-auth-react'

const meta: Meta<typeof PatternForm> = {
  title: 'Patterns/PatternForm',
  component: PatternForm,
  tags: ['autodocs'],
  parameters: { layout: 'fullscreen' },
  decorators: [
    (Story) => (
      <div className="container mx-auto px-4 py-8 max-w-3xl">
        <Story />
      </div>
    ),
  ],
}

export default meta
type Story = StoryObj<typeof PatternForm>

export const CreateAsEditor: Story = {
  decorators: [withSession(MOCK_EDITOR_SESSION)],
  args: { mode: 'create' },
}

export const CreateAsAdmin: Story = {
  decorators: [withSession(MOCK_ADMIN_SESSION)],
  args: { mode: 'create' },
}

export const EditExisting: Story = {
  decorators: [withSession(MOCK_ADMIN_SESSION)],
  args: {
    mode: 'edit',
    initialData: MOCK_PATTERN,
  },
}

export const WithCmsLabels: Story = {
  decorators: [withSession(MOCK_EDITOR_SESSION)],
  args: {
    mode: 'create',
    labels: {
      createTitle: 'New Pattern',
      titleLabel: 'Title',
      titlePlaceholder: 'Pattern name',
      shortDescLabel: 'Short Description',
      categoryLabel: 'Category',
      tagsLabel: 'Tags',
      contentLabel: 'Full Content (Markdown)',
      authorLabel: 'Author',
      createLabel: 'Create Pattern',
      cancelLabel: 'Cancel',
    },
  },
}
