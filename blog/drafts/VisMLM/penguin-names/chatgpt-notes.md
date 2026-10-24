# Development notes: “Palmer Penguins Cry Out”

Based on `planning.md` and the current `index.qmd`, read October 23, 2026. These are editorial and analytical comments on those files, not an independent rerun of the analysis or verification of the external references.

## The central story

The strongest thread is already here: **a name makes a point memorable; a useful choice of variables explains why it deserves attention.** The correction from Hook Nose to Socrates gives that thread a satisfying personal consequence. Your own interpretation changes when you look more carefully at what was measured.

Keep three questions visible throughout: unusual on which measures, compared with whom, and does the name fit? They connect the book, Thompson’s poster, the transformed variables, and the six portraits without requiring every reader to follow the software development story.

The most valuable next step is to finish the currently unwritten interpretive sections before expanding the introduction or adding plots. The first half already has substantial narrative; the promised payoff is still largely in HTML comments.

## Suggested shape and pacing

1. Keep the penguin conversation and introduce the question about names quickly. Two exchanges are enough. The personality joke can return in the final sentence.
2. Tell the book’s three-bird story briefly, including the mistaken Hook Nose interpretation. Keep the QQ plot compact or put it in a collapsible aside if the opening feels slow.
3. Credit Thompson and introduce her four names. The admission that you had forgotten the source is engaging and worth keeping.
4. Bring “One view in 2D” forward so readers meet all six birds before the longer discussion of label selection.
5. Explain the new variables and the comparison group, then show the shape–stoutness plot as the main reveal.
6. Develop the gallery in contrasting pairs: Cyrano/Socrates, Falstaff/Tinkerbell, then BFG/Average Joe.
7. Close with what the names now mean, invite a name for case 183, and return to the personality scales.

“Who gets a label?” is relevant, especially for your R audience, but its implementation details currently delay the main reveal. Consider a short main-text version with the `noteworthy()` example and a callout for the `stat_noteworthy()` problems. It could also become a separate companion post. Retain the distinction between selecting points and drawing their labels: that is the part readers can reuse immediately.

## Fill the conceptual gap before the main figure

The “What makes a penguin unusual?” section needs two short paragraphs that work without reading the preceding posts. A possible starting point:

> A long bill is only part of a description. Is it also deep, or unusually slender? And a heavy penguin may simply be a large penguin. To separate these questions, I use bill length relative to bill depth, and mass relative to the cube of flipper length. The first describes bill shape; the second is an index of stoutness.
>
> The comparison matters too. Here I standardize each measure within species: zero is that species’ mean, and one unit is one of its standard deviations. A Gentoo-shaped bill on an Adelie is a different story from the same bill on a Gentoo. These are comparisons within species, with males and females together.

Then give the actual plotted formulas, `log(L / D)` and `log(M^(1/3) / F)`, with links to the earlier posts. Explain that the second has the same ordering as `M / F^3`. Describe stoutness as a proportion index using flipper length as a size proxy; it does not directly measure fatness, health, or physical body volume.

Do not needlessly introduce all four size/shape variables if only two are used in the main display. The other two can enter in a brief explanation of the BFG or a technical aside.

## Statistical wording and distinctions to resolve

- **“A true outlier” is too categorical.** The QQ plot supplies evidence relative to a reference model. Suggested wording: “Only Cyrano falls outside the plot’s 95% reference envelope.” Because these data combine three species, also distinguish this overall diagnostic from the later within-species comparison. Avoid making the envelope a biological verdict.
- **Raw extremes and standardized extremes differ.** Socrates has the smallest raw `L / D` among the 333 complete cases; case 183 is more extreme relative to its own species. Likewise, Falstaff has the largest raw stoutness index, while the planning table gives him rank 3 on absolute within-species stoutness z-score. Tinkerbell is least stout in the raw index and most extreme in absolute standardized stoutness. Keep “raw ratio,” “within species,” and “absolute z-score” explicit whenever reporting a superlative.
- **“Each named bird is extreme in a different direction” does not fit Average Joe.** Revise the main figure caption to something like: “The named birds occupy contrasting positions in bill shape and stoutness, standardized within species. Average Joe provides a reference near the center.”
- **Check the ellipse caption.** The `stat_ellipse()` layers specify nominal levels; they do not guarantee that exactly 68% and 95% of observed points lie inside. Prefer “Reference ellipses at nominal 68% and 95% levels.” If you want to say they enclose those proportions of the observations, calculate the observed coverage first. Make clear that these are pooled ellipses after within-species standardization.
- **Axis labels should describe the plotted values.** The code plots `z_shape` and `z_stout`, but the labels currently name the unstandardized log quantities. Add “within-species z-score.” On the vertical axis, use “leaner” and “stouter” with appropriate vertical direction, or simply explain low/high values in the caption; the current left-pointing arrow is confusing.
- **Species versus species-and-sex baselines:** `planning.md` uses species-and-sex means for some descriptive comparisons, while the draft’s z-scores use species alone. Both can be useful, but label the baseline where it changes. Average Joe can equal the male mean for flipper length without being exactly at the species-wide center.
- **Distance attribution:** the planning notes correctly acknowledge that squared marginal z-scores do not sum to Mahalanobis distance when correlations remain. Avoid saying a particular variable “accounts for” an exact portion of D² without defining the decomposition. The gallery can make its point with ratios and standardized values instead.
- **The BFG classification result:** if included, call 0.97 a fitted LDA posterior probability under the stated two-variable model, rather than an unqualified probability that the bird is a Gentoo. The simpler visual statement may suffice. If you discuss the four-variable classification, the planning notes say it narrowly favors Chinstrap, not Adelie.
- **Eye versus algorithm:** “Her eye was doing something the formula wasn’t” is a good sentence, but judging within species is an interpretation of the labels. Consider “Her annotations invite a comparison with each bird’s own species.” Average Joes represents a trend rather than an outlier.

