---
name: index
description: "Index the codebase. Map architecture, dependencies, patterns. Build mental model fast for Claude or new team members."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# /index - Codebase Intelligence

Build a complete mental model of this codebase. Used by other skills to understand project context.

## Scope
$ARGUMENTS

If no scope: index the entire project.

## Phase 1: Project Overview

```bash
echo "=== PROJECT TYPE ==="
# Package manager & runtime
[ -f "package.json" ] && echo "Node.js: $(node -v 2>/dev/null || echo 'not available')"
[ -f "package.json" ] && echo "Package manager: $([ -f "pnpm-lock.yaml" ] && echo "pnpm" || ([ -f "yarn.lock" ] && echo "yarn" || echo "npm"))"
[ -f "pyproject.toml" ] && echo "Python: $(python3 --version 2>/dev/null || echo 'not available')"
[ -f "go.mod" ] && echo "Go: $(go version 2>/dev/null || echo 'not available')"
[ -f "Cargo.toml" ] && echo "Rust: $(rustc --version 2>/dev/null || echo 'not available')"

echo ""
echo "=== FRAMEWORKS ==="
[ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ] && echo "Next.js"
[ -f "nuxt.config.ts" ] || [ -f "nuxt.config.js" ] && echo "Nuxt"
[ -f "vite.config.ts" ] || [ -f "vite.config.js" ] && echo "Vite"
[ -f "angular.json" ] && echo "Angular"
grep -q "fastapi" requirements.txt 2>/dev/null && echo "FastAPI"
grep -q "django" requirements.txt 2>/dev/null && echo "Django"
grep -q "express" package.json 2>/dev/null && echo "Express"
grep -q "fastify" package.json 2>/dev/null && echo "Fastify"
grep -q "nestjs" package.json 2>/dev/null && echo "NestJS"

echo ""
echo "=== DATABASE ==="
[ -f "prisma/schema.prisma" ] && echo "Prisma ORM"
[ -f "drizzle.config.ts" ] || [ -f "drizzle.config.js" ] && echo "Drizzle ORM"
grep -q "mongoose" package.json 2>/dev/null && echo "MongoDB (Mongoose)"
grep -q "typeorm" package.json 2>/dev/null && echo "TypeORM"
grep -q "sqlalchemy" requirements.txt 2>/dev/null && echo "SQLAlchemy"

echo ""
echo "=== TESTING ==="
grep -q "vitest" package.json 2>/dev/null && echo "Vitest"
grep -q "jest" package.json 2>/dev/null && echo "Jest"
grep -q "playwright" package.json 2>/dev/null && echo "Playwright"
grep -q "cypress" package.json 2>/dev/null && echo "Cypress"
grep -q "pytest" requirements.txt 2>/dev/null && echo "Pytest"

echo ""
echo "=== DIRECTORY STRUCTURE ==="
find . -maxdepth 2 -type d \
  -not -path "*/node_modules*" \
  -not -path "*/.git*" \
  -not -path "*/dist*" \
  -not -path "*/build*" \
  -not -path "*/.next*" \
  -not -path "*/__pycache__*" | sort

echo ""
echo "=== FILE COUNTS ==="
echo "TypeScript: $(find . -name '*.ts' -o -name '*.tsx' | grep -v node_modules | wc -l)"
echo "JavaScript: $(find . -name '*.js' -o -name '*.jsx' | grep -v node_modules | wc -l)"
echo "Python: $(find . -name '*.py' | grep -v node_modules | wc -l)"
echo "Go: $(find . -name '*.go' | grep -v vendor | wc -l)"
echo "Tests: $(find . -name '*.test.*' -o -name '*.spec.*' | grep -v node_modules | wc -l)"
```

## Phase 2: Architecture Map

```bash
echo "=== ENTRY POINTS ==="
# Find main entry points
for f in "src/index.ts" "src/main.ts" "src/app.ts" "src/server.ts" "app/layout.tsx" "app/page.tsx" "main.py" "app.py" "main.go" "cmd/main.go"; do
  [ -f "$f" ] && echo "Entry: $f"
done

echo ""
echo "=== API ROUTES ==="
# Find API endpoint definitions
find . -path "*/api/*" -name "*.ts" -o -path "*/api/*" -name "*.py" | grep -v node_modules | sort | head -30

echo ""
echo "=== MODELS / SCHEMAS ==="
find . \( -name "*.model.*" -o -name "*.schema.*" -o -path "*/models/*" -o -path "*/schemas/*" \) | grep -v node_modules | sort | head -20

echo ""
echo "=== KEY CONFIG FILES ==="
for f in "tsconfig.json" ".eslintrc.js" "eslint.config.js" "prettier.config.js" ".prettierrc" "vitest.config.ts" "jest.config.ts" "playwright.config.ts" "docker-compose.yml" ".env.example" "Makefile"; do
  [ -f "$f" ] && echo "Config: $f"
done
```

## Phase 3: Dependency Graph

```bash
echo "=== KEY DEPENDENCIES ==="
if [ -f "package.json" ]; then
  echo "--- Production ---"
  cat package.json | jq -r '.dependencies // {} | keys[]' 2>/dev/null | sort
  echo ""
  echo "--- Dev ---"
  cat package.json | jq -r '.devDependencies // {} | keys[]' 2>/dev/null | sort
fi

if [ -f "requirements.txt" ]; then
  echo "--- Python Deps ---"
  cat requirements.txt | grep -v '^#' | grep -v '^$'
fi
```

## Output

```
## Codebase Index: [project name]

### Stack
- Runtime: [Node.js 20 / Python 3.12 / Go 1.22]
- Framework: [Next.js 15 / FastAPI / Express]
- Database: [PostgreSQL + Prisma / MongoDB + Mongoose]
- Testing: [Vitest + Playwright / Pytest]
- Deploy: [Vercel / Docker / Railway]

### Architecture
- Pattern: [monolith / modular monolith / microservices]
- Structure: [feature-based / layer-based / hybrid]
- API style: [REST / GraphQL / tRPC]

### Key Directories
- [dir]: [purpose]

### Entry Points
- [file]: [what it does]

### Key Patterns
- [pattern observed in codebase]

### Potential Issues
- [anything that looks off or risky]
```
