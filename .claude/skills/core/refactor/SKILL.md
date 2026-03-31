---
name: refactor
description: "Safe refactoring with evidence trail. Rename, extract, restructure code without breaking anything."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /refactor - Safe Refactoring

Refactor with confidence. Every change verified, nothing broken.

## Target
$ARGUMENTS

## Refactoring Rules

1. **Tests pass BEFORE you start** - If tests are already failing, fix them first
2. **One refactoring at a time** - Don't mix rename + restructure + optimize
3. **Tests pass AFTER each change** - Run tests after every meaningful change
4. **No behavior change** - Refactoring changes structure, not behavior
5. **Commit often** - Small, reversible commits

## Phase 1: Pre-Flight

```bash
# Ensure tests pass before refactoring
npm test 2>&1 || python -m pytest 2>&1 || go test ./... 2>&1
echo "Exit code: $?"

# Ensure types pass
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1
```

If tests fail → STOP. Fix tests first. Don't refactor broken code.

## Phase 2: Analysis

Understand the scope of change:
```bash
# Find all usages of the target
rg -n "TARGET_NAME" --glob '!node_modules' --glob '!.git' --glob '!dist'

# Find imports/exports
rg -n "import.*TARGET|export.*TARGET|require.*TARGET" --glob '*.{ts,tsx,js,jsx}'

# Find type references
rg -n "TARGET" --glob '*.{d.ts,types.ts}'
```

Map the blast radius:
```
### Blast Radius
- Files affected: [count]
- Direct references: [count]
- Transitive dependents: [count]
- Risk level: [Low/Med/High]
```

## Phase 3: Execute

### Common Refactoring Patterns

**Rename (Symbol)**
1. Find all references (imports, usages, types, tests)
2. Update all in one pass
3. Run tests

**Extract Function**
1. Identify the block to extract
2. Identify inputs (parameters) and outputs (return value)
3. Create function with descriptive name
4. Replace original block with function call
5. Run tests

**Extract Component (React)**
1. Identify self-contained JSX block
2. Identify props it needs
3. Create component file
4. Replace inline JSX with component
5. Run tests

**Move to Module**
1. Create new file in target location
2. Move code
3. Update all imports
4. Run tests
5. Delete old code (don't leave stubs)

**Simplify Conditionals**
1. Identify complex condition
2. Extract into named function or variable
3. Replace condition
4. Run tests

## Phase 4: Verify

```bash
# Tests still pass
npm test 2>&1 || python -m pytest 2>&1

# Types still pass
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1

# Lint passes
([ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ]) && npx eslint . --max-warnings=0 2>&1

# Build still works
npm run build 2>&1 || true
```

## Phase 5: Report

```
## Refactoring: [description]

### Changes
| Before | After | Reason |
|--------|-------|--------|
| [old pattern] | [new pattern] | [why this is better] |

### Files Modified
- [file]: [what changed]

### Verification
- [ ] Tests pass (before & after)
- [ ] Types check
- [ ] Lint clean
- [ ] Build succeeds
- [ ] No behavior change (same inputs → same outputs)

### Rollback
If issues arise: `git revert HEAD` (or specific commit hash)
```
