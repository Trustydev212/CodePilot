---
name: saas-auth
description: "Enterprise auth for SaaS. Multi-tenancy, RBAC, team/org management, SSO, API keys, audit logs."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /saas-auth — Enterprise SaaS Authentication

Build production-grade auth for multi-tenant SaaS applications.

## Usage

```
/saas-auth setup                    # Full auth system setup
/saas-auth multi-tenant             # Add multi-tenancy
/saas-auth rbac                     # Role-based access control
/saas-auth sso                      # SSO (Google, GitHub, SAML)
/saas-auth api-keys                 # API key management
/saas-auth audit                    # Audit logging
```

## Key Patterns

- Organization model with members, roles, invitations
- Tenant isolation (subdomain or path-based)
- RBAC with granular permissions (members:read, data:write, etc.)
- API key generation with SHA-256 hashing (never store plaintext)
- Audit logging for all auth events
- Rate limiting on login endpoints
- Session management with refresh token rotation

## Rules

- ALWAYS hash API keys before storing
- Tenant data isolation is mandatory
- Rate limit auth endpoints
- Log all auth events to audit trail
- Rotate refresh tokens on every use
- Invitation tokens must expire (24-48h)
- Implement account lockout after repeated failures
