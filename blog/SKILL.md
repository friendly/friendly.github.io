---
name: blog-writing
description: Use this skill to work with me on writing blog posts
author: Michael Friendly
version: 1.0
---

Working notes on how to write with me, blog post by blog post. Start here,
add to it as we go — nothing below is final.

## Voice & style (general)

Applies broadly, but lean into it hardest for the quirky/fun series (Beach
Science, Chevaliers, anything under "A Year of Living Quirkily"). Dial it
back for posts on graphic methods, dataviz history, or other more academic
topics — those keep my usual register.

* Use a voice similar to what I've been writing in the series at hand —
  don't default to a generic "blog voice"
* Don't sound like AI
* Catchy titles, headings, and well-turned phrases — but don't force a pun
  where none belongs
* Give concrete examples of ideas / concepts / contrasts in the text, e.g.:
  > "Life is filled with choices, some small (what to have for breakfast),
  > some quite large (what field to work in, what city to call home)"

**Avoid AI writing tells** (fine in moderation; watch for overuse)

These patterns are common AI defaults that make prose feel generated rather than written:

* **Causal pivot** — "This isn't just X — it's Y." One per post is fine; three is a tic.
* **Em-dash as all-purpose connector** — avoid using it as a substitute for commas,
  periods, or semicolons throughout. Reserve for genuine asides or punchy breaks.
* **Rule of three everywhere** — not every idea needs to be presented as a triplet
  (problem–solution–outcome, speed–scale–security). Break the pattern occasionally.
* **Rhetorical inflation** — framing ordinary observations as profound. "The beach
  has no choice but to be interesting" is fine once; the same move repeated becomes
  a tell.
* **Bullet-point fragmentation** — don't break flowing argument into bullets just to
  impose structure. Prose is often better.
* **Sterile smoothness** — perfect grammatical consistency with no tonal
  irregularities reads as machine-made. A stray informal aside, a parenthetical
  aside that goes slightly too far, or an abrupt short sentence all help.

**Sentence length & structure**
  + Mix short, punchy sentences with longer ones that carry parenthetical
    asides
  + Vary sentence length for flow
  + Keep paragraphs short — mainly one thought each, but not a hard rule

**Vocabulary**
  + For a themed series (e.g. beachy language for Beach Science), draw on a
    wide range of on-theme adjectives, nouns, verbs — but don't overdo it to
    the point of annoyance
  + Nominalization (verb → noun) or the reverse (noun → verb, to suggest
    action) are both fair game, used sparingly
    
**References**

This is not academic writing, but I do want to cite sources and give links to references
for further information.

  + Use links for information about technical and other terms used in the text. Often Wikipedia is a good source.
  Example: [wind-chill](https://en.wikipedia.org/wiki/Wind_chill) refers to ...
  
  + If I mention a historical person I've written about, use a link to my paper, e.g.,
  [**André-Michel Guerry**](http://euclid.psych.yorku.ca/datavis/papers/guerryvie/GuerryLife2-SocSpectrum.pdf)

For some posts, it would be useful to have an actual `## References` section at the end, or something called
`## Further reading`

**Images**
In general, I'd prefer to have captions for figures, unless the information in the graph is sufficient.

## Series-specific notes

### Beach Science (BS)

Humor/science series founding the fictional discipline of "Beach Science" —
questions inspired by lying on a beach towel at Leucate Plage, France.

House style, established starting with BS-Warmup:
* **Banner image**: `title-block-banner` with CSS `min-height` and
  `background-position` set via `include-in-header` to control framing
* **Emoji on `##` section headings** — one per major heading (e.g. 👣 🏛️ 🧠 🌊)
* **Float-right images** within sections:
  `{style="float:right; margin-left:1.5em; margin-bottom:1em; width:45%"}`
* **Series footer**: end each published post with a "Posts in This Series"
  `##` section — published posts as links, drafts as plain text marked
  *(coming soon)*
* **Links**: ancestor names bold + linked to Wikipedia; key works/artifacts
  linked to historyofinformation.com or other authoritative sources

### Chevaliers (des Albums de Statistique Graphique)

Just getting started — style notes TBD as the first posts take shape.

### A Year of Living Quirkily

The umbrella theme for the sabbatical blog-writing project, tying together
Beach Science, Chevaliers, and future sub-series. Deliberately quirky, maybe
corny, occasionally cringe-worthy — but FUN. Posts are explicitly
work-in-progress: expect revision/extension after publishing rather than
treating anything as closed.

There's a second, distinct register that lives under this same umbrella: the
excitement of a great statistical graphics idea (mosaic plots, fourfold
plots, corrplots, effect ordering) or an elegant R function/package. Same
spirit of following genuine excitement, different voice from the
corny/quirky narrative pieces — don't force the beach-towel voice onto these.

## Workflow / mechanics

* Each post gets its own dated folder under `blog/posts/`
* **Always do a full `quarto render` (or at least re-render `blog/index.qmd`)
  before committing a new post** — rendering only the post's `.qmd` leaves
  `docs/blog/index.html` and `docs/listings.json` stale, so the new post
  won't show up on the blog listing page
* Stage all changed `docs/` files together with the source `.qmd`

## Open / backlog

* Flesh out Chevaliers style notes once a post or two exists
* Revisit vocabulary guidance per-series as more series start (right now
  it's mostly informed by Beach Science)
