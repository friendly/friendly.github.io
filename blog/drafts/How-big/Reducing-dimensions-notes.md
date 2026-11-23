# Reducing Dimensions: planning notes

*Started 2026-11-21. A companion to "On Extending `lm()` Methods to `"mlm"`" (`index.qmd`
here; notes in `notes.md`), to become its own post when that one is done.*

- **MF's original note** comes first, moved unchanged from "Additions" in `notes.md`.
- **The sketch** follows. It is Claude's expansion of that note, for MF to rework.
- **To settle**, near the end, lists what turned up in checking, including one point that
  affects the current post.

## MF's original note

**Additions**

[MF: I think this could be a major addition to the post, possibly title: Getting Dimensions Back, or, more directly, Reducing Dimensions. Or maybe it is too much for here, so should be a separate post]

One thing not addressed here in the 'one more dimension' idea is how multivariate thinking
and matrix notation can lead to reducing the dimensions of an R object or of making a complex
statistical test simpler, by considering what is important, aided by geometry.

- How "big" is $\mathbf{y}$, or $\mathbf{Y}$, or $\mathbf{X}$, or $\mathbf{H}$ relative to $\mathbf{E}$?
  - This is the core of the ideas of variance ($\sigma^2$), covariance ($\Sigma^2$) and their sample friends,
  s^2, S, H and E
  
  - Matrix algebra has some handy tools for this: Vector (||x||) and matrix (||X||) norm characterizes the size
  of an object in a single number: its' "length" in some sense, most often in a least-squares, Euclidean. but also
  accommodates other spaces: Manhattan (-> LASSO vs. ridge regression), ...
  
  - It is, of course also the central idea behind PCA, as a data dimension reduction method, and biplots
  as a means to visualize your data in fewer dimensions, while seeing how the observations an variables
  in "low-rank" space relate to your data.
  
  - In the MLM context, this was a problem that was solved by matrix algebra by different ways of calculating
  a scalar measure of how big $\mathbf{H}$ is relative to $\mathbf{E}$. Wilks, Pillai, Hotelling-Lawley, Roy each
  addressed this in different, but reasonable ways. But then, some statistical magic happened. Wills' Lambda ... were 
  seen as measures with totally different distributions, but all could be converted to an F-statistic. 
  Often the conversion was **exact**: p-values identical. When these could only be guarranteed asymptotically,
  statisticians of the day provided conditions: s=1, 2-- exact, ...
  
  [MF: Table 3, in the ellipses paper gives the details of Wilks', ...: formula and geometric interpret of "mean".
  fig 19 there shows the geometry of the tests.]
  
  - For HE plots this became a different challenge: how to visualize how big H vs. E --- the graphic design idea
  involved just centering and scaling to put their data ellipsoids in the same visual frame, where they could be
  compared for "size" to answer that question, but also show their orientation, "fatness" (variance), ...
  For factors could show thier means, show contrasts, ... Scaling choices also gave an option for "significance scaling" ...
  
  [MF: Either put just a stubb for this in the current post, or leave this for another time...]

---

## Sketch

### Titles

- **Getting Dimensions Back**: answers "One more dimension", but could be read as *regaining* them.
- **Reducing Dimensions**: direct, but sounds like a post on PCA alone.
- **How Big Is My Matrix?** The question that runs through all of your note. My suggestion, perhaps
  with the subtitle "Reducing dimensions in multivariate linear models and in graphical methods: Stories
  from a fireside chat".
  [MF: Use this title]

### Banner

Candidate: `images/fireside-HE-chat-V2.jpg`. Editing notes, reference photos and what's left to do:
[images/fireside-image-notes.md](images/fireside-image-notes.md).

Also for section 3, on the four tests: the bar cartoon,
`../VisMLM/jokes/images/four-tests-cartoon-v3.png` (Roy: "HIM!"), as the payoff to "their maximum
friend Roy" in the first post.

### The idea in one paragraph

The first post climbs up the ladder: scalar → vector → matrix → array. This one climbs back down.
Each step down answers "how big is it?", and to answer that you first have to say *compared to
what* (a metric: **I**, **E**, **H** + **E**) and *in what sense* (total, largest, volume).
The algebra tells you how few numbers you need. The geometry shows what they measure, and
what was thrown away to get them.

**Possible thesis line:** to reduce dimensions well, decide what "big" means, keep what you
need to measure it, and draw a picture of what's left.

### Possible opening

