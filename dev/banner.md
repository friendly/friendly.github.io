# Banner Image Brainstorming

## Context

The new `friendly.github.io` site needs a banner image — for the site header and/or the blog listing page.
The older `datavis.ca` site used a recognizable visual identity:

- **Logo** (`logo1.jpg`): A profile silhouette of a head with gears/cogs inside the brain area,
  representing analytical/mechanical thinking. Text: "DataVis.ca / Michael Friendly / York University".
- **Masthead** (`datavis-masthead-v3.png`): A wide, dark banner with *two facing profiles* (Janus-like),
  filled with circuit-board/technical patterns, with the motto:
  **"Data Visualization: Looking back, going forward"**

The Janus motif is apt: Janus is the Roman god of beginnings, transitions, time, and duality — always
shown with two faces looking in opposite directions. For Michael's work it captures the dual identity of
historian of data visualization and active developer of modern methods.

---

## Available Visual Assets (in `images/`)

| File | Description | Notes |
|---|---|---|
| `hexsession-mypkgs.jpg` | Collage of ~13 R package hex stickers | Colorful, R-community recognizable; currently used as favicon |
| `VisMLM-cover.jpg` | 3D HE-plot ellipsoids on light blue | Visually distinctive; represents multivariate viz work |
| `DDAR-cover.png` | Mosaic/categorical plots, red background | Represents discrete data work |
| `FriendlyWainer-cover.jpg` | Wave/grid pattern on blue-gray | Elegant, abstract; history of data visualization book |
| `MF-Gemeni-crop.png` | Profile photo | Personal; already used on home page |

---

## Banner Options

### Option A: Revive the Janus Masthead (zero new work)
Reuse `datavis-masthead-v3.png` as-is, or lightly adapt it for the new site.

- **Pros:** Brand continuity with datavis.ca; already the right proportions for a web banner;
  the motto is perfect; dark background works with the cosmo/darkly theme
- **Cons:** Tied to the old site's visual language; circuit-board fill looks dated; text says "DataVis.ca" not the new site

**Verdict:** Good as a starting reference / placeholder. The motto should be kept; the image could be refreshed.

---

### Option B: Hex Sticker Panorama
Extend the existing `hexsession-mypkgs.jpg` into a full-width banner, perhaps with a gradient fade at the edges.

- **Pros:** Very recognizable in the R community; already exists; represents the packages work
- **Cons:** Only represents the packages facet; doesn't capture the history/scholarship dimension;
  the image resolution may not be wide enough for a crisp banner
- **Suited for:** The R Packages page specifically, or the blog if the blog is packages-focused

---

