# Diagram: "unit circles" for different senses of length (section 1).
# Draws images/unit-balls.png. Run from the post folder:
#   Rscript R/unit-balls.R
# Left: the points at distance 1 from the origin under L1, L2 and L-infinity.
# Right: under the Mahalanobis metric e' S^-1 e = 1 the circle becomes an ellipse.
# Points A and B are both at Euclidean distance 1, but at very different
# Mahalanobis distances.

library(ggplot2)
library(patchwork)

col <- c(L1 = "#4C78A8", L2 = "#F58518", Linf = "#54A24B", M = "#E45756")
th <- seq(0, 2 * pi, length.out = 361)

base <- function(xlim = c(-1.9, 1.9)) list(
  geom_hline(yintercept = 0, colour = "grey85"),
  geom_vline(xintercept = 0, colour = "grey85"),
  coord_equal(xlim = xlim, ylim = c(-1.9, 1.9)),
  theme_void(base_size = 13),
  theme(plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 6)),
        plot.background = element_rect(fill = "white", colour = NA))
)

# ---- left: L1, L2, L-infinity ----
balls <- rbind(
  data.frame(norm = "L1",   x = c(1, 0, -1, 0, 1), y = c(0, 1, 0, -1, 0)),
  data.frame(norm = "L2",   x = cos(th), y = sin(th)),
  data.frame(norm = "Linf", x = c(1, -1, -1, 1, 1), y = c(1, 1, -1, -1, 1))
)
lab1 <- data.frame(
  norm  = c("Linf", "L2", "L1"),
  x     = c(-1, 1.12, 1.12), y = c(1.16, 0.95, -0.75),     # text
  x0    = c(NA, 0.71, 0.50), y0 = c(NA, 0.71, -0.50),      # leader from the curve
  label = c("L∞:  max(|x|, |y|) = 1", "L₂:  x² + y² = 1",
            "L₁:  |x| + |y| = 1")
)

p1 <- ggplot(balls, aes(x, y, colour = norm)) +
  base(xlim = c(-1.4, 2.8)) +
  geom_path(linewidth = 1.1) +
  geom_segment(data = lab1[-1, ], aes(x = x0, y = y0, xend = x - 0.04, yend = y),
               linewidth = 0.4) +
  geom_text(data = lab1, aes(x, y, label = label), hjust = 0, vjust = 0.3, size = 4) +
  scale_colour_manual(values = col, guide = "none") +
  ggtitle("Three lengths")

# ---- right: Mahalanobis ----
rho <- 0.75
S <- matrix(c(1, rho, rho, 1), 2)
ell <- t(t(chol(S)) %*% rbind(cos(th), sin(th)))       # e' S^-1 e = 1
ell <- data.frame(x = ell[, 1], y = ell[, 2])
circ <- data.frame(x = cos(th), y = sin(th))

pts <- data.frame(x = c(1, -1) / sqrt(2), y = c(1, 1) / sqrt(2), name = c("A", "B"))
dm <- sqrt(mahalanobis(as.matrix(pts[, c("x", "y")]), c(0, 0), S))
pts$label <- sprintf("%s: Euclid 1, Mahalanobis %.2f", pts$name, dm)

p2 <- ggplot() +
  base() +
  geom_path(data = circ, aes(x, y), colour = col[["L2"]], linewidth = 0.8, linetype = "22") +
  geom_path(data = ell, aes(x, y), colour = col[["M"]], linewidth = 1.1) +
  geom_segment(data = pts, aes(x = 0, y = 0, xend = x, yend = y), colour = "grey30") +
  geom_point(data = pts, aes(x, y), size = 2.6) +
  geom_text(data = pts, aes(x, y, label = name), nudge_x = c(0.1, -0.1), nudge_y = 0.1,
            fontface = "bold", size = 4.4) +
  annotate("text", x = 0, y = -1.55, size = 3.5, lineheight = 0.95,
           label = paste0(pts$label[1], "\n", pts$label[2])) +
  annotate("text", x = 0.6, y = -0.9, colour = col[["M"]], hjust = 0, size = 4,
           parse = TRUE, label = "bold(e)^T*bold(S)^-1*bold(e)==1") +
  ggtitle(sprintf("Change the metric: ρ = %.2f", rho))

p <- p1 + p2 + plot_layout(widths = c(4.2, 3.8))

ragg::agg_png("images/unit-balls.png", width = 9.5, height = 4.6, units = "in", res = 200)
print(p)
invisible(dev.off())
