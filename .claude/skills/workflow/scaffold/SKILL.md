---
name: scaffold
description: "Generate project structures, feature modules, and boilerplate with stack-aware templates. From empty folder to running app."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /scaffold - Smart Project & Feature Scaffolding

Generate production-ready structures adapted to your stack. Not generic templates — real patterns.

## Target
$ARGUMENTS

## Phase 1: Detect Context

```bash
echo "=== DETECTING CONTEXT ==="

# Check if we're in an existing project or starting fresh
if [ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "go.mod" ] || [ -f "Cargo.toml" ]; then
  echo "MODE: Feature scaffold (existing project)"
  echo ""
  
  # Detect stack
  [ -f "next.config.mjs" ] || [ -f "next.config.js" ] || [ -f "next.config.ts" ] && echo "FRAMEWORK: Next.js"
  [ -f "nuxt.config.ts" ] && echo "FRAMEWORK: Nuxt"
  [ -f "vite.config.ts" ] && echo "FRAMEWORK: Vite"
  [ -f "tsconfig.json" ] && echo "LANG: TypeScript"
  [ -f "prisma/schema.prisma" ] && echo "ORM: Prisma"
  [ -f "drizzle.config.ts" ] && echo "ORM: Drizzle"
  [ -d "src/app" ] && echo "ROUTER: Next.js App Router"
  [ -d "src/pages" ] && echo "ROUTER: Pages Router"
  [ -f "tailwind.config.ts" ] || [ -f "tailwind.config.js" ] && echo "CSS: Tailwind"
  
  echo ""
  echo "=== EXISTING STRUCTURE ==="
  find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" \) | head -30
else
  echo "MODE: Project scaffold (new project)"
fi
```

## Phase 2: Determine Scaffold Type

Based on the target argument, determine what to scaffold:

### A. New Project Scaffolds

| Stack | What Gets Generated |
|-------|-------------------|
| **Next.js + Prisma** | App Router, auth, DB, API routes, Tailwind, testing |
| **Next.js + Drizzle** | App Router, auth, DB, API routes, Tailwind, testing |
| **FastAPI + SQLAlchemy** | Async API, migrations, auth, testing, Docker |
| **Express + Prisma** | REST API, auth, validation, testing, Docker |
| **Vite + React** | SPA, routing, state management, testing |
| **CLI Tool (Node)** | Commander/yargs, config, testing, publishing |
| **CLI Tool (Python)** | Click/typer, config, testing, publishing |

### B. Feature Scaffolds (Existing Project)

| Feature | Files Generated |
|---------|----------------|
| **CRUD resource** | Route + service + types + validation + tests |
| **Auth flow** | Login/register pages + API + middleware + tests |
| **Dashboard page** | Layout + widgets + data fetching + loading states |
| **Form with validation** | Component + schema + server action + tests |
| **API endpoint** | Route + validation + service + error handling + tests |
| **Database model** | Schema + migration + seed + types |
| **Email template** | React Email component + preview + send function |
| **Webhook handler** | Route + signature validation + retry logic + tests |
| **Background job** | Worker + queue setup + retry + monitoring |
| **File upload** | Component + API route + storage + validation |

## Phase 3: Generate Structure

### For New Projects

```
project-name/
├── src/
│   ├── app/                    # Routes (Next.js) or pages
│   │   ├── layout.tsx          # Root layout with providers
│   │   ├── page.tsx            # Landing page
│   │   ├── (auth)/             # Auth group
│   │   │   ├── login/page.tsx
│   │   │   └── register/page.tsx
│   │   ├── dashboard/
│   │   │   ├── layout.tsx      # Dashboard layout with sidebar
│   │   │   └── page.tsx
│   │   └── api/                # API routes
│   │       └── health/route.ts # Health check endpoint
│   ├── components/
│   │   ├── ui/                 # shadcn/ui components
│   │   └── [feature]/          # Feature-specific components
│   ├── lib/
│   │   ├── db.ts               # Database client
│   │   ├── auth.ts             # Auth configuration
│   │   ├── utils.ts            # Utility functions
│   │   └── validations/        # Zod schemas
│   ├── server/
│   │   ├── actions/            # Server actions
│   │   └── services/           # Business logic
│   └── types/                  # TypeScript types
├── prisma/
│   ├── schema.prisma           # Database schema
│   └── seed.ts                 # Seed data
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── public/
├── .env.example                # Environment template
├── .gitignore
├── docker-compose.yml          # Local dev services (DB, Redis)
├── package.json
├── tsconfig.json
├── tailwind.config.ts
└── README.md
```

### For Feature Scaffolds

#### CRUD Resource Example (e.g., `/scaffold crud:product`)

Generate these files following the existing project conventions:

1. **Schema/Types** — Zod validation schema + TypeScript types
2. **Database** — Prisma model or Drizzle table + migration
3. **API Route** — CRUD endpoints with validation and error handling
4. **Service Layer** — Business logic separated from routes
5. **UI Components** — List, detail, form components
6. **Server Actions** — Create, update, delete actions
7. **Tests** — Unit tests for service + integration tests for API

## Phase 4: Implement

Rules for generated code:
1. **Follow existing patterns** — Match the project's naming, structure, and style conventions
2. **Use real implementations** — No placeholder "TODO" code. Every file should be functional
3. **Include error handling** — Try/catch, error boundaries, loading states
4. **Add validation** — Zod schemas for all inputs
5. **Type everything** — Full TypeScript types, no `any`
6. **Include tests** — At least one test per service function and one integration test per endpoint

## Phase 5: Wire Up

After generating files:

```bash
# Install any new dependencies
npm install 2>&1 | tail -5

# Run database migration if schema changed
npx prisma migrate dev --name "add_[feature]" 2>/dev/null || \
npx drizzle-kit push 2>/dev/null || true

# Generate types
npx prisma generate 2>/dev/null || true

# Type check
npx tsc --noEmit 2>&1 | tail -10

# Run tests
npm test 2>&1 | tail -10
```

## Phase 6: Summary

```
## Scaffold Summary

### Generated Files
| File | Purpose |
|------|---------|
| [path] | [description] |

### Dependencies Added
- [package]: [why]

### Next Steps
1. [What the developer should customize]
2. [What to configure (env vars, etc.)]
3. [What to test manually]

### Run It
[Command to see the result: npm run dev, etc.]
```

RULE: Never generate boilerplate that the developer will delete. Every line should be code they'll keep and customize.
RULE: Match the existing project's conventions exactly. If they use kebab-case files, generate kebab-case. If they use barrel exports, add barrel exports.
RULE: Always check existing patterns with Grep/Glob before generating to avoid conflicts.
