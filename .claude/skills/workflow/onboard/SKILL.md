---
name: onboard
description: "Auto-generate onboarding guide for new developers joining the project. Scans codebase and produces a comprehensive getting-started document."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /onboard — Developer Onboarding Guide Generator

You are a senior developer writing the onboarding guide you wish you had on day one.

## Target
$ARGUMENTS

## Phase 1: Scan Project

Gather all context automatically:

```bash
# Package manager & dependencies
[ -f "package.json" ] && cat package.json | head -50
[ -f "requirements.txt" ] && cat requirements.txt
[ -f "pyproject.toml" ] && cat pyproject.toml
[ -f "go.mod" ] && cat go.mod

# Project structure
find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" \) | head -50

# Config files
ls -la *.config.* .env.example tsconfig.json docker-compose.* 2>/dev/null

# Scripts available
[ -f "package.json" ] && cat package.json | jq '.scripts' 2>/dev/null

# Database
[ -f "prisma/schema.prisma" ] && head -30 prisma/schema.prisma
[ -d "migrations" ] && ls migrations/
```

## Phase 2: Analyze Architecture

Identify:
1. **Entry points** — where does the app start? (main, index, app, server)
2. **Routing** — how are routes/pages organized?
3. **Data layer** — ORM, database, API clients
4. **Auth** — how does authentication work?
5. **State management** — frontend state approach
6. **Key patterns** — middleware, hooks, services, repositories
7. **External services** — APIs, queues, storage, email

## Phase 3: Generate Onboarding Guide

Write `ONBOARDING.md` with these sections:

```markdown
# Developer Onboarding Guide

## Quick Start (get running in 5 minutes)

### Prerequisites
- [list required tools with versions]
- [list required accounts/access]

### Setup
1. Clone the repo
2. Install dependencies: `[exact command]`
3. Set up environment: `cp .env.example .env` + what to fill in
4. Set up database: `[exact command]`
5. Run the app: `[exact command]`
6. Verify: open [URL] and you should see [what]

## Project Structure
[tree of important directories with 1-line descriptions]

## Architecture Overview

### Tech Stack
| Layer | Technology | Why |
|-------|-----------|-----|
| Frontend | [X] | [reason] |
| Backend | [X] | [reason] |
| Database | [X] | [reason] |

### Request Flow
[How a typical request flows through the system]

### Key Patterns
[Patterns used in this codebase with examples]

## Common Tasks

### Adding a new API endpoint
1. [step-by-step with file paths]

### Adding a new page/route
1. [step-by-step with file paths]

### Adding a database migration
1. [step-by-step with commands]

### Running tests
- Unit: `[command]`
- Integration: `[command]`
- E2E: `[command]`

## Environment Variables
| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| [from .env.example] | | | |

## Debugging Tips
- [common issues and how to fix them]
- [useful debug commands]
- [where to find logs]

## Code Conventions
- [naming conventions found in codebase]
- [file organization patterns]
- [commit message format]

## Key Files to Read First
1. [most important file] — [why]
2. [second most important] — [why]
3. [third] — [why]
```

## Phase 4: Verify

1. Check all commands mentioned actually work
2. Check all file paths mentioned actually exist
3. Check .env.example variables match what's documented
4. Ensure no secrets or internal URLs leaked into the guide

## Phase 5: Report

```
ONBOARDING GUIDE GENERATED

File: ONBOARDING.md
Sections: [count]
Setup steps verified: [yes/no]

Key findings:
- Stack: [detected stack]
- Entry point: [file]
- [count] env vars documented
- [count] common tasks documented
```

## Rules

1. **Be specific** — exact commands, exact file paths, exact URLs
2. **Verify commands** — don't document commands that don't work
3. **No secrets** — never include actual secret values
4. **Assume nothing** — explain everything a new dev would need
5. **Keep it current** — only document what actually exists in the codebase
6. **Link to files** — reference actual files, not hypothetical ones
