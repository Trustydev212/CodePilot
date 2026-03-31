---
name: database
description: "PostgreSQL, MongoDB, Prisma, Drizzle ORM patterns. Schema design, migrations, query optimization, indexing strategy."
paths:
  - "**/prisma/**"
  - "**/drizzle/**"
  - "**/migrations/**"
  - "**/models/**"
  - "**/schema/**"
  - "**/*.sql"
---

# Database Expert

Design schemas that scale, write queries that perform, handle migrations safely.

## Auto-Detection

- `prisma/schema.prisma` → Prisma ORM
- `drizzle.config.*` → Drizzle ORM
- `*.sql` migration files → Raw SQL
- `models.py` → Django ORM / SQLAlchemy
- `mongodb` in dependencies → MongoDB

## Schema Design Principles

1. **Normalize first, denormalize for performance** - Start with 3NF, denormalize only with evidence
2. **Every table needs**: `id`, `created_at`, `updated_at`
3. **Use UUIDs** for public-facing IDs, auto-increment for internal
4. **Soft delete** for user data (`deleted_at` timestamp)
5. **Enums over strings** for fixed value sets
6. **Foreign keys always** - Data integrity is not optional

## Prisma Patterns

### Schema Design
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  role      Role     @default(USER)
  posts     Post[]
  orders    Order[]
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")

  @@map("users")
  @@index([email])
  @@index([role, createdAt])
}

model Post {
  id          String   @id @default(cuid())
  title       String
  content     String?  @db.Text
  published   Boolean  @default(false)
  author      User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId    String   @map("author_id")
  tags        Tag[]
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  @@map("posts")
  @@index([authorId])
  @@index([published, createdAt(sort: Desc)])
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

### Query Patterns - Avoid N+1
```typescript
// BAD: N+1 query
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } })
}

// GOOD: Include related data
const users = await prisma.user.findMany({
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
    _count: { select: { orders: true } }
  }
})

// GOOD: Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    _count: { select: { posts: true } }
  }
})
```

### Transactions
```typescript
// Multi-table operation - use transaction
const [order, payment] = await prisma.$transaction(async (tx) => {
  const order = await tx.order.create({
    data: { userId, items: { create: orderItems }, total }
  })

  const payment = await tx.payment.create({
    data: { orderId: order.id, amount: total, status: 'PENDING' }
  })

  await tx.user.update({
    where: { id: userId },
    data: { balance: { decrement: total } }
  })

  return [order, payment]
})
```

## Drizzle ORM Patterns

```typescript
import { pgTable, text, timestamp, boolean, integer, uuid } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: text('email').unique().notNull(),
  name: text('name').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
})

export const posts = pgTable('posts', {
  id: uuid('id').defaultRandom().primaryKey(),
  title: text('title').notNull(),
  content: text('content'),
  published: boolean('published').default(false).notNull(),
  authorId: uuid('author_id').references(() => users.id, { onDelete: 'cascade' }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  authorIdx: index('posts_author_idx').on(table.authorId),
  publishedIdx: index('posts_published_idx').on(table.published, table.createdAt),
}))

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))
```

## Indexing Strategy

### When to Add Indexes:
- Columns in `WHERE` clauses (frequently filtered)
- Columns in `ORDER BY` (sorted results)
- Foreign key columns (JOIN performance)
- Columns in `UNIQUE` constraints
- Composite indexes for multi-column queries

### When NOT to Index:
- Tables with <1000 rows (full scan is faster)
- Columns with low cardinality (boolean, status with 3 values)
- Columns that are mostly NULL
- Tables with heavy write traffic (each index slows writes)

### Composite Index Order Rule:
```sql
-- Query: WHERE status = 'active' AND created_at > '2026-01-01' ORDER BY created_at DESC
-- Index should be: (status, created_at DESC)
-- Rule: Equality columns first, then range/sort columns
CREATE INDEX idx_orders_status_created ON orders (status, created_at DESC);
```

## Migration Safety

```bash
# ALWAYS review migrations before applying
npx prisma migrate dev --name add_user_role --create-only
# Review the generated SQL, then apply:
npx prisma migrate dev

# Production: NEVER use migrate dev
npx prisma migrate deploy
```

### Safe Migration Checklist:
- [ ] Adding column? Use DEFAULT or make nullable (no downtime)
- [ ] Removing column? Remove code references first, then column in next deploy
- [ ] Renaming column? Create new → copy data → update code → drop old (3 deploys)
- [ ] Adding index? Use `CREATE INDEX CONCURRENTLY` (PostgreSQL) to avoid locks
- [ ] Changing type? Create new column → migrate data → swap → drop old
- [ ] Dropping table? Ensure no foreign keys reference it

## Performance Red Flags

- `SELECT *` - Only select columns you need
- No `LIMIT` on queries returning lists
- `LIKE '%text%'` - Use full-text search instead
- Joins across 4+ tables - Consider denormalization
- `COUNT(*)` on large tables - Use approximate counts or cache
- N+1 queries in loops - Use `include`, `join`, or batch queries
- Missing indexes on frequently queried columns - Check `EXPLAIN ANALYZE`
