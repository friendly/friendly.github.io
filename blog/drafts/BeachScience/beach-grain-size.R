# Here is beach_grain_size.R — ggplot code simulating grain-size distributions (phi scale) for four beach types (fine sand, medium sand, coarse/granule, shingle), plus a Dean equilibrium profile plot. Ready to paste into webRios/RStudio.

library(tidyverse)

# ---- 1. Grain size distributions by beach type -----------------------------
# Phi scale: phi = -log2(D_mm). Natural sediment is log-normal in mm,
# i.e. approximately NORMAL in phi -- so we simulate directly in phi space.
# Folk & Ward (1957) sorting coefficient sigma_phi is just the phi SD.

set.seed(42)

beach_types <- tribble(
  ~beach, ~mean_phi, ~sd_phi, ~n,
  "Fine sand (sheltered bay)", 3.0, 0.30, 20000,
  "Medium sand (open coast)", 1.5, 0.45, 20000,
  "Coarse sand / granule", 0.0, 0.70, 20000,
  "Shingle (high-energy)", -3.0, 0.90, 20000
)

# simulate phi values, convert back to mm for intuitive x-axis
grain_data <- beach_types |>
  rowwise() |>
  reframe(
    beach = beach,
    phi = rnorm(n, mean_phi, sd_phi),
    mm = 2^(-phi)
  )

grain_data$beach <- factor(grain_data$beach, levels = beach_types$beach)

p_phi <- ggplot(grain_data, aes(phi, fill = beach, colour = beach)) +
  geom_density(alpha = 0.35, linewidth = 0.8) +
  scale_x_reverse(name = expression(phi~scale~(phi == -log[2](D[mm])))) +
  labs(
    title = "Grain size distributions across beach types",
    subtitle = "Normal in φ-space ⇒ log-normal in mm (fragmentation theory, Kolmogorov 1941)",
    y = "Density", fill = "Beach type", colour = "Beach type"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

p_phi

# Optional: same data on mm scale (log x) for a more "physical" read
p_mm <- ggplot(grain_data, aes(mm, fill = beach, colour = beach)) +
  geom_density(alpha = 0.35, linewidth = 0.8) +
  scale_x_log10(name = "Grain diameter (mm, log scale)") +
  labs(title = "Same distributions, grain size in mm", y = "Density") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

p_mm

# ---- 2. Summary stats (Folk & Ward style) ----------------------------------
grain_summary <- grain_data |>
  group_by(beach) |>
  summarise(
    mean_phi = mean(phi),
    sigma_phi = sd(phi), # sorting coefficient
    sorting_class = case_when(
      sigma_phi < 0.35 ~ "very well sorted",
      sigma_phi < 0.50 ~ "well sorted",
      sigma_phi < 0.71 ~ "moderately well sorted",
      sigma_phi < 1.00 ~ "moderately sorted",
      TRUE ~ "poorly sorted"
    )
  )

grain_summary

# ---- 3. Dean equilibrium beach profile -------------------------------------
# h(x) = A * x^(2/3), Dean (1977/1991). A depends on grain size (coarser -> steeper).
# A (m^1/3) roughly increases with median grain size; illustrative values below.

dean_profile <- function(x, A) A * x^(2/3)

profile_data <- expand_grid(
  x = seq(0, 200, length.out = 400),
  A = c(0.10, 0.15, 0.21) # fine, medium, coarse -- illustrative A values
) |>
  mutate(
    depth = -dean_profile(x, A),
    grain = factor(A, labels = c("Fine sand (A=0.10)",
                                  "Medium sand (A=0.15)",
                                  "Coarse sand (A=0.21)"))
  )

p_dean <- ggplot(profile_data, aes(x, depth, colour = grain)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Dean equilibrium beach profile",
    subtitle = expression(h(x) == A ~ x^{2/3}),
    x = "Distance offshore (m)", y = "Depth below MSL (m)", colour = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

p_dean

# ---- Save for the blog ------------------------------------------------------
# ggsave("grain_size_phi.png", p_phi, width = 7, height = 5, dpi = 300)
# ggsave("grain_size_mm.png", p_mm, width = 7, height = 5, dpi = 300)
# ggsave("dean_profile.png", p_dean, width = 7, height = 5, dpi = 300)
