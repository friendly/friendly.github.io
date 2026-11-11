# Notes: Shanley's Observable palettes vs. ggCheysson swatches

Source read: <https://observablehq.com/@tomshanley/cheysson-color-palettes> (version @2059,
ISC license, 2021), via its compiled module
`https://api.observablehq.com/@tomshanley/cheysson-color-palettes.js?v=4`, plus two of its
pattern attachments (`dec01.txt`, `dec11.txt`). Compared against ggCheysson `master`
(1.2.0.9000) in `C:\R\Projects\ggCheysson`: `R/swatches.R`, `R/show_swatches.R`,
`R/scale_patterns.R`, `dev/patterns/parse_patterns_v2.R`, `dev/TASKS.md`,
`dev/ggpattern-issue.md`.

(The package moved from `C:\Dropbox\R\projects\ggCheysson` to `C:\R\Projects\ggCheysson`;
sketch.md has been updated.)

## TL;DR

Shanley didn't have to *build* the patterns at all. RJ Andrews had already drawn every swatch
as an SVG `<pattern>` (exported from Illustrator, by the look of it), and SVG patterns are a
native fill type in the browser. So Shanley's whole "palette" machinery is: paste the SVG text
into `<defs>`, then fill shapes with `url(#id)`. The browser does the tiling, clipping,
transforms, dashes, dots and legend rendering.

