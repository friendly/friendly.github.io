# ggfourfold vs. vcd::fourfold: notes from a real use

Michael Friendly, 2026-11-10 (drafted with Claude)

Package: **ggfourfold 0.1.0** (CRAN), compared with `vcd::fourfold()`.

## Update, 2026-11-12: ggfourfold 0.1.1.9000

Thanks! Both fixes work. With `geom_fourfold(labels = "both")` the sides read
"Killer: No", "Killer: Yes", and so on, and the docs now say where the axis titles go.
The `0.1.1.9000` dev version also takes care of point 3 below. The faceted code is now
simpler, with no need to rename `Killer`'s levels:

```r
ff_long <- with(stack(dat[ff_vars]),
                data.frame(Variable  = factor(ind, labels = ff_lab),
                           Predictor = factor(values, labels = c("No", "Yes")),
                           Killer    = fac$Killer))

ggplot(ff_long, aes(x = Predictor, y = Killer)) +
  geom_fourfold(labels = "both") +
  facet_wrap(vars(Variable), nrow = 2) +
  theme_fourfold()
```

Two smaller points remain, both about where the variable names come from.

1. **Faceted long data can't name the variable per panel.** The names come from the
   columns, so with the predictors stacked into one column, every panel says
   "Predictor: No/Yes". What I wanted was "Female: No/Yes", "Financial gain: No/Yes", etc.
   Per-panel level names (`"Female: No"`, ...) don't work either: they need free scales,
   and `facet_wrap()` refuses those with the fixed aspect ratio:

   > `facet_wrap()` can't use free scales with `coord_cartesian()` with a fixed `ratio` argument.

   My workaround is one plot per predictor, combined with **patchwork**:

   ```r
   ff <- setNames(fac[c("Killer", ff_vars)], c("Killer", labels[ff_vars]))
   ff_plots <- lapply(seq_along(ff_vars), function(i)
     ggplot(ff, aes(x = .data[[labels[[ff_vars[i]]]]], y = Killer)) +
       geom_fourfold(labels = "both") +
       labs(title = ff_lab[i]) +
       theme_fourfold())
   wrap_plots(ff_plots, nrow = 2)
   ```

   This looks right, but it loses the Holm adjustment across panels, since each plot is
   adjusted on its own (here the same panels were shaded either way).

   *Suggestion:* let the side names come from the data, e.g. optional `x_name` / `y_name`
   aesthetics (`aes(x = Predictor, y = Killer, x_name = Variable)`), or a labeller-style
   function. Then facets would give both the right labels and the adjustment.

2. **`labs()` doesn't rename the sides.** `aes(A, B) + labs(x = "Gain", y = "Killer")`
   with `labels = "both"` still draws "A: No", "B: Yes". In ggplot2, `labs()` is the usual
   way to rename a variable for display, and `theme_fourfold()` hides the axis titles
   anyway, so using `labs(x =, y =)` (when set) for the names would feel natural. Right now
   the only way is to rename the columns, which needs `.data[[...]]` for names with spaces.

The figure in the post now uses the patchwork version.

---

*Original notes, 2026-11-10:*

## The task

Seven fourfold displays, one for each binary predictor (Female, Employed, Related,
Financial, and three AI guesses) against `Killer`, for 166 characters in the 12 Miss
Marple novels (Lutz, 2026, *Significance*). The data are individual-level: one row per
character, with 0/1 columns. Code: `AgathaChristie.R`, chunk `fig-fourfold`.

## Bottom line

ggfourfold was **easier** than `vcd::fourfold()`, and the result looks better. The one
real gap is that there's no way to show which variable is which.

## The two versions

**vcd**: build a 2 × 2 × 7 array by hand, then plot:

```r
ff <- array(sapply(ff_vars, function(v) xtabs(reformulate(c(v, "Killer")), fac)),
            dim = c(2, 2, length(ff_vars)),
            dimnames = list(Predictor = c("No", "Yes"), Killer = c("No", "Yes"),
                            Variable = sprintf("%s (OR = %.1f)", labels[ff_vars],
                                               uni[labels[ff_vars], "OR"])))
fourfold(ff, mfcol = c(2, 4), std = "margins", conf_level = 0.95, fontsize = 10)
```

**ggfourfold**: stack into long form, then facet:

```r
ff_long <- do.call(rbind, lapply(seq_along(ff_vars), function(i)
  data.frame(Variable = ff_lab[i], Predictor = fac[[ff_vars[i]]],
             Killer = factor(fac$Killer, labels = c("Innocent", "Killer")))))
ff_long$Variable <- factor(ff_long$Variable, levels = ff_lab)

ggplot(ff_long, aes(x = Predictor, y = Killer)) +
  geom_fourfold() +
  facet_wrap(vars(Variable), nrow = 2) +
  theme_fourfold()
```

## What was easier with ggfourfold

- **Data step.** The amount of code is about the same, but long form is the natural shape
  for individual-level data. With vcd, I had to assemble the array and its `dimnames` by hand.
  
- **Layout just worked.** With vcd, my first try (`par(mfrow = c(2, 4))` and a loop)
  drew all seven panels on top of each other, because `fourfold()` uses grid graphics and
  ignores `par()`. Its own `mfrow` argument then filled the panels column by column, so I
  needed `mfcol` to get row order. Even then the panels were small, with a lot of white
  space. `facet_wrap()` filled the page with no extra work.
  
- **Titles.** Facet labels can hold two lines ("Financial gain" / "OR = 51.8"). vcd adds a
  "Variable:" prefix to each panel title.
  
- **Details handled for me.** Counts move out to the corners when the rings reach them,
  Holm adjustment for the shading is the default (as in vcd), and `ggsave()` and Quarto
  needed no special handling.

## Where it was harder

1. **There's no way to show variable names.** `theme_fourfold()` builds on
   `theme_void()`, so there are no axis titles. With No/Yes levels on both variables, a
   reader can't tell which is the predictor and which is `Killer`. vcd labels each side as
   "Killer: No", and so on. My workaround was to rename the `Killer` levels to
   Innocent/Killer and put the predictor's name in the facet title. That works here, but it
   won't always be possible.

2. **Turning axis titles back on misleads.** I tried

   ```r
   labs(x = "Financial gain") + theme(axis.title.x = element_text())
   ```

   The title appears at the bottom, right next to the **y** levels, because the `x` levels
   are drawn on the left/right sides and the `y` levels on top/bottom. A reader would pair
   "Financial gain" with "Killer".

   *Suggestion:* an argument such as `labels = c("levels", "both")`, where `"both"` draws
   "Var: level" on each side, as `label_both` does for facets and as vcd does. At the
   least, the docs should say how `x` and `y` map to the sides of the display.

3. **Minor, versions:** the package was already at 0.1.0 before the CRAN submission. A
   local build from 2026-10-05, before the switch from ticks to the diagonal band, was
   therefore indistinguishable by version from the CRAN release. Using a `0.1.0.9000`-style
   dev version between releases would avoid that.
