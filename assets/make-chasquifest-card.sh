#!/usr/bin/env bash
# Regenera assets/chasquifest.png desde el dashboard publicado.
# Aísla el Caso 3 (el de -56.8% vs +11.5%), recorta y normaliza al canvas 2400x1280.
# Requiere: google-chrome, imagemagick, python3.
set -euo pipefail

URL="https://r0sewt.github.io/chasquifest-auditoria-visual/"
CASE=3
OUT="$(cd "$(dirname "$0")" && pwd)/chasquifest.png"
BG='#f9f9f7'   # --plane del dashboard en light mode
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -sSL "$URL" -o "$TMP/page.html"

# Ocultar todo salvo la card objetivo: header, las otras cards, y la coda
# (.twist / .pen) para que el corte quede en el borde del gráfico.
python3 - "$TMP/page.html" "$TMP/shot.html" "$CASE" <<'PY'
import sys
src, dst, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
html = open(src, encoding="utf-8").read()
inject = f"""<style>
header.top{{display:none!important}}
main>.case{{display:none!important}}
main>.case:nth-of-type({n}){{display:block!important;margin:0!important}}
.twist,.pen,footer,.foot{{display:none!important}}
body{{padding:0}}
.wrap{{max-width:1120px}}
</style>"""
open(dst, "w", encoding="utf-8").write(html.replace("</head>", inject + "</head>"))
PY

google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1200,760 --virtual-time-budget=7000 \
  --screenshot="$TMP/raw.png" "file://$TMP/shot.html" >/dev/null 2>&1

# El borde de 1px le da a -trim un color de referencia; el de 28px es el aire
# alrededor de la card. Luego se centra en el canvas comun de la grilla.
convert "$TMP/raw.png" \
  -bordercolor "$BG" -border 1 -fuzz 0% -trim +repage \
  -bordercolor "$BG" -border 28 \
  -background "$BG" -gravity center -extent 2400x1280 \
  "$OUT"

identify -format '%f  %wx%h  ratio=%[fx:w/h]\n' "$OUT"
