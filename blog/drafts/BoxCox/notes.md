# Addendum idea: multivariate Box-Cox transformations for an `mlm`

*Notes started 2026-11-26, from work in heplots. Revised the same day, after the functions
moved from prototypes into the package. For when this comes up again: a worked example of
the post's thesis, with the design decisions that went into it.*

## Next session (left 2026-11-27)

The draft (`index.qmd`) is complete through "What I learned"; all three repos (friendly.github.io,
heplots, mvinfluence) were pushed and clean. `git pull` in each before starting.

- **Render with R 4.6.2** (heplots >= 1.8.7 needed for `bcProfile()`, `Dystrophy`). From a shell:
  `QUARTO_R='C:/R/R-4.6.2/bin/x64/Rscript.exe' quarto render index.qmd`.
- **Draft, to do:**
  - MF editing pass over the whole post.
  - Keep or drop the Diabetes `plot.boxM()` figure (`fig-diab-boxm-plot`); dropping it loses the
    "pooled above every group means shape/orientation differ" point.
  - Place ChatGPT's new image (`figures/box-cox-plot-poster*.png`) in "What other displays might
    please Box & Cox?".
  - Optional closing line from the banner (HTML comment at the end of "What I learned").
  - Before publishing: move to `blog/posts/`, full site render (see CLAUDE.md).
- **heplots** (`issues/TASKS.md`, top of TODOs): `plot.bcProfile()` legend overlaps the Box's M
  contours; per-variable summary (prototype `bc_summary()` / `bc_dotplot()` in this draft);
  profile-vs-slice wording in `?bcProfile`. The `boxM.lm()` fixes (commit `649c87e0`) need
  `R CMD check` before 1.9.0 goes to CRAN.
- **mvinfluence** (`dev/TASKS.md`): `influence(fit, m = 2)` partial matching; `cooks.distance.mlm()`
  / `hatvalues.mlm()` case labels.

Possible title: Box & Cox Come to Multivariate Town

Banner image: A Western movies scene, wide angle, with rows of buildings-- saloon,
barber shop, grocer, ... on opposite sides of the main street. 
Box & Cox (need reference images) are gunslingers, but rather than facing off
against each other, are aiming at a target. The target has contours of the
likelihood, as in what you get from `heplots::bcProfile()`.
There's a young girl with pigtails running from near the target towards
Box & Cox, holding a placard, with $\lambda_1, \lambda_2$ in large blue characters.
Add a horse or carriage, if they can fit in the scene

**Where things are in heplots (v1.8.7, in development):**

- `R/bcProfile.R`: `bcProfile()` (methods for `"powerTransform"` and `"mlm"`), with `plot()`
  and `print()` methods; `bcRefit()`; `bcBoxM()`. All documented on one page, `?bcProfile`.
- `dev/box-cox.md` (the running design notes, in rounds), and the prototypes and demos
  `dev/box-cox-functions.R`, `box-cox-demo.R` (Dystrophy), `box-cox-diabetes.R`,
  `box-cox-tradeoff.R` (normality vs equal covariance).
- New datasets used in the examples: `Dystrophy`, with `SnapBeans` and `Phosphate`, from
  Rencher & Christensen (2012) via the rencher package (`data-raw/Rencher-import.R`).
- NEWS, README (a "Transformations" example) and the pkgdown site all updated.

## Why it fits the post

It is the same story as the rest of "Extending `lm()` to `mlm`", in a small, self-contained
case:

- **The hook.** `car::boxCox()` on an mlm stops with "This function is for univariate
  response only" (as does `MASS::boxcox()`). Another row for the hook table.
