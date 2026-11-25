# Diagram: same total size, different spread (section 2b, "How big is a matrix of data?").
# Draws figures/spread-spectra.png. Run from the post folder:
#   Rscript R/spread-spectra.R
# Eigenvalues of three 5 x 5 correlation matrices, i.e. d_i^2 / (n - 1) for standardized
# data. All have total (trace, squared Frobenius size) = 5, so the total can't tell them
# apart. The largest (spectral), the product (determinant) and the condition number can:
#   Round:     all equal, the data ellipsoid is a sphere.
#   Pottery:   the five standardized oxides (carData::Pottery), one big dimension.
#   Collinear: made up; four ordinary dimensions and one nearly missing.

library(ggplot2)

data(Pottery, package = "carData")
spec <- list(
  "Round"           = rep(1, 5),
  "Pottery oxides"  = eigen(cor(Pottery[, -1]))$values,
  "Nearly collinear" = c(1.30, 1.25, 1.25, 1.19, 0.01)
)

bars <- do.call(rbind, lapply(names(spec), function(s) {
  l <- spec[[s]]
  data.frame(panel = s, i = seq_along(l), lambda = l,
             role = c("largest", rep("other", length(l) - 2), "smallest"))
}))
bars$panel <- factor(bars$panel, levels = names(spec))
bars$role[bars$panel == "Round"] <- "other"

fmt <- function(x) formatC(x, digits = 3, format = "fg", flag = "#")
notes <- do.call(rbind, lapply(names(spec), function(s) {
  l <- spec[[s]]
  data.frame(panel = s, y = 4.35 - 0.36 * (0:3), what = c("total", "largest", "product", "cond"),
             label = c(sprintf("total  Σλ = %g", round(sum(l), 2)),
                       sprintf("largest  λ₁ = %s", fmt(l[1])),
                       sprintf("product  Πλ = %s", fmt(prod(l))),
                       sprintf("condition  √(λ₁/λ₅) = %s", fmt(sqrt(l[1] / l[5])))))
}))
notes$panel <- factor(notes$panel, levels = names(spec))

fill <- c(largest = "#E45756", other = "grey70", smallest = "#4C78A8")
txt  <- c(total = "grey25", largest = "#C0392B", product = "grey25", cond = "#2F5D8C")

p <- ggplot(bars, aes(i, lambda)) +
  geom_hline(yintercept = 1, linetype = "22", colour = "grey55") +
  geom_col(aes(fill = role), width = 0.7) +
  geom_text(aes(label = formatC(lambda, digits = 2, format = "f")), vjust = -0.4,
            size = 3.4, colour = "grey30") +
  geom_text(data = notes, aes(x = 5.45, y = y, label = label, colour = what),
            hjust = 1, size = 3.9, fontface = "bold") +
  facet_wrap(~ panel, nrow = 1) +
  scale_fill_manual(values = fill, guide = "none") +
  scale_colour_manual(values = txt, guide = "none") +
  scale_x_continuous(breaks = 1:5, labels = paste0("λ", c("₁", "₂", "₃", "₄", "₅"))) +
  scale_y_continuous(limits = c(0, 4.55), expand = c(0, 0)) +
  labs(x = NULL, y = "eigenvalue (variance along that axis)") +
  theme_minimal(base_size = 14) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        strip.text = element_text(face = "bold", size = 14),
        panel.spacing.x = unit(1.5, "lines"),
        plot.background = element_rect(fill = "white", colour = NA))

ragg::agg_png("figures/spread-spectra.png", width = 11, height = 4.6, units = "in", res = 200)
print(p)
invisible(dev.off())
