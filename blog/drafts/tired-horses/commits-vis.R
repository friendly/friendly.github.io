# Ridgeline commit-activity timeline (superseded "option B" small-multiples --
# same underlying idea, one row per project on a shared week axis, but drawn
# as overlapping ridges instead of separate panels).
#
# HistData is excluded: only active at the very start and very end of the
# window, not part of the ongoing juggling act this chart is about. Row order
# is thematic, not chronological: heplots and candisc feed into Vis-MLM-book;
# vcdExtra work follows from teaching psy6136; friendly.github.io (the blog)
# sits apart, commenting on all of it.
#
# Reads data/commit-history.rds (from pull-commit-history.R).

library(dplyr)
library(tidyr)
library(ggplot2)
library(ggridges)

commits <- readRDS("data/commit-history.rds") %>%
  filter(repo != "HistData")

# Chrome from the dataviz skill's reference instance (palette.md); categorical
# fill order (slots 1-6) so overlapping ridges stay tellable apart -- this is
# an "adjacent pairs" use (each ridge only really overlaps its neighbors), not
# an all-pairs one, so the full 6 clears the CVD gate.
row_order <- c("Vis-MLM-book", "heplots", "candisc", "psy6136", "vcdExtra", "friendly.github.io")
row_fill  <- c("#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300")
names(row_fill) <- row_order

# Two top-level projects (book, course) plus the blog, which sits apart from
# both; heplots/candisc nest under Vis-MLM-book, vcdExtra nests under psy6136.
top_level   <- c("Vis-MLM-book", "psy6136", "friendly.github.io")
short_name  <- c("Vis-MLM-book" = "Vis-MLM", "heplots" = "heplots", "candisc" = "candisc",
                  "psy6136" = "psy6136", "vcdExtra" = "vcdExtra",
                  "friendly.github.io" = "friendly.github.io")

ink_primary <- "#0b0b0b"
ink_muted   <- "#898781"
grid_line   <- "#e1e0d9"
surface     <- "#fcfcfb"

# Weekly commit count per repo, with explicit zeros for silent weeks -- a
# missing row and a zero-commit week must look different (a real gap, not a
# hole in the data).
weekly <- commits %>%
  mutate(week_start = as.Date(week_start)) %>%
  count(repo, week_start, name = "n")

all_weeks <- seq(min(weekly$week_start), max(weekly$week_start), by = "week")

weekly <- weekly %>%
  complete(repo = row_order, week_start = all_weeks, fill = list(n = 0))

# Ridge height is normalized per repo (0-1, own max = 1): raw counts range
# from ~20/week (heplots) to ~70/week (vcdExtra, Vis-MLM-book), and plotting
# those directly would flatten the quieter projects to invisible slivers.
# The point of a ridgeline here is *when*, not relative volume -- that's
# still carried by the per-row total-commits label, as in the small-multiples
# version.
# Total commits per repo goes into the row label itself, not a floating text
# layer -- a tall peak can cover an overlaid label, but it can't cover the
# axis. Row colors are keyed to the plain repo name so they still line up
# after the label gets the count appended.
totals <- commits %>% count(repo, name = "total")
total_by_repo <- setNames(totals$total[match(row_order, totals$repo)], row_order)

# Plain element_text (not ggtext::element_markdown -- tried it, but ggtext
# 0.1.2 predates ggplot2 4.0's theme-element rewrite and silently drops the
# markdown class whenever the element is merged/inherited, e.g. via
# `theme_minimal() + theme(axis.text.y = element_markdown())`; it rendered
# literal "**...**"/"&nbsp;" instead of parsing them). Plain text preserves
# leading spaces fine, so indentation alone -- no bold -- carries the
# hierarchy: top-level flush left, nested packages indented under their
# parent project.
row_labels <- setNames(vapply(row_order, function(r) {
  label <- paste0(short_name[[r]], "  (", total_by_repo[[r]], ")")
  if (r %in% top_level) label else paste0("    ", label)
}, character(1)), row_order)

weekly <- weekly %>%
  group_by(repo) %>%
  mutate(height = if (max(n) > 0) n / max(n) else 0) %>%
  ungroup() %>%
  mutate(
    fill_key = factor(repo, levels = row_order),
    repo = factor(row_labels[repo], levels = rev(row_labels))  # rev: ggridges plots first level at the bottom
  )

p <- ggplot(weekly, aes(x = week_start, y = repo, height = height, fill = fill_key)) +
  geom_ridgeline(scale = 1.4, color = surface, linewidth = 0.5, alpha = 1) +
  scale_fill_manual(values = row_fill, guide = "none") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y", expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_discrete(expand = expansion(add = c(0.3, 1.1))) +
  labs(
    title = "All the tired repos",
    subtitle = "Weekly commit activity, 2025-09-01 to present -- grouped by which project pulled from which",
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.background   = element_rect(fill = surface, color = NA),
    panel.background  = element_rect(fill = surface, color = NA),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.x = element_line(color = grid_line, linewidth = 0.3),
    axis.text.y       = element_text(color = ink_primary, size = 10, hjust = 0),
    axis.text.x       = element_text(color = ink_muted),
    axis.ticks        = element_blank(),
    plot.title        = element_text(color = ink_primary, face = "bold"),
    plot.subtitle     = element_text(color = ink_muted),
    plot.margin       = margin(t = 10, r = 16, b = 8, l = 8)
  )

dir.create("figures", showWarnings = FALSE)
ggsave("figures/commits-ridgeline.png", p, width = 9, height = 7, dpi = 150, bg = surface)

message("Saved figures/commits-ridgeline.png")
print(p)
