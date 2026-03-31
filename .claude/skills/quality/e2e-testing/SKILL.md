---
name: e2e
description: "End-to-end testing with Playwright. Write reliable E2E tests for critical user journeys. Anti-flake patterns included."
user-invocable: true
paths:
  - "**/e2e/**"
  - "**/playwright*"
  - "**/*.spec.ts"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /e2e - End-to-End Testing with Playwright

Write reliable E2E tests for critical user journeys. Flaky tests are bugs.

## Scope
$ARGUMENTS

## Setup Check

```bash
# Verify Playwright is installed
if ! npx playwright --version 2>/dev/null; then
  echo "Playwright not installed. Run: npm i -D @playwright/test && npx playwright install"
fi

# Check for existing config
ls playwright.config.* 2>/dev/null || echo "No playwright config found"
```

## Playwright Config (if missing)

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['list']],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 30000,
  },
})
```

## E2E Test Patterns

### Page Object Pattern (Recommended)
```typescript
// e2e/pages/login.page.ts
import { type Page, type Locator } from '@playwright/test'

export class LoginPage {
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator
  readonly errorMessage: Locator

  constructor(private page: Page) {
    this.emailInput = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton = page.getByRole('button', { name: /sign in/i })
    this.errorMessage = page.getByRole('alert')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}
```

### Test Structure
```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/login.page'

test.describe('Authentication', () => {
  let loginPage: LoginPage

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    await loginPage.goto()
  })

  test('successful login redirects to dashboard', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123')
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible()
  })

  test('invalid credentials shows error', async ({ page }) => {
    await loginPage.login('user@example.com', 'wrong-password')
    await expect(loginPage.errorMessage).toContainText(/invalid credentials/i)
    await expect(page).toHaveURL('/login')  // Stay on login page
  })

  test('empty form shows validation errors', async ({ page }) => {
    await loginPage.submitButton.click()
    await expect(loginPage.emailInput).toHaveAttribute('aria-invalid', 'true')
  })
})
```

## Anti-Flake Patterns

### DO:
```typescript
// Wait for specific element, not arbitrary time
await expect(page.getByText('Order confirmed')).toBeVisible()

// Use role-based locators (resilient to text/class changes)
page.getByRole('button', { name: /submit/i })
page.getByLabel('Email address')
page.getByTestId('order-total')  // Fallback for complex components

// Wait for network idle after navigation
await page.goto('/dashboard')
await page.waitForLoadState('networkidle')

// Retry assertions automatically (Playwright does this)
await expect(page.getByText('Saved')).toBeVisible({ timeout: 5000 })
```

### DON'T:
```typescript
// NEVER use fixed timeouts
await page.waitForTimeout(3000)  // FLAKY - race condition

// NEVER use CSS selectors for text content
page.locator('.btn-primary')  // FRAGILE - class names change

// NEVER depend on element order
page.locator('button').nth(2)  // FRAGILE - order changes

// NEVER test implementation details
await expect(page.locator('[data-state="open"]')).toExist()  // FRAGILE
```

## Critical User Journeys to Test

For most web apps, these are the essential E2E tests:

1. **Sign up → Verify email → First login**
2. **Login → Navigate → Logout**
3. **Search → View results → Open detail**
4. **Add to cart → Checkout → Payment → Confirmation**
5. **Create resource → Edit → Delete**
6. **Invite team member → Accept invite → Collaborate**

Focus on these first. Don't test every page - that's what unit tests are for.

## Running Tests

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test e2e/auth.spec.ts

# Run with UI mode (great for debugging)
npx playwright test --ui

# Show report
npx playwright show-report
```
