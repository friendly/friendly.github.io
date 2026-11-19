# On extending `lm()` methods to `"mlm"`: planning notes

*Started 2026-11-19. Notes only, not yet `index.qmd`.*

## The idea in one paragraph

R fits a multivariate linear model with the same `lm()` call as a univariate one:
`lm(cbind(y1, y2, y3) ~ x1 + x2)` returns an object of class `c("mlm", "lm")`. But much of
the methods ecosystem that grew up around `"lm"` either errors on it or quietly does q
separate univariate analyses. Over about 20 years I've been filling those gaps, one package
at a time:

- **heplots**: visualizing tests;
- **candisc**: low-dimensional views;
- **mvinfluence**: influence diagnostics;
- **`heplots::robmlm()`**: robust fitting;
- **genridge**: ridge regression, now in development.

The post tells that story and pulls out the recurring move that makes each extension work,
and what was hard to do, and what remains.

## Framing

### Hook: what `lm()` methods actually do with an `"mlm"`

Checked on 2026-11-19 with R 4.6.1, using `fit <- lm(cbind(mpg, qsec) ~ hp + wt, data = mtcars)`.
The results fall into three kinds. This could be a small table in the post (re-run it at render
time, with errors caught).

| Method | What happens |
|---|---|
| `plot(fit)` | **Error:** `'plot.mlm' is not implemented yet` (a nice opening line) |
| `car::avPlots()`, `car::influencePlot()`, `car::vif()` | **Error** (cryptic: "not all arguments have the same length", "'x' and 'y' lengths differ", "argument is of length zero") |
| `MASS::rlm(cbind(...) ~ ...)` | **Error:** "incompatible dimensions" |
| `summary(fit)` | Runs, but returns a `listof` q separate univariate summaries |
| `cooks.distance()`, `rstudent()`, `influence.measures()` | Run, but return an n × q matrix: one univariate diagnostic per response, nothing joint |
| `hatvalues()` | Correct as is: leverage depends only on X |
| `vcov()` | Correct: the full pq × pq matrix |
| `anova()`, `car::Anova()` | Genuine multivariate tests (Pillai, Wilks, ...); the starting point for heplots |

The middle kind is the interesting one. Those methods don't fail, so a user may never notice
they got q univariate answers to a multivariate question.

Note: once mvinfluence is loaded, `cooks.distance(fit)` dispatches to its `mlm` method and
returns a single length-n vector. That makes a good before/after demo.

### The recurring move: every object gains a dimension

*(MF, 2026-11-19.)* Going from y to Y adds one dimension to every object a model produces:

- scalar → vector;
- vector → matrix;
- matrix → 3-way array, or a list of matrices.

This is the post's central idea. It works on two levels:

1. **The statistics.** What does the univariate quantity become? (See the table below.)
2. **The software.** The returned objects change shape, so every method that consumes them has
   to change too: `print()`, `summary()`, `coef()`, `confint()`, `predict()` and the plots.
   Much of the "doesn't work" or "quietly does q univariate things" behavior in the hook table
   comes from methods written for one shape receiving the next one up.

**What `lm()` already does with the extra dimension** (checked in R 4.6.1, 2026-11-19, on
`lm(cbind(mpg, qsec) ~ hp + wt, mtcars)`):

| Object | `lm` | `mlm` | How base R copes |
|---|---|---|---|
| σ² (residual variance) | scalar | q × q matrix Σ | `summary()` gives up: a `listof` q univariate summaries, each with its own σ̂ |
| Coefficients | p-vector | p × q matrix **B** | `coef()` returns the matrix (fine) |
| Var(coefficients) | p × p | pq × pq (= Σ ⊗ (X′X)⁻¹) | `vcov()` returns it flattened, with names like `mpg:hp` |
| Coefficient CIs | p × 2 | p × q × 2 (3-way) | `confint()` **flattens** to a pq × 2 matrix with `mpg:hp` names |
| Residual eᵢ, Cook's Dᵢ | n-vector | n × q matrix | `residuals()` is right; `cooks.distance()` gives q univariate columns |
| Fitted values | n-vector | n × q matrix | `predict()` is fine |
| SE of a fitted value | n-vector | n q × q matrices (a 3-way array) | `predict(fit, se.fit = TRUE)` **errors:** "the 'se.fit' argument is not yet implemented for "mlm" objects" |
| CI for a fitted value | n × 3 (`fit`, `lwr`, `upr`) | n × q × 3, or an ellipsoid per case | `interval =` is not supported for `mlm` |

