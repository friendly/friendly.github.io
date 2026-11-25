# Diagram: Pottery read the way of fig-h-relative-e (section "Don't reduce too soon").
# Draws figures/pottery-he.png. Run from the post folder:
#   Rscript R/pottery-he.R
# Two panels, both with effect scaling, E/df_e and H/df_e (heplot(size = "effect")):
#   A. data space, Al against Fe: the shadows of the 5-D E and H ellipsoids on that plane.
#   C. canonical space: z = A'(y - ybar), with A chosen so that E = I and H is diagonal,
#      so E is the unit circle and the semi-axes of H are sqrt(lambda_i).
#      Grey arrows: structure correlations of the oxides with Can1 and Can2 (scaled).
# Labelled A and C to match panels A and C of figures/h-relative-e.png (mathscore).
# Replaces figures/he-vs-canonical.png, whose right panel repeated the first post.
# The numbers are computed here, not typed in.

library(ggplot2)
library(patchwork)

col_h <- "#4C78A8"; col_e <- "#D6604D"; col_pt <- "grey60"; col_v <- "grey30"
col_lab <- "#2A5783"   # darker blue for text labels, legible on white

data(Pottery, package = "carData")
ox  <- c("Al", "Fe", "Mg", "Ca", "Na")
fit <- lm(cbind(Al, Fe, Mg, Ca, Na) ~ Site, data = Pottery)
aov <- car::Anova(fit)
dfe <- aov$error.df
H <- aov$SSP$Site / dfe
E <- aov$SSPE / dfe
Y <- as.matrix(Pottery[, ox])
ybar <- colMeans(Y)
site <- c(Llanedyrn = "Llanedyrn", Caldicot = "Caldicot",
          IsleThorns = "Isle Thorns", AshleyRails = "Ashley Rails")
gm <- aggregate(Y ~ Site, data = Pottery, FUN = mean)
gm$label <- site[as.character(gm$Site)]
nudge <- function(v) unname(v[as.character(gm$Site)])     # per-site offsets, by name

msqrt <- function(M, p = 1/2) { e <- eigen(M, symmetric = TRUE)
  e$vectors %*% diag(e$values^p) %*% t(e$vectors) }

# canonical coefficients: A = E^{-1/2} W, with W the eigenvectors of H* = E^{-1/2} H E^{-1/2}
Eih <- msqrt(E, -1/2)
es  <- eigen(Eih %*% H %*% Eih, symmetric = TRUE)
lambda <- es$values[1:3]
A <- Eih %*% es$vectors[, 1:3]
Z  <- sweep(Y, 2, ybar) %*% A
Zm <- sweep(as.matrix(gm[, ox]), 2, ybar) %*% A
struc <- cor(Y, Z)[, 1:2]
if (struc["Al", 1] > 0) { Z[, 1] <- -Z[, 1]; Zm[, 1] <- -Zm[, 1]; struc[, 1] <- -struc[, 1] }
if (struc["Na", 2] < 0) { Z[, 2] <- -Z[, 2]; Zm[, 2] <- -Zm[, 2]; struc[, 2] <- -struc[, 2] }
stopifnot(all.equal(t(A) %*% E %*% A, diag(3), tolerance = 1e-8),        # E = I
          all.equal(t(A) %*% H %*% A, diag(lambda), tolerance = 1e-8),   # H diagonal
          all.equal(lambda, Re(eigen(solve(aov$SSPE, aov$SSP$Site))$values[1:3])))

th <- seq(0, 2 * pi, length.out = 361)
circ <- rbind(cos(th), sin(th))
ell <- function(M, centre = c(0, 0)) {
  p <- t(msqrt(M) %*% circ) + rep(centre, each = length(th))
  data.frame(x = p[, 1], y = p[, 2]) }

