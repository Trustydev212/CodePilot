---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
---

# Testing Rules

- Test file location: next to the file it tests (`users.service.ts` → `users.service.test.ts`).
- Test names describe BEHAVIOR, not implementation: "shows error when email is invalid" not "calls setError".
- AAA pattern: Arrange → Act → Assert. One blank line between each section.
- One assertion per test when possible. Multiple assertions only for related checks.
- No shared mutable state between tests. Each test sets up its own data.
- Mock only at system boundaries (database, HTTP, file system). Never mock internal functions.
- Test the public API of a module, not internal implementation details.
- Use factories/helpers for test data: `createTestUser()`, `createTestOrder()`.
- Clean up after tests: reset database, clear mocks, restore timers.
- Tests should be fast. Mock slow external services. Use in-memory database for unit tests.
- Cover: happy path, validation errors, edge cases (empty, null, boundary), error responses.
- Flaky tests are bugs. Fix them immediately or delete them.
