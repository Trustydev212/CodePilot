---
name: test
description: "Generate meaningful tests that catch real bugs. Unit, integration, E2E. Test behavior, not implementation."
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /test - Test Generation Expert

Write tests that catch REAL bugs, not tests that just increase coverage numbers.

## Scope
$ARGUMENTS

## Test Framework Detection

```bash
# Auto-detect test framework
if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then echo "vitest"
elif [ -f "jest.config.ts" ] || [ -f "jest.config.js" ]; then echo "jest"
elif grep -q '"jest"' package.json 2>/dev/null; then echo "jest"
elif [ -f "pytest.ini" ] || [ -f "conftest.py" ]; then echo "pytest"
elif [ -f "go.mod" ]; then echo "go-test"
fi
```

## Test Pyramid

```
         /  E2E  \         ← Few: Critical user journeys only
        / Integration \     ← Some: API endpoints, DB queries
       /    Unit Tests   \  ← Many: Business logic, utilities
```

## What to Test (Decision Framework)

### ALWAYS test:
- Business logic (calculations, transformations, validations)
- API endpoints (status codes, response shape, auth)
- Database queries (CRUD, edge cases, constraints)
- Error handling paths (what happens when things fail)
- User-facing flows (login, checkout, form submission)

### NEVER test:
- Framework internals (React rendering, Express routing)
- Third-party library behavior
- CSS styling (use visual regression tools)
- Getters/setters with no logic
- Constants/configuration values

### Test behavior, NOT implementation:

```typescript
// BAD: Tests implementation details
it('calls setState with correct value', () => {
  const setState = vi.fn()
  // Testing internal state changes = brittle test
})

// GOOD: Tests observable behavior
it('shows error message when form submitted with empty email', async () => {
  render(<LoginForm />)
  await userEvent.click(screen.getByRole('button', { name: /sign in/i }))
  expect(screen.getByText(/email is required/i)).toBeInTheDocument()
})
```

## Test Patterns

### Unit Test Pattern (AAA)
```typescript
describe('calculateOrderTotal', () => {
  it('sums item prices with tax for US orders', () => {
    // Arrange
    const items = [
      { name: 'Widget', price: 10, quantity: 2 },
      { name: 'Gadget', price: 25, quantity: 1 },
    ]

    // Act
    const total = calculateOrderTotal(items, { country: 'US', state: 'CA' })

    // Assert
    expect(total).toEqual({
      subtotal: 45,
      tax: 4.19,     // CA tax rate 9.3%
      total: 49.19,
    })
  })

  it('returns zero for empty order', () => {
    const total = calculateOrderTotal([], { country: 'US', state: 'CA' })
    expect(total).toEqual({ subtotal: 0, tax: 0, total: 0 })
  })

  it('throws for negative quantities', () => {
    const items = [{ name: 'Widget', price: 10, quantity: -1 }]
    expect(() => calculateOrderTotal(items, { country: 'US', state: 'CA' }))
      .toThrow('Quantity must be positive')
  })
})
```

### API Integration Test
```typescript
describe('POST /api/orders', () => {
  it('creates order and returns 201 with order data', async () => {
    const user = await createTestUser()
    const product = await createTestProduct({ stock: 10 })

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${user.token}`)
      .send({ items: [{ productId: product.id, quantity: 2 }] })

    expect(res.status).toBe(201)
    expect(res.body.data).toMatchObject({
      status: 'pending',
      items: [{ productId: product.id, quantity: 2 }],
    })

    // Verify side effects
    const updatedProduct = await db.product.findUnique({ where: { id: product.id } })
    expect(updatedProduct.stock).toBe(8)  // Stock decreased
  })

  it('returns 400 when ordering more than available stock', async () => {
    const user = await createTestUser()
    const product = await createTestProduct({ stock: 1 })

    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${user.token}`)
      .send({ items: [{ productId: product.id, quantity: 5 }] })

    expect(res.status).toBe(400)
    expect(res.body.error.code).toBe('INSUFFICIENT_STOCK')
  })

  it('returns 401 without authentication', async () => {
    const res = await request(app)
      .post('/api/orders')
      .send({ items: [] })

    expect(res.status).toBe(401)
  })
})
```

### React Component Test
```typescript
describe('SearchInput', () => {
  it('calls onSearch when Enter is pressed', async () => {
    const onSearch = vi.fn()
    render(<SearchInput onSearch={onSearch} />)

    const input = screen.getByRole('searchbox')
    await userEvent.type(input, 'test query')
    await userEvent.keyboard('{Enter}')

    expect(onSearch).toHaveBeenCalledWith('test query')
  })

  it('shows loading spinner during search', async () => {
    render(<SearchInput onSearch={() => new Promise(() => {})} />)

    await userEvent.type(screen.getByRole('searchbox'), 'query{Enter}')

    expect(screen.getByRole('status')).toBeInTheDocument()
  })

  it('debounces rapid input', async () => {
    vi.useFakeTimers()
    const onSearch = vi.fn()
    render(<SearchInput onSearch={onSearch} debounceMs={300} />)

    const input = screen.getByRole('searchbox')
    await userEvent.type(input, 'a')
    await userEvent.type(input, 'b')
    await userEvent.type(input, 'c')

    vi.advanceTimersByTime(300)
    expect(onSearch).toHaveBeenCalledTimes(1)
    expect(onSearch).toHaveBeenCalledWith('abc')
    vi.useRealTimers()
  })
})
```

## Edge Cases to Always Consider

| Category | Edge Cases |
|----------|-----------|
| **Strings** | Empty `""`, whitespace `"  "`, unicode `"日本語"`, very long, special chars `<script>` |
| **Numbers** | 0, negative, very large, decimal precision, NaN, Infinity |
| **Arrays** | Empty `[]`, single item, duplicate items, very large |
| **Objects** | Empty `{}`, missing optional fields, extra fields |
| **Dates** | Midnight, DST transitions, different timezones, leap years |
| **Auth** | No token, expired token, wrong role, revoked session |
| **Network** | Timeout, 500 error, empty response, malformed JSON |
| **Concurrency** | Simultaneous requests, double-click submit, stale data |

## After Writing Tests

```bash
# Run and show results
npm test -- --verbose 2>&1 || python -m pytest -v 2>&1

# Show coverage for changed files only
npm test -- --coverage --changedSince=main 2>&1
```

Report format:
```
## Tests Added

| File | Tests | Focus |
|------|-------|-------|
| [test file] | X tests | [what's tested] |

### Results
- Passed: X
- Failed: Y
- Coverage: Z% (for changed files)
```
