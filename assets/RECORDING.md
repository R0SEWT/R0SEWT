# Assets del README

Las cuatro cards comparten un canvas fijo. Cualquier asset nuevo debe respetar
el ratio o la grilla se desalinea: las dos celdas de una fila se muestran con
`width="100%"`, así que si los ratios difieren, las alturas difieren y los
textos de abajo dejan de coincidir.

| Parámetro | Valor |
|---|---|
| Ratio | **1.875:1** (no negociable) |
| Peso máximo | **< 3 MB** por asset animado |
| Fondo | opaco, nada transparente |

El tamaño en píxeles no importa mientras el ratio sea correcto — lo que manda
es la resolución suficiente para que no se vea borroso a ~470 px de ancho.

| Asset | Estado | Receta |
|---|---|---|
| `geno-map.png` | ✅ 887×473 | nativo del pipeline del póster, ya es 1.875:1 exacto |
| `chasquifest.png` | ✅ 2400×1280 | `make-chasquifest-card.sh` |
| `project-kit.gif` | ✅ 846×451, 304 KB | `make-project-kit-gif.sh` |
| `inwatch.webp` | ✅ 840×448, 53 frames, 2,3 MB | ver abajo |

---

## project-kit — hecho

`make-project-kit-gif.sh` graba una sesión real: asciinema captura un pty de
verdad y todo lo que aparece es salida auténtica de `scaffold.sh`. No es un
terminal simulado.

Son tres beats: el scaffold corriendo, `uv run pytest -q` en verde, y un
`eza -a --tree -L 1` que muestra **qué quedó armado**. Ese último es el punto
del GIF — un scroll de `create:` demasiado rápido se lee como borrón; el árbol
deja ver los componentes. Con `-L 1` entra completo en las 22 filas junto al
`1 passed`, así que el loop descansa sobre un frame que dice a la vez "funciona"
y "esto es lo que tenés".

Herramientas: **asciinema + agg**, no vhs. vhs necesita `ttyd` y `ffmpeg` del
sistema; agg convierte el cast a GIF sin ninguno de los dos y es un solo
binario. El árbol lo dibuja **eza** (`tree` no viene instalado y requiere sudo).

**Ritmo.** `--fps-cap 24` es lo que hace que el scroll se vea fluido en vez de
a saltos — con 12 se notaban los escalones. `--speed 1.35` (antes 1.6) deja
respirar las líneas `create:`. Y hay pausas explícitas en el driver después del
`Done:` y del `1 passed`, para que cada beat aterrice antes del siguiente.
Cuesta 304 KB en vez de 180, muy dentro del presupuesto.

Tres cosas que costaron y están resueltas en el script:

- **`bd init` es interactivo.** Pregunta el rol por stdin y la grabación se
  cuelga en el prompt. Se evita con `BD_NON_INTERACTIVE=1`.
- **76 columnas, no 104.** A 104 el texto quedaba en ~6 px al escalar la card a
  470 px: ilegible. A 76 las líneas que importan (`create:`, `Done:`,
  `1 passed`) siguen entrando sin wrap y el texto es ~37% más grande. Por eso
  también el target es `/tmp/demo` y no `/tmp/demo-project`.
- **Calentar la cache de uv** antes de la toma, o el GIF se llena de
  `Downloading polars-runtime-32 (47.6MiB)` y dura el doble.

El padding lateral hasta 1.875:1 se hace con el color de fondo del propio
terminal en vez de reescalar, para no emborronar el texto.

Se probó reemplazarlo por una card diseñada con números grandes (fuente en el
scratchpad de la sesión). Se descartó: quedaba desconectada del resto. El GIF
se queda.

---

## InWatch — webp, no GIF

La card sale de un mp4 de `pulso-estadios` (riesgo de robo callejero alrededor
de los estadios, hora por hora) grabado en la máquina que tiene los datos.

**GIF no servía.** El contenido es un mapa oscuro con gradientes fotográficos y
cámara en movimiento: cada frame cambia entero y el dithering agrega ruido que
mata la compresión. Medido, no estimado:

| variante | peso |
|---|---|
| 21 s completos, 10 fps, 900 px | 64 MB |
| acelerado 1.6×, 12 fps | 48 MB |
| solo el tramo del Monumental, 5,4 s | **19 MB** |

Con presupuesto de 3 MB, ni el clip más corto entraba. El mismo tramo en
**webp animado** pesa 2,3 MB — unas 8× menos.

**`<video>` no es opción.** GitHub lo elimina entero del README; verificado
contra su API de markdown, devuelve un `<p></p>` vacío. `<img src="...webp">`
sí sobrevive.

Cómo se generó:

