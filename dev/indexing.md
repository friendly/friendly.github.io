# Indexing: blog post draft and helper code

## Files

- `blog/drafts/quarto-indexes/index.qmd` — draft blog post "Creating Book Indexes in Quarto"
- `blog/drafts/quarto-indexes/indexing.R` — extracted R helper functions (see below)
- `blog/assets/images/pdflatex-diagram.png` — LaTeX workflow diagram used in the post

## Blog post

Part of the *Making of Vis-MLM* series. Covers:
- Why dual HTML/PDF Quarto output makes indexing hard
- The `pkg()`, `package()`, `dataset()`, `func()` inline helper functions
- Corresponding LaTeX macros (`\ixp`, `\ixd`, `\ixfunc`, etc.) in `preamble.tex`
- The underscore problem in `\index{}` entries and how `escape()` solves it
- Avoiding duplicate index entries via macro routing

YAML header uses `description:` (not `subtitle:`), `categories: [quarto, latex, indexing, books]`,
and `image: "../../assets/images/pdflatex-diagram.png"`.

### Image paths in blog posts

Two contexts, two rules:

**YAML `image:` field** (listing thumbnail) — Quarto must physically locate the file
to copy it to `docs/`, so a relative path is required:
```yaml
image: "../../assets/images/pdflatex-diagram.png"
```
This works unchanged whether the post is under `blog/drafts/slug/` or
`blog/posts/YYYY-MM-DD-slug/` — both sit at the same depth below `blog/`.

**`<img src=...>` in content** — use a site-root-relative path with a leading `/`;
Quarto websites resolve `/` from the project root, matching `here::here()` for R:
```html
<img src="/blog/assets/images/pdflatex-diagram.png" width="40%">
```
This works from any post at any depth, and is stable across draft→publish moves.

## indexing.R

Extracted from `C:\R\projects\Vis-MLM-book\R\common.R` (the indexing section only).
Book-specific machinery (`.to.cite`, `write_pkgs`, `read_pkgs`, `clean_pkgs`) was excluded.

**Dependencies:** `colorize`, `stringr`, `dplyr`, `knitr`

**Functions:**
| Function | Purpose |
|----------|---------|
| `escape(name)` | Replaces `_` with `\_` for LaTeX display text |
| `tt(name)` | Builds a `sort@\texttt{display}` makeindex entry fragment |
| `pkg(package, cite)` | Formats package name; adds `\ixp{}` index entry for PDF |
| `package(package, cite)` | Like `pkg()` but appends "package" after the name |
| `dataset(name, package)` | Formats dataset name; adds `\ixd{}` and optionally `\ixp{}` |
| `func(name, package, test)` | Formats function name; adds `\ixfunc{sort}{display}` entry |

Configuration globals `pkgname_font` and `pkgname_color` control the appearance
of package names across `pkg()` and `package()`.

The file includes the full set of LaTeX macro definitions as a comment block,
making it self-contained for use as a GitHub gist.

To use in a chapter or blog post:
```r
# in a setup chunk with include: false
source("indexing.R")
```
