---
name: issue
description: "Turn GitHub issues into implementations. Read issue, plan, implement, test, create PR. Full issue-to-PR pipeline."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /issue — Issue-to-PR Pipeline

Transform a GitHub issue into a complete implementation with tests and PR.

## Usage

```
/issue 42                              # Implement issue #42
/issue 42 --plan-only                  # Show plan without implementing
/issue 42 --yes                        # Skip confirmation, implement directly
```

## Execution Protocol

### Phase 1: Read Issue

1. Parse `$ARGUMENTS` for issue number or URL
2. Fetch issue details using GitHub MCP tools or `gh issue view`:
   - Title, body, labels, assignee
   - Linked issues and PRs
   - Comments (may contain clarifications)
3. Classify issue type from labels/content:
   - `bug` → fix branch, regression test
   - `feature` → feature branch, new tests
   - `enhancement` → feature branch, update tests
   - `docs` → docs branch, no tests needed
   - `chore` → chore branch, minimal tests

### Phase 2: Analyze & Plan

1. Extract requirements from issue description
2. Search codebase for relevant files:
   - Grep for keywords mentioned in the issue
   - Find related components, services, routes
   - Identify test files to update
3. Create implementation plan:

```
## Implementation Plan for #42

### Issue: Fix user session timeout after 15 minutes
Type: Bug | Complexity: Medium

### Root Cause Analysis
- Session TTL hardcoded to 900s in src/auth/config.ts:12
- No refresh mechanism when user is active

### Changes Required
| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | src/auth/config.ts | Modify | Make TTL configurable via env var |
| 2 | src/auth/session.ts | Modify | Add sliding window refresh |
| 3 | src/middleware/auth.ts | Modify | Call refresh on each request |
| 4 | tests/auth/session.test.ts | Create | Add timeout + refresh tests |

### Dependencies & Risks
- Changing session logic affects all authenticated routes
- Need to test with concurrent sessions

### Test Strategy
- Unit: session refresh logic
- Integration: middleware chain with auth
- Regression: existing auth tests must pass
```

4. If `--plan-only` flag: display plan and stop
5. Otherwise: show plan and ask for confirmation (unless `--yes`)

### Phase 3: Implement

1. Create feature branch:
   ```bash
   git checkout -b fix/issue-42-session-timeout  # bug
   git checkout -b feature/issue-42-user-export   # feature
   ```

2. Implement changes following the plan:
   - Follow existing code conventions (naming, structure, patterns)
   - Add proper error handling
   - Add input validation where needed
   - Write clean, maintainable code

3. Write tests:
   - Unit tests for new/changed functions
   - Integration tests for API changes
   - Regression tests for bug fixes (reproduce the bug first)

### Phase 4: Verify

Run all quality gates:

```bash
npx tsc --noEmit
npx eslint . --ext .ts,.tsx
npm test
npm run build
```

If any check fails:
- Fix the issue
- Re-run verification
- Use `/loop quality` approach if multiple issues

### Phase 5: Ship

1. Stage and commit with conventional commit:
   ```
   fix(auth): extend session timeout with sliding refresh

   - Make session TTL configurable via SESSION_TTL_SECONDS env var
   - Add sliding window refresh on active requests
   - Default TTL increased from 15min to 30min

   Fixes #42
   ```

2. Push branch:
   ```bash
   git push -u origin fix/issue-42-session-timeout
   ```

3. Create PR linking to the issue with `Fixes #N` or `Closes #N`

### Phase 6: Report

```
## Issue #42 → PR #45

### Fix: User session timeout after 15 minutes
- Type: Bug fix
- Branch: fix/issue-42-session-timeout
- Files changed: 4
- Lines: +87 -12
- Tests added: 3

### Changes
| File | Change |
|------|--------|
| src/auth/config.ts | Made TTL configurable via env var |
| src/auth/session.ts | Added sliding window refresh |
| src/middleware/auth.ts | Added refresh call on requests |
| tests/auth/session.test.ts | Added timeout + refresh tests |

### Quality Gates
- [x] Types pass
- [x] Lint clean
- [x] Tests pass (49/49, +3 new)
- [x] Build success

### PR: fix/issue-42-session-timeout → main
Fixes #42
```

## Branch Naming Convention

| Issue Type | Branch Pattern | Commit Prefix |
|-----------|----------------|---------------|
| Bug | `fix/issue-{N}-{slug}` | `fix(scope):` |
| Feature | `feature/issue-{N}-{slug}` | `feat(scope):` |
| Enhancement | `feature/issue-{N}-{slug}` | `feat(scope):` |
| Docs | `docs/issue-{N}-{slug}` | `docs(scope):` |
| Chore | `chore/issue-{N}-{slug}` | `chore(scope):` |

## Rules

- ALWAYS link PR to issue with `Fixes #N` or `Closes #N`
- NEVER commit directly to main — always create a feature branch
- Follow existing project commit conventions
- Show plan and get confirmation before implementing (unless `--yes`)
- Create regression test for every bug fix
- Keep PR focused — one issue per PR, no scope creep
- If issue is too large (>500 lines changed), suggest breaking into sub-issues
