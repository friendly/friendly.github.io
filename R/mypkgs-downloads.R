# downloads of my packages

library(dplyr)
library(extrafont)
library(cranlogs)

packages <- c("heplots",
    "candisc",
    "mvinfluence",
    "VisCollin",
    "genridge",
    "matlib",
    "HistData",
    "vcdExtra",
    "nestedLogit",
    "ggbiplot",
    "HistData",
    "Guerry",
    "WordPools",
    "statquotes"
             )

downloads <- cran_downloads(packages, from = "2021-01-01", to = Sys.Date())

