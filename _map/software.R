library(googlesheets4)
library(tidyverse)

dt <- read_sheet("https://docs.google.com/spreadsheets/d/1pjzwDDR23XSIPFz63U0GqM-8sFVrfPE1RvC16JPc7zU/edit#gid=0")

write_rds(dt, file = "_map/software_packages.rds")
