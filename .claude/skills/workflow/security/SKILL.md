---
name: security
description: "Security scanning. Dependency audit, SAST, secrets detection, OWASP Top 10 check, CSP headers, rate limiting."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /security — Security Scan & Hardening

Comprehensive security analysis and automated fixes.

## Usage

```
/security                       # Full security scan
/security deps                  # Dependency vulnerability audit
/security secrets               # Scan for leaked secrets
/security headers               # Check HTTP security headers
/security api                   # API security audit
/security fix                   # Auto-fix common issues
```

## Execution Protocol

### Phase 1: Dependency Audit

Run `npm audit`, `pip-audit`, or `govulncheck`. Report vulnerabilities with severity, CVE, and fix availability.

### Phase 2: Secrets Scanning

Scan for API keys, AWS credentials, GitHub tokens, JWTs, private keys, connection strings, and generic passwords across source code, config files, and git history.

### Phase 3: OWASP Top 10

Check for: Broken Access Control, Cryptographic Failures, Injection, Insecure Design, Security Misconfiguration, Vulnerable Components, Auth Failures, Data Integrity, Logging Failures, SSRF.

### Phase 4: HTTP Security Headers

Verify: Strict-Transport-Security, X-Content-Type-Options, X-Frame-Options, Content-Security-Policy, Referrer-Policy, Permissions-Policy.

### Phase 5: API Security

Check auth middleware, input validation, rate limiting, CORS scope, error leakage, injection prevention.

### Phase 6: Auto-Fix (`/security fix`)

- Add security headers
- Replace Math.random() with crypto.randomUUID()
- Add input validation schemas
- Add rate limiting
- Fix SQL injection
- Add .env* to .gitignore

## Rules

- NEVER display actual secret values — mask them
- Treat leaked secrets as compromised
- Check git history, not just current files
- Rate limiting is mandatory for auth endpoints
- CORS * is never acceptable in production
- Passwords must use bcrypt/argon2