> When we left A. Square, the Sphere had just shown him what one more dimension looks like.
> But earlier in the story he dreams of a trip the other way, to Lineland, whose King can't
> conceive of anything but length. I used to feel a little sorry for the King. Then I noticed
> how much of multivariate statistics consists of working out, very carefully, how to get to
> Lineland. You start with a matrix of 130 numbers. You'd like to finish with one, and be able
> to say "that's big".

(Pointland, whose only inhabitant is entirely pleased with himself, is there for the *p*-value.)

### 1. How big is **y**? Length

- $\|\mathbf{y}\|^2 = \mathbf{y}^\top\mathbf{y}$. Centered, it is $SS_T$, and per df it is
  $s^2$. A variance is a squared length.
- Pythagoras gives $SS_T = SS_H + SS_E$, and $F$ is a ratio of two squared lengths, each per df.
  So the univariate test already asks "how big is H relative to E?"
- Other senses of length: $L_1$ (Manhattan), $L_2$ (Euclidean), $L_\infty$ (largest element).
  Their unit "circles" are a diamond, a circle and a square. The corners of the diamond are
  why LASSO sets coefficients to zero and ridge doesn't.
- Change the metric and the circle becomes an ellipse: $\mathbf{e}^\top\mathbf{S}^{-1}\mathbf{e}$,
  the Mahalanobis distance already used in robmlm and mvinfluence.

### 2a. How big is a covariance matrix: Determinant

cite: A Geometric Approach to Determinants
Author(s): John Hannah
Source:
The American Mathematical Monthly, Vol. 103, No. 5 (May, 1996), pp. 401-409
Published by: Mathematical Association of America
Stable URL: http://www.jstor.org/stable/2974931
https://sites.cos.unt.edu/~tushar/project%20ideas/monthly%2096%20hannah%20geometric%20determinant.pdf


Locke, P. (1994). THE GEOMETRY OF DETERMINANTS. PRIMUS, 4(1), 1–8. https://doi.org/10.1080/10511979408965726


### 2b. How big is **Y**, or **X**? Singular values

For a centered matrix with singular values $d_1 \ge d_2 \ge \dots$, up to constants and df:

| "Size" | Formula | For the data ellipsoid | Statistical name |
|---|---|---|---|
| Frobenius norm, squared | $\sum d_i^2$ | sum of squared semi-axes | total variance (trace) |
| Spectral norm, squared | $d_1^2$ | longest semi-axis, squared | variance of the first PC |
| Determinant (not a norm) | $\prod d_i^2$ | volume, squared | generalized variance |

- **PCA** keeps the largest $d_i$, giving the best rank-$k$ approximation in both the
  Frobenius and spectral norms (Eckart & Young 1936). The **biplot** draws observations and
  variables together in that space (Gabriel 1971).
  
- **For X, the small end matters.** $d_1/d_p$ is the condition number. With ridge constant $k$,
  component $i$ is shrunk by $d_i^2/(d_i^2 + k)$, and the sum of these factors is the
  effective df: a matrix reduced to a scalar. Pillai's trace has the same form (section 4).

### 3. How big is **H** relative to **E**? From matrices to $s$ numbers

- You can't just divide matrices, so change the metric. Transform the responses to make **E**
  a circle:
  $$\mathbf{H}^\star = \mathbf{E}^{-1/2}\,\mathbf{H}\,\mathbf{E}^{-1/2}, \qquad \mathbf{E}^\star = \mathbf{I}.$$
  
- Rotate to the axes of $\mathbf{H}^\star$, and all that remains are
  $\lambda_1 \ge \dots \ge \lambda_s$, the nonzero roots of $\mathbf{HE}^{-1}$, with
  $s = \min(q, df_h)$.
  
- **Why this is enough:** the hypothesis doesn't care about the units of the responses, or
  which (nonsingular) combinations of them you use. Invariant tests can depend only on the
  $\lambda_i$. Invariance does the reducing.
  
- **What is lost:** the directions. candisc gets them back from the eigenvectors.

The Pottery MANOVA from the first post, coming down the ladder:

| Step | Object | Numbers | What was set aside |
|---|---|--:|---|
| data | **Y**, 26 × 5 | 130 | |
| sums of squares and products | **H**, **E** | 15 + 15 | cases, grand means |
| relative size | $\lambda$ = 34.16, 1.25, 0.028 | 3 | units, directions |
| one size | Pillai $V$ = 1.554 | 1 | how the size is spread over dimensions |
| evidence | $F$ = 4.30 on (15, 60) df, $p$ = 2.4e-5 | 1 | the size itself |

