
library(purrr)
library(tidyverse)

rmds <- list.files(pattern = c('.Rmd', '.rmd'), recursive = TRUE)

rmds <- rmds[!str_detect(rmds, "_fr.Rmd") & !str_detect(rmds, "_esp.Rmd")]

rmd_df <- 
  rmds |> 
  set_names() |> 
  map(read_lines) |> 
  map(as_tibble) |> 
  bind_rows(.id = "filename") |> 
  filter(!(str_detect(value, "theme") & str_detect(value, "journal"))) |> 
  filter(!(str_detect(value, "includes:"))) |> 
  filter(!(str_detect(value, "after_body") & str_detect(value, "linking_script.html"))) |> 
  group_by(filename) |> 
  group_walk(~ write_lines(x = .x$value, file = paste0("test_", .x$filename)))
               
               # knitr::purl(text = .x$purl_text, output = paste0("_book/", .x$output_file_name, ".R")))


