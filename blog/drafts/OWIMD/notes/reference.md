# Reference items to check

Found while making `../references.bib` on 2026-10-30.

## In `references.bib`

- [x] **HE plots paper title.** Confirmed 2026-10-30: the published title is "HE Plots for
      Multivariate Linear Models", as in Crossref and `references.bib`. Fixed `Friendly:07:manova` in
      `vita.bib` and `graphics.bib` (`Friendly:04:manova`, the submitted version, keeps the old title).
- [x] **My book.** Kept year 2024 (copyright from the 2024 online draft); note changed from "In progress"
      to "To be published 2027" (2026-10-30). Same change made in `vita.bib`.

## In my R packages

- [x] **`heplots`:** `citation("heplots")` gave the 2007 paper the wrong title ("...Multivariate *General*
      Linear Models") and `number = 4`. Fixed in the source on 2026-10-30 (title, issue 2, DOI added),
      in `inst/CITATION`, `CITATION.cff`, the README, roxygen and `.Rd` files and `vignettes/HE-examples.bib`.
      Not committed yet; takes effect from the next release after 1.8.6.
- [x] **`candisc`:** `citation("candisc")` gave the URL as `package=heplots`, and the 2007 paper's old
      title. Both fixed and pushed on 2026-10-30; takes effect from the next release after 1.1.1.

The `.bib` already has the correct issue number and URL, so these two only need fixing in the packages.

## When publishing

- [x] Connect the `.bib` to `index.qmd` (done 2026-10-30). All 9 entries are cited; the book,
      HE plots paper and packages are cited next to their existing links.
- [ ] Update the package versions in the `.bib`, if they have changed. (Checked 2026-10-30: heplots 1.8.6,
      candisc 1.1.1 and mvinfluence 0.9.4 are the current CRAN versions.)
