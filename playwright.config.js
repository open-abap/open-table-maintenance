// playwright.config.js
// @ts-check

/** @type {import('@playwright/test').PlaywrightTestConfig} */
const config = {
  testDir: 'test',
  timeout: 30000,
  forbidOnly: !!process.env.CI,
  retries: 0,
  // Limit the number of workers on CI, use default locally
  workers: process.env.CI ? 2 : undefined,
  use: {
    // Configure browser and context here
  },
};

module.exports = config;