### Option C: Historical + Modern Split
A diptych banner: left half shows a historical statistical graphic (e.g., Playfair's trade charts, Minard's
Napoleon map, Nightingale's rose), right half shows a modern R visualization from your work
(e.g., an HE plot, mosaic plot, or genridge ellipses). The two halves meet in the center.

- **Pros:** Directly embodies the "looking back, going forward" theme without using Janus iconography;
  scholarly and distinctive; can be produced in R; **HistData is itself the perfect bridge** — it
  digitizes historical data for modern R use, so it naturally belongs at the join point
- **Cons:** Requires careful composition and some image editing for the transition zone
- **Refined concept:** A 4-zone strip rather than a hard diptych:
  1. Far left — scanned original historical figure (e.g., actual Minard or Playfair image)
  2. Left-center — R/HistData reproduction of the same data (ggplot2 re-vision)
  3. Right-center — HistData used in a modern analytical way (e.g., Galton regression)
  4. Far right — heplots HE-plot ellipsoids or genridge traces

---

## Tools for Option C

### Core approach: R + magick (fully reproducible, authentically "data viz")

This is the recommended path — everything stays in R, looks like real scholarly work, not AI art.

**Step 1 — Generate the individual panels in R:**

| Panel | Package / Code |
|---|---|
| Minard map (original scan) | Source from Wikimedia Commons or `HistData::Minard.troops` |
| Minard R reproduction | `ggplot2` + `HistData` — the classic Wilkinson/Wickham recreation |
| Nightingale coxcomb | `HistData::Nightingale` + `ggplot2` polar coord |
| Playfair wheat | `HistData::Wheat` + `ggplot2` |
| Galton regression | `HistData::Galton` + regression ellipse |
| HE plot (heplots) | `heplots::heplot()` — multivariate ellipses, like VisMLM cover |
| genridge traces | `genridge::plot.ridge()` |
| Mosaic plot | `vcdExtra` or `ggmosaic` |

**Step 2 — Compose and blend with `magick`:**

```r
library(magick)
# Read individual panel images
left  <- image_read("panel-minard-original.png")
lc    <- image_read("panel-minard-r.png")
rc    <- image_read("panel-galton.png")
right <- image_read("panel-heplot.png")

# Resize all to same height
panels <- c(left, lc, rc, right) |> image_resize("x300")

# Append side by side
banner <- image_append(panels)

# Apply gradient fade between panels using a mask
# (dissolve old into new across each boundary)
image_write(banner, "images/banner.png")
```

For a smooth morph/dissolve between panels, `magick::image_composite()` with a gradient mask
image achieves a photographic cross-fade. The `imager` package offers more pixel-level blending.

**Step 3 — Optional polish in Inkscape or Affinity Designer:**
- Export R plots as SVG for crisp vector output
- Import panels into vector editor
- Draw the transition zone (diagonal wipe, wave curve, or dissolve)
- Add motto text with a consistent font

---

### AI tools — what to use and what to avoid

**Avoid** (produces the over-saturated, fantasy-art, clearly-AI look):
- DALL-E / Bing Image Creator (Microsoft's "Image Creator" — sometimes called derogatory nicknames)
- Gemini image generation
- Standard Midjourney prompts without heavy style constraints
- Stable Diffusion with default samplers at high cfg-scale

**Potentially useful (controlled, non-photorealistic):**

| Tool | Use case | Why it avoids the AI look |
|---|---|---|
| **Stable Diffusion + ControlNet** | Style-transfer over your R plot output | Uses your actual plot as the structural skeleton (Canny/depth map); output follows your composition exactly |
| **Adobe Firefly** (Illustrator integration) | Generating a gradient/texture fill for the transition zone | "Reference image" mode stays close to inputs; vector output option |
| **Recraft.ai** | Generating illustration-style decorative elements | Built for design/brand work; outputs clean vector/SVG; avoids photorealism |
| **ChatGPT + DALL-E 3** with style prompt | Only if you need to fill a small decorative region | Prompt: *"scientific diagram, flat illustration, no gradients, clean line art, monochrome"* suppresses the AI look |
| **Inkscape's built-in AI trace** (`Path > Trace Bitmap`) | Vectorizing/stylizing an R plot output | Produces clean SVG outlines from bitmap input — looks like line art, not AI |

**Honest assessment:** For a banner that is authentically *you*, the pure R + magick approach will look
more credible than any AI-generated image. The AI tools are best reserved for:
- Generating a seamless gradient texture for the transition zone
- Upscaling a low-res historical scan cleanly (use **Topaz Gigapixel AI** or **waifu2x** — these
  are upscalers, not image generators, so they don't hallucinate new content)
- Removing JPEG artifacts from old scans

---

## Suggested First Prototype

Start simple to test the composition before investing in the polish:

1. Reproduce **Minard's Napoleon march** with `HistData` + ggplot2 (left panel) — this is well-documented
2. Create a **heplots HE plot** for a familiar dataset (right panel)
3. Stitch with `magick::image_append()`
4. Crop to banner proportions (1400 × 300 px)
5. Evaluate whether the juxtaposition reads clearly before adding a transition effect

Resources:
- Andrew Heiss's Minard ggplot reproduction: well-known tutorial
- `vignette("HE-examples", package="heplots")` for heplot output examples
- `magick` vignette: https://docs.ropensci.org/magick/articles/intro.html

---

### Option D: Updated Janus — Profiles Filled with Data (most ambitious)
Refresh the Janus concept: two facing head silhouettes, but instead of gears/circuits:
- Left profile filled with imagery from the history of visualization (old maps, Playfair charts)
- Right profile filled with modern R output (ellipsoids, mosaic tiles, hex colors)

- **Pros:** Richest conceptual fit; modern take on the established identity; unique
- **Cons:** Requires graphic design skill (Inkscape/Illustrator or R with `ggfx`/`magick`);
  most effort of all options
- **Suited for:** Main site header; could become the definitive new brand image

---

### Option E: Milestones Collage Ribbon
A horizontal strip of thumbnail images from the Milestones Project — famous historical
visualizations arranged chronologically left to right, representing the history of the field.

- **Pros:** Directly showcases the Milestones Project; visually rich; scholarly
- **Cons:** Requires sourcing many small images and composing them; copyright considerations
  for some historical images
- **Suited for:** A "History" or "Milestones" blog post banner, or the books page

---

### Option F: VisMLM Ellipsoids as Abstract Art
Crop and reframe the 3D HE-plot ellipsoids from the `VisMLM-cover.jpg` as a wide banner.
The overlapping translucent ellipsoids are visually elegant and abstract enough to work as art.

- **Pros:** Exists already; visually striking; represents your signature methodology (HE plots)
- **Cons:** Represents only one part of the work; the vertical cover format needs reformatting for a banner
- **Suited for:** Blog banner; could work with a semi-transparent overlay for text readability

---

### Option G: FriendlyWainer Cover Grid as Texture
The *History of Data Visualization & Graphic Communication* cover has a beautiful wave/grid pattern —
almost like a spectrogram or data art. This could be used as a full-width background texture with
title text overlaid.

- **Pros:** Elegant, abstract, and scholarly; the gridded wave reads as "data"
- **Cons:** Not obviously connected to the rest of the site; may not reproduce well at banner proportions
- **Suited for:** Blog banner (especially for history-themed posts)

---

## Motto Candidates

The original motto is strong and should probably be kept in some form:

> **"Data Visualization: Looking back, going forward"**

Variations to consider:
- *"Looking back at the history of data visualization — going forward with new methods"* (expanded)
- *"Data visualization: from Playfair to R"* (more concrete)
- No motto — let the image speak (cleaner, more modern web style)

---

## Recommendations

**For the main site header:**
- **Short term:** Use Option A (existing masthead) as a placeholder to see how it looks in the Quarto layout
- **Medium term:** Option C (historical + modern split) — achievable in R, distinctive, on-theme
- **Ideal:** Option D (updated Janus with data-filled profiles) if graphic design resources are available

**For the blog:**
- Option F (VisMLM ellipsoids) or Option G (FriendlyWainer grid) as a clean, elegant header image
- A separate, simpler banner per post using relevant figures from the post content is also standard practice

---

## Implementation Notes (Quarto)

A site-wide banner can be added via a custom `header.html` partial or CSS:

```css
/* In styles.css */
.banner-image {
  width: 100%;
  max-height: 300px;
  object-fit: cover;
  object-position: center;
}
```

Or as a hero section in `index.qmd`:
```markdown
![](images/banner.png){.banner-image}
```

For the blog listing page, Quarto supports an `image` field at the top of `blog/index.qmd` that appears
as a header image.

Banner dimensions to target: **1400 × 300 px** (wide, shallow) at 2× for retina = 2800 × 600 px source.
