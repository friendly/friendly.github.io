library(tidyverse)
library(ggridges)

# Load Zonination's perceptions dataset
probly <- read_csv("https://raw.githubusercontent.com/zonination/perceptions/master/probly.csv")

# Pivot to long, compute median per term, reorder factor by median
prob_long <- probly |>
  pivot_longer(everything(), names_to = "term", values_to = "probability") |>
  filter(!is.na(probability)) |>
  group_by(term) |>
  mutate(med = median(probability)) |>
  ungroup() |>
  mutate(term = fct_reorder(term, med))

term_summary <- prob_long |>
  distinct(term, med)

# Ridgeline plot
ggplot(prob_long, aes(x = probability, y = term, fill = med)) +
  geom_density_ridges(scale = 1.8, rel_min_height = 0.01,
                      colour = "grey30", linewidth = 0.4, alpha = 0.85) +
  geom_point(data = term_summary,
             aes(x = med, y = term),
             colour = "white", size = 1.8, inherit.aes = FALSE) +
  scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#d6604d",
                       midpoint = 50, name = "Median\n(%)") +
  scale_x_continuous(breaks = seq(0, 100, 10),
                     labels = function(x) paste0(x, "%"),
                     limits = c(0, 100)) +
  labs(title = 'How likely is "likely"?',
       subtitle = "Perceived probability of estimative words (n ≈ 46)\nWhite dot = median",
       x = "Assigned probability (%)", y = NULL,
       caption = "Data: Zonination · github.com/zonination/perceptions") +
  theme_ridges(grid = TRUE, center_axis_labels = TRUE) +
  theme(plot.title = element_text(face = "bold", size = 16),
        legend.position = "none")
