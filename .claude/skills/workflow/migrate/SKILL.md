---
name: migrate
description: "Safely upgrade dependencies and frameworks. Step-by-step migration with rollback plan and compatibility checks."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /migrate - Safe Dependency & Framework Migration

Upgrade dependencies without breaking your app. Step by step, with rollback at every stage.

## Target
$ARGUMENTS

## Phase 1: Assess Current State

```bash
echo "=== CURRENT VERSIONS ==="
if [ -f "package.json" ]; then
  echo "--- Node.js Dependencies ---"
  cat package.json | jq '.dependencies // {}' 2>/dev/null
  echo ""
  echo "--- Dev Dependencies ---"
  cat package.json | jq '.devDependencies // {}' 2>/dev/null
  echo ""
  echo "--- Outdated ---"
  npm outdated 2>&1 | head -30
fi

if [ -f "requirements.txt" ]; then
  echo "--- Python Dependencies ---"
  cat requirements.txt
fi

echo ""
echo "=== NODE/PYTHON VERSION ==="
node -v 2>/dev/null || true
python3 --version 2>/dev/null || true
```

## Phase 2: Create Checkpoint

```bash
# Save current state before any changes
git stash push -m "pre-migration-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
git tag "pre-migration/$(date +%Y%m%d-%H%M%S)" HEAD
echo "Checkpoint created. Rollback: git reset --hard <tag>"
```

## Phase 3: Research Breaking Changes

Before upgrading, check:
1. **Changelog/release notes** of the target package
2. **Migration guides** (major version upgrades)
3. **Peer dependency conflicts**
4. **Deprecated APIs** that your code uses

```bash
# Check for specific package changelogs
# npm view <package> versions --json | jq '.[-5:]'
# npm view <package> repository.url
```

## Phase 4: Upgrade Strategy

### For minor/patch updates (safe):
```bash
# Update all non-breaking
npm update
# Or specific package
npm install <package>@latest
```

### For major updates (careful):
Upgrade ONE package at a time:

```
1. Upgrade package
2. Fix compilation errors
3. Run tests
4. Fix test failures
5. Commit
6. Repeat for next package
```

### Dependency Upgrade Order:
1. **Build tools first** (TypeScript, ESLint, Vite, Webpack)
2. **Framework** (React, Next.js, FastAPI, Django)
3. **ORM/Database** (Prisma, Drizzle, SQLAlchemy)
4. **UI libraries** (Tailwind, shadcn/ui, MUI)
5. **Utilities last** (lodash, date-fns, zod)

## Phase 5: Execute Migration

For each package:

### 5a. Install new version
```bash
npm install <package>@<version>
```

### 5b. Fix TypeScript errors
```bash
npx tsc --noEmit 2>&1 | head -30
```

### 5c. Run tests
```bash
npm test 2>&1
```

### 5d. Fix breaking changes
- Check official migration guide
- Search codebase for deprecated APIs:
```bash
rg "deprecatedFunction|oldAPI|removedMethod" --glob '*.{ts,tsx,js,jsx}' --glob '!node_modules'
```

### 5e. Commit this package upgrade
```bash
git add package.json package-lock.json
git commit -m "chore(deps): upgrade <package> to v<version>"
```

## Phase 6: Verify

```bash
echo "=== POST-MIGRATION CHECKS ==="

# Types
[ -f "tsconfig.json" ] && echo "--- TypeScript ---" && npx tsc --noEmit 2>&1

# Lint
echo "--- Lint ---"
npx eslint . --max-warnings=0 2>&1 | tail -5

# Tests
echo "--- Tests ---"
npm test 2>&1 | tail -10

# Build
echo "--- Build ---"
npm run build 2>&1 | tail -10

# Audit
echo "--- Security ---"
npm audit --production 2>&1 | tail -10
```

## Migration Report

```
## Migration Report

### Upgraded
| Package | From | To | Breaking Changes |
|---------|------|----|-----------------|
| [name] | [old] | [new] | [yes/no - details] |

### Code Changes Required
- [file]: [what changed and why]

### Verification
- [ ] Types: PASS
- [ ] Lint: PASS
- [ ] Tests: PASS (X/X)
- [ ] Build: PASS
- [ ] Security audit: PASS

### Rollback
git reset --hard pre-migration/<timestamp>
```

## Common Framework Migrations

### Next.js 14 → 15
- `params` is now a `Promise` (await in server components)
- `searchParams` is now a `Promise`
- New `next.config.ts` support
- `fetch` caching changed (no-store by default)

### React 18 → 19
- New `use()` hook for promises and context
- `useActionState` replaces `useFormState`
- `ref` as prop (no `forwardRef` needed)
- Server Components stable

### Prisma 5 → 6
- JSON protocol by default
- Improved type safety for `$queryRaw`
- New `omit` field for excluding columns

RULE: Never upgrade more than one major version at a time. If on v3, go to v4 first, then v5.
