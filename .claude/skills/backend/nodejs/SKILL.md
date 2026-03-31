---
name: nodejs
description: "Node.js & TypeScript backend patterns. Express, Fastify, Hono, NestJS. Error handling, middleware, project structure, testing."
user-invocable: false
paths:
  - "**/server/**"
  - "**/src/api/**"
  - "**/src/routes/**"
  - "**/src/services/**"
  - "**/src/middleware/**"
---

# Node.js Backend Expert

Production-grade Node.js patterns. TypeScript-first, performance-conscious.

## Framework Detection

- `express` → Express.js
- `fastify` → Fastify
- `hono` → Hono
- `@nestjs/core` → NestJS
- `koa` → Koa

## Project Structure (Feature-Based)

```
src/
├── modules/                    # Feature modules
│   ├── users/
│   │   ├── users.router.ts     # Route definitions
│   │   ├── users.service.ts    # Business logic
│   │   ├── users.schema.ts     # Validation schemas (Zod)
│   │   ├── users.types.ts      # TypeScript types
│   │   └── users.test.ts       # Tests
│   ├── orders/
│   │   ├── orders.router.ts
│   │   ├── orders.service.ts
│   │   └── ...
│   └── auth/
│       └── ...
├── middleware/
│   ├── auth.ts                 # Authentication middleware
│   ├── validate.ts             # Request validation
│   ├── rate-limit.ts           # Rate limiting
│   └── error-handler.ts        # Global error handler
├── lib/
│   ├── db.ts                   # Database client (singleton)
│   ├── redis.ts                # Cache client
│   ├── logger.ts               # Structured logging
│   └── env.ts                  # Validated env vars
├── app.ts                      # App setup (middleware, routes)
└── server.ts                   # Server startup
```

## Environment Variables (Validate at Startup)

```typescript
// lib/env.ts - Fail fast if config is wrong
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  CORS_ORIGINS: z.string().transform(s => s.split(',')),
})

export const env = envSchema.parse(process.env)
// If this throws, the app won't start. That's intentional.
```

## Middleware Patterns

### Request Validation
```typescript
// middleware/validate.ts
import { z, ZodSchema } from 'zod'
import type { RequestHandler } from 'express'

export function validate(schema: {
  body?: ZodSchema
  query?: ZodSchema
  params?: ZodSchema
}): RequestHandler {
  return (req, res, next) => {
    const errors: Record<string, unknown> = {}

    if (schema.body) {
      const result = schema.body.safeParse(req.body)
      if (!result.success) errors.body = result.error.flatten().fieldErrors
      else req.body = result.data
    }

    if (schema.query) {
      const result = schema.query.safeParse(req.query)
      if (!result.success) errors.query = result.error.flatten().fieldErrors
      else req.query = result.data as any
    }

    if (schema.params) {
      const result = schema.params.safeParse(req.params)
      if (!result.success) errors.params = result.error.flatten().fieldErrors
      else req.params = result.data as any
    }

    if (Object.keys(errors).length > 0) {
      return res.status(400).json({
        error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: errors }
      })
    }

    next()
  }
}

// Usage
router.post('/users',
  validate({ body: CreateUserSchema }),
  usersController.create
)
```

### Structured Logging
```typescript
// lib/logger.ts
import pino from 'pino'
import { env } from './env'

export const logger = pino({
  level: env.NODE_ENV === 'production' ? 'info' : 'debug',
  ...(env.NODE_ENV !== 'production' && { transport: { target: 'pino-pretty' } }),
  serializers: {
    err: pino.stdSerializers.err,
    req: (req) => ({
      method: req.method,
      url: req.url,
      ip: req.ip,
    }),
  },
})

// Usage - structured, not string concatenation
logger.info({ userId, action: 'login' }, 'User logged in')
logger.error({ err, orderId }, 'Payment processing failed')
```

### Graceful Shutdown
```typescript
// server.ts
const server = app.listen(env.PORT, () => {
  logger.info({ port: env.PORT }, 'Server started')
})

async function shutdown(signal: string) {
  logger.info({ signal }, 'Shutting down gracefully...')

  server.close(() => {
    logger.info('HTTP server closed')
  })

  // Close database connections
  await prisma.$disconnect()
  // Close Redis
  await redis?.quit()

  process.exit(0)
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT', () => shutdown('SIGINT'))

// Handle unhandled rejections (don't crash silently)
process.on('unhandledRejection', (reason) => {
  logger.fatal({ err: reason }, 'Unhandled rejection')
  process.exit(1)
})
```

## Service Layer Pattern

```typescript
// modules/users/users.service.ts
export class UsersService {
  constructor(private db: PrismaClient) {}

  async findById(id: string) {
    const user = await this.db.user.findUnique({ where: { id } })
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', `User ${id} not found`)
    return user
  }

  async create(data: CreateUserInput) {
    const existing = await this.db.user.findUnique({ where: { email: data.email } })
    if (existing) throw new AppError(409, 'EMAIL_EXISTS', 'Email already registered')

    const passwordHash = await hash(data.password)
    return this.db.user.create({
      data: { ...data, password: undefined, passwordHash },
      select: { id: true, email: true, name: true, role: true, createdAt: true },
    })
  }

  async update(id: string, data: UpdateUserInput) {
    await this.findById(id)  // Throws 404 if not found
    return this.db.user.update({
      where: { id },
      data,
      select: { id: true, email: true, name: true, role: true },
    })
  }
}
```

## Testing Patterns

```typescript
// modules/users/users.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { createTestApp, createTestUser, resetDatabase } from '@/test/helpers'

describe('Users API', () => {
  let app: Express

  beforeAll(async () => {
    app = await createTestApp()
  })

  afterAll(async () => {
    await resetDatabase()
  })

  describe('POST /api/users', () => {
    it('creates user with valid data', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({ name: 'Test', email: 'test@example.com', password: 'secure123!' })

      expect(res.status).toBe(201)
      expect(res.body.data).toMatchObject({
        name: 'Test',
        email: 'test@example.com',
      })
      expect(res.body.data).not.toHaveProperty('password')
      expect(res.body.data).not.toHaveProperty('passwordHash')
    })

    it('returns 400 for invalid email', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({ name: 'Test', email: 'not-an-email', password: 'secure123!' })

      expect(res.status).toBe(400)
      expect(res.body.error.code).toBe('VALIDATION_ERROR')
    })

    it('returns 409 for duplicate email', async () => {
      await createTestUser({ email: 'dupe@example.com' })
      const res = await request(app)
        .post('/api/users')
        .send({ name: 'Test', email: 'dupe@example.com', password: 'secure123!' })

      expect(res.status).toBe(409)
    })
  })
})
```

## Performance Tips

- Use connection pooling (Prisma default, pg-pool for raw)
- Cache hot data in Redis (user sessions, config, rate limits)
- Stream large responses (`res.write()` chunks, not buffer all in memory)
- Use `Promise.all()` for independent async operations
- Set appropriate `keep-alive` timeouts
- Use compression middleware for JSON responses >1KB
- Profile with `clinic.js` or `0x` before optimizing blindly
