#!/usr/bin/env bash
# Regenera assets/concurrente.png: el diagrama Archify del K-means concurrente
# (concurrente.archify.json), validado contra el código de R0SEWT/concurrente
# en la revisión fijada en meta.repository, y normalizado al canvas 2400x1280.
# Requiere: git, node 22 con playwright, chromium, imagemagick.
#   CHROME=/ruta/a/chrome ./make-concurrente-card.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SPEC="$HERE/concurrente.archify.json"
OUT="$HERE/concurrente.png"
ARCHIFY_REV=594f6087358610bd16e64e5602976020871b6bff   # archify v3.0.1
REPO_REV="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['meta']['repository']['revision'])" "$SPEC")"
CHROME="${CHROME:-$(command -v chromium || command -v google-chrome)}"
BG='#ffffff'   # fondo del tema light de Archify
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone -q https://github.com/tt-a1i/archify.git "$TMP/archify"
git -C "$TMP/archify" checkout -q "$ARCHIFY_REV"
git clone -q https://github.com/R0SEWT/concurrente.git "$TMP/concurrente"
git -C "$TMP/concurrente" checkout -q "$REPO_REV"

# finalize valida el JSON, comprueba cada `sources` contra el repo y corre el
# gate de navegador. Si falla, no hay card.
mkdir -p "$TMP/work/.archify/dataflow-concurrente"
cp "$SPEC" "$TMP/work/.archify/dataflow-concurrente/candidate.json"
(cd "$TMP/work" && ARCHIFY_CHROME="$CHROME" node "$TMP/archify/archify/bin/archify.mjs" finalize dataflow \
  .archify/dataflow-concurrente/candidate.json .archify/dataflow-concurrente/concurrente.html \
  --repo-root "$TMP/concurrente" --quality showcase --json >/dev/null)

# Solo el <svg> del diagrama, sin toolbar, cards ni índice de nodos.
cat > "$TMP/shot.js" <<'JS'
const { chromium } = require('playwright');
(async () => {
  const [html, png, exe] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: exe });
  const p = await b.newPage({ viewport: { width: 1440, height: 1000 }, deviceScaleFactor: 2 });
  await p.goto('file://' + html + '?theme=light');
  await p.waitForTimeout(800);
  await p.screenshot({ path: png, clip: await p.locator('svg[data-quality-profile]').boundingBox() });
  await b.close();
})();
JS
NODE_PATH="$(npm root -g)" node "$TMP/shot.js" \
  "$TMP/work/.archify/dataflow-concurrente/concurrente.html" "$TMP/raw.png" "$CHROME"

# Mismo tratamiento que chasquifest: trim, aire de 28px y centrado en el canvas
# común. El svg es más ancho que 1.875:1, así que primero se ajusta al ancho.
convert "$TMP/raw.png" \
  -bordercolor "$BG" -border 1 -fuzz 0% -trim +repage \
  -resize 2344x \
  -bordercolor "$BG" -border 28 \
  -background "$BG" -gravity center -extent 2400x1280 \
  "$OUT"

identify -format '%f  %wx%h  ratio=%[fx:w/h]\n' "$OUT"
