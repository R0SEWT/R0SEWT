<!-- Badges en un bloque alineado a la derecha, bajo el nombre. Antes flotaban
     con align="right" y en móvil caían en escalera (cada float busca su hueco);
     como texto en línea dentro de un <div align="right"> bajan de fila juntos
     y en orden. El contador es de komarev: cambiar de servicio o de username
     reinicia la cuenta. Cada carga suma una visita: al previsualizar, simularlo. -->
<h1>Rody Vilchez
  <div align="right">
    <a href="https://rosewt.dev"><img src="https://img.shields.io/badge/rosewt.dev-2C3E50?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Website: rosewt.dev" /></a>
    <a href="https://www.linkedin.com/in/r0sewt/"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
    <img src="https://komarev.com/ghpvc/?username=r0sewt&style=for-the-badge" alt="Profile views" />
  </div>
</h1>

**Applied ML Engineer · AI Systems & Evaluation**

Agents in production at work, ML research on biased data outside it.
Both come down to the same question: how do you know it works?

At **CIP · CGIAR**, I build a hub-and-spoke multi-agent system for IT
support and the LLM-as-judge layer that evaluates it: regression tests
between versions, response quality, and agent behavior.

---

## Selected engineering & research

<table>
<tr>
<td width="50%" valign="top">

<h3 id="inwatch">InWatch</h3>
<p><sub><b>Geospatial research</b> · Interactive experiments</sub></p>

<a href="https://github.com/R0SEWT/InWatch">
  <img src="assets/inwatch.webp" width="100%" alt="Hourly pattern of reported street robberies around Estadio Monumental, averaged across 71 match days with spectators in 2019–2023." />
</a>

<p>A research workbench for crime-risk analysis under reporting bias.
Separates precomputed results from interactive views, with versioned
data contracts and code provenance. Spatial units are an explicit
experimental choice.</p>

<p><sub><b>Preview:</b> Estadio Monumental, averaged across 71 match days
with spectators in 2019–2023; patterns in reported street robberies.</sub></p>

<p>
<a href="https://github.com/R0SEWT/InWatch">Code &amp; experiments</a> ·
<a href="https://github.com/R0SEWT/InWatch/blob/main/registry/canonical_numbers.json">Results &amp; provenance</a> ·
<a href="https://github.com/R0SEWT/InWatch/blob/main/design/contrato-unidades.md">Spatial units &amp; assumptions</a>
</p>

</td>
<td width="50%" valign="top">

<h3 id="project-kit">project-kit</h3>
<p><sub><b>Developer tooling</b> · Agent-assisted workflows</sub></p>

<a href="https://github.com/R0SEWT/project-kit">
  <img src="assets/project-kit.gif" width="100%" alt="One scaffold command lays down the project and its tests pass immediately." />
</a>

<p>A Claude Code plugin that scaffolds a project with CI, a smoke test,
uv, issue tracking, and CLAUDE.md/AGENTS.md instructions for coding
agents. Non-destructive by default: it skips files that already exist.</p>

<p>
<a href="https://github.com/R0SEWT/project-kit">Code &amp; setup</a> ·
<a href="https://github.com/R0SEWT/project-kit/blob/main/catalog/setup-options.md">Tooling research log</a>
</p>

</td>
</tr>
</table>

<!--
  Segunda fila = tabla aparte, a propósito, y ahora plegada.
  GitHub pinta tr:nth-child(2n) con fondo gris y no acepta atributos style,
  así que una tabla de 2x2 saldría con la fila de abajo tintada.
  Con una tabla por fila, cada <tr> es nth-child(1) y las cuatro cards
  quedan del mismo color.
-->

<details>
<summary><b>More projects</b> · GENO-MAP, concurrente</summary>
<br />

<table>
<tr>
<td width="50%" valign="top">

<h3 id="geno-map">GENO-MAP</h3>
<p><sub><b>Scientific computing</b> · Research poster presented at SALA 2026</sub></p>

<a href="https://github.com/R0SEWT/GENO-MAP_Correspondence-Free-Diagnostics-for-Sweet-Potato-Diversity-Maps">
  <img src="assets/geno-map.png" width="100%" alt="The research question: are PCA-UMAP-kNN diversity maps structurally robust when the two genotyping panels share no identifiers?" />
