# Our World in Multivariate Data -- trial labelings for the development profiles figure
# (fig-profiles). The labels stacked at the right end are hard to match to the curves,
# because most curves converge at (max GDP, 1). These versions label the curves in the
# middle of the GDP range instead, where they are spread out.

if (!exists("profiles")) source("R/01-profiles.R")

dollar_log <- scale_x_continuous(breaks = 3:5, labels = c("$1,000", "$10,000", "$100,000"))

base <- ggplot(profiles, aes(logGDP, fit, colour = response)) +
  geom_line(linewidth = 1.1) +
  dollar_log +
  labs(x = "GDP per capita (log scale)",
       y = "Fitted level (0 = poorest, 1 = richest)") +
  theme(legend.position = "none")

# value of each curve at the grid point nearest a given log GDP
at_gdp <- function(x) {
  profiles |>
    group_by(response) |>
    slice_min(abs(logGDP - x), n = 1, with_ties = FALSE) |>
    ungroup()
}

## ---- version A: all labels at $10,000, right-justified, just left of each curve
labA <- at_gdp(4)
pA <- base +
  geom_point(data = labA, size = 1.5) +
  geom_text_repel(data = labA, aes(label = response), hjust = 1, direction = "y",
                  nudge_x = -0.12, xlim = c(NA, 3.95), segment.colour = "grey60",
                  size = 3.6, min.segment.length = 0, seed = 1)

## ---- version B: each curve labelled where it crosses its own midpoint (0.5)
# This ties the labels to the "development thresholds" read off at height 0.5.
labB <- profiles |>
  group_by(response) |>
  slice(which(fit >= 0.5)[1]) |>
  ungroup()
pB <- base +
  geom_hline(yintercept = 0.5, colour = "grey70", linetype = 2) +
  geom_point(data = labB, size = 1.8) +
  geom_text_repel(data = labB, aes(label = response), hjust = 1, direction = "y",
                  nudge_x = -0.15, nudge_y = 0.0, segment.colour = "grey60",
                  size = 3.6, min.segment.length = 0, seed = 1)

## ---- version C: separated curves labelled in the middle, the central cluster at the right
# Electricity, Doctors and Water are labelled at $10,000 / $25,000 (right-justified, left of the
# curve); the six curves of the middle cluster keep a (shorter) stack of labels at the right.
mid <- c("Electricity", "Doctors", "Water")
labC_mid <- bind_rows(at_gdp(3.55) |> filter(response %in% c("Electricity", "Doctors")),
                      at_gdp(4.55) |> filter(response == "Water"))
labC_end <- profiles |>
  filter(!response %in% mid) |>
  filter(logGDP == max(logGDP))
pC <- base +
  geom_text(data = labC_mid, aes(label = response), hjust = 1, nudge_x = -0.04,
            nudge_y = 0.03, size = 3.8, fontface = "bold") +
  geom_text_repel(data = labC_end, aes(label = response), hjust = 0, nudge_x = 0.08,
                  direction = "y", segment.colour = "grey70", size = 3.6, seed = 1) +
  coord_cartesian(xlim = c(min(OW$logGDP), max(OW$logGDP) + 0.4), clip = "off")

## ---- version A2: as A, with white label boxes so the curves don't run through the text
pA2 <- base +
  geom_point(data = labA, size = 1.8) +
  geom_label_repel(data = labA, aes(label = response), hjust = 1, direction = "y",
                   nudge_x = -0.15, xlim = c(NA, 3.92), box.padding = 0.15,
                   label.padding = 0.12, label.size = NA, fill = alpha("white", 0.85),
                   segment.colour = "grey50", size = 3.8, fontface = "bold",
                   min.segment.length = 0, seed = 1)

## ---- version A3: an evenly spaced, right-aligned column of labels, with leader lines
# Labels in curve order (top to bottom at $10,000), spaced evenly; text right-aligned at x0.
x0 <- 3.72
labA3 <- labA |>
  arrange(desc(fit)) |>
  mutate(ylab = seq(0.80, 0.16, length.out = n()))
pA3 <- base +
  geom_segment(data = labA3, aes(x = x0 + 0.01, y = ylab, xend = logGDP, yend = fit),
               colour = "grey60", linewidth = 0.4) +
  geom_point(data = labA3, size = 1.8) +
  geom_label(data = labA3, aes(x = x0, y = ylab, label = response), hjust = 1,
             label.padding = unit(0.12, "lines"), linewidth = NA,
             fill = alpha("white", 0.85), size = 3.8, fontface = "bold")

pA
pB
pC
pA2
pA3
