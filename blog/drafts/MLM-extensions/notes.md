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

## Decisions (MF, 2026-11-20)

- **Title:** keep "On Extending `lm()` Methods to `"mlm"`".
- **Audience:** package developers and statisticians.
- **Code:** most code runs live. Short illustrative chunks in the intro get
  `code-fold: false` (no Code button); chunks whose results aren't used can be `eval: false`.

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

## Polishing list (review of the full draft, updated 2026-11-20)

*Done 2026-11-20 (mechanical pass):* `***don't* fail**`; "does in for" → "does for `predict()`";
period after `(dev/pred.mlm.R)`; "same design S3 design"; double "only"; `$mathbf{X}$` and
`\mathbf{\beta}` → `\boldsymbol{\beta}`; techniques caption now says the *quantitative* q > 1
column; "there are other", "a wrinkle", "an MLM", "for free from base R"; "statistics and for
the software"; double space; the "But, importantly here…" fragment in "Filling in the gaps"
made a sentence; school-cross text now says `visit` crosses zero "at nearly the same λ" (reading
crosses at λ ≈ 1, mathematics between 1 and 2).

*Numbers checked in R (2026-11-20):* Pillai F 4.30 → 6.55 (robust); case 9's D = 10.8× the next
largest; candisc: dims 1–2 significant (p = .029 for dim 2), dim 3 not; `robmlm.default()` uses
`cov.trob`, `mahalanobis()`, `psi.bisquare`, `qchisq(1 - P, df = p)`, as described. All
citation keys resolve.

**Notation (MF to decide)**

1. **E for two things.** In mvinfluence, `qᵢᵢ = eᵢ′(E′E)⁻¹eᵢ` uses **E** for the residual matrix,
   but everywhere else **E** is the error SSP matrix. Vis-MLM-book uses
   `\providecommand{\Epsilon}{\boldsymbol{\Large\varepsilon}}` for the residual matrix. Options:
   adopt `\Epsilon` (define it in a hidden `$$ $$` macro block at the top), or write
   `eᵢ′ E⁻¹ eᵢ` with **E** = the SSP matrix, which avoids the residual matrix altogether.
   Check other places a residual matrix appears (robmlm: "residual covariance matrix S").

**Consistency**

2. Conclusion says the "gaps in the last section" include `plot.mlm()`, AV plots and effect
   displays, but "What's still missing" only has `predict.mlm()`; the others are in an HTML
   comment. Add a short "Other gaps" list (plot.mlm, `car::avPlots()`/`vif()`, effects,
   multivariate shrinkage: Brown & Zidek 1980, Breiman & Friedman 1997, both in references.bib).
   
3. Ladder bullets in "One more dimension": the first uses σ² → Σ, but the figure's first rung
   is eᵢ → a q-vector. Use eᵢ, and mention σ² → Σ as the case that jumps two rungs.
   
4. "`dim(X) + 1`" ("One more dimension") and "`dim() + 1`" (genridge, in an awkward sentence
   that also needs rewriting): **X** is the model matrix elsewhere; pick one phrase.
5. The Kronecker product appears four times (intro, mvinfluence, genridge, predict).
Name it
   as a recurring motif, perhaps in the Conclusion; the LATER comment on factorial design
   matrices could join it there.
   
6. Hotelling radius: the post uses `F(q, n−p−q+1)`; the heplots draft (`dev/pred.mlm.R`) uses
   `qf(level, m, n-p-m)`. Reconcile the draft with the post.
   
7. Section rhythm: subheadings differ by package (heplots "What was easy"; mvinfluence "Design
   challenges"/"New influence plots"; robmlm "What took more work"; genridge "doesn't
   change"/"does change"/"design lesson"). A shared pattern (what gains a dimension → what
   was hard in the software → the display) would make the "same problem each time" argument
   easier to see.

**Unfinished or awkward text**

