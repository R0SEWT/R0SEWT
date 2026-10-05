#!/usr/bin/env bash
# Regenera assets/concurrente.png: una iteración de Lloyd del worker pool de
# R0SEWT/concurrente, dibujada como SVG (concurrente-card/build.mjs) y
# rasterizada con Chromium al canvas 2400x1280.
# Requiere: node y un Chromium para Playwright (npx playwright install chromium,
# o CHROMIUM=/ruta/al/binario).
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR/concurrente-card"
[[ -d node_modules ]] || npm install --no-audit --no-fund --silent
node build.mjs concurrente-card.svg
node render.mjs concurrente-card.svg "$DIR/concurrente.png" 2400 1280
echo "ok: $DIR/concurrente.png"
