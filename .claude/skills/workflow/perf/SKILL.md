---
name: perf
description: "Performance benchmarking, bundle analysis, and regression detection. Measure before and after every optimization."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /perf — Performance Analysis & Optimization

Measure, analyze, and optimize performance with data-driven decisions.

## Usage

```
/perf bundle          # Analyze JS bundle sizes
/perf api             # Profile API endpoint latency
/perf render          # React component render performance
/perf query           # Database query analysis
/perf lighthouse      # Run Lighthouse audit
/perf compare         # Before/after comparison
```

## Execution Protocol

### Phase 1: Detect Context

Parse `$ARGUMENTS` to determine analysis type. Auto-detect stack:
- `package.json` → Node.js / frontend bundle analysis
- `next.config.*` → Next.js specific (bundle analyzer, ISR, SSR)
- `prisma/schema.prisma` → Database query analysis
- React components → Render performance

### Phase 2: Baseline Measurement

**Always measure before making changes.**

#### Bundle Analysis
```bash
# Next.js
ANALYZE=true npx next build 2>&1

# Webpack
npx webpack --profile --json > stats.json

# Vite
npx vite build --report

# Generic
npm run build 2>&1
du -sh dist/ .next/ build/ 2>/dev/null
```

Record for each chunk/entry:
- File name, raw size, gzipped size
- Largest dependencies

#### API Latency
```bash
for i in {1..10}; do
  curl -o /dev/null -s -w "%{time_total}\n" http://localhost:3000/api/endpoint
done

# Or load testing
npx autocannon -d 10 -c 10 http://localhost:3000/api/endpoint
```

Record: P50, P95, P99 latency, requests/sec, error rate

#### Database Queries
```sql
EXPLAIN ANALYZE SELECT ...;
```

Record: execution time, rows scanned, index usage, sequential scans

#### Lighthouse
```bash
npx lighthouse http://localhost:3000 --output json --chrome-flags="--headless"
```

Record: Performance, Accessibility, Best Practices, SEO scores

### Phase 3: Analyze Bottlenecks

#### Bundle Bottlenecks
1. Find largest dependencies with `npx depcheck`
2. Check for tree-shaking issues (barrel file imports, CommonJS modules)
3. Find duplicate dependencies in bundle
4. Check for large polyfills or unused locales

#### API Bottlenecks
1. Identify N+1 query patterns (ORM logs)
2. Missing database indexes
3. Unoptimized serialization
4. Missing response caching
5. Synchronous operations that could be async

#### Render Bottlenecks
1. Unnecessary re-renders (missing React.memo, useMemo, useCallback)
2. Large component trees without virtualization
3. Expensive computations in render path
4. Missing Suspense boundaries

### Phase 4: Optimize

Apply targeted fixes based on analysis:

#### Bundle Optimizations
```typescript
// Dynamic imports for heavy libraries
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />
})

// Replace heavy dependencies
// moment (300KB) → dayjs (2KB)
// lodash (72KB) → lodash-es (tree-shakeable) or native

// Optimize imports — avoid barrel files
import { Button } from '@/components/ui/Button'  // specific
// NOT: import { Button } from '@/components/ui'  // barrel
```

#### API Optimizations
```typescript
// Add response caching
res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate')

// Batch database queries
const [users, posts] = await Promise.all([
  db.user.findMany({ where: { active: true } }),
  db.post.findMany({ where: { published: true } })
])

// Add database indexes
// schema.prisma: @@index([userId, createdAt])
```

#### Render Optimizations
```typescript
// Memoize expensive components
const ExpensiveList = React.memo(({ items }) => (
  <VirtualList height={600} itemCount={items.length} itemSize={50}>
    {({ index, style }) => <Item key={items[index].id} style={style} {...items[index]} />}
  </VirtualList>
))

// Memoize expensive computations
const sortedData = useMemo(() => 
  data.sort((a, b) => b.score - a.score), 
  [data]
)
```

### Phase 5: Compare & Report

```
## Performance Report

### Bundle Analysis
| Chunk | Before | After | Change |
|-------|--------|-------|--------|
| main.js | 245 KB | 198 KB | -19.2% |
| vendor.js | 890 KB | 720 KB | -19.1% |
| Total (gzip) | 1.13 MB | 918 KB | -18.8% |

### API Performance
| Endpoint | P50 Before | P50 After | Change |
|----------|-----------|-----------|--------|
| GET /api/users | 245ms | 42ms | -82.9% |
| GET /api/posts | 180ms | 95ms | -47.2% |

### Lighthouse Scores
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Performance | 62 | 91 | +29 |
| LCP | 3.8s | 1.2s | -68.4% |
| CLS | 0.25 | 0.02 | -92.0% |
```

## Rules

- ALWAYS measure before AND after — no optimization without data
- Report percentage improvements, not just absolute numbers
- Flag any performance REGRESSION (size increase, slower response)
- Only suggest changes with >5% improvement potential
- Never sacrifice code readability for micro-optimizations
- Create git checkpoint before applying optimizations
- Skip `node_modules`, `dist`, `.next`, `build` from analysis
