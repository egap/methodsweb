# Refresh the columns of software/catalog.csv that are copied from elsewhere:
# the package's title, authors, version, and latest release date (from CRAN,
# SSC, PyPI, or GitHub), its page at the archive, and the guides whose code
# loads it. The columns a person writes (topics, sentence, egap_authors,
# learning_days) are left alone.
#
# Run by hand from the repository root, not at every site build, so that an
# outage at an archive cannot stop the site from building:
#   Rscript software/refresh.R
# It reports any package an archive no longer lists and any link that does
# not answer.

source("software/catalog_functions.R")

catalog <- read_catalog()
db <- tools::CRAN_package_db()

copied <- pmap(catalog, function(name, language, install_from, github, net_from, url, ...) {
  facts <- switch(install_from,
    CRAN = cran_facts(name, db),
    SSC = ssc_facts(name),
    PyPI = pypi_facts(name),
    GitHub = github_facts(name, github),
    net = tibble(name = name, title = NA, authors = NA, version = NA,
                 last_release = NA)
  )
  ## SSC and net rows keep the link a person chose (a RePEc or GitHub page),
  ## because the .pkg file is not a page a reader can use.
  if (!"url" %in% names(facts)) facts$url <- url
  facts
}) |> bind_rows()

## Keep the stored value wherever an archive gave nothing, so that a failed
## download does not blank a row.
for (col in c("title", "authors", "version", "last_release", "url")) {
  catalog[[col]] <- coalesce(na_if(copied[[col]], ""), catalog[[col]])
}
catalog$guides <- guides_using(catalog)

## Rows installed with -net install- are not read from an archive, so they
## have no record to miss.
missing <- catalog$name[is.na(copied$title) & catalog$install_from != "net"]
if (length(missing)) message("No archive record for: ", paste(missing, collapse = ", "))

status <- map_int(catalog$url, function(u) {
  r <- tryCatch(curlGetHeaders(u), error = function(e) NULL)
  if (is.null(r)) NA_integer_ else attr(r, "status")
})
bad <- catalog$name[is.na(status) | status >= 400]
if (length(bad)) message("Links that did not answer: ", paste(bad, collapse = ", "))

write_catalog(catalog)
message("Wrote ", nrow(catalog), " rows to software/catalog.csv")
