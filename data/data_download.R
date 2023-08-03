rm(list = ls())

## Download the data set from Harvard Dataverse
URL <- "https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/OOMI57/TFU3WG"
temp <- tempfile()
download.file(URL, temp)
dat <- read.csv(unz(temp, "01_Data/01_Survey/round_2_clean.csv"))
unlink(temp)

## Subset the data set to only include the relevant variables
dat <- dat %>% 
  dplyr::select(treat_assign, prob_shirt_st, prob_joke_st, prob_meeting_st, 
                prob_vh_st, prob_pungwe_st, prob_testify_st) %>% 
  subset(treat_assign == "C" | treat_assign == "TG")

## Export the data set to a csv file
write.csv(dat, file = "~/Documents/GitHub/methodsweb/guides/Young_2019.csv")
