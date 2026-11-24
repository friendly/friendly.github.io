# Fireside HE chat: notes on editing the banner

*2026-11-22.* For the banner of *How Big Is a Matrix?* *2026-11-24:* the banner is now
`fireside-HE-chat-V3.jpg`, V2 with Georges Monette in seat 6 (prompt 5). The table and prompts 1–4
below refer to the original, `fireside-HE-chat.png`. The cast and original prompts are in
`fireside-HE-chat.md`. This folder was `images/` until 2026-11-24; it's now `figures/`, as in
the other posts.

![The current image, V3](fireside-HE-chat-V3.jpg)

## In brief

Comparing the original drawing with photographs, more than Roy needed fixing.

| Seat (from left) | Cast as | As drawn | In the photos | What to do |
|---|---|---|---|---|
| 1 | Hotelling | slim, wavy dark hair, glasses | heavy-set, straight hair, no glasses | **Rename as Wilks**, whom he already resembles |
| 2 | Wilks | bald, mustache, glasses | full wavy hair, clean-shaven, glasses | **Redraw as Hotelling** |
| 3 | Pillai | slim, thick wavy hair, glasses | bald, full face, no glasses | **Redraw** |
| 4 | Roy | white-haired white man (generated as Lawley) | Indian, full face, dark graying hair | **Redraw first**: he is the joke |
| 5 | Friendly | curly gray hair, beard, glasses | curly gray hair, shorter beard, no glasses | Optional touch-up |
| 6 | Wickham | short hair, beard, bow tie | short hair, reddish beard | **Redraw as Georges Monette** (2026-11-24) |

## What to keep

- **Roy's pointing hand.** The geometry works. Estimated from the drawing, the direction of Roy's
  largest root is about 13° above horizontal, and the long axis of **H**, where his finger is, is
  about 17°.
- **The ellipses**, exactly as drawn: $\lambda_1 \approx 5.3$, $\lambda_2 \approx 0.2$, one dominant
  root, the case that favors Roy.
- **The colors**: red **E** and blue **H**, as in heplots and to go with the first banner.
- **The composition**, and Pillai holding the sheet.

## Editing prompts

Edit one seat at a time, in this order, starting each edit from the last good result. Attach only
something based on the reference photo for that seat. If there's a selection tool from the reference photo,
select just the head (plus the
hands, only if skin tone must change). After each step, check that the ellipses, the two letters
and the pointing finger haven't moved.

### 1. Seat 4: Roy (attach `refs/Roy.jpg`)

> Edit only the fourth seated man from the left. Make him S. N. Roy, an Indian (Bengali)
> statistician in his fifties, using the attached photograph for his likeness: full round face,
> dark hair graying at the sides, heavy dark eyebrows, clean-shaven, no glasses. Give his face and
> hands a natural, matching skin tone. Keep his pose, suit, gaze and pointing hand exactly where
> they are, and draw him in the same illustration style. Do not change the sheet, the ellipses,
> the letters or anyone else.

### 2. Seat 3: Pillai (attach `refs/Pillai.jpg`)

> Edit only the head of the third seated man from the left, who holds the sheet. Make him
> K. C. S. Pillai, an Indian statistician, using the attached photograph for his likeness: bald on
> top with short hair at the sides, full face, clean-shaven, no glasses. He must be clearly a
> different person from the man to his right in the picture. Keep the head angle, downward gaze,
> suit, hands and illustration style. Do not change the sheet, the ellipses, the letters or anyone
> else.

### 3. Seat 2: Hotelling (attach `refs/Hotelling.png`)

> Edit only the head of the second seated man from the left. Make him Harold Hotelling, using the
> attached photograph for his likeness: broad heavy face, straight dark hair combed back from a
> high forehead, clean-shaven, no glasses. Keep the head angle, pose, suit, open hand and
> illustration style. Do not change anything or anyone else.

### 4. Seat 5: Friendly, optional (attach `refs/Friendly.png`)

> Edit only the head of the fifth seated man from the left, using the attached photograph for his
> likeness: tousled curly gray hair, short gray beard and mustache, smiling, no glasses. Keep the
> head angle, pose, clothing and illustration style. Do not change anything or anyone else.

Leave out "no glasses" if you'd rather keep them.

### 5. Seat 6: Georges Monette (attach `refs/GeorgesMonette.png`)

*2026-11-24.* Start from `fireside-HE-chat-V2.jpg`. Seat 6 becomes Georges Monette, who gets
credit in the post for "ellipses have shadows". He must look clearly different from Friendly,
next to him: Friendly has curly gray hair and a beard; Georges is clean-shaven, with straight
hair and glasses.

> Edit only the sixth seated man, at the far right, who now has a reddish beard and a bow tie.
> Make him Georges Monette, using the attached photograph for his likeness: a man in his
> seventies with thick, straight white-silver hair swept up and back, a broad round face,
> clean-shaven, thin rectangular glasses, and a wide, warm smile. Replace the bow tie with a
> plain dark tie, to match the others. Keep his profile, head angle, gaze toward the sheet,
> gesturing hand, suit and seat exactly where they are, and draw him in the same illustration
> style. He must be clearly a different person from the gray-bearded man next to him. Do not change the sheet, the ellipses, the letters, the cups, the book or anyone else.

