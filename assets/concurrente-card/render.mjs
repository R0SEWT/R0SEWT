// Renderiza el SVG de la card a PNG con Chromium. Las fuentes (Inter y
// JetBrains Mono, de @fontsource-variable) se incrustan en base64: el render no
// depende de la red ni de las fuentes del sistema.
import { chromium } from "playwright";
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const [svgPath, out, width = "2400", height = "1280"] = process.argv.slice(2);

const face = (family, pkg, subset) => {
  const file = require.resolve(`@fontsource-variable/${pkg}/files/${pkg}-${subset}-wght-normal.woff2`);
  const b64 = readFileSync(file).toString("base64");
  return `@font-face{font-family:"${family}";font-weight:100 900;src:url(data:font/woff2;base64,${b64}) format("woff2")}`;
};
const fonts = [
  face("Inter", "inter", "latin"),
  face("Inter", "inter", "greek"),        // Σ
  face("JetBrains Mono", "jetbrains-mono", "latin"),
].join("\n");

const html = `<!doctype html><html><head><style>${fonts}
html,body{margin:0;background:#fff}svg{display:block}</style></head>
<body>${readFileSync(svgPath, "utf8")}</body></html>`;

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
const page = await browser.newPage({ viewport: { width: +width, height: +height } });
await page.setContent(html);
await page.evaluate(() => document.fonts.ready);
const loaded = await page.evaluate(() => [...document.fonts].filter((f) => f.status === "loaded").map((f) => f.family));
for (const f of ['"Inter"', '"JetBrains Mono"'])
  if (!loaded.includes(f) && !loaded.includes(f.replaceAll('"', ""))) throw new Error(`font not loaded: ${f} (${loaded})`);
await page.screenshot({ path: out, clip: { x: 0, y: 0, width: +width, height: +height } });
await browser.close();
