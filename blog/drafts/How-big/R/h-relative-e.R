# Diagram: "How big is H, relative to E?" for heplots::mathscore (2 responses, 2 groups).
# Draws figures/h-relative-e.png. Run from the post folder:
#   Rscript R/h-relative-e.R
# Three panels, all with E/df_e and H/df_e (effect scaling, as in heplot(size = "effect")):
#   A. data space: the E ellipse (within-group covariance) and H, which is a line because
#      two groups differ in only one direction (s = min(q, df_h) = 1);
#   B. change the metric: z = E^{-1/2} (y - ybar) makes E the unit circle; H becomes H*;
#   C. rotate to the axes of H*: all that's left are the lambdas (here 6.42 and 0).
# The numbers are computed here, not typed in.

library(ggplot2)
library(patchwork)

col_h <- "#4C78A8"   # H, blue as in the banner and heplots
col_e <- "#D6604D"   # E, red as in the banner and heplots
col_pt <- "grey55"
col_lab <- "#2A5783"   # darker blue for text labels, legible on white

data(mathscore, package = "heplots")
fit <- lm(cbind(BM, WP) ~ group, data = mathscore)
aov <- car::Anova(fit)
dfe <- aov$error.df
H <- aov$SSP$group / dfe
E <- aov$SSPE / dfe
ybar <- colMeans(mathscore[, c("BM", "WP")])
gm <- aggregate(cbind(BM, WP) ~ group, data = mathscore, FUN = mean)

ev <- eigen(solve(aov$SSPE, aov$SSP$group))
lambda <- Re(ev$values)
stopifnot(abs(lambda[2]) < 1e-8)
uni <- diag(aov$SSP$group) / diag(aov$SSPE)          # univariate lambdas: SS_H / SS_E

# symmetric square roots
msqrt <- function(M, p = 1/2) { e <- eigen(M, symmetric = TRUE)
  e$vectors %*% diag(e$values^p) %*% t(e$vectors) }
Eih <- msqrt(E, -1/2)
Hs  <- Eih %*% H %*% Eih                                 # H* = E^{-1/2} H E^{-1/2}
es  <- eigen(Hs, symmetric = TRUE)
stopifnot(all.equal(es$values[1], lambda[1]))

th <- seq(0, 2 * pi, length.out = 361)
circ <- rbind(cos(th), sin(th))
ell <- function(M, centre = c(0, 0)) {                   # the ellipse { M^{1/2} u + centre }
  p <- t(msqrt(M) %*% circ) + rep(centre, each = length(th))
  data.frame(x = p[, 1], y = p[, 2]) }
hline <- function(M, centre = c(0, 0)) {                 # a rank-1 "ellipse" is a segment
  e <- eigen(M, symmetric = TRUE); h <- sqrt(e$values[1]) * e$vectors[, 1]
  data.frame(x = centre[1] - h[1], y = centre[2] - h[2], xend = centre[1] + h[1], yend = centre[2] + h[2]) }

