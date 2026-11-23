# Diagram: what each test statistic counts as "big" (section 4).
# Draws images/four-contours.png. Run from the post folder:
#   Rscript R/four-contours.R
# In the (lambda1, lambda2) plane, each curve is the contour of one statistic
# through the concentrated effect lambda = (1, 0). All four agree there.
# The diffuse effect (0.5, 0.5) has the same Hotelling-Lawley trace, so it lies on
# the HL line; it is outside the Pillai and Wilks contours (they call it bigger)
# and inside Roy's (Roy calls it smaller).
# By convention lambda1 >= lambda2; the other half (shaded) is the mirror image.

library(ggplot2)

col <- c(Pillai = "#4C78A8", Wilks = "#54A24B", HL = "#F58518", Roy = "#E45756")
conc <- c(1, 0); diff <- c(0.5, 0.5)

# value of each statistic at the concentrated effect
V0 <- sum(conc / (1 + conc)); L0 <- prod(1 / (1 + conc)); U0 <- sum(conc); R0 <- max(conc)

l1 <- seq(0, 1, length.out = 201)
inv <- function(t) t / (1 - t)                           # solves l / (1 + l) = t
curves <- rbind(
  data.frame(stat = "Pillai", x = l1, y = inv(V0 - l1 / (1 + l1))),
  data.frame(stat = "Wilks",  x = l1, y = 1 / (L0 * (1 + l1)) - 1),
  data.frame(stat = "HL",     x = l1, y = U0 - l1),
  data.frame(stat = "Roy",    x = c(1, 1, 0), y = c(0, 1, 1))
)
curves$stat <- factor(curves$stat, levels = names(col))

# where each contour crosses the diagonal lambda1 = lambda2
cross <- data.frame(stat = factor(names(col), levels = names(col)),
                    v = c(1 / 3, sqrt(2) - 1, 0.5, 1))
labs <- data.frame(
  stat = factor(names(col), levels = names(col)),
  x = 0.04, y = c(1.255, 1.195, 1.135, 1.075),               # a key above the Roy line
  label = c(sprintf("Pillai  V = %.1f", V0), sprintf("Wilks  Λ = %.1f", L0),
            sprintf("Hotelling-Lawley  U = %g", U0), sprintf("Roy  R = %g", R0))
)
pts <- data.frame(x = c(conc[1], diff[1]), y = c(conc[2], diff[2]),
                  label = c("concentrated (1, 0)", "diffuse (0.5, 0.5)"),
                  hjust = c(-0.08, -0.12), vjust = c(-0.6, 1.6))

p <- ggplot() +
  annotate("polygon", x = c(0, 0, 1.3), y = c(0, 1.3, 1.3), fill = "grey95") +
  annotate("segment", x = 0, y = 0, xend = 1.3, yend = 1.3, colour = "grey70",
           linetype = "22") +
  annotate("text", x = 1.22, y = 1.27, label = "λ₁ = λ₂", hjust = 1,
           colour = "grey50", size = 3.6) +
  geom_path(data = curves, aes(x, y, colour = stat), linewidth = 1.2) +
  geom_point(data = cross, aes(v, v, colour = stat), size = 2.2) +
  geom_text(data = labs, aes(x, y, label = label, colour = stat), hjust = 0, size = 4,
            fontface = "bold") +
  geom_point(data = pts, aes(x, y), size = 3.4, shape = 21, fill = "white", stroke = 1.3) +
  geom_text(data = pts, aes(x, y, label = label, hjust = hjust, vjust = vjust), size = 3.8) +
  scale_colour_manual(values = col, guide = "none") +
  coord_equal(xlim = c(0, 1.3), ylim = c(0, 1.3), expand = FALSE, clip = "off") +
  labs(x = expression(lambda[1]), y = expression(lambda[2])) +
  theme_minimal(base_size = 14) +
  theme(panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(10, 20, 10, 10))

ragg::agg_png("images/four-contours.png", width = 6.2, height = 6, units = "in", res = 200)
print(p)
invisible(dev.off())
