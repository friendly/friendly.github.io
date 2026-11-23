# Diagram: "Ellipses have shadows" (section 5a; a redraw of Figure 13 of the ellipses paper).
# Draws images/coffee-shadows.png. Run from the post folder:
#   Rscript R/coffee-shadows.R
# lm(Heart ~ Coffee + Stress), matlib::coffee. In beta space, the confidence ellipse
#   E_r = { b + r * V^{1/2} z : |z| = 1 },  V = vcov of (b_Coffee, b_Stress)
# casts a shadow on any line. Along direction g, the shadow of g'beta is
#   g'b +/- r * sqrt(g' V g),
# touched by the ellipse at b +/- r * V g / sqrt(g' V g).
#   r = t_{.975, nu}           (d = 1): ordinary 95% intervals, one at a time
#   r = sqrt(2 F_{.95; 2, nu}) (d = 2): Scheffe intervals, for every linear combination
# Left panel: shadows on the two axes. Right panel: two other directions:
#   oblique, along the lines b_C + k b_S = const (k = slope of Stress on Coffee), onto
#     b_Stress = 0: its centre is the simple-regression slope for Coffee (omitted-variable
#     formula b_simple = b_C + k b_S);
#   orthogonal, onto the axis through 0 in direction (-1, 1): b_Stress - b_Coffee.

library(ggplot2)
library(patchwork)

data(coffee, package = "matlib")
fit <- lm(Heart ~ Coffee + Stress, data = coffee)
b   <- coef(fit)[c("Coffee", "Stress")]
V   <- vcov(fit)[c("Coffee", "Stress"), c("Coffee", "Stress")]
nu  <- df.residual(fit)
r1  <- qt(0.975, nu)
r2  <- sqrt(2 * qf(0.95, 2, nu))

ellipse <- function(r, n = 361) {
  th <- seq(0, 2 * pi, length.out = n)
  p  <- t(b + r * t(chol(V)) %*% rbind(cos(th), sin(th)))
  data.frame(x = p[, 1], y = p[, 2])
}
shadow <- function(g, r) {            # interval for g'beta, and where the ellipse touches
  s <- sqrt(drop(t(g) %*% V %*% g))
  list(ci = sum(g * b) + c(-1, 1) * r * s,
       touch = rbind(drop(b - r * V %*% g / s), drop(b + r * V %*% g / s)))
}

# --- checks against the usual numbers -------------------------------------------------
stopifnot(all.equal(unname(shadow(c(1, 0), r1)$ci), unname(confint(fit)["Coffee", ])),
          all.equal(unname(shadow(c(0, 1), r1)$ci), unname(confint(fit)["Stress", ])))
k       <- unname(coef(lm(Stress ~ Coffee, data = coffee))[2])
simple  <- lm(Heart ~ Coffee, data = coffee)
obl     <- shadow(c(1, k), r1)
stopifnot(all.equal(mean(obl$ci), unname(coef(simple)[2])))
dif     <- shadow(c(-1, 1), r1)
cat("Coffee  (Stress held):", round(shadow(c(1, 0), r1)$ci, 2), "\n",
    "Stress  (Coffee held):", round(shadow(c(0, 1), r1)$ci, 2), "\n",
    "Scheffe Coffee:", round(shadow(c(1, 0), r2)$ci, 2),
    " Stress:", round(shadow(c(0, 1), r2)$ci, 2), "\n",
    "Oblique shadow (simple slope for Coffee):", round(obl$ci, 2),
    "  centre", round(mean(obl$ci), 3), "\n",
    "Simple-regression CI, for comparison:", round(confint(simple)[2, ], 2), "\n",
    "Stress - Coffee:", round(dif$ci, 2), "\n")

# --- drawing --------------------------------------------------------------------------
col_ell <- "#4C78A8"; col_sh <- "#F58518"; col_sch <- "#9D9D9D"; col_ray <- "grey55"
e1 <- ellipse(r1); e2 <- ellipse(r2)
xl <- c(-2.1, 2.1); yl <- c(-1.1, 2.9)

base <- function(title) list(
  geom_hline(yintercept = 0, colour = "grey80"),
  geom_vline(xintercept = 0, colour = "grey80"),
  coord_equal(xlim = xl, ylim = yl, expand = FALSE),
  labs(title = title, x = expression(beta[Coffee]), y = expression(beta[Stress])),
  theme_minimal(base_size = 13),
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey94"),
        plot.title = element_text(face = "bold", size = 13)))

# a shadow strip: polygon from the two touch points to their landing points on a line
strip <- function(touch, land) data.frame(x = c(touch[1, 1], land[1, 1], land[2, 1], touch[2, 1]),
                                          y = c(touch[1, 2], land[1, 2], land[2, 2], touch[2, 2]))
ray <- function(touch, land) data.frame(x = touch[, 1], y = touch[, 2],
                                        xend = land[, 1], yend = land[, 2])
seg <- function(land) data.frame(x = land[1, 1], y = land[1, 2], xend = land[2, 1], yend = land[2, 2])

# Left: shadows on the axes
sx <- shadow(c(1, 0), r1); landx <- cbind(sx$ci, 0)
sy <- shadow(c(0, 1), r1); landy <- cbind(0, sy$ci)
qx <- shadow(c(1, 0), r2)$ci; qy <- shadow(c(0, 1), r2)$ci
off <- 0.13                       # Scheffe intervals drawn just outside the axes

