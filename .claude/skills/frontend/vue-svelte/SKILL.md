---
name: vue-svelte
description: "Vue 3 (Composition API, Nuxt 3) and Svelte 5 (SvelteKit) patterns. Reactivity, routing, SSR, state management."
user-invocable: false
paths:
  - "**/*.vue"
  - "**/*.svelte"
  - "**/nuxt.config.*"
  - "**/svelte.config.*"
---

# Vue 3 & Svelte 5 Expert

Modern patterns for Vue 3 Composition API / Nuxt 3 and Svelte 5 / SvelteKit.

## Auto-Detect

- `nuxt.config.*` → Nuxt 3 (Vue)
- `*.vue` files → Vue 3
- `svelte.config.*` → SvelteKit (Svelte)
- `*.svelte` files → Svelte 5

## Vue 3 (Composition API)

### Component Pattern
```vue
<!-- components/UserCard.vue -->
<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  user: User
  showEmail?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showEmail: false,
})

const emit = defineEmits<{
  select: [userId: string]
  delete: [userId: string]
}>()

const initials = computed(() =>
  props.user.name.split(' ').map(n => n[0]).join('').toUpperCase()
)
</script>

<template>
  <div class="user-card" @click="emit('select', user.id)">
    <div class="avatar">{{ initials }}</div>
    <h3>{{ user.name }}</h3>
    <p v-if="showEmail">{{ user.email }}</p>
    <button @click.stop="emit('delete', user.id)">Delete</button>
  </div>
</template>
```

### Composables (Custom Hooks)
```typescript
// composables/useAuth.ts
import { ref, computed } from 'vue'

export function useAuth() {
  const user = ref<User | null>(null)
  const isAuthenticated = computed(() => !!user.value)

  async function login(email: string, password: string) {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })
    user.value = await response.json()
  }

  function logout() {
    user.value = null
  }

  return { user, isAuthenticated, login, logout }
}
```

### Nuxt 3 Data Fetching
```vue
<script setup lang="ts">
// Auto-imported composable - SSR + client hydration
const { data: users, pending, error } = await useFetch('/api/users', {
  query: { page: 1, limit: 20 },
})

// Server-only fetch
const { data: secrets } = await useAsyncData('config',
  () => $fetch('/api/admin/config'),
  { server: true }
)
</script>
```

### Pinia (State Management)
```typescript
// stores/cart.ts
import { defineStore } from 'pinia'

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])

  const total = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )

  function addItem(product: Product) {
    const existing = items.value.find(i => i.productId === product.id)
    if (existing) {
      existing.quantity++
    } else {
      items.value.push({ productId: product.id, ...product, quantity: 1 })
    }
  }

  function removeItem(productId: string) {
    items.value = items.value.filter(i => i.productId !== productId)
  }

  return { items, total, addItem, removeItem }
})
```

## Svelte 5 (Runes)

### Component Pattern
```svelte
<!-- components/UserCard.svelte -->
<script lang="ts">
  interface Props {
    user: User
    showEmail?: boolean
    onselect?: (userId: string) => void
    ondelete?: (userId: string) => void
  }

  let { user, showEmail = false, onselect, ondelete }: Props = $props()

  let initials = $derived(
    user.name.split(' ').map(n => n[0]).join('').toUpperCase()
  )
</script>

<div class="user-card" onclick={() => onselect?.(user.id)}>
  <div class="avatar">{initials}</div>
  <h3>{user.name}</h3>
  {#if showEmail}
    <p>{user.email}</p>
  {/if}
  <button onclick|stopPropagation={() => ondelete?.(user.id)}>Delete</button>
</div>
```

### Reactivity with Runes
```svelte
<script lang="ts">
  // Reactive state
  let count = $state(0)
  let doubled = $derived(count * 2)

  // Reactive effect
  $effect(() => {
    console.log(`Count changed to ${count}`)
  })

  function increment() {
    count++
  }
</script>

<button onclick={increment}>
  Count: {count} (doubled: {doubled})
</button>
```

### SvelteKit Data Loading
```typescript
// +page.server.ts
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ params, locals }) => {
  const user = await db.user.findUnique({ where: { id: params.id } })
  if (!user) throw error(404, 'User not found')

  return { user }
}

// +page.svelte
<script lang="ts">
  import type { PageData } from './$types'
  let { data }: { data: PageData } = $props()
</script>

<h1>{data.user.name}</h1>
```

### SvelteKit Form Actions
```typescript
// +page.server.ts
import type { Actions } from './$types'
import { fail } from '@sveltejs/kit'

export const actions: Actions = {
  create: async ({ request }) => {
    const data = await request.formData()
    const name = data.get('name')?.toString()

    if (!name || name.length < 1) {
      return fail(400, { name, missing: true })
    }

    await db.user.create({ data: { name } })
    return { success: true }
  },
}
```

## Vue vs Svelte Quick Reference

| Aspect | Vue 3 | Svelte 5 |
|--------|-------|----------|
| Reactivity | `ref()`, `reactive()` | `$state`, `$derived` |
| Computed | `computed()` | `$derived()` |
| Watch | `watch()`, `watchEffect()` | `$effect()` |
| Props | `defineProps<T>()` | `$props()` |
| Events | `defineEmits<T>()` | Callback props |
| Slots | `<slot>` | `{@render children()}` |
| State mgmt | Pinia | Svelte stores / runes |
| SSR | Nuxt 3 | SvelteKit |
| Styling | Scoped `<style>` | Scoped `<style>` |
