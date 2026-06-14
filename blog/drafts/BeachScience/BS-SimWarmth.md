BS: Simulating Warmth Term Ratings — How It Works


One of the great advantages of Beach Science is that you can do the statistics without leaving your towel. No ethics board, no recruitment drive, no clipboards. Just a simulation that captures the essential structure of the data you would collect if you were so inclined.


---


THE CORE IDEA


We want to model what happens when 200 people are each asked to assign a temperature in °C to 25 words — from freezing to broiling. The real study would take weeks to run. The simulation takes seconds, and lets us explore the statistical structure before committing to anything.


The key insight is that not all words are equally precise. Freezing is anchored — nearly everyone agrees it means something near 0°C. Mild is a vessel — people pour their own thermal history into it. The simulation models this explicitly.


---


THE TERMS AND THEIR PARAMETERS


Each term is assigned two numbers:


mean_temp — the consensus central temperature in °C, from ~0°C (Freezing) to ~46°C (Broiling).


precision — a weight from 0 (maximally vague) to 1 (maximally anchored). Freezing gets 0.9; Mild and Comfortable get 0.35. This is the most debatable part of the setup — and deliberately so.


---


THE VARIANCE MODEL


sd = (1 - precision) × (3 + √mean_temp × 0.8)


Combines mean-scaling (hotter terms slightly more variable) with a precision override (anchored terms stay tight regardless of mean).


---


THE ERROR DISTRIBUTION


Ratings drawn from t(4) — heavier tails than normal. The Finn who calls 15°C warm, the Senegalese respondent for whom mild starts at 28°C. The tails are where the interesting individual differences live.


---


INDIVIDUAL DIFFERENCES


- Geographic origin (northern/temperate/southern): ~3°C shift across all ratings

- Acclimatisation (0-14 days): each beach day adds ~0.15°C to warmth perception


---


SIMULATION AS EXPLORATION


There is another reason to simulate before collecting data that does not get mentioned enough: it lets you play with the assumptions.


What if the t distribution has 2 degrees of freedom instead of 4 — fatter tails, more extreme outliers? Change one number and rerun. What if geographic origin shifts ratings by 6°C rather than 3°C? What if acclimatisation matters twice as much as we assumed? Each of these is a one-line edit followed by a replot.


This is the what-if machine. You can explore the space of plausible worlds before committing to data collection in any of them. And crucially, when real data eventually arrives, you already have an intuition for what the results should look like — which means surprises are actually informative rather than just confusing.


Statisticians call this a prior predictive check. Beach Scientists call it an afternoon well spent.


---


WHAT THIS ISN'T


The simulation assumes the precision weights and mean temperatures we gave it. A real study would estimate these from data. Maybe lukewarm is more anchored than we think. Maybe warm is more contested than mild.


The simulation is a prior. The study would be the update. That is, more or less, what Bayesian statistics is. And you can think about all of this lying on a beach towel, which is the point.


---


== R SCRIPT (beach_science_warmth_sim.R) ==


Packages: tidyverse, ggridges, ggrepel, scales


# BS: Simulation of warmth term temperature ratings

library(tidyverse)

library(ggridges)

library(scales)


set.seed(1234)


terms <- tribble(

~term, ~mean_temp, ~precision,

"Freezing", 0, 0.9,

"Frigid", 2, 0.8,

"Icy", 3, 0.85,

"Bitter", 4, 0.75,

"Raw", 7, 0.6,

"Chilly", 10, 0.7,

"Cool", 14, 0.6,

"Crisp", 13, 0.55,

"Fresh", 15, 0.4,

"Mild", 18, 0.35,

"Temperate", 19, 0.45,

"Comfortable", 21, 0.35,

"Pleasant", 22, 0.35,

"Neutral", 20, 0.5,

"Lukewarm", 30, 0.6,

"Tepid", 28, 0.55,

"Warm", 24, 0.4,

"Balmy", 26, 0.45,

"Toasty", 28, 0.55,

"Sultry", 32, 0.5,

"Hot", 35, 0.75,

"Sweltering", 38, 0.7,

"Scorching", 42, 0.85,

"Blistering", 44, 0.8,

"Broiling", 46, 0.85

)


n_subjects <- 200


