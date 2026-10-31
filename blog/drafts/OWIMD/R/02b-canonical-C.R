# Our World in Multivariate Data -- 2b. Canonical plot of region differences, version C
# (see notes/canonical-analysis.md): the axes come from modR's own H and E, and the plotted
# points are the GDP-adjusted responses projected on them.

if (!exists("cc")) source("R/00-setup.R")

## ---- canonical-C
modR <- lm(Z ~ ns(logGDP, 3) + region, data = cc)

# GDP-adjusted responses: partial residuals from modR, the responses minus the fitted GDP part
X <- model.matrix(modR)
gdp <- grep("ns(logGDP", colnames(X), fixed = TRUE)
Z_adj <- scale(Z - X[, gdp] %*% coef(modR)[gdp, ], scale = FALSE)

# canonical axes for region from modR. Its scores, means and structure use the raw Z, which
# still contains GDP, so replace them using Z_adj
can_region <- candisc(modR, term = "region")
scores <- Z_adj %*% can_region$coeffs.raw
can_region$scores <- data.frame(region = cc$region, scores)
can_region$means <- aggregate(scores, list(region = cc$region), mean)
rownames(can_region$means) <- can_region$means$region
can_region$means <- can_region$means[, -1]
can_region$structure <- cor(Z_adj, scores)

can_region
round(can_region$means, 2)
round(can_region$structure, 2)

## ---- fig-candisc
# plot() can't make the region labels bold, so blank them (rownames must differ) and add them after
region_cols <- scales::hue_pal()(nlevels(cc$region))
can_means <- can_region$means
rownames(can_region$means) <- strrep(" ", seq_len(nlevels(cc$region)))
plot(can_region, var.lwd = 2, var.col = "black", ellipse = TRUE, rev.axes = c(TRUE, FALSE),
     scale = 5.5, col = region_cols, var.pos = c(4, 3, 1, 4, 3, 1, 4, 4, 3))
text(-can_means$Can1, can_means$Can2, labels = rownames(can_means), col = region_cols,
     font = 2, pos = c(1, 2, 4, 3, 1))

## ---- checks
# correlation of the scores with log GDP: overall, and pooled within regions
within <- function(x) x - ave(x, cc$region)
round(rbind(overall = cor(scores[, 1:4], cc$logGDP)[, 1],
            within = cor(apply(scores[, 1:4], 2, within), within(cc$logGDP))[, 1]), 3)

# countries at each end of the two axes
ends <- function(v) {
  o <- rownames(scores)[order(scores[, v])]
  list(low = head(o, 8), high = rev(tail(o, 8)))
}
ends("Can1")
ends("Can2")

# the first two dimensions are nearly tied, so only the plane is well determined.
# Can1 + Can2 and Can1 - Can2, rotated by 45 degrees, as an alternative to the two axes
rot <- scores[, 1:2] %*% matrix(c(1, 1, 1, -1), 2) / sqrt(2)
colnames(rot) <- c("Rot1", "Rot2")
round(aggregate(rot, list(region = cc$region), mean)[, -1], 2) |>
  `rownames<-`(levels(cc$region))
round(cor(Z_adj, rot), 2)