</a>

<p>Validation of genetic diversity maps across panels with no shared
sample identifiers. Uses graph structure and robustness experiments to
assess sensitivity to preprocessing when direct alignment is unavailable.</p>

<p>
<a href="https://github.com/R0SEWT/GENO-MAP_Correspondence-Free-Diagnostics-for-Sweet-Potato-Diversity-Maps">Code &amp; experiments</a> ·
<a href="https://github.com/R0SEWT/GENO-MAP_Correspondence-Free-Diagnostics-for-Sweet-Potato-Diversity-Maps/blob/main/docs/poster/poster_a1_v2.pdf">Poster</a> ·
<a href="https://github.com/R0SEWT/GENO-MAP_Correspondence-Free-Diagnostics-for-Sweet-Potato-Diversity-Maps/blob/main/docs/explainer-es.md">Explainer</a>
</p>

</td>
<td width="50%" valign="top">

<h3 id="concurrente">concurrente</h3>
<p><sub><b>Concurrent systems</b> · Go worker pool, model-checked with Spin</sub></p>

<a href="https://github.com/R0SEWT/concurrente">
  <img src="assets/concurrente.png" width="100%" alt="Archify data-flow diagram of one Lloyd iteration: a channel dispatches chunks to persistent goroutines, each writes a private partial, a WaitGroup barrier releases an ordered reduce, and Spin verifies the synchronization." />
</a>

<p>Lloyd's K-means over 2.8M NYC taxi trips, sequential and with a
persistent worker pool. Partials are reduced in chunk order, so the result
is bit-identical for any worker count. Spin checks the synchronization over
every interleaving; benchmarks run on four machines, from a server to a phone.</p>

<p>
<a href="https://github.com/R0SEWT/concurrente">Code &amp; benchmarks</a> ·
<a href="https://github.com/R0SEWT/concurrente/blob/main/tp/spin/README.md">Spin model</a> ·
<a href="https://github.com/R0SEWT/concurrente/blob/main/tp/docs/analisis-pc2.md">Speedup analysis</a>
</p>

</td>
</tr>
</table>

</details>

---

<details>
<summary><b>View tools</b></summary>
<br />

**AI systems & evaluation**<br />
`LiteLLM` `OpenAI` `Anthropic` `Gemini` `LangGraph` `Claude Code` `MCP`

**Data & ML**<br />
`Python` `SQL` `Polars` `DuckDB` `PyTorch` `scikit-learn` `LightGBM` `SHAP`

**Geospatial & visualization**<br />
`GeoPandas` `H3` `pydeck` `Matplotlib` `Power BI`

**Engineering**<br />
`uv` `pytest` `Ruff` `GitHub Actions` `Docker` `FastAPI` `Azure`

</details>

---

## GitHub activity

<!-- align="top" en ambas: la card de lenguajes es más baja y sin esto queda
     flotando al medio de la de stats.
     <picture>: tema algolia en modo oscuro, default en claro (el fondo azul fijo
     chocaba con la página blanca). Ancho en px, no en %: en escritorio caben
     lado a lado (450 + 300) y en móvil bajan una por fila a ancho completo, en
     vez de encogerse juntas hasta no leerse. En srcset las comas separan
     candidatos, así que el hide= va con %2C. -->
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github-stats-iota-ten.vercel.app/api?username=r0sewt&theme=algolia&hide_border=true&include_all_commits=true&count_private=true" />
    <img align="top" src="https://github-stats-iota-ten.vercel.app/api?username=r0sewt&theme=default&hide_border=true&include_all_commits=true&count_private=true" alt="GitHub stats for r0sewt" width="450" />
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github-stats-iota-ten.vercel.app/api/top-langs/?username=r0sewt&theme=algolia&hide_border=true&layout=compact&count_private=true&hide=html%2Cjupyter%20notebook%2Cc%2Ccss%2Cc%2B%2B" />
    <img align="top" src="https://github-stats-iota-ten.vercel.app/api/top-langs/?username=r0sewt&theme=default&hide_border=true&layout=compact&count_private=true&hide=html%2Cjupyter%20notebook%2Cc%2Ccss%2Cc%2B%2B" alt="Most used languages for r0sewt" width="300" />
  </picture>
</p>
