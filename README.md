# EGAP Methods Website

This repository contains the source for the [EGAP Methods website](https://methods.egap.org), a collection of methods guides for impact evaluation, along with software tools and teaching materials.

## How to Contribute

We welcome contributions to improve existing guides, fix errors, add translations, or propose new content.

### Reporting Issues

- Use [GitHub Issues](https://github.com/egap/methodsweb/issues) to report errors, suggest improvements, or propose new guides
- Please check existing issues before creating a new one

### Making Changes

1. Fork the repository
2. Create a branch for your changes
3. Make your edits (see sections below for guidelines)
4. Test locally with `quarto preview`
5. Submit a pull request with a clear description of changes

When you make changes to one language version, note whether corresponding changes should be made to other language versions. If you can make the change in other languages, please do so.

## Local Development Setup

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (1.3 or later)
- [R](https://www.r-project.org/) (4.0 or later)
- RStudio (recommended but not required)

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/egap/methodsweb.git
cd methodsweb

# Restore R package dependencies (renv will activate automatically)
R -e "renv::restore()"

# Preview the site locally
quarto preview
```

The site will open in your browser with live reload enabled.

### Building the Full Site

```bash
# Render all pages (outputs to _site/)
quarto render

# Render a single guide
quarto render guides/research-questions/effect-types_en.qmd
```

## File Organization

### Directory Structure

```
guides/
├── analysis-procedures/    # Statistical analysis methods
├── assessing-designs/      # Power, external validity
├── causal-inference/       # Causal inference fundamentals
├── data-collection/        # Randomization, measurement, sampling
├── implementation/         # Field implementation guidance
├── interpretation/         # Interpreting results
├── planning/               # Pre-analysis plans, survey design
└── research-questions/     # Effect types, mechanisms
```

### File Naming Convention

All guide files use underscore + language code before `.qmd`:

- English: `guide-name_en.qmd`
- Spanish: `guide-name_es.qmd`
- French: `guide-name_fr.qmd`

Each guide also has associated files in the same directory:
- `guide-name.bib` — BibTeX references
- `guide-name.png` — Thumbnail image for listings

## Writing Guides

### Guide Template

Each guide should include YAML frontmatter:

```yaml
---
title: "10 Things to Know About [Topic]"
author:
  - name: "Author Name"
    url: https://author-website.com/
image: guide-name.png
bibliography: guide-name.bib
abstract: |
  A brief summary of what this guide covers and who it is for.
---
```

For translated guides, also include `sidebar:` to enable the language switcher:

```yaml
sidebar: guide-id  # Must match the id in _quarto.yml
```

### Style Guidelines

<!-- TODO: Add specific writing style guidelines for EGAP methods guides -->

- Guides follow a "10 Things to Know" format where appropriate
- Use clear, accessible language suitable for researchers and practitioners
- Include concrete examples and, where helpful, R code demonstrations
- Use numbered sections (`#`, `##`) for the main points
- Cite sources using BibTeX references

### Code Chunks

R code chunks should generally use:

```
{r}
#| echo: true
#| message: false
# Your code here
```

Code is folded by default (readers click to expand). Use `#| code-fold: false` for code that should always be visible.

### Cross-References

When linking to other guides on the site, use absolute paths:

```markdown
See [10 Things to Know About Causal Inference](https://methods.egap.org/guides/causal-inference/causal-inference_en.html)
```

## Translations

### Adding a New Translation

1. Copy the English version (`guide-name_en.qmd`) to a new file with the appropriate language suffix (e.g., `guide-name_es.qmd`)
2. Add `sidebar: guide-id` to the YAML frontmatter (use the same id as other translations of that guide)
3. Translate the content, keeping the same structure and section numbering
4. Update `_quarto.yml` to add the new language to the sidebar menu if needed

### Translation Guidelines

<!-- TODO: Add specific translation guidelines -->

- Maintain the same document structure as the English version
- Keep code chunks and their output unchanged (unless translating comments)
- Translate figure captions and alt text
- Keep bibliographic references unchanged

## Adding New Guides

<!-- TODO: Document the process for proposing and adding new guides -->

1. Open an issue to propose the new guide topic
2. Once approved, create the guide following the template above
3. Add a thumbnail image (PNG, approximately 800x600)
4. Add the guide to the appropriate sidebar in `_quarto.yml` if it needs a language switcher
5. Submit a pull request

## Deployment

The site is automatically built and deployed to GitHub Pages when changes are pushed to the `main` branch. The GitHub Actions workflow:

1. Sets up R and restores renv dependencies
2. Installs Quarto
3. Renders the site
4. Publishes to the `gh-pages` branch

## Questions?

- For technical issues with the site: Open a GitHub issue
- For questions about EGAP: Visit [egap.org](https://egap.org)

## License

<!-- TODO: Specify the license for this content -->
