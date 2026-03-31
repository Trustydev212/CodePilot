---
name: ship
description: "Pre-flight checks, build verification, and deploy preparation. Ensures code is production-ready before shipping."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# /ship - Ship to Production

You are the final quality gate before production. Be thorough but fast.

## Target
$ARGUMENTS

## Pre-Flight Checklist

Run ALL checks in parallel where possible:

### 1. Code Quality
```bash
# Type checking
[ -f "tsconfig.json" ] && echo "=== TypeScript ===" && npx tsc --noEmit 2>&1

# Linting
([ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]) && echo "=== ESLint ===" && npx eslint . --max-warnings=0 2>&1

# Python
[ -f "pyproject.toml" ] && echo "=== Python ===" && (python -m mypy . 2>&1 || true) && (python -m ruff check . 2>&1 || true)
```

### 2. Tests
```bash
# Run full test suite
echo "=== Tests ==="
if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then
  npx vitest run --reporter=verbose 2>&1
elif [ -f "jest.config.ts" ] || [ -f "jest.config.js" ] || grep -q '"jest"' package.json 2>/dev/null; then
  npx jest --verbose 2>&1
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
  python -m pytest -v 2>&1
elif [ -f "go.mod" ]; then
  go test ./... -v -count=1 2>&1
fi
```

### 3. Build
```bash
echo "=== Build ==="
if [ -f "package.json" ]; then
  npm run build 2>&1
elif [ -f "Makefile" ]; then
  make build 2>&1
elif [ -f "go.mod" ]; then
  go build ./... 2>&1
fi
```

### 4. Security Quick Scan
```bash
echo "=== Security ==="
# Check for leaked secrets
rg -i '(password|secret|api.?key|token|private.?key)\s*[:=]\s*["\x27][^"\x27]{8,}' \
  --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs,env}' -t code \
  --glob '!node_modules' --glob '!.git' --glob '!*.lock' 2>&1 | head -20

# Check for known vulnerable patterns
rg 'eval\(|innerHTML\s*=|dangerouslySetInnerHTML|exec\(|__proto__|prototype pollution' \
  --type-add 'code:*.{ts,tsx,js,jsx,py}' -t code \
  --glob '!node_modules' 2>&1 | head -10
```

### 5. Dependency Check
```bash
# Outdated/vulnerable deps
[ -f "package.json" ] && npm audit --production 2>&1 | tail -10
[ -f "requirements.txt" ] && pip audit 2>&1 | tail -10 || true
```

## Ship Report

```
## Ship Report

### Pre-Flight Results
| Check | Status | Details |
|-------|--------|---------|
| Types | PASS/FAIL | [errors if any] |
| Lint | PASS/FAIL | [warnings count] |
| Tests | PASS/FAIL | [X passed, Y failed] |
| Build | PASS/FAIL | [size if relevant] |
| Security | PASS/FAIL | [findings if any] |
| Deps | PASS/WARN/FAIL | [vulnerabilities] |

### Blockers
- [list any FAIL items - these MUST be fixed]

### Warnings (non-blocking)
- [list any WARN items]

### Ready to Ship: YES / NO
```

CRITICAL RULES:
- If ANY check FAILs, the answer is "NOT ready to ship"
- Fix blockers before re-running /ship
- Security findings are ALWAYS blockers
- Failed tests are ALWAYS blockers
- Lint warnings with --max-warnings=0 are blockers
