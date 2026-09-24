#!/usr/bin/env bash
# Regenera assets/project-kit.gif grabando una sesión real de scaffold.sh.
#
# No es un terminal simulado: asciinema graba un pty de verdad y todo lo que
# se ve en el GIF es salida real del script. agg convierte el cast a GIF sin
# necesitar ffmpeg.
#
# Requiere: gh, asciinema, agg, eza, bd, uv, imagemagick.
#   uv tool install asciinema
#   gh release download v1.9.0 --repo asciinema/agg \
#     --pattern 'agg-x86_64-unknown-linux-musl' --output ~/.local/bin/agg && chmod +x ~/.local/bin/agg
#   gh release download v0.23.5 --repo eza-community/eza \
#     --pattern 'eza_x86_64-unknown-linux-gnu.tar.gz' | tar xz && mv eza ~/.local/bin/
set -euo pipefail

OUT="$(cd "$(dirname "$0")" && pwd)/project-kit.gif"
TARGET=/tmp/demo                  # sale en pantalla: tiene que ser corto
COLS=76; ROWS=22
RATIO=1.875                       # el canvas común de las cuatro cards del README
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP" "$TARGET"' EXIT

gh repo clone R0SEWT/project-kit "$TMP/pk" -- --depth 1 --quiet

# Driver: teclea el comando (para que se vea escribirse) y ejecuta el real.
cat > "$TMP/drive.sh" <<'DRIVE'
#!/usr/bin/env bash
set -u
export PATH="$HOME/.local/bin:$PATH"
# bd init pregunta el rol por stdin; sin esto la toma se cuelga en el prompt.
export BD_NON_INTERACTIVE=1
GREEN=$'\033[38;5;114m'; BLUE=$'\033[38;5;110m'; OFF=$'\033[0m'
type_out() { local s="$1" i; for (( i=0; i<${#s}; i++ )); do printf '%s' "${s:i:1}"; sleep 0.032; done; }
run() { printf '%s❯%s %s%s%s ' "$GREEN" "$OFF" "$BLUE" "$1" "$OFF"; type_out "$2"; printf '\n'; sleep 0.45; eval "$2"; }

sleep 0.8
run 'project-kit' './scripts/scaffold.sh /tmp/demo --profile data'
# Pausa para que "Done: 15 created" se lea antes de seguir.
sleep 1.8
printf '\n'
run 'demo' 'cd /tmp/demo && uv run pytest -q'
sleep 1.6
printf '\n'
# El árbol es el punto del GIF: qué quedó armado. Con -L 1 entra completo en
# las 22 filas junto al "1 passed", y ese es el frame donde descansa el loop.
run 'demo' 'eza -a --tree -L 1 --git-ignore'
sleep 3.4
DRIVE
chmod +x "$TMP/drive.sh"

# Calentar la cache de uv: si no, la toma se llena de "Downloading ..." y dura el doble.
rm -rf "$TARGET" /tmp/demo-warm
( cd "$TMP/pk" && BD_NON_INTERACTIVE=1 ./scripts/scaffold.sh /tmp/demo-warm --profile data ) >/dev/null 2>&1 || true
rm -rf /tmp/demo-warm "$TARGET"

# -i 1.2 recorta las pausas muertas; el resto del timing es el real.
( cd "$TMP/pk" && asciinema rec --cols "$COLS" --rows "$ROWS" --overwrite -q -i 1.2 \
    -c "$TMP/drive.sh" "$TMP/pk.cast" </dev/null )

# fps-cap 24 (no 12) es lo que hace que el scroll se vea fluido en vez de a
# saltos; speed 1.35 deja respirar las líneas `create:` en vez de borronearlas.
agg --font-size 14 --speed 1.35 --fps-cap 24 --theme github-dark "$TMP/pk.cast" "$TMP/raw.gif"

# agg da un lienzo más alto que 1.875:1. Se completa con el fondo del propio
# terminal en vez de reescalar, para no emborronar el texto.
# El \n final no es cosmético: sin él `read` devuelve 1 al llegar a EOF y
# `set -e` aborta el script justo antes del convert.
read -r W H < <(identify -format '%w %h\n' "$TMP/raw.gif[0]")
BG="$(convert "$TMP/raw.gif[0]" -format '%[pixel:p{2,2}]' info:)"
TW=$(python3 -c "print(round($H * $RATIO))")
convert "$TMP/raw.gif" -coalesce -background "$BG" -gravity center \
        -extent "${TW}x${H}" -layers optimize "$OUT"

identify -format '%f  %wx%h  ratio=%[fx:w/h]  frames=%n\n' "$OUT" | head -1
du -h "$OUT"
