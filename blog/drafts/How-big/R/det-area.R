# Diagram: the determinant as area (section 2a, "How big is a covariance matrix?").
# Draws figures/det-area.png. Run from the post folder:
#   Rscript R/det-area.R
# Left: det(A) is the area of the parallelogram spanned by the rows of A
#   (after step 8 of the matlib vignette "Properties of determinants").
# Right: data ellipses x' S^-1 x = 1 for two variables with unit variances and
#   correlation r = 0, 0.75, 0.95. All have trace 2; det(S) = 1 - r^2 shrinks, and the
#   area of each ellipse is pi * sqrt(det S). For r = 0.75 the semi-axes are drawn:
#   their lengths are the square roots of the eigenvalues of S, so
#   det(S) = (product of the semi-axes)^2 and tr(S) = sum of their squares.
# Base graphics with matlib::vectors(), as in the matlib vignettes.

library(matlib)

A <- matrix(c(3, 1,
              2, 4), nrow = 2, byrow = TRUE)
rs  <- c(0, 0.75, 0.95)
col <- c("grey45", "#E45756", "#4C78A8")
th  <- seq(0, 2 * pi, length.out = 361)
ell <- function(S) t(t(chol(S)) %*% rbind(cos(th), sin(th)))   # x' S^-1 x = 1

ragg::agg_png("figures/det-area.png", width = 10, height = 5, units = "in", res = 200)
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 1), cex = 1.1)

# ---- left: parallelogram ----
plot(c(0, 5.5), c(0, 5.5), type = "n", asp = 1, xlab = expression(X[1]),
     ylab = expression(X[2]), main = "det(A) is an area", las = 1)
sum <- A[1, ] + A[2, ]
polygon(rbind(c(0, 0), A[1, ], sum, A[2, ]), col = adjustcolor("#F58518", 0.25),
        border = NA)
vectors(sum, origin = A[1, ], col = "grey60", lwd = 1.5)
vectors(sum, origin = A[2, ], col = "grey60", lwd = 1.5)
vectors(A, labels = c(expression(bold(a)[1]), expression(bold(a)[2])), pos.lab = c(4, 2),
        lwd = 2.5, cex.lab = 1.3)
text(sum[1] / 2, sum[2] / 2, sprintf("area = %g", det(A)), font = 2, cex = 1.1)
text(0, 5.4, "A = [3 1; 2 4]", pos = 4, family = "mono", cex = 0.95)

# ---- right: data ellipses ----
plot(c(-1.6, 1.6), c(-2.3, 1.4), type = "n", asp = 1, xlab = expression(X[1]),
     ylab = expression(X[2]), main = "det(S): same variances, less area", las = 1)
abline(h = 0, col = "grey88")
segments(0, -1.25, 0, 2, col = "grey88")                 # stop above the table
for (i in seq_along(rs)) {
  S <- matrix(c(1, rs[i], rs[i], 1), 2)
  polygon(ell(S), border = col[i], lwd = 2.2,
          col = if (i == 2) adjustcolor(col[i], 0.12) else NA)
}
# semi-axes of the r = 0.75 ellipse
S <- matrix(c(1, 0.75, 0.75, 1), 2)
e <- eigen(S)
ax <- t(e$vectors %*% diag(sqrt(e$values)))
if (ax[2, 1] > 0) ax[2, ] <- -ax[2, ]                  # point the minor axis up-left
vectors(ax, col = "black", lwd = 2, labels = c(expression(sqrt(lambda[1])),
                                               expression(sqrt(lambda[2]))),
        pos.lab = c(4, 2), cex.lab = 1.05)
legend("bottom", bty = "n", cex = 0.9, inset = 0.01, text.col = col, title.col = "black",
       title = "  r      det(S)    area",
       legend = sprintf("%4.2f    %5.3f     %4.2f", rs, 1 - rs^2, pi * sqrt(1 - rs^2)))

par(op)
invisible(dev.off())
