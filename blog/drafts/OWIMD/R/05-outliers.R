# Our World in Multivariate Data -- 5. Unusual countries: multivariate outliers & influence

if (!exists("cc")) source("R/00-setup.R")
if (!exists("mod2")) mod2 <- lm(Z ~ ns(logGDP, 3), data = cc)

## ---- fig-cqplot
# chi-square QQ plot of residual squared Mahalanobis distances
rownames(mod2$residuals) <- cc$country
cqplot(mod2, id.n = 8, main = "Residuals from Z ~ ns(logGDP, 3)")

## ---- D2-table
res <- resid(mod2)
D2 <- mahalanobis(res, colMeans(res), cov(res))
head(data.frame(D2 = round(sort(D2, decreasing = TRUE), 1)), 10)

## ---- fig-influence
# mvinfluence supplies the influencePlot() method for "mlm" objects
library(mvinfluence)
influencePlot(mod2, id.n = 4, type = "LR")

## ---- tbl-sensitivity
# refit the GDP model without some countries, standardizing the responses again
refit <- function(drop = character()) {
  d <- cc[!(cc$country %in% drop), ]
  Zd <- scale(as.matrix(d[, resp]))
  m1 <- lm(Zd ~ logGDP, data = d)
  m2 <- lm(Zd ~ ns(logGDP, 3), data = d)
  R <- cor(resid(m2))
  p <- prcomp(resid(m2))
  c("Countries" = nrow(d),
    "Pillai, spline vs. linear" = anova(m1, m2)$Pillai[2],
    "Average partial correlation" = mean(R[lower.tri(R)]),
    "ChildMort, Stillbirth" = R["ChildMort", "Stillbirth"],
    "ChildMort, LifeExp" = R["ChildMort", "LifeExp"],
    "Electricity, Doctors" = R["Electricity", "Doctors"],
    "Largest LifeSat correlation" = max(R["LifeSat", setdiff(resp, "LifeSat")]),
    "PC1 share of variance" = p$sdev[1]^2 / sum(p$sdev^2))
}
cook <- influence(mod2)$CookD
sensitivity <- cbind("All" = refit(),
                     "Without Nigeria, Guyana" = refit(c("Nigeria", "Guyana")),
                     "Without top 10 D²" = refit(names(sort(D2, decreasing = TRUE))[1:10]),
                     "Without top 8 Cook's D" = refit(cc$country[order(cook, decreasing = TRUE)][1:8]))
knitr::kable(round(sensitivity, 2))
