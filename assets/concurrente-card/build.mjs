// Dibuja la card de concurrente como SVG: una iteración de Lloyd del worker
// pool de R0SEWT/concurrente (tp/kmeans/concurrente.go). Escala de la card:
// 2400x1280 vista a ~470 px, así que ningún texto baja de 30 px.
import { writeFileSync } from "node:fs";

const W = 2400, H = 1280;
const INK = "#1d2433", MUTED = "#5b6474", FAINT = "#9aa3b2", LINE = "#d7dce4";
const RED = "#d6334a", TEAL = "#0f6b56";
const SANS = "Inter, sans-serif", MONO = "'JetBrains Mono', monospace";

// Tono por índice de chunk: claro → oscuro. El orden se lee como gradiente.
const shades = ["#d3efe5", "#b3e3d3", "#8fd3bd", "#66bfa3", "#3fa688", "#238b6f", "#147459", "#0b5b46"];
const fg = (c) => (c < 4 ? "#0b3d30" : "#ffffff");

// Planificación de ejemplo, coherente con un canal FIFO: cada worker libre
// recibe el siguiente chunk. Tiempos en unidades arbitrarias.
const lanes = [
  [[1, 0, 190], [5, 200, 400]],
  [[0, 10, 230], [6, 240, 450]],
  [[3, 20, 180], [4, 190, 420]],
  [[2, 30, 260], [7, 270, 380]],
];

const GX = 470, GW = 830, TMAX = 450, tx = (t) => GX + (t / TMAX) * GW;
const LY = 290, LH = 92, LG = 22, ly = (i) => LY + i * (LH + LG);
const BX = 1350;                       // barrera
const PY = 810, PH = 92, PW = 92, PP = 104, px = (c) => GX + c * PP;
const PROW_END = px(7) + PW;

const t = (x, y, s, { size = 34, weight = 500, fill = INK, font = SANS, anchor = "start", ls = 0 } = {}) =>
  `<text x="${x}" y="${y}" font-family="${font}" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}" letter-spacing="${ls}">${s}</text>`;

let s = "";

// Eyebrow
s += t(80, 104, "ONE LLOYD ITERATION", { size: 30, weight: 700, fill: MUTED, font: MONO, ls: 3 });
s += t(80, 150, "tp/kmeans/concurrente.go", { size: 30, fill: FAINT, font: MONO });

// Banda de solo lectura sobre los workers
s += `<rect x="${GX}" y="180" width="${GW}" height="74" rx="14" fill="#f1f3f7" stroke="${LINE}" stroke-width="2"/>`;
s += t(GX + 28, 230, "X · centroids", { size: 36, weight: 700, font: MONO });
s += t(GX + GW - 28, 230, "read-only, no locks", { size: 32, fill: MUTED, anchor: "end" });

// Canal
const CX = 90, CW = 170, CT = 56, CH = 46;
s += t(CX, 150 + 80, "chan", { size: 30, fill: MUTED, font: MONO });
s += t(CX, 270 - 4, "trabajos", { size: 36, weight: 700, font: MONO });
s += `<rect x="${CX - 14}" y="${LY - 14}" width="${CW + 28}" height="${8 * CT + 18}" rx="18" fill="none" stroke="${LINE}" stroke-width="3"/>`;
for (let c = 0; c < 8; c++) {
  const y = LY + c * CT;
  s += `<rect x="${CX}" y="${y}" width="${CW}" height="${CH}" rx="9" fill="${shades[c]}"/>`;
  s += t(CX + CW / 2, y + 34, `c${c}`, { size: 32, weight: 700, font: MONO, fill: fg(c), anchor: "middle" });
}
const CHMID = LY + (8 * CT) / 2 - 10;
s += `<path d="M ${CX + CW + 30} ${CHMID} L ${GX - 110} ${CHMID}" stroke="${FAINT}" stroke-width="4" marker-end="url(#gray)"/>`;
s += t(CX + CW + 40, CHMID + 64, "FIFO", { size: 30, fill: FAINT, font: MONO });

// Workers
for (let i = 0; i < 4; i++) {
  const y = ly(i);
  s += t(GX - 22, y + LH / 2 + 12, `G${i + 1}`, { size: 34, weight: 700, font: MONO, fill: MUTED, anchor: "end" });
  s += `<line x1="${GX}" y1="${y + LH / 2}" x2="${BX}" y2="${y + LH / 2}" stroke="${LINE}" stroke-width="2"/>`;
  let end = 0;
  for (const [c, a, b] of lanes[i]) {
    const x0 = tx(a), x1 = tx(b) - 6;
    s += `<rect x="${x0}" y="${y}" width="${x1 - x0}" height="${LH}" rx="12" fill="${shades[c]}"/>`;
    s += t((x0 + x1) / 2, y + LH / 2 + 13, `c${c}`, { size: 36, weight: 700, font: MONO, fill: fg(c), anchor: "middle" });
    end = x1;
  }
  // espera en la barrera
  s += `<line x1="${end + 14}" y1="${y + LH / 2}" x2="${BX - 12}" y2="${y + LH / 2}" stroke="${RED}" stroke-width="4" stroke-dasharray="3 11" stroke-linecap="round"/>`;
  s += `<circle cx="${end + 2}" cy="${y + LH / 2}" r="9" fill="${RED}"/>`;
}
s += t(GX, ly(3) + LH + 52, "workers take chunks in any order", { size: 32, fill: MUTED });
s += t(BX - 24, ly(3) + LH + 52, "Done()", { size: 30, fill: RED, font: MONO, anchor: "end" });

