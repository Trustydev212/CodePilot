---
name: fix
description: "Diagnose root cause of a bug, fix it, add regression test, verify nothing else broke."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /fix - Bug Fix Workflow

You are a senior debugger. Your job is to find the ROOT CAUSE, not just patch symptoms.

## Bug Report
$ARGUMENTS

## Phase 1: Reproduce (MANDATORY)

Before touching any code:
1. Understand the expected vs actual behavior
2. Find or create a minimal reproduction
3. If there's an error message, search the codebase for where it's thrown

```bash
# Search for error messages or related code
rg -n "ERROR_TEXT_OR_KEYWORD" --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs}' -t code
```

## Phase 2: Root Cause Analysis

Use the **5 Whys** technique:
1. **What** failed? → Identify the exact line/function
2. **Why** did it fail? → Trace the data flow backward
3. **Why** was that data wrong? → Find the source
4. **Why** wasn't this caught? → Missing validation/test
5. **What** is the minimal fix? → Smallest change that fixes root cause

### Debugging checklist:
- [ ] Read the full error stack trace
- [ ] Check recent changes to affected files (`git log --oneline -10 -- <file>`)
- [ ] Check if the bug exists in related code paths
- [ ] Verify assumptions about input data
- [ ] Check environment differences (dev vs prod config)

## Phase 3: Fix

Rules:
- Fix the ROOT CAUSE, not the symptom
- Make the MINIMAL change needed
- Don't refactor surrounding code (separate concern)
- If the fix is in a hot path, consider performance impact
- Add a code comment ONLY if the fix is non-obvious

## Phase 4: Regression Test

Write a test that:
1. **Fails** without your fix (proves the bug existed)
2. **Passes** with your fix (proves you fixed it)
3. **Tests the boundary** around the bug (prevents similar issues)

```
// Test name should describe the bug, not the fix
// BAD:  "should handle null input"
// GOOD: "should return empty array when user has no orders instead of crashing"
```

## Phase 5: Verify

```bash
# Run full test suite - nothing else should break
npm test 2>&1 || python -m pytest 2>&1 || go test ./... 2>&1

# Type check
[ -f "tsconfig.json" ] && npx tsc --noEmit
```

## Phase 6: Report

```
## Bug Fix: [title]

### Root Cause
[Explain WHY the bug happened, not just what you changed]

### Fix
- [file:line]: [what changed]

### Regression Test
- [test file]: [test name] - verifies [what]

### Verification
- [ ] Root cause identified (not just symptom patched)
- [ ] Regression test added
- [ ] Existing tests pass
- [ ] Types check
- [ ] No unrelated changes
```
