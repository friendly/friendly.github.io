# Reference items to check

Found while making `../references.bib` on 2026-10-30.

## In `references.bib`

- [ ] **HE plots paper title.** Crossref has "HE Plots for Multivariate Linear Models", but `vita.bib`
      and the R citations say "HE plots for Multivariate *General* Linear Models". The `.bib` uses
      Crossref's title. Confirm it against the paper, then correct whichever is wrong
      (`Friendly:07:manova` in `vita.bib`).
- [ ] **My book.** `Friendly:2024:VisMLM` copies `vita.bib`: year 2024, "In progress". Update it if the
      year or status has changed.

## In my R packages

- [ ] **`heplots`:** `citation("heplots")` gives the 2007 paper as `number = 4`. Crossref and `vita.bib`
      have issue 2. Package version checked: 1.8.6.
- [ ] **`candisc`:** `citation("candisc")` gives the URL as `package=heplots`. It should be
      `package=candisc`. Package version checked: 1.1.1.

The `.bib` already has the correct issue number and URL, so these two only need fixing in the packages.

## When publishing

- [ ] Connect the `.bib` to `index.qmd`: add `bibliography: references.bib` to the YAML, change the
      citations in the text to `[@key]` form, and replace the typed list under `## References`.
- [ ] Update the package versions in the `.bib`, if they have changed.
