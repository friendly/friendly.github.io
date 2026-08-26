# R script for the "Upon my word" CDA angle (Mosteller & Wallace marker word, Hamilton vs Madison)
#
# Pulls the text via gutenbergr (eBook #18), splits into the 85 essays, tags authorship
# (traditional/M&W consensus: Hamilton, Madison, Disputed, Jay), then runs:
#
# - contingency table + mosaic plot of usage-level x author
# - Poisson -> negative binomial count model, rate per 1000 words, essay length as offset
# - rootogram diagnostic
# - effects plot of estimated rate by author
# - Mosteller-Wallace-style dot plot, one point per essay
#
# Not yet tested in a live R session - check the essay-splitting regex against the actual
# Gutenberg text before trusting the output.

## ------------------------------------------------------------------------
## "Upon my word": a CDA-style analysis of Mosteller & Wallace's marker word
##
## Counts and rates of "upon" in the 85 Federalist essays, by author, with
## the classic mosaic / count-model / effect-plot toolkit.
##
## Text source : Project Gutenberg eBook #18 (public domain)
## Authorship  : traditional consensus, seconded by Mosteller & Wallace (1964)
## Hamilton (51): 1,6-9,11-13,15-17,21-36,59-61,65-85
## Madison (17): 10,14,18-20,37-48 (undisputed)
## Disputed (12): 49-58,62-63 (M&W: all Madison)
## Jay (5): 2-5,64 (excluded from model)
## ------------------------------------------------------------------------

library(tidyverse)
library(gutenbergr)
library(vcd)
library(vcdExtra)
library(MASS) # glm.nb
library(effects)

## ---- 1. Get the text ----------------------------------------------------

fed_raw <- gutenberg_download(18) |>
  pull(text) |>
  paste(collapse = "\n")

## ---- 2. Split into the 85 numbered essays --------------------------------
## Each essay opens with the two-line header "THE FEDERALIST.\nNo. .\n"

blocks <- str_split(fed_raw, "(?=\\nTHE FEDERALIST\\.\\nNo\\. [IVXLC]+\\.\\n)")[[1]]
blocks <- blocks[str_detect(blocks, "^\\nTHE FEDERALIST\\.\\nNo\\. ")]

parse_essay <- function(block) {
  roman <- str_match(block, "No\\. ([IVXLC]+)\\.")[, 2]
  number <- as.integer(as.roman(roman))

  # keep the essay body only: up to (and excluding) the first sign-off,
  # so footnotes appended after "PUBLIUS." don't inflate the word count
  body <- str_extract(block, "(?s)^.*?(?=PUBLIUS\\.)")
  if (is.na(body)) body <- block

  words <- str_extract_all(str_to_lower(body), "[a-z']+")[[1]]

  tibble(no = number,
         n_words = length(words),
         n_upon = sum(words == "upon"))
}

essays <- map_dfr(blocks, parse_essay) |> arrange(no)

## ---- 3. Attach known authorship ------------------------------------------

author_of <- function(n) {
  case_when(
    n %in% c(2, 3, 4, 5, 64) ~ "Jay",
    n %in% c(1, 6:9, 11:13, 15:17, 21:36, 59:61, 65:85) ~ "Hamilton",
    n %in% c(49:58, 62, 63) ~ "Disputed",
    n %in% c(10, 14, 18:20, 37:48) ~ "Madison",
    TRUE ~ NA_character_
  )
}

essays <- essays |>
  mutate(author = factor(author_of(no), levels = c("Hamilton", "Madison", "Disputed", "Jay")),
         rate_1000 = 1000 * n_upon / n_words)

essays_hm <- essays |> # the Hamilton/Madison contrast M&W cared about
  filter(author != "Jay") |>
  mutate(author = fct_drop(author))

## ---- 4. Contingency table + mosaic plot ----------------------------------
## Bin each essay's raw "upon" count into a few usage levels

essays_hm <- essays_hm |>
  mutate(usage = cut(n_upon, breaks = c(-1, 0, 2, Inf),
                      labels = c("none", "1-2", "3+")))

tab <- xtabs(~ author + usage, data = essays_hm)
print(tab)

mosaic(tab, shade = TRUE, legend = TRUE,
       main = '"Upon" usage by author (Federalist Papers)')

## ---- 5. Count model: rate of "upon" per 1000 words, by author ------------
## Poisson first; check dispersion, fall back to negative binomial

m_pois <- glm(n_upon ~ author, family = poisson,
              offset = log(n_words / 1000), data = essays_hm)
summary(m_pois)

disp <- sum(residuals(m_pois, type = "pearson")^2) / df.residual(m_pois)
cat("Poisson dispersion ratio:", round(disp, 2), "\n") # >> 1 -> use NB

m_nb <- glm.nb(n_upon ~ author + offset(log(n_words / 1000)), data = essays_hm)
summary(m_nb)
AIC(m_pois, m_nb)

## ---- 6. Rootogram: does the fitted model reproduce the count shape? ------

rootogram(m_nb, main = 'Fitted vs. observed "upon" counts')

## ---- 7. Effect plot: estimated rate per 1000 words, by author ------------

plot(allEffects(m_nb),
     main = 'Estimated "upon" rate per 1000 words, by author')

## ---- 8. Mosteller-Wallace-style dot plot: one point per essay ------------

ggplot(essays_hm, aes(x = rate_1000, y = fct_rev(author), color = author)) +
  geom_jitter(height = 0.15, size = 2.2, alpha = 0.85) +
  stat_summary(fun = mean, geom = "point", shape = "|", size = 9, color = "black") +
  labs(x = '"upon" occurrences per 1000 words', y = NULL,
       title = 'Federalist Papers: "upon" rate by author',
       subtitle = "Each point = one essay; black bar = author mean") +
  theme_minimal() +
  theme(legend.position = "none")
