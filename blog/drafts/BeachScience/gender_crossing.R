
# BS: Crossing the Gender Gap

# Hypothetical logistic curves: Prob(cross) vs age for M & W

#

# Prior assumptions:

# - Both curves decline with age overall (younger cross more)
# - Women cross more than men at younger ages
# - Men cross more than women at older ages
# - Curves cross somewhere around age 55-60
# - Women's curve steeper (stronger age effect)


library(tidyverse)


# -----------------------------------------------------------------------

# 1. Logistic function on the probability scale

# We parameterise directly as a smooth curve via plogis()

# log-odds = a + b * age

# -----------------------------------------------------------------------


# Parameters chosen to match the prior story:

# Women: high prob at 20 (~0.55), low at 80 (~0.12), steeper slope

# Men: lower prob at 20 (~0.30), less steep, ending higher than women at 80 (~0.22)


params <- tribble(

  ~gender, ~intercept, ~slope,

  "Women", 1.10, -0.038,

  "Men", 0.10, -0.018

)


ages <- seq(18, 82, by = 1)


curves <- params |>

  rowwise() |>

  reframe(

    age = ages,

    gender = gender,

    logodds = intercept + slope * age,

    prob = plogis(logodds)

  )


# -----------------------------------------------------------------------

# 2. Simulate observed data points with binomial noise

# -----------------------------------------------------------------------


set.seed(42)

n_per_cell <- 30 # observers per age-group x gender cell


obs_data <- curves |>

  filter(age %in% seq(20, 80, by = 10)) |>

  mutate(

    n = n_per_cell,

    crossers = rbinom(n(), size = n, prob = prob),

    obs_prob = crossers / n,

    se = sqrt(obs_prob * (1 - obs_prob) / n),

    lo = pmax(0, obs_prob - 1.96 * se),

    hi = pmin(1, obs_prob + 1.96 * se)

  )


# -----------------------------------------------------------------------

# 3. Find crossing point of the two curves

# -----------------------------------------------------------------------


crossing_age <- curves |>

  select(age, gender, prob) |>

  pivot_wider(names_from = gender, values_from = prob) |>

  mutate(diff = Women - Men) |>

  filter(diff >= 0) |>

  slice_tail(n = 1) |>

  pull(age)


crossing_prob <- curves |>

  filter(gender == "Women", age == crossing_age) |>

  pull(prob)


# -----------------------------------------------------------------------

# 4. Plot

# -----------------------------------------------------------------------


gender_colours <- c("Women" = "#d6604d", "Men" = "#2166ac")


p <- ggplot(curves, aes(x = age, y = prob, colour = gender)) +


  # Shaded confidence band (approximate)

  geom_ribbon(

    aes(

      ymin = plogis(intercept + slope * age - 0.3),

      ymax = plogis(intercept + slope * age + 0.3),

      fill = gender

    ),

    alpha = 0.12, colour = NA,

    data = curves |> left_join(params, by = "gender")

  ) +


  # Smooth logistic curves

  geom_line(linewidth = 1.2) +


  # Observed data points with error bars

  geom_pointrange(

    data = obs_data,

    aes(y = obs_prob, ymin = lo, ymax = hi),

    size = 0.4, linewidth = 0.7,

    position = position_dodge(width = 1.5)

  ) +


  # Mark the crossing point

  annotate("segment",

           x = crossing_age, xend = crossing_age,

           y = 0, yend = crossing_prob,

           linetype = "dashed", colour = "grey50", linewidth = 0.6

  ) +

  annotate("point",

           x = crossing_age, y = crossing_prob,

           shape = 21, size = 3, fill = "white", colour = "grey30"

  ) +

  annotate("text",

           x = crossing_age + 1.5, y = crossing_prob + 0.03,

           label = paste0("Crossover\n~ age ", crossing_age),

           hjust = 0, size = 3.2, colour = "grey40"

  ) +


  scale_colour_manual(values = gender_colours, name = NULL) +

  scale_fill_manual(values = gender_colours, name = NULL, guide = "none") +

  scale_y_continuous(

    limits = c(0, 0.7),

    labels = scales::percent_format(accuracy = 1),

    breaks = seq(0, 0.7, by = 0.1)

  ) +

  scale_x_continuous(breaks = seq(20, 80, by = 10)) +


  labs(

    title = "Who crosses the gender gap?",

    subtitle = "Hypothetical probability of crossing to the shorter queue, by age and gender\nPoints = simulated observations (n = 30 per cell) with 95% CI",

    x = "Age",

    y = "P(cross to other side)",

    caption = "Beach Science | Hypothetical data — logistic model"

  ) +

  theme_minimal(base_size = 13) +

  theme(

    plot.title = element_text(face = "bold", size = 15),

    plot.subtitle = element_text(colour = "grey40", size = 10),

    plot.caption = element_text(colour = "grey50", size = 8),

    legend.position = c(0.88, 0.88),

    legend.text = element_text(size = 11),

    panel.grid.minor = element_blank()

  )


print(p)

ggsave("beach_science_gender_crossing.png", p, width = 8, height = 5.5, dpi = 150)

message("Saved: beach_science_gender_crossing.png")



