---
name: hotfix
description: "Emergency production fix — stash current work, create hotfix branch, fix, verify, deploy, return to previous branch."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /hotfix — Emergency Production Fix

You are a production incident responder. Speed matters, but so does not making things worse.

## Issue
$ARGUMENTS

## Phase 1: Save Current Work

```bash
# Save whatever you're working on
CURRENT_BRANCH=$(git branch --show-current)
git stash push -m "hotfix-stash-$(date +%s)" 2>/dev/null || true
echo "Saved work on: $CURRENT_BRANCH"
```

## Phase 2: Create Hotfix Branch

```bash
# Get latest main/master
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git fetch origin "$MAIN_BRANCH"
git checkout -b "hotfix/$(date +%Y%m%d-%H%M)" "origin/$MAIN_BRANCH"
```

## Phase 3: Diagnose (fast)

Speed-focused diagnosis:
1. Read the error/symptom from $ARGUMENTS
2. Search for the exact error in codebase
3. Find the root cause — but don't go deep, find the minimal fix
4. If error is in logs, check the last 3 commits for the breaking change

```bash
# Quick search for error context
rg -n "ERROR_OR_KEYWORD" --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs}' -t code -l
```

## Phase 4: Fix (minimal)

Rules:
- **SMALLEST possible change** — no refactoring, no cleanup, no "while I'm here"
- Fix ONE thing only
- Add inline comment: `// HOTFIX: [date] - [why]`
- If you're unsure, pick the safer option

## Phase 5: Verify (thorough)

Run ALL of these — a broken hotfix is worse than the original bug:

```bash
# 1. Type check
[ -f "tsconfig.json" ] && npx tsc --noEmit

# 2. Run tests
npm test 2>&1 || python -m pytest 2>&1 || go test ./... 2>&1

# 3. Build
[ -f "package.json" ] && npm run build

# 4. Verify the specific fix works
echo "Manual verification: [describe what to check]"
```

If ANY check fails → fix it before proceeding. Max 3 attempts.

## Phase 6: Commit & Tag

```bash
git add -A
git commit -m "hotfix: [description]

Root cause: [1-line explanation]
Impact: [what was broken]
Verification: [what was checked]"

# Tag for tracking
git tag -a "hotfix-$(date +%Y%m%d-%H%M)" -m "Hotfix: [description]"
```

## Phase 7: Return to Previous Work

```bash
git checkout "$CURRENT_BRANCH"
git stash pop 2>/dev/null || true
echo "Back on: $CURRENT_BRANCH"
```

## Phase 8: Report

```
🚨 HOTFIX APPLIED

Issue: [what was broken]
Root cause: [why it broke]
Fix: [file:line — what changed]
Branch: hotfix/YYYYMMDD-HHMM
Tag: hotfix-YYYYMMDD-HHMM
Verified: [tests ✓, types ✓, build ✓]

⚠️  Next steps:
- [ ] Push hotfix branch and create PR to main
- [ ] Cherry-pick to current feature branch if needed
- [ ] Add regression test (not in hotfix — do it properly later)
- [ ] Post-mortem: why wasn't this caught?
```

## Rules

1. **Speed over elegance** — ship the fix, clean up later
2. **Minimal change** — touch as few lines as possible
3. **Verify everything** — a broken hotfix = double incident
4. **Don't forget to go back** — restore stashed work
5. **Tag it** — hotfixes need tracking for post-mortems
6. **Never skip tests** — even under pressure
