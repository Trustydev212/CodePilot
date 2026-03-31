---
name: state-graphql
description: "State management (Zustand, Jotai, TanStack Query) and API patterns (GraphQL, tRPC). Pick the right tool for the job."
paths:
  - "**/store/**"
  - "**/stores/**"
  - "**/hooks/use*"
  - "**/graphql/**"
  - "**/trpc/**"
---

# State Management & API Patterns

Pick the right tool. Over-engineering state is the #1 cause of React complexity.

## State Management Decision Tree

```
Is the state in the URL? (search, filters, page)
  → YES: useSearchParams + nuqs
  → NO: ↓

Is it server data? (from DB/API)
  → YES: Server Components (Next.js) or TanStack Query
  → NO: ↓

Is it form data?
  → YES: react-hook-form + zod
  → NO: ↓

Is it used in only one component?
  → YES: useState
  → NO: ↓

Is it shared between 2-3 nearby components?
  → YES: Lift state to parent, pass as props
  → NO: ↓

Is it simple global state? (theme, sidebar, modal)
  → YES: Zustand (tiny store)
  → NO: ↓

Is it complex with many independent atoms?
  → YES: Jotai (atomic)
  → NO: Zustand (single store)
```

## Zustand (Simple Global State)

```typescript
// stores/auth-store.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AuthState {
  user: User | null
  token: string | null
  login: (user: User, token: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      login: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null }),
    }),
    { name: 'auth-storage' }
  )
)

// Usage in component
function Header() {
  const user = useAuthStore((s) => s.user)  // Only re-renders when user changes
  const logout = useAuthStore((s) => s.logout)
  // ...
}
```

## TanStack Query (Server State)

```typescript
// hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// Query keys as const for type safety
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
}

export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => api.users.list(filters),
    staleTime: 5 * 60 * 1000,  // 5 min before refetch
  })
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => api.users.get(id),
    enabled: !!id,  // Don't fetch if no ID
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: CreateUserInput) => api.users.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() })
    },
  })
}

// Usage
function UserList() {
  const { data, isLoading, error } = useUsers({ page: 1 })
  const createUser = useCreateUser()

  if (isLoading) return <Skeleton />
  if (error) return <Error message={error.message} />

  return (
    <>
      {data.users.map(u => <UserCard key={u.id} user={u} />)}
      <button onClick={() => createUser.mutate({ name: 'New User' })}>
        {createUser.isPending ? 'Creating...' : 'Add User'}
      </button>
    </>
  )
}
```

## tRPC (End-to-End Type Safety)

```typescript
// server/trpc/router.ts
import { router, publicProcedure, protectedProcedure } from './trpc'
import { z } from 'zod'

export const appRouter = router({
  users: router({
    list: publicProcedure
      .input(z.object({
        page: z.number().default(1),
        limit: z.number().max(100).default(20),
      }))
      .query(async ({ input, ctx }) => {
        return ctx.db.user.findMany({
          skip: (input.page - 1) * input.limit,
          take: input.limit,
        })
      }),

    create: protectedProcedure
      .input(z.object({
        name: z.string().min(1),
        email: z.string().email(),
      }))
      .mutation(async ({ input, ctx }) => {
        return ctx.db.user.create({ data: input })
      }),
  }),
})

export type AppRouter = typeof appRouter

// Client usage (full type safety, no codegen)
function UserList() {
  const users = trpc.users.list.useQuery({ page: 1 })
  const createUser = trpc.users.create.useMutation()
  // Types are inferred from the router definition ↑
}
```

## GraphQL (When You Need It)

Use GraphQL when:
- Multiple frontends need different data shapes
- Complex nested relationships
- Real-time subscriptions needed
- API is consumed by third parties

Don't use GraphQL when:
- Single frontend consuming the API (use tRPC or REST)
- Simple CRUD operations
- Team is small and doesn't need schema-first design

```typescript
// With urql or Apollo Client
const USERS_QUERY = graphql(`
  query Users($page: Int!) {
    users(page: $page) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
`)

function UserList() {
  const [result] = useQuery({ query: USERS_QUERY, variables: { page: 1 } })
  const { data, fetching, error } = result
  // ...
}
```

## Anti-Patterns

1. **Redux for simple apps** - Zustand or Server Components are simpler for 90% of cases
2. **useEffect for data fetching** - Use TanStack Query or Server Components
3. **Global state for everything** - Most state should be local (useState)
4. **Prop drilling through Context** - Context causes unnecessary re-renders. Use Zustand.
5. **Caching in useState** - Use TanStack Query for server data caching
6. **GraphQL for internal APIs** - tRPC gives type safety without schema overhead