- **The estimation already existed.** `car::powerTransform()` handles an mlm and maximizes
  the multivariate likelihood of Andrews, Gnanadesikan & Warner (1971) (Rencher &
  Christensen 2012, eq. 4.43). I checked that it matches a direct `optim()` of (4.43). So
  the gap was not the statistics but the **graphics and the workflow**: no `plot()` method
  for a `powerTransform` object, no easy refit, no before/after comparison. That is the
  post's claim that the hard part is software design, almost exactly. As the help page now
  says: it "stemmed from reading Rencher & Christensen's description of the problem, and the
  recognition that `car::powerTransform()` had already done the heavy lifting".
- **Every object gains a dimension:**

  | Univariate | Multivariate |
  |---|---|
  | λ, a scalar | λ = (λ₁, …, λ_q), a vector |
  | profile log-likelihood ℓ(λ), a curve | a surface over q dimensions; shown as 1-D profiles and 2-D contour plots for pairs |
  | 95% CI for λ, an interval | a confidence **region** for a pair, with the **Wald ellipse** from the inverse Hessian beside the LR region |
  | "is λ = 1 in the interval?" | "how far is (1, …, 1) from the region?", an LR test on q df |
  | transform y | transform each column of Y, and refit |
  | spread-level plot (choose λ to stabilize variance) | choose λ to make the group **covariance matrices** alike (Box's M) |

  "Find the ellipse that shows it" again: the Wald confidence ellipse for (λⱼ, λₖ) is a
  data ellipse for parameters, and comparing it with the exact LR region shows how good
  the quadratic approximation is.

## Design decisions, and why

1. **Build on `powerTransform()`, don't re-estimate.** One internal function,
   `bc_loglik(lambda, pt)`, recomputes the log-likelihood from the pieces a `powerTransform`
   object keeps (`y`, the QR of X). It reproduces car's LR tests exactly, so the plots and
   car's tests can't disagree.

2. **Marginal vs conditional.** `powerTransform(Y)` makes the responses multinormal;
   `powerTransform(mlm)` makes the *residuals* multinormal, which is what MANOVA assumes.
   Use the residual (conditional) version. (A new question that only arises once there's a
   model with several responses.)

3. **One function for 1-D and 2-D** (MF): `bcProfile(pt, variables)` gives a curve for one
   variable and a surface for two. The dimension of the result follows the dimension of the
   question. It accepts a `powerTransform` object or an mlm (and calls `powerTransform()`).

4. **Profile vs slice.** A true profile re-maximizes over the other λs at each grid point (one
   `optim()` per point: ~10 s for a 61 × 61 grid); a slice holds them at the MLE (instant).
   They agree when the λ estimates are uncorrelated (Dystrophy) and differ when they're not
   (Diabetes: `glufast`, `glutest`, correlation 0.40; the slice falls off too fast). So the
   cheap version is only safe when `cov2cor(invHess)` is near diagonal. An instance of
   "know when the multivariate version adds nothing", and when it does. The default is
   `type = "profile"`.

5. **How to draw a likelihood surface** (MF): nested LR regions at several coverage levels,
   each filled with a light, low-alpha colour, so the fill builds up toward the maximum; a
   fine grid so the contours are smooth; the 95% LR contour and the Wald ellipse on top;
   reference lines at "nice" powers (−1, −½, 0, ½, 1, 2).

6. **Show how far "no transformation" is** (MF): `extend_range = TRUE` widens the grid to
   include λ = 1, marks it, annotates its LR test, and adds labelled deviance contours
   between the region and (1, 1). Around the MLE alone, the plot can't show how strongly
   the data reject leaving things alone.

7. **λ in the axis labels** (MF): λ_CK rather than "CK"; the axes are powers, not data.
   And a larger `cex.lab` (1.3) by default, since that's what users end up overriding.

8. **Colours are arguments, and the defaults depend on the plot** (MF). The "λ = 1"
   highlight is bold red in a 1-D plot, but darkorange in the busier 2-D plot, where red
   competes with everything else. To keep red unambiguous, the rounded powers moved to purple
   and Box's M to dark green. Small, but it's the kind of decision that decides whether a
   plot can be read.

9. **Plotmath, not Unicode,** for the "λ = (1): χ²(1) = …" annotation, so it works on every
   device (R CMD check runs examples on `pdf()`, which can't always encode λ or χ²).

10. **Refitting.** `bcRefit(mod, lambda)` keeps the **Box-Cox scaling** (y^λ − 1)/λ (MF), so
    the direction of an effect is preserved when λ < 0. Transformed responses need names
    that are valid in R: `CK^-0.5` isn't, so `CK_m0.5`, `Hpx_2`, `logPK` (MF: OK). The λs
    are kept as an attribute; `lambda` may also be the `powerTransform` object itself (its
    rounded powers are used). A small instance of "return objects that work with the rest
    of the ecosystem": the refit is an ordinary mlm, so `Anova()`, `heplot()`, `cqplot()`,
    `boxM()` all just work.

11. **A truly multivariate criterion: equal covariance matrices** (MF: "a great idea").
    Box-Cox targets normality, but for MANOVA homogeneity of the group covariance matrices
    often matters more. So choose λ to minimize Box's M (invariant to rescaling each
    variable, so no Jacobian). The univariate ancestor is the spread-versus-level plot.
    - Dystrophy: the two criteria agree for Hpx, PK and LD (M is smallest inside their 95%
      LR intervals); only for CK do they disagree: M keeps falling toward −1, beyond the
      interval.
    - Diabetes: the normality transformation already takes M from 397 to 145; minimizing M
      only gets to 138, and sends `relwt` to λ = 6.3, where M is flat, at a large cost in
      normality.
    - Lesson: an optimizer will exploit a flat direction. So **show the criterion as a plot**
      rather than optimize it blindly. `bcProfile(..., group = )` computes M at the same
      full λ vector as the log-likelihood at every grid point; `plot()` draws it on a second
      axis (1-D) or as dashed contours (2-D), and says when its minimum is at the edge of
      the grid ("still falling"). `bcBoxM()`, the optimizer, is kept, with a warning in the
      docs.

12. **One help page, with a grouped See also** (MF). `bcProfile()`, `bcRefit()` and
    `bcBoxM()` are one workflow, so they share `?bcProfile` (not `?bcPower`, which would
    collide with car's topic). The See also is organized by relationship: estimation and
    tests (car); univariate versions (`car::boxCox()`, `MASS::boxcox()`, `symbox()`,
    `spreadLevelPlot()`); checking assumptions before and after (`cqplot()`, `boxM()`,
    `covEllipses()`, `bartlettTests()`, `leveneTests()`); an alternative for heavy tails
    rather than skewness (`robmlm()`); seeing the effects after (`heplot()`, `pairs.mlm()`).
    That grouping is itself a small map of where this sits among multivariate diagnostics.

13. **Scope: positive responses only, for now** (MF). Only the `bcPower` family; the help
    page points to `bcnPower` and `yjPower` in `car::powerTransform()` for zeros and
    negative values. See "Later" below.

## The two examples

- **`heplots::Dystrophy`** (Rencher Table 5.7, from Andrews & Herzberg 1985): four enzymes,
  carriers vs noncarriers, with age and month as covariates. Skewed in *both* directions:
  the ML powers are (CK −0.5, hemopexin 2, PK 0, LD 0). Hemopexin is skewed left, so it
  wants squaring, which "log the skewed ones" misses. After the transformation, Pillai for
  group rises from 0.35 to 0.47, and Box's M p-value goes from < 10⁻²³ to .19: the
  transformation also equalizes the covariance matrices.
- **`heplots::Diabetes`** (Reaven & Miller): five measures, three groups. Strong
  transformations for the glucose measures (≈ −1 and −½). The before/after `covEllipses()`
  plot is the clearest single picture: the overt diabetics' ellipse dwarfs the others in raw
  units, and is much closer in size after Box-Cox, but heterogeneity remains that no power
  transformation can remove. `relwt` needs no transformation at all.

## Next: a `pairs()` method, and what it should leave out

The obvious next step is `pairs()` for all the λs at once: 1-D profiles on the diagonal,
2-D profiles off it. But a pairs plot has to decide **what to show and what to exclude**,
or it just multiplies the clutter of one panel by p². (MF, 2026-11-26: "A pairs method has
to decide what to show and what to exclude to show something useful.") That is a design
story of its own, and another instance of "know when the multivariate version adds
nothing". The questions:

- **Which pairs are worth a 2-D panel?** When two λ estimates are nearly uncorrelated, the
  2-D region is close to the product of the two 1-D intervals: the panel adds nothing the
  diagonal doesn't show. In Dystrophy every correlation is ≤ 0.13; in Diabetes only
  (`glufast`, `glutest`) at 0.40 stands out. So: compute the 2-D profile only where
  |cor| is large, and show something cheaper elsewhere (the Wald ellipse alone, which is
  free from `invHess`, or the correlation as a number).
- **Which variables?** A response whose λ = 1 is well inside its interval (`relwt`) needs no
  transformation; including it adds a row and a column of empty panels. Default to the
  responses that need transforming (LR test of λⱼ = 1), with `variables =` to override.
- **Upper vs lower triangle.** A natural split: normality (the likelihood regions) below the
  diagonal, homogeneity (Box's M contours) above it, on the same pairs of axes, transposed.
  Then agreement or conflict between the criteria is visible pair by pair.
- **Shared axes vs zoom.** A scatterplot matrix uses one range per variable, across its row
  and column. But the range that shows the region well (± a few SEs around the MLE) and the
  range that includes λ = 1 (`extend_range`) can differ by a factor of five; a shared range
  that includes 1 shrinks every region to a dot. Probably: zoom around the MLE, and show
  "how far is 1" on the diagonal only, or as a number.
- **Cost.** Each 2-D profile is one `optim()` per grid point (~10–20 s at 61 × 61); with
  p = 5 that's 10 panels. A slice is instant but misleads exactly when the λs are
  correlated, which is when the 2-D panel matters. So: profile only for the selected
  (correlated) pairs, a coarser grid in small panels, and slices or Wald ellipses for the
  rest.
- **Annotation.** Legends, the λ = 1 text, labelled deviance contours: none of it fits in a
  small panel. One shared legend; numbers on the diagonal only.
- **Is a pairs plot the right display at all?** For most data the useful summary is per
  variable: MLE and interval, rounded power, where Box's M is smallest, whether the two
  agree, and how far λ = 1 is. A compact **dot / interval plot, one row per response**
  (like a forest plot), with the 2-D panels kept for the few correlated pairs, may say more
  than a full p × p matrix. That's the open TODO "summary table per variable" in
  `R/bcProfile.R`.

## Status (2026-11-26)

- In the package (`R/bcProfile.R`), checked with `R CMD check` (0 errors, warnings,
  notes), on the pkgdown site, and in the README.
- Open: the `pairs()` method (above), the per-variable summary display, and other families.
  Whether a `plot()` method for `powerTransform` objects belongs in car rather than heplots
  is still a question for John Fox.
- For the post: probably a short section, or a follow-up post, "Transforming an mlm", with
  two figures: the extended 2-D profile for (CK, Hpx), with (1, 1) far outside, and the
  Diabetes covariance ellipses before and after. The `pairs()` question is a good
  closing paragraph on what a multivariate display should leave out.

## Later: zeros and negative values (MF, 2026-11-26)

A separate story, to tack on: Box-Cox needs positive responses. Zeros (counts, times,
concentrations below detection) and negative values need either a shift (`bcPower` with a
start), car's `bcnPower` (Box-Cox with negatives, Hawkins & Weisberg 2017), or Yeo-Johnson
(`yjPower`; Yeo & Johnson 2000). For an mlm that means a shift or γ per response, another
dimension again. The `?bcProfile` help page now says this and points to those families.
