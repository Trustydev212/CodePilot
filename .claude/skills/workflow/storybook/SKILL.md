---
name: storybook
description: "Auto-generate Storybook stories from React/Vue components. Detect props, create variants, add interaction tests."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /storybook — Auto-generate Component Stories

Generate Storybook stories from existing components with variants and interaction tests.

## Usage

```
/storybook <component>          # Generate story for specific component
/storybook all                  # Generate stories for all components
/storybook setup                # Set up Storybook in project
```

## Execution Protocol

### Phase 1: Analyze Component

Read component file. Extract props interface, default values, variants, event handlers, state-dependent renders.

### Phase 2: Generate Story

Create `.stories.tsx` using CSF3 format with:
- Meta with argTypes and controls
- Default story
- One story per variant
- State stories (disabled, loading, error)
- Interaction tests for interactive elements

### Phase 3: Story Variants

| Prop Type | Generated Stories |
|-----------|------------------|
| `variant: 'a' \| 'b'` | One story per variant |
| `disabled: boolean` | Default + Disabled |
| `loading: boolean` | Default + Loading |
| `onClick: () => void` | Story with interaction test |

### Phase 4: Setup (`/storybook setup`)

Detect stack and configure:
- Next.js → `@storybook/nextjs`
- Vite → `@storybook/react-vite`
- Vue → `@storybook/vue3-vite`

## Rules

- Place stories next to components
- Use CSF3 format
- Include `tags: ['autodocs']`
- Add argTypes with controls for every prop
- Add interaction tests for interactive components
