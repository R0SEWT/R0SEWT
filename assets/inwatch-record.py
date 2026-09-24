"""Captura los frames del GIF de InWatch desde el notebook marimo ya servido.

No graba video: toma screenshots del viewport y los deja numerados en --out.
El GIF lo arma `make-inwatch-gif.sh` con ImageMagick. Se eligió así porque el
mapa es pydeck (WebGL dentro de un iframe) y el encoder de video de Playwright
agrega una dependencia que no hace falta — la animación son cambios de estado
discretos, no movimiento continuo.

El viewport es 1200x640 = 1.875:1, el canvas común de las cards del README, así
que los frames ya salen con el ratio correcto y no hay que padear nada.

Uso:
    python inwatch-record.py --url <url> --out frames/ [--preview] [--headed]

--preview toma UNA captura y sale. Correr eso primero: si el mapa no entra en
cuadro o los controles quedan fuera, se ajusta --scroll antes de gastar la toma.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

VIEWPORT = {"width": 1200, "height": 640}

# Etiquetas exactas de los checkboxes, de experiments/tejido-vs-hexagono/notebook.py:
#   mo.ui.checkbox(value=True, label="Tesselación morfológica (azul)")
#   mo.ui.checkbox(value=True, label="Grilla H3 res-8 (naranja)")
CAPA_HEX = "Grilla H3 res-8"
CAPA_TEJIDO = "Tesselación morfológica"


def find_checkbox(page, texto: str):
    """Ubica el checkbox por su etiqueta, con varios intentos.

    marimo puede cambiar cómo renderiza el label entre versiones, así que si
    ninguno funciona listamos lo que sí hay en vez de fallar en silencio.
    """
    intentos = [
        lambda: page.get_by_role("checkbox", name=re.compile(texto, re.I)),
        lambda: page.locator(f"label:has-text('{texto}')").locator("input[type=checkbox]"),
        lambda: page.locator(f"*:has-text('{texto}') >> input[type=checkbox]").first,
    ]
    for intento in intentos:
        try:
            loc = intento()
            if loc.count() > 0:
                loc.first.wait_for(state="visible", timeout=4000)
                return loc.first
        except Exception:
            continue

    etiquetas = page.locator("label").all_inner_texts()
    print(f"\n  No encontré el checkbox '{texto}'.", file=sys.stderr)
    print("  Labels presentes en la página:", file=sys.stderr)
    for e in etiquetas:
        if e.strip():
            print(f"    · {e.strip()[:90]}", file=sys.stderr)
    print("\n  Ajustá CAPA_HEX / CAPA_TEJIDO arriba con el texto real.", file=sys.stderr)
    sys.exit(2)


def esperar_mapa(page):
    """El deck.gl tarda en pintar; sin esto los primeros frames salen vacíos."""
    try:
        frame = page.frame_locator("iframe").first
        frame.locator("canvas").first.wait_for(state="visible", timeout=45_000)
    except Exception:
        print("  aviso: no vi un <canvas> dentro del iframe; sigo igual.", file=sys.stderr)
    page.wait_for_timeout(3500)  # margen para que deck.gl termine de pintar


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", required=True, help="URL que imprimió `marimo run`")
    ap.add_argument("--out", default="frames", help="directorio de salida")
    ap.add_argument("--scroll", type=int, default=0,
                    help="px a scrollear antes de capturar; subir si el mapa queda abajo")
    ap.add_argument("--preview", action="store_true", help="una captura y salir")
    ap.add_argument("--headed", action="store_true",
                    help="navegador visible. Recomendado: WebGL headless puede salir en negro")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for viejo in out.glob("f_*.png"):
        viejo.unlink()

    n = 0

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=not args.headed,
            # SwiftShader da WebGL por software: sin esto el canvas puede salir
            # en negro cuando no hay GPU disponible.
            args=["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"],
        )
        page = browser.new_context(viewport=VIEWPORT, device_scale_factor=2).new_page()
        page.goto(args.url, wait_until="networkidle", timeout=90_000)
        esperar_mapa(page)

        if args.scroll:
            page.evaluate(f"window.scrollTo(0, {args.scroll})")
            page.wait_for_timeout(700)

        if args.preview:
            page.screenshot(path=str(out / "preview.png"))
            print(f"  preview -> {out / 'preview.png'}")
            print("  Miralo. Si el mapa no entra o faltan los controles, ajustá --scroll.")
            browser.close()
            return 0

        def capturar(cuantos: int, cada_ms: int):
            nonlocal n
            for _ in range(cuantos):
                page.screenshot(path=str(out / f"f_{n:03d}.png"))
                n += 1
                page.wait_for_timeout(cada_ms)

        hexagono = find_checkbox(page, CAPA_HEX)

        # El guion: las dos capas encima de la misma cuadra, se saca la grilla,
        # se la vuelve a poner. Ahí se ve el hexágono cortando manzanas.
        capturar(10, 120)          # A. ambas capas — arranque en reposo
        hexagono.click()
        capturar(14, 90)           # B. la grilla se va
        capturar(12, 140)          # C. solo el tejido: la forma real
        hexagono.click()
        capturar(14, 90)           # D. la grilla vuelve encima
        capturar(16, 140)          # E. reposo final — donde cierra el loop

        browser.close()

    print(f"  {n} frames -> {out}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