To keep his open-collared shirt from the photo instead, change the tie sentence to: "Replace
the bow tie with an open-collared pale lavender shirt, no tie."

Check afterwards: the two white-haired men in seats 5 and 6 should read as two different
people even at thumbnail size, and the three right-hand figures should still look toward the sheet.

**V3 edit, 2026-11-24.** Used ImageGen with `refs/GeorgesMonette.png` to redraw seat 6
with swept-back silver hair, rectangular glasses, a clean-shaven smile, and a plain dark
tie. Blended the new portrait and tie into V2 to preserve the surrounding illustration,
including Roy's pointing hand and the original red E and blue H ellipses and labels.

### 6. Elemental Forces on the coffee cups

V4 starts from `fireside-HE-chat-V3.jpg`. ImageGen adapted the artwork from
`elemental-forces-V2.jpg` into small decals, which were blended into the original
cup faces. From left to right, the cups show **Algebra** (a diagonal matrix),
**Graphs** for Michael Friendly (a scatterplot with an elliptical contour), and
**Geometry** for Georges Monette (a blue ellipsoid and its shadow).

![V4 with the Elemental Forces coffee cups](fireside-HE-chat-V4.jpg)

## Reference images

| | Person | File | Source |
|---|---|---|---|
| ![](refs/Roy.jpg){width=120} | S. N. Roy (1906–1964) | `refs/Roy.jpg` | [Wikipedia](https://en.wikipedia.org/wiki/File:SamarendraNathRoy.jpg), non-free; also [MacTutor](https://mathshistory.st-andrews.ac.uk/Biographies/Roy/) |
| ![](refs/Pillai.jpg){width=120} | K. C. S. Pillai (1920–1985) | `refs/Pillai.jpg` | [MacTutor](https://mathshistory.st-andrews.ac.uk/Biographies/Pillai/), rights not stated; only 147 × 180 px |
| ![](refs/Hotelling.png){width=120} | Harold Hotelling (1895–1973) | `refs/Hotelling.png` | **Your portraits folder**: `C:\Dropbox\Documents\milestones\images\portraits\HaroldHotelling.png` |
| ![](refs/Hotelling-older.jpg){width=120} | Hotelling, older | `refs/Hotelling-older.jpg` | [Wikipedia](https://en.wikipedia.org/wiki/File:Harold_Hotelling.jpg), non-free |
| ![](refs/Wilks.jpg){width=120} | S. S. Wilks (1906–1964) | `refs/Wilks.jpg` | [Wikipedia](https://en.wikipedia.org/wiki/File:Samuel_S_Wilks.jpg), non-free; a profile view at [MacTutor](https://mathshistory.st-andrews.ac.uk/Biographies/Wilks/) |
| ![](refs/Friendly.png){width=120} | Michael Friendly | `refs/Friendly.png` | This site's avatar, `images/MF-face.png` |
| ![](refs/GeorgesMonette.png){width=120} | Georges Monette | `refs/GeorgesMonette.png` | Added by MF, 2026-11-24; replaces Wickham in seat 6 |
| ![](refs/Wickham.jpg){width=120} | Hadley Wickham | `refs/Wickham.jpg` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Hadley-wickham2016-02-04.jpg), by Hadley Wickham, CC BY-SA 4.0; no longer in the banner |
| *none found* | D. N. Lawley (1915–2012) | | No MacTutor or English Wikipedia page. Try the Royal Society of Edinburgh or University of Edinburgh archives. |

`refs/` was git-ignored at first, because several photos are non-free and this repo is public.
*2026-11-23:* MF chose to commit them anyway, so they travel with the drafts. Use them as
references only, and don't copy them into a published post. The links above give the sources.

## Before using the banner

- [x] Redraw seats 4, 3 and 2 (done in V2, along with touch-ups to 1 and 5).
- [x] Update the cast in `fireside-HE-chat.md`: Wilks, Hotelling, Pillai, Roy, Friendly,
      Monette, left to right (Wickham until V3).
- [ ] Account for Lawley, perhaps in the caption: "(Lawley sends his regrets.)" With no photo,
      don't add an invented likeness.
- [x] *2026-11-24, done:* replace Wickham (seat 6) with **Georges Monette**, who gets
      credit for "ellipses have shadows" in the post. Done in ChatGPT, with prompt 5 above.
  - [x] Reference photo in `refs/GeorgesMonette.png`.
  - [x] Save the result as `fireside-HE-chat-V3.jpg` (1400 × 700 px).
  - [x] Point the post's banner and `image:` line at V3.
  - [x] Update the cast in `fireside-HE-chat.md`, and the banner caption in `index.qmd`, which
        now names Georges.
- [ ] Send Georges the picture before the post is published with his name in the caption.
- [x] Recheck that Roy's finger is still at the right-hand end of **H**.
- [x] Make a 1400 px JPEG from the final version, for the post and its `image:` line: V3 is one
      (1400 × 700, 429 KB). When the post is published, only that gets copied; V2 and the PNG
      can stay behind in drafts.
- [x] Write the `fig-alt` from the final image (2026-11-24, from V3).
