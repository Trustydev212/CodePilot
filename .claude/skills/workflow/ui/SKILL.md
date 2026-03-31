---
name: ui
description: "Generate UI components from text descriptions. Auto-detect shadcn/ui, Radix, Headless UI. Responsive, dark mode, variants."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /ui — AI Component Generation

Generate production-grade UI components from natural language descriptions.

## Usage

```
/ui login form with email, password, remember me, and social login buttons
/ui dashboard sidebar with collapsible navigation and user avatar
/ui pricing table with 3 tiers, toggle monthly/yearly, highlight popular
/ui data table with sorting, filtering, pagination, and row selection
/ui modal confirm dialog with danger variant
```

## Execution Protocol

### Phase 1: Detect UI Stack

Auto-detect from project files:
- `components.json` → shadcn/ui (read theme, style, aliases)
- `tailwind.config.*` → Tailwind CSS (read colors, fonts, spacing)
- `package.json` → Check for Radix, Headless UI, Mantine, Chakra, MUI, Ant Design
- `globals.css` → CSS variables, custom properties
- `src/components/ui/` → Existing component patterns

### Phase 2: Parse Component Request

From `$ARGUMENTS` extract component type, features, variants, interactions, responsive needs, accessibility requirements.

### Phase 3: Design Decisions

Before generating, determine:
- Component structure and file path
- Props interface
- Dependencies (existing vs new)
- States (idle, loading, error, success)
- Responsive breakpoints
- Accessibility requirements

### Phase 4: Generate Component

Follow design principles:
- **Typography**: Intentional type scale, not generic sizes
- **Colors**: Semantic CSS variables (bg-primary, text-muted-foreground)
- **Spacing**: Consistent scale (space-y-6 sections, space-y-4 groups, space-y-2 fields)
- **Patterns**: React Hook Form + Zod for forms, @tanstack/react-table for tables

### Phase 5: Dark Mode Support

All colors use CSS variables that auto-switch. No hardcoded colors.

## Component Library (Common Patterns)

| Request | Implementation |
|---------|---------------|
| Login/signup form | React Hook Form + Zod + shadcn Form |
| Data table | @tanstack/react-table + shadcn Table |
| Command palette | shadcn Command (cmdk) |
| File upload | react-dropzone + shadcn Progress |
| Date picker | shadcn Calendar (react-day-picker) |
| Rich text editor | Tiptap + shadcn toolbar |
| Charts | Recharts + shadcn Card wrapper |
| Kanban board | @dnd-kit/sortable + shadcn Card |
| Toast notifications | shadcn Sonner |
| Multi-step form | React Hook Form + shadcn Tabs |
| Settings page | shadcn Form + Tabs + Switch |

## Rules

- ALWAYS check existing components before creating new ones
- Use project's design tokens, never hardcode colors
- Every component must work in dark mode
- Every interactive element must be keyboard accessible
- Use semantic HTML elements
- Prefer composition over monolithic components
- Include TypeScript props interface
- Add 'use client' only when component uses hooks/interactivity
- Keep components under 150 lines
- Include loading/error/empty states for data-dependent components
