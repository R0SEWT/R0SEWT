<!-- Badges flotando a la derecha del nombre. align="right" apila de derecha a
     izquierda, así que van en orden inverso: el primero queda en el extremo.
     hspace sobrevive al sanitizador de GitHub; vspace no.
     El nombre va antes que los badges: al revés, en móvil los floats le comen
     el ancho y el nombre se parte letra por letra. El <br clear> hace que el h1
     crezca si los badges bajan de línea, en vez de invadir el párrafo siguiente. -->
<h1>Rody Vilchez
  <img align="right" hspace="2" src="https://komarev.com/ghpvc/?username=r0sewt&style=for-the-badge" alt="Profile views" />
  <a href="https://www.linkedin.com/in/r0sewt/"><img align="right" hspace="2" src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
  <a href="https://rosewt.dev"><img align="right" hspace="2" src="https://img.shields.io/badge/rosewt.dev-2C3E50?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Website: rosewt.dev" /></a>
  <br clear="right" />
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
<summary><b>More projects</b> · GENO-MAP, ChasquiFest Visual Audit</summary>
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

<h3 id="chasquifest-visual-audit">ChasquiFest Visual Audit</h3>
<p><sub><b>Data visualization</b> · Case study with synthetic data</sub></p>

<a href="https://r0sewt.github.io/chasquifest-auditoria-visual/">
  <img src="assets/chasquifest.png" width="100%" alt="Audit card: the headline claims a 57% drop; measured over comparable days the same data moves +11.5%." />
</a>

<p>Five visual audits of how coverage, denominators, and causal claims
affect interpretation. Each pairs the original claim with a corrected
comparison, backed by reproducible analysis and an interactive dashboard.</p>

<p>
<a href="https://github.com/R0SEWT/chasquifest-auditoria-visual">Code &amp; analysis</a> ·
<a href="https://r0sewt.github.io/chasquifest-auditoria-visual/">Dashboard</a> ·
<a href="https://github.com/R0SEWT/chasquifest-auditoria-visual/blob/main/informe/informe.pdf">Report</a>
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
     flotando al medio de la de stats. -->
<p align="center">
  <img align="top" src="https://github-stats-iota-ten.vercel.app/api?username=r0sewt&theme=algolia&hide_border=true&include_all_commits=true&count_private=true" alt="GitHub stats for r0sewt" width="55%" />
  <img align="top" src="https://github-stats-iota-ten.vercel.app/api/top-langs/?username=r0sewt&theme=algolia&hide_border=true&layout=compact&count_private=true&hide=html,jupyter%20notebook,c,css,c%2B%2B" alt="Most used languages for r0sewt" width="40%" />
</p>
