# Our World in Multivariate Data -- 2. Thinking multivariately: the MLM and HE plots

if (!exists("cc")) source("R/00-setup.R")

## ---- mlm-shape
# Is the relation with log GDP linear, jointly over all responses?
mod1 <- lm(Z ~ logGDP, data = cc)
mod2 <- lm(Z ~ ns(logGDP, 3), data = cc)
anova(mod1, mod2)

## ---- tbl-rsq
rsq <- function(mod) sapply(summary(mod), \(s) s$r.squared)
tab_rsq <- data.frame(linear = rsq(mod1), spline = rsq(mod2), row.names = resp)
tab_rsq$diff <- tab_rsq$spline - tab_rsq$linear
knitr::kable(round(tab_rsq, 2))

## ---- mlm-region
# Does region matter, beyond GDP?  And is the GDP slope the same in all regions?
modR <- lm(Z ~ ns(logGDP, 3) + region, data = cc)
Anova(modR)

modRI <- lm(Z ~ ns(logGDP, 3) + region + logGDP:region, data = cc)
anova(modR, modRI)

## ---- fig-heplot
# GDP-adjusted responses: residuals from the model with GDP alone
res_gdp <- resid(lm(Z ~ ns(logGDP, 3), data = cc))
adj_means <- aggregate(res_gdp, list(region = cc$region), mean)

# HE plot for two responses; GDP H ellipse vs. region H ellipse, relative to E.
# Suppress the raw region means and add the GDP-adjusted ones.
vars <- c("LifeExp", "LifeSat")
heplot(modR, variables = vars, factor.means = FALSE,
       fill = TRUE, fill.alpha = 0.1, label.cex = 1.15,
       term.labels = c("GDP (spline)", "region"))
points(adj_means[, vars], pch = 16, cex = 1.2)
text(adj_means[, vars], labels = adj_means$region, pos = c(3, 1, 3, 3, 3), cex = 1.1)

## ---- fig-heplot-pairs
# region means are left out here: the default ones would be unadjusted for GDP
pairs(modR, variables = c("ChildMort", "Doctors", "LifeExp", "Water", "LifeSat"),
      factor.means = FALSE, fill = TRUE, fill.alpha = 0.1,
      term.labels = c("GDP", "region"))

## ---- fig-candisc
# Canonical view of region differences, after removing GDP:
# region model for the residuals from Z ~ ns(logGDP, 3)
modA <- lm(res_gdp ~ region, data = cc)
can_region <- candisc(modA, term = "region")
can_region
# reverse Can1 so that right = higher life satisfaction (the Americas), and
# reverse Can2 so that up = better on electricity, doctors, life expectancy
plot(can_region, var.lwd = 2, var.col = "black", ellipse = TRUE, rev.axes = c(TRUE, TRUE),
     scale = 4, col = scales::hue_pal()(nlevels(cc$region)))
