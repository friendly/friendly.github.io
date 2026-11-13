# Editing notes for “Whodunnit? Reanalyzing Lutz’s Miss Marple data”

The draft is clear for readers who know Lutz’s article. The distinction between odds ratios and discrimination comes through, and “Whom would Miss Marple accuse?” gives the reanalysis a question worth following. The opening reads like a methods summary. Bring that question and the main result forward, then trim the explanations of R output where the tables and folded code already carry the detail.

## Changes I’d make first

1. **Open with the finding.** After the citation, try something like “Lutz’s rankings hold up, but her reported odds ratios need correcting. When I score suspects one novel at a time, family ties and financial gain identify a killer 68% of the time. Adding the web-based AI guess raises the held-out hit rate to 76%, though it is unclear what the AI knew about the endings.” Give the three AI inputs their short names on first use. Lutz (p. 12) supplied Chapter 1 in one condition, gave the novel title and asked the AI to find Chapter 1 in another, and pasted a chapter around the 20% point in the third. “The ~20% passage” can sound like the first fifth of the book.

2. **Explain exactly what is held out.** Replace “predicting the killer in a novel you haven’t read” with “ranking suspects in a held-out novel using the existing character codes and AI guesses.” The regression is refit on 11 novels, while the held-out novel’s AI flags are already available. Lutz (pp. 14–15) also notes that financial motives and relationships can be revealed late. Mention that limitation beside the first held-out result. In the doubledecker discussion, say that the two cases are consistent with the AI having access to plot knowledge. The plots show where the advantage occurs. They cannot identify its source.

3. **Name the hit-rate denominator and use like-for-like comparisons.** The score is the expected chance of accusing one actual killer when choosing one person from the highest-scoring set, averaged equally over the 12 books. Lutz’s web figure of 64% credits a correct identification even when other suspects are named (p. 13). A brief example or a sentence explaining the difference would help readers reconcile the two numbers. For the web-augmented model, 85% → 76% is the conditional-logit comparison. The ordinary logistic model is about 76% both times. For a compact summary, use conditional-logit hit rates throughout and identify the pooled logistic AUC separately. The runner-up conditional models scored 75% in cross-validation, so describe 76% as the highest observed hit rate in this sample.

4. **Show one numerical correction before the model details.** Table 1 describes logistic regressions (Lutz, p. 13). Show what reproduces the financial-gain result. The killer proportions are 10/17 and 4/149. Exponentiating their difference gives 1.75, while the ratio of their odds is (10/7)/(4/145) ≈ 51.8. Both scores order those two groups the same way. Define AUC with half credit for ties, which matter for binary predictors. Say explicitly that the linear fit also supplied the reported intervals and p-values. The sentence saying the problem is confined to odds ratios could say that the AUC results reproduce while Table 1’s odds-ratio inference needs revision.

## Smaller edits

- **Conditional logistic regression.** Explain that in every book the observed killer set contains as many gainers as any same-sized set of suspects could contain, with ties allowed. In the three books where an innocent character gains, all the killers also gain. Four books have no gainers and supply no contrast for this predictor. This helps readers reconcile an infinite fitted odds ratio with the 57% hit rate for money alone.
- **Cross-validation.** Lead with the within-book hit rate, then explain that intercepts shift scores across folds and therefore affect pooled AUC. The draft’s explanation about withholding a killer also applies to withholding the other characters in that book. The intercept change depends on the whole fold. Move the alternate AUC range into a methods note if it interrupts the story.
- **Strength of evidence.** Narrow “gender and employment are irrelevant” to “show little evidence of association here.” Limit “the odds ratios are clearly different from 1” to the predictors whose intervals exclude 1. Call the interaction exploratory and put the 2-of-3 count beside its p-value. In the doubledecker section, “the largest difference is in one group” is safer than implying the plots differ only there.
- **Reading flow.** Use “Reproducing Lutz’s Table 1 and Figure 1” because the multivariable AUCs are in Figure 1. Trim the Yates correction and implementation details such as No/Yes factor copies and drop1() from the main narrative. Start the fourfold discussion with what to look at in the financial-gain and employment panels and let the caption explain the rings. Check the opening on a narrow screen, where the illustration may push the finding below the fold.
- **Ending and metadata.** Close with what the reanalysis adds to Lutz’s account, namely stronger estimates of the association with motive and a within-book ranking that helps quantify the contribution of the AI guess. Turn the description’s sentence fragment after the semicolon into a complete sentence or replace it with the main finding.

Review based on index.qmd, Lutz’s six-page Significance article (pp. 10–15), and spot checks of AgathaChristie.R and the existing index.html. The models were not rerun.

## Claude summary 

The editing notes cover four areas:

  1. Opening and framing. Open with the main finding: Related + Financial is right 68% of the time, and adding the web
     AI guess gives 76% held out. Describe the three AI conditions clearly on first use; "~20% passage" is ambiguous.
     Rewrite the description in the front matter and give the post a closing paragraph.
  2. Rigor and wording.
     - Show the financial-gain numbers early: 1.75 vs. an odds ratio of about 51.8.
     - Define AUC with half credit for ties.
     - Spell out what the hit rate is a fraction of, and how it differs from Lutz's 64% figure.
     - Use conditional-logit hit rates throughout.
     - Say exactly what the cross-validation holds out.
     - Soften "irrelevant" and "clearly different from 1", and call the interaction exploratory.
     - Explain why the infinite financial-gain odds ratio sits alongside a 57% hit rate.
  3. Flow. Retitle the section to include Lutz's Figure 1. Cut details like the Yates correction, the No/Yes factor
     copies and drop1() from the main text. Lead the cross-validation section with the hit rates and move the alternate
     AUC range to a methods note.
  4. Figures.
     - Keep the fourfold display, with shared labels.
     - Fold the effect plot and mosaic, or add a small counts table.
     - Replace the two doubledeckers with a four-cell table: web guess 2/14 vs. 0/123, pasted 0/9 vs. 2/128.
     - Replace the printed cross-validation table with a paired dot plot of in-sample vs. held-out hit rates.

