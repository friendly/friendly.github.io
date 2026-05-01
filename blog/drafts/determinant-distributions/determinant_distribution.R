# Distribution of Determinants of 3x3 Matrices from 1:9
# ========================================================

library(ggplot2)
library(dplyr)

# Function to compute determinant from a vector of 9 numbers
det_from_vec <- function(v) {
  M <- matrix(v, nrow = 3, ncol = 3, byrow = TRUE)
  det(M)
}

# ========================================================
# EXACT SOLUTION: All 9! = 362,880 permutations
# ========================================================

cat("Computing exact distribution...\n")
cat("Generating all 9! = 362,880 permutations...\n")

# Generate all permutations using expand.grid approach
# This is memory-efficient for 9! permutations
library(arrangements)  # More efficient for large permutations

# If arrangements package is not available, use base R
if (!requireNamespace("arrangements", quietly = TRUE)) {
  cat("Using base R permutation generation...\n")
  # For base R, we'll use a different approach
  # Generate all permutations iteratively
  n_perms <- factorial(9)
  determinants_exact <- numeric(n_perms)
  
  # Use combinat or gtools if available, otherwise sample approach
  if (requireNamespace("gtools", quietly = TRUE)) {
    all_perms <- gtools::permutations(9, 9, 1:9)
    determinants_exact <- apply(all_perms, 1, det_from_vec)
  } else {
    cat("For exact solution, install 'arrangements' or 'gtools' package\n")
    cat("install.packages('arrangements')\n")
    cat("Proceeding with permutation approach only...\n")
    determinants_exact <- NULL
  }
} else {
  # Use arrangements package (more efficient)
  all_perms <- arrangements::permutations(1:9, k = 9)
  determinants_exact <- apply(all_perms, 1, det_from_vec)
}

# ========================================================
# PERMUTATION DISTRIBUTION: Random sampling
# ========================================================

cat("\nGenerating random permutation distribution...\n")

B <- 100000  # Number of random permutations
set.seed(42)  # For reproducibility

determinants_random <- replicate(B, {
  v <- sample(1:9, 9, replace = FALSE)
  det_from_vec(v)
})

# ========================================================
# ANALYSIS AND SUMMARY STATISTICS
# ========================================================

cat("\n========================================\n")
cat("SUMMARY STATISTICS\n")
cat("========================================\n")

if (!is.null(determinants_exact)) {
  cat("\nEXACT SOLUTION (all 9! permutations):\n")
  cat(sprintf("  Total permutations: %d\n", length(determinants_exact)))
  cat(sprintf("  Range: [%.1f, %.1f]\n", 
              min(determinants_exact), max(determinants_exact)))
  cat(sprintf("  Mean: %.2f\n", mean(determinants_exact)))
  cat(sprintf("  Median: %.2f\n", median(determinants_exact)))
  cat(sprintf("  SD: %.2f\n", sd(determinants_exact)))
  cat(sprintf("  Unique values: %d\n", length(unique(determinants_exact))))
  
  # Check for zero determinants
  n_zero <- sum(determinants_exact == 0)
  cat(sprintf("  Zero determinants: %d (%.2f%%)\n", 
              n_zero, 100 * n_zero / length(determinants_exact)))
}

cat("\nRANDOM PERMUTATION SAMPLE (B =", B, "):\n")
cat(sprintf("  Range: [%.1f, %.1f]\n", 
            min(determinants_random), max(determinants_random)))
cat(sprintf("  Mean: %.2f\n", mean(determinants_random)))
cat(sprintf("  Median: %.2f\n", median(determinants_random)))
cat(sprintf("  SD: %.2f\n", sd(determinants_random)))
cat(sprintf("  Unique values: %d\n", length(unique(determinants_random))))

# ========================================================
# VISUALIZATION
# ========================================================

cat("\nCreating visualizations...\n")

# Prepare data for plotting
if (!is.null(determinants_exact)) {
  df_exact <- data.frame(
    determinant = determinants_exact,
    method = "Exact (all 9! permutations)"
  )
  
  df_random <- data.frame(
    determinant = determinants_random,
    method = paste0("Random sample (B = ", format(B, big.mark = ","), ")")
  )
  
  df_combined <- rbind(df_exact, df_random)
  
  # Plot 1: Comparison of both methods
  p1 <- ggplot(df_combined, aes(x = determinant, fill = method)) +
    geom_histogram(aes(y = after_stat(density)), 
                   bins = 100, alpha = 0.3, position = "identity") +
    geom_density(aes(color = method), linewidth = 1, fill = NA, alpha = 0.5) +
    scale_fill_manual(values = c("#3498db", "#e74c3c")) +
    scale_color_manual(values = c("#2c3e50", "#c0392b")) +
    labs(
      title = "Distribution of Determinants of 3×3 Matrices from {1,2,...,9}",
      subtitle = "Each matrix uses digits 1-9 exactly once",
      x = "Determinant",
      y = "Density",
      fill = "Method",
      color = "Method"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    )
  
  print(p1)
  ggsave("determinant_distribution_comparison.png", p1, 
         width = 10, height = 6, dpi = 300)
  
  # Plot 2: Exact solution only (more detailed)
  p2 <- ggplot(df_exact, aes(x = determinant)) +
    geom_histogram(aes(y = after_stat(density)), 
                   bins = 120, fill = "#3498db", alpha = 0.5) +
    geom_density(color = "#2c3e50", linewidth = 1.2) +
    labs(
      title = "Exact Distribution: All 362,880 Permutations",
      subtitle = "Determinants of 3×3 matrices using digits 1-9 once each",
      x = "Determinant",
      y = "Density"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    )
  
  print(p2)
  ggsave("determinant_distribution_exact.png", p2, 
         width = 10, height = 6, dpi = 300)
  
} else {
  # Only random permutation plot
  df_random <- data.frame(determinant = determinants_random)
  
  p <- ggplot(df_random, aes(x = determinant)) +
    geom_histogram(aes(y = after_stat(density)), 
                   bins = 100, fill = "#e74c3c", alpha = 0.7) +
    geom_density(color = "#c0392b", linewidth = 1.2) +
    labs(
      title = "Distribution of Determinants (Random Permutation Sample)",
      subtitle = paste0("B = ", format(B, big.mark = ","), 
                       " random 3×3 matrices using digits 1-9 once each"),
      x = "Determinant",
      y = "Density"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    )
  
  print(p)
  ggsave("determinant_distribution_random.png", p, 
         width = 10, height = 6, dpi = 300)
}

# ========================================================
# Additional Analysis: Distribution Properties
# ========================================================

if (!is.null(determinants_exact)) {
  cat("\n========================================\n")
  cat("DISTRIBUTION PROPERTIES\n")
  cat("========================================\n")
  
  # Quartiles
  cat("\nQuartiles (exact):\n")
  print(quantile(determinants_exact, probs = c(0, 0.25, 0.5, 0.75, 1)))
  
  # Most common values
  cat("\nTop 10 most frequent determinant values:\n")
  freq_table <- sort(table(determinants_exact), decreasing = TRUE)
  print(head(freq_table, 10))
  
  # Symmetry check
  cat("\nSymmetry check:\n")
  cat(sprintf("  Skewness: %.3f\n", 
              moments::skewness(determinants_exact)))
  cat(sprintf("  (0 = symmetric, >0 = right-skewed, <0 = left-skewed)\n"))
}

cat("\n========================================\n")
cat("Analysis complete!\n")
cat("Plots saved to current directory.\n")
cat("========================================\n")
