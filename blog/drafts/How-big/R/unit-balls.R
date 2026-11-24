# Diagram: "unit circles" for different senses of length (section 1).
# Draws images/unit-balls.png. Run from the post folder:
#   Rscript R/unit-balls.R
# Left: the points at distance 1 from the origin under L1, L2 and L-infinity, and two
#   vectors measured all three ways. a = (0.6, 0.8) is on the circle (L2 = 1), outside
#   the diamond and inside the square. b = (-0.5, -0.5) is on the diamond (L1 = 1).
#   The dashed path for a is its city-block (L1) route; its longer leg, shaded green,
#   is its L-infinity length.
# Right: under the Mahalanobis metric e' S^-1 e = 1 the circle becomes an ellipse.
#   Points A and B are both at Euclidean distance 1, but at very different
#   Mahalanobis distances.

library(ggplot2)
library(patchwork)

col <- c(L1 = "#4C78A8", L2 = "#F58518", Linf = "#54A24B", M = "#E45756")
# darker versions, for text on white
txt <- c(L1 = "#2F5D8C", L2 = "#B85A00", Linf = "#2E7D32", M = "#C0392B")
th <- seq(0, 2 * pi, length.out = 361)

base <- function(xlim = c(-1.9, 1.9)) list(
  geom_hline(yintercept = 0, colour = "grey85"),
  geom_vline(xintercept = 0, colour = "grey85"),
  coord_equal(xlim = xlim, ylim = c(-1.9, 1.9)),
  theme_void(base_size = 14),
  theme(plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 6)),
        plot.background = element_rect(fill = "white", colour = NA))
)
arr <- arrow(length = unit(0.1, "inches"), type = "closed")

# ---- left: L1, L2, L-infinity ----
balls <- rbind(
  data.frame(norm = "L1",   x = c(1, 0, -1, 0, 1), y = c(0, 1, 0, -1, 0)),
  data.frame(norm = "L2",   x = cos(th), y = sin(th)),
  data.frame(norm = "Linf", x = c(1, -1, -1, 1, 1), y = c(1, 1, -1, -1, 1))
)
lab1 <- data.frame(
  norm  = c("Linf", "L2", "L1"),
  x     = c(-1, 1.12, 1.12), y = c(1.17, 0.40, -0.75),     # text
  x0    = c(NA, 0.92, 0.50), y0 = c(NA, 0.39, -0.50),      # leader from the curve
  label = c("L∞:  max(|x|, |y|) = 1", "L₂:  x² + y² = 1",
            "L₁:  |x| + |y| = 1")
)

vecs <- data.frame(name = c("a", "b"), x = c(0.6, -0.5), y = c(0.8, -0.5))
len <- function(v) c(L1 = sum(abs(v)), L2 = sqrt(sum(v^2)), Linf = max(abs(v)))
L <- t(apply(vecs[, c("x", "y")], 1, len))
fmt <- function(z) sub("\\.?0+$", "", sprintf("%.2f", z))
table1 <- data.frame(
  x = -1.35, y = c(-1.3, -1.58),
  label = sprintf("%s = (%s, %s):   L₁ %s   L₂ %s   L∞ %s",
                  vecs$name, fmt(vecs$x), fmt(vecs$y), fmt(L[, "L1"]), fmt(L[, "L2"]),
                  fmt(L[, "Linf"]))
)

p1 <- ggplot(balls, aes(x, y, colour = norm)) +
  base(xlim = c(-1.4, 2.9)) +
  geom_path(linewidth = 1.1) +
  # city-block route for a; its longer leg (green underlay) is its L-infinity length
  annotate("segment", x = 0.6, y = 0, xend = 0.6, yend = 0.8, colour = col[["Linf"]],
           linewidth = 3, alpha = 0.45) +
  annotate("segment", x = 0, y = 0, xend = 0.6, yend = 0, colour = txt[["L1"]],
           linetype = "22", linewidth = 0.9) +
  annotate("segment", x = 0.6, y = 0, xend = 0.6, yend = 0.8, colour = txt[["L1"]],
           linetype = "22", linewidth = 0.9) +

  geom_segment(data = vecs, aes(x = 0, y = 0, xend = x, yend = y), inherit.aes = FALSE,
               colour = "black", linewidth = 0.9, arrow = arr) +
  geom_text(data = vecs, aes(x, y, label = name), inherit.aes = FALSE,
            nudge_x = c(0.07, -0.09), nudge_y = c(0.08, -0.08),
            fontface = "bold.italic", size = 5.5) +
  geom_segment(data = lab1[-1, ], aes(x = x0, y = y0, xend = x - 0.04, yend = y),
               linewidth = 0.4) +
  geom_text(data = lab1, aes(x, y, label = label), colour = txt[lab1$norm], hjust = 0,
            vjust = 0.3, size = 4.8, fontface = "bold") +
  geom_text(data = table1, aes(x, y, label = label), inherit.aes = FALSE, hjust = 0,
            size = 4.2) +
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
  geom_path(data = circ, aes(x, y), colour = col[["L2"]], linewidth = 0.9, linetype = "22") +
  geom_path(data = ell, aes(x, y), colour = col[["M"]], linewidth = 1.1) +
  geom_segment(data = pts, aes(x = 0, y = 0, xend = x, yend = y), colour = "grey30",
               linewidth = 0.8, arrow = arr) +
  geom_point(data = pts, aes(x, y), size = 2.6) +
  geom_text(data = pts, aes(x, y, label = name), nudge_x = c(0.1, -0.1), nudge_y = 0.11,
            fontface = "bold", size = 5) +
  annotate("text", x = 0, y = -1.55, size = 4.2, lineheight = 0.95,
           label = paste0(pts$label[1], "\n", pts$label[2])) +
  annotate("text", x = 0.6, y = -0.9, colour = txt[["M"]], hjust = 0, size = 4.8,
           parse = TRUE, label = "bold(e)^T*bold(S)^-1*bold(e)==1") +
  ggtitle(sprintf("Change the metric: ρ = %.2f", rho))

p <- p1 + p2 + plot_layout(widths = c(4.7, 3.8))

ragg::agg_png("images/unit-balls.png", width = 10.5, height = 4.8, units = "in", res = 200)
print(p)
invisible(dev.off())
