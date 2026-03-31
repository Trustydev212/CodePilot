---
name: db-migrate
description: "Database migration safety. Diff schema, generate migrations, test rollback, detect breaking changes."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /db-migrate — Safe Database Migration

Generate, validate, and apply database migrations with safety checks.

## Usage

```
/db-migrate                     # Generate migration from schema diff
/db-migrate check               # Validate pending migrations
/db-migrate rollback             # Generate rollback for last migration
/db-migrate status               # Show migration status
```

## Execution Protocol

### Phase 1: Detect ORM

- `prisma/schema.prisma` → Prisma
- `drizzle.config.*` → Drizzle
- `alembic.ini` → SQLAlchemy/Alembic
- `knexfile.*` → Knex.js
- `typeorm` in package.json → TypeORM

### Phase 2: Analyze Schema Changes

Compare current schema vs last migration. Show new tables, modified columns, dropped items, new indexes/relations.

### Phase 3: Safety Analysis

Flag dangerous operations:

| Operation | Risk | Mitigation |
|-----------|------|------------|
| DROP TABLE | CRITICAL | Backup first |
| DROP COLUMN | HIGH | Check references |
| NOT NULL without default | HIGH | Backfill first |
| Rename column | MEDIUM | May break code |
| Add unique constraint | MEDIUM | Check duplicates |
| Change column type | HIGH | Check compatibility |

### Phase 4: Generate Migration

Generate SQL/migration file. Review before applying.

### Phase 5: Generate Rollback

Create corresponding rollback script for every migration.

### Phase 6: Verify

Apply migration, regenerate client, run type check and tests.

## Rules

- ALWAYS review generated SQL before applying
- NEVER drop tables/columns without confirmation
- Generate rollback for every migration
- Backfill before NOT NULL constraints
- Check duplicates before unique constraints
- One logical change per migration file
- Descriptive migration names
