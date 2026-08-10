# Ridgeline commit-activity timeline, weighted by files changed instead of
# commit count -- companion to commits-vis.R. Same chart shape and reading,
# different metric: a single big-diff commit (e.g. an image/PDF-heavy commit
# in Vis-MLM-book) counts for a lot more here than in the commit-count
# version, where it's just one commit like any other.
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
library(here)

infile <- here("blog/drafts/tired-horses/data/commit-history.rds")
commits <- readRDS(infile) |>
  filter(repo != "HistData")

# Chrome from the dataviz skill's reference instance (palette.md); categorical
# fill order (slots 1-6) so overlapping ridges stay tellable apart -- this is
# an "adjacent pairs" use (each ridge only really overlaps its neighbors), not
# an all-pairs one, so the full 6 clears the CVD gate.
#
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

# Weekly files-changed total per repo (sum, not count), with explicit zeros
# for silent weeks -- a missing row and a zero-activity week must look
# different (a real gap, not a hole in the data).
weekly <- commits %>%
  mutate(week_start = as.Date(week_start)) %>%
  group_by(repo, week_start) %>%
  summarise(n = sum(files_changed), .groups = "drop")

all_weeks <- seq(min(weekly$week_start), max(weekly$week_start), by = "week")

weekly <- weekly %>%
  complete(repo = row_order, week_start = all_weeks, fill = list(n = 0))

# Ridge height is normalized per repo (0-1, own max = 1), same reasoning as
# commits-vis.R: raw weekly files-changed totals vary far more here than raw
# commit counts do (a single big commit can dwarf a whole quiet week
# elsewhere), so plotting un-normalized would flatten everything but the one
# tallest spike. The point of a ridgeline here is still *when*, not relative
# volume -- that's carried by the per-row total-files label instead.
#
# Total files changed per repo goes into the row label itself, not a floating
# text layer -- a tall peak can cover an overlaid label, but it can't cover
# the axis. Row colors are keyed to the plain repo name so they still line up
# after the label gets the count appended.
#
totals <- commits %>% group_by(repo) %>% summarise(total = sum(files_changed), .groups = "drop")
total_by_repo <- setNames(totals$total[match(row_order, totals$repo)], row_order)

# Plain element_text (not ggtext::element_markdown -- see commits-vis.R for
# why: ggtext 0.1.2 silently drops the markdown class under ggplot2 4.0's
# theme-element rewrite). Indentation alone carries the hierarchy: top-level
# flush left, nested packages indented under their parent project.
row_labels <- setNames(vapply(row_order, function(r) {
  label <- paste0(short_name[[r]], "  (", format(total_by_repo[[r]], big.mark = ","), ")")
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
  # alpha < 1 on fill only (outline stays solid) so overlap between adjacent
  # rows reads as a blend instead of one ridge silently occluding the other.
  geom_ridgeline(scale = 1.4, color = surface, linewidth = 0.5, alpha = 0.7) +
  scale_fill_manual(values = row_fill, guide = "none") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y", expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_discrete(expand = expansion(add = c(0.3, 1.1))) +
  labs(
    title = "All the Wild Repos, by Files Touched",
    subtitle = "Weekly files-changed volume, 2025-09-01 to present -- grouped by project",
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

outfile <- here("blog/drafts/tired-horses/figures/commits-ridgeline-files.png")
dir.create(dirname(outfile), showWarnings = FALSE)
ggsave(outfile, p, width = 9, height = 7, dpi = 150, bg = surface)

message("Saved ", outfile)
print(p)