So base R uses three tactics: return the bigger object (`coef`), flatten it (`vcov`, `confint`),
or refuse (`se.fit`). 
`broom` has a few methods, that simply add a `response` column to the result in a tidy data.frame

Each choice puts a cost on the downstream methods.

**Worked example: `predict.mlm()` with SEs and CIs.** This is your heplots TODO.
- Sources: `heplots/issues/AskClaude.md`, `heplots/dev/pred.mlm.R` and `heplots/issues/TASKS.md`
  ("`pred.mlm()`: extend `predict.lm`-style CIs/PIs to multivariate models; draft only").
- Base R already has `stats:::predict.mlm()`, but it gives fitted values only.
- The point for the post: the generalization gets hard not because the math is hard, but because
  every output gains a dimension:
  - **SE.** For case i, se.fit(i) becomes a q × q covariance matrix,
    h₀ᵢ Σ̂ with h₀ᵢ = x₀ᵢ′(X′X)⁻¹x₀ᵢ: a matrix per case.
  - **CI.** The interval [lwr, upr] becomes either
    - q separate intervals, which ignore the correlation between responses; or
    - a joint confidence *ellipsoid* per case, whose radius comes from a Hotelling T² / F
      quantile. The draft uses `qf(level, m, n-p-m)`.
  - **Return value.** The draft returns an `array(dim = c(n, m, 3))`. The usual
    `cbind(fit, lwr, upr)` has nowhere to go.
  - **Printing and summarizing** that array, and **plotting** it, raise further design
    questions. The natural plot is an ellipse around each predicted point in a 2-D response
    space, which is heplots territory again.
- A nice illustration of "the extra dimension shows up first in the return value, and then in
  every method downstream". It's honest to say this one isn't done yet.

**Possible thesis line:** a good multivariate extension isn't "run it q times". It decides what
to do with the extra dimension: find the matrix that plays the role of the scalar, and the
ellipse that shows it.

### The statistical side: what each quantity becomes

Usually a scalar becomes a matrix and a squared distance becomes a Mahalanobis distance, and
then the univariate picture becomes an ellipse (the "Elliptical Insights" theme).

| Univariate (`lm`) | Multivariate (`mlm`) | Where |
|---|---|---|
| SS_H, SS_E, F = ratio of mean squares | **H**, **E** SSP matrices; tests from eigenvalues of **HE**⁻¹ | `car::Anova()`, heplots |
| Comparing group means on one y | H ellipse vs E ellipse; projection into the canonical space | heplots, candisc |
| Squared residual e²ᵢ | Squared Mahalanobis distance of the residual vector | mvinfluence, robmlm, `cqplot()` |
| Cook's D | Generalized Cook's D (Barrett & Ling 1992) | mvinfluence |
| Huber/bisquare weights from \|eᵢ\|/s | Weights from Mahalanobis distances, with scale from `MASS::cov.trob()` | `robmlm()` |
| Var(b̂) = σ² V | Var(vec B̂) = Σ ⊗ V | genridge (new) |
| Ridge trace of b̂(λ) | Trace per response, plus cross-response ellipses (shape of Σ) | genridge (new) |

### Design lessons (the "methods" part of the title)

These are for R developers, and to be kept short:

- **S3 dispatch on `"mlm"` before `"lm"`.** A `foo.mlm()` method is the cheapest way in, and it
  is what makes `heplot(fit)` or `cooks.distance(fit)` "just work".
  
- **Return objects that work with the rest of the ecosystem.**
  - `robmlm` objects inherit from `"mlm"`, so `car::Anova()` and `heplot()` work on them.
  - Recent fix (2026-10-03): `robmlm.mlm()` stores its call so that `update()` works.
  
- **Separate class vs inheriting.** genridge's `"mlmridge"` deliberately does *not* inherit
  from `"ridge"`. The plan's audit (`genridge/dev/ridge_mlm-plan.md` §10) showed which inherited
  methods would silently give wrong answers. That is the "quietly does the wrong thing" theme
  again, from the developer's side.
  
- **Delegate per response, then add what's truly multivariate.**
  - genridge first did `traceplot(x, response = )` via `as.ridge()`, then made the default
    draw all responses.
  - Genuinely new plots come after.
  
