import { defineConfig, devices } from '@playwright/test';
import { loadEnvConfig } from '@next/env';

// The Playwright runner is a separate Node process from the Next.js dev server, so
// it does NOT auto-load .env.local. e2e/global.setup.ts reads AUTH_SECRET there to
// mint the synthetic Auth.js session for authenticated tests; without it the setup
// writes an empty session ({cookies:[]}) and ALL authenticated coverage silently
// skips. Load Next's env files the same way Next does. @next/env does not override
// variables already present in process.env, so CI (which injects AUTH_SECRET as a
// step env var) is unaffected.
loadEnvConfig(process.cwd(), true);

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
  testDir: './e2e',

  /* Global setup: logs in as Editor and Admin (if credentials are configured) and
   * saves storageState files that authenticated-flows.spec.ts reuses.
   * Runs before any test. Skips gracefully when E2E_EDITOR_EMAIL is not set. */
  globalSetup: './e2e/global.setup.ts',

  /* Run tests in files in parallel */
  fullyParallel: true,

  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,

  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,

  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,

  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: process.env.CI ? [['html'], ['github']] : 'html',

  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:3000',

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',

    /* Screenshot on failure */
    screenshot: 'only-on-failure',

    /* Video on failure */
    video: 'retain-on-failure',
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: { ...devices['Pixel 5'] },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: { ...devices['iPhone 12'] },
    // },
  ],

  /* Run your local dev server before starting the tests */
  webServer: {
    // In CI the workflow builds and starts the frontend before running tests.
    // `reuseExistingServer: true` means Playwright reuses it; if none is running
    // (local dev without a server) it falls back to starting `npm run dev`.
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: true,
    timeout: 120 * 1000,
    stdout: 'ignore',
    stderr: 'pipe',
  },
});