8. candisc: the `pairs()` paragraph ("which is actually `heplots::pairs.mlm()` in real life
   just does its `pairs()` thing") and its footnote ("Trellis graphics, ... `GGally` and
   other extensions ,,,"); the "wrinkle" bullet runs into the `can_lm()`/`varOrder()` lines.
9. genridge: the three "..." bullets (covariance ellipses, PCA views, biplot). An example
   figure could go here, e.g. `pca()` / `biplot()` for one response.
10. genridge "design lesson": "that's a good outcome" refers to the seven methods that
    errored, but "the same quietly univariate problem" refers to the one that silently lost
    the predictor names, and the "confess" paragraph now sits between them. Put the silent
    one next to its point.
11. Intro: the `cbind` "also works for a sequence of vectors, matrices and dataframes"
    sentence trails off; say why it matters or cut it. The two bullets after
    `cooks.distance()` aren't parallel (the second is a separate point).
    
12. End of "Filling in the gaps": "as I've learned about how to take these methods to 'One
    more dimension'" is awkward.
    
13. Decide: the `influence(fit, m = 2)` partial-matching pitfall (lesson in the post, or just
    mvinfluence TASKS.md); the `vcov.mlm` "think twice" sentence; the compact hook table
    (comment in the intro).
    
14. Cite VARshrink where `lm_multiv_ridge()` is mentioned.

15. robmlm: compute the Pillai Fs (4.3 → 6.6) with inline `` `r` `` code instead of typing them.
    Note that the denominator df drops 60 → 51 in the robust fit (near-zero weights
    effectively remove cases), so the two Fs aren't quite like for like. Also worth a
    clause: three of the four downweighted cases (1, 7, 11) are Llanedyrn, the fourth (25)
    Ashley Rails.

**Figures**

16. Ladder (`R/dimension-ladder.R`): crop ~15% empty space at the top; the back layer of the
    3-way array shows only as an orange L-strip and reads like a ragged matrix (bigger offset,
    perspective, or a "qsec" layer label); "CI for **B**" label sits a few px above
    "CI for **b**".
17. Rohwer HE plot: `ss` label is faint gray; `ns` label at the frame edge. Minor.
18. Pottery canonical: "IsleThorns"/"AshleyRails" overlap, "Mg"/"Fe" overlap, "Caldicot" sits
    on the ellipse boundary. Try `label.pos`, `cex`, or wider limits.
19. Pottery robust: left panel colored by site with no key (legend, or say in caption: blue =
    Llanedyrn, red = Caldicot, green = Isle Thorns, black = Ashley Rails). Right panel: the
    two "Site" labels overlap and the blue one is clipped at the bottom; "Error" labels and
    IsleThorns/AshleyRails overlap.
    
20. School trace: HKB/LW labels overprint ("HKLW"); counseling/education collide in two
    panels; everything bunches near λ = 0 with the axis starting at −1. Try
    `traceplot(sridge, X = "df")` or a log-spaced λ grid.
    
21. School cross: stacked fills go muddy brown (lower `fill.alpha`); λ labels 0/0.05/0.1
    overprint (label a subset, e.g. 0, 0.25, 1, 5).
    
22. Prediction ellipses: text says all ellipses have the same shape, but unequal axis scales
    make that hard to see; `asp = 1`, or just say so.

**Clean-up before publishing**

23. Remove obsolete HTML comments: the Status line (2026-11-19), the mtcars/dataset question,
    the SKELETON banner, the predict.mlm pointer note in "One more dimension", the CHECK
    comment in "Filling in the gaps" (done).
24. Verify the four pkgdown URLs and the Vis-MLM book link (Fig 6.1 is a chapter page).
25. Categories: consider adding candisc and mvinfluence.
26. Update the genridge 0.8.1 wording once CRAN accepts it.

27. A one-line pointer to Vis-MLM chapters 9, 11–14, 21 could go in the Conclusion.
    Uncited entries in references.bib (FriendlySigal 2015, 2016; Friendly & Kwan) can be
    cited or dropped.
