# The software catalog

`software.qmd` builds the Software page of methods.egap.org from the files in
this folder.

- `catalog.csv` has one row per package and language.
- `topics.csv` lists the topics the page is arranged by, with the guides each
  topic serves.
- `catalog_functions.R` holds the functions the page, the refresh script, and
  the tests share.
- `refresh.R` updates the columns copied from elsewhere.
- `test_catalog.R` checks the catalog against the topics and the guides.

## Columns of catalog.csv

A person writes these columns:

| column | what it holds |
|---|---|
| name | the package name as its archive spells it (Stata names in lower case) |
| language | R, Stata, or Python |
| install_from | CRAN, SSC, PyPI, GitHub, or net (a Stata package installed with `net install`) |
| github | owner/repository for GitHub rows, or owner/repository/subdirectory when the package sits in a subdirectory |
| net_from | the URL that `net install` reads, for net rows |
| topics | one or more slugs from topics.csv, separated by semicolons |
| sentence | one sentence on what the package does for an evaluator |
| egap_authors | authors who are EGAP members |
| learning_days | "EGAP book" or "Learning Days materials" when those materials use the package |
| added | the date the row was added |

`refresh.R` fills these columns:

| column | where it comes from |
|---|---|
| title, authors, version, last_release | CRAN's package list, the SSC `.pkg` file, PyPI, or the package's DESCRIPTION file on GitHub |
| url | the package's CRAN, PyPI, or GitHub page; for SSC rows the RePEc page, which a person enters |
| guides | the English guides whose executed R code loads the package; code in comments and in chunks with `eval=FALSE` does not count |

## How the first list was made

The first 139 rows were assembled in October 2026. The candidates came from
the R packages the guides load, the Google Sheet behind the earlier Software
page (`_map/software_packages.rds`), and three CRAN Task Views
(ExperimentalDesign, CausalInference, ClinicalTrials), 774 packages in all.
Packages that the Task Views list only for other fields (plant breeding,
industrial experiments, drug dose-finding, and similar) were removed, as were
general tools such as ggplot2. Claude agents then assigned each remaining
package a topic and marked it "include," "maybe," or "exclude" from its title
and description. The 138 marked "include" became the first list, and Jake
Bowers added riposte and CMRSS. The Stata row for cptest was merged with
the row for cvcrand, the SSC package that contains it. The sentences began as the
agents' reasons and have not all been checked.

To fill the `egap_authors` column, each package's authors were matched
against the member list on egap.org (October 2026) by surname and first
name, and every match was checked by hand. The `learning_days` column comes from a search of the
code in EGAP's *The Theory and Practice of Field Experiments* and its
Learning Days repositories for the packages they load.

## Refreshing and testing

Run from the repository root:

    Rscript software/refresh.R
    Rscript software/test_catalog.R

`refresh.R` downloads from CRAN, SSC, PyPI, and GitHub, so it runs by hand
rather than at every site build. It reports packages an archive no longer
lists and links that do not answer.
