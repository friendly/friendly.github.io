# Addendum idea: multivariate Box-Cox transformations for an `mlm`

*Notes started 2026-11-26, from work in heplots (`dev/box-cox.md`, `dev/box-cox-functions.R`,
`dev/box-cox-demo.R`, `dev/box-cox-diabetes.R`). For when this comes up again: a worked
example of the post's thesis, with the design decisions that went into it.*

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
  post's claim that the hard part is software design, almost exactly.
- **Every object gains a dimension:**

  | Univariate | Multivariate |
  |---|---|
  | λ, a scalar | λ = (λ₁, …, λ_q), a vector |
  | profile log-likelihood ℓ(λ), a curve | a surface over q dimensions; shown as 1-D profiles and 2-D contour plots for pairs |
  | 95% CI for λ, an interval | a confidence **region** for a pair, with the **Wald ellipse** from the inverse Hessian beside the LR region |
  | "is λ = 1 in the interval?" | "how far is (1, …, 1) from the region?", an LR test on q df |
  | transform y | transform each column of Y, and refit |

  "Find the ellipse that shows it" again: the Wald confidence ellipse for (λⱼ, λₖ) is a
  data ellipse for parameters, and comparing it with the exact LR region shows how good
  the quadratic approximation is.

## Design decisions, and why

1. **Build on `powerTransform()`, don't re-estimate.** One function, `bc_loglik(lambda, pt)`,
   recomputes the log-likelihood from the pieces a `powerTransform` object keeps (`y`, the QR
   of X). It reproduces car's LR tests exactly, so the plots and car's tests can't disagree.

2. **Marginal vs conditional.** `powerTransform(Y)` makes the responses multinormal;
   `powerTransform(mlm)` makes the *residuals* multinormal, which is what MANOVA assumes.
   Use the residual (conditional) version. (A new question that only arises once there's a
   model with several responses.)

3. **One function for 1-D and 2-D** (MF): `bc_profile(pt, variables)` gives a curve for one
   variable and a surface for two. The dimension of the result follows the dimension of the
   question.

4. **Profile vs slice.** A true profile re-maximizes over the other λs at each grid point (one
   `optim()` per point: ~10 s for a 61 × 61 grid); a slice holds them at the MLE (instant).
   They agree when the λ estimates are uncorrelated (Dystrophy) and differ when they're not
   (Diabetes: `glufast`, `glutest`, correlation 0.40; the slice falls off too fast). So the
   cheap version is only safe when `cov2cor(invHess)` is near diagonal. An instance of
   "know when the multivariate version adds nothing", and when it does.

5. **How to draw a likelihood surface** (MF): nested LR regions at several coverage levels,
   each filled with a light, low-alpha colour, so the fill builds up toward the maximum; a
   fine grid so the contours are smooth; the 95% LR contour and the Wald ellipse on top;
   reference lines at "nice" powers (−1, −½, 0, ½, 1, 2).

6. **Show how far "no transformation" is** (MF): `extend_range = TRUE` widens the grid to
   include λ = 1, marks it, annotates its LR test, and adds labelled deviance contours
   between the region and (1, 1). Around the MLE alone, the plot can't show how strongly
   the data reject leaving things alone.

7. **λ in the axis labels** (MF): λ_CK rather than "CK"; the axes are powers, not data.

8. **Refitting.** `bc_refit(mod, lambda)` keeps the **Box-Cox scaling** (y^λ − 1)/λ (MF), so
   the direction of an effect is preserved when λ < 0. Transformed responses need names that
   are valid in R: `CK^-0.5` isn't, so `CK_m0.5`, `Hpx_2`, `logPK` (MF: OK). The λs are
   kept as an attribute. A small instance of "return objects that work with the rest of the
   ecosystem": the refit is an ordinary mlm, so `Anova()`, `heplot()`, `cqplot()`,
   `boxM()` all just work.

9. **A truly multivariate criterion: equal covariance matrices** (MF: "a great idea").
   Box-Cox targets normality, but for MANOVA homogeneity of the group covariance matrices
   often matters more. So choose λ to minimize Box's M (invariant to rescaling each
   variable, so no Jacobian). The univariate ancestor is Tukey's spread-versus-level plot.
   - Dystrophy: the two criteria agree in direction; minimizing M pushes CK further
     (toward −1).
   - Diabetes: the normality transformation already takes M from 397 to 145; minimizing M
     only gets to 138, and sends `relwt` to λ = 6.3, where M is flat, at a large cost in
     normality.
   - Lesson: an optimizer will exploit a flat direction. Show the criterion as a **plot**
     against each λ, beside the likelihood profile, rather than optimize it blindly. The
     trade-off between normality and homogeneity is the interesting display.

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
  transformation can remove.

## Status and open questions (2026-11-26)

- Prototypes only, in heplots `dev/`. Not yet in the package.
- Open: a 1-D plot with both criteria (log-likelihood profile and Box's M) against λⱼ; a
  `pairs()` version (2-D profiles below the diagonal, 1-D on it); default `type` for 2-D;
  function names; whether a `plot()` method for `powerTransform` belongs in car rather than
  heplots.
- For the post: probably a short section, or a follow-up post, "Transforming an mlm", with
  one figure: the extended 2-D profile for (CK, Hpx), with (1, 1) far outside, and the
  Diabetes covariance ellipses before and after.

## Later: zeros and negative values (MF, 2026-11-26)

A separate story, to tack on: Box-Cox needs positive responses. Zeros (counts, times,
concentrations below detection) and negative values need either a shift (`bcPower` with a
start), car's `bcnPower` (Box-Cox with negatives, Hawkins & Weisberg 2017), or Yeo-Johnson
(`yjPower`). For an mlm that means a shift or γ per response, another dimension again.
The heplots functions (`bcProfile()` etc., now in `R/bcProfile.R`) support only `bcPower` for
now.
