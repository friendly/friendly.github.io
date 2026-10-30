# Assemble the data behind OWID's "How is life at different levels of GDP per capita?"
# (Life-GDP.jpg), from the public OWID grapher CSV endpoints.
#
# The chart uses the "latest available data" for each indicator, so we take, for each
# country and indicator, the most recent non-missing year (and record that year).
# Only real countries are kept (ISO3 codes; OWID_* aggregates & regions dropped).
# Run from the post folder: raw downloads go to data-raw/, results to data/.

library(dplyr)
library(tidyr)
library(purrr)

raw_dir <- "data-raw"
dir.create(raw_dir, showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

# variable name -> OWID grapher slug
slugs <- c(
  GDP         = "gdp-per-capita-worldbank",          # GDP pc, PPP const. intl $ (World Bank)
  ChildMort   = "youth-mortality-rate",              # % dying before age 15
  Stillbirth  = "stillbirth-rate",                   # stillbirths per 100 births
  MatMort     = "maternal-mortality",                # maternal deaths per 100,000 live births
  Stunting    = "share-of-children-younger-than-5-who-suffer-from-stunting", # % under-5 stunted
  Doctors     = "physicians-per-1000-people",        # physicians per 1,000
  LifeExp     = "life-expectancy",                   # life expectancy at birth
  Literacy    = "cross-country-literacy-rates",      # % adults literate
  SchoolYrs   = "expected-years-of-schooling",       # expected years of schooling
  TestScores  = "average-harmonized-learning-outcome-scores", # harmonized test scores
  Electricity = "share-of-the-population-with-access-to-electricity", # % with access
  Water       = "proportion-using-safely-managed-drinking-water",     # % safely managed
  LifeSat     = "happiness-cantril-ladder"           # Cantril ladder, 0-10
)

fetch <- function(slug) {
  f <- file.path(raw_dir, paste0(slug, ".csv"))
  if (!file.exists(f)) {
    url <- paste0("https://ourworldindata.org/grapher/", slug,
                  ".csv?v=1&csvType=full&useColumnShortNames=true")
    download.file(url, f, quiet = TRUE, mode = "wb")
  }
  read.csv(f, check.names = FALSE)
}

# latest non-missing value per country; the value is the 4th column in every file
latest <- function(var, slug) {
  d <- fetch(slug)
  names(d)[4] <- "value"
  d |>
    filter(grepl("^[A-Z]{3}$", code), !is.na(value)) |>
    group_by(code) |>
    slice_max(year, n = 1, with_ties = FALSE) |>
    ungroup() |>
    transmute(country = entity, code, var = var, value, year)
}

long <- imap(slugs, \(slug, var) latest(var, slug)) |> list_rbind()

# region (OWID continent) from the GDP file
region <- fetch(slugs["GDP"]) |>
  filter(grepl("^[A-Z]{3}$", code), owid_region != "") |>
  distinct(code, region = owid_region)

LifeGDP <- long |>
  select(-year) |>
  pivot_wider(names_from = var, values_from = value) |>
  left_join(region, by = "code") |>
  relocate(region, .after = code) |>
  filter(!is.na(GDP)) |>
  mutate(region = factor(region)) |>
  arrange(country) |>
  as.data.frame()

# year of each observation, same shape -- useful to check how "latest" varies
LifeGDP_year <- long |>
  select(-value) |>
  pivot_wider(names_from = var, values_from = year) |>
  semi_join(LifeGDP, by = "code") |>
  arrange(country) |>
  as.data.frame()

write.csv(LifeGDP, "data/LifeGDP.csv", row.names = FALSE)
write.csv(LifeGDP_year, "data/LifeGDP-year.csv", row.names = FALSE)
save(LifeGDP, LifeGDP_year, file = "data/LifeGDP.RData")

# ---- quick summary ------------------------------------------------------------
str(LifeGDP)
cat("\nNon-missing per variable:\n"); print(colSums(!is.na(LifeGDP[, -(1:3)])))
resp <- setdiff(names(slugs), "GDP")
cat("\nComplete cases on all 12 responses:", sum(complete.cases(LifeGDP[, resp])), "\n")
cat("Complete cases without Literacy, TestScores, Stunting:",
    sum(complete.cases(LifeGDP[, setdiff(resp, c("Literacy", "TestScores", "Stunting"))])), "\n")
