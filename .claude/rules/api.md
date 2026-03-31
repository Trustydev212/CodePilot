---
paths:
  - "**/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/handlers/**"
---

# API Rules

- RESTful: plural nouns for resources (`/users`, `/orders`), HTTP verbs for actions.
- Always validate input at the API boundary. Use Zod (Node.js) or Pydantic (Python).
- Consistent response format: `{ data }` for success, `{ error: { code, message, details } }` for errors.
- Proper HTTP status codes: 201 for create, 400 for validation, 401 for auth, 404 for not found, 409 for conflicts.
- Pagination on ALL list endpoints. Default limit of 20, max of 100.
- Never expose internal IDs, stack traces, or database schema in error responses.
- Rate limiting on public endpoints, especially auth.
- All endpoints that modify data need authentication AND authorization checks.
- Use middleware for cross-cutting concerns (auth, validation, logging, rate limiting).
- Log request/response for audit trails (exclude sensitive fields like passwords, tokens).
- API versioning: URL prefix (`/api/v1/`) for breaking changes.