### 4. From $s$ numbers to one: four kinds of mean

This is Table 3 of the ellipses paper, with a twist that makes the "means" exact. Let
$u_i = 1/(1+\lambda_i) = 1 - \rho_i$, the proportion of *error* in canonical dimension $i$.
Then every statistic is a mean of the same $s$ numbers:

| Criterion | Statistic | Mean of the $u_i$ | which equals | $\eta^2$ = 1 − mean, Pottery |
|---|---|---|---|--:|
| Pillai | $V = \sum \lambda_i/(1+\lambda_i)$ | arithmetic | $1 - V/s$ | 0.518 |
| Wilks | $\Lambda = \prod 1/(1+\lambda_i)$ | geometric | $\Lambda^{1/s}$ | 0.769 |
| Hotelling-Lawley | $U = \sum \lambda_i$ | harmonic | $s/(s+U)$ | 0.922 |
| Roy | $R = \lambda_1$ | minimum | $1/(1+R)$ | 0.972 |

- These are power means of order 1, 0, −1 and −∞. So by the inequality of means, $\eta^2$
  is *always* ordered Pillai ≤ Wilks ≤ HL ≤ Roy, with equality when all $s$ roots are equal.
  This could be the "aha" of the post.
- Two are squared norms. With $\mathbf{Z} = \widehat{\mathbf{Y}}_H\mathbf{E}^{-1/2}$, the
  effect in the error metric, HL is $\|\mathbf{Z}\|_F^2$ and Roy is $\|\mathbf{Z}\|_2^2$:
  section 2 again.
- **They differ in what counts as big.** Here are two effects with the same HL:

  | $\lambda$ | Pillai $V$ | Wilks $\Lambda$ | HL $U$ | Roy $R$ |
  |---|--:|--:|--:|--:|
  | (1, 0), concentrated | 0.50 | 0.50 | 1 | 1.0 |
  | (0.5, 0.5), diffuse | 0.67 | 0.44 | 1 | 0.5 |

  Pillai and Wilks call the diffuse effect bigger, Roy the concentrated one, and HL can't
  tell them apart. This leads into Schatzoff (1966) and Olson (1974) on power.

### 5. The geometry: Figure 19

Where **E** is the unit circle, $(\mathbf{H}+\mathbf{E})^\star$ is an ellipse with semi-axes
$a = \sqrt{1+\lambda_1}$ and $b = \sqrt{1+\lambda_2}$. For $q = 2$:

| Criterion | What you measure in the picture | Relation |
|---|---|---|
| Roy | major semi-axis $a$ | $R = a^2 - 1$ |
| Wilks | area, as $ab$ | $\Lambda = 1/(ab)^2$ |
| HL | diagonal $c = \sqrt{a^2+b^2}$ | $U = c^2 - 2$ |
| Pillai | perpendicular $d$ from the origin to that diagonal | $V = 2 - 1/d^2$ |

Four tests, four ways of taking a ruler to one ellipse.

### 5a. Ellipses have shadows

