# Restaurant density — Southern France

R script that builds a commune-level choropleth of restaurant density in southern France (**Occitanie**, **Provence–Alpes–Côte d’Azur**, and **Corsica**) using **`sf`** and **`ggplot2`**.

## Overview

The workflow downloads open data locally, aggregates point-like equipment counts to the commune (municipality) level, joins them to commune boundaries in **Lambert‑93 (EPSG:2154)**, then maps **establishments per km²** (`sqrt`‑scaled colours for readability).

## Data sources

| Asset | Role | Source |
|--------|------|--------|
| CSV | INSEE‑style facility counts (`typequ` **A504** ≈ restaurants, 2016 vintage in this extract) | [holtzy/R-graph-gallery — `data_on_french_states.csv`](https://github.com/holtzy/R-graph-gallery/tree/master/DATA) |
| GeoJSON | Metropolitan + overseas commune geometries (`code`, `nom`) | [gregoiredavid/france-geojson — `communes.geojson`](https://github.com/gregoiredavid/france-geojson) |

Commune identifiers are aligned via the INSEE code derived from **IRIS-style** cells in the CSV (`dciris`, prefix before `_`).

## Requirements

- [**R**](https://www.r-project.org/) ≥ 4.0 (recommended)
- R packages **`sf`**, **`ggplot2`**, **`dplyr`** (install system dependencies for `sf`, e.g. GDAL/PROJ, as prompted by [`sf` installation docs](https://r-spatial.github.io/sf/))

```r
install.packages(c("sf", "ggplot2", "dplyr"))
```

## Usage

From the repository root:

```bash
Rscript mappa.R
```

The script writes downloaded files under **`data/`**:

- `data/data_on_french_states.csv`
- `data/communes.geojson`

It then renders a static map via **`ggplot2`** (`geom_sf`). To save instead of relying on interactive plotting, pipe the ggplot object to **`ggsave()`** from your session or extend the script.

## Repository layout

- **`mappa.R`** — download, join, density calculation, choropleth
- **`esempio.md`** — short glossary on thematic maps (`sf` / `ggplot2`)

## Disclaimer

Facility definitions and vintages come from upstream datasets; verify against current INSEE documentation if you reuse this for publication or reporting.