theme_he <- function() list(theme_minimal(base_size = 13),
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey93"),
        plot.title = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey15", size = 11.5)))

# ---- A: data space, Al and Fe ----
j <- c("Al", "Fe")
pA <- ggplot() +
  geom_point(data = Pottery, aes(Al, Fe), colour = col_pt, size = 1.8) +
  geom_polygon(data = ell(H[j, j], ybar[j]), aes(x, y), fill = col_h, alpha = 0.10,
               colour = col_h, linewidth = 1.1) +
  geom_polygon(data = ell(E[j, j], ybar[j]), aes(x, y), fill = col_e, alpha = 0.15,
               colour = col_e, linewidth = 1) +
  geom_point(data = gm, aes(Al, Fe), colour = col_h, size = 3.2) +
  geom_text(data = gm, aes(Al, Fe, label = label), colour = col_lab, size = 3.9, fontface = "bold",
            hjust = nudge(c(Llanedyrn = 0, Caldicot = 1, IsleThorns = 0, AshleyRails = 1)),
            nudge_x = nudge(c(Llanedyrn = 0.35, Caldicot = -0.35, IsleThorns = 0.35, AshleyRails = -0.35)),
            nudge_y = nudge(c(Llanedyrn = 0.1, Caldicot = 0, IsleThorns = 0.2, AshleyRails = -0.3))) +
  annotate("text", x = ybar["Al"] + 1.7, y = ybar["Fe"] + 1.15, label = "E", colour = col_e,
           size = 6, fontface = "bold.italic") +
  annotate("text", x = 18.3, y = 0.2, label = "H", colour = col_h,
           size = 6, fontface = "bold.italic") +
  coord_equal() +
  labs(title = "A. In the units of the data", subtitle = "Al against Fe: one shadow of five dimensions",
       x = "Al", y = "Fe") +
  theme_he()

# ---- C: canonical space ----
r <- sqrt(lambda)
vs <- 5.2                                                  # arrow scale, for legibility
V <- data.frame(ox = rownames(struc), x = vs * struc[, 1], y = vs * struc[, 2])
V$label <- V$ox; V$label[V$ox == "Fe"] <- "Fe, Mg"; V$label[V$ox == "Mg"] <- ""
pC <- ggplot() +
  geom_point(data = data.frame(x = Z[, 1], y = Z[, 2]), aes(x, y), colour = col_pt, size = 1.8) +
  geom_segment(data = V, aes(0, 0, xend = x, yend = y), colour = col_v, linewidth = 0.5,
               arrow = arrow(length = unit(0.07, "inches"))) +
  geom_text(data = V, aes(x * 1.13, y * 1.13, label = label), colour = col_v, size = 3.4) +
  geom_polygon(data = ell(diag(r[1:2]^2)), aes(x, y), fill = col_h, alpha = 0.10,
               colour = col_h, linewidth = 1.1) +
  geom_polygon(data = ell(diag(2)), aes(x, y), fill = col_e, alpha = 0.15, colour = col_e,
               linewidth = 1) +
  geom_point(data = data.frame(x = Zm[, 1], y = Zm[, 2]), aes(x, y), colour = col_h, size = 3.2) +
  geom_text(data = data.frame(x = Zm[, 1], y = Zm[, 2], label = gm$label), aes(x, y, label = label),
            colour = col_lab, size = 3.9, fontface = "bold",
            hjust = nudge(c(Llanedyrn = 0.5, Caldicot = 0, IsleThorns = 0.5, AshleyRails = 0.5)),
            nudge_x = nudge(c(Llanedyrn = 0, Caldicot = 0.35, IsleThorns = 0, AshleyRails = 0)),
            nudge_y = nudge(c(Llanedyrn = -0.5, Caldicot = 0, IsleThorns = 0.55, AshleyRails = -0.55))) +
  annotate("segment", x = 0, xend = -r[1], y = -1.75, yend = -1.75, colour = col_h, linewidth = 0.6,
           arrow = arrow(ends = "both", length = unit(0.06, "inches"))) +
  annotate("text", x = -r[1] / 2, y = -2.2, colour = col_h, size = 4, parse = TRUE,
           label = sprintf("sqrt(lambda[1]) == %.2f", r[1])) +
  annotate("segment", x = -0.25, xend = -0.25, y = 0, yend = r[2], colour = col_h,
           linewidth = 0.6, arrow = arrow(ends = "both", length = unit(0.05, "inches"))) +
  annotate("text", x = -0.4, y = r[2] + 0.35, colour = col_h, size = 4, parse = TRUE, hjust = 1,
           label = sprintf("sqrt(lambda[2]) == %.2f", r[2])) +
  annotate("text", x = -1.2, y = -0.7, label = "E = I", colour = col_e, size = 4.6,
           fontface = "bold.italic", hjust = 1) +
  annotate("text", x = -9.3, y = -4.3, hjust = 0, size = 4.1, parse = TRUE,
           label = sprintf("lambda == '%.2f, %.2f, %.3f'", lambda[1], lambda[2], lambda[3])) +
  coord_equal(xlim = c(-9.5, 8.5), ylim = c(-4.6, 4.6)) +
  labs(title = "C. Canonical space: E a circle, H on the axes",
       subtitle = "The first post's canonical plot, in effect units",
       x = "Can1", y = "Can2") +
  theme_he()

cat(sprintf("lambda = %s; sqrt = %s\n", paste(round(lambda, 3), collapse = ", "),
            paste(round(r, 2), collapse = ", ")))
print(round(struc, 2))
print(round(Zm[, 1:2], 2))

p <- pA + pC + plot_layout(widths = c(1, 1.55))
ragg::agg_png("figures/pottery-he.png", width = 13, height = 5.4, units = "in", res = 200)
print(p)
invisible(dev.off())
