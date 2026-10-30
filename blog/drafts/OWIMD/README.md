# Our World in Multivariate Data

Draft blog post: multivariate views of Our World in Data's chart "How is life at different levels
of GDP per capita?": 12 outcome measures vs. GDP per capita. Moved here on 2026-10-30 from
`C:\Dropbox\Documents\images\OurWorldInData`. Open `OWIMD.Rproj` to run things; all paths are
relative to this folder, and `quarto render index.qmd` works from here too.

| file | purpose |
|---|---|
| `index.qmd` | the post; self-contained, with all code inline. **This is the master copy.** |
| `R/get-LifeGDP.R` | builds `data/` from the OWID series, downloading to `data-raw/` any not already there |
| `R/00-setup.R` | transforms and orients the responses; builds `OW`, `cc`, `Z` |
| `R/01-profiles.R` … `R/07-whole-data.R` | one script per section of the post |
| `data/LifeGDP.RData` | `LifeGDP` (198 countries × 12 responses + GDP), `LifeGDP_year` (data year of each value) |
| `data/LifeGDP.csv`, `data/LifeGDP-year.csv` | the same two tables as CSV |
| `data-raw/` | the OWID series as downloaded |
| `images/` | `Life-GDP.jpg` (the OWID chart), `LifeGDP-replica.png` |
| `notes/LifeGDP-notes.md` | early notes on the data and ideas, and questions for Max Roser; its results predate the post |
| `notes/OWIMD-with-notes.qmd.txt` | the post as of the move, with all the commented "Points to make" and TODOs. Named `.txt` so Quarto won't render it. |

The `R/0*.R` scripts are for running a section on its own (each sources `R/00-setup.R` if needed).
They are not used by `index.qmd` and may fall out of sync with it.

`OWIMD-share.html` is a standalone page for sharing, not tracked by git:
`quarto render index.qmd --to html -M embed-resources:true -o OWIMD-share.html`

## Next: turning `OWIMD.qmd` into a draft blog post

Status (2026-10-30): steps 1-5 and 9 below are done. Prose is written through the covariance
section; whole-data views have figures only, and Lessons is still a short list.

**Destination:** `C:\R\Projects\friendly.github.io\blog\drafts\OWIMD\`. Read
`blog/SKILL.md` (voice, style, AI-writing tells) and the repo `CLAUDE.md` first. Model the
post on a recent Vis-MLM post, e.g. `blog/posts/2026-10-peng-altviews/`.

Blog conventions (from the repo, 2026-10-29):

- A post is a folder with `index.qmd`, plus an `images/` folder for static images (not
  `figures/`). Drafts live in `blog/drafts/<name>/`. They are excluded from the site build
  (`_quarto.yml`: `!blog/drafts/**`), so they can be rendered locally without being published.
- On publication the folder moves to `blog/posts/YYYY-MM-<slug>/` (e.g. `2026-11-owimd`).
- R figures are generated at render time (`execute: freeze: auto`), not saved as PNGs.
- Posts that use data from a package load it with `data(..., package = )`.
- Typical YAML: `title`, `subtitle`, `description` (one sentence, for the listing),
  `author`, `date`, `categories` (this series uses `Vis-MLM`), `image` (listing thumbnail in
  `images/`), `format: html: toc, code-fold: show, fig-width/fig-height`, and
  `execute: message/warning: false`. Some posts add a `css:` file.
- Posts start with a hidden setup chunk:
  `knitr::opts_chunk$set(comment = "#>", fig.align = "center")`.

Steps:

1. **Create `blog/drafts/OWIMD/`** with `index.qmd` copied from `OWIMD.qmd`. Rewrite the YAML
   to match the template above. Drop `draft: true` (drafts/ already does that), add
   `description`, `image`, and `categories: [Vis-MLM, R, multivariate, ...]`. Remove the PLAN /
   SKETCH comment.
2. **Static images go in `blog/drafts/OWIMD/images/`:** `Life-GDP.jpg` (the OWID chart, CC-BY),
   and update the path in `@fig-owid`. For the listing thumbnail, either save one R figure
   (development profiles or HE plot) as a PNG in `images/`, or use the OWID chart.
3. **Data.** Copy `LifeGDP.RData` into the post folder and load it from there. It is not in a
   package yet (adding it to heplots is an option for later, as `data(LifeGDP, package =
   "heplots")`). Optionally put `LifeGDP.csv` and `get-LifeGDP.R` there too, and link them
   for download.
4. **Code display.** Switch `code-fold: true` to `code-fold: show`, as in other posts? Keep
   the setup and transform chunks hidden or folded. Consider dropping raw printed output (e.g.
   MANOVA tables) where the text already quotes the numbers.
5. **Remove working notes.** Strip all `**Points to make**` lists and the `<!-- R/... -->`
   comments, after resolving or moving the remaining `?` / TODO items (below).
6. **Revise the prose for voice (SKILL.md).** The current text leans heavily on bullet lists,
   which SKILL.md flags ("bullet-point fragmentation"). Turn many of them back into prose.
   Vary sentence length, add catchier section headings, and use Wikipedia links for technical
   terms (MANCOVA, Pillai's trace, biplot, canonical discriminant analysis, ...).
7. **Links / references.** Add links to the earlier Vis-MLM posts (penguins) and HE plot posts,
   the book (*Visualizing Multivariate Data and Models in R*), the heplots, candisc and
   mvinfluence packages, the OWID chart and the X post. Maybe add a `## Further reading`.
8. **Write the remaining sections** (outliers, covariance by income, whole-data views) and the
   Lessons / conclusion.
9. **Render the draft** (`quarto render blog/drafts/OWIMD/index.qmd`) and check
   cross-references (`@fig-`, `@tbl-`), figure sizes, inline values, and that nothing depends
   on this Dropbox folder or the `R/` scripts.
10. **To publish (later):** move to `blog/posts/YYYY-MM-owimd/`. Do a **full** site render
    (`render-site.cmd`), not just the post, so that `docs/blog/index.html` and
    `docs/listings.json` update. Stage all changed `docs/` files with the source.

### Open items to resolve before publishing

- Missing-data note: show the missingness pattern; is multiple imputation worth it?
- Profiles: try a monotone fit (`scam`) or trimmed GDP range; check the ordering with other
  smoothers or percentile scaling; bootstrap intervals for the thresholds.
- Residual sections use `mod2` (GDP only); HE plots use `modR` (GDP + region). Decide whether
  to keep this or switch the residual analyses to `modR`.
- Check Mozambique and data vintages generally (`LifeGDP_year`): Guyana's LifeSat is from 2011;
  Palestine's GDP is post-2023 war.
- Biplot (`fig-biplot`): vector labels hide some country labels.
- Hard-coded fold ranges ("15-fold", "30-fold") in the thresholds text could be computed inline.
- Optional: `heplot3d()` widget; Y biplot with log GDP as a supplementary vector.
- `R/01b-profile-labels.R` (trial labelings for the profiles figure) can be deleted.
- `images/LifeGDP-replica.png` predates the rename and still labels a panel `Electric`. The code
  that drew it wasn't saved; `fig-smoothed` in `index.qmd` is the closest version.

Data: Our World in Data (CC-BY).
