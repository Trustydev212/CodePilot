---
name: design-system
description: "Create, audit, and manage design systems. Design tokens, theme config, consistency audit, brand guidelines enforcement."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /design-system — Design System Management

Create, audit, and enforce design systems across your project.

## Usage

```
/design-system create                # Create design system from scratch
/design-system audit                 # Audit UI consistency
/design-system tokens                # Generate/update design tokens
/design-system theme <brand>         # Generate theme from brand guidelines
/design-system doc                   # Document the design system
```

## Execution Protocol

### Phase 1: Analyze Current State

Scan project for existing design decisions:
- tailwind.config.* → Custom colors, fonts, spacing
- globals.css → CSS variables
- components.json → shadcn/ui config
- src/components/ui/ → Existing components

Produce audit with colors, typography, spacing analysis and issues found.

### Phase 2: Create/Update Design Tokens

Generate CSS variables with:
- Colors (HSL for composability, semantic naming)
- Typography scale (Major Third 1.25 ratio)
- Spacing scale (4px base)
- Border radius, shadows, transitions
- Light + dark mode variants

### Phase 3: Audit Components

Check each component for:
- CSS variable usage (no hardcoded colors)
- Consistent border radius
- Consistent spacing from scale
- Dark mode support
- Focus visible styles
- Typography from type scale

Generate fix commands with exact file:line and before/after.

### Phase 4: Theme Generation

From brand input, generate complete CSS variables + Tailwind config with accessible contrast ratios.

### Phase 5: Documentation

Generate design system docs with color swatches, type scale, spacing, component inventory.

## Rules

- NEVER hardcode colors — use CSS variables or Tailwind theme
- Every color pairing must meet WCAG AA contrast (4.5:1)
- Use consistent spacing scale (4px or 8px base)
- Use mathematical type scale
- Dark mode is not optional
- Border radius must be consistent project-wide
- Document every design token with usage guidelines
