---
name: a11y
description: "Accessibility audit and fixes. WCAG 2.1 compliance, screen reader, keyboard navigation, color contrast, ARIA patterns."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /a11y — Accessibility Audit & Fix

Comprehensive accessibility analysis following WCAG 2.1 AA standards.

## Usage

```
/a11y                          # Full audit of the project
/a11y <component>              # Audit specific component/page
/a11y fix                      # Auto-fix common a11y issues
/a11y report                   # Generate detailed a11y report
```

## Execution Protocol

### Phase 1: Scan Codebase

Analyze all component files across 8 categories:

1. **Images & Media** — Missing alt text, captions, aria-labels on SVGs
2. **Forms & Inputs** — Missing labels, aria-describedby, autocomplete
3. **Navigation & Structure** — Skip links, heading hierarchy, landmarks
4. **Interactive Elements** — Non-button click handlers, missing keyboard events
5. **Color & Contrast** — Low contrast Tailwind pairs, color-only info
6. **Dynamic Content** — Missing aria-live regions, loading announcements
7. **Tables** — Missing captions, th scope, headers attributes
8. **ARIA Usage** — Invalid roles, redundant ARIA, hidden focusable elements

### Phase 2: Report Issues

Categorize by severity (Critical/Warning) with before/after code examples.

### Phase 3: Auto-Fix (`/a11y fix`)

- Add `alt=""` to decorative images
- Convert `<div onClick>` to `<button>`
- Add `type="button"` to non-submit buttons
- Add skip-to-content link
- Add `aria-hidden="true"` to decorative SVGs
- Fix heading hierarchy

### Phase 4: Tooling Setup

Recommend eslint-plugin-jsx-a11y and axe-core for testing.

## Common Fix Patterns

### Skip to Content
```tsx
<a href="#main-content" className="sr-only focus:not-sr-only">
  Skip to content
</a>
```

### Live Region
```tsx
<div aria-live="polite" aria-atomic="true">
  {status && <p>{status}</p>}
</div>
```

## Rules

- WCAG 2.1 AA is the minimum standard
- Every interactive element MUST be keyboard accessible
- Color alone must NEVER convey information
- All images need alt text (or alt="" for decorative)
- Forms need visible labels, not just placeholders
- Dynamic content changes must be announced to screen readers
