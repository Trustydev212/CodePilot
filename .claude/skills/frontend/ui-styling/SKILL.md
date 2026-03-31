---
name: ui-styling
description: "Tailwind CSS v4, shadcn/ui, responsive design, accessibility. Build production-grade UIs that don't look like AI slop."
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.css"
  - "**/tailwind.config.*"
  - "**/components/ui/**"
---

# UI & Styling Expert

Build interfaces that are distinctive, accessible, and production-grade. Avoid generic "AI template" aesthetics.

## Design Principles

1. **Visual hierarchy** - Size, color, and spacing guide the eye naturally
2. **Consistency** - Same spacing scale, color palette, border radius everywhere
3. **Whitespace** - More space = more premium feel. Don't cram.
4. **Motion** - Subtle, purposeful animations (not decorative)
5. **Accessibility** - WCAG 2.1 AA minimum. Not optional.

## Tailwind CSS Patterns

### Spacing System (stick to the scale)
```
p-1 (4px)  - Tight: badges, chips
p-2 (8px)  - Compact: list items, table cells
p-3 (12px) - Default: card content
p-4 (16px) - Comfortable: sections
p-6 (24px) - Spacious: page sections
p-8 (32px) - Generous: hero sections
```

### Responsive Design (mobile-first)
```tsx
<div className="
  grid grid-cols-1         /* Mobile: single column */
  sm:grid-cols-2           /* 640px+: two columns */
  lg:grid-cols-3           /* 1024px+: three columns */
  gap-4 sm:gap-6           /* Responsive gaps */
">
```

### Color Usage
```tsx
// Semantic colors, not arbitrary values
<button className="bg-primary text-primary-foreground">       {/* Main action */}
<button className="bg-secondary text-secondary-foreground">   {/* Secondary */}
<button className="bg-destructive text-destructive-foreground"> {/* Danger */}
<span className="text-muted-foreground">                       {/* Subtle text */}
```

### Dark Mode
```tsx
// Always design for both modes
<div className="bg-white dark:bg-zinc-950 text-zinc-900 dark:text-zinc-100">
  <p className="text-zinc-500 dark:text-zinc-400">Muted text</p>
</div>
```

## shadcn/ui Patterns

### Use existing components first
Before building custom UI, check if shadcn/ui has it:
- Dialog, Sheet, Popover, Tooltip, DropdownMenu
- Form, Input, Select, Checkbox, RadioGroup
- Table, Card, Badge, Avatar, Skeleton
- Toast, Alert, AlertDialog

### Composition pattern
```tsx
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

function ProjectCard({ project }: { project: Project }) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{project.name}</CardTitle>
          <Badge variant={project.status === 'active' ? 'default' : 'secondary'}>
            {project.status}
          </Badge>
        </div>
        <CardDescription>{project.description}</CardDescription>
      </CardHeader>
      <CardContent>
        {/* Content here */}
      </CardContent>
    </Card>
  )
}
```

## Accessibility Checklist (Non-negotiable)

- [ ] All interactive elements are keyboard accessible (Tab, Enter, Escape)
- [ ] Focus visible on all interactive elements (`focus-visible:ring-2`)
- [ ] Color contrast ratio ≥ 4.5:1 for text, ≥ 3:1 for large text
- [ ] Images have descriptive alt text (or `alt=""` for decorative)
- [ ] Form inputs have associated labels (not just placeholder)
- [ ] Error messages are announced to screen readers (`aria-live="polite"`)
- [ ] Modals trap focus and return focus on close
- [ ] Skip navigation link for keyboard users
- [ ] No content conveyed by color alone (use icons + text)
- [ ] Touch targets ≥ 44x44px on mobile

### ARIA Patterns
```tsx
// Loading state
<button disabled aria-busy="true">
  <Spinner className="animate-spin" aria-hidden="true" />
  <span>Saving...</span>
</button>

// Icon-only button
<button aria-label="Close dialog">
  <XIcon aria-hidden="true" />
</button>

// Live region for dynamic updates
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>
```

## Animation Guidelines

```tsx
// Subtle enter animation
<div className="animate-in fade-in-0 slide-in-from-bottom-2 duration-300">

// Hover transitions (keep under 200ms)
<button className="transition-colors duration-150 hover:bg-primary/90">

// Loading skeleton
<div className="animate-pulse rounded-md bg-muted h-4 w-[200px]" />
```

### What to animate:
- Page transitions, modal enter/exit
- Hover/focus states
- Loading states
- Success/error feedback

### What NOT to animate:
- Text content changes
- Layout shifts
- Background colors on large areas
- Anything that loops forever without purpose

## Anti-Patterns (AI Slop Indicators)

Avoid these patterns that scream "AI generated":
1. **Gradient everything** - Use flat colors, gradients only for CTAs
2. **Excessive rounded corners** - `rounded-lg` max for cards, not `rounded-3xl`
3. **Too many shadows** - One shadow level per elevation
4. **Icon soup** - Don't put icons on everything. Use them to disambiguate.
5. **Generic hero sections** - No "Welcome to [App]" with gradient text
6. **Fake dashboard data** - Use realistic sample data with edge cases
7. **Perfect alignment** - Real UIs have visual tension. Not everything is centered.
