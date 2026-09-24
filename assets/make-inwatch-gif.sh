#!/usr/bin/env bash
# Genera assets/inwatch.gif — el hexágono cortando manzanas.
#
# CORRER EN LA MÁQUINA QUE TIENE LOS DATOS (la Dell). Los loaders de InWatch
# leen de rutas absolutas tipo /home/rosewt-dell/Code/tesis/infelix/data; sin
# esos parquet no hay tesselación que dibujar.
#
# SIN PROBAR: se escribió sin poder ejecutarlo (esta máquina no tiene los
# datos). Correr primero con --preview y mirar el encuadre antes de la toma.
#
# Uso:
#   ./make-inwatch-gif.sh /ruta/a/InWatch [--preview] [--scroll N]
set -euo pipefail

IW="${1:?uso: $0 /ruta/al/checkout/de/InWatch [--preview] [--scroll N]}"; shift
EXTRA=("$@")
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/inwatch.gif"
FRAMES="$HERE/.inwatch-frames"
NB="experiments/tejido-vs-hexagono/notebook.py"
PORT=2718

IW="$(cd "$IW" && pwd)"
cd "$IW"

# --- preflight: fallar temprano y con motivo -------------------------------
[[ -f "$NB" ]] || { echo "error: no encuentro $NB en $IW"; exit 1; }
command -v uv >/dev/null || { echo "error: falta uv"; exit 1; }
command -v convert >/dev/null || { echo "error: falta imagemagick (convert)"; exit 1; }

# La ruta de datos está hardcodeada en el loader; la leemos de ahí en vez de
# repetirla acá, así si cambia en el repo esto no queda mintiendo.
SOURCE="$(grep -oP '^SOURCE = Path\("\K[^"]+' experiments/tejido-vs-hexagono/loader.py || true)"
if [[ -n "$SOURCE" && ! -d "$SOURCE" ]]; then
  echo "error: el loader espera datos en:"
  echo "         $SOURCE"
  echo "       y ahí no hay nada. Estás en la máquina equivocada, o movió el repo de origen."
  exit 1
fi

echo "==> dependencias"
uv sync --extra geo --extra viz

echo "==> precómputo (tarda: tesselación morfológica sobre Lima+Callao)"
uv run python "$NB/../loader.py"

echo "==> levantando marimo"
LOG="$(mktemp)"
uv run marimo run "$NB" --headless --port "$PORT" >"$LOG" 2>&1 &
MARIMO=$!
cleanup() { kill "$MARIMO" 2>/dev/null || true; rm -f "$LOG"; }
trap cleanup EXIT

# marimo imprime la URL (con access_token si lo pide). La sacamos del log en
# vez de construirla, que es lo que se rompe cuando cambian el esquema de auth.
URL=""
for _ in $(seq 1 60); do
  URL="$(grep -oE 'http://(localhost|127\.0\.0\.1):'"$PORT"'[^[:space:]]*' "$LOG" | head -1 || true)"
  [[ -n "$URL" ]] && break
  sleep 1
done
[[ -n "$URL" ]] || { echo "error: marimo no levantó. Log:"; cat "$LOG"; exit 1; }
echo "    $URL"

echo "==> capturando frames"
uv run --with playwright python "$HERE/inwatch-record.py" \
  --url "$URL" --out "$FRAMES" --headed "${EXTRA[@]}"

# Con --preview solo queremos mirar el encuadre.
if [[ " ${EXTRA[*]} " == *" --preview "* ]]; then
  echo "==> preview en $FRAMES/preview.png — miralo y reintentá sin --preview"
  exit 0
fi

echo "==> armando el GIF"
# -delay 8 = 12.5 fps. El último frame se queda quieto ~1.2s para que el loop
# descanse sobre el mapa con las dos capas en vez de cortar en seco.
convert -delay 8 -loop 0 "$FRAMES"/f_*.png \
        \( -clone -1 -set delay 120 \) \
        -layers optimize "$OUT"

identify -format '%f  %wx%h  ratio=%[fx:w/h]  frames=%n\n' "$OUT" | head -1
du -h "$OUT"
echo
echo "Revisar antes de darlo por bueno:"
echo "  · ¿el canvas salió pintado y no en negro? (WebGL)"
echo "  · ¿se lee a 470px de ancho, que es el tamaño real en el README?"
echo "  · ¿pesa menos de 3 MB? Si no, bajar frames o subir -delay."
