---
name: seed
description: "Generate database seed data from schema. Factory patterns, realistic fake data, and dev/test/demo dataset generation."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /seed - Database Seed Generator

Generate realistic seed data from your database schema. Not random gibberish — actual useful dev/test data.

## Target
$ARGUMENTS

## Phase 1: Analyze Schema

```bash
echo "=== DATABASE SCHEMA ANALYSIS ==="

# Prisma
if [ -f "prisma/schema.prisma" ]; then
  echo "ORM: Prisma"
  echo ""
  echo "--- Models ---"
  grep -E "^model |^\s+\w+\s+\w+" prisma/schema.prisma
  echo ""
  echo "--- Relations ---"
  grep -E "@relation|references:" prisma/schema.prisma
  echo ""
  echo "--- Existing seed ---"
  [ -f "prisma/seed.ts" ] && echo "seed.ts exists" && head -30 prisma/seed.ts
  [ -f "prisma/seed.js" ] && echo "seed.js exists" && head -30 prisma/seed.js
fi

# Drizzle
if [ -f "drizzle.config.ts" ] || [ -f "drizzle.config.js" ]; then
  echo "ORM: Drizzle"
  echo ""
  echo "--- Schema files ---"
  find . -path "*/db/schema*" -o -path "*/drizzle/schema*" | grep -v node_modules
fi

# SQLAlchemy
if grep -rq "SQLAlchemy\|sqlalchemy" --include="*.py" . 2>/dev/null; then
  echo "ORM: SQLAlchemy"
  echo ""
  echo "--- Model files ---"
  grep -rn "class.*Base\|class.*Model" --include="*.py" . | grep -v __pycache__ | grep -v .venv
fi
```

## Phase 2: Generate Seed Strategy

### Data Generation Rules

1. **Realistic data** — Use actual names, emails, addresses (not "test1", "test2")
2. **Referential integrity** — Create parent records before children
3. **Edge cases** — Include empty strings, long text, special characters, unicode
4. **Relationships** — Properly link related records
5. **Deterministic** — Same seed produces same data (use fixed seeds for faker)

### Seed Data Tiers

| Tier | Purpose | Records |
|------|---------|---------|
| **Minimal** | Quick dev setup | 5-10 per model |
| **Standard** | Full dev testing | 50-100 per model |
| **Demo** | Client demos | Curated, realistic scenarios |
| **Load test** | Performance testing | 1000+ per model |

## Phase 3: Generate Seed File

### Prisma Example Pattern

```typescript
// prisma/seed.ts
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database...");

  // Clear existing data (development only)
  if (process.env.NODE_ENV !== "production") {
    await prisma.$transaction([
      // Delete in reverse dependency order
      prisma.orderItem.deleteMany(),
      prisma.order.deleteMany(),
      prisma.product.deleteMany(),
      prisma.category.deleteMany(),
      prisma.user.deleteMany(),
    ]);
  }

  // 1. Users (no dependencies)
  const users = await Promise.all(
    seedUsers.map((user) => prisma.user.create({ data: user }))
  );
  console.log(`  ✓ ${users.length} users`);

  // 2. Categories (no dependencies)
  const categories = await Promise.all(
    seedCategories.map((cat) => prisma.category.create({ data: cat }))
  );
  console.log(`  ✓ ${categories.length} categories`);

  // 3. Products (depends on categories)
  const products = await Promise.all(
    seedProducts(categories).map((p) => prisma.product.create({ data: p }))
  );
  console.log(`  ✓ ${products.length} products`);

  // 4. Orders (depends on users + products)
  const orders = await Promise.all(
    seedOrders(users, products).map((o) =>
      prisma.order.create({ data: o })
    )
  );
  console.log(`  ✓ ${orders.length} orders`);

  console.log("🌱 Seeding complete!");
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

### Drizzle Example Pattern

```typescript
// src/db/seed.ts
import { db } from "./index";
import { users, categories, products, orders } from "./schema";

async function seed() {
  console.log("🌱 Seeding database...");
  
  // Insert with returning to get IDs
  const insertedUsers = await db
    .insert(users)
    .values(seedUsers)
    .returning();
  
  const insertedCategories = await db
    .insert(categories)
    .values(seedCategories)
    .returning();
    
  // Use returned IDs for relationships
  await db.insert(products).values(
    seedProducts(insertedCategories)
  );
  
  console.log("🌱 Seeding complete!");
}

seed().catch(console.error);
```

### Factory Pattern (Reusable)

```typescript
// tests/factories.ts
export function createUser(overrides?: Partial<User>): User {
  return {
    name: "Jane Smith",
    email: `user-${Date.now()}@example.com`,
    role: "USER",
    ...overrides,
  };
}

export function createProduct(
  categoryId: string,
  overrides?: Partial<Product>
): Product {
  return {
    name: "Sample Product",
    price: 2999, // cents
    categoryId,
    inStock: true,
    ...overrides,
  };
}
```

## Phase 4: Configure Seed Command

```bash
# Check if seed command exists in package.json
echo "=== SEED CONFIGURATION ==="
[ -f "package.json" ] && cat package.json | jq '.prisma.seed // .scripts.seed // .scripts["db:seed"] // "not configured"' 2>/dev/null
```

Add to package.json if not present:
```json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  },
  "scripts": {
    "db:seed": "tsx prisma/seed.ts",
    "db:reset": "prisma migrate reset"
  }
}
```

## Phase 5: Run Seed

```bash
# Run the seed
echo "=== RUNNING SEED ==="
if [ -f "prisma/schema.prisma" ]; then
  npx prisma db seed 2>&1
elif [ -f "package.json" ] && cat package.json | jq -e '.scripts["db:seed"]' &>/dev/null; then
  npm run db:seed 2>&1
fi
```

## Phase 6: Summary

```
## Seed Summary

### Generated
| Model | Records | Dependencies |
|-------|---------|-------------|
| User | 10 | - |
| Category | 5 | - |
| Product | 20 | Category |
| Order | 15 | User, Product |

### Files Created/Updated
- prisma/seed.ts (or src/db/seed.ts)
- tests/factories.ts (reusable factories)
- package.json (seed command added)

### Commands
- Seed: `npm run db:seed`
- Reset + seed: `npx prisma migrate reset`
- Factory usage: `import { createUser } from 'tests/factories'`
```

RULE: NEVER seed production databases. Always check NODE_ENV.
RULE: Delete in reverse dependency order, insert in dependency order.
RULE: Use deterministic data, not Math.random(). Tests should be reproducible.
RULE: Passwords in seed data must be pre-hashed, never stored as plaintext.
