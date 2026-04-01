---
name: health
description: "Project health score dashboard — deps, test coverage, type coverage, bundle size, code quality metrics in one view."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /health — Project Health Dashboard

You are a project health monitor. Generate a comprehensive health report with scores.

## Target
$ARGUMENTS

## Phase 1: Gather Metrics

Run all checks in parallel where possible:

### 1. Dependencies Health
```bash
# Outdated packages
npm outdated --json 2>/dev/null || pip list --outdated --format=json 2>/dev/null

# Known vulnerabilities
npm audit --json 2>/dev/null || pip-audit --format=json 2>/dev/null || safety check --json 2>/dev/null

# Total dependency count
[ -f "package.json" ] && cat node_modules/.package-lock.json 2>/dev/null | jq '.packages | length' || echo "N/A"
```

### 2. Type Safety
```bash
# TypeScript strict mode?
[ -f "tsconfig.json" ] && cat tsconfig.json | jq '.compilerOptions.strict' 2>/dev/null

# Type errors count
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1 | tail -1

# Any files
[ -f "tsconfig.json" ] && rg ": any" --type ts -c 2>/dev/null | awk -F: '{sum+=$2} END {print sum}'
```

### 3. Test Coverage
```bash
# Run tests with coverage
npm test -- --coverage --silent 2>/dev/null || python -m pytest --cov --cov-report=term-missing --quiet 2>/dev/null

# Count test files vs source files
TEST_FILES=$(find . -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" | grep -v node_modules | wc -l)
SOURCE_FILES=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" | grep -v node_modules | grep -v test | grep -v spec | wc -l)
echo "Test files: $TEST_FILES / Source files: $SOURCE_FILES"
```

### 4. Code Quality
```bash
# Lint errors
npx eslint . --format json 2>/dev/null | jq '[.[] | .errorCount] | add' || echo "N/A"

# TODO/FIXME/HACK count
rg -c "TODO|FIXME|HACK|XXX" --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs}' -t code 2>/dev/null | awk -F: '{sum+=$2} END {print sum}'

# Console.log / debug statements
rg -c "console\.(log|debug)|debugger|print\(" --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs}' -t code 2>/dev/null | awk -F: '{sum+=$2} END {print sum}'

# Large files (>300 lines)
find . -name "*.ts" -o -name "*.tsx" -o -name "*.py" | grep -v node_modules | xargs wc -l 2>/dev/null | awk '$1 > 300 {print}' | grep -v total
```

### 5. Build Health
```bash
# Build succeeds?
[ -f "package.json" ] && timeout 120 npm run build 2>&1 | tail -5

# Bundle size (if Next.js or webpack)
[ -d ".next" ] && du -sh .next/ 2>/dev/null
[ -d "dist" ] && du -sh dist/ 2>/dev/null
```

### 6. Security
```bash
# Hardcoded secrets
rg -l "(password|secret|api_key|token)\s*[:=]\s*['\"][^'\"]{8,}" --type-add 'code:*.{ts,tsx,js,jsx,py,go,rs}' -t code 2>/dev/null | grep -v test | grep -v mock

# .env in git?
git ls-files | grep -E '\.env$|\.env\.local$|\.env\.production$'

# Permissions
find . -perm 777 -type f 2>/dev/null | head -5
```

### 7. Git Health
```bash
# Uncommitted changes
git status --porcelain | wc -l

# Last commit age
git log -1 --format="%cr"

# Branch count
git branch -r | wc -l

# Large files in repo
git ls-files | xargs ls -la 2>/dev/null | awk '$5 > 1048576 {print $5, $9}' | sort -rn | head -5
```

## Phase 2: Score

Calculate health score (0-100) per category:

| Category | Weight | Scoring |
|----------|--------|---------|
| Dependencies | 15% | -5 per critical vuln, -2 per high, -1 per outdated |
| Type Safety | 20% | 100 if strict + 0 errors, -10 per `any`, -5 per error |
| Test Coverage | 20% | Direct % from coverage report |
| Code Quality | 15% | -2 per lint error, -1 per TODO/FIXME, -3 per debug stmt |
| Build | 15% | 100 if builds, 0 if not |
| Security | 10% | -20 per hardcoded secret, -10 per .env in git |
| Git Health | 5% | -5 per uncommitted file, based on commit recency |

**Overall Score = Weighted average**

## Phase 3: Report

```
PROJECT HEALTH REPORT

Overall Score: [XX]/100

| Category        | Score | Details             |
|-----------------|-------|---------------------|
| Dependencies    | XX/100| X outdated, Y vulns |
| Type Safety     | XX/100| X errors, Y `any`s  |
| Test Coverage   | XX/100| XX% coverage        |
| Code Quality    | XX/100| X lint, Y TODOs     |
| Build           | XX/100| passes / fails      |
| Security        | XX/100| X issues found      |
| Git Health      | XX/100| X uncommitted       |

Critical Issues (fix immediately):
- [list critical items]

Warnings (fix soon):
- [list warnings]

Good:
- [list things that are healthy]

Recommendations (priority order):
1. [most impactful improvement]
2. [second most impactful]
3. [third]
```

## Phase 4: Save (optional)

If $ARGUMENTS contains "save":
- Write report to `HEALTH-REPORT.md`
- Include timestamp for tracking over time

## Rules

1. **Measure, don't guess** — every score backed by real data
2. **Prioritize by impact** — critical issues first
3. **Be actionable** — every finding includes how to fix it
4. **No false alarms** — verify before reporting
5. **Fast** — entire health check should take < 60 seconds
