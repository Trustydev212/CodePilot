---
name: docs
description: "Auto-generate documentation from code. API docs, component docs, architecture overviews, and README sections."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /docs - Smart Documentation Generator

Generate documentation that stays accurate because it's derived from actual code, not written separately.

## Target
$ARGUMENTS

## Phase 1: Analyze Codebase

```bash
echo "=== DOCUMENTATION SCAN ==="

# API routes
echo "--- API Endpoints ---"
find . -path "*/api/*" -name "*.ts" -o -name "*.py" | grep -v node_modules | grep -v __pycache__ | sort
find . -path "*/routes/*" -name "*.ts" -o -name "*.py" | grep -v node_modules | sort

# Components
echo ""
echo "--- Components ---"
find . -path "*/components/*" -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" | grep -v node_modules | head -30

# Services / Business Logic
echo ""
echo "--- Services ---"
find . -path "*/services/*" -o -path "*/lib/*" -o -path "*/utils/*" | grep -v node_modules | head -20

# Database models
echo ""
echo "--- Database Models ---"
[ -f "prisma/schema.prisma" ] && grep "^model " prisma/schema.prisma
find . -name "schema.ts" -path "*/db/*" -o -name "schema.ts" -path "*/drizzle/*" | grep -v node_modules

# Environment variables
echo ""
echo "--- Environment Variables Used ---"
grep -roh 'process\.env\.\w\+' --include="*.ts" --include="*.tsx" --include="*.js" . 2>/dev/null | sort -u | head -20
grep -roh 'os\.environ\[.\+\]' --include="*.py" . 2>/dev/null | sort -u | head -20

echo ""
echo "--- Package Info ---"
[ -f "package.json" ] && cat package.json | jq '{name, version, description, scripts: (.scripts | keys)}' 2>/dev/null
```

## Phase 2: Determine Documentation Type

Based on the target, generate the appropriate documentation:

### A. API Documentation (`/docs api`)

For each API endpoint, document:

```markdown
## API Reference

### Authentication
> All endpoints require `Authorization: Bearer <token>` unless marked as public.

---

### `POST /api/auth/login`
**Public**

Create a new session.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | ✓ | User email address |
| password | string | ✓ | Min 8 characters |

**Response:** `200 OK`
```json
{
  "token": "eyJhbG...",
  "user": { "id": "...", "email": "..." }
}
```

**Errors:**
| Status | Code | Description |
|--------|------|-------------|
| 401 | INVALID_CREDENTIALS | Email or password incorrect |
| 422 | VALIDATION_ERROR | Missing required fields |
```

**How to extract:**
1. Read each route file
2. Extract HTTP method from export name or decorator
3. Parse Zod/Pydantic schemas for request/response types
4. Find error handling for error codes
5. Check middleware for auth requirements

### B. Component Documentation (`/docs components`)

For each major component:

```markdown
## Components

### `<DataTable>`
**Path:** `src/components/ui/data-table.tsx`

**Props:**
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| columns | ColumnDef[] | required | Table column definitions |
| data | T[] | required | Array of data to display |
| searchKey | string | - | Enable search on this column |
| pagination | boolean | true | Show pagination controls |

**Usage:**
\`\`\`tsx
<DataTable
  columns={columns}
  data={products}
  searchKey="name"
/>
\`\`\`

**Dependencies:** @tanstack/react-table, lucide-react
```

### C. Architecture Documentation (`/docs architecture`)

```markdown
## Architecture Overview

### Tech Stack
| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | Next.js 15, React 19 | UI and SSR |
| Styling | Tailwind CSS, shadcn/ui | Design system |
| Backend | Next.js API Routes | REST API |
| Database | PostgreSQL + Prisma | Data persistence |
| Auth | NextAuth v5 | Authentication |
| Testing | Vitest, Playwright | Unit + E2E |

### Directory Structure
[Auto-generated from actual file tree]

### Data Flow
[Request → Middleware → Route Handler → Service → Database]

### Key Patterns
- **Server Components**: Default for data fetching, client components for interactivity
- **Server Actions**: Form mutations via `useActionState`
- **Repository Pattern**: Services abstract database queries
- **Zod Validation**: All inputs validated at API boundary
```

### D. Environment Documentation (`/docs env`)

```markdown
## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| DATABASE_URL | ✓ | - | PostgreSQL connection string |
| NEXTAUTH_SECRET | ✓ | - | Auth encryption key |
| NEXTAUTH_URL | ✓ | http://localhost:3000 | Auth callback URL |

### Setup
1. Copy `.env.example` to `.env`
2. Fill in required variables
3. Run `npx prisma migrate dev` to initialize database
```

### E. Full README Generation (`/docs readme`)

Generate a complete README.md with:
1. Project name + description (from package.json)
2. Quick start (install, configure, run)
3. Tech stack table
4. Project structure
5. Available scripts
6. Environment setup
7. API overview (summary, link to full docs)
8. Contributing guidelines
9. License

## Phase 3: Generate Documentation

Read the actual source code files and extract:
- Function signatures and their JSDoc/docstrings
- Type definitions and interfaces
- Zod schemas (convert to human-readable tables)
- Route definitions and HTTP methods
- Middleware chains and auth requirements
- Component props (from TypeScript interfaces)
- Database schema (from Prisma/Drizzle definitions)

## Phase 4: Write Documentation

Write the documentation to the appropriate location:
- API docs → `docs/api.md` or inline in README
- Component docs → `docs/components.md`
- Architecture → `docs/architecture.md`
- Full README → `README.md`

## Phase 5: Verify

```bash
# Check all links are valid (no broken references)
echo "=== VERIFICATION ==="

# Check markdown renders
if command -v npx &>/dev/null; then
  echo "Markdown files generated:"
  find docs/ -name "*.md" -exec wc -l {} \; 2>/dev/null
  wc -l README.md 2>/dev/null
fi

echo ""
echo "Documentation generated. Review and customize as needed."
```

RULE: Documentation must be generated from actual code, not imagined. Read every file before documenting it.
RULE: If a function has no JSDoc, infer the purpose from the function name, parameters, and usage — don't leave it blank.
RULE: Keep examples real — use actual types and values from the codebase, not generic "foo/bar" placeholders.
RULE: Always include a "Last generated" timestamp so developers know if docs are stale.
