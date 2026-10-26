# Functions shared by software.qmd, software/refresh.R, and
# software/test_catalog.R. They read the catalog, find which packages the
# guides load, build the install line a reader types, and copy package facts
# (title, authors, version, release date) from CRAN, SSC, PyPI, and GitHub.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(purrr)
})

read_catalog <- function(path = "software/catalog.csv") {
  read_csv(path, col_types = cols(.default = col_character()), na = "")
}

## The project keeps its text files in plain ASCII, so accented names that
## archives return ("Clement de Chaisemartin" with an accent) are folded.
write_catalog <- function(catalog, path = "software/catalog.csv") {
  catalog <- mutate(catalog, across(everything(),
                                    \(x) stringi::stri_trans_general(x, "Latin-ASCII")))
  write_csv(catalog, path, na = "")
}

## The command a reader types to install the package. Stata packages that
## are not on SSC install with -net install- from the URL in net_from.
install_line <- function(install_from, language, name, github = NA, net_from = NA) {
  case_when(
    install_from == "CRAN" ~ sprintf('install.packages("%s")', name),
    install_from == "SSC" ~ sprintf("ssc install %s", str_to_lower(name)),
    install_from == "PyPI" ~ sprintf("pip install %s", name),
    install_from == "GitHub" & language == "R" ~
      sprintf('remotes::install_github("%s")', github),
    install_from == "net" & language == "Stata" ~
      sprintf('net install %s, from("%s")', str_to_lower(name), net_from),
    TRUE ~ NA_character_
  )
}

## Which packages a guide's code loads. Only code that runs counts: lines in
## R chunks, minus comments and minus chunks whose options say eval=FALSE,
## because a reader who copies a commented line or an unevaluated chunk has
## not seen the package work in the guide.
packages_in_code <- function(lines) {
  in_chunk <- FALSE
  runs <- FALSE
  keep <- character(0)
  for (line in lines) {
    if (!in_chunk && str_detect(line, "^\\s*```+\\s*\\{r")) {
      in_chunk <- TRUE
      runs <- !str_detect(line, "eval\\s*=\\s*(FALSE|F)\\b")
      next
    }
    if (in_chunk && str_detect(line, "^\\s*```+\\s*$")) {
      in_chunk <- FALSE
      next
    }
    if (!in_chunk) next
    if (str_detect(line, "^\\s*#\\|\\s*eval:\\s*false")) {
      runs <- FALSE
      next
    }
    if (runs) keep <- c(keep, str_remove(line, "#.*$"))
  }
  code <- paste(keep, collapse = "\n")
  unique(c(
    str_match_all(code, "\\b(?:library|require)\\(\\s*[\"']?([A-Za-z][A-Za-z0-9.]*)")[[1]][, 2],
    str_match_all(code, "\\b([A-Za-z][A-Za-z0-9.]*):::?[A-Za-z_.]")[[1]][, 2]
  ))
}

packages_in_guide <- function(file) packages_in_code(read_lines(file))

