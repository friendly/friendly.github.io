# Diagram: the four test statistics as four measurements of one ellipse (section 5;
# a redraw of Figure 19 of the ellipses paper, one measurement per panel).
# Draws images/four-rulers.png. Run from the post folder:
#   Rscript R/four-rulers.R
# In the error metric, E is the unit circle and (H + E) is an ellipse with
# semi-axes a = sqrt(1 + lambda1), b = sqrt(1 + lambda2). For q = 2:
#   Roy    R = a^2 - 1            (the major semi-axis a)
#   Wilks  Lambda = 1 / (ab)^2    (the area, pi * ab)
#   HL     U = c^2 - 2            (c = sqrt(a^2 + b^2), the chord from (a, 0) to (0, b))
#   Pillai V = 2 - 1 / d^2        (d = ab / c, the perpendicular from 0 to that chord)

library(ggplot2)
library(patchwork)

lambda <- c(3, 1)                    # toy roots, chosen for round numbers
a <- sqrt(1 + lambda[1]); b <- sqrt(1 + lambda[2])
c <- sqrt(a^2 + b^2); d <- a * b / c
foot <- c(a * b^2, a^2 * b) / c^2   # foot of the perpendicular from 0 to the chord
u1 <- c(-a, b) / c; u2 <- -foot / d; k <- 0.14   # along the chord, back toward 0
ra <- data.frame(x = foot[1] + k * c(u1[1], u1[1] + u2[1], u2[1]),
                 y = foot[2] + k * c(u1[2], u1[2] + u2[2], u2[2]))

stat <- c(Roy = a^2 - 1, Wilks = 1 / (a * b)^2, HL = c^2 - 2, Pillai = 2 - 1 / d^2)
# check against the usual definitions
stopifnot(all.equal(unname(stat),
                    c(max(lambda), prod(1 / (1 + lambda)), sum(lambda),
                      sum(lambda / (1 + lambda)))))

col_e <- "#9D9D9D"; col_he <- "#F58518"; col_hi <- "#4C78A8"
th <- seq(0, 2 * pi, length.out = 361)
circ <- data.frame(x = cos(th), y = sin(th))
ell  <- data.frame(x = a * cos(th), y = b * sin(th))

base <- function(title) list(
  geom_hline(yintercept = 0, colour = "grey88"),
  geom_vline(xintercept = 0, colour = "grey88"),
  geom_polygon(data = ell, aes(x, y), fill = NA, colour = col_he, linewidth = 1),
  geom_polygon(data = circ, aes(x, y), fill = NA, colour = col_e, linewidth = 0.9),
  annotate("text", x = -0.62, y = -0.62, label = "E", colour = "grey40", fontface = "bold",
           size = 4.2),
  annotate("text", x = -a * 0.8, y = -b * 0.9, label = "H + E", colour = col_he,
           fontface = "bold", size = 4.2, hjust = 1),
  coord_equal(xlim = c(-a - 0.25, a + 0.35), ylim = c(-b - 0.35, b + 0.35)),
  ggtitle(title),
  theme_void(base_size = 12),
  theme(plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 4)),
        plot.background = element_rect(fill = "white", colour = NA))
)
seg <- function(x, y, xend, yend, ...)
  annotate("segment", x = x, y = y, xend = xend, yend = yend, ...)
hi  <- function(lw = 1.6) list(colour = col_hi, linewidth = lw)
lab <- function(x, y, label, ...)
  annotate("text", x = x, y = y, label = label, colour = col_hi, fontface = "bold",
           size = 4.4, ...)

p_roy <- ggplot() + base(sprintf("Roy:  R = a² − 1 = %g", stat[["Roy"]])) +
  do.call(seg, c(list(0, 0, a, 0), hi())) +
  lab(a * 0.78, 0.2, "a")

p_wilks <- ggplot() + base(sprintf("Wilks:  Λ = 1 / (ab)² = %g", stat[["Wilks"]])) +
  geom_polygon(data = ell, aes(x, y), fill = col_hi, alpha = 0.25) +
  do.call(seg, c(list(0, 0, a, 0), hi(1))) +
  do.call(seg, c(list(0, 0, 0, b), hi(1))) +
  lab(a / 2, -0.18, "a") + lab(-0.15, b / 2, "b") +
  lab(a / 2, -b / 2, "area = πab")

p_hl <- ggplot() + base(sprintf("Hotelling-Lawley:  U = c² − 2 = %g", stat[["HL"]])) +
  seg(a, 0, a, b, colour = "grey60", linetype = "22") +
  seg(0, b, a, b, colour = "grey60", linetype = "22") +
  do.call(seg, c(list(a, 0, 0, b), hi())) +
  lab(a / 2 + 0.2, b / 2 + 0.2, "c")

p_pillai <- ggplot() + base(sprintf("Pillai:  V = 2 − 1 / d² = %g", stat[["Pillai"]])) +
  seg(a, 0, 0, b, colour = "grey60", linewidth = 0.8) +
  do.call(seg, c(list(0, 0, foot[1], foot[2]), hi())) +
  geom_path(data = ra, aes(x, y), colour = "grey40", linewidth = 0.5) +
  lab(foot[1] / 2 + 0.05, foot[2] / 2 + 0.22, "d")

p <- (p_roy + p_wilks) / (p_hl + p_pillai) +
  plot_annotation(
    caption = sprintf("λ = (%g, %g):  a = %.3g,  b = %.3g,  c = %.3g,  d = %.3g",
                      lambda[1], lambda[2], a, b, c, d),
    theme = theme(plot.caption = element_text(hjust = 0.5, size = 11, colour = "grey30")))

ragg::agg_png("images/four-rulers.png", width = 8.5, height = 6.6, units = "in", res = 200)
print(p)
invisible(dev.off())
