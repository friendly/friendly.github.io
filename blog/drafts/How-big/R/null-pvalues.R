# Simulation: type I error of the four MANOVA tests, using car's F conversions (section 6).
# Draws figures/null-pvalues.png and prints the table. Run from the post folder:
#   Rscript R/null-pvalues.R
# Under H0 (and multivariate normal errors), only the eigenvalues of E^{-1} H matter, and
#   H ~ Wishart_q(df_h, I) (built as Z'Z, since df_h < q is allowed),  E ~ Wishart_q(df_e, I)
# independently, so we can simulate those directly instead of fitting lm()s.
# car:::Pillai(), Wilks(), HL(), Roy() are the functions car::Anova() uses; each takes all q
# eigenvalues, df_h and df_e, and returns c(statistic, F, df1, df2).

library(ggplot2)
set.seed(20261124)
nrep <- 1e5

configs <- data.frame(q = c(5, 2, 5, 5), dfh = c(1, 2, 2, 3), dfe = c(20, 20, 20, 22),
                      label = c("q = 5, df_h = 1", "q = 2, df_h = 2", "q = 5, df_h = 2",
                                "q = 5, df_h = 3 (as in Pottery)"))
tests <- list(Pillai = car:::Pillai, Wilks = car:::Wilks,
              "Hotelling-Lawley" = car:::HL, Roy = car:::Roy)

pvals <- function(q, dfh, dfe) {
  E <- rWishart(nrep, dfe, diag(q))
  out <- matrix(NA_real_, nrep, length(tests), dimnames = list(NULL, names(tests)))
  for (i in seq_len(nrep)) {
    Z <- matrix(rnorm(dfh * q), dfh, q)                  # H = Z'Z, singular when df_h < q
    eig <- Re(eigen(solve(E[, , i], crossprod(Z)), only.values = TRUE)$values)
    eig <- pmax(eig, 0)
    for (t in names(tests)) {
      f <- tests[[t]](eig, dfh, dfe)
      out[i, t] <- pf(f[2], f[3], f[4], lower.tail = FALSE)
    }
  }
  out
}

res <- lapply(seq_len(nrow(configs)), function(k) with(configs[k, ], pvals(q, dfh, dfe)))

tab <- cbind(configs[, 1:3], s = pmin(configs$q, configs$dfh),
             t(sapply(res, function(p) colMeans(p < 0.05))))
print(format(tab, digits = 3), row.names = FALSE)
cat("Monte Carlo SE at .05:", round(sqrt(0.05 * 0.95 / nrep), 4), "\n")
saveRDS(tab, "R/null-pvalues-table.rds")

# Figure: distribution of null p-values for the Pottery-sized case. Should be flat.
p3 <- res[[4]]
d <- data.frame(test = factor(rep(colnames(p3), each = nrep), levels = names(tests)),
                p = as.vector(p3))
rate <- data.frame(test = factor(names(tests), levels = names(tests)),
                   lab = sprintf("p < .05: %.3f", colMeans(p3 < 0.05)))
col <- c(Pillai = "#4C78A8", Wilks = "#54A24B", "Hotelling-Lawley" = "#F58518", Roy = "#E45756")

g <- ggplot(d, aes(p, fill = test)) +
  geom_histogram(aes(y = after_stat(density)), breaks = seq(0, 1, by = 0.05),
                 colour = "white", linewidth = 0.3) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey30") +
  geom_text(data = rate, aes(x = 0.98, y = Inf, label = lab), inherit.aes = FALSE,
            hjust = 1, vjust = 1.6, size = 3.8, colour = "grey20") +
  facet_wrap(~ test, nrow = 1) +
  scale_fill_manual(values = col, guide = "none") +
  scale_x_continuous(breaks = c(0, 0.5, 1)) +
  labs(x = "p-value when there is no effect", y = "density") +
  theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank(), strip.text = element_text(face = "bold", size = 12))

ragg::agg_png("figures/null-pvalues.png", width = 11, height = 3.6, units = "in", res = 200)
print(g)
invisible(dev.off())
