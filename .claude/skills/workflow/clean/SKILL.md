---
name: clean
description: "Remove dead code, unused imports, unused variables, and unnecessary files. Safe cleanup with verification."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /clean — Dead Code Removal

You are a codebase janitor. Remove what's unused. Touch nothing that's used.

## Target
$ARGUMENTS

## Phase 1: Checkpoint

```bash
# Save a checkpoint before cleaning
git stash push -m "pre-clean-$(date +%s)" 2>/dev/null || true
git stash pop 2>/dev/null || true
# Remember current state so we can verify nothing breaks
```

## Phase 2: Detect Dead Code

### 2a. Unused Imports
```bash
# TypeScript/JavaScript
npx eslint . --rule '{"no-unused-vars": "warn", "@typescript-eslint/no-unused-vars": "warn", "import/no-unused-modules": "warn"}' --format json 2>/dev/null || true

# Python
python -m autoflake --check --remove-all-unused-imports -r . 2>/dev/null || true
```

### 2b. Unused Exports
Search for exports that are never imported anywhere:
```bash
# Find all exports
rg "export (const|function|class|type|interface|enum) (\w+)" --type ts -o | sort > /tmp/exports.txt

# For each export, check if it's imported elsewhere
# If not imported anywhere = dead export
```

### 2c. Unused Files
```bash
# Find files not imported by any other file
# Check for orphaned components, utilities, helpers
```

### 2d. Dead Patterns
Look for:
- Commented-out code blocks (more than 3 lines)
- `console.log` / `print()` debug statements
- Unused CSS classes (if tooling available)
- Empty files or files with only imports
- Deprecated functions still in codebase
- TODO/FIXME comments older than 6 months (check git blame)

## Phase 3: Classify

Organize findings by risk:

**Safe to remove** (no references anywhere):
- Unused imports
- Unused local variables
- Commented-out code
- Debug statements (`console.log`, `debugger`, `print`)

**Verify before removing** (might have side effects):
- Unused exports (could be used by external consumers)
- Unused files (could be dynamically imported)
- Unused CSS (could be used via string interpolation)

**Do NOT remove** (looks unused but isn't):
- Barrel exports (`index.ts` re-exports)
- Convention-based files (middleware, plugins, hooks auto-loaded)
- Test fixtures and mocks
- Type-only exports used in declaration files
- Environment-specific code (`if (process.env.NODE_ENV === ...`)

## Phase 4: Clean

For each category, clean in order:
1. **Unused imports** — remove with confidence
2. **Unused variables** — remove with confidence
3. **Debug statements** — remove `console.log`, `debugger`, `print()`
4. **Commented-out code** — remove blocks > 3 lines
5. **Unused exports** — remove only if confirmed unused
6. **Unused files** — remove only if confirmed unused

**Rules while cleaning:**
- One file at a time
- Run type check after each file
- If removing something breaks types → put it back
- Keep a list of everything removed

## Phase 5: Verify

```bash
# 1. Type check — must pass
[ -f "tsconfig.json" ] && npx tsc --noEmit

# 2. Lint — must pass
[ -f ".eslintrc*" ] || [ -f "eslint.config*" ] && npx eslint . --max-warnings=0

# 3. Tests — must pass
npm test 2>&1 || python -m pytest 2>&1 || go test ./... 2>&1

# 4. Build — must succeed
[ -f "package.json" ] && npm run build
```

If anything fails → revert the last change and report it as "couldn't clean."

## Phase 6: Report

```
🧹 CLEANED

Removed:
- [X] unused imports across [N] files
- [X] unused variables
- [X] debug statements (console.log, debugger)
- [X] lines of commented-out code
- [X] unused files

Kept (unsafe to remove):
- [list items that look unused but might have side effects]

Files changed: [count]
Lines removed: [count]
Verified: types ✓ | lint ✓ | tests ✓ | build ✓
```

## Rules

1. **When in doubt, keep it** — false positive removal breaks things
2. **Verify after every change** — type check is your safety net
3. **Don't refactor** — removing dead code is NOT refactoring
4. **Don't reorganize** — just remove, don't move things around
5. **Track everything** — list every removal in the report
6. **Barrel exports are sacred** — don't touch `index.ts` re-exports without checking consumers
