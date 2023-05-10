rm(list = ls())

library(tidyverse)
library(estimatr)

## Read the data set
dat <- read.csv("~/Documents/GitHub/methodsweb/guides/Young_2019.csv")

## Estimate the effects of fear on propensity to dissent
# Treatment effect on propensity to wear an opposition party t-shirt
mod1 <- lm_robust(prob_shirt_st ~ treat_assign, data = dat)

# Treatment effect on propensity to share a funny joke about the president
mod2 <- lm_robust(prob_joke_st ~ treat_assign, data = dat)

# Treatment effect on propensity to go to an opposition rally
mod3 <- lm_robust(prob_meeting_st ~ treat_assign, data = dat)

# Treatment effect on propensity to go to a rally for the ruling party
mod4 <- lm_robust(prob_vh_st ~ treat_assign, data = dat)

# Treatment effect on propensity to tell a state security agent that she supports the opposition
mod5 <- lm_robust(prob_pungwe_st ~ treat_assign, data = dat)

# Treatment effect on propensity to testify in court against a perpetrator of violence
mod6 <- lm_robust(prob_testify_st ~ treat_assign, data = dat)

# Summarize the estimates
summary <- bind_rows(
  list(tidy(mod1), tidy(mod2), tidy(mod3), tidy(mod4), tidy(mod5), tidy(mod6))) %>% 
  filter(term == "treat_assignTG")

## Create a summary table to compare p-values
compare_p <- summary %>% 
  transmute(
    outcome,
    estimate,
    std.error,
    unadjusted_p = p.value,
    Bonferroni = p.adjust(p = p.value, method = "bonferroni"),
    Holm = p.adjust(p = p.value, method = "holm"),
    BH = p.adjust(p = p.value, method = "BH")
  )
print(compare_p, digits = 2)
