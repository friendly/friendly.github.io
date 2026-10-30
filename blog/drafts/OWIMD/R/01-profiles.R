# Our World in Multivariate Data -- 1. From twelve panels to one: development profiles

if (!exists("cc")) source("R/00-setup.R")

## ---- fig-smoothed
# The top two rows of the OWID chart, with a loess smoother added to each panel
panels <- c("ChildMort", "Stillbirth", "MatMort", "Stunting", "Doctors", "LifeExp")
LifeGDP |>
  select(GDP, all_of(panels)) |>
  mutate(across(c(ChildMort, Stillbirth, MatMort), log10)) |>
  pivot_longer(all_of(panels), names_to = "indicator", values_to = "value") |>
  mutate(indicator = factor(indicator, levels = panels)) |>
  ggplot(aes(GDP, value)) +
  geom_point(shape = 1, colour = "navy") +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, colour = "red") +
  scale_x_log10(breaks = c(1e3, 1e4, 1e5), labels = c("$1,000", "$10,000", "$100,000")) +
  facet_wrap(~ indicator, scales = "free_y") +
  labs(x = "GDP per capita (log scale)", y = "Value (log10 for ChildMort, Stillbirth, MatMort)") +
  theme(axis.text.x = element_text(size = 9))

## ---- profiles-fit
# Smooth fit of each (transformed) response on log GDP, using all available countries
# for each response, rescaled to [0, 1] over the observed GDP range:
# 0 = level of the poorest countries, 1 = level of the richest
grid <- data.frame(logGDP = seq(min(OW$logGDP), max(OW$logGDP), length.out = 200))

fit_profiles <- function(data) {
  lapply(resp, \(v) {
    fit <- lm(reformulate("ns(logGDP, 3)", v), data = data)
    yhat <- predict(fit, newdata = grid)
    data.frame(grid, response = v,
               fit = (yhat - min(yhat)) / (max(yhat) - min(yhat)))
  }) |> bind_rows()
}

# "development threshold": GDP where the fitted profile first reaches 10/50/90% of its range
fit_thresholds <- function(profiles) {
  profiles |>
    group_by(response) |>
    summarise(half = logGDP[which(fit >= 0.5)[1]],
              q10  = logGDP[which(fit >= 0.1)[1]],
              q90  = logGDP[which(fit >= 0.9)[1]]) |>
    arrange(half) |>
    mutate(response = factor(response, levels = response))
}

profiles <- fit_profiles(OW)
thresholds <- fit_thresholds(profiles)
profiles$response <- factor(profiles$response, levels = levels(thresholds$response))

# GDP values for inline text, e.g. `r usd(thr50["Water"])`
usd <- function(x) paste0("\\$", format(round(x, -2), big.mark = ",", trim = TRUE))
thr50 <- setNames(10^thresholds$half, thresholds$response)

## ---- profiles-raw
# Same profiles on the original scales (mortality-type outcomes only negated)
OWraw <- LifeGDP |>
  transmute(logGDP = log10(GDP), ChildMort = -ChildMort, Stillbirth = -Stillbirth,
            MatMort = -MatMort, Doctors, LifeExp, SchoolYrs, Electricity, Water, LifeSat)
thresholds_raw <- fit_thresholds(fit_profiles(OWraw))
thr50_raw <- setNames(10^thresholds_raw$half, thresholds_raw$response)

## ---- tbl-thresholds
data.frame(Transformed = usd(thr50), Rank = seq_along(thr50),
           Raw = usd(thr50_raw[names(thr50)]),
           `Raw rank` = match(names(thr50), names(thr50_raw)),
           row.names = names(thr50), check.names = FALSE) |>
  knitr::kable(align = "rrrr")

## ---- fig-profiles
dollar_log <- scale_x_continuous(breaks = 3:5, labels = c("$1,000", "$10,000", "$100,000"))

# label each curve at GDP = $10,000, where the curves are spread out; right-justified
# labels just left of the curve, with white boxes so the curves don't run through the text
lab10k <- profiles |>
  group_by(response) |>
  slice_min(abs(logGDP - 4), n = 1, with_ties = FALSE) |>
  ungroup()

ggplot(profiles, aes(logGDP, fit, colour = response)) +
  geom_line(linewidth = 1.1) +
  geom_point(data = lab10k, size = 1.8) +
  geom_label_repel(data = lab10k, aes(label = response), hjust = 1, direction = "y",
                   nudge_x = -0.15, xlim = c(NA, 3.92), box.padding = 0.15,
                   label.padding = 0.12, label.size = NA, fill = alpha("white", 0.85),
                   segment.colour = "grey50", size = 3.8, fontface = "bold",
                   min.segment.length = 0, seed = 1) +
  dollar_log +
  labs(x = "GDP per capita (log scale)",
       y = "Fitted level (0 = poorest, 1 = richest)") +
  theme(legend.position = "none")

## ---- fig-thresholds
ggplot(thresholds, aes(y = response)) +
  geom_linerange(aes(xmin = q10, xmax = q90), linewidth = 1, colour = "grey60") +
  geom_point(aes(x = half), size = 3, colour = "navy") +
  dollar_log +
  labs(x = "GDP per capita where 10% / 50% / 90% of the range is reached",
       y = NULL)
