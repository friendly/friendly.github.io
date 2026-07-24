# Claude Instructions for friendly.github.io

## What this is
Personal academic/blog website for Michael Friendly, built with Quarto
(`_quarto.yml`) and published to GitHub Pages via the `docs/` output directory.

## Building / rendering
- Full site render: `./render-site.sh` (or `render-site.cmd` on Windows) —
  wraps `quarto render`, works around Dropbox file-locking issues, then
  copies `images/` into `docs/`.
- `blog/drafts/**` and all `*.md` files are excluded from the site build
  (see `_quarto.yml`) — drafts never appear on the published site no matter
  how they're rendered.
- Rendering a single `.qmd` only updates that file's own output. It does
  **not** refresh `docs/blog/index.html` or `docs/listings.json`, so a
  new or changed post won't show up in blog listings until a full site
  render runs. Do a full render before committing anything meant to appear
  there.

## Directory-specific guidance
- Blog writing — voice/style, per-series notes, DataViz reference material,
  BibTeX bib file locations: see `blog/SKILL.md`.
