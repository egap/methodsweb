
library(tidyverse)

# remotes::install_github("r-lib/pkgapi")
# remotes::install_github("ropenscilabs/pkginspector")

# library(pkgapi)

software <- read_rds("_map/software_packages.rds") |> 
  filter(str_detect(tolower(Platform), "r")) |> 
  transmute(Name = Package, Description = Functionality, Authors = `Member(s)`, URL)

pkg_list <- software |> filter(str_detect(URL, "cran")) |> slice(1:5) |> pull(Name) 

# map(pkg_list, function(x) eval(parse(text = paste0("install.packages('", x, "')"))))

library_safely <- safely(library)

map(pkg_list, function(x) eval(parse(text = paste0("library_safely(", x, ")"))))

fns <- 
  map(paste0("package:", pkg_list), function(x) ls.str(x) |> as.list() |> unlist()) |> 
  set_names(pkg_list) |> 
  map(as_tibble) |> 
  map(rename, fn = value) |> 
  bind_rows(.id = "package")

packages <- 
  read_rds("_map/software_packages.rds") |> 
  distinct(Package, .keep_all = TRUE)

dt <- 
  fns |> 
  left_join(packages, by = c("package" = "Package"))

write_rds(dt, file = "software_functions.rds")

# DT::datatable(fns, colnames = c("Package", "Function name"), rownames = FALSE, options = list(search = list()))


# DT::datatable(
#   fns |> arrange(package) |> relocate(fn, package),
#   extensions = 'RowGroup',
#   options = list(rowGroup = list(dataSrc = 1)),
#   colnames = c("Package", "Function name"), 
#   rownames = FALSE, 
#   selection = 'none'
# )
