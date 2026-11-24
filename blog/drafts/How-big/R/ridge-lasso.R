# Diagram: ridge regression vs. the lasso, as L2 vs. L1 length (section 1).
# Draws images/ridge-lasso.png. Run from the post folder:
#   Rscript R/ridge-lasso.R
# Two coefficients, correlated predictors. The red ellipses are contours of the residual
# sum of squares around the OLS estimate; they are Mahalanobis ellipses in the metric of
# X'X. Each method shrinks the estimate to the first point where an RSS contour touches
# its constraint region, of the same size t in both panels: the L2 disk for ridge, the L1
# diamond for the lasso. The diamond's corner makes the lasso set beta1 exactly to zero;
# the round disk never does. Dashed curves: the whole path of solutions as t shrinks.
# Inspired by a three-panel figure (ridge, lasso, elastic net) of unknown source.

library(ggplot2)
library(patchwork)

col <- c(L1 = "#4C78A8", L2 = "#F58518", rss = "#E45756")
txt <- c(L1 = "#2F5D8C", L2 = "#B85A00", rss = "#C0392B")

bhat <- c(0.25, 0.85)                       # OLS; corner needs bhat1 <= bhat2 - t (rho = .5)
rho  <- 0.5
A    <- matrix(c(1, rho, rho, 1), 2)        # X'X, standardized predictors
rss  <- function(b) drop(t(b - bhat) %*% A %*% (b - bhat))
t_size <- 0.5                               # size of both constraint regions

# ridge: b(k) = (A + kI)^-1 A bhat; path over k, and the k giving ||b||_2 = t
ridge <- function(k) drop(solve(A + k * diag(2), A %*% bhat))
k_t <- uniroot(function(k) sqrt(sum(ridge(k)^2)) - t_size, c(0, 1e3))$root
b_ridge <- ridge(k_t)
path_ridge <- do.call(rbind, lapply(c(0, exp(seq(-6, 8, length.out = 300))), ridge))

# lasso: minimize (1/2) rss(b) + lam * ||b||_1, by coordinate descent
soft <- function(z, g) sign(z) * pmax(abs(z) - g, 0)
lasso <- function(lam, b = bhat) {
  for (it in 1:500) for (j in 1:2) {
    r <- drop(A[j, ] %*% bhat) - A[j, -j] * b[-j]
    b[j] <- soft(r, lam) / A[j, j]
  }
  b
}
lam_t <- uniroot(function(l) sum(abs(lasso(l))) - t_size, c(0, 2))$root
b_lasso <- lasso(lam_t)
path_lasso <- do.call(rbind, lapply(seq(0, 1.2, length.out = 300), lasso))
stopifnot(abs(b_lasso[1]) < 1e-8)           # the corner solution

th <- seq(0, 2 * pi, length.out = 361)
# contour rss(b) = level. chol(A) = R with A = R'R; points b = bhat + sqrt(level) R^-1 u have rss = level
ellipse <- function(level) {
  z <- solve(chol(A), rbind(cos(th), sin(th)))
  data.frame(x = bhat[1] + sqrt(level) * z[1, ], y = bhat[2] + sqrt(level) * z[2, ])
}

panel <- function(title, region, b_star, path, key, rlab) {
  lev <- rss(b_star)
  inner <- do.call(rbind, lapply(c(0.15, 0.45), function(f)
    cbind(ellipse(f * lev), lev = f)))
  fmt <- function(v) sprintf("(%.2f, %.2f)", v[1], v[2])
  ggplot() +
    geom_hline(yintercept = 0, colour = "grey60") +
    geom_vline(xintercept = 0, colour = "grey60") +
    geom_polygon(data = region, aes(x, y), fill = col[[key]], alpha = 0.18,
                 colour = col[[key]], linewidth = 1.1) +
    geom_path(data = inner, aes(x, y, group = lev), colour = col[["rss"]],
              linewidth = 0.6, alpha = 0.7) +
    geom_path(data = ellipse(lev), aes(x, y), colour = col[["rss"]], linewidth = 1.1) +
    geom_path(data = data.frame(x = path[, 1], y = path[, 2]), aes(x, y),
              linetype = "22", colour = "grey20", linewidth = 0.6) +
    annotate("point", x = bhat[1], y = bhat[2], size = 2.8, colour = txt[["rss"]]) +
    annotate("text", x = bhat[1] + 0.04, y = bhat[2] + 0.04, hjust = 0, size = 4.3,
             colour = txt[["rss"]], fontface = "bold",
             label = paste("OLS", fmt(bhat))) +
    annotate("point", x = b_star[1], y = b_star[2], size = 3.4, shape = 21, fill = "white",
             stroke = 1.4) +
    annotate("text", x = b_star[1] + 0.05, y = b_star[2] - 0.05, hjust = 0, vjust = 1,
             size = 4.3, fontface = "bold", label = paste(title, fmt(b_star))) +
    annotate("text", x = 1.17, y = -0.47, hjust = 1, size = 4.3, colour = txt[[key]],
             fontface = "bold", label = rlab) +
    coord_equal(xlim = c(-0.6, 1.2), ylim = c(-0.55, 1.6), expand = FALSE) +
    labs(x = expression(beta[1]), y = expression(beta[2]), title = title) +
    theme_minimal(base_size = 14) +
    theme(panel.grid = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.background = element_rect(fill = "white", colour = NA))
}

disk    <- data.frame(x = t_size * cos(th), y = t_size * sin(th))
diamond <- data.frame(x = t_size * c(1, 0, -1, 0), y = t_size * c(0, 1, 0, -1))

p <- panel("Ridge", disk, b_ridge, path_ridge, "L2",
           sprintf("L₂:  β₁² + β₂² ≤ %g²", t_size)) +
  panel("Lasso", diamond, b_lasso, path_lasso, "L1",
        sprintf("L₁:  |β₁| + |β₂| ≤ %g", t_size))

ragg::agg_png("images/ridge-lasso.png", width = 10, height = 6.2, units = "in", res = 200)
print(p)
invisible(dev.off())
