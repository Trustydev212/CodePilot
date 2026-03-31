---
name: cache
description: "Caching strategies. Redis, in-memory, CDN, cache invalidation, stale-while-revalidate, cache-aside patterns."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /cache — Caching Strategies

Multi-layer caching for performance at scale.

## Usage

```
/cache setup                        # Set up Redis + caching layer
/cache api <endpoint>               # Add caching to API endpoint
/cache invalidation                 # Cache invalidation strategy
```

## Patterns

- Redis cache-aside pattern
- Stale-while-revalidate for non-critical data
- Next.js API route caching headers
- Tenant-scoped cache keys: `org:{orgId}:resource:{id}`

## Rules

- Cache reads, not writes
- Always set TTL
- Invalidate on write
- Namespace keys by tenant
- Log cache hit/miss ratios
- Don't cache sensitive data without encryption
