import type { Meta, StoryObj } from '@storybook/react'
import { PatternContent } from './PatternContent'

const SAMPLE_MARKDOWN = `## Overview

Chain of Thought (CoT) prompting encourages the model to show its reasoning before giving a final answer.

## When to Use

Use CoT prompting when:

- The task requires **multi-step reasoning**
- Accuracy is more important than speed
- You need the model to explain its thinking

## Example

\`\`\`
Q: Roger has 5 tennis balls. He buys 2 more cans of 3 balls each.
   How many tennis balls does he have now?
A: Roger started with 5 balls.
   2 cans × 3 balls = 6 new balls.
   Total: 5 + 6 = 11 tennis balls.
\`\`\`

## Variants

### Zero-Shot CoT

Add "Let's think step by step" at the end of your prompt.

> "Let's think step by step" consistently improves accuracy on arithmetic and logic tasks.

### Few-Shot CoT

Provide a few worked examples before the question.

## Trade-offs

| Benefit | Cost |
|---------|------|
| Better accuracy | More tokens used |
| Explainable reasoning | Slower responses |
| Catches simple errors | Not always needed |

## Further Reading

- [Chain-of-Thought Prompting Elicits Reasoning in LLMs](https://arxiv.org/abs/2201.11903)
- [OpenAI Cookbook](https://cookbook.openai.com)
`

const meta: Meta<typeof PatternContent> = {
  title: 'Patterns/PatternContent',
  component: PatternContent,
  tags: ['autodocs'],
  argTypes: {
    content: { control: 'text' },
  },
}

export default meta
type Story = StoryObj<typeof PatternContent>

export const FullPattern: Story = {
  args: { content: SAMPLE_MARKDOWN },
}

export const Simple: Story = {
  args: {
    content: `## Overview\n\nA simple pattern with minimal content.\n\n- Point one\n- Point two\n- Point three`,
  },
}

export const WithCodeBlock: Story = {
  args: {
    content: `## Implementation\n\n\`\`\`typescript\nfunction getCompletion(prompt: string): Promise<string> {\n  return openai.complete({ prompt, model: 'gpt-4' })\n}\n\`\`\`\n\nInline code: use \`const\` not \`let\` for immutable values.`,
  },
}

export const WithTable: Story = {
  args: {
    content: `## Comparison\n\n| Approach | Accuracy | Speed |\n|----------|----------|-------|\n| Direct | Low | Fast |\n| CoT | High | Slow |\n| Few-Shot | Medium | Medium |`,
  },
}
