# Publishing note: turning "On Extending `lm()` Methods to `"mlm"`" into a journal article

*Started 2026-11-23. Planning notes only.*

## Why it's worth a paper

The post has a thesis that is not in any of my earlier papers: extending `lm` to `mlm` is mostly a *software-design* problem, not a statistical one, and the same move solves it each time (find the matrix that plays the role of the scalar, then find a way to see it, usually as an ellipse). The earlier papers each cover one package or one method. This one lines up 20 years of them (heplots, candisc, mvinfluence, `robmlm()`, genridge) and draws out the general lessons, plus a list of open problems ("Un-Vized Problems") that invites other developers in.

That makes it a cross-cutting *perspective/review* paper, not a new-method or new-software paper. That shapes the choice of journal.

## Candidate journals

1. **The American Statistician (TAS)** --- first choice. Its Statistical Computing and Graphics section takes this kind of reflective, broad-audience piece, and I've published there before (Friendly & Sigal 2020, equality of covariance matrices). The "lessons learned" framing and the Kronecker-product thread suit the general statistical readership. Risk: reviewers may see it as too R-specific or too much a summary of my own packages.

2. **Journal of Statistical Software (JSS)** --- a step down for this piece, as noted. JSS expects a paper centred on one piece of software, with full reproducible code. It would fit better as "the `mlm` methods across heplots/candisc/mvinfluence/genridge", but that loses the general argument. Prior JSS paper: Friendly 2010 (HE plots for repeated measures).

3. **Other options to consider:**

   - *The R Journal* --- natural audience for "an invitation to R developers"; open access, quick. Lower prestige than TAS, but the right readers.

   - *Journal of Computational and Graphical Statistics (JCGS)* --- where HE plots (2007) and the generalized ridge trace plot (2013) appeared. Probably wants more new methodology than this has.

   - *Statistical Science* --- published "Elliptical Insights" (2013). A long shot unless the paper leans much harder on the geometry and history.

   - *WIREs Computational Statistics* --- review-style articles; often by invitation.

## What has to change from the blog post

- [ ] **Lead with the thesis, not the story.** The post is told in the first person, in time order. A paper should state the general claim in the abstract and introduction, then use the packages as evidence.

- [ ] **Related work section.** Put the post in context: my earlier papers (JCGS 2007, Comp. Stat. 2009, JSS 2010, Stat. Sci. 2013, JCGS 2013, TAS 2020), Fox's work on `car` and `effects`, and other software for multivariate linear models in R and elsewhere (SAS PROC GLM/MANOVA, Stata `mvreg`). Say clearly what is new here compared with each.

- [ ] **Tighten the scope.** About 9,700 words with 8 figures now. Check the TAS length limit and cut to fit. Candidates for cutting or moving to supplementary material: the repeated-measures subsection, some of the code listings, and the detailed `robmlm()` implementation notes.

- [ ] **Make the "what `lm()` methods do with an `mlm`" table a formal Table 1.** It is the hook (see `notes.md`) and it is reproducible.

- [ ] **Turn the conclusion's bullet list into a short "Principles" section.** These are the paper's main contribution: the statistics were the easy part; find the matrix that plays the role of the scalar; know what doesn't change; the Kronecker product keeps the two dimensions apart; inheritance is a promise.

- [ ] **Strip blog-only material:** the HTML/CSS framed thesis quote, `code-fold`, the "To cite this article" block, and links into the online book.

- [ ] **Reproducibility.** Provide all code as supplementary material (or a GitHub repo), with package versions. genridge `mlm` support needs to be on CRAN before submission, or be described as in development.

- [ ] **Format.** Rewrite as a Quarto article using a journal template (e.g. the `quarto-journals` ASA template, if it fits TAS) or as LaTeX.

## Things to check before submitting

- [ ] **Overlap with the book.** *Visualizing Multivariate Data and Models in R* (CRC/T&F) is in production. Any figures or passages reused from it may need permission from CRC, even though TAS is also published by T&F. Prefer new figures made for the paper.

- [ ] **Prior publication.** Check the target journal's policy on material already posted on a blog or preprint server. Safest: keep the blog post as a draft until the paper is submitted, then publish it and say so in the cover letter, or post a preprint (arXiv stat.CO) at the same time.

- [ ] **AI-use statement.** T&F journals require disclosure of AI tool use. Record now which parts were drafted or edited with AI help (the conclusion is marked as a first draft written for me), so the statement is accurate.

- [ ] **Co-authors?** Consider whether John Fox or Georges Monette should be invited, given how much of the story runs through `car` and our joint papers.

## Next steps

1. Finish and publish the blog version (or hold it --- see "Prior publication").
2. Decide on TAS versus The R Journal: TAS if the general argument can be made to stand without the R detail, The R Journal if not.
3. Draft a 250-word abstract around the thesis, as a test of whether the general argument stands on its own.
