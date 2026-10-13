// Export the approved repeating SVG as it is painted by the HTML authority.
// NODE_PATH must provide Playwright; pass the Chromium executable as argv[2].
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

(async () => {
  const directory = path.resolve(__dirname, '../rookframe/ui/assets/silkbound-ledger');
  const source = fs.readFileSync(path.join(directory, 'linen.svg'));
  const browser = await chromium.launch({ executablePath: process.argv[2] });
  try {
    const page = await browser.newPage({
      viewport: { width: 288, height: 288 }, deviceScaleFactor: 1,
    });
    const url = `data:image/svg+xml;base64,${source.toString('base64')}`;
    await page.setContent(`<style>
      html,body{margin:0;background:transparent}
      div{width:288px;height:288px;background-image:url("${url}")}
    </style><div></div>`);
    await page.evaluate(async (url) => {
      const image = new Image(); image.src = url; await image.decode();
      await new Promise(requestAnimationFrame);
    }, url);
    // An interior tile preserves the reference's repeated-background painting,
    // including the strands crossing SVG boundaries. An <img> export differs.
    await page.screenshot({
      path: process.argv[3] || path.join(directory, 'linen.png'),
      omitBackground: true, clip: { x: 96, y: 96, width: 96, height: 96 },
    });
    console.log(`Exported approved linen using ${await browser.version()}`);
  } finally {
    await browser.close();
  }
})();
