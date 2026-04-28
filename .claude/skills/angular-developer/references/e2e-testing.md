# End-to-End (E2E) Testing

This project uses [Playwright](https://playwright.dev/) for end-to-end (E2E) testing, which simulates real user interactions in a browser. The E2E tests are located primarily within the `devtools/` package.

## Running E2E Tests

The primary way to run E2E tests is through the `pnpm` script defined in the root `package.json`.

1.  **Build DevTools:** The E2E tests run against a built version of the devtools extension. You must build it first:

    ```shell
    pnpm -F ng-devtools-mcp build:dev
    ```

2.  **Run Playwright:** Use the Playwright scripts:
    - To open Playwright UI mode for interactive debugging:
      ```shell
      pnpm -F ng-devtools-mcp test:e2e --ui
      ```
    - To run tests headlessly in the terminal (ideal for CI):
      ```shell
      pnpm -F ng-devtools-mcp test:e2e
      ```
    - To run with the Playwright HTML report:
      ```shell
      pnpm -F ng-devtools-mcp test:e2e --reporter=html
      ```

## Test Structure

- **Configuration:** The main Playwright configuration is located at `devtools/playwright.config.ts`.
- **Specs:** Test files are located in `devtools/e2e/` (commonly `*.spec.ts`).
- **Fixtures and Helpers:** Reusable fixtures and helpers are typically kept in `devtools/e2e/fixtures/` and `devtools/e2e/utils/`.

### Example E2E Test Snippet

A typical test might look like this:

```typescript
// in devtools/e2e/profiler.spec.ts

import { test, expect } from '@playwright/test';

test.describe('Profiler', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/?e2e-app');
    await page.getByRole('link', { name: 'Profiler' }).click();
  });

  test('should record and display profiling data', async ({ page }) => {
    // Find the record button and click it
    await page.locator('button[aria-label="start-recording-button"]').click();

    // Interact with the test application to generate profiling data
    await page.locator('#cards button').first().click();

    // Stop recording
    await page.locator('button[aria-label="stop-recording-button"]').click();

    // Assert that the flame graph is now visible
    await expect(page.locator('ng-devtools-recording-timeline canvas')).toBeVisible();
  });
});
```

### Best Practices

- **Use stable selectors:** Prefer `getByRole`, `getByLabel`, or `data-testid` selectors to make tests resilient to CSS and DOM changes.
- **Use fixtures:** Encapsulate common setup (authentication, seeded data, navigation) in Playwright fixtures instead of repeating steps in each test.
- **Wait on explicit state:** Avoid fixed delays. Use Playwright assertions (`await expect(...)`) and route/network waiting for deterministic synchronization.