// Parciales, ordenados por chunk
for (let c = 0; c < 8; c++) {
  s += `<rect x="${px(c)}" y="${PY}" width="${PW}" height="${PH}" rx="12" fill="${shades[c]}"/>`;
  s += t(px(c) + PW / 2, PY + PH / 2 + 12, `${c}`, { size: 36, weight: 700, font: MONO, fill: fg(c), anchor: "middle" });
}
s += t(GX, PY + PH + 50, "parciales[c]", { size: 34, weight: 700, font: MONO });
s += t(GX + 262, PY + PH + 50, "stored by index · one writer each", { size: 32, fill: MUTED });

// Barrera
s += `<line x1="${BX}" y1="180" x2="${BX}" y2="${PY + PH + 24}" stroke="${RED}" stroke-width="6" stroke-dasharray="18 12"/>`;
s += t(BX, 160, "wg.Wait()", { size: 34, weight: 700, font: MONO, fill: RED, anchor: "middle" });

// Reducción en orden de chunk → centroides nuevos
const RY = PY + PH / 2, SX = 1490;
s += `<path d="M ${PROW_END + 16} ${RY} L ${SX - 62} ${RY}" stroke="${TEAL}" stroke-width="6" marker-end="url(#teal)"/>`;
s += `<circle cx="${SX}" cy="${RY}" r="52" fill="${TEAL}"/>`;
s += t(SX, RY + 22, "Σ", { size: 62, weight: 700, fill: "#fff", anchor: "middle" });
s += t(SX, RY + 104, "in chunk order", { size: 32, weight: 600, fill: TEAL, anchor: "middle" });

const NX = 1590, NW = 270;
s += `<path d="M ${SX + 56} ${RY} L ${NX - 14} ${RY}" stroke="${TEAL}" stroke-width="6" marker-end="url(#teal)"/>`;
s += `<rect x="${NX}" y="${PY}" width="${NW}" height="${PH}" rx="14" fill="#fff" stroke="${INK}" stroke-width="3"/>`;
s += t(NX + NW / 2, PY + PH / 2 + 13, "centroids′", { size: 36, weight: 700, font: MONO, anchor: "middle" });

// Lazo a la siguiente iteración
const LX = NX + NW / 2;
s += `<path d="M ${LX} ${PY - 14} L ${LX} 217 L ${GX + GW + 22} 217" fill="none" stroke="${INK}" stroke-width="4" marker-end="url(#ink)"/>`;
s += t(LX + 22, 520, "next", { size: 32, fill: MUTED });
s += t(LX + 22, 560, "iteration", { size: 32, fill: MUTED });

// Resultados
const MX = 1980;
s += `<line x1="${MX - 40}" y1="180" x2="${MX - 40}" y2="${PY + PH + 60}" stroke="${LINE}" stroke-width="2"/>`;
const metric = (y, big, a, b, color = INK) => {
  s += t(MX, y, big, { size: 92, weight: 800, fill: color, ls: -1 });
  s += t(MX, y + 52, a, { size: 32, weight: 600 });
  s += t(MX, y + 92, b, { size: 30, fill: MUTED });
};
metric(290, "5.82×", "speedup, 8 workers", "2.83M trips · k=8");
metric(560, "1 result", "bit-identical", "for P = 1, 2, 4, 8, 16");
metric(830, "3 / 3", "mutants caught", "by Spin, all interleavings");

// Tesis
s += `<line x1="80" y1="1090" x2="${W - 80}" y2="1090" stroke="${LINE}" stroke-width="2"/>`;
s += `<text x="80" y="1180" font-family="${SANS}" font-size="46" font-weight="500" fill="${INK}">` +
  `Scheduling decides <tspan font-weight="800">who</tspan> computes a chunk; its index decides <tspan font-weight="800">where</tspan> it is summed.` +
  `</text>`;

const marker = (id, color) =>
  `<marker id="${id}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="4.2" markerHeight="4.2" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="${color}"/></marker>`;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
<defs>${marker("gray", FAINT)}${marker("teal", TEAL)}${marker("ink", INK)}</defs>
<rect width="${W}" height="${H}" fill="#ffffff"/>
<g transform="translate(0 16)">${s}</g>
</svg>`;

writeFileSync(process.argv[2] ?? "concurrente-card.svg", svg);
