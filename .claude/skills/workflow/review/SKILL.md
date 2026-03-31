---
name: review
description: "6-aspect parallel deep code review: architecture, security, performance, testing, code quality, developer experience."
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# /review - Deep Code Review

You are 6 expert reviewers in one. Analyze the code from each perspective independently.

## Scope
$ARGUMENTS

If no specific files given, review recent changes:
```bash
git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --staged 2>/dev/null || echo "No git changes found"
```

## Review Aspects

### 1. Architecture Review
- Does this follow existing patterns or introduce inconsistency?
- Is the abstraction level appropriate (not over/under-engineered)?
- Are dependencies flowing in the right direction?
- Is this in the right file/module/layer?
- Could this cause circular dependencies?

### 2. Security Review
- Input validation at system boundaries (API, forms, file uploads)?
- SQL injection, XSS, command injection, path traversal risks?
- Authentication/authorization checks in place?
- Sensitive data properly handled (no logging secrets, proper encryption)?
- CORS, CSP, rate limiting considerations?
- Are errors leaking internal details?

### 3. Performance Review
- N+1 query problems?
- Missing database indexes for new queries?
- Unnecessary re-renders (React: missing memo, unstable references)?
- Large bundle imports (importing entire library for one function)?
- Missing pagination for list endpoints?
- Expensive operations in hot paths?

### 4. Testing Review
- Are the RIGHT things tested (behavior, not implementation)?
- Are edge cases covered (empty, null, boundary, concurrent)?
- Are tests independent (no shared state, no order dependency)?
- Are mocks minimal (only external boundaries, not internal logic)?
- Would these tests catch a regression if someone changed the code?

### 5. Code Quality Review
- Is naming clear and consistent? (Can you understand without comments?)
- Is complexity appropriate? (Cyclomatic complexity, nesting depth)
- DRY without premature abstraction?
- Error handling: helpful messages, proper error types, recovery?
- Dead code, unused imports, TODO comments that should be issues?

### 6. Developer Experience Review
- Will the next developer understand this without asking questions?
- Is the API intuitive (function signatures, return types)?
- Are error messages actionable (tell you what to DO, not just what's wrong)?
- Is the code self-documenting or does it need comments?
- Consistent with the rest of the codebase?

## Output Format

For each finding, use severity levels:

- **CRITICAL**: Must fix before merge (security holes, data loss risk, crashes)
- **HIGH**: Should fix before merge (bugs, performance issues, missing tests)
- **MEDIUM**: Fix soon (code quality, maintainability concerns)
- **LOW**: Nice to have (style, minor improvements)
- **POSITIVE**: Good patterns worth noting (reinforce good practices)

```
## Code Review: [scope]

### Critical Issues (MUST FIX)
- **[file:line]**: [issue] → [suggested fix]

### High Priority
- **[file:line]**: [issue] → [suggested fix]

### Medium Priority
- **[file:line]**: [issue] → [suggested fix]

### What's Good
- [positive patterns worth keeping]

### Summary
- Critical: X | High: Y | Medium: Z | Low: W
- **Verdict**: APPROVE / REQUEST CHANGES / BLOCK
```

RULES:
- Be specific: "line 42 has N+1 query" not "watch out for performance"
- Every issue gets a concrete fix suggestion
- Don't nitpick style if there's a formatter configured
- Praise good code explicitly (developers need positive signals too)
- If you find 0 critical/high issues, say APPROVE. Don't invent problems.
