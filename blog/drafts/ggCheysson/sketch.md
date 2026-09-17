# Sketch: "Émile Cheysson Meets ggplot2"

Status: **sketch only**, not started as `index.qmd`. Picking this up fresh (new machine/session)?
Read this whole file first, then see "Source material" below for where the real technical detail
lives.

## Framing

Time-travel dream conceit: the narrator discovers he can time-travel in his dreams. The *Albums de
Statistique Graphique* have long been on his mind, so one night he books a round-trip: YYZ (2026)
-> CDG (1896). [Running gags to plant early: do I need a visa? Is my passport *down*-to-date? Does
my time-travelling SKILL.md include provisions for building airplanes and airports?]

He arrives to meet Émile Cheysson and his draftsmen, bearing gifts - a bottle of Niagara ice-wine,
Canadian maple syrup - and his laptop, loaded with R 4.6.1 and a full library of ggplot2-adjacent
packages (each, naturally, with its own hex sticker, which needs explaining to a 19th-century
audience).

Framing questions for the "interview" with Cheysson:

- "What can we learn from each other?"
- "How should I design an R package to let my people craft beautiful graphics in your style?"
- "What might be hard about this once I'm back in Toronto?"

The post should use this framing as a light narrative wrapper around a genuine "making of
ggCheysson" retrospective - real design dilemmas hit while porting a 19th-century hand-drawn
graphic style into a modern, reproducible R package, told with more whimsy than a standard
package-development post.

## Candidate scenes / dilemmas (drawn from the actual ggCheysson `colorpat` branch work)

Each of these is a real thing that happened during development, with enough narrative shape to
carry a scene. Pick 4-6, not all of them - full technical detail for each is in
`C:\Dropbox\R\projects\ggCheysson\dev\TASKS.md` (search for the bolded phrase quoted below).

1. **Three men, three names for the same 25 plates.** The package's own naming scheme (album year
   + plate number), RJ Andrews' Advent-calendar labels (he released one plate per day every
   December), and Tom Shanley's Observable notebook IDs all describe the same 25 palettes, but
   agree on nothing. Building the crosswalk (`cheysson_labels`) surfaced two literal typos in
   Shanley's own ID strings. Good scene: showing Cheysson three different "index cards" for the
   same map and watching him not understand why there'd ever be three.
   - TASKS.md: "cross-checked the naming-collision finding against Tom Shanley's own IDs"

2. **The bug that ate five of Cheysson's plates.** The package derived palette names from a
   `Qty` field (a color count) instead of the real unique plate identifier, so 4 real collisions
   silently overwrote each other during data extraction - 5 of the original 25 plates were just
   *gone*, with no error, for months. Found while building a reconstruction of Andrews' own
   reference grid and noticing the numbers didn't add up. Great "detective story" beat: modern
   software silently discarding history through a data-modeling shortcut, discovered only by
   holding it up against the original.
   - TASKS.md: "built `dev/colorpat/RJ-Andrews-reconstruct.{R,png}`" / "**fixed the Album+Qty
     naming scheme itself**"

3. **Cheysson had no need of underscores.** While chasing a "why do the fonts look tiny/garbled"
   report, found that none of the 5 hand-drawn Cheysson font files contain a glyph for `_` at all
   (`systemfonts::glyph_info("_", ...)` returns `.notdef` for every one) - a palette name like
   `1880_21` rendered as a broken tofu box wherever it appeared in a Cheysson-styled title. Not a
   bug, exactly - just a character that never needed to exist in an 1880s hand-lettered alphabet.
   Fixed by rewording the text, not the font. This is a genuinely fun, ready-made line (the user's
   own, from the session that found it): *"Cheysson had no need of them!"*
   - TASKS.md: "checked `vignettes/getting-started.Rmd` for the same title/axis-title undersizing"

4. **Static paper vs. a resizable window.** A "the text is too small" bug report turned out not to
   be a proportion bug at all - the *relative* sizing was correct, matching `theme_minimal()`'s
   own ratios, but a vignette bakes plots into a fixed-pixel image, while Cheysson himself drew at
   whatever scale the printed page demanded. Confirmed by testing interactively in RStudio (where
   resizing the plot window rescales everything together) versus a static rendered HTML page. Nice
   thematic pairing: Cheysson's plates were engraved for one fixed page size; a modern ggplot2
   theme has to work at any size the viewer chooses, and that's a fundamentally different design
   problem, not a defect.
   - TASKS.md: "Before going ahead with this, I still wonder why this might be necessary..."
     (direct quote from the user, mid-investigation - could work as an epigraph or dialogue beat)

5. **Letting the title fill the page, on purpose.** Guerry's own 1830s choropleth maps used a
   title that nearly filled the map's horizontal width - a dramatically different hierarchy than
   any default ggplot2 theme, where the title is modest and the panel dominates. Redesigning
   `theme_cheysson_map()` to match meant *not* reusing ggplot2's usual title/body ratio, but
   inventing a new one specific to this historical poster style. A good "what can we learn from
   each other" moment: the 19th-century convention actively informed a 2026 design decision,
   not just its color palette.
   - TASKS.md: "checked `guerry-maps.Rmd` for the same issue - confirmed present, and a proper
     redesign of `theme_cheysson_map()`"

6. **(Optional, more meta/comic) The gift that Dropbox ate.** A recurring subplot this whole
   session: the repo lived inside a continuously-syncing Dropbox folder, which repeatedly
   corrupted `.git` mid-session (missing objects, stale index, phantom "selective sync conflict"
   folders) on two different machines. Could work as a short comic aside about 2026-era tooling
   fragility that even time travel doesn't help with - "I once lost an afternoon's work not to
   war, revolution, or shipwreck, but to a cloud-sync client."
   - TASKS.md: "## Git/Dropbox corruption"

## Source material (this package, `colorpat` branch)

- `C:\Dropbox\R\projects\ggCheysson\dev\TASKS.md` - the full, detailed development log for
  everything above (and more) - the primary source to mine for specifics, exact numbers, and
  direct quotes.
- Figures worth pulling in:
  - `man/figures/RJ-Andrews-color-palettes.jpg` and `man/figures/shanley-palettes.png` - the two
    "index cards" for dilemma #1
  - `dev/colorpat/RJ-Andrews-reconstruct.png` - the reconstruction that surfaced dilemma #2's bug
  - `dev/fonts/title_size_fix_base*_{minimal,cheysson}.png` - before/after pairs for dilemma #3/#4
  - Any of the `guerry-maps` vignette's rendered maps for dilemma #5 (large dominant title)
- `NEWS.md` (1.1.0 section) - a condensed, already-written summary of the substantive fixes, useful
  as a fact-check against whatever prose ends up in the post.

## Open questions for later

- How much real R code (reproducible chunks) vs. pure narrative? The "commit-history-vis" and
  "tired-horses" drafts in this blog show both styles are in use - pick per how technical this one
  should land.
- Title: user proposed "Émile Cheysson Meets `ggplot2`" - keep, or let the actual dilemmas chosen
  suggest something else once drafted?
- Does the time-travel frame carry a whole post, or work better as a short cold-open before
  settling into a more conventional "here's what I learned" structure?
