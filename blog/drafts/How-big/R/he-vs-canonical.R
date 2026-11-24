# Diagram: an HE plot beside its canonical version, for Pottery (section 7).
# Draws figures/he-vs-canonical.png. Run from the post folder:
#   Rscript R/he-vs-canonical.R
# Left: data space, for the two oxides that Can1 mainly contrasts (Al against Fe).
#   E is a tilted ellipse in the units of the data.
# Right: canonical space. E becomes a circle and H lies along the axes: the
#   picture of section 5 (four-rulers.png), now with real data. The arrows are
#   the correlations of the oxides with the canonical dimensions; Fe and Mg
#   nearly coincide, so they share a label.
# Both use the default significance (evidence) scaling of H.
# Site means are labelled by hand, because two pairs of them nearly overlap.

library(heplots)
library(candisc)

data(Pottery, package = "carData")
pottery.mlm <- lm(cbind(Al, Fe, Mg, Ca, Na) ~ Site, data = Pottery)
pottery.can <- candisc(pottery.mlm)

site <- c(Llanedyrn = "Llanedyrn", Caldicot = "Caldicot",
          IsleThorns = "Isle Thorns", AshleyRails = "Ashley Rails")
means_data <- aggregate(cbind(Al, Fe) ~ Site, data = Pottery, FUN = mean)
means_can  <- pottery.can$means[, 1:2]

mark <- function(x, y, names, pos) {
  points(x, y, pch = 16, cex = 1.1)
  text(x, y, site[names], pos = pos[names], cex = 1, offset = 0.45)
}

ragg::agg_png("figures/he-vs-canonical.png", width = 10, height = 5, units = "in", res = 200)
op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.5, 1))

heplot(pottery.mlm, variables = c("Al", "Fe"), fill = TRUE, fill.alpha = 0.1,
       factor.means = FALSE, main = "Data space: Al and Fe", cex.lab = 1.2)
mark(means_data$Al, means_data$Fe, as.character(means_data$Site),
     pos = c(Llanedyrn = 4, Caldicot = 2, IsleThorns = 3, AshleyRails = 1))

# what heplot.candisc() does, but with factor.means = FALSE
scores  <- pottery.can$scores
can.mod <- lm(cbind(Can1, Can2, Can3) ~ Site, data = scores)
pct <- round(pottery.can$pct, 1)
heplot(can.mod, fill = TRUE, fill.alpha = 0.1, factor.means = FALSE, asp = 1,
       label.pos = c(1, 3), xlim = c(-17, 19),
       xlab = sprintf("Can1 (%s%%)", pct[1]), ylab = sprintf("Can2 (%s%%)", pct[2]),
       main = "Canonical space", cex.lab = 1.2)
abline(h = 0, v = 0, col = "gray")
st <- pottery.can$structure[, 1:2]
cs <- 13 * st                                        # vecscale() overshoots here
rownames(cs) <- c("Al", "Fe, Mg", "", "Ca", "Na")   # Fe and Mg nearly coincide
vectors(cs, col = "blue", labels = rownames(cs), lwd = 2, xpd = TRUE)
mark(means_can[, 1], means_can[, 2], rownames(means_can),
     pos = c(Llanedyrn = 3, Caldicot = 1, IsleThorns = 3, AshleyRails = 1))

par(op)
invisible(dev.off())
