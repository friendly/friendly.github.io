# How to Manage Your Chunks

OK, you've written an R-based book with extensive code examples — all analyses and figures
are reproducible from source. But now, for publication in both online and print form, you ask:
is it really necessary to show all that code inline?
A reviewer of my book [*Visualizing Multivariate Data and Models in R*](https://friendly.github.io/Vis-MLM-book/)
commented that there was too much code on display, and that the book could be shortened
by folding or hiding some of it.

## Folding code in HTML and PDF

With Quarto, it is easy to fold code in HTML using the chunk option `code-fold`:

````
```{r}
#| label: fig-my-plot
#| code-fold: true
#| code-summary: "Show the code"
#| fig-cap: "A scatterplot"
ggplot(data, aes(x, y)) + geom_point()
```
````

This renders a collapsed "Show the code" button in HTML that the reader can expand at will.
Setting `code-fold: show` makes code visible but still collapsible; `code-fold: false` forces
it always open.

But `code-fold` is an HTML-only feature — it has no effect on PDF output, where the code
will still appear in full. For print, the relevant option is `echo`. You can suppress code
entirely in PDF while keeping it foldable in HTML with a small `knitr` trick: put
`echo=knitr::is_html_output()` directly on the chunk header line (not as a `#|` comment,
which won't work):

````
```{r echo=knitr::is_html_output()}
#| label: fig-my-plot
#| code-fold: true
#| code-summary: "Show the code"
#| fig-cap: "A scatterplot"
ggplot(data, aes(x, y)) + geom_point()
```
````

Now the code is hidden in PDF and folded-but-available in HTML. The two options work
independently: `echo=knitr::is_html_output()` controls whether code reaches the output at
all; `code-fold` controls how it is presented once it does.

<!-- TODO: maybe add a side-by-side screenshot of HTML folded vs PDF suppressed? -->

## What else is worth tracking?

Once you start thinking systematically about code chunks in a large project, other questions
come up naturally:

- **Label style**: Quarto recommends `#| label: my-chunk` (YAML-style, inside the chunk body),
  but old-style knitr labels `` ```{r my-chunk} `` are still valid. A book that started before
  Quarto may have a mix. It would be nice to know which files still use the old style.
- **Figure inventory**: which chunks produce figures (`fig-cap` set, label starts with `fig-`),
  what size are they (`fig-width`, `fig-height`, `out-width`)?
- **Unlabeled chunks**: chunks without labels can't be cross-referenced and are harder to
  audit. How many are there?
- **Dead code**: chunks with `eval: false` don't run at all — useful to know when reviewing.
- **Code volume**: how many lines of non-trivial code are in each chunk? Longer chunks are
  the higher-payoff targets for folding.

## Building a chunk database

The idea is simple: treat your `.qmd` source files as data and use R to parse them.
Each code chunk becomes one row in a data frame, with columns for the attributes above.

In R, code chunks start with a line matching `` ```{r `` and end at the next line that is
exactly ` ``` `. Everything in between is either a `#|` YAML option line or code. That
structure is regular enough to parse with base-R string tools — no specialised package
needed.

```r
parse_file_chunks <- function(file) {
  lines  <- readLines(file, warn = FALSE)
  starts <- grep("^```\\{r", lines)          # chunk openings

  lapply(starts, function(s) {
    # find the closing ```
    e <- s + which(grepl("^```\\s*$", lines[(s+1):length(lines)]))[1]

    chunk_lines <- lines[(s+1):e]
    opts <- chunk_lines[grepl("^#\\|", chunk_lines)]   # YAML options
    code <- chunk_lines[!grepl("^#\\|", chunk_lines) &
                        !grepl("^```\\s*$", chunk_lines)]

    list(
      label     = get_opt(opts, "label"),     # #| label: value
      code_fold = get_opt(opts, "code-fold"),
      echo_html = grepl("echo=knitr::is_html_output()", lines[s], fixed=TRUE),
      n_code    = sum(nchar(trimws(code)) > 0)
    )
  })
}
```

For a full book project like *Vis-MLM*, with 19 source files and three active child files,
this produces a tidy data frame of 669 chunks with 17 fields:

```r
load("data/chunks.RData")
dplyr::glimpse(chunks)
```

<!-- TODO: insert actual glimpse() output here -->

The fields include: `chapter`, `file`, `line`, `label`, `has_label`, `old_style`,
`is_fig`, `echo_html`, `echo_header`, `echo_opt`, `code_fold`, `code_summary`,
`eval`, `fig_cap`, `out_width`, `n_code_lines`, and a derived `fold_status`.

## The `fold_status` field

The key derived field is `fold_status`, which combines `code_fold` and `echo_html` into a
single summary:

| `fold_status` | Meaning |
|---|---|
| `"both"` | `echo_html` + `code-fold: true` — fully treated |
| `"fold-only"` | `code-fold: true` but no `echo_html` — HTML folds, code still in PDF |
| `"echo-only"` | `echo_html` but no `code-fold` — PDF hidden, but code visible in HTML |
| `"fold-show"` | `code-fold: show` — always shown, but collapsible |
| `"fold-false"` | `code-fold: false` — explicitly kept visible |
| `"no-eval"` | `eval: false` — chunk doesn't run |
| `"neither"` | No fold treatment at all |

For the *Vis-MLM* book, the breakdown across 281 figure chunks is:

```
fold_status   n
neither     227    ← potential targets for future folding
fold-only    19    ← HTML folded, but code still appears in PDF  (incomplete)
both         14    ← fully treated (Gavin's audit, this round)
fold-show    15
fold-false    4
no-eval       3
```

The 19 `fold-only` figure chunks are a useful finding in themselves: they were folded in HTML
(probably added before the book targeted PDF), but code still appears in the printed version.
Those are candidates for a follow-up pass.

## Practical uses

With `chunks.RData` in hand, a few lines of R answer questions that would otherwise require
manually scanning thousands of lines of source:

**Which figure chunks still need folding treatment?**
```r
chunks[chunks$is_fig & chunks$fold_status == "neither",
       c("chapter", "label", "n_code_lines")]
```

**How many old-style chunk labels remain?**
```r
sum(chunks$old_style, na.rm = TRUE)   # 150 in Vis-MLM
```

**Which chapters have the longest unfolded figure code?**
```r
library(dplyr)
chunks |>
  filter(is_fig, fold_status == "neither") |>
  group_by(chapter) |>
  summarise(total_lines = sum(n_code_lines), n_figs = n()) |>
  arrange(desc(total_lines))
```

**Cross-checking a reviewer's audit**: given a list of chunk labels a reviewer flagged
for folding, join against `chunks` to confirm each has been treated and report its
`fold_status` automatically — no manual searching through source files required.

<!-- TODO: could link to the annotate-audit.R script or show a snippet -->

## Summing up

For a large Quarto/knitr book project, treating code chunks as data pays off quickly.
The parsing logic is straightforward — chunks have a regular open/close structure and
`#|` options are easy to extract. The resulting data frame supports systematic auditing,
reviewer cross-checks, and bulk edits that would be tedious to do by hand.

The full script (`chunks.R`) is available as a GitHub gist <!-- TODO: add gist link -->.
Adapt the `active_files` list and the `child_files` vector to your own project structure,
and you should be able to build a similar database in a few minutes.

<!-- TODO: check whether knitr or any other package already provides something like this -->
