// Rasteriza un SVG a PNG con Chromium, dentro de un <img> como lo muestra GitHub:
// sin acceso a fuentes externas, así que solo sale bien si el SVG trae sus fuentes.
import { chromium } from "playwright";
import { readFileSync } from "node:fs";

const [svg, out, w = "2400", h = "1280"] = process.argv.slice(2);
const src = `data:image/svg+xml;base64,${readFileSync(svg).toString("base64")}`;

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
const page = await browser.newPage({ viewport: { width: +w, height: +h } });
await page.setContent(`<body style="margin:0;background:#fff"><img id="i" width="${w}" src="${src}"></body>`);
await page.waitForFunction(() => document.getElementById("i").complete);
await page.waitForTimeout(500); // las fuentes incrustadas se decodifican después del load
await page.screenshot({ path: out, clip: { x: 0, y: 0, width: +w, height: +h } });
await browser.close();
