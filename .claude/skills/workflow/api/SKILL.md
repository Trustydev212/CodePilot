---
name: api
description: "Design and implement API endpoints from spec. Generates route, validation, service, types, and tests in one go."
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /api - API Endpoint Generator

Generate complete API endpoints: route + validation + service + types + tests.

## Spec
$ARGUMENTS

## Phase 1: Analyze

Detect the API framework and patterns:
```bash
# Framework detection
if grep -q "fastify" package.json 2>/dev/null; then echo "Framework: Fastify"
elif grep -q "hono" package.json 2>/dev/null; then echo "Framework: Hono"
elif grep -q "express" package.json 2>/dev/null; then echo "Framework: Express"
elif grep -q "nestjs" package.json 2>/dev/null; then echo "Framework: NestJS"
elif grep -q "fastapi" requirements.txt 2>/dev/null; then echo "Framework: FastAPI"
elif grep -q "django" requirements.txt 2>/dev/null; then echo "Framework: Django"
fi

# Find existing API patterns
find . -path "*/api/*" -o -path "*/routes/*" -o -path "*/controllers/*" | head -10
```

Read 2-3 existing endpoints to understand the project's patterns.

## Phase 2: Design

Before coding, define the API contract:

```
### Endpoint: [METHOD] [path]

**Request**:
- Headers: [required headers]
- Params: [URL params with types]
- Query: [query params with types and defaults]
- Body: [JSON schema]

**Response**:
- 2xx: [success shape]
- 4xx: [error shapes]

**Auth**: [required role/permission]
**Rate Limit**: [requests per window]
```

## Phase 3: Generate

Create all files following the project's existing patterns:

1. **Validation Schema** (Zod/Pydantic)
   - Request body validation
   - Query parameter validation
   - URL parameter validation

2. **Route/Controller**
   - HTTP method + path
   - Middleware (auth, validation, rate limit)
   - Request parsing
   - Response formatting

3. **Service Layer**
   - Business logic (no HTTP concerns)
   - Database operations
   - Error handling with proper error types

4. **Types/Interfaces**
   - Request types
   - Response types
   - Shared types

5. **Tests**
   - Happy path (valid request → correct response)
   - Validation errors (invalid input → 400)
   - Auth errors (no token → 401, wrong role → 403)
   - Not found (missing resource → 404)
   - Edge cases (empty lists, boundary values)

## Phase 4: Verify

```bash
# Type check
[ -f "tsconfig.json" ] && npx tsc --noEmit

# Run tests for new endpoint
npm test -- --grep "[endpoint name]" 2>&1 || npm test 2>&1
```

## Output

```
## API Generated: [METHOD] [path]

### Files Created/Modified
- [route file]: Endpoint handler
- [schema file]: Input validation
- [service file]: Business logic
- [types file]: TypeScript interfaces
- [test file]: X tests (happy + error + edge)

### API Contract
[Summary of request/response]

### Verification
- [ ] Types: PASS
- [ ] Tests: PASS (X/X)
```