*Added 2026-11-23, from MF: "Ellipses have shadows", an idea MF attributes to Georges Monette.
Source: the ellipses paper (`Friendly-etal:ellipses:2012`, Section 4.6, Figs. 12–13), which in
turn cites @Monette:90 for the geometry. [Check: is the phrase itself in print anywhere, or
just Georges's way of saying it? Attribute accordingly.]*

**The idea.** A shadow (projection) of an ellipse onto a line is a step down from two
dimensions to one. The ellipse holds *all* of these at once: for any linear combination
$\mathbf{a}^\top \boldsymbol{\beta}$, the interval for it is the ellipse's shadow on the
$\mathbf{a}$ axis. So a confidence ellipse is a compact store of infinitely many univariate
answers, and you pick the one you want by choosing where the light comes from.

**Why it belongs in this post.** It's the gentlest answer to "how big?": each shadow is a
one-number-plus-interval summary, and the ellipse keeps every one of them. That's the
argument of section 7 (don't reduce too soon) and the design lesson of section 8 (store
$\boldsymbol{\Sigma}$, expand or reduce on demand), in one picture.

**Fig. 13 of the paper, in numbers.** `matlib::coffee` (n = 20), `lm(Heart ~ Coffee + Stress)`.
Checked in R 2026-11-23:

| Shadow | What it gives | 95% interval |
|---|---|---|
| on the $\beta_\text{Coffee}$ axis | CI for Coffee, controlling for Stress | (−1.02, 0.21): includes 0 |
| on the $\beta_\text{Stress}$ axis | CI for Stress, controlling for Coffee | (0.73, 1.67) |
| oblique, onto the line $\beta_\text{Stress} = 0$ | slope for Coffee in the *simple* regression | (0.88, 1.33): excludes 0 |
| on an axis of slope −1 | $\beta_\text{Stress} - \beta_\text{Coffee}$ | excludes 0 |

The sign flip for Coffee is the Simpson-like surprise, and here it's just two different
shadows of one ellipse: one straight down, one along the ellipse's own tilt.

**Two sizes of ellipse.** The same ellipse, scaled two ways:

- radius $\sqrt{F_{1,\nu}} = t_\nu$ ($d = 1$, the "confidence-interval generating ellipse"):
  each shadow is an ordinary 95% interval, one at a time;
- radius $\sqrt{2 F_{2,\nu}}$ ($d = 2$, the joint confidence ellipse): each shadow is a
  Scheffé interval, simultaneous over *every* linear combination. That's the price of
  looking in all directions, "fishing", paid in advance.

**Link to the four tests (section 5).** Roy's test is the shadow idea run in reverse: the
largest root is the biggest univariate $F$ over all linear combinations
$\mathbf{a}^\top \mathbf{y}$ of the responses (union–intersection, @Roy1957). In an HE plot,
"**H** protrudes outside **E** somewhere" says there's a direction in which the shadow of **H**
is longer than the shadow of **E**. It also explains the one-way rule in the first post's Roy
footnote: a 2D HE plot is itself a shadow of the $q$-dimensional ellipsoids, so protrusion
can show up in it, but its absence there doesn't rule it out elsewhere.

**Side note, not the main thread: linear hypotheses and Scheffé.** Every $\mathbf{L}\boldsymbol{\beta} = \mathbf{0}$
with one row asks about one shadow; Scheffé's method protects all of them at once, which is
why its ellipse is bigger. A sentence or a footnote, pointing to the first post's
$\mathbf{L}\mathbf{B}\mathbf{M} = \mathbf{0}$, may be enough.

**Possible line:** "Ellipses have shadows, and every shadow is an answer to some question.
The ellipse is the set of all the answers."

### 6. The magic: all roads lead to $F$

The statistics have different null distributions, yet each converts to an $F$:

| Case | Pillai | Wilks | HL | Roy |
|---|---|---|---|---|
| $s = 1$ | exact | exact | exact | exact |
| $s = 2$ | approximate | **exact** | approximate | bound |
| $s \ge 3$ | approximate | approximate | approximate | bound |

- For $s = 1$ there's nothing to average, and the four $p$-values are identical. Each 1-df
  term in the Rohwer model shows this: for `SES`, $F$ = 12.18 on (3, 60) df, four times over.
  Hotelling's $T^2$ is the same case.
- For Wilks, $s = 2$ is exact by way of $\sqrt{\Lambda}$. Beyond that it's Rao's approximation.
- Roy's $F$ is an upper bound, so its $p$-value is too small when $s > 1$.

Simulated type I error at nominal .05, using R's $F$ conversions (100,000 replications,
Monte Carlo SE ≈ .001):

| $q, df_h, df_e$ | $s$ | Pillai | Wilks | HL | Roy |
|---|--:|--:|--:|--:|--:|
| 5, 1, 20 | 1 | .049 | .049 | .049 | .049 |
| 2, 2, 20 | 2 | .044 | .050 | .055 | .162 |
| 5, 2, 20 | 2 | .041 | .049 | .056 | .177 |
| 5, 3, 22 (as in Pottery) | 3 | .038 | .050 | .062 | .376 |

### 7. Don't reduce too soon: HE plots

A test gives the size as one number. The HE plot is the graphic design answer to the same
question, and it stops one rung earlier, in two dimensions.

- **Center** both ellipsoids at the grand mean: one visual frame, in which the factor means
  can be plotted too.
- **Scale** both by $df_e$. **E** is then the data ellipse of the residuals, and **H** is in
  effect-size units: "how big?"
- **Rescale H** by a critical value, for significance (evidence) scaling: "big enough?"
- **Read** what the scalar lost: orientation, fatness, rank (a 1-df **H** is a line), and how
  contrasts decompose an effect.
- **Rotate**, with candisc, and the idealized picture of section 5 appears in real data: **E**
  a circle, **H** along the axes. It's a PCA of the effect in the error metric, which is why
  the canonical plot works as a biplot.

### 8. Smaller R objects, too