- **Know when the multivariate version adds nothing.** In shared-λ ridge, each column of
  B̂(λ) *is* the univariate ridge, and `vif()`, df and the shrinkage factors depend only on X.
  - Honest point for the post: not every method needs a new multivariate visualization.
  - The novelty is in Σ, in pooled GCV and in the H/E view.

## Sections, roughly

1. **Opening:** `plot(fit)` → "'plot.mlm' is not implemented yet". The quiet-failure table.
1a. **The extra dimension.** The shape table (scalar → vector → matrix → array), with
    `confint()` flattening and `predict(se.fit = TRUE)` refusing as the two concrete examples.
    This frames everything after it. `predict.mlm()` could appear here, or in section 8 as
    unfinished business.
2. **Why bother with MLMs?** Correlated responses, one test instead of q, and the error rate.
   Keep it short and link to the Vis-MLM book rather than re-teaching it.
3. **Seeing tests: heplots** (`heplot()`, `pairs()`, `heplot3d()` for `mlm`).
   - Also `coefplot`, `cqplot`, `distancePlot`, `etasq` and `glance.mlm`.
   - One HE-plot figure; candidate datasets are iris and `heplots::Rohwer`.
4. **Seeing it in fewer dimensions: candisc.**
   - `candisc.mlm()`, `candiscList()`.
   - The canonical view as the "biplot of the HE plot".
5. **Influence: mvinfluence.**
   - `hatvalues`, `cooks.distance`, `influence`, `influencePlot`, `infIndexPlot` for `mlm`.
   - Barrett & Ling's generalized measures; the subset deletion idea, if it's worth a sentence.
6. **Robustness: `robmlm()`.**
   - IWLS with Mahalanobis-distance weights.
   - `plot.robmlm()` shows the case weights.
   - Before/after HE plots.
7. **Now: multivariate ridge in genridge** (the news hook).
   - `ridge(cbind(Y1, Y2) ~ ...)` → `"mlmridge"`.
   - Faceted `traceplot()`.
   - The Kronecker fact, and why the ellipses all share Σ's shape.
   - Planned: cross-response coefficient ellipses and ridge HE plots.
   - Invite comments: this is development work on GitHub, not on CRAN.
8. **What's still missing:**
   - an actual `plot.mlm()` (should someone write one?);
   - `predict.mlm()` with SEs and CIs/PIs (the heplots draft, `dev/pred.mlm.R`). What should it
     return, and how should it print and plot?
   - `car::avPlots()` and `car::vif()` for `mlm`;
   - multivariate shrinkage that borrows strength across responses (Brown & Zidek 1980; curds
     and whey, Breiman & Friedman 1997);
   - an `mlm` version of `effects`.
9. **Further reading** (book chapters and papers).

## Figures and diagrams to reuse

*(Added 2026-11-19.)* Copy the files into `figures/` here when they are used; don't link into the
book repo.

**Now in `index.qmd`:**
- `figures/techniques-table.png` (@fig-techniques), at the end of the introduction;
- `figures/dimension-ladder.png` (@fig-dimension-ladder), drawn by `R/dimension-ladder.R`,
  after the bullet list in "One more dimension".