## Figures

- **Keep the fourfold display.** The contrast between Employment and Financial gain works well. Use shared row and column labels to remove the repeated rotated text. If seven panels are too much, show those two panels and put the full grid in a foldout.
- **Fold the effect plot and mosaic.** The mosaic's 135-character cell dominates the area and the important 2-of-3 group is a sliver. A small table of observed killer counts over group totals would make the interaction easier to read. If the effect plot stays in the main text, use a shared linear percentage scale and label the 8.4% reference line.
- **Replace the two doubledeckers with a four-cell table.** For the 137 characters with neither coded motive, show killers over suspects for flagged and unflagged groups. Web Chapter 1 is 2/14 flagged and 0/123 unflagged. Pasted Chapter 1 is 0/9 flagged and 2/128 unflagged. The current plots clip labels and make the two missed killers hard to see.
- **Add one paired dot plot in place of the printed cross-validation table.** Plot in-sample and held-out conditional-logit hit rates on a shared 0–100% axis and mark random accusation at about 8%. The main comparisons are family ties plus financial gain (68% to 68%), all four character traits (72% to 55%), and family ties plus financial gain plus web AI (85% to 76%). If comparing AI inputs, include the pasted Chapter 1 and 20%-point conditions. Both scored 75% held out. Keep pooled AUC in the prose or folded output.

## Codex work

- Added [R/figures.R](R/figures.R) and loaded its labeled chunks from `index.qmd` with `knitr::read_chunk()`. The new displays use the existing model results and character data.
- Replaced the printed cross-validation table with a paired dot plot for five conditional-logit models, with a dashed line at the 8.4% random-accusation rate. The text now explains what each fold holds out and reports the pooled logistic AUC separately.
- Replaced the two doubledeckers with a four-cell table for the 137 characters with neither coded motive. The web Chapter 1 guess flagged 2 killers among 14 suspects and left 0 among 123 unflagged. The pasted Chapter 1 guess flagged 0 among 9 and left 2 among 128 unflagged.
- Removed the mosaic from the draft and put the counts beside the exploratory interaction test. Among characters who stood to gain, 2 of 3 unrelated characters and 8 of 14 relatives were killers.
- Added a closing paragraph after the caveats. It connects the corrected financial-gain odds ratio (about 52) to the held-out hit rates (68% with family ties and financial gain, 76% with the web AI guess) and ends with the question of what the AI knew about the endings.
- Reran the models, checked the plotted rates and table counts, and verified both displays and the closing paragraph in the [rendered draft](index.html).

## Still to do (Claude review, 2026-11-13)

Checked `index.qmd` against the notes above after the Codex pass. Housekeeping (R script
move, obsolete figures, stale notes) and a "What I learned" section are done; these remain.

**Opening and framing**

1. Open with the finding: 68% for family ties + financial gain, 76% held out once the web AI
   guess is added. The intro still reads like a methods summary.
2. Name the three AI inputs clearly on first use. "The ~20% passage" still appears in the
   fourfold and AI-add sections.
3. Fix the `description:` in the front matter (fragment after the colon), or replace it with
   the main finding.

**Rigor**

4. Show the worked financial-gain numbers: 10/17 vs 4/149, exp(difference in proportions)
   = 1.75 but the odds ratio is (10/7)/(4/145) ≈ 51.8.
5. Define AUC with half credit for ties.
6. Replace "So the problem is confined to the odds ratios" with: the AUCs reproduce, but
   Table 1's odds-ratio inference needs revision. Say the linear fit also gave the CIs and
   p-values.
7. Say what the hit rate is a fraction of, and reconcile it with Lutz's 64% web figure
   (which credits a hit even when other suspects are also named, p. 13).
8. Beside the first held-out result, add Lutz's point (pp. 14–15) that financial motives
   and family ties can be revealed late in a novel.
9. Conditional logit: say four books have no character who gains (no contrast), and explain
   why an infinite odds ratio sits alongside a 57% hit rate.
10. Soften "Gender and employment are irrelevant" and "clearly different from 1".

**Flow**

11. Rename the section "Reproducing Lutz's Table 1 and Figure 1".
12. Cut the Yates correction, the "No/Yes factor copies" and `drop1()` details from the main
    text.
13. Start the fourfold discussion with what to look at (Financial gain vs Employed panels);
    leave how to read the rings to the caption.
14. Check the opening on a narrow screen (the banner may push the finding below the fold).

**Figures**

15. Effect plot is still in the main text on a logit scale: fold it, or use a linear
    percentage scale and label the 8.4% reference line.
16. Fourfold: consider shared row/column labels instead of per-panel side labels, or show
    only Financial gain and Employed with the full grid folded.

**Also**

17. Review the new "What I learned" section (LLM as consulting detective), then re-render.

**After publishing**

18. Send a letter to the editor of *Significance* (≤ 400 words, marked "For publication").
    Submission details, points to make and a rough draft are in
    [Significance-letter.md](Significance-letter.md).