## Develop the gallery around a few memorable facts

Aim for roughly 70–110 words per bird: what the measurements show, one revealing comparison, and a verdict on the name. Avoid reproducing the entire table in prose.

| Bird | Best detail to develop | Qualification worth retaining |
|---|---|---|
| Cyrano | Bill ratio 3.26; long and slender, with short flippers adding stoutness | Female; the literary name describes a feature, not sex or personality |
| Socrates | Short *and* deep bill; raw ratio 1.64 | Depth does not establish curvature; case 183 is more unusual after species standardization |
| Falstaff | 4650 g on 184 mm flippers; ordinary bill | “Stoutest” refers to the chosen raw proportion index |
| Tinkerbell | 2700 g despite ordinary female Chinstrap flipper length | “Lightest” is more precise than “smallest”; she is not simply a miniature bird |
| The BFG | Longest Adelie flippers, 210 mm; lean proportions | Large relative to Adelies; the overall and within-species distance ranks answer different questions |
| Average Joe | Ordinary Gentoo proportions and a central reference | He is a comparison bird, not an experimental control |

The Socrates paragraph should make the correction plainly: “I had mistaken bill depth for curvature.” That small admission does more teaching than a long methodological warning. Explain the snub-nosed association briefly, with a checked source or footnote before publication.

For Falstaff and Tinkerbell, emphasize that shape can differ even when no single raw length is remarkable. For the BFG, the rank change from 89th overall to 3rd within species is an excellent illustration of “compared with whom?”—provided the calculation and distance definition are documented.

## Tables, figures, and the banner

The ten-column table will be hard to read on a phone. Consider a short main-text table with name, species, bill ratio, stoutness z-score, and a plain-language distinguishing feature. Move raw measurements and sex into a collapsible table. Include units wherever raw measurements remain: mm for bill and flipper lengths, g for mass.

The current table order uses `abs(z_shape) + abs(z_stout)`. That is a convenient sorting rule, not the Mahalanobis ranking. Either state the rule or use the gallery’s narrative order so readers do not infer a formal ranking.

The main transformed plot deserves the most visual space. Before adding another figure, ask whether each of the QQ plot, bill-length/depth plot, Thompson poster, and reconstructed Thompson view has a distinct role. The poster establishes provenance; the reconstructed view lets readers follow the six birds; the transformed view explains their differences. These are the essential three for this particular story.

Use `images/penguin-names-banner-v3.png` for the selected banner. Its colors and body shapes support the story, but the deliberately doubled Cyrano bill is caricature rather than a scale drawing. A short caption can say so. Suggested alt text:

> Six penguins in sunglasses on Antarctic ice, colored purple, orange, and green by species, with contrasting body shapes and an exaggerated long bill on Cyrano at the left.

If you add a left-to-right key, the order is Cyrano, Socrates, Falstaff, Tinkerbell, the BFG, Average Joe. Distinguish the proposed names from the established ones in the prose rather than relying only on question marks in every plot label.

## Possible ending

> Cyrano keeps her name. Hook Nose gets a correction, and Socrates seems a better fit. Falstaff finally gets a name, while Tinkerbell and the BFG earn theirs in different ways. Average Joe reminds us what ordinary looks like. The names help me remember the birds; the variables help me explain them.
>
> There is still a Gentoo, case 183, waiting for a name. And the personality scales will have to wait.

This is a possible direction, not a replacement for your voice. The ending will be stronger if it returns to the birds rather than the unfinished software.

## Practical finishing order

1. Write the missing explanatory paragraphs and six gallery entries.
2. Decide how much of “Who gets a label?” belongs in the main narrative.
3. Reconcile superlatives, baselines, figure captions, and the distance calculations before finalizing prose.
4. Add links to the two preceding posts and complete “Further reading.” Check quotations, attribution/license wording, literary references, and software claims against their original sources.
5. Set a real publication date; replace the banner TODO; add figure alt text and units; remove obsolete planning comments. The source header still points to `penguin-names.md`, while the local planning file supplied here is `planning.md`—clarify the intended source reference.
6. Render and inspect the table, labels, color distinctions, and main plot on desktop and at a narrow reading width. Confirm that prose rankings match the rendered results.

No source draft or analysis was changed for these notes.
