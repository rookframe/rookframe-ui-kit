// Build-time only. Requires Playwright on NODE_PATH and a Chromium executable.
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

async function exportFonts(directory, executablePath) {
  const profiles = JSON.parse(fs.readFileSync(path.join(directory, 'profiles.json')));
  const browser = await chromium.launch({ executablePath });
  try {
    const page = await browser.newPage();
    for (const profile of profiles) {
      const face = profile.name;
      const data = fs.readFileSync(path.join(directory, `${face}.ttf`)).toString('base64');
      const glyphs = JSON.parse(fs.readFileSync(path.join(directory, `${face}.json`)));
      await page.evaluate(async ({ data, face }) => {
        const font = await new FontFace(face, `url(data:font/ttf;base64,${data})`, {
          weight: '400 800',
        }).load();
        document.fonts.add(font);
      }, { data, face });
      for (const weight of profile.weights) {
        for (const size of profile.sizes) {
          const result = await page.evaluate(({ glyphs, profile, weight, size }) => {
            const pages = [];
            const records = [];
            let canvas, context, x, y, row;
            function startPage() {
              canvas = document.createElement('canvas');
              canvas.width = canvas.height = 1024;
              context = canvas.getContext('2d');
              context.font = `${weight} ${size}px ${profile.name}`;
              context.fillStyle = profile.color;
              x = y = row = 0;
            }
            function finishPage(height) {
              const pixels = context.getImageData(0, 0, 1024, height);
              // Preserve coverage, while allowing Godot to tint the glyphs.
              for (let i = 0; i < pixels.data.length; i += 4) {
                pixels.data[i] = pixels.data[i + 1] = pixels.data[i + 2] = 255;
              }
              const cropped = document.createElement('canvas');
              cropped.width = 1024;
              cropped.height = height;
              cropped.getContext('2d').putImageData(pixels, 0, 0);
              pages.push(cropped.toDataURL());
            }
            startPage();
            for (const glyph of glyphs) {
              const text = String.fromCodePoint(glyph.codepoint);
              const metrics = context.measureText(text);
              const left = Math.ceil(metrics.actualBoundingBoxLeft) + 2;
              const top = Math.ceil(metrics.actualBoundingBoxAscent) + 2;
              const width = Math.max(4, left + Math.ceil(metrics.actualBoundingBoxRight) + 2);
              const height = Math.max(4, top + Math.ceil(metrics.actualBoundingBoxDescent) + 2);
              if (x + width > 1024) {
                x = 0; y += row; row = 0;
              }
              if (y + height > 1024) {
                finishPage(1024); startPage();
              }
              context.fillText(text, x + left, y + top);
              records.push({
                glyph: glyph.glyph, advance: metrics.width, page: pages.length,
                x, y, width, height, left, top,
              });
              x += width;
              row = Math.max(row, height);
            }
            finishPage(Math.max(1, y + row));
            return { records, pages };
          }, { glyphs, profile, weight, size });
          const name = `${face}-${weight}-${size}`;
          fs.writeFileSync(path.join(directory, `${name}.json`), JSON.stringify(result.records));
          result.pages.forEach((image, index) => {
            fs.writeFileSync(path.join(directory, `${name}-${index}.png`),
              Buffer.from(image.split(',')[1], 'base64'));
          });
        }
        console.log(`${face} ${weight}: ${profile.sizes.length} sizes`);
      }
    }
    console.log(`Reference renderer: Chromium ${await browser.version()}`);
  } finally {
    await browser.close();
  }
}
exportFonts(path.resolve(process.argv[2]), process.argv[3]).catch(error => {
  console.error(error);
  process.exitCode = 1;
});
