---
name: admin
description: "Admin panel generation. CRUD dashboards, data tables, filters, bulk actions, role-based admin access."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /admin — Admin Panel Generation

Generate admin dashboards with CRUD, filters, bulk actions.

## Usage

```
/admin setup                        # Admin layout and routes
/admin crud <model>                 # CRUD pages for model
/admin dashboard                    # Dashboard with stats
/admin users                        # User management
```

## Patterns

- Admin layout with role-based access
- CRUD: list (search, filter, sort, paginate), detail, create, edit
- Stats dashboard with charts
- Audit trail for admin actions

## Rules

- Require ADMIN/OWNER role
- Log all admin actions
- Implement soft delete
- Confirmation for destructive actions
- Paginate all lists
