// Renders an SVG to a PNG with a transparent background (generate.sh). Quick Look, used before,
// paints SVGs on white, which gave every icon opaque white corners around its rounded tile.
//
//   node render.mjs <in.svg> <out.png> <size>
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

// playwright-core is a dev dependency of desiide-ai (its webview harness) in the desiide repo.
const require = createRequire(
  fileURLToPath(new URL('../../../../extensions/desiide-ai/package.json', import.meta.url)),
);
const { chromium } = require('playwright-core');

const [input, output, sizeArg] = process.argv.slice(2);
const size = Number(sizeArg);
if (!input || !output || !Number.isInteger(size)) throw new Error('usage: render.mjs <in.svg> <out.png> <size>');
const svg = readFileSync(input, 'utf8');
const browser = await chromium.launch();
try {
  const page = await browser.newPage({ viewport: { width: size, height: size } });
  const src = `data:image/svg+xml;base64,${Buffer.from(svg).toString('base64')}`;
  await page.setContent(
    `<style>html,body{margin:0;background:transparent}</style><img src="${src}" width="${size}" height="${size}">`,
  );
  await page.locator('img').evaluate((img) => img.decode());
  await page.screenshot({ path: output, omitBackground: true });
} finally {
  await browser.close();
}
