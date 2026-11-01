# Our World in Multivariate Data -- 1c. Bump chart of the 50% thresholds on the transformed and
# original scales, as an alternative to the table of thresholds

if (!exists("thresholds_raw")) source("R/01-profiles.R")

## ---- fig-thresholds-bump
usd_plain <- function(x) paste0("$", format(round(x, -2), big.mark = ",", trim = TRUE))

ranks <- data.frame(response = names(thr50), rank1 = seq_along(thr50), gdp1 = thr50) |>
  inner_join(data.frame(response = names(thr50_raw), rank2 = seq_along(thr50_raw), gdp2 = thr50_raw),
             by = "response") |>
  mutate(response = factor(response, levels = names(thr50)))

# S-shaped curve joining each outcome's two ranks (ggbump isn't on CRAN)
curves <- ranks |>
  reframe(x = seq(1, 2, length.out = 100), .by = c(response, rank1, rank2)) |>
  mutate(rank = rank1 + (rank2 - rank1) * plogis(10 * (x - 1.5)))

ggplot(ranks, aes(colour = response)) +
  geom_line(data = curves, aes(x, rank), linewidth = 1.1) +
  geom_point(aes(1, rank1), size = 3.5) +
  geom_point(aes(2, rank2), size = 3.5) +
  geom_text(aes(1, rank1, label = paste0(response, "  ", usd_plain(gdp1))), hjust = 1,
            nudge_x = -0.05, size = 3.8, fontface = "bold") +
  geom_text(aes(2, rank2, label = paste0(usd_plain(gdp2), "  ", response)), hjust = 0,
            nudge_x = 0.05, size = 3.8, fontface = "bold") +
  scale_x_continuous(breaks = 1:2, labels = c("Transformed scales", "Original scales"),
                     position = "top", limits = c(0.45, 2.55), expand = c(0, 0)) +
  scale_y_reverse(breaks = 1:9) +
  labs(x = NULL, y = "Order of reaching half the range (1 = earliest)") +
  theme(legend.position = "none", panel.grid = element_blank(), panel.border = element_blank(),
        axis.ticks = element_blank(), axis.text.x.top = element_text(face = "bold", size = 13))
