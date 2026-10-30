# Our World in Multivariate Data -- 3. What GDP doesn't explain: residual correlations

if (!exists("cc")) source("R/00-setup.R")
if (!exists("mod2")) mod2 <- lm(Z ~ ns(logGDP, 3), data = cc)

## ---- resid-cor
R_raw  <- cor(Z)
res    <- resid(mod2)
R_part <- cor(res)

# raw correlations with log GDP: the "common factor"
round(cor(Z, cc$logGDP)[, 1], 2)

## ---- fig-corrplot
op <- par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))
ord <- corrplot::corrMatOrder(R_part, order = "AOE")
corrplot::corrplot(R_raw[ord, ord], method = "ellipse", type = "lower", diag = FALSE,
                   tl.col = "black", tl.srt = 45, addCoef.col = "black",
                   number.cex = 0.6, title = "Raw", mar = c(0, 0, 2, 0))
corrplot::corrplot(R_part[ord, ord], method = "ellipse", type = "lower", diag = FALSE,
                   tl.col = "black", tl.srt = 45, addCoef.col = "black",
                   number.cex = 0.6, title = "Controlling for GDP", mar = c(0, 0, 2, 0))
par(op)

## ---- fig-resid-spm
# residual scatterplot matrix with 68% data ellipses
scatterplotMatrix(res[, c("ChildMort", "MatMort", "Water", "LifeExp", "LifeSat")],
                  smooth = FALSE, regLine = FALSE,
                  ellipse = list(levels = 0.68, fill.alpha = 0.1),
                  diagonal = list(method = "density"),
                  col = "navy", pch = 16, cex = 0.6)
