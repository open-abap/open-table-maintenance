import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost:3000/abap');

  await page.dblclick('text=1_ >> :nth-match(td, 3)');
  await page.fill('input', 'foo');
  await page.press('input', 'Enter', {delay: 100});

  await page.dblclick('tr:nth-child(2) td:nth-child(3)');
  await page.fill('input', 'bar');

  await page.dblclick('tr:nth-child(2) td:nth-child(2)');
  await page.fill('input', 'sdf');

  await page.click('text=Save', {delay: 100});
  page.once('dialog', dialog => {
    console.log(`Dialog message: ${dialog.message()}`);
    dialog.dismiss().catch(() => {});
  });

  await page.goto('http://localhost:3000/abap', {waitUntil: 'domcontentloaded'});
  await page.waitForTimeout(100);
  expect(page.locator('tr:nth-child(2) td:nth-child(3)')).toHaveText('bar');

  await page.screenshot({ path: 'screenshot.png' });
});
