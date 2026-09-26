# QM-tools: what's reusable for "Notation as a Tool of Thought"

Survey of `C:\Users\friendly\Dropbox\Documents\Presentations\QM-tools\`
(abbreviated `QM/` below), done 2026-09-25.

> **MF decision (2026-09-25):** There is way too much APL (and Logo) material here
> for the current post plan. Keep this post's APL content to the hook and the Iverson
> section. The rest (APL/APL2/APL2STAT, Logo turtle geometry and Hilbert curves) could
> make a good **companion piece**, e.g. "Tools for Thinking: APL, Logo, and me"
> (working title), building on the 2010 talk and the 2020 `ToolsForThinking.Rmd`.

## What the folder is

* **The talk**: *Tools for Thinking in Statistical Computation and Graphics:
  A 40-year journey from APL to SAS to R*. QM Brownbag Seminar, York,
  Nov. 15, 2010 (BSB 163). 62 slides.
  - `Tools for Thinking in Statistical Computation.ppt` (source; old `.ppt`, not `.pptx`)
  - `Tools for Thinking in Statistical Computation.pdf` (1 slide/page), `...2x2.pdf` (handout)
  - `abstract.txt`: "various programming languages and environments differ widely
    [from a cognitive point of view] ... I hope to raise more questions than I can answer."
* **A later attempt to turn it into an article**: `ToolsForThinking.Rmd` (2020-07-01),
  "Tools for Thinking about Computation and Graphics". Abstract plus the start of
  a **Notation** section (Descartes, Leibniz vs. Newton, Lagrange's f′, f″). Only
  a few paragraphs, but it is the direct ancestor of this post.
* **Notes files** (2019-2020): `notation-notes.txt` (numerals, zero, fluxions,
  Newton/Leibniz, matrices/Cayley), `notes-power-of-prog-lang.txt` (quotes),
  `Rformulas.txt` (formula examples), `Rpackages.txt` (CRAN counts 2001-2009).
* **Images**: `fig/` (from 2010 talk), `fignew/` (added ~2019-2020), plus
  `Leibnitz-Newton.png`.
* **Other people's material** (reference only): `plyr-intro-090510.pdf`,
  `r-plyr-20091029.pdf` (Wickham's plyr talks), `HOCKING-latticedl-semin-r.pdf`
  (lattice/directlabels), `Tierney-JSM2019.pdf` ("Some Thoughts on Languages for
  Statistical Computing and Graphics", JSM 2019).
* **Not relevant**: `examples/Escher-like Spiral Tilings*` (saved web page),
  `practicum/`, `fig/prog_lang_poster.pdf`, `05-subsetting.pdf`.

## Big finds for this post

1. **Your APL history is documented here**, which fills the `<!-- MF: -->`
   placeholder in the hook. The talk quotes you and John Fox:

   > *APL2 is arguably the most powerful language yet developed for expressing
   > statistical computation. One's ability to get work done, however, depends as
   > much on the programming environment as on the primitives of the language.*
   > (Friendly & Fox, *JCGS*, 1994)

   `vita.bib` has the papers (copy into `notation.bib` if used):
   - `FriendlyFox:94`: Using APL2 to create an object-oriented environment for
     statistical computation. *JCGS*, 3(4), 387-407.
   - `FoxFriendly:95`: Data analysis using APL2 and APL2STAT. *Sociological Methods
     & Research*, 23(3), 282-302.
   - `FoxFriendly:97`: same title, chapter in Stine & Fox (eds.), *Statistical
     Computing Environments for Social Research*, Sage.
   - `Friendly:91:TR200`: APL2 tools for multivariate data analysis (York TR).

   The point for the post: APL wasn't just a language you used; you and Fox *built
   a statistical system* in it (APL2STAT), with datasets as nested arrays and
   operators like `BOOTSTRAP`.

2. **You already mapped Iverson's list in 2010.** Slide 11 ("APL: Notation as a
   tool for thought") gives Iverson's characteristics with your glosses, *adding
   universality* and a Cayley example: $\mathbf{Ax} = \mathbf{b} \rightarrow
   \mathbf{x} = \mathbf{A}^{-1}\mathbf{b}$. Note the slide says "tool **for**
   thought"; the post now uses Iverson's "of".

3. **Your own complementary list** (slide 4, "Power & elegance"): CS view (all
   languages are Turing-equivalent) vs. **cognitive view**, where languages differ
   in *expressive power*, *elegance* (readability), *extensibility*, and
   *learnability* (rate and asymptote of the learning curve). This is a nice
   psychologist's companion to Iverson's list, and fits the "background scorecard" idea.

4. **The model-formula section is half-written in slides 39-44**, already framed in
   Iverson's terms:
   - Formula syntax (`+ - : * ^ .`, `I()`, `cbind()` responses, `update(m, . ~ . + x5)`)
   - **generality**: same notation in `lm`, `glm`, `nls`, `gnm`, `rlm`, `nlme`
   - **suggestivity**: formulas escape modeling into tables (`xtabs(Freq ~ Gender + Admit)`)
     and graphs (`plot(logIMR ~ region)` gives boxplots; `plot(~ a + b + c)` gives a
     scatterplot matrix), then lattice adds conditioning, `y ~ x | z, groups =`
   - `Rformulas.txt` has the code for these.

5. **Computational equivalence** (the "fitted object you keep working with" point):
   slides 36-38. `methods(class = "lm")` lists 33 methods; `plot(mymod)` gives the
   regression quartet; the same generic `plot()` gives a scatterplot matrix for a data
   frame and a mosaic display for a table. Good concrete illustration.

## Material by post section

### Hook / personal thread
* **Slide 3, first summer job (1962)**: Harcourt, Brace & World test department,
  45 correlations among 10 tests, n = 500, on a **Monroe calculator**; insight that
  n, Σx, Σy, Σx², Σy², Σxy can be done in one pass; "I could write this in Fortran!"
  Image: `fig/Monroe88N-786-IMG_2437-5.jpg`. A lovely opener for "the notation
  of computation changes what you think to do."
* **Slide 2, RAND "home computer"**: `fig/Home_computer1954.jpg`.
  **Caution**: this widely-circulated photo is a known fake (a doctored photo of a
  submarine control console from a museum exhibit; the RAND caption was invented).
  If used, use it as a joke about predictions, and say it's a fake.
* Other period images: `fig/IBM7094.jpg`, `fig/Keypunch.jpg`, `fig/asr33-teletype.jpg`,
  `fig/fortran.gif`.

### Iverson / APL
* APL screen images (all `fig/`): `apl-primitive-operators.jpg` (reduction, scan,
  outer products, incl. Pascal's triangle `V∘.!V←0 1 2 3 4`: a very good
  *suggestivity* example), `apl-outer-products*.jpg`, `apl-primenumbers.jpg`
  (the famous one-liner `(2=+⌿0=I∘.|I)/I←⍳50`), `apl-chisquare-table.jpg`.
* APL2/APL2STAT: `apl2-nested1-3.jpg` (partitioned matrix
  $\mathbf{Z} = (\mathbf{y} \mid \mathbf{X})$, and $\mathbf{Z}'\mathbf{Z}$ computed
  blockwise with nested arrays), `apl2-data-driven.jpg` (row proportions and cumulative
  proportions without loops), `apl2-operators.jpg`, `apl2stat-bootstrap*.jpg`
  (annotated `BOOTSTRAP` operator; "operators: functions of functions"),
  `dataset-proto.jpg`, `dataset-sample.jpg` (datasets as nested arrays).
* Quotes (`notes-power-of-prog-lang.txt`, slide 10):
  - "APL is the most powerful notation for array processing ever invented. Because of
    its lack of influence on other languages, it will not be discussed further."
    (a curriculum board, as quoted by Brown & Wheeler, *APL2002*). Wonderfully
    self-refuting, since R, NumPy etc. inherited a lot from APL.
  - "Saying 'powerful language' is just a friendlier way of saying 'obfuscated
    syntax.'" (Jim Lehmer). The honest counterweight: APL as "write-only".
  - Knuth, *Literate Programming* (1984): "...concentrate rather on explaining to human
    beings what we want a computer to do." Useful for notation-as-communication.

### Short history
* `notation-notes.txt` has researched notes on:
  - **numerals**: Hindu-Arabic place value, zero (Aryabhata, Brahmagupta), Fibonacci
    bringing it to Europe ~1200; image `fignew/1920px-Numeral_Systems_of_the_World.svg.png`
    (Wikimedia; check license)
  - **Newton vs. Leibniz**: Newton's fluxions hidden in an anagram in his letter to
    Leibniz. **Check the string**: the notes' version looks garbled in transcription;
    the usual form is `6accdae13eff7i3l9n4o4qrr4s8t12ux`.
  - **matrices**: Sylvester named them, Cayley developed the algebra in the 1850s,
    with this quote (from Knill's Harvard history page):
    > "The invention of matrices illustrates once more the power and suggestiveness of
    > a well-devised notation; it also exemplifies the fact ... that a trivial
    > notational device may be the germ of a vast theory having innumerable applications."

    This is almost the thesis of the post. Knill's page is a secondary source;
    find the original before quoting.
* `Leibnitz-Newton.png`: tweet by Christopher Green (@histochristo) quoting Fermat's
  Library: Leibniz introduced df/dx in 1675; Lagrange's f′(x) came 95 years later.
  Green: "Leibniz's innovation allowed Europe to move forward mathematically, while
  Newton's notation chained British mathematics to the 17th c. for 100+ years."
  Great quote for the Newton/Leibniz paragraph (quote the text; don't reuse the screenshot).
* `ToolsForThinking.Rmd`: your 2020 draft paragraph on $y = a + bx$, $\Sigma$,
  Descartes' *La Géométrie* (1637), Leibniz → Lagrange. Can be lifted almost directly.
* **Logo** (slides 6-9; `fig/logo-*.gif/jpg`, `examples/Hilbert.lgo`): turtle
  graphics as a *different notation for geometry* ("body syntonic", Papert's
  *Mindstorms*, 1980), recursion, Hilbert curves, and a "proof by enumeration" by
  redefining `forward` to accumulate path length. Iverson's *formal proofs*
  characteristic, in a child's language. You also have Logo papers in `vita.bib`
  (`Friendly:90a:SUGI` "SAS/GRAPH software meets the Logo turtle", Logo 85/86
  conference papers). Possibly too big a detour; could be one paragraph or a sidebar.

### Data processing (split-apply-combine)
* **SAS thinking** (slides 23-32): DATA step → PROC → output dataset → PROC GPLOT
  pipeline diagrams (these are representation diagrams in the same spirit as ours);
  PROC SUMMARY with `class`; BY processing (`proc mi` → `proc reg ... by _Imputation_`
  → `proc mianalyze`); macros ("text substitution, not computation").
* **Tower of Babel** (slides 30-32; `fig/Tower-Of-Babel.jpg`, `Babel1/2.jpg`):
  builds up SAS's many sub-languages (data step, procs, Annotate, IML, %macro, ODS,
  ODS templates) as floors of the tower. A strong image for *lack of economy*
  (Iverson's point that utility falls with the size of vocabulary the user must hold).
  Painting is Marten van Valckenborch (public domain); confirm source.
* **R \*apply** (slides 45-48): `apply()` annotated diagram; `replicate()` for
  Horn's parallel analysis simulation.
* **plyr** (slides 49-62; `fig/plyr-*.jpg`, `fig/2x3-*.jpg`, `fig/pliers.jpg`):
  split-apply-combine; the 3×4 grid of `aaply ... l_ply` names (input type × output
  type: a naming *grammar*); cube diagrams of array margins (from Wickham's slides/paper,
  so credit or redraw); the four-step strategy (solve one piece by hand, wrap in a
  function, apply to all); baseball example (1152 per-player models → density of R²).
  Code in `examples/baseball-ply.R`, `class-ply.R`, `aaply-ex.R`, `apply-ex.R`.

### Graphics
* Lattice slides 42-44 and `fig/lattice-*.jpg`: formula + conditioning as a
  graphics notation (bridge from formulas to a grammar of graphics).
* `fignew/inside-out-ggplot.png`: Claus Wilke tweet, ggtext markdown inside ggplot2
  (code beside plot). Mildly useful; shows how long a "grammar" call can get.
* `fig/UNplot1/2.jpg`: plot-formula examples (UN data).

### Economy / too many ways
* `fignew/lawful-chaotic.png`: Jacqueline Nolis tweet (2019), D&D alignment chart of
  nine ways to extract a column in R (`df[["y"]]` "lawful good" ... `pmap_int(...)`
  "chaotic evil"). Funny and on point for *economy*: a notation with too many ways to
  say the same thing. (Tweet screenshot: ask permission, or describe it and link.)
* `fignew/twitter-SQL.png`: Thomas Leeper (2020): SQL as "an interface to
  rectangular and relational data ... that will also always be conceptually helpful."
  Relevant to dplyr's verbs, which are essentially SQL.

### Coda
* Last slide: "This account (n=1) entirely impressionistic. ... How to study
  empirically? Experiment: tasks? population? language features?" A psychologist's
  question the post could end on (or hand to the "SEM Machine").
* `Tierney-JSM2019.pdf`: Luke Tierney on languages for statistical computing
  (from dynamic graphics to language design). Possible *Further reading*.

## Suggested next steps

* Replace the APL placeholder in `index.qmd` with the real history (APL → APL2 →
  APL2STAT with John Fox), and add `FriendlyFox:94` / `FoxFriendly:95` to `notation.bib`.
* Consider opening the hook with the 1962 Monroe calculator story instead of (or
  before) Bollen.
* Copy only the images actually used into `drafts/notation/images/`, not the whole folder.
* Screenshots of tweets and Wickham's plyr figures need credit/permission; APL
  screen captures and your own slides are yours.
