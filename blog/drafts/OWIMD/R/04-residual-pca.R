# Our World in Multivariate Data -- 4. Doing better than your money: residual PCA / biplot

if (!exists("cc")) source("R/00-setup.R")
if (!exists("mod2")) mod2 <- lm(Z ~ ns(logGDP, 3), data = cc)

## ---- pca-y
# PCA of the (standardized, oriented) responses: PC1 is essentially GDP
pca_y <- prcomp(Z)
summary(pca_y)$importance[, 1:4]
round(cor(pca_y$x[, 1:2], cc$logGDP), 2)

## ---- pca-resid
# PCA of residuals from the GDP model
res <- resid(mod2)
pca_r <- prcomp(res)
# orient PC1 so that positive = better than GDP predicts
if (sum(pca_r$rotation[, 1]) < 0) {
  pca_r$rotation[, 1] <- -pca_r$rotation[, 1]
  pca_r$x[, 1] <- -pca_r$x[, 1]
}
summary(pca_r)$importance[, 1:4]
round(pca_r$rotation[, 1:2], 2)

## ---- fig-biplot
scores <- data.frame(cc[, c("country", "region")], pca_r$x[, 1:2])
extreme <- scores |> filter(rank(PC1) <= 6 | rank(-PC1) <= 6 | rank(-abs(PC2)) <= 4)
vscale <- 0.9 * max(abs(scores[, c("PC1", "PC2")])) / max(abs(pca_r$rotation[, 1:2]))
vecs <- data.frame(var = rownames(pca_r$rotation), vscale * pca_r$rotation[, 1:2])
pve <- round(100 * pca_r$sdev^2 / sum(pca_r$sdev^2))

ggplot(scores, aes(PC1, PC2)) +
  geom_hline(yintercept = 0, colour = "grey70") +
  geom_vline(xintercept = 0, colour = "grey70") +
  geom_point(aes(colour = region), size = 2, alpha = 0.7) +
  stat_ellipse(aes(colour = region), level = 0.68, linewidth = 0.6) +
  geom_text_repel(data = extreme, aes(label = country), size = 3.2, max.overlaps = 20) +
  geom_segment(data = vecs, aes(x = 0, y = 0, xend = PC1, yend = PC2),
               arrow = arrow(length = unit(0.2, "cm")), linewidth = 0.8) +
  geom_label_repel(data = vecs, aes(label = var), size = 3.4, fontface = "bold",
                   label.size = NA, fill = alpha("white", 0.7), min.segment.length = 1) +
  coord_equal() +
  labs(x = paste0("PC1: better / worse than GDP predicts (", pve[1], "%)"),
       y = paste0("PC2 (", pve[2], "%)"))

## ---- fig-performance
# PC1 of residuals as a "performance relative to income" score
top <- scores |>
  arrange(PC1) |>
  slice(c(1:12, (n() - 11):n())) |>
  mutate(country = factor(country, levels = country),
         side = ifelse(PC1 > 0, "better", "worse"))

ggplot(top, aes(PC1, country, colour = side)) +
  geom_segment(aes(x = 0, xend = PC1, yend = country)) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = c(better = "#1b7837", worse = "#c51b7d")) +
  labs(x = "Residual PC1 score", y = NULL, colour = "Than GDP predicts")