## Guides are named by slug, the file name without "_en.qmd".
guide_file <- function(slug) {
  hits <- list.files("guides", pattern = paste0("^", slug, "_en\\.qmd$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) == 0) NA_character_ else hits[1]
}

## For every English guide, the packages its executed code loads; then, for
## each catalog row, the guides that load it. Only R rows can be loaded by
## the guides' R code.
guides_using <- function(catalog) {
  files <- list.files("guides", pattern = "_en\\.qmd$", recursive = TRUE,
                      full.names = TRUE)
  uses <- map(files, packages_in_guide) |>
    set_names(str_remove(basename(files), "_en\\.qmd$"))
  map2_chr(catalog$name, catalog$language, function(n, l) {
    if (l != "R") return(NA_character_)
    g <- names(uses)[map_lgl(uses, \(u) n %in% u)]
    if (length(g) == 0) NA_character_ else paste(sort(g), collapse = "; ")
  })
}

## ---- Copying package facts from the archives ----

## Author fields mix names with roles, ORCID links, and e-mail addresses;
## keep the names.
clean_authors <- function(x) {
  x |>
    str_replace_all("\\[[^\\]]*\\]", "") |>
    str_replace_all("\\([^)]*\\)", "") |>
    str_replace_all("<[^>]*>", "") |>
    str_split(",|\\band\\b|\\n") |>
    map_chr(\(a) paste(unique(str_squish(a[nzchar(str_squish(a))])), collapse = ", "))
}

cran_facts <- function(names, db = tools::CRAN_package_db()) {
  db <- db[!duplicated(db$Package), ]
  tibble(name = names) |>
    left_join(tibble(name = db$Package, title = str_squish(db$Title),
                     authors = clean_authors(db$Author), version = db$Version,
                     last_release = str_sub(db$Published, 1, 10)),
              by = "name") |>
    mutate(url = paste0("https://cran.r-project.org/package=", name))
}

## SSC keeps a plain-text .pkg file for each module, whose lines starting
## "d" hold the title, the authors, and the distribution date.
ssc_facts <- function(name) {
  n <- str_to_lower(name)
  url <- sprintf("http://fmwww.bc.edu/repec/bocode/%s/%s.pkg", str_sub(n, 1, 1), n)
  pkg <- tryCatch(read_lines(url), error = function(e) character(0))
  if (length(pkg) == 0) return(tibble(name = name, title = NA, authors = NA,
                                      version = NA, last_release = NA))
  title <- str_match(pkg[1], "^d '[^']*':\\s*(.*)$")[, 2]
  authors <- pkg[str_detect(pkg, "^d\\s+Authors?:")] |>
    str_remove("^d\\s+Authors?:\\s*") |> str_remove(",.*$") |> str_squish()
  date <- str_match(paste(pkg, collapse = "\n"), "Distribution-Date:\\s*(\\d{8})")[, 2]
  tibble(name = name,
         title = str_to_sentence(str_squish(title)),
         authors = paste(authors[nzchar(authors)], collapse = ", "),
         version = NA_character_,
         last_release = if (is.na(date)) NA_character_ else
           paste(str_sub(date, 1, 4), str_sub(date, 5, 6), str_sub(date, 7, 8), sep = "-"))
}

pypi_facts <- function(name) {
  j <- tryCatch(jsonlite::fromJSON(sprintf("https://pypi.org/pypi/%s/json", name)),
                error = function(e) NULL)
  if (is.null(j)) return(tibble(name = name, title = NA, authors = NA, version = NA,
                                last_release = NA, url = NA))
  files <- j$releases[[j$info$version]]
  tibble(name = name, title = j$info$summary, authors = j$info$author,
         version = j$info$version,
         last_release = if (length(files)) str_sub(files$upload_time[1], 1, 10) else NA_character_,
         url = sprintf("https://pypi.org/project/%s/", name))
}

## An R package on GitHub: read its DESCRIPTION. "owner/repo/subdir" means
## the package sits in a subdirectory of the repository.
github_facts <- function(name, github) {
  parts <- str_split(github, "/")[[1]]
  repo <- paste(parts[1:2], collapse = "/")
  sub <- if (length(parts) > 2) paste0(paste(parts[-(1:2)], collapse = "/"), "/") else ""
  raw <- sprintf("https://raw.githubusercontent.com/%s/HEAD/%sDESCRIPTION", repo, sub)
  d <- tryCatch(read.dcf(url(raw)), error = function(e) NULL)
  field <- function(f) if (!is.null(d) && f %in% colnames(d)) str_squish(d[1, f]) else NA_character_
  authors <- field("Author")
  if (is.na(authors) && !is.na(field("Authors@R"))) {
    people <- tryCatch(eval(parse(text = field("Authors@R"))), error = function(e) NULL)
    authors <- if (is.null(people)) NA_character_ else
      paste(format(people, include = c("given", "family")), collapse = ", ")
  }
  tibble(name = name, title = field("Title"), authors = clean_authors(authors),
         version = field("Version"), last_release = NA_character_,
         url = paste0("https://github.com/", repo))
}
