# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the EGAP (Evidence in Governance and Politics) Methods website, a Quarto-based multilingual educational resource for impact evaluation methodology. The site provides methods guides, software tools catalog, and teaching materials for researchers and practitioners.

## Build and Development Commands

```bash
# Preview the site locally (starts dev server with live reload)
quarto preview

# Build the site (outputs to _site/)
quarto render

# Render a single guide
quarto render guides/research-questions/effect-types_en.qmd

# Restore R package dependencies (required before first build)
# R will auto-activate renv via .Rprofile
R -e "renv::restore()"
```

## Architecture

### Content Structure

- **guides/** — Methods guides organized by topic subdirectories:
  - `analysis-procedures/`, `assessing-designs/`, `causal-inference/`, `data-collection/`, `implementation/`, `interpretation/`, `planning/`, `research-questions/`
- **index.qmd** — Homepage with featured guides listing
- **guides.qmd** — Main guides index using Quarto listings
- **software.qmd** — Searchable R/Stata software catalog (uses DataTables)
- **teaching.qmd** — Links to Learning Days coursebook

### Multilingual File Naming Convention

Guides use underscore + language code before `.qmd`:
- English: `*_en.qmd` (e.g., `effect-types_en.qmd`)
- Spanish: `*_es.qmd` (e.g., `effect-types_es.qmd`)
- French: `*_fr.qmd` (e.g., `effect-types_fr.qmd`)

Language switching uses sidebar configuration in `_quarto.yml` with flag icons linking between translations.

### Guide YAML Frontmatter

Each guide includes:
- `title:` — Guide title
- `author:` — List with name/url pairs
- `image:` — Thumbnail image filename (stored alongside the .qmd)
- `bibliography:` — BibTeX file for references
- `sidebar:` — ID matching `_quarto.yml` sidebar for language switcher (translations only)
- `abstract:` — Summary shown at top of guide

### Configuration Files

- `_quarto.yml` — Site structure, navigation, sidebar definitions, HTML format options
- `_language.yml` — Custom labels (author, date display)
- `renv.lock` / `renv/` — R package versions for reproducibility
- `DESCRIPTION` — R package dependencies list

### Quarto Features in Use

- `freeze: auto` — Caches code execution results in `_freeze/`
- `cache: true` — R code chunk caching
- `code-fold: true` — Collapsible code blocks
- Listings for grid-based guide indexes
- Custom partials in `partials/` for title blocks and TOC

## Deployment

GitHub Actions (`.github/workflows/build-quarto.yml`) builds and publishes to GitHub Pages on push to `main`. The workflow:
1. Sets up R with renv
2. Installs system dependencies (libgit2, udunits2, gdal, geos, proj)
3. Runs `quarto render` and publishes to `gh-pages` branch