- **Techniques table: slide 9 of `Vis-MLM-book/talks/Vis-MLM-talk.pptx`** ("MLM problem: easy to
  fit, hard to see").
  - The image is the book's Figure 6.1: `Vis-MLM-book/images/techniques-table.png`
    (3732 × 2175; also a `.pdf`).
  - It classifies linear-model methods by the number (p, q) and type (quantitative or discrete)
    of the predictors and responses.
  - On the slide, a "Graphs:" row overlays ✔ ? ✔ ? on the four response columns (q = 1 vs q > 1,
    quantitative and discrete). The speaker notes say: "The right-hand column, multivariate
    responses, is where graphical methods have been thin."
  - That ✔/? row is exactly the point of this post. It isn't in the PNG; it's drawn on the
    slide with two SVG icons. For the post, either re-create it as an annotated version of the
    PNG, or say it in the caption.
  - **Where:** at the end of the introduction, after `plot(fit)` fails ("easy to fit, hard to
    see"), or opening "Why bother with MLMs?".
  - The slide's other bullets fit the framing too: "Math is beautiful & easy too: y ⤳ Y. But the
    results arrive as tables of multivariate tests. Goal: plots that show what those tests mean."
- **`Vis-MLM-book/images/MLM-table.png`.** A simpler 2-column version: y = Xβ vs Y = XB, with
  regression/ANOVA/ANCOVA rows. Use it if Figure 6.1 is too busy. Both would be redundant.
- **`Vis-MLM-book/images/HE-framework.png`.** Data ellipses → HE plot → discriminant scores →
  canonical space, for a two-group example. A ready-made overview for the heplots and candisc
  sections, or a single figure covering both.
- **`Vis-MLM-book/images/response-dimensions.png`.** Two panels of group ellipses in (Y1, Y2):
  effects along one dimension vs two. There's also a `manova-response-dimensions-anno.png`
  variant. This could illustrate why the extra dimension matters statistically: the effect can
  lie in a direction that neither response shows alone.
- **Other possibly relevant files in `Vis-MLM-book/images/`:**
  - `duncan-av-influence.png` (influence);
  - `ridge-demo.png`;
  - `Duncan-3D-ellipses.png`;
  - `peng-3D-ellipses.png`.

  Not yet viewed.

**New diagram worth making:** the "every object gains a dimension" ladder.
- Shapes (point → line → rectangle → box) on the left, with matched pairs of lm and mlm objects:
  - σ² → Σ;
  - b → B;
  - CI table → p × q × 2 array;
  - se.fit → n q × q matrices.
- It could be drawn in R (grid/ggplot) or as SVG. It would replace or accompany the bullet list
  in "One more dimension".

## Open questions for MF

- **Title.** Options:
  - "On Extending `lm()` Methods to `"mlm"`" (your working title);
  - "What `lm()` Methods Do with an `"mlm"`";
  - "'plot.mlm' is not implemented yet";
  - "From Scalars to Ellipses".
  
- **Audience.** R package developers (lean on the S3 design lessons), or users of MLMs (lean on
  the graphics)? I'd lean towards users, with a short developer section.
  
- **Code.** Should the post run code (heplots, candisc, mvinfluence and genridge are installed),
  or be mostly narrative with a few figures? The genridge part needs the GitHub development
  version.
  
- **Timing.** Publish before genridge's mlmridge reaches CRAN, as a call for feedback, or after?
- **Length.** Seven packages and features is a lot; it could become a two-part post (the history,
  then genridge).
- **History.** Do you want a personal history thread (when each package started, and why)?
  I don't have the dates; I'd need them from you or the package NEWS files.

## Sources and links

- **Vis-MLM book:** https://friendly.github.io/Vis-MLM-book. Relevant chapters:
  - 09: collinearity and ridge;
  - 11 and 12: the MLM and its visualization;
  - 13: equality of covariance;
  - 14: influence and robust methods;
  - 21: discriminant analysis.

  The book repo (`C:\R\Projects\Vis-MLM-book`) is also source material; see the
  `project_vis_mlm_blog` memory.
- **Package sites:** heplots, candisc, mvinfluence and genridge pkgdown sites at
  `https://friendly.github.io/<pkg>/`. Verify each before linking.
- **genridge development plan:** `C:\R\Projects\genridge\dev\ridge_mlm-plan.md`. Plot ideas are
  in §5; scope beyond shared λ is in §6.
- **References,** checked in the canonical bib files on 2026-11-19 (keys as found):
  - `vita.bib`:
    - `Friendly:07:manova`: HE plots for MLMs (JCGS 2007);
    - `FoxFriendlyMonette:08:compstat`: the heplots package;
    - `FoxFriendlyWeisberg:13:rjournal`: MLM hypothesis tests with car;
    - `Friendly-etal:ellipses:2012`: "Elliptical Insights";
    - `FriendlySigal:2016:TQMP`: R tutorial on graphical methods for MLMs;
    - `FriendlySigal:2015`: recent advances in visualizing MLMs;
    - `Friendly:genridge:2013`: the generalized ridge trace plot (JCGS).
  - `statistics.bib`: `Brown-Zidek-1980`.
  - **Not found in the bib files; propose entries:**
    - Barrett & Ling (1992), JASA 87(417), 184–191 (cited in mvinfluence's docs);
    - Barrett (2003);
    - Breiman & Friedman (1997), JRSS B 59(1).
  - Check whether a candisc paper is in `vita.bib` (none showed up in a title search).