The other half of your first sentence: structure tells you what needn't be stored.

| Object | As the first post grows it | What's sufficient |
|---|---|---|
| `vcov()`, Pottery | 20 × 20, 210 distinct elements | $\Sigma$ and $(\mathbf{X}^\top\mathbf{X})^{-1}$: 15 + 10 |
| `se.fit` for $n$ cases | $n \times q \times q$ array | $n$ leverages and one $\Sigma$ |
| ridge covariances, $L$ values of $k$ | $L$ matrices, each $pq \times pq$ | one $\Sigma$ and $L$ matrices, each $p \times p$ |
| influence of $m$ cases | two $m \times m$ matrices | `FUN = det` or `tr`: a choice of "size" |

A possible design lesson: store the factors, and let the methods expand or reduce them. That
may also answer the open `predict.mlm()` question in the first post.

### 9. Closing

Every summary is a projection, and has things it can't see. The first post warned about
methods that quietly return $q$ univariate answers. The opposite mistake is to return one
multivariate answer and forget what was averaged to get it.

## Figures

MF: Do these in `images/` for now, where I have other things related to a new post

1. The descending ladder, or a funnel, for Pottery (section 3). New, in the style of
   `R/dimension-ladder.R`; probably the key figure.
   **Draft:** `images/reducing-ladder.png`, from `R/reducing-ladder.R` (2026-11-22). Numbers are
   computed in the script, and match the table in section 3.
2. Unit balls for $L_1$, $L_2$, $L_\infty$, and Mahalanobis (section 1). New, small.
   **Draft:** `images/unit-balls.png`, from `R/unit-balls.R` (2026-11-22). Right panel: A and B
   are both at Euclidean distance 1, but at Mahalanobis distance 0.76 and 2.00 (rho = 0.75).
3. Figure 19 in four panels, one measurement highlighted in each (section 5). Redraw.
   **Draft:** `images/four-rulers.png`, from `R/four-rulers.R` (2026-11-22). Toy roots
   lambda = (3, 1), so a = 2, b = sqrt(2); the script checks each formula against the usual
   definition of the statistic.
4. Contours of the four statistics in the $(\lambda_1, \lambda_2)$ plane, with the concentrated
   and diffuse effects as points (section 4). New.
   **Draft:** `images/four-contours.png`, from `R/four-contours.R` (2026-11-22). One contour per
   statistic, the one through the concentrated effect (1, 0). The diffuse effect lies on the HL
   line, outside the Pillai and Wilks curves, inside Roy's. On the diagonal the curves cross at
   1/3, sqrt(2) - 1, 1/2 and 1: the ordering of section 4. The shapes echo the unit balls: HL is
   an L1 diamond and Roy an L-infinity square.
5. HE plot beside its canonical version, for Pottery (section 7). Adapt from `index.qmd`.
   **Draft:** `images/he-vs-canonical.png`, from `R/he-vs-canonical.R` (2026-11-22). Left: Al
   against Fe in data space, where E is a tilted ellipse. Right: canonical space, where E is a
   circle and H lies along Can1. The right panel rebuilds what `heplot.candisc()` does, because
   that function always labels the means and Isle Thorns and Ashley Rails overlap. Fe and Mg
   share an arrow label. Still crowded around the Al arrow; a candisc option to suppress or
   place mean labels would help.
6. Ellipses have shadows (section 5a). Redraw Fig. 13 of the ellipses paper from
   `matlib::coffee`, in $\beta$ space: the $d = 1$ and $d = 2$ ellipses, their shadows on both
   axes, the oblique shadow onto $\beta_\text{Stress} = 0$, and the $\beta_\text{Stress} - \beta_\text{Coffee}$
   axis. `car::confidenceEllipse()` with `dfn = 1` and `dfn = 2` draws the two ellipses. Not
   **Draft:** `images/coffee-shadows.png`, from `R/coffee-shadows.R` (2026-11-23). Two panels:
   shadows on the axes (d = 1 CIs in orange; d = 2 Scheffé intervals in grey, just outside the
   axes), and shadows in other directions (oblique onto b_Stress = 0; orthogonal onto the
   Stress − Coffee axis). Shadows drawn as light strips with dashed rays. The script checks the
   axis shadows against `confint()` and the oblique centre against the simple-regression slope.
   The original, for comparison: `images/refs/fig13-original.png` (git-ignored).
   **Note:** the oblique shadow (0.97, 1.25) is narrower than the simple-regression CI
   (0.88, 1.33). Only the centre is exact; the paper's blue line is the actual CI. Say so
   in the post, or show both.