subjects <- tibble(

id = 1:n_subjects,

origin = sample(c("northern", "southern", "temperate"),

n_subjects, replace = TRUE, prob = c(0.3, 0.3, 0.4)),

acclim_days = sample(0:14, n_subjects, replace = TRUE)

) |>

mutate(

origin_shift = case_when(

origin == "northern" ~ rnorm(n(), -3, 1),

origin == "southern" ~ rnorm(n(), 3, 1),

TRUE ~ rnorm(n(), 0, 1)

),

acclim_shift = acclim_days * 0.15

)


sim_data <- crossing(subjects, terms) |>

mutate(

term_sd = (1 - precision) * (3 + sqrt(mean_temp) * 0.8),

error = rt(n(), df = 4) * term_sd,

rating = mean_temp + origin_shift + acclim_shift * 0.3 + error,

rating = pmax(-10, pmin(60, rating))

)


term_summary <- sim_data |>

group_by(term, mean_temp, precision) |>

summarise(med = median(rating), mn = mean(rating),

sd = sd(rating), .groups = "drop")


sim_data <- sim_data |>

mutate(term = fct_reorder(term, rating, .fun = median))


# Ridgeline plot

p_ridge <- ggplot(sim_data, aes(x = rating, y = term, fill = mean_temp)) +

geom_density_ridges(scale = 1.8, rel_min_height = 0.01,

colour = "white", linewidth = 0.3, alpha = 0.85) +

geom_point(data = term_summary, aes(x = med, y = term),

colour = "white", size = 1.8, inherit.aes = FALSE) +

scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#d6604d",

midpoint = 22, name = "Mean\ntemp (°C)") +

scale_x_continuous(breaks = seq(-10, 60, 10),

labels = function(x) paste0(x, "°")) +

labs(title = 'How warm is "warm"?',

subtitle = "Simulated ratings for 25 warmth terms (n = 200)\nWhite dot = median",

x = "Assigned temperature (°C)", y = NULL,

caption = "Beach Science | t(4) errors, variance scaled by precision") +

theme_ridges(grid = TRUE, center_axis_labels = TRUE) +

theme(plot.title = element_text(face = "bold", size = 16))


# Precision vs spread

p_precision <- ggplot(term_summary, aes(x = mean_temp, y = sd)) +

geom_point(aes(colour = precision), size = 3) +

geom_smooth(method = "loess", se = FALSE, colour = "grey60",

linewidth = 0.7, linetype = "dashed") +

ggrepel::geom_text_repel(aes(label = term), size = 3, max.overlaps = 20) +

scale_colour_gradient(low = "#d6604d", high = "#2166ac",

name = "Precision\n(1 = anchored)") +

labs(title = "Term precision vs. observed spread",

x = "Mean temperature (°C)", y = "SD of ratings (°C)") +

theme_minimal(base_size = 12)


# Origin facets

origin_summary <- sim_data |>

filter(term %in% c("Mild", "Warm", "Comfortable", "Chilly", "Hot")) |>

group_by(term, origin) |> summarise(med = median(rating), .groups = "drop")


p_origin <- ggplot(

sim_data |> filter(term %in% c("Mild", "Warm", "Comfortable", "Chilly", "Hot")),

aes(x = rating, fill = origin)) +

geom_density(alpha = 0.5, colour = NA) +

geom_vline(data = origin_summary, aes(xintercept = med, colour = origin),

linewidth = 0.8, linetype = "dashed") +

facet_wrap(~term, ncol = 1, scales = "free_y") +

scale_fill_brewer(palette = "Set2", name = "Origin") +

scale_colour_brewer(palette = "Set2", guide = "none") +

labs(title = "Geographic origin shifts warmth perception",

x = "Assigned temperature (°C)", y = "Density") +

theme_minimal(base_size = 11) +

theme(strip.text = element_text(face = "italic"), legend.position = "bottom")


ggsave("warmth_terms_ridgeline.png", p_ridge, width = 10, height = 12, dpi = 150)

ggsave("warmth_terms_precision.png", p_precision, width = 8, height = 6, dpi = 150)

ggsave("warmth_terms_origin.png", p_origin, width = 6, height = 10, dpi = 150)


message("Done. Three figures saved.")


