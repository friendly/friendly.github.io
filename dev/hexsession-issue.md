# hexsession issue: Using hexsession easily in Quarto/Rmarkdown HTML documents

`hexsession` is a potentially very useful package, but it has quirks that make it less practically and easily usable by applications.

It should be able to be used in Quarto for HTML output easily, but there is no documentation or examples of how to do this.
See: https://github.com/luisDVA/hexsession/issues/13

I solved this for my [`packages.qmd`](https://friendly.github.io/packages.html) page (source: [packages.qmd](https://github.com/friendly/friendly.github.io/blob/master/packages.qmd)). Below is what worked, what didn't, and the problems it surfaced with `hexsession` (version 0.1.0) that might be useful to the maintainer or to others hitting the same walls.

## Basic display in HTML

There is no simple examply in the documentation, but
the basic case is easy and needs no special chunk options — `make_tile()` returns an `htmltools::HTML()` fragment, and knitr/rmarkdown already has a registered `knit_print` method for that class, so it auto-prints as raw HTML:

````
```{r}
#| echo: false
#| message: false
library(hexsession)
make_tile(packages = c("heplots", "candisc", "vcdExtra"))
```
````

You will need to add `#| results: asis` once you start building the HTML yourself with `cat()` (see below) rather than just returning `make_tile()`'s result directly.

The wrinkle is `make_tile()`'s behavior depends on `getOption("knitr.in.progress")` and `knitr::is_html_output()`. Inside a Quarto HTML render both are `TRUE`, so `make_tile()` takes the "in `knitr`, HTML output" branch: it strips the `<head>`/`<body>` wrapper off its internal template and returns a `<div class="hexsession-container">` containing just the inner `<script>`, `<div class="main">`, and `<style>` blocks. That's convenient for dropping into a chunk's output — but see "Dark mode" below for why keeping the `<style>`/`<script>` in that fragment is also the root of the worst problem.

## Duplicate logos

Both console rendering and in-document use suffer if a package has several logo-like images under `man/figures/` (e.g. `logo.png` + `logo-old.png` + `logo.jpg`) — `make_tile()`'s auto-picker prompts interactively to choose one:

```
Package: twoway - Multiple possible logos. Please select the image to use:

1: logo-old.png
2: logo.jpg
3: logo.png
4: None of the above
```

An interactive `readline()`-style prompt firing mid-render clobbers use in a Quarto/Rmarkdown document (there's no console to answer it) — the render just hangs or errors depending on context.

**Workaround** — resolve the ambiguity myself before calling `make_tile()`, using `local_images =` / `local_urls =` instead of `packages =`, preferring a file _literally_ named `"logo.png"`:

```r
resolve_logo <- function(pkg) {
  files <- list.files(system.file(package = pkg),
                       pattern = "\\.png$|\\.jpg$|\\.svg$",
                       recursive = TRUE, full.names = TRUE)
  matches <- files[grepl("hex|logo", files, ignore.case = TRUE)]
  if (length(matches) == 0) return(NA_character_)
  preferred <- matches[basename(matches) == "logo.png"]
  if (length(preferred) >= 1) preferred[1] else matches[1]
}

logos <- vapply(pkgs, resolve_logo, character(1))
urls  <- vapply(pkgs, function(p) {
  url <- packageDescription(p)$URL
  if (is.null(url)) paste0("https://cran.r-project.org/package=", p) else strsplit(url, ",")[[1]][1]
}, character(1))

make_tile(local_images = logos, local_urls = urls)
```

**Feature request**: an argument like `check_dups = c(TRUE, FALSE)` (default `FALSE` outside an interactive session, or auto-detected via `interactive()`) that resolves duplicates by a documented default rule instead of prompting — so `packages = ` keeps working unattended in a render.

## Controlling the height & width

What I tried first: render the tile in the console, manually resize the window, and screenshot it. That's what the static `images/hexsession-mypkgs2-2row.png` on the page currently is — but it bakes in whatever background color happened to be behind it, doesn't update when packages/logos change, and obviously isn't interactive.

Moving to a live, in-document `make_tile()` call surfaced two real problems, neither really fixable from the caller's side:

1. **No size arguments.** `make_tile()` has no `width`/`height`/`cols`/`rows` argument — tile size is fixed by CSS custom properties (`--s: 100px` at desktop width, stepping down via two `@media` breakpoints) baked into the template, and the number of columns is whatever wraps naturally in the available width. Wrapping the output in `htmltools::div(style = "max-width: 600px; ...")` controls the *width* fine, but there's no way to ask for, say, "3 rows" or a specific pixel height.

2. **A stray scrollbar / clipped bottom.** With the wrapping `<div style="max-width:600px">` approach, the tile grid either grew a vertical scrollbar or had its bottom ~10% clipped, depending on the surrounding page's CSS. Root cause: the template's `.attribution` element ("created with hexsession") is positioned `absolute` with `bottom: -44px` relative to `.main { position: relative }` — i.e. it deliberately renders *below* the visible bounding box of the tile grid. That's invisible to `scrollHeight`-based measurement unless the measuring element itself is in normal flow, and it also interacts badly with any ancestor that sets `overflow-x: auto` (in my case, Quarto's own `.cell-output-display { overflow-x: auto }` rule) — per the CSS overflow spec, setting only one of `overflow-x`/`overflow-y` to a non-`visible` value forces the browser to compute the *other* axis as `auto` too, so that ancestor grew an unwanted vertical scrollbar that clipped the grid.

**Feature request**: at minimum, expose the tile size / column count as arguments (e.g. `tile_size`, `cols`, or an overall `width`/`height`), and consider making `.attribution`'s negative-offset absolute positioning optional (or keep it in normal flow) so the rendered fragment's own bounding box is self-contained and doesn't require extra space the caller can't predict.

## Dark mode

This was the most surprising problem, and I think it's a real design issue in the `in_html_knitr` code path specifically (the one used for Quarto/Rmarkdown HTML output), not just a styling clash.

`make_tile(dark_mode = )` is a **static boolean baked in at generation time** — `generate_hexsession_js()` interpolates `tolower(as.character(dark_mode))` directly into the emitted `<script>` as `const darkMode = false;` (or `true`). It's not a live `prefers-color-scheme` media query and can't respond to a theme toggle that happens after the page loads (e.g. Quarto's own light/dark switcher).

That alone is a minor annoyance. The bigger problem is *where* that setting gets applied. The internal template (`_hexout_template.html`) styles the **real `<body>` element**, not a class scoped to the widget:

```css
body {
  background-color: var(--bg-color);
  color: var(--text-color);
  font-family: ...;
}
```

...with `--bg-color`/`--text-color` set via `document.documentElement.style.setProperty(...)` on `:root` at `DOMContentLoaded`. That's fine when `make_tile()`'s output is the *entire* standalone page (the non-knitr code path, which keeps `<html>`/`<head>`/`<body>`). But in the `in_html_knitr` branch, the function strips the `<body>` tags and returns everything *between* them — including this `<style>` block — as a fragment meant to be dropped into someone else's page. The `body { ... }` rule doesn't get scoped or removed; it just now targets the **host document's** `<body>`.

Concretely, on my site (Quarto, `theme: { light: cosmo, dark: darkly }`, dark mode toggled via a `.quarto-dark` class on `<body>`):

- `make_tile()`'s injected `body { background-color: #ffffff; color: #000000 }` rule (from the default `dark_mode = FALSE`) collided with the site's own dark-mode CSS.
- Because of how the two rule sets and Bootstrap's CSS layers interacted, the *background* stayed pinned to the widget's hardcoded value regardless of the site's theme, while the *text color* still tracked the site's dark-mode variable — so toggling dark mode left the page's actual `<body>` background stuck light-ish while unrelated text elsewhere on the page (package card descriptions, styled only via inherited `body` color) turned white, i.e. white-on-white.
- This had nothing to do with my card CSS — it was `hexsession`'s fragment quietly overwriting `body`'s `background-color`/`color` for the whole page it was embedded in.

**This looks like a bug, not just a styling clash**: in the fragment/embed code path, styling the bare `body` selector is unsafe by construction, since the caller's own `<body>` almost certainly already carries meaningful styling (here, an entire dark-mode theme). Scoping those rules to `.hexsession-container` instead (e.g. `.hexsession-container { background-color: var(--bg-color); color: var(--text-color); }`) would fix this without changing anything about the standalone-page code path.

**Feature request**: also consider supporting a live `prefers-color-scheme: dark` media query as an alternative to (or default for) the baked-in `dark_mode` boolean, so embedded tiles can track the reader's OS/browser theme without needing a re-render.

## What I had to do to make it work

`htmltools::div(style = "max-width: 600px; ...", make_tile(...))` got the width right but, per the two sections above, left either a scrollbar/clipped bottom or a body-styling collision (or both) depending on what else was on the page — and there was no way to fix either from the caller's side, since both come from CSS/JS baked into `make_tile()`'s own fragment.

The fix I landed on: render `make_tile()`'s fragment into a **sandboxed `<iframe srcdoc="...">`** instead of injecting it directly into the page. That scopes its `<style>`/`<script>` (including the problematic `body { ... }` rule) to the iframe's own document, so it can no longer touch or be affected by the host page's CSS. Since the iframe's content height isn't known ahead of time (it depends on how many packages are tiled) and `srcdoc` iframes have an opaque origin (no direct DOM access from the parent to measure it), the iframe posts its rendered height back to the parent via `postMessage`, and the parent resizes the iframe to fit:

```r
widget_html <- as.character(make_tile(local_images = logos, local_urls = urls))

doc <- sprintf('<!DOCTYPE html><html><head><meta charset="utf-8"><style>
html, body { margin: 0; padding: 0; background: transparent !important; }
.main { padding-bottom: 8px; }
.attribution {
  position: static !important;
  display: block;
  text-align: right;
  color: #888 !important;
  background: transparent !important;
}
</style></head><body>%s
<script>
function hexsessionReportHeight() {
  var h = document.documentElement.scrollHeight;
  window.parent.postMessage({ hexsessionHeight: h }, "*");
}
window.addEventListener("load", function() {
  hexsessionReportHeight();
  setTimeout(hexsessionReportHeight, 50);
});
window.addEventListener("resize", hexsessionReportHeight);
</script>
</body></html>', widget_html)

cat(sprintf(
  '<div style="max-width: 600px; margin: 20px auto;">
<iframe id="hexsession-frame" srcdoc="%s" style="width: 100%%; height: 320px; border: none; display: block;" scrolling="no"></iframe>
</div>
<script>
window.addEventListener("message", function(e) {
  if (e.data && typeof e.data.hexsessionHeight === "number") {
    var f = document.getElementById("hexsession-frame");
    if (f) { f.style.height = e.data.hexsessionHeight + "px"; }
  }
});
</script>',
  htmltools::htmlEscape(doc, attribute = TRUE)
))
```

Notes on that snippet:
- `.attribution { position: static !important; ... }` pulls the "created with hexsession" credit back into normal document flow, so `scrollHeight` measures it correctly instead of missing the `bottom: -44px` overflow.
- `background: transparent !important` on `html, body` overrides the widget's own hardcoded `--bg-color`, so the tile grid blends into whatever's behind the iframe rather than showing a hardcoded white/dark box.
- The full `packages.qmd` chunk (with the package list, `resolve_logo()`, and comments on *why* each override is there) is at [packages.qmd](https://github.com/friendly/friendly.github.io/blob/master/packages.qmd).

## Summary of asks for `hexsession`

1. **Bug**: in the `in_html_knitr` fragment code path, don't style the bare `body` selector — scope those rules to `.hexsession-container` (or similar) so embedding a tile can't silently override the host document's body background/text color.
2. **Feature**: an option to suppress the interactive duplicate-logo prompt (e.g. `check_dups = FALSE`, or auto-detect via `interactive()`) with a documented default resolution rule, so `packages = ` works unattended in a render.
3. **Feature**: expose tile size / layout controls (`tile_size`, `cols`, or overall `width`/`height`) instead of a fixed CSS-only layout.
4. **Feature**: consider a live `prefers-color-scheme` option as an alternative to the static `dark_mode` boolean, so embedded tiles can track the reader's theme.
5. **Nice to have**: some official guidance/example for embedding `make_tile()` output in a Quarto/Rmarkdown HTML doc — the `in_html_knitr` branch is discoverable in the source but undocumented, and its assumptions (owns the whole page) don't match how it's actually used (embedded fragment in someone else's page).
