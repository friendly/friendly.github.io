# Canonical plot of region differences (Fig 7): which version?

Notes of 2026-10-30, after Gavin Klorfine's notes (`GK-OWIMD-notes.md`, point 1). Gavin's notes are
about the region means in the HE plot (Fig 5). They say the same issue applies to Fig 7, but don't
go into the canonical analysis itself. These notes do. **Status: undecided.** The draft currently
uses version B. The old version A is in `OWIMD-share-old.html`, and `compare-GK.html` shows A and B
side by side.

## The problem

`modR <- lm(Z ~ ns(logGDP, 3) + region)`. `candisc(modR, term = "region")` gets its canonical axes
from the right H (Type II, region adjusted for GDP) and E, but computes the plotted scores from the
raw `Z`, which still contains GDP. Can1 then correlates −0.86 with log GDP, and the plot shows the
income gradient again. So the axes are right but the points are not, and something else is needed
for display.

## Three versions

| | responses for `candisc(lm(. ~ region))` | E | H | % Can1, Can2 | Pillai |
|---|---|---|---|---|---|
| **A** (old) | residuals from `Z ~ ns(logGDP, 3)` (GDP alone) | not modR's | shrunk | 52.8, 33.1 | 1.00 |
| **B** (now in draft) | partial residuals from modR: `Z − X_gdp B_gdp` | = modR's E exactly | between-adjusted-means SSCP | 58.7, 28.4 | 1.58 |
| **C** | modR's own axes (`candisc(modR, "region")`), B's partial residuals projected on them | = modR's E | Type II H from modR | 42.4, 40.2 | 1.33 (modR) |

- **A** removes GDP from the responses only. Region and GDP are related, so the GDP-only fit soaks
  up part of the region effect (Frisch–Waugh–Lovell: you'd have to residualize the region dummies
  too). Its E isn't modR's E either: the largest element difference is 5.3. In effect this is a
  "GDP first, region gets what's left" view, though not exactly the sequential (Type I) test.
- **B** removes the GDP part using modR's own coefficients. Its E is exactly modR's E (to 1e-14),
  and the region means of the scores are the adjusted means. But its H is the plain between-group
  SSCP of the adjusted means, not modR's Type II H, so the axes and percentages differ from C, and
  Pillai (1.58) overstates modR's (1.33).
- **C** is closest to "the model's own canonical analysis". The axes come from modR's H and E, and
  only the plotted points are changed to the partial residuals. Projected adjusted means (Can1,
  Can2): Africa (2.12, −1.49), Asia/Oceania (−0.36, 0.60), Europe (−1.49, −0.35), N. America
  (0.78, 2.14), S. America (1.21, 1.82). There's no ready-made `plot()` for this; it would need
  the scores and vectors drawn by hand, or a candisc object with its `scores` and `means` replaced.

How different are B and C? The cosines between the canonical weight vectors are 0.85 for Can1
and 0.97 for Can2. For A against C they are 0.65 and 0.47. So B is much closer to the model than
A, but it isn't the same.

Note that C's first two dimensions are nearly equal (42% and 40%). The *plane* is well determined,
but the *rotation* within it is not, so how Can1 and Can2 split the variance shouldn't be read too
closely in any version. The structure correlations that `candisc(modR)` prints are computed from
the raw Z (all about −0.75 to −0.93), so they reflect GDP and aren't useful for interpreting C.

## The confounding problem behind all this

The real issue may be less A vs. B vs. C than how far "at the same GDP" is supported by the data.
GDP per capita ranges of the 121 complete-case countries:

| | Africa | Asia/Oceania | Europe | N. America | S. America |
|---|---|---|---|---|---|
| min | \$1,123 | \$1,964 | \$16,155 | \$6,726 | \$14,319 |
| median | \$4,116 | \$16,101 | \$48,965 | \$26,493 | \$19,068 |
| max | \$17,687 | \$139,593 | \$131,338 | \$76,931 | \$83,659 |

Africa and Europe barely overlap: the richest African country (\$17.7k) is about as rich as the
poorest European one (\$16.2k). So the Africa–Europe contrast "at the same GDP" is almost entirely
extrapolation, through the spline and the assumption of parallel curves. And the post already
reports that the slopes are not equal (interaction Pillai 0.66, F(36, 416) = 2.30). With unequal
slopes, adjusted means depend on the GDP value at which they're compared.

So how much of the region effect is "region" and how much is "GDP" is not well identified here.
A puts the shared part with GDP and B and C split it as the model does. Neither is wrong as a
description of its model, but they answer different questions.

## Some things to consider

- Use C, as the canonical analysis that matches the tests reported for modR.
- Show B or C, but say plainly in the text that the Africa–Europe contrast rests on little overlap
  in GDP.
- Keep A, presented as the conservative view (GDP gets all the shared variation), and say so.
- Show the regions' GDP ranges (e.g. a strip plot of log GDP by region) next to the HE plot, so
  readers can see the overlap problem.
- Fit the canonical analysis only where regions overlap (say \$5k to \$40k)? That loses many
  countries.
- Ask John Fox / Georges Monette whether `candisc()` should have an option for scores from
  partial residuals (or adjusted for other terms) when `term` is one term of a larger model.
  The same question applies to `heplot()`'s `factor.means`.

## Code

The comparison scripts are in `compare-GK.qmd` (A vs. B). C isn't in it yet. Its scores are:

```r
X <- model.matrix(modR)
gdp <- grep("ns(logGDP", colnames(X), fixed = TRUE)
Z_adj <- scale(Z - X[, gdp] %*% coef(modR)[gdp, ], scale = FALSE)
canC <- candisc(modR, term = "region")
scC <- Z_adj %*% canC$coeffs.raw[, 1:2]
```
