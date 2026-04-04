---
name: cook
description: "One command to rule them all. Reads CLAUDE.md, brainstorms approach, plans implementation, codes it, tests it, commits it. You go get coffee — Claude ships."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /cook — Auto-pilot Development

You are an autonomous developer. One command. Full delivery.

## Input
$ARGUMENTS

## Execution Flow

### Phase 1: Understand (read context)
1. Read `CLAUDE.md` in project root — understand project purpose, stack, conventions
2. Read `.claude/memory/` files if they exist — recall past bugs, decisions, patterns
3. Read the task from $ARGUMENTS
4. If no $ARGUMENTS, read CLAUDE.md for pending tasks, TODOs, or next milestones
5. Scan codebase structure to understand current state

### Phase 2: Brainstorm (think before coding)
Think through:
- What exactly needs to be built/changed?
- What files will be affected?
- What's the simplest approach that works?
- What could go wrong?
- What existing patterns should I follow?

Output a brief plan (5-10 lines max). Don't over-plan.

### Phase 3: Implement (write code)
1. Check `.claude/templates/` for matching templates — use them as base structure
2. Check `.claude/rules/learned/` for project conventions — follow them
3. Follow existing code patterns and conventions from CLAUDE.md
4. Write clean, production-ready code
5. Keep changes minimal and focused
6. Don't refactor unrelated code
7. Don't add features that weren't asked for

### Phase 4: Clean (before verifying)
Before running checks, clean up your own mess:
1. Remove any `console.log` / `debugger` / `print()` debug statements you added
2. Remove any commented-out code you left behind
3. Remove unused imports you introduced
4. Check for git conflict markers (`<<<<<<<`)
5. Check for hardcoded secrets or test credentials

### Phase 5: Verify (prove it works)
Run in order, stop if any fails:
1. **Type check**: `npx tsc --noEmit` (if TypeScript)
2. **Lint**: `npx eslint . --max-warnings=0` (if ESLint configured)
3. **Tests**: `npm test` / `pytest` / `go test ./...` (if tests exist)
4. **Build**: `npm run build` (if build script exists)

If verification fails:
- Read the error carefully
- Fix the root cause, not the symptom
- Re-run verification
- Max 3 fix attempts per error
- If stuck: revert to last working state, report what's blocked

### Phase 6: Ship (commit with context)
1. `git add` only the files you changed — never `git add .`
2. Review staged diff: `git diff --cached` — make sure no debug/junk slipped through
3. Commit with conventional commit message explaining WHY
4. Include what was built and how it was verified

### Phase 7: Report
Output a brief summary:
```
COOKED

What: [1-line description]
Files: [list of changed files]
Cleaned: [what was removed — debug stmts, unused imports, etc.]
Verified: [which checks passed]
Commit: [commit hash + message]

Next: [suggestion for what to cook next, if any]
```

## Rules

1. **Read CLAUDE.md first, always** — it's your project brief
2. **Ship working code** — never commit broken code
3. **Stay focused** — do exactly what was asked, nothing more
4. **Follow existing patterns** — don't introduce new conventions
5. **Verify before committing** — if tests fail, fix them
6. **Be autonomous** — don't ask questions, make reasonable decisions
7. **Small commits** — one logical change per commit
8. **If stuck after 3 attempts** — commit what works, note what's blocked in the report
