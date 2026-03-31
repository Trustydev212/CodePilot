---
name: react-nextjs
description: "Expert React 19 & Next.js 15 patterns. Server/client components, App Router, data fetching, state management, performance optimization."
user-invocable: false
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/next.config.*"
  - "**/app/**"
  - "**/components/**"
---

# React 19 & Next.js 15 Expert

You are a React/Next.js expert. Apply these patterns based on the project's actual setup.

## Auto-Detection

Check before applying patterns:
- `next.config.*` exists → Next.js (check version in package.json)
- `app/` directory → App Router
- `pages/` directory → Pages Router (legacy)
- `src/` prefix → Source directory structure

## Server vs Client Components (Next.js App Router)

### Default: Server Components
```tsx
// app/users/page.tsx - Server Component (default, no directive needed)
import { db } from '@/lib/db'

export default async function UsersPage() {
  const users = await db.user.findMany()  // Direct DB access, zero client JS
  return <UserList users={users} />
}
```

### Client Components - ONLY when needed
Add `'use client'` ONLY for:
- Event handlers (onClick, onChange, onSubmit)
- useState, useEffect, useRef
- Browser APIs (window, document, localStorage)
- Third-party libs that use React context

```tsx
'use client'
// components/search-input.tsx - Client because it needs useState
import { useState } from 'react'

export function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')
  return (
    <input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      onKeyDown={(e) => e.key === 'Enter' && onSearch(query)}
    />
  )
}
```

### Composition Pattern - Push client boundary DOWN
```tsx
// app/dashboard/page.tsx - Server Component
import { SearchInput } from '@/components/search-input'  // Client
import { DashboardStats } from '@/components/dashboard-stats'  // Server

export default async function Dashboard() {
  const stats = await getStats()  // Server-side data fetch
  return (
    <div>
      <DashboardStats data={stats} />  {/* Static, server-rendered */}
      <SearchInput onSearch={searchAction} />  {/* Interactive, client */}
    </div>
  )
}
```

## Data Fetching Patterns

### Server Components (preferred)
```tsx
// Direct async/await - no useEffect, no loading state management
// Note: In Next.js 15+, params is a Promise
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const product = await db.product.findUnique({ where: { id } })
  if (!product) notFound()
  return <ProductDetail product={product} />
}
```

### Server Actions (mutations)
```tsx
// app/actions/user.ts
'use server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

const UpdateProfileSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
})

export async function updateProfile(formData: FormData) {
  const parsed = UpdateProfileSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  })

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors }
  }

  await db.user.update({ where: { id: userId }, data: parsed.data })
  revalidatePath('/profile')
}
```

### React 19 `use()` for client-side data
```tsx
'use client'
import { use } from 'react'

function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise)  // Suspense-integrated
  return comments.map(c => <Comment key={c.id} {...c} />)
}
```

## State Management Decision Tree

1. **URL state** (search, filters, pagination) → `useSearchParams` + `nuqs`
2. **Server state** (DB data) → Server Components + Server Actions
3. **Form state** → `useActionState` (React 19) or react-hook-form
4. **Local UI state** (modals, toggles) → `useState` in the component
5. **Shared client state** → Zustand (simple) or Jotai (atomic)
6. **Complex server cache** → TanStack Query (only if Server Components don't fit)

## Performance Checklist

- [ ] Images use `<Image>` with width/height or fill
- [ ] Dynamic imports for heavy components: `const Chart = dynamic(() => import('./Chart'), { ssr: false })`
- [ ] Lists >50 items use virtualization (tanstack-virtual)
- [ ] Expensive calculations wrapped in `useMemo` with stable deps
- [ ] Event handlers wrapped in `useCallback` only when passed to memoized children
- [ ] No layout shift (explicit width/height on media, skeleton loaders)
- [ ] Fonts use `next/font` (no FOUT)
- [ ] Metadata uses `generateMetadata` (not client-side document.title)

## File Structure Convention

```
app/
├── (auth)/                  # Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── (dashboard)/
│   ├── layout.tsx           # Shared dashboard layout
│   ├── page.tsx             # /dashboard
│   └── settings/page.tsx    # /dashboard/settings
├── api/
│   └── webhooks/
│       └── route.ts         # API route handler
├── layout.tsx               # Root layout
├── loading.tsx              # Global loading UI
├── error.tsx                # Global error UI
└── not-found.tsx            # 404 page

components/
├── ui/                      # Reusable primitives (button, input, card)
├── forms/                   # Form components
├── layouts/                 # Layout components (header, sidebar)
└── [feature]/               # Feature-specific components

lib/
├── db.ts                    # Database client
├── auth.ts                  # Auth utilities
├── utils.ts                 # Shared utilities
└── validations/             # Zod schemas
```

## Common Mistakes to Avoid

1. **Don't** put `'use client'` on page components - push it to leaf components
2. **Don't** use `useEffect` for data fetching - use Server Components or Server Actions
3. **Don't** prop-drill through 3+ levels - use composition or context
4. **Don't** put heavy computation in render - use `useMemo` or move to server
5. **Don't** use `any` type - use proper generics or `unknown` with type guards
6. **Don't** forget error boundaries - add `error.tsx` at route segment level
7. **Don't** use `router.push` for mutations - use Server Actions + `revalidatePath`