## Starter code

```r
data(Pottery, package = "carData")
pottery.mlm <- lm(cbind(Al, Fe, Mg, Ca, Na) ~ Site, data = Pottery)
aov <- car::Anova(pottery.mlm)
H <- aov$SSP$Site
E <- aov$SSPE

s <- min(ncol(H), aov$df[["Site"]])
lambda <- Re(eigen(solve(E, H), only.values = TRUE)$values)[1:s]
u <- 1 / (1 + lambda)

eta2 <- 1 - c(Pillai = mean(u),
              Wilks  = prod(u)^(1/s),
              HL     = 1 / mean(1/u),
              Roy    = min(u))
round(eta2, 3)
```

## To settle

### Found in checking (2026-11-21; only item 1 has been acted on, in the post)

1. **Significance scaling: affects the current post.** `heplots:::Roy.crit()` inverts Roy's
   $F$ bound, so for $s > 1$, **H** protrudes somewhere in the full response space far more
   than 5% of the time under the null (the Roy column in section 6). The "if and only if"
   sentence in `index.qmd` is true of that approximate test, not of an exact .05 test.
   *Qualifier and footnote `[^roy]` added to the post 2026-11-21.* The heplots documentation
   may need the same.
   
2. **Exactness.** "s = 1, 2: exact" holds only for Wilks. The ellipses paper (beside Fig. 19)
   says all four are exact, with identical *p*-values, for $s \le 2$, and the book
   (`11-mlm-review.qmd:616`) says all are exact. For all four, that's true only for $s = 1$.
   
3. **Means of what?** Table 3 says means of $\rho$; the book (`11-mlm-review.qmd:611`) says
   means of $\lambda_i$. The geometric and harmonic means work only for $1-\rho_i$ (section 4).
   
4. **Two footnotes in the paper.** Note 13 has $df_1 = \max(df_h, df_e)$, which should be
   $\max(p, df_h)$ for $p$ responses, as in heplots. Note 14 calls Wilks the ratio of areas
   of **H** and **E**; it's the squared ratio of the areas of **E** and **H** + **E**.
   
5. **In the original note:** the covariance matrix is $\Sigma$, not $\Sigma^2$.

### Decisions for MF

- **Title**, and whether this is "Part 2" or stands alone. [MF: It stands alone, with a link in the intro to the earler post]

- **Scope:** are sections 1–2 the way in, or a detour before H vs. E? I'd keep them short and
  make 3–7 the core. Section 8 could shrink to a paragraph.
  
- **Notation:** $\lambda$ is the ridge constant in the first post and an eigenvalue here (the
  sketch uses $k$ for ridge). $U$ is used for HL since **H** is taken, but is close to
  $\widehat{\mathbf{U}}$. The paper uses $p$ for responses, the posts $q$.
  
- **Stub in the first post?** If so, one sentence in the Conclusion would do: "Going up a
  dimension is half the story; the other half, for another post, is how to come back down
  without losing what matters."

## References

- In `references.bib`: `Friendly-etal:ellipses:2012` (Table 3, Fig. 19), `Friendly:07:manova`,
  `Friendly:genridge:2013`, `Abbott:1884`.
- In `statistics.bib`: `Hotelling:1931`, `Schatzoff1966`, `Olson:1974`, `Roy1957`.
- In `timeref.bib`: `Gabriel:1971`.
- For section 5a: `Monette:90` (`graphics.bib`; Fox & Long, eds., *Modern Methods of Data
  Analysis*, ch. 5) and `Scheffe1960` (`statistics.bib`, *The Analysis of Variance*).
  Scheffé (1953), "A method for judging all contrasts in the analysis of variance",
  *Biometrika*, wasn't found; from memory, so check it.
- Not found searching the bib files by author. **These are from memory, so check them:**
  - Wilks (1932), Certain generalizations in the analysis of variance, *Biometrika*;
  - Eckart & Young (1936), The approximation of one matrix by another of lower rank, *Psychometrika*;
  - Lawley (1938), A generalization of Fisher's z test, *Biometrika*;
  - Hotelling (1951), A generalized T test and measure of multivariate dispersion, *Berkeley Symposium*;
  - Rao (1951), An asymptotic expansion of the distribution of Wilks' criterion, *Bull. ISI*;
  - Roy (1953), On a heuristic method of test construction, *Ann. Math. Statist.*;
  - Pillai (1955), Some new test criteria in multivariate analysis, *Ann. Math. Statist.*
