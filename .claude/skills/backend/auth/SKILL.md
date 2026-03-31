---
name: auth
description: "Authentication & authorization patterns. JWT, OAuth, session management, RBAC, secure password handling. Works with Next-Auth, Lucia, Better-Auth, Clerk."
paths:
  - "**/auth/**"
  - "**/middleware.*"
  - "**/session*"
  - "**/login*"
  - "**/signup*"
---

# Authentication & Authorization Expert

Security-first auth patterns. Every shortcut here is a future breach.

## Auth Library Detection

- `next-auth` / `@auth/core` → NextAuth.js v5
- `lucia` → Lucia Auth
- `better-auth` → Better Auth
- `@clerk/nextjs` → Clerk
- `passport` → Passport.js
- `jsonwebtoken` → Custom JWT
- `express-session` → Session-based

## Authentication Decision Tree

1. **SaaS with social login** → Clerk or Better-Auth (fastest to ship)
2. **Full control needed** → NextAuth.js v5 or Lucia
3. **API-only (no frontend)** → JWT with refresh tokens
4. **Internal tool** → Session-based with LDAP/SSO
5. **Multi-tenant** → Better-Auth with organization support

## Secure Patterns

### Password Hashing (NEVER roll your own)
```typescript
import { hash, verify } from '@node-rs/argon2'  // or bcrypt

// Hash on registration
const passwordHash = await hash(password, {
  memoryCost: 19456,   // 19 MiB
  timeCost: 2,
  outputLen: 32,
  parallelism: 1,
})

// Verify on login
const isValid = await verify(storedHash, inputPassword)
```

### JWT Pattern (API authentication)
```typescript
import { SignJWT, jwtVerify } from 'jose'

const secret = new TextEncoder().encode(process.env.JWT_SECRET)

// Create token
async function createToken(userId: string, role: string) {
  return new SignJWT({ sub: userId, role })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('15m')          // Short-lived access token
    .sign(secret)
}

// Create refresh token (longer lived, stored in httpOnly cookie)
async function createRefreshToken(userId: string) {
  return new SignJWT({ sub: userId, type: 'refresh' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .setJti(crypto.randomUUID())      // Unique ID for revocation
    .sign(secret)
}

// Verify token
async function verifyToken(token: string) {
  try {
    const { payload } = await jwtVerify(token, secret)
    return payload
  } catch {
    return null  // Invalid or expired
  }
}
```

### NextAuth.js v5 Pattern
```typescript
// auth.ts
import NextAuth from 'next-auth'
import Google from 'next-auth/providers/google'
import Credentials from 'next-auth/providers/credentials'
import { PrismaAdapter } from '@auth/prisma-adapter'

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    Google,
    Credentials({
      credentials: {
        email: { label: 'Email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string },
        })
        if (!user?.passwordHash) return null
        const valid = await verify(user.passwordHash, credentials.password as string)
        return valid ? user : null
      },
    }),
  ],
  callbacks: {
    async session({ session, user }) {
      session.user.id = user.id
      session.user.role = user.role
      return session
    },
  },
})

// middleware.ts - Protect routes
import { auth } from './auth'

export default auth((req) => {
  const isAuth = !!req.auth
  const isAuthPage = req.nextUrl.pathname.startsWith('/login')
  const isProtected = req.nextUrl.pathname.startsWith('/dashboard')

  if (isProtected && !isAuth) {
    return Response.redirect(new URL('/login', req.url))
  }
  if (isAuthPage && isAuth) {
    return Response.redirect(new URL('/dashboard', req.url))
  }
})

export const config = { matcher: ['/dashboard/:path*', '/login', '/register'] }
```

### Role-Based Access Control (RBAC)
```typescript
// lib/permissions.ts
type Role = 'user' | 'editor' | 'admin' | 'superadmin'

const PERMISSIONS = {
  'posts:read':    ['user', 'editor', 'admin', 'superadmin'],
  'posts:create':  ['editor', 'admin', 'superadmin'],
  'posts:update':  ['editor', 'admin', 'superadmin'],
  'posts:delete':  ['admin', 'superadmin'],
  'users:manage':  ['admin', 'superadmin'],
  'settings:manage': ['superadmin'],
} as const satisfies Record<string, Role[]>

type Permission = keyof typeof PERMISSIONS

export function hasPermission(role: Role, permission: Permission): boolean {
  return PERMISSIONS[permission].includes(role)
}

// Usage in API route
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  const session = await auth()
  if (!session) return Response.json({ error: 'Unauthorized' }, { status: 401 })
  if (!hasPermission(session.user.role, 'posts:delete')) {
    return Response.json({ error: 'Forbidden' }, { status: 403 })
  }
  // ... proceed with deletion
}
```

## Security Checklist (Non-negotiable)

- [ ] Passwords hashed with argon2/bcrypt (NEVER SHA256/MD5)
- [ ] Access tokens short-lived (15min max)
- [ ] Refresh tokens in httpOnly, secure, sameSite cookies
- [ ] CSRF protection on state-changing endpoints
- [ ] Rate limiting on login endpoint (5 attempts per minute)
- [ ] Account lockout after repeated failures
- [ ] Constant-time string comparison for tokens
- [ ] Session invalidation on password change
- [ ] Logout invalidates all tokens/sessions
- [ ] No sensitive data in JWT payload (only user ID + role)
- [ ] HTTPS only in production (no token over HTTP)
- [ ] Password requirements: min 8 chars, check against breached passwords

## Common Mistakes

1. **Storing JWT in localStorage** → XSS can steal it. Use httpOnly cookies.
2. **No refresh token rotation** → Stolen refresh token = permanent access
3. **Checking auth client-side only** → Always verify server-side
4. **Same secret for all environments** → Use different secrets per environment
5. **Not invalidating sessions on password change** → Old sessions stay active
6. **Exposing user IDs in URLs** → Use slugs or check ownership
