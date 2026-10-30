# Our World in Multivariate Data -- setup
# Builds the analysis data from data/LifeGDP.RData (see R/get-LifeGDP.R):
#   OW  : all 198 countries, responses transformed and oriented so that higher = better
#   cc  : complete cases on the 9 responses used in the main analyses (n = 121)
#   Z   : standardized response matrix for cc
# Paths are relative to the post folder: open OWIMD.Rproj, or setwd() there.

## ---- setup
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(splines)
library(car)
library(heplots)
library(candisc)

load("data/LifeGDP.RData")

theme_set(theme_bw(base_size = 13))

## ---- transform
# empirical logit for percentages with a ceiling at 100%
elogit <- function(p, eps = 0.5) log((p + eps) / (100 - p + eps))

# 9 responses with good coverage; Literacy, TestScores, Stunting held back (missingness,
# and the 1950-vintage Literacy values)
resp <- c("ChildMort", "Stillbirth", "MatMort", "Doctors", "LifeExp",
          "SchoolYrs", "Electricity", "Water", "LifeSat")

# transformed & oriented: mortality-type outcomes are reversed (-log10), so + = better
OW <- LifeGDP |>
  transmute(country, code, region,
            GDP,
            logGDP      = log10(GDP),
            ChildMort   = -log10(ChildMort),
            Stillbirth  = -log10(Stillbirth),
            MatMort     = -log10(MatMort),
            Doctors     = log10(Doctors),
            LifeExp,
            SchoolYrs,
            Electricity = elogit(Electricity),
            Water       = elogit(Water),
            LifeSat)
rownames(OW) <- OW$country

# axis labels that say what was done to each response
resp_lab <- c(ChildMort = "-log ChildMort", Stillbirth = "-log Stillbirth",
              MatMort = "-log MatMort", Doctors = "log Doctors", LifeExp = "LifeExp",
              SchoolYrs = "SchoolYrs", Electricity = "logit Electricity",
              Water = "logit Water", LifeSat = "LifeSat")

## ---- complete-cases
cc <- OW[complete.cases(OW[, resp]), ]
# only one Oceania country is complete: merge with Asia
levels(cc$region)[levels(cc$region) %in% c("Asia", "Oceania")] <- "Asia/Oceania"
cc$region <- droplevels(cc$region)
Z <- scale(as.matrix(cc[, resp]))

# GDP tercile groups, used for covariance comparisons
cc$income <- cut(cc$logGDP, quantile(cc$logGDP, 0:3 / 3), include.lowest = TRUE,
                 labels = c("Low", "Middle", "High"))

table(cc$region)
