#!/usr/bin/env bash
# Regenera assets/concurrente.png: Nueva York en cuatro momentos, cada zona de
# taxi pintada con su arquetipo de viaje dominante. La figura la genera
# R0SEWT/concurrente (tp/scripts/hero_mapa.py) desde sus propios datos; acá solo
# se fija la revisión y se rasteriza el SVG al canvas 2400x1280.
# Requiere: git, uv, node y un Chromium para Playwright (npx playwright install
# chromium, o CHROMIUM=/ruta/al/binario).
set -euo pipefail

REV="${REV:-fe754f5}"   # commit de concurrente con hero_mapa.py
DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone -q https://github.com/R0SEWT/concurrente "$TMP/concurrente"
git -C "$TMP/concurrente" checkout -q "$REV"
(cd "$TMP/concurrente/tp" && uv run --no-project scripts/hero_mapa.py -o "$TMP/mapa.svg")

cd "$DIR/concurrente-card"
[[ -d node_modules ]] || npm install --no-audit --no-fund --silent
node render.mjs "$TMP/mapa.svg" "$DIR/concurrente.png" 2400 1280
echo "ok: $DIR/concurrente.png"
