const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('http://localhost:3000/abap');
  await page.screenshot({ path: 'screenshot.png' });
  await browser.close();
})();