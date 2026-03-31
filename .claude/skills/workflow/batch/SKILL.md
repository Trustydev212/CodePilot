---
name: batch
description: "Apply changes across multiple files in parallel. Bulk refactoring, renaming, pattern replacement across the entire codebase."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /batch - Parallel Codebase Changes

Apply bulk changes across many files safely. Rename, replace, add, remove, or transform patterns with preview, confirmation, and verification.

## Input
Batch operation: $ARGUMENTS

## Phase 1: Parse Intent

Classify the operation into one of these categories:

| Category | Example | What Happens |
|----------|---------|-------------|
| **rename** | `rename userId to memberId across src/` | Rename variable, function, class, type, or file references |
| **replace** | `replace console.log with logger.info in src/server/` | Swap one pattern for another |
| **add** | `add "use client" to all components using useState` | Insert code at specific locations in matching files |
| **remove** | `remove unused imports` | Delete matching code from files |
| **transform** | `convert require() to import` | Convert one code pattern to another |

Parse from $ARGUMENTS:
- **Action**: rename / replace / add / remove / transform
- **Search pattern**: What to find (regex or literal)
- **Replacement**: What to change it to (if applicable)
- **Scope**: Directory or file glob to target (default: entire project)
- **Flags**: `--yes` (skip confirmation), `--dry-run` (preview only)

Output:
```
## Batch Operation
- **Action**: [category]
- **Find**: [pattern]
- **Replace with**: [replacement or N/A]
- **Scope**: [directory/glob]
- **Flags**: [any flags]
```

## Phase 2: Scope Discovery

Find every affected file. Always exclude these directories:
- `node_modules/`, `dist/`, `.next/`, `build/`, `__pycache__/`
- `.git/`, `coverage/`, `.turbo/`, `.nuxt/`, `.output/`
- `vendor/`, `target/`, `.venv/`, `venv/`

Use Grep/Glob to locate all matches, then build a summary table:

```
## Affected Files

| # | File | Lines | Current | Proposed |
|---|------|-------|---------|----------|
| 1 | src/api/users.ts | 12, 45 | userId | memberId |
| 2 | src/types/auth.ts | 8 | userId | memberId |
| ... | ... | ... | ... | ... |

### By Directory
- src/api/ — 4 files
- src/types/ — 2 files
- src/components/ — 8 files

**Total: X files, Y occurrences**
```

RULE: If zero matches found, report it and stop. Do not fabricate changes.

## Phase 3: Dry Run

Show exact before/after diffs for the first 5 files:

```
### Preview: src/api/users.ts

- Line 12:
  - const userId = req.params.id;
  + const memberId = req.params.id;

- Line 45:
  - return { userId, name, email };
  + return { memberId, name, email };

### Preview: src/types/auth.ts
...

[Showing 5 of X files. Remaining files follow the same pattern.]
```

If `--dry-run` flag is present, stop here and report the full summary.

If `--yes` flag is NOT present, ask:
```
Proceed with batch changes to X files (Y occurrences)? [y/N]
```

Wait for user confirmation before continuing.

## Phase 4: Execute

### Step 1: Create Git Checkpoint

```bash
git add -A && git commit -m "checkpoint: before batch operation" --allow-empty 2>/dev/null || true
```

### Step 2: Apply Changes

Apply changes file by file using the Edit tool:
- For each file, use Edit with the exact `old_string` and `new_string`
- Track progress and report after every batch of files:

```
Applying changes... [3/14 files]
  ✓ src/api/users.ts (2 changes)
  ✓ src/types/auth.ts (1 change)
  ✓ src/components/UserProfile.tsx (3 changes)
  ...
```

If more than 10 files are affected, use the Agent tool to parallelize:
- Split files into batches
- Process each batch with a sub-agent
- Collect results from all agents

### Step 3: Track Failures

If any file fails to update (Edit mismatch, read error, etc.), log it:
```
⚠ Failed: src/legacy/old-module.ts — old_string not found (file may have changed)
```

Continue with remaining files. Report all failures at the end.

## Phase 5: Verify

Run quality gates to ensure nothing broke:

```bash
# TypeScript type check
if [ -f "tsconfig.json" ]; then
  npx tsc --noEmit 2>&1 | tail -20
fi

# Lint
if [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
  npx eslint --max-warnings=0 . 2>&1 | tail -20
fi

# Tests
if [ -f "vitest.config.ts" ]; then
  npx vitest run --reporter=verbose 2>&1 | tail -30
elif [ -f "jest.config.ts" ] || [ -f "jest.config.js" ]; then
  npx jest --verbose 2>&1 | tail -30
fi
```

## Phase 6: Report

```
## Batch Complete

### Operation
[rename/replace/add/remove/transform]: [description]

### Results
| Metric | Count |
|--------|-------|
| Files modified | X |
| Total changes | Y |
| Lines changed | Z |
| Failures | N |

### Quality Gates
- [ ] Types: PASS/FAIL
- [ ] Lint: PASS/FAIL
- [ ] Tests: PASS/FAIL (X passed, Y failed)

### Rollback
If anything went wrong, run:
git revert HEAD --no-edit
```

## Examples

### Rename across codebase
```
/batch rename userId to memberId across src/
```

### Add directive to components
```
/batch add "use client" to all components using useState
```

### Replace logging calls
```
/batch replace console.log with logger.info in src/server/
```

### Remove dead code
```
/batch remove unused imports
```

### Transform patterns
```
/batch transform "require(...)" to "import ... from ..." in src/
```

## Rules

RULE: Always show preview before executing. Never modify files without confirmation (unless `--yes`).
RULE: Skip `node_modules/`, `dist/`, `.next/`, `build/`, `__pycache__/`, and other generated directories.
RULE: Create a git checkpoint before batch operations so changes can be reverted.
RULE: Report exact count of files modified, occurrences changed, and lines affected.
RULE: If type check or tests fail after changes, report the failures clearly.
RULE: For rename operations, handle all forms: camelCase, PascalCase, UPPER_CASE, kebab-case, snake_case variations when the user's intent implies it.
