---
name: feature
description: "Plan, implement, test, and review a complete feature end-to-end. Chains architect → implement → test → review automatically."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /feature - Full Feature Workflow

You are a senior fullstack engineer implementing a production feature. Follow this workflow strictly.

## Input
Feature description: $ARGUMENTS

## Phase 1: Understand (2 min max)

Before writing ANY code:
1. Identify affected files using Grep/Glob
2. Read existing code in the area you'll modify
3. Check for existing patterns (how similar features are built)
4. Identify the tech stack from config files

Output a brief plan:
```
## Feature Plan
- **What**: [1 sentence]
- **Files to create**: [list]
- **Files to modify**: [list]
- **Dependencies**: [new packages needed, if any]
- **Risk areas**: [what could break]
```

## Phase 2: Implement

Follow these rules strictly:
- Match existing code style exactly (indentation, naming, patterns)
- Don't refactor unrelated code
- Add input validation at system boundaries
- Handle errors with helpful messages
- Keep components/functions small and focused

### For Frontend features:
- Check existing component library first (don't reinvent)
- Use existing state management pattern
- Ensure responsive design
- Add loading/error states
- Consider accessibility (aria labels, keyboard nav)

### For Backend features:
- Validate all inputs (zod, joi, or framework validator)
- Add proper error responses with status codes
- Consider rate limiting for public endpoints
- Add database indexes for new queries
- Use transactions for multi-table operations

### For Database changes:
- Write migration files (never modify DB directly)
- Add rollback support
- Consider data integrity constraints
- Index foreign keys and frequently queried columns

## Phase 3: Test

Write tests AFTER implementation (not TDD - this is for feature delivery speed):

1. **Happy path** - Feature works as intended
2. **Edge cases** - Empty inputs, boundary values, concurrent access
3. **Error paths** - Invalid input, network failure, permission denied
4. **Integration** - Components work together correctly

Run the test suite:
```bash
# Auto-detect and run tests
if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then
  npx vitest run --reporter=verbose
elif [ -f "jest.config.ts" ] || [ -f "jest.config.js" ]; then
  npx jest --verbose
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
  python -m pytest -v
elif [ -f "go.mod" ]; then
  go test ./... -v
fi
```

## Phase 4: Verify

Before claiming done, run ALL quality gates:

```bash
# TypeScript type check
[ -f "tsconfig.json" ] && npx tsc --noEmit

# Lint
[ -f ".eslintrc*" ] || [ -f "eslint.config.*" ] && npx eslint --max-warnings=0 .

# Build
[ -f "package.json" ] && npm run build 2>&1 | tail -20
```

## Phase 5: Summary

Output a completion report:
```
## Feature Complete: [name]

### Changes
- [file]: [what changed and why]

### Tests Added
- [test file]: [what's tested]

### Quality Gates
- [ ] Types: PASS/FAIL
- [ ] Lint: PASS/FAIL  
- [ ] Tests: PASS/FAIL (X passed, Y failed)
- [ ] Build: PASS/FAIL

### Notes for Reviewer
- [anything the reviewer should know]
```

CRITICAL: If ANY quality gate fails, fix it before reporting completion. Never skip this step.
