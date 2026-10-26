# Tests for the software catalog behind software.qmd.
#
# The page promises a reader three things: every package listed sits under a
# topic the guides cover, the reader can install it with the line shown, and
# each mark (EGAP author, used in a guide, used in Learning Days materials)
# is true. These tests check those promises against the catalog file and
# the guide sources.
#
# Run from the repository root:
#   Rscript software/test_catalog.R
# Tests that need the network (CRAN's package list) are skipped when it is
# unreachable.

suppressPackageStartupMessages({
  library(testthat)
  library(readr)
  library(dplyr)
  library(stringr)
})
source("software/catalog_functions.R")

catalog <- read_catalog("software/catalog.csv")
topics <- read_csv("software/topics.csv", show_col_types = FALSE)

test_that("every package sits under at least one known topic, and every topic has a package", {
  catalog_topics <- unlist(str_split(catalog$topics, ";\\s*"))
  expect_true(all(catalog_topics %in% topics$slug),
              info = paste(setdiff(catalog_topics, topics$slug), collapse = ", "))
  expect_true(all(nzchar(catalog$topics)))
  expect_true(all(topics$slug %in% catalog_topics),
              info = paste(setdiff(topics$slug, catalog_topics), collapse = ", "))
})

test_that("a package appears once per language", {
  dups <- catalog |> count(name, language) |> filter(n > 1)
  expect_equal(nrow(dups), 0, info = paste(dups$name, collapse = ", "))
})

test_that("each row says where to install from and has what the page shows", {
  expect_true(all(catalog$install_from %in% c("CRAN", "SSC", "PyPI", "GitHub", "net")))
  ## GitHub rows name owner/repo, or owner/repo/subdir when the package sits
  ## in a subdirectory; Stata rows installed with -net install- need a URL.
  gh <- catalog |> filter(install_from == "GitHub")
  expect_true(all(str_detect(gh$github, "^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)?$")),
              info = paste(gh$name, collapse = ", "))
  net <- catalog |> filter(install_from == "net")
  expect_true(all(str_detect(net$net_from, "^https://")))
  expect_false(any(is.na(install_line(catalog$install_from, catalog$language,
                                      catalog$name, catalog$github, catalog$net_from))))
  for (col in c("sentence", "title", "url")) {
    empty <- catalog$name[is.na(catalog[[col]]) | !nzchar(catalog[[col]])]
    expect_length(empty, 0)
  }
})

## The page lets a reader sort a table by release date. Its script sorts the
## dates as text, and text order equals date order only when every date is
## written YYYY-MM-DD. refresh.R copies the dates from three archives, which
## write them three different ways.
test_that("release dates are YYYY-MM-DD or blank, so sorting them as text sorts by date", {
  dated <- catalog$last_release[!is.na(catalog$last_release)]
  expect_true(all(str_detect(dated, "^\\d{4}-\\d{2}-\\d{2}$")),
              info = paste(dated[!str_detect(dated, "^\\d{4}-\\d{2}-\\d{2}$")], collapse = ", "))
  expect_false(any(is.na(as.Date(dated, format = "%Y-%m-%d"))))
})

test_that("the install line is the command a reader would type", {
  expect_equal(install_line("CRAN", "R", "RItools", NA), 'install.packages("RItools")')
  expect_equal(install_line("SSC", "Stata", "ritest", NA), "ssc install ritest")
  expect_equal(install_line("PyPI", "Python", "rdrobust", NA), "pip install rdrobust")
  expect_equal(install_line("GitHub", "R", "riposte", "bowers-illinois-edu/riposte"),
               'remotes::install_github("bowers-illinois-edu/riposte")')
  expect_equal(install_line("net", "Stata", "rdlocrand", NA, "https://example.org/stata"),
               'net install rdlocrand, from("https://example.org/stata")')
})

test_that("a package marked as used in a guide is loaded by that guide's executed code", {
  marked <- catalog |> filter(!is.na(guides), nzchar(guides))
  expect_gt(nrow(marked), 0)
  for (i in seq_len(nrow(marked))) {
    for (g in str_split(marked$guides[i], ";\\s*")[[1]]) {
      f <- guide_file(g)
      expect_true(file.exists(f), info = g)
      expect_true(marked$name[i] %in% packages_in_guide(f),
                  info = paste(marked$name[i], "in", g))
    }
  }
})

test_that("code in comments or in chunks that do not run does not count as use", {
  txt <- c("```{r}", "library(randomizr)", "# library(RItools)", "```",
           "```{r, eval=FALSE}", "library(coin)", "```",
           "```{r}", "#| eval: false", "library(ri2)", "```",
           "Text mentioning library(estimatr) outside code.")
  expect_setequal(packages_in_code(txt), "randomizr")
})

test_that("the packages Jake named carry the right topic and marks", {
  ritools <- catalog |> filter(name == "RItools")
  expect_true(str_detect(ritools$topics, "balance"))
  expect_true(str_detect(ritools$egap_authors, "Jake Bowers"))
  expect_true(str_detect(ritools$guides, "cluster-randomization"))
  for (p in c("riposte", "CMRSS")) {
    row <- catalog |> filter(name == p)
    expect_equal(nrow(row), 1, info = p)
    expect_true(str_detect(row$topics, "randomization-inference"), info = p)
    expect_equal(row$install_from, "GitHub", info = p)
    expect_true(str_detect(row$egap_authors, "Jake Bowers"), info = p)
  }
  ## randomizr has an R package and a Stata port; check both.
  expect_true(all(str_detect(catalog$topics[catalog$name == "randomizr"], "random-assignment")))
})

test_that("Learning Days marks name a source", {
  ld <- catalog |> filter(!is.na(learning_days), nzchar(learning_days))
  expect_true(all(unlist(str_split(ld$learning_days, ";\\s*")) %in%
                    c("EGAP book", "Learning Days materials")))
  expect_true(all(c("DeclareDesign", "randomizr", "estimatr") %in% ld$name))
})

test_that("the catalog is plain ASCII", {
  txt <- read_lines("software/catalog.csv")
  bad <- which(str_detect(txt, "[^\\x20-\\x7E]"))
  expect_length(bad, 0)
})

test_that("every row marked CRAN is a current CRAN package", {
  db <- tryCatch(tools::CRAN_package_db(), error = function(e) NULL)
  skip_if(is.null(db), "CRAN unreachable")
  cran <- catalog |> filter(install_from == "CRAN")
  expect_true(all(cran$name %in% db$Package),
              info = paste(setdiff(cran$name, db$Package), collapse = ", "))
})
