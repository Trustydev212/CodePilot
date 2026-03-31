---
name: audit
description: "Security audit, dependency check, OWASP Top 10 review, secret scanning. Find vulnerabilities before attackers do."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# /audit - Security & Project Health Audit

Comprehensive project audit: security, dependencies, code quality, performance.

## Scope
$ARGUMENTS

If no scope specified, run full audit.

## Phase 1: Secret Scanning (CRITICAL)

```bash
echo "=== SECRET SCAN ==="
# Hardcoded secrets
rg -i '(password|secret|api.?key|token|private.?key|access.?key)\s*[:=]\s*["\x27][^"\x27]{8,}' \
  --glob '!node_modules' --glob '!.git' --glob '!*.lock' --glob '!*.min.js' \
  --glob '!dist' --glob '!build' --glob '!coverage' 2>&1

# AWS credentials
rg 'AKIA[0-9A-Z]{16}' --glob '!node_modules' --glob '!.git' 2>&1

# Private keys
rg 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY' --glob '!node_modules' --glob '!.git' 2>&1

# .env files in repo (should be gitignored)
find . -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -name ".env.example" 2>&1
```

## Phase 2: Dependency Vulnerabilities

```bash
echo "=== DEPENDENCY AUDIT ==="
# Node.js
[ -f "package.json" ] && npm audit --production 2>&1

# Python
[ -f "requirements.txt" ] && pip audit 2>&1 || true
[ -f "pyproject.toml" ] && pip audit 2>&1 || true

# Check for outdated critical deps
[ -f "package.json" ] && npm outdated 2>&1 | head -20
```

## Phase 3: OWASP Top 10 Code Review

Check each vulnerability class:

### A01: Broken Access Control
```bash
# Routes without auth middleware
rg -n '(app\.(get|post|put|patch|delete)|router\.(get|post|put|patch|delete))' \
  --glob '*.{ts,js}' --glob '!node_modules' 2>&1 | head -30
# Look for: routes missing auth middleware, missing role checks
```

### A02: Cryptographic Failures
```bash
# Weak hashing
rg -n '(md5|sha1|sha256)\(' --glob '*.{ts,js,py}' --glob '!node_modules' 2>&1
# HTTP instead of HTTPS
rg -n 'http://' --glob '*.{ts,js,py,env}' --glob '!node_modules' --glob '!*.test.*' 2>&1
```

### A03: Injection
```bash
# SQL injection risks (string concatenation in queries)
rg -n '(query|execute)\s*\(\s*[`"'"'"'].*\$\{' --glob '*.{ts,js}' --glob '!node_modules' 2>&1
rg -n 'f".*SELECT|f".*INSERT|f".*UPDATE|f".*DELETE' --glob '*.py' 2>&1
# Command injection
rg -n 'exec\(|execSync\(|child_process' --glob '*.{ts,js}' --glob '!node_modules' 2>&1
# XSS
rg -n 'innerHTML|dangerouslySetInnerHTML|v-html' --glob '*.{tsx,jsx,vue}' --glob '!node_modules' 2>&1
```

### A04: Insecure Design
- Missing rate limiting on auth endpoints
- No account lockout after failed attempts
- Missing CSRF protection on state-changing routes
- No input size limits on file uploads

### A05: Security Misconfiguration
```bash
# CORS wildcards
rg -n "origin:\s*['\"]?\*" --glob '*.{ts,js}' --glob '!node_modules' 2>&1
# Debug mode in production configs
rg -n 'DEBUG\s*=\s*[Tt]rue|debug:\s*true' --glob '*.{ts,js,py,env}' --glob '!node_modules' 2>&1
# Default credentials
rg -n '(admin|root|test|password|123456)' --glob '.env*' 2>&1
```

### A07: Authentication Weaknesses
```bash
# JWT without expiration
rg -n 'sign\(' --glob '*.{ts,js}' --glob '!node_modules' -A 5 2>&1 | head -20
# Missing password requirements
rg -n 'password' --glob '*.schema.*' --glob '*.validation.*' 2>&1
```

## Phase 4: Performance Red Flags

```bash
echo "=== PERFORMANCE ==="
# N+1 queries (loop with await inside)
rg -n 'for.*await.*find|for.*await.*query|\.forEach.*await' \
  --glob '*.{ts,js,py}' --glob '!node_modules' --glob '!*.test.*' 2>&1

# Large bundle imports
rg -n "import .* from ['\"]lodash['\"]|import .* from ['\"]moment['\"]" \
  --glob '*.{ts,tsx,js,jsx}' --glob '!node_modules' 2>&1

# Missing pagination
rg -n 'findMany\(\s*\)|\.find\(\s*\{?\s*\}?\s*\)' \
  --glob '*.{ts,js}' --glob '!node_modules' --glob '!*.test.*' 2>&1
```

## Phase 5: Code Quality

```bash
echo "=== CODE QUALITY ==="
# TODO/FIXME/HACK comments (technical debt)
rg -n 'TODO|FIXME|HACK|XXX|WORKAROUND' \
  --glob '*.{ts,tsx,js,jsx,py}' --glob '!node_modules' 2>&1 | wc -l

# Any types (TypeScript)
rg -n ': any\b|as any\b' --glob '*.{ts,tsx}' --glob '!node_modules' --glob '!*.d.ts' 2>&1 | wc -l

# Console.log left in code
rg -n 'console\.(log|debug|info)\(' --glob '*.{ts,tsx,js,jsx}' \
  --glob '!node_modules' --glob '!*.test.*' --glob '!*.spec.*' 2>&1 | wc -l
```

## Audit Report Format

```
## Security & Health Audit Report

### Critical (Fix Immediately)
🔴 [Finding] - [file:line] - [impact] - [fix]

### High (Fix Before Next Release)
🟠 [Finding] - [file:line] - [impact] - [fix]

### Medium (Plan to Fix)
🟡 [Finding] - [file:line] - [impact] - [fix]

### Low (Nice to Have)
🔵 [Finding] - [file:line] - [impact] - [fix]

### Summary
| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Secrets | X | X | X | X |
| Dependencies | X | X | X | X |
| OWASP | X | X | X | X |
| Performance | X | X | X | X |
| Code Quality | X | X | X | X |

### Overall Health: CRITICAL / NEEDS ATTENTION / HEALTHY
```