ggCheysson starts from **the same 25 SVG files** (`data-raw/observable/decNN.txt` are
Shanley's attachments), but R graphics has no "fill with this SVG tile" primitive. So
ggCheysson has to *translate* each SVG into a parametric description (type, fill, line color,
angle, spacing), then *re-draw* it with gridpattern's stripe/crosshatch generators, and then
fit that through ggplot2's one-aesthetic-one-scale model. Nearly all of the work, and
nearly all of the bugs, happen in that translate and re-draw step and in the ggplot2
plumbing. Observable never needed either.

In one line: **Shanley passes the drawing along as it is; ggCheysson has to describe it and
then draw it again.**

## How Shanley's notebook works

### Data: one object per palette

Each of the 25 palettes is a cell like this (day 3 shown):

```js
const sequential12512012 = {
  displayName: "Sequential 12512.012",
  day: 3,
  type: "sequential",
  patterns: await FileAttachment("dec03.txt").text(),   // raw SVG <pattern> markup
  range:     ["sequential-12512012-1", ...],            // pattern IDs
  rangeURLs: ["url(#sequential-12512012-1)", ...]       // ready-made CSS fill values
};
```

`.range` and `.rangeURLs` are written out by hand: 134 IDs, each typed twice. A `palettes`
cell collects all 25 into one dictionary.

### What a swatch actually is: Andrews' SVG, passed through untouched

`dec01.txt` (diverging, 7 swatches) is tidy hand-written SVG:

```xml
<pattern id="diverging-12541021-2" x="0" y="0" width="3" height="3" patternUnits="userSpaceOnUse">
  <rect width="100%" height="100%" fill="#edddce" />
  <line stroke="#e16767" stroke-width="2px" y1="1" x2="100%" y2="1" />
</pattern>
```

`dec11.txt` uses a different style, an Illustrator-like export: a 100×100 tile with 17
explicit `<line>`s, `style="stroke:...;stroke-width:2px"` and a
`patternTransform="translate(20.31 72.24)"` offset.

Across all 25 files there are 134 `<pattern>`s holding 2023 `<line>`, 135 `<rect>`, and
158 `<path>` elements (all 158 `<path>`s in `dec12.txt`, the rounded white dots of
`1891_25`). There are also dashed strokes (`stroke-dasharray:12 8` in dec12 and `10 10` in
dec20, i.e. `1891_19`), and `rotate(-90)` / `translate()` pattern transforms. The browser
renders all of this without being asked. Shanley's code never looks inside a pattern.

### Swatches: about 20 lines of D3

The swatch strip (`radioLegend()`, and the larger `previewPalette()`) is:

```js
let svg  = d3.create("svg").attr("width", 20 * palette.range.length).attr("height", 20)
             .style("background-color", "#f9ece3");
svg.append("defs").html(palette.patterns);          // 1. inject the SVG patterns
svg.selectAll("rect").data(palette.rangeURLs)
   .enter().append("rect")
   .attr("x", (d, i) => i * 20).attr("width", 20).attr("height", 20)
   .style("fill", d => d);                          // 2. fill = "url(#id)"
```

The demo choropleth (US states) is the same thing on a bigger scale:
`d3.scaleOrdinal().range(palette.rangeURLs)`, then `.attr("fill", d => fill(...))`. The legend
is just more `<rect>`s with the same `url(#…)` fill. His usage instructions to readers come
down to three steps: import the palette, `svg.append("defs").html(p.patterns)`, then
`fill: url(#id)`, or put `rangeURLs` in any D3 scale (`scaleThreshold`, `scaleOrdinal`, ...).
The fourth step sets the paper color `#f9ece3`.

### Why it's easy

1. **The swatch is drawn already, and a swatch is just a name.** One string,
   `url(#grouped-12516011-4)`, stands for the whole bundle: paper color, line color(s),
   angle, spacing, line width, dashes, dots, offset. There's nothing to break apart into
   separate settings.
2. **Fills in the browser can be any paint.** A color and a pattern are interchangeable
   values of the `fill` property, so any D3 scale can return patterns as easily as colors.
3. **The legend is the same drawing as the plot.** No separate key-drawing code, and no zoom
   factor.
4. **Fixed pixel scale.** `patternUnits="userSpaceOnUse"` means the tile is the same size in
   pixels everywhere, in a 20 px legend square or across Texas. Andrews chose those sizes by
   eye once, and they stay as he chose them.
5. **No package or API contract.** It's a notebook: other notebooks `import {palettes}`, and
   that's the whole interface. No CRAN checks, no backward compatibility, no NA handling,
   no versions of a dependency to support.

## How ggCheysson does the same job

### Step 1: translate SVG into parameters (`dev/patterns/parse_patterns_v2.R`)

R can't fill a polygon with an SVG tile, so the parser *reads* each `<pattern>` with
regexes, line by line, and reduces it to a small spec:

```r
list(type = "stripe" | "crosshatch" | "solid",
     fill = <paper color or "transparent">,
     pattern_fill = <line color>, pattern_fill2 = <2nd color>,
     pattern_angle = <deg>, pattern_spacing = <measured>, pattern_linewidth = ...)
```

It works out the angle from the `x1,y1,x2,y2` of each `<line>` (`atan2`, then sorted into
horizontal / vertical / diagonal), and calls a pattern a crosshatch if it finds two
directions.

This translation step is where the real bugs were:

- **Valid SVG that the parser rejected.** Most of Andrews' `<line>`s leave out coordinates
  that default to 0 (e.g. `x1="-25" x2="125"` with no `y`). The parser required all four,
  silently dropped every line, and 15 swatches in 6 palettes came out as `NULL`. Fed to
  ggpattern, a `NULL` became `NA` and hard-crashed rendering. (TASKS.md, 2026-09-16.) In
  Observable this could never happen, because the browser applies SVG's defaults.
- **Two SVG dialects.** `dec01.txt` uses `x2="100%"` and `stroke="#…"` attributes; the
  others use `style="stroke:…"`. So the parser needed `parse_coord()` and broader regexes.
  A browser accepts both.
- **What the parameters can't express.** `1891_25`'s white dots (158 `<path>`s), the dashed
  stripes in `1891_19` and `1891_25`, the round line caps, and the per-tile offsets are
  dropped. TASKS item (3) is still open: "Dots / dashes the aesthetics can't express". So
  the R swatches are a *lossy* copy of Shanley's.
- `patternTransform="rotate(-90)"` is ignored by the parser. I checked: all the rotated
  patterns (in dec02, dec03, dec07) are crosshatches or +-grids, which look the same turned
  90°. So nothing was lost, but by luck rather than design.

### Step 2: re-draw each swatch with grid (`R/swatches.R`)

Each of the 134 swatches is registered with gridpattern as its own named pattern
(`"1886_28-1"`, ...). All of them share one drawing function:

```r
function(params, boundary_df, aspect_ratio, legend = FALSE) {
  spec <- swatch_spec(params$pattern)               # look up the parsed spec by name
  bg   <- polygonGrob(x, y, id, gp = gpar(fill = paper))
  if (spec$type == "solid") return(bg)
  lines <- gridpattern::patternGrob(
    if (spec$type == "crosshatch") "gridpattern::crosshatch" else "gridpattern::stripe",
    x, y, id, fill = spec$pattern_fill, fill2 = spec$pattern_fill2,
    angle = spec$pattern_angle, density = ..., spacing = ..., units = ...)
  grobTree(bg, lines)
}
```

plus `register_swatches()`, which has two code paths: `register_pattern()` for gridpattern
1.5.0 and later, and the `ggpattern_geometry_funcs` option for older versions. It's hooked
into `.onLoad()` through `rlang::on_package_load("gridpattern", ...)` because gridpattern is
only in Suggests.

### Step 3: get spacing and size right (the part Observable gets free)

Gridpattern spacing is a fraction of the plot (`"snpc"`) by default, not a fixed pixel size
like Andrews' tiles. So ggCheysson needed:

- a base spacing (0.025 snpc, or 0.3 cm) and density (0.3);
- **per-swatch spacing ratios**, measured from the parsed tiles and capped to [0.5, 2] because
  some measurements are implausible (`1883_21` is all placeholders, and `1891_19` runs from
  0.006 to 0.2), so that sequential palettes like `1888_27` still get denser at each step;
- an **"absolute" and a "relative" mode**, because ggpattern before 1.4.0 always supplies its
  own default `pattern_spacing` (0.05) and `pattern_density` (0.2), so a swatch can't tell
  whether the user set them;
- a documented **legend-key** caveat: ggpattern zooms the pattern in a key by a fixed factor,
  so thick stripes can look solid in the key. The workarounds are `pattern_key_scale_factor`
  or bigger keys.

In SVG, each tile simply *is* a size in pixels, so none of this comes up.

### Step 4: fit it into ggplot2's aesthetics (the real reason it took so long)

In ggplot2 each visual property is a separate aesthetic with its own scale. So the first
design (1.1.0) needed **five mappings and five scales** to apply one palette:

```r
geom_col_pattern(aes(fill = country, pattern = country, pattern_fill = country,
                     pattern_fill2 = country, pattern_angle = country), ...) +
  scale_fill_cheysson_pattern("1886_28") + scale_pattern_type_cheysson("1886_28") +
  scale_pattern_fill_cheysson("1886_28") + scale_pattern_fill2_cheysson("1886_28") +
  scale_pattern_angle_cheysson("1886_28")
```

Then came `aes_cheysson()` + a list-of-scales `scale_cheysson()`. Then a question to Trevor
Davis (ggpattern#154). Then three proofs of concept. Only then did it arrive at the current
design, where the swatch name *is* the pattern:

```r
ggplot(trade, aes(country, exports, pattern = country)) +
  geom_col_pattern() +
  scale_cheysson("1886_28")      # values = "1886_28-1", "1886_28-2", ...
```

That is exactly Shanley's design: **a swatch is a single name**, and the scale maps data
levels to names. It took ggCheysson months and a new gridpattern API (`register_pattern()`)
to get back to what `url(#id)` gives you on day one.

## The swatch atlases, side by side

| | Shanley `radioLegend()` / `previewPalette()` | ggCheysson `show_swatches()` |
|---|---|---|
| What gets drawn | SVG `<rect>` filled with `url(#id)` | `geom_tile_pattern(aes(pattern = swatch))` + `scale_pattern_identity()` |
| Source of the swatch | Andrews' SVG, untouched | parsed SVG, then re-drawn as gridpattern stripe/crosshatch |
| Code size | ~20 lines of D3 per strip | ~50 lines of ggplot2 (data frame, facets by type, theme), *plus* all of `swatches.R` behind it |
| Layout | one strip per palette, HTML forms/grid | one faceted plot, rows = palettes, panels = type |
| Size of tiles | fixed pixels (Andrews' tile sizes) | relative to the panel (snpc) |
| Dots, dashes, line caps, offsets | yes | no (lost in parsing) |
| Paper background | `#f9ece3` on the whole SVG | `"white"` behind hatches on `fill = "transparent"` |
| Dependencies | d3 v6 | ggplot2, ggpattern, gridpattern (Suggests), rlang |

## What R gets in return

These are worth saying in the post, so the comparison isn't one-sided:

- **Real scales.** `scale_cheysson()` does ordered selection (`select_values()`: light-to-dark
  spread for sequential/diverging when `n` < palette size), `reverse =`, NA handling, merged
  legends. Shanley's `rangeURLs` is a bare array; the D3 user does all of that themselves.
- **Geometry the swatch doesn't know about.** The same swatch fills bars, tiles, `sf` maps, and
  legend keys.
- **Data you can query.** `cheysson_patterns` is structured data (type, colors, angle,
  spacing) you can inspect, filter and plot, e.g. the color-wheel idea in TASKS.md. Shanley's
  patterns are SVG text: easy to render, hard to ask questions of.
- **Fonts, themes, `cheysson_labels`**: the rest of the package has no Observable
  counterpart.

## Small findings in the notebook itself (for dilemma #1, "three names")

Beyond the two ID typos already in TASKS.md (`diverging12541021` → `12514021`;
`category1252605` → `12526050`):

- `grouped1251203` (day 23, Rumsey 12512.**030**) also loses its trailing zero, the same
  slip as `category1252605`. Probably the "illegible" 25th ID in the earlier cross-check;
  worth confirming.
- Several `displayName`s are copy-paste leftovers: day 2 (`grouped12516024`) and day 4
  (`grouped12516017`) are both labeled **"Grouped 12541.021"**. That is day 1's number, with
  the transposition typo and the wrong type. Day 7 (`grouped12516011`) is labeled
  **"Grouped 12511.007"**, which is day 6's. Day 17 shows "Category 12526.05" and day 23
  "Grouped 12512.03".
- So the notebook has *three* naming layers that can disagree: the JS variable name, the
  pattern-ID prefix inside the SVG (`diverging-12541021-…`, copied from Andrews' files), and
  `displayName`. That's good material for the "Cheysson sees three index cards" scene: even
  inside one person's notebook, the card disagrees with itself.

## Possible framings for the post

- **"Cheysson drew; Andrews drew again; Shanley passed it along; I had to describe it and
  draw it a third time."** A nice chain: the engraver's plate → Andrews' hand-built SVG →
  Shanley's 3-step wrapper → ggCheysson's parse-and-redraw.
- Cheysson's draftsmen worked like SVG: a swatch was a *drawn thing* you copied. ggplot2
  thinks like a printer's spec sheet: angle 45°, spacing 0.025, color #b75533. Moving from
  one to the other is the hard part, and the bugs (missing coordinates, `100%`, dots that
  can't be described as parameters) all happen at that point.
- The happy ending: the final `scale_cheysson()` design, which treats a swatch as a name, is
  the R version of `url(#id)`. Shanley's notebook was already the right design, and the R
  stack needed `register_pattern()` before it could do the same.

## Open / to check

- Could ggCheysson skip the translation step entirely? R 4.1+ grid has
  `pattern()` fills (`grid::pattern(grob, ...)`), and `grImport2`/`rsvg` can turn SVG into a
  grob or raster. A swatch could be Andrews' SVG tile itself, used as a grid pattern fill,
  which would keep the dots and dashes. Not every graphics device supports pattern fills
  (`dev.capabilities()$patterns`), which may be why ggpattern does its own clipping. Worth a
  sentence in the post as "the road not taken", or a TASKS item.
- Confirm `grouped1251203` against `man/figures/shanley-palettes.png`.
