---
name: optimize
description: "Performance profiling and optimization. Identify bottlenecks with data, fix with evidence, benchmark results."
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /optimize - Performance Optimization

Optimize with DATA, not intuition. Measure → Identify → Fix → Verify.

## Target
$ARGUMENTS

## Rule #1: Don't Optimize Without Profiling

> "Premature optimization is the root of all evil" - Knuth
> "But measured optimization is engineering" - Reality

## Phase 1: Measure Current State

### Frontend Performance
```bash
# Bundle size analysis
[ -f "package.json" ] && npx next build 2>&1 | grep -A 50 "Route" || \
  npx vite build 2>&1 | tail -30

# Check for large dependencies
[ -f "package.json" ] && npx depcheck 2>&1 | head -20
```

### Backend Performance
```bash
# Database query analysis (if using Prisma)
# Enable query logging temporarily
export DEBUG="prisma:query"

# Check for slow queries in logs
rg -n 'duration.*ms' --glob '*.log' 2>&1 | sort -t'=' -k2 -nr | head -10
```

### Bundle Size Offenders
```bash
# Find large imports
rg -n "import .* from ['\"]" --glob '*.{ts,tsx,js,jsx}' --glob '!node_modules' 2>&1 | \
  grep -iE '(lodash|moment|date-fns|rxjs|@mui|antd|chart)' | head -20
```

## Phase 2: Common Optimizations

### Frontend Optimizations

**1. Code Splitting**
```typescript
// Before: Everything in one bundle
import { HeavyChart } from './components/HeavyChart'

// After: Loaded only when needed
import dynamic from 'next/dynamic'
const HeavyChart = dynamic(() => import('./components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false,  // Skip server-render for client-only components
})
```

**2. Image Optimization**
```tsx
// Before: Unoptimized
<img src="/hero.png" />

// After: Next.js Image (auto WebP, lazy load, responsive)
import Image from 'next/image'
<Image src="/hero.png" width={1200} height={600} alt="Hero" priority />
```

**3. Memoization (only when measured)**
```typescript
// Only memoize if profiler shows expensive re-renders
const expensiveResult = useMemo(() => {
  return items.filter(filterFn).sort(sortFn).map(transformFn)
}, [items, filterFn, sortFn])

// Only useCallback when passing to React.memo children
const handleClick = useCallback((id: string) => {
  dispatch({ type: 'SELECT', payload: id })
}, [dispatch])
```

**4. Virtual Lists (>50 items)**
```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function LargeList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  })

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((vi) => (
          <div key={vi.key} style={{
            position: 'absolute',
            top: vi.start,
            height: vi.size,
          }}>
            <ItemRow item={items[vi.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

### Backend Optimizations

**1. Database Query Optimization**
```typescript
// Before: N+1 query
const orders = await db.order.findMany()
for (const order of orders) {
  order.user = await db.user.findUnique({ where: { id: order.userId } })
}

// After: Single query with join
const orders = await db.order.findMany({
  include: { user: { select: { id: true, name: true, email: true } } }
})
```

**2. Caching Strategy**
```typescript
import { Redis } from 'ioredis'

const redis = new Redis(process.env.REDIS_URL)
const CACHE_TTL = 300 // 5 minutes

async function getCachedOrFetch<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttl = CACHE_TTL
): Promise<T> {
  const cached = await redis.get(key)
  if (cached) return JSON.parse(cached)

  const data = await fetcher()
  await redis.setex(key, ttl, JSON.stringify(data))
  return data
}

// Usage
const products = await getCachedOrFetch(
  `products:category:${categoryId}:page:${page}`,
  () => db.product.findMany({ where: { categoryId }, skip, take }),
  300
)
```

**3. Parallel I/O**
```typescript
// Before: Sequential (slow)
const user = await getUser(id)
const orders = await getOrders(id)
const preferences = await getPreferences(id)

// After: Parallel (fast)
const [user, orders, preferences] = await Promise.all([
  getUser(id),
  getOrders(id),
  getPreferences(id),
])
```

## Phase 3: Verify Improvement

```bash
# Build and compare sizes
npm run build 2>&1 | grep -E "Route|Size|First Load"

# Run benchmarks if available
npm run bench 2>&1 || echo "No benchmark script found"
```

## Optimization Report

```
## Optimization Report: [target]

### Before
- [Metric]: [value] (e.g., Bundle: 450KB, Query: 230ms, LCP: 3.2s)

### Changes Made
| Change | File | Impact |
|--------|------|--------|
| [what] | [where] | [expected improvement] |

### After
- [Metric]: [value] (e.g., Bundle: 280KB (-38%), Query: 12ms (-95%), LCP: 1.1s (-66%))

### Not Optimized (and why)
- [thing]: [reason it's not worth optimizing yet]
```

RULE: Every optimization must have before/after measurements. "It should be faster" is not evidence.
