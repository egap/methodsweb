rm(list = ls())

library(tidyverse)
library(estimatr)

## Read the data set
dat <- read.csv("~/Downloads/EGAP_hackathon/Young_2019.csv")

## Estimate the effects of fear on propensity to dissent
# Treatment effect on propensity to wear an opposition party t-shirt
mod1 <- tidy(lm_robust(prob_shirt_st ~ treat_assign, data = dat))[2,]

# Treatment effect on propensity to share a funny joke about the president
mod2 <- tidy(lm_robust(prob_joke_st ~ treat_assign, data = dat))[2,]

# Treatment effect on propensity to go to an opposition rally
mod3 <- tidy(lm_robust(prob_meeting_st ~ treat_assign, data = dat))[2,]

# Treatment effect on propensity to go to a rally for the ruling party
mod4 <- tidy(lm_robust(prob_vh_st ~ treat_assign, data = dat))[2,]

# Treatment effect on propensity to tell a state security agent that she supports the opposition
mod5 <- tidy(lm_robust(prob_pungwe_st ~ treat_assign, data = dat))[2,]

# Treatment effect on propensity to testify in court against a perpetrator of violence
mod6 <- tidy(lm_robust(prob_testify_st ~ treat_assign, data = dat))[2,]

# Summarize the estimates
summary <- rbind(mod1, mod2, mod3, mod4, mod5, mod6)

## Create a summary table to compare p-values
compare_p <- data.frame(
  outcome = summary$outcome,
  ATE = summary$estimate,
  SE = summary$std.error,
  unadjusted_p = summary$p.value,
  Bonferroni = p.adjust(p = summary$p.value, method = "bonferroni"),
  Holm = p.adjust(p = summary$p.value, method = "holm"),
  BH = p.adjust(p = summary$p.value, method = "BH")
)
print(compare_p, digits = 2)
