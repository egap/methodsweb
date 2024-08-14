rm(list = ls())

library(tidyverse)
library(sampling)

## Read the example data set
data(swissmunicipalities)
# Data description is available at https://search.r-project.org/CRAN/refmans/sampling/html/swissmunicipalities.html
df <- swissmunicipalities

## Simple random sampling
# Set seed for reproducibility
set.seed(1234567)

# Sample 100 Swiss municipalities out of 2896 through sample random sampling
df %>% 
  slice_sample(n = 100,        # sample size
               replace = FALSE # sampling without replacement
               )

## Stratified sampling
# Set seed for reproducibility
set.seed(1234567)

# Sort the data in ascending order by the stratification variable
df2 <- df[order(df$REG), ] # REG contains data on Swiss regions, ranging from 1 to 7

# Sample 100 Swiss municipalities out of 2896 through stratified sampling by region
stratified_sampling <- strata(
  df2,                                  # data frame sorted by region
  stratanames = c("REG"),               # stratification variable (region)
  size = c(20, 20, 20, 10, 10, 10, 10), # stratum sample sizes for each region
  method = "srswor"                     # sampling without replacement
  )
getdata(df, stratified_sampling)

## Cluster sampling
# Set seed for reproducibility
set.seed(1234567)

# Sample 3 Swiss regions out of 7 through cluster sampling
cluster_sampling <- cluster(
  df,                     # data frame
  clustername = c("REG"), # clustering variable (region)
  size = 3,               # sample size of region
  method = "srswor"       # sampling without replacement
  )
getdata(df, cluster_sampling)

## Multistage sampling (e.g., clustering by region --> clustering by canton)
# Set seed for reproducibility
set.seed(1234567)

# Sort the data in ascending order by the clustering variables
df3 <- df[order(df$REG, df$CT), ] # CT contains data on Swiss cantons, ranging from 1 to 26

# Sample Swiss municipalities through two-stage cluster sampling (by region then by canton)
two_cluster_sampling <- mstage(
  df3,                                # data frame sorted by region and canton
  stage = list("cluster", "cluster"), # sampling types at each stage
  varnames = list("REG", "CT"),       # clustering variables
  size = list(3,                      # sample 3 clusters at the first stage
              c(1, 1, 1)),            # sample 1 canton from each sampled cluster at the second stage
  method = list("srswor", "srswor")   # sampling without replacement
  )
getdata(df, two_cluster_sampling)[[2]]