theme_he <- function() list(theme_minimal(base_size = 13),
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey93"),
        plot.title = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey15", size = 11.5)))

# ---- A: data space ----
pA <- ggplot() +
  geom_point(data = mathscore, aes(BM, WP), colour = col_pt, size = 1.8) +
  geom_polygon(data = ell(E, ybar), aes(x, y), fill = col_e, alpha = 0.12, colour = col_e, linewidth = 1) +
  geom_segment(data = hline(H, ybar), aes(x, y, xend = xend, yend = yend), colour = col_h, linewidth = 2) +
  geom_point(data = gm, aes(BM, WP), colour = col_h, size = 3.2) +
  geom_text(data = gm, aes(BM, WP, label = paste("group", group)), colour = col_lab, size = 3.9, fontface = "bold",
            nudge_x = 4, nudge_y = c(-3, 3), hjust = 0) +
  annotate("text", x = ybar[1] + 22, y = ybar[2] + 24, label = "E", colour = col_e,
           size = 6, fontface = "bold.italic") +
  annotate("text", x = ybar[1] - 15, y = ybar[2] + 8, label = "H", colour = col_h,
           size = 6, fontface = "bold.italic") +
  coord_equal(xlim = c(135, 210)) +
  labs(title = "A. In the units of the data", subtitle = "H is a line: two groups differ in one direction",
       x = "Basic math (BM)", y = "Word problems (WP)") +
  theme_he()

# ---- B: make E a circle ----
lim <- 3.5
z  <- t(Eih %*% (t(as.matrix(mathscore[, c("BM", "WP")])) - ybar))
zm <- t(Eih %*% (t(as.matrix(gm[, c("BM", "WP")])) - ybar))
pB <- ggplot() +
  geom_point(data = data.frame(x = z[, 1], y = z[, 2]), aes(x, y), colour = col_pt, size = 1.8) +
  geom_polygon(data = ell(diag(2)), aes(x, y), fill = col_e, alpha = 0.12, colour = col_e, linewidth = 1) +
  geom_segment(data = hline(Hs), aes(x, y, xend = xend, yend = yend), colour = col_h, linewidth = 2) +
  geom_point(data = data.frame(x = zm[, 1], y = zm[, 2]), aes(x, y), colour = col_h, size = 3.2) +
  annotate("text", x = 0.8, y = 1.15, hjust = 0, label = "E = I", colour = col_e, size = 5, fontface = "bold.italic") +
  annotate("text", x = 0.75, y = -0.35, hjust = 0, label = "H*", colour = col_h, size = 5.5, fontface = "bold.italic") +
  coord_equal(xlim = c(-lim, lim), ylim = c(-lim, lim)) +
  labs(title = "B. Measure in units of E", subtitle = expression(H^"*" == E^{-1/2} * H * E^{-1/2}),
       x = NULL, y = NULL) +
  theme_he()

# ---- C: rotate to the axes of H* ----
R <- es$vectors; if (R[1, 1] < 0) R[, 1] <- -R[, 1]
zr  <- z %*% R; zmr <- zm %*% R
r1 <- sqrt(lambda[1])
pC <- ggplot() +
  geom_point(data = data.frame(x = zr[, 1], y = zr[, 2]), aes(x, y), colour = col_pt, size = 1.8) +
  geom_polygon(data = ell(diag(2)), aes(x, y), fill = col_e, alpha = 0.12, colour = col_e, linewidth = 1) +
  annotate("segment", x = -r1, xend = r1, y = 0, yend = 0, colour = col_h, linewidth = 2) +
  geom_point(data = data.frame(x = zmr[, 1], y = zmr[, 2]), aes(x, y), colour = col_h, size = 3.2) +
  annotate("segment", x = 0, xend = 1, y = -0.35, yend = -0.35, colour = col_e, linewidth = 0.6,
           arrow = arrow(ends = "both", length = unit(0.06, "inches"))) +
  annotate("text", x = 0.5, y = -0.6, label = "1", colour = col_e, size = 4) +
  annotate("segment", x = 0, xend = r1, y = 0.45, yend = 0.45, colour = col_h, linewidth = 0.6,
           arrow = arrow(ends = "both", length = unit(0.06, "inches"))) +
  annotate("text", x = r1 / 2, y = 0.75, colour = col_h, size = 4, parse = TRUE,
           label = sprintf("sqrt(lambda[1]) == %.2f", r1)) +
  annotate("text", x = -lim + 0.15, y = -lim + 0.5, hjust = 0, size = 4.2, parse = TRUE,
           label = sprintf("lambda[1] == %.2f*','~~lambda[2] == 0", lambda[1])) +
  coord_equal(xlim = c(-lim, lim), ylim = c(-lim, lim)) +
  labs(title = "C. Rotate to the axes of H*", subtitle = "All that's left: the eigenvalues",
       x = NULL, y = NULL) +
  theme_he()

cat(sprintf("lambda = %.3f; univariate lambdas BM %.3f, WP %.3f; Pillai = eta^2 = %.3f\n",
            lambda[1], uni[1], uni[2], lambda[1] / (1 + lambda[1])))
cat("discriminant weights (eigenvector of E^-1 H):", round(ev$vectors[, 1] / max(abs(ev$vectors[, 1])), 3), "\n")

p <- pA + pB + pC + plot_layout(widths = c(1.15, 1, 1))
ragg::agg_png("figures/h-relative-e.png", width = 13, height = 5, units = "in", res = 200)
print(p)
invisible(dev.off())
