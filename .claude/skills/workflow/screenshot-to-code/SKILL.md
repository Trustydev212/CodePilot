---
name: screenshot-to-code
description: "Convert screenshots, mockups, or design descriptions into production React/Vue components with Tailwind CSS."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /screenshot-to-code — Design to Code Conversion

Convert visual designs into production-ready components.

## Usage

```
/screenshot-to-code <image-path>              # Convert screenshot to component
/screenshot-to-code <description>             # Convert text description to UI
/screenshot-to-code <url> --capture           # Capture and recreate a web page section
```

## Execution Protocol

### Phase 1: Analyze Input

- **Image file** → Analyze layout, components, colors, typography, spacing
- **Text description** → Parse UI requirements
- **URL** → Analyze referenced design

### Phase 2: Detect Project UI Stack

Same as /ui skill — detect shadcn/ui, Tailwind, component library.

### Phase 3: Map Visual to Components

Break design into component tree. Identify:
- Existing components to reuse
- New components to create
- Layout structure (grid, flex, columns)

### Phase 4: Extract Design Tokens

Map visual colors/typography/spacing to project's CSS variables and Tailwind classes.

### Phase 5: Generate Code

Generate each component following project conventions:
- TypeScript with props interfaces
- Project's component library (shadcn/ui, etc.)
- Responsive breakpoints (mobile-first)
- Dark mode compatible

### Phase 6: Assemble Page

Create page/layout that composes all generated components.

## Supported Inputs

| Input Type | How It Works |
|-----------|-------------|
| PNG/JPG screenshot | Claude analyzes the image visually |
| Figma description | Parse layout, components, styles |
| Text description | Natural language to components |
| Wireframe | Low-fidelity to high-fidelity code |
| Reference URL | Analyze and recreate design patterns |

## Rules

- ALWAYS map colors to project's design tokens
- ALWAYS reuse existing components before creating new ones
- Generate responsive layouts (mobile-first)
- Include dark mode support
- Use semantic HTML
- Each component under 100 lines
- Add TypeScript props interfaces
- Include loading/empty/error states
- Follow project's directory structure
- Prefer shadcn/ui primitives over custom implementations
