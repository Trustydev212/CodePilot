---
name: loop
description: "Run recurring quality checks, watch for issues, continuously fix. Automated development loops until all checks pass."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /loop — Automated Development Loop

Run iterative fix-verify cycles until all quality gates pass or max iterations reached.

## Loop Types

Parse `$ARGUMENTS` to determine loop type:

### 1. Quality Loop (`/loop quality` or `/loop fix-all`)
Cycle: type check → lint → test → fix issues → repeat

### 2. Test Loop (`/loop tests`)
Cycle: run tests → fix failures → re-run → repeat until green

### 3. Lint Loop (`/loop lint`)
Cycle: run linter → auto-fix → re-run → repeat until clean

### 4. Type Loop (`/loop types`)
Cycle: run tsc → fix type errors → re-run → repeat until pass

### 5. Review Loop (`/loop review-fixes`)
Cycle: read review comments → apply fix → verify → next comment → repeat

### 6. Custom Loop (`/loop until "condition" do "action"`)
User-defined condition and action pair.

## Execution Protocol

### Phase 1: Setup
1. Parse loop type and parameters from `$ARGUMENTS`
2. Detect project stack (package.json → Node, pyproject.toml → Python, etc.)
3. Set max iterations (default: 10, override with `--max N`)
4. Create git checkpoint: `git stash push -m "loop-checkpoint-$(date +%s)"`

### Phase 2: Baseline
Run initial checks and record baseline error count:
```
Baseline: 5 type errors, 12 lint warnings, 2 test failures
```

### Phase 3: Iterate

For each iteration:

1. **Run check** — Execute the relevant command:
   - TypeScript: `npx tsc --noEmit 2>&1`
   - ESLint: `npx eslint . --format json 2>&1`
   - Tests: `npm test 2>&1` or `pytest 2>&1`
   - Python types: `mypy . 2>&1`

2. **Parse errors** — Extract error messages, file paths, line numbers

3. **Fix** — Apply targeted fixes using Edit tool:
   - Type errors: fix type annotations, add missing types
   - Lint errors: apply auto-fixable rules, manually fix the rest
   - Test failures: fix failing assertions, update snapshots

4. **Verify** — Re-run the same check to confirm fix worked

5. **Compare** — Count remaining errors vs previous iteration
   - If errors increased: STOP immediately, revert last change
   - If errors same after 2 attempts: skip this error, move to next
   - If zero errors: proceed to next check type (in quality loop)

### Phase 4: Report

Display summary table:

```
## Loop Summary

| Iteration | Check | Errors Before | Fixed | Remaining |
|-----------|-------|---------------|-------|-----------|
| 1 | tsc | 5 | 3 | 2 |
| 2 | tsc | 2 | 2 | 0 |
| 3 | eslint | 12 | 12 | 0 |
| 4 | jest | 2 | 2 | 0 |

Total iterations: 4
Total fixes: 19
Time elapsed: 2m 34s
Result: ALL CHECKS PASSING
```

## Exit Conditions

Stop the loop when ANY of these are true:
- All checks pass (success)
- Max iterations reached (default 10)
- Errors increased after a fix attempt (safety stop)
- Same error persists after 2 fix attempts (skip or stop)
- User interrupts

## Quality Loop Order

For `/loop quality`, run checks in this sequence:
1. Type checking (tsc / mypy)
2. Linting (eslint / ruff)
3. Tests (jest / pytest / vitest)
4. Build (npm run build / next build)

Only advance to next check when current check passes.

## Stack-Specific Commands

### Node.js / TypeScript
```bash
npx tsc --noEmit
npx eslint . --ext .ts,.tsx,.js,.jsx
npx jest --passWithNoTests  # or npx vitest run
npm run build
```

### Python
```bash
mypy .
ruff check . --fix
pytest
python -m build
```

### Go
```bash
go build ./...
golangci-lint run
go test ./...
```

## Rules

- ALWAYS create a git checkpoint before starting
- Maximum 10 iterations by default (prevent infinite loops)
- STOP if a fix makes things worse (more errors than before)
- Show progress after each iteration
- Report total changes and time at the end
- Never modify test expectations to make tests pass — fix the source code
- Skip `node_modules`, `dist`, `.next`, `build`, `__pycache__`
