# Our World in Multivariate Data -- 6. Does the covariance structure change with development?

if (!exists("cc")) source("R/00-setup.R")
if (!exists("mod2")) mod2 <- lm(Z ~ ns(logGDP, 3), data = cc)

## ---- boxm
# Equality of residual covariance matrices across GDP terciles
res <- resid(mod2)
bm <- boxM(res, cc$income)
bm

## ---- fig-boxm
plot(bm, gplabel = "Income group")

## ---- fig-covellipses
covEllipses(res, cc$income, variables = c("ChildMort", "Doctors", "LifeExp", "Water"),
            fill = TRUE, fill.alpha = 0.1, pooled = TRUE,
            col = c("#d95f02", "#7570b3", "#1b9e77", "black"))

## ---- tbl-cov-summary
res_inc <- split(as.data.frame(res), cc$income)
data.frame(`Log determinant` = bm$logDet[names(res_inc)],
           `Total variance` = sapply(res_inc, \(d) sum(sapply(d, var))),
           `Average correlation` = sapply(res_inc, \(d) {
             r <- cor(d)
             mean(r[lower.tri(r)])
           }),
           `PC1 share` = sapply(res_inc, \(d) {
             e <- eigen(cov(d))$values
             e[1] / sum(e)
           }),
           check.names = FALSE) |>
  round(2) |>
  knitr::kable()

## ---- tbl-spread
sapply(res_inc, \(d) sapply(d, sd)) |>
  round(2) |>
  knitr::kable()
