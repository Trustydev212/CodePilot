---
name: api-design
description: "RESTful API design, input validation, error handling, pagination, rate limiting. Build APIs that frontend devs love."
user-invocable: false
paths:
  - "**/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/handlers/**"
---

# API Design Expert

Build APIs that are consistent, well-documented, and a joy to consume.

## Input
$ARGUMENTS

## API Design Principles

1. **Consistent naming**: plural nouns for collections (`/users`, `/orders`)
2. **Proper HTTP verbs**: GET=read, POST=create, PUT/PATCH=update, DELETE=remove
3. **Meaningful status codes**: Don't use 200 for everything
4. **Predictable response shape**: Same structure for all endpoints
5. **Pagination by default**: Never return unbounded lists

## Standard Response Format

### Success
```json
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-03-31T10:00:00Z"
  }
}
```

### List with Pagination
```json
{
  "data": [ ... ],
  "meta": {
    "total": 150,
    "page": 1,
    "perPage": 20,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

## HTTP Status Codes

| Code | When to Use |
|------|------------|
| 200 | Success (GET, PUT, PATCH, DELETE) |
| 201 | Created (POST that creates a resource) |
| 204 | No Content (DELETE with no response body) |
| 400 | Bad Request (validation error, malformed JSON) |
| 401 | Unauthorized (no/invalid auth token) |
| 403 | Forbidden (valid auth but insufficient permissions) |
| 404 | Not Found (resource doesn't exist) |
| 409 | Conflict (duplicate entry, version mismatch) |
| 422 | Unprocessable Entity (valid JSON but business logic rejected) |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error (unexpected failure) |

## Input Validation (Always at the boundary)

### Node.js/Express with Zod
```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email format'),
  role: z.enum(['user', 'admin']).default('user'),
  age: z.number().int().min(13).max(120).optional(),
})

app.post('/api/users', async (req, res) => {
  const parsed = CreateUserSchema.safeParse(req.body)

  if (!parsed.success) {
    return res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid input',
        details: parsed.error.issues.map(i => ({
          field: i.path.join('.'),
          message: i.message,
        })),
      },
    })
  }

  const user = await db.user.create({ data: parsed.data })
  return res.status(201).json({ data: user })
})
```

### Python/FastAPI
```python
from pydantic import BaseModel, EmailStr, Field
from fastapi import FastAPI, HTTPException

class CreateUser(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    role: str = Field(default="user", pattern="^(user|admin)$")
    age: int | None = Field(default=None, ge=13, le=120)

@app.post("/api/users", status_code=201)
async def create_user(body: CreateUser):
    user = await db.user.create(body.model_dump())
    return {"data": user}
```

## Pagination Patterns

### Offset-based (simple, good for most cases)
```
GET /api/users?page=2&perPage=20&sort=createdAt&order=desc
```

### Cursor-based (better for real-time, infinite scroll)
```
GET /api/users?cursor=eyJpZCI6MTAwfQ&limit=20
```

```typescript
// Cursor pagination implementation
async function listUsers(cursor?: string, limit = 20) {
  const decodedCursor = cursor
    ? JSON.parse(Buffer.from(cursor, 'base64url').toString())
    : null

  const users = await db.user.findMany({
    take: limit + 1,  // Fetch one extra to know if there's more
    ...(decodedCursor && {
      cursor: { id: decodedCursor.id },
      skip: 1,
    }),
    orderBy: { id: 'asc' },
  })

  const hasNext = users.length > limit
  const data = hasNext ? users.slice(0, -1) : users
  const nextCursor = hasNext
    ? Buffer.from(JSON.stringify({ id: data[data.length - 1].id })).toString('base64url')
    : null

  return { data, meta: { hasNext, nextCursor } }
}
```

## Error Handling Pattern

```typescript
// Centralized error handler (Express)
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message)
  }
}

// Usage in routes
throw new AppError(404, 'USER_NOT_FOUND', `User ${id} not found`)
throw new AppError(409, 'DUPLICATE_EMAIL', 'Email already registered')

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.message, details: err.details }
    })
  }

  // Unknown error - don't leak internals
  console.error('Unhandled error:', err)
  return res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' }
  })
})
```

## Security Checklist for APIs

- [ ] Rate limiting on all public endpoints (express-rate-limit, slowapi)
- [ ] Input validation on EVERY endpoint (never trust client data)
- [ ] SQL parameterized queries (never string concatenation)
- [ ] CORS configured for specific origins (not `*` in production)
- [ ] Authentication tokens in headers (not URL query params)
- [ ] File upload size limits and type validation
- [ ] Response doesn't leak internal IDs, stack traces, or DB schema
- [ ] Sensitive endpoints have audit logging