pA <- ggplot() + base("Shadows on the axes") +
  geom_polygon(data = strip(sx$touch, landx), aes(x, y), fill = col_sh, alpha = 0.12) +
  geom_polygon(data = strip(sy$touch, landy), aes(x, y), fill = col_sh, alpha = 0.12) +
  geom_segment(data = ray(sx$touch, landx), aes(x, y, xend = xend, yend = yend),
               colour = col_ray, linetype = "22", linewidth = 0.4) +
  geom_segment(data = ray(sy$touch, landy), aes(x, y, xend = xend, yend = yend),
               colour = col_ray, linetype = "22", linewidth = 0.4) +
  geom_path(data = e2, aes(x, y), colour = col_sch, linewidth = 0.7) +
  geom_polygon(data = e1, aes(x, y), fill = col_ell, alpha = 0.18, colour = col_ell, linewidth = 1) +
  geom_segment(data = seg(landx), aes(x, y, xend = xend, yend = yend), colour = col_sh, linewidth = 2.4) +
  geom_segment(data = seg(landy), aes(x, y, xend = xend, yend = yend), colour = col_sh, linewidth = 2.4) +
  annotate("segment", x = qx[1], xend = qx[2], y = -off, yend = -off, colour = col_sch, linewidth = 1.2) +
  annotate("segment", x = off, xend = off, y = qy[1], yend = qy[2], colour = col_sch, linewidth = 1.2) +
  annotate("point", x = b[1], y = b[2], size = 2.2, colour = col_ell) +
  annotate("text", x = mean(sx$ci), y = -0.38, label = "Coffee: includes 0",
           colour = col_sh, size = 3.8, fontface = "bold") +
  annotate("text", x = 0.25, y = mean(sy$ci), label = "Stress:\nexcludes 0", hjust = 0,
           colour = col_sh, size = 3.8, fontface = "bold", lineheight = 0.9) +
  annotate("text", x = -1.95, y = 2.65, hjust = 0, size = 3.6, lineheight = 0.95,
           label = "blue: 95% CI ellipse (d = 1)\n   its shadows are the usual CIs",
           colour = col_ell) +
  annotate("text", x = -1.95, y = 2.2, hjust = 0, size = 3.6, lineheight = 0.95,
           label = "grey: joint ellipse (d = 2)\n   its shadows are Scheffé intervals",
           colour = "grey40")

# Right: shadows in other directions
landO <- cbind(obl$ci, 0)                               # oblique, onto b_Stress = 0
u     <- c(-1, 1) / sqrt(2)                             # unit vector of the difference axis
landD <- t(sapply(dif$ci, function(v) v * c(-1, 1) / 2)) # value v sits at v * a / |a|^2
axisD <- data.frame(x = 2.1, y = -2.1, xend = -1.1, yend = 1.1)
ticks <- data.frame(v = seq(0, 2, by = 0.5))
ticks <- transform(ticks, x = -v / 2, y = v / 2)
perp  <- c(1, 1) / sqrt(2) * 0.06

pB <- ggplot() + base("Shadows in other directions") +
  geom_segment(data = axisD, aes(x, y, xend = xend, yend = yend), colour = "grey60", linewidth = 0.5) +
  geom_segment(data = ticks, aes(x = x - perp[1], y = y - perp[2], xend = x + perp[1], yend = y + perp[2]),
               colour = "grey60") +
  geom_text(data = ticks, aes(x = x + 2.4 * perp[1], y = y + 2.4 * perp[2], label = v),
            size = 3, colour = "grey45") +
  geom_polygon(data = strip(obl$touch, landO), aes(x, y), fill = col_sh, alpha = 0.12) +
  geom_polygon(data = strip(dif$touch, landD), aes(x, y), fill = col_sh, alpha = 0.12) +
  geom_segment(data = ray(obl$touch, landO), aes(x, y, xend = xend, yend = yend),
               colour = col_ray, linetype = "22", linewidth = 0.4) +
  geom_segment(data = ray(dif$touch, landD), aes(x, y, xend = xend, yend = yend),
               colour = col_ray, linetype = "22", linewidth = 0.4) +
  geom_polygon(data = e1, aes(x, y), fill = col_ell, alpha = 0.18, colour = col_ell, linewidth = 1) +
  geom_segment(data = seg(landO), aes(x, y, xend = xend, yend = yend), colour = col_sh, linewidth = 2.4) +
  geom_segment(data = seg(landD), aes(x, y, xend = xend, yend = yend), colour = col_sh, linewidth = 2.4) +
  annotate("point", x = b[1], y = b[2], size = 2.2, colour = col_ell) +
  annotate("point", x = mean(obl$ci), y = 0, size = 2.2, colour = "black") +
  annotate("text", x = 0.95, y = -0.38, size = 3.8, fontface = "bold", colour = col_sh,
           label = "Coffee, ignoring Stress") +
  annotate("text", x = 0.95, y = -0.62, size = 3.4, colour = "grey30",
           label = "(the simple regression)") +
  annotate("text", x = -1.05, y = 0.55, size = 3.8, fontface = "bold", colour = col_sh,
           angle = -45, label = "Stress − Coffee")

p <- pA + pB
ragg::agg_png("images/coffee-shadows.png", width = 11, height = 5.6, units = "in", res = 200)
print(p)
invisible(dev.off())
