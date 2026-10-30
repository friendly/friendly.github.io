# Our World in Multivariate Data -- 7. Whole-data views: ordered heatmap, parallel coordinates

if (!exists("cc")) source("R/00-setup.R")

## ---- fig-heatmap
# countries (rows) ordered by GDP, responses (cols) ordered by correlation with GDP
var_ord <- names(sort(cor(Z, cc$logGDP)[, 1], decreasing = TRUE))
Zlong <- data.frame(country = cc$country, logGDP = cc$logGDP, Z) |>
  pivot_longer(all_of(resp), names_to = "response", values_to = "z") |>
  mutate(country = reorder(country, logGDP),
         response = factor(response, levels = var_ord),
         z = pmax(pmin(z, 2.5), -2.5))

ggplot(Zlong, aes(response, country, fill = z)) +
  geom_tile() +
  scale_fill_distiller(palette = "RdBu", direction = 1, limits = c(-2.5, 2.5),
                       name = "z (+ = better)") +
  scale_x_discrete(position = "top") +
  labs(x = NULL, y = "Countries, ordered by GDP per capita") +
  theme(axis.text.y = element_text(size = 5),
        axis.text.x = element_text(angle = 45, hjust = 0),
        panel.grid = element_blank())

## ---- fig-parcoord
Zlong |>
  ggplot(aes(response, z, group = country, colour = logGDP)) +
  geom_line(alpha = 0.5) +
  scale_colour_viridis_c(name = "GDP pc", breaks = 3:5,
                         labels = c("$1k", "$10k", "$100k")) +
  labs(x = NULL, y = "Standardized value (+ = better)") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
