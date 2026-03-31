---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
---

# React Rules

- Functional components only. No class components.
- Component files: PascalCase matching component name (`UserCard.tsx` exports `UserCard`).
- One component per file for components >30 lines.
- Props interface named `{ComponentName}Props`.
- Destructure props in function signature: `function UserCard({ name, email }: UserCardProps)`.
- Keep components under 150 lines. Extract sub-components if longer.
- State should live as close to where it's used as possible. Lift only when sharing.
- Event handlers: `handle{Event}` naming (handleClick, handleSubmit, handleChange).
- Custom hooks: `use{Purpose}` naming (useAuth, useDebounce, useLocalStorage).
- Avoid inline object/array literals in JSX props (causes unnecessary re-renders).
- Use Suspense boundaries for async components. Add fallback loading UI.
- Error boundaries at route segment level minimum.
- Accessibility: every interactive element needs keyboard support and ARIA when semantic HTML isn't enough.
