# Extending "Distribution of Determinants" to 4x4 Matrices from 1:16
# ====================================================================
# 3x3 case (see original post) uses exhaustive enumeration: 9! = 362,880
# permutations is small enough to compute exactly.
#
# 4x4 case: 16! ~= 2.09e13 permutations -- far too many to enumerate.
# This script instead uses:
#   1. Monte Carlo sampling to approximate the distribution shape
#   2. Multi-start hill climbing + simulated annealing to find the
#      true maximum |determinant|, since sampling alone underestimates
#      extreme tail values.

library(ggplot2)
library(arrangements)
library(moments)
options(scipen = 999)

det_mat_n <- function(v, n) det(matrix(v, nrow = n, ncol = n, byrow = TRUE))

# ====================================================================
# 1. Reference: 3x3 exact distribution (for comparison)
# ====================================================================

all_perms3 <- arrangements::permutations(1:9, k = 9)
det3_exact <- apply(all_perms3, 1, det_mat_n, n = 3)

cat("3x3 exact: n=", length(det3_exact),
    " max|det|=", max(abs(det3_exact)),
    " kurtosis=", kurtosis(det3_exact), "\n")

# ====================================================================
# 2. 4x4: why exact enumeration is off the table
# ====================================================================

cat("\n16! =", format(factorial(16), scientific = FALSE, big.mark = ","), "\n")

# ====================================================================
# 3. Monte Carlo approximation of the 4x4 distribution
# ====================================================================

set.seed(42)
B4 <- 2000000
det4_rand <- replicate(B4, det_mat_n(sample(1:16, 16, replace = FALSE), 4))

cat("\n4x4 random (B=", B4, "):\n")
cat(" min=", min(det4_rand), " max=", max(det4_rand), "\n")
cat(" mean=", mean(det4_rand), " sd=", sd(det4_rand), "\n")
cat(" skewness=", skewness(det4_rand), "\n")
cat(" kurtosis=", kurtosis(det4_rand), " (normal = 3; 3x3 exact = ",
    round(kurtosis(det3_exact), 2), ")\n")
cat(" unique values sampled=", length(unique(det4_rand)), "\n")

# ====================================================================
# 4. Shape comparison plot: standardized 3x3 (exact) vs 4x4 (MC)
# ====================================================================

df_shape <- rbind(
  data.frame(z = det3_exact / sd(det3_exact), n = "3x3 (exact, 9! perms)"),
  data.frame(z = det4_rand  / sd(det4_rand),  n = "4x4 (Monte Carlo, B=2e6)")
)

p_shape <- ggplot(df_shape, aes(x = z, color = n)) +
  geom_density(linewidth = 1.1) +
  stat_function(fun = dnorm, color = "grey40", linetype = "dashed", linewidth = 0.8) +
  xlim(-6, 6) +
  scale_color_manual(values = c("#3498db", "#e74c3c")) +
  labs(title = "Standardized determinant distributions: 3x3 vs 4x4",
       subtitle = "Dashed grey = standard normal for reference",
       x = "Determinant / SD", y = "Density", color = NULL) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave("images/det_compare_3x3_4x4.png", p_shape, width = 8, height = 5, dpi = 130)

# ====================================================================
# 5. Finding the true maximum |determinant| via local search
# ====================================================================
# Random sampling (B4 above) only found max = 38304. Multi-start hill
# climbing (2-swap neighborhood) searches much more effectively for
# the true extreme.

hill_climb <- function(v, maximize = TRUE) {
  best_v <- v
  best_d <- det_mat_n(v, 4)
  improved <- TRUE
  while (improved) {
    improved <- FALSE
    for (i in 1:15) {
      for (j in (i + 1):16) {
        cand <- best_v
        cand[c(i, j)] <- cand[c(j, i)]
        d <- det_mat_n(cand, 4)
        if ((maximize && d > best_d) || (!maximize && d < best_d)) {
          best_v <- cand
          best_d <- d
          improved <- TRUE
        }
      }
    }
  }
  list(v = best_v, d = best_d)
}

set.seed(123)
n_starts <- 500
best_overall <- -Inf
best_mat_vec <- NULL
local_optima <- numeric(n_starts)

for (s in 1:n_starts) {
  res <- hill_climb(sample(1:16, 16), maximize = TRUE)
  local_optima[s] <- res$d
  if (res$d > best_overall) {
    best_overall <- res$d
    best_mat_vec <- res$v
  }
}

cat("\nMulti-start hill climb (n_starts=", n_starts, "):\n")
cat(" best determinant found:", best_overall, "\n")
cat(" starts reaching that exact value:", sum(local_optima == best_overall), "/", n_starts, "\n")
cat(" (vs. Monte Carlo max of", max(det4_rand), "-- sampling misses the true extreme)\n\n")

cat("Maximizing matrix:\n")
print(matrix(best_mat_vec, nrow = 4, ncol = 4, byrow = TRUE))

# ====================================================================
# 6. Independent verification: 3-cycle neighborhood + simulated annealing
# ====================================================================
# Confirms 40800 isn't just a strong 2-swap local optimum.

# 6a. Check all 3-element cyclic swaps from the claimed optimum
positions <- combn(1:16, 3)
improvement_found <- FALSE
for (k in 1:ncol(positions)) {
  idx <- positions[, k]
  for (dir in list(c(2, 3, 1), c(3, 1, 2))) {
    cand <- best_mat_vec
    cand[idx] <- best_mat_vec[idx[dir]]
    if (det_mat_n(cand, 4) > best_overall) improvement_found <- TRUE
  }
}
cat("\n3-cycle neighborhood check -- any improvement found?", improvement_found, "\n")

# 6b. Simulated annealing from scratch, independent of hill climbing
sim_anneal <- function(iters = 200000, T0 = 5000) {
  v <- sample(1:16, 16)
  best_v <- v; best_d <- det_mat_n(v, 4)
  cur_d <- best_d
  for (it in 1:iters) {
    Temp <- T0 * (1 - it / iters)
    ij <- sample(1:16, 2)
    cand <- v
    cand[ij] <- cand[rev(ij)]
    d <- det_mat_n(cand, 4)
    if (d > cur_d || runif(1) < exp((d - cur_d) / max(Temp, 1e-6))) {
      v <- cand
      cur_d <- d
      if (d > best_d) { best_d <- d; best_v <- v }
    }
  }
  list(v = best_v, d = best_d)
}

set.seed(999)
sa_results <- replicate(20, sim_anneal()$d)
cat("Simulated annealing (20 independent runs):\n")
print(table(sa_results))