```bash
ffmpeg -i pulso.mp4 \
  -vf "trim=13.6:18.9,setpts=PTS-STARTPTS,fps=10,scale=840:448:flags=lanczos" \
  -c:v libwebp_anim -lossless 0 -q:v 58 -compression_level 5 -loop 0 -an inwatch.webp
```

Cuatro cosas que costaron:

- **840×448, no 800×426.** `scale=800:-2` redondea el alto a 426 y el ratio se
  va a 1.878. Para que dé 1.875 exacto el ancho tiene que ser múltiplo de 15
  (`h = w·8/15` entero y par): 840→448, 900→480, 750→400.
- **`compression_level 6` es inusable.** `libwebp_anim` es monohilo: 21 s a
  900 px llevaba más de 3 minutos sin escribir un byte (bufferea todo y escribe
  al final, así que el archivo se queda en 0 y parece colgado). Con 3–5 tarda
  ~6 s.
- **Para inspeccionar frames hay que `-coalesce`.** webp guarda deltas; sin eso
  las zonas que no cambian salen transparentes y `convert` las pinta de blanco.
  Parece que el encode se corrompió y no es así.
- **El ffmpeg de Playwright no sirve.** Es un build recortado sin decoder h264
  ni muxer gif; ni hace probe. Se puede traer uno completo desde PyPI sin sudo:
  `uv run --with imageio-ffmpeg python -c "import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())"`.

**Deuda conocida.** El mp4 de origen llegó por WhatsApp, o sea recomprimido, y
eso queda horneado en la card. PR R0SEWT/InWatch#38 mete la pieza al repo y la
vuelve regenerable; cuando entre, conviene regenerar el mp4 limpio y volver a
encodear con el comando de arriba.

### La alternativa que existe y no se usó

Hay un GIF de `tejido-vs-hexagono` grabado en la Dell (900×480, 1,29 MB, bucle
sin salto) que en papel es mejor: más liviano y coincide con el texto anterior
de la card. No se usó porque nunca llegó a esta máquina, y porque está grabado
contra PR R0SEWT/InWatch#37, que sigue abierto — si ese PR no entra, hay que
re-grabarlo. El detalle está en R0SEWT/R0SEWT#1.

Lo que ese intento dejó aprendido, por si se retoma: togglear una capa
**reconstruye el iframe entero** (pydeck se re-serializa, 10-15 s con un velo
gris de marimo encima), así que grabar en continuo da casi solo velo — hay que
esperar a que el render se asiente y armar el bucle con dos estados y
duraciones largas. Y el canvas WebGL **no** salió negro en headless con
`--use-angle=swiftshader --enable-unsafe-swiftshader`; no hizo falta `--headed`.

`make-inwatch-gif.sh` e `inwatch-record.py` quedan en `assets/` para eso.

---

## El sanitizador de GitHub: qué sobrevive y qué no

Todo verificado contra `POST /markdown` de la API, no supuesto. Ahorra
adivinar en la próxima vuelta.

| Se elimina | Sobrevive |
|---|---|
| `style="…"` (el atributo entero) | `width`, `align` en `<img>` y `<td>`, `valign` en `<td>` |
| `onerror`, cualquier handler de evento | `<h3 id="x">` → sale como `id="user-content-x"`, y los links `#x` funcionan |
| `<video>` completo (queda `<p></p>`) | `<a name="x">` → `name="user-content-x"` |
| | `<img src="….webp">` animado |

Consecuencias que ya se aplicaron en el README:

- **Zebra de tablas.** `tr:nth-child(2n)` va gris y no hay `style` para
  anularlo → una tabla por fila de cards, así cada `<tr>` es el primero.
- **Alinear las dos cards de stats.** Tienen alturas distintas y la de
  lenguajes quedaba flotando al medio. `align="top"` en cada `<img>` las
  alinea arriba sin meter otra tabla (que traería bordes).
- **Anclas a las cards.** Los `<h3>` en HTML crudo dentro de `<td>` **no**
  reciben ancla automática (salen como `<h3 dir="auto">` pelados). Con `id`
  explícito sí.
- **Fallback de imagen rota no existe.** El `onerror` del README anterior
  nunca disparó; la única defensa es que la imagen esté en este repo.

---

## Dónde viven los assets

Los cuatro están en `assets/` de **este** repo, no hotlinkeados desde los repos
de cada proyecto. Es a propósito: el README del perfil es la vitrina y no
debería romperse porque en otro repo se renombró una rama o se movió una
figura. El README publicado hoy sí hotlinkea `raw.githubusercontent.com` de
tres repos distintos, y eso es una dependencia silenciosa.

Nada impide tener además una copia en el repo del proyecto — los READMEs de
InWatch y project-kit tampoco tienen ninguna imagen hoy, así que el mismo GIF
les sirve.
