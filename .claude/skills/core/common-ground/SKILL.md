---
name: common-ground
description: "Surface and validate Claude's assumptions about your project. Prevent misunderstandings before they become bugs."
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# /common-ground - Context Alignment

Surface Claude's assumptions about your project so you can correct them before they become bugs.

## Purpose

Claude makes invisible assumptions about:
- Your tech stack and versions
- Project conventions and patterns
- Architecture decisions
- Business logic and domain rules
- What "good" looks like for YOUR project

This skill makes those assumptions VISIBLE so you can confirm or correct them.

## Process

### Step 1: Auto-Detect (Evidence-Based)

I'll scan your project and report what I observe:

```bash
# Framework & version detection
[ -f "package.json" ] && cat package.json | jq '{
  name: .name,
  frameworks: (.dependencies + .devDependencies) | to_entries | map(select(.key | test("next|react|vue|angular|express|fastify|hono|nest"))) | from_entries
}' 2>/dev/null

# TypeScript config
[ -f "tsconfig.json" ] && echo "=== TS Config ===" && cat tsconfig.json | jq '.compilerOptions | {strict, target, module, jsx}' 2>/dev/null

# Linting/formatting
[ -f ".prettierrc" ] || [ -f "prettier.config.js" ] && echo "Prettier: yes"
([ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ]) && echo "ESLint: yes"

# Project structure pattern
echo "=== Structure Pattern ==="
ls -d src/*/ 2>/dev/null || ls -d app/*/ 2>/dev/null || echo "Flat structure"
```

### Step 2: State Assumptions Explicitly

```
## My Current Understanding

### Tech Stack
- [ ] Runtime: [Node.js X / Python X / Go X]
- [ ] Framework: [Next.js X / FastAPI / Express]
- [ ] Language: [TypeScript strict / JavaScript / Python typed]
- [ ] Database: [PostgreSQL + Prisma / MongoDB / SQLite]
- [ ] Auth: [NextAuth / Clerk / Custom JWT]
- [ ] Styling: [Tailwind + shadcn/ui / CSS Modules / Styled Components]
- [ ] Testing: [Vitest / Jest / Pytest] + [Playwright / Cypress]

### Architecture Assumptions
- [ ] Pattern: [Monolith / Modular / Microservices]
- [ ] API style: [REST / GraphQL / tRPC / Server Actions]
- [ ] State management: [Server Components / Zustand / Redux / Context]
- [ ] File structure: [Feature-based / Layer-based / Flat]

### Conventions I'll Follow
- [ ] Component naming: [PascalCase files / kebab-case files]
- [ ] Import style: [Absolute @/ / Relative ../]
- [ ] Error handling: [Custom errors / HTTP exceptions / Result type]
- [ ] Commit style: [Conventional commits / Free-form]

### Business Logic Assumptions
- [ ] [Domain assumption 1]
- [ ] [Domain assumption 2]

### What I'm Uncertain About
- [Question 1]
- [Question 2]
```

### Step 3: Ask for Correction

Please review the assumptions above:
- **Confirm** items that are correct (I'll follow these patterns)
- **Correct** items that are wrong (I'll update my understanding)
- **Add** anything missing (conventions, constraints, preferences)

This alignment prevents:
- Writing code in the wrong style
- Using outdated patterns
- Making incorrect architecture decisions
- Misunderstanding business requirements

### Step 4: Update Context

After your corrections, I'll save the confirmed context to use throughout our session. This means:
- All code I write will match YOUR conventions
- Architecture decisions will align with YOUR patterns
- I won't ask the same questions again

## When to Use This

- **Start of a new project session** - Align once, code confidently
- **Before a major feature** - Ensure we agree on approach
- **When something feels "off"** - Surface hidden assumptions
- **New team member onboarding** - Document tribal knowledge
