# Letter to the editor of *Significance* (on Lutz, 2026)

Status: **to do**, after the blog post is finished.

## How to submit

From *Significance*'s post on X (<https://x.com/signmagazine/status/2111049851869733209>):

- Email: significance@rss.org.uk
- At most **400 words**, clearly marked **"For publication"**.
- Letters may be edited to fit.

Link the published blog post for the full reanalysis and code.

## Points to make (pick 2–3; 400 words goes fast)

1. **Table 1's odds ratios are wrong.** They are exp(slope) from a linear probability
   model, i.e. exp(difference in proportions), which can't exceed e ≈ 2.72. Logistic
   odds ratios: Financial gain 1.75 → 51.8 (95% CI 14–233); Related 1.43 → 21.3; AI web
   Chapter 1 1.45 → 19.2. The AUCs are correct, and the conclusions about which
   predictors matter stand.
2. **Novels are matched sets.** Conditional logit with `strata(novel)` compares each
   killer with the other suspects in the same book. Financial gain is perfectly
   separated within novels.
3. **Whom would Miss Marple accuse?** Accusing the top-scoring suspect in each novel:
   chance 8%, Related + Financial 68%, + web AI 85% in-sample, 76% with
   leave-one-novel-out cross-validation.
4. **The web AI advantage** is consistent with the AI's prior knowledge of these famous
   plots (Lutz notes this too); a test on mysteries it couldn't have read would settle it.

## Rough draft (~260 words; not yet checked against the final post)

> **For publication**
>
> Sharon Lutz's "Statistical sleuths versus AI" (*Significance*, 23(6), 10–15) is a
> delightful use of Agatha Christie's Miss Marple novels to teach logistic regression.
> Reanalysing her data, I found one numerical problem worth correcting and some
> extensions readers may enjoy.
>
> The odds ratios in Table 1 (0.98 to 1.75) are too small for binary predictors with
> AUCs above 0.80. They are reproduced exactly by exponentiating the slopes of a linear
> probability model, that is, exp(difference in proportions), which can never exceed
> e ≈ 2.72. The logistic odds ratios are far larger: about 52 for financial gain (95% CI
> 14–233), 21 for being related to the victim, and 19 for the AI's web-based Chapter 1
> guess. The AUCs, and the conclusions about which predictors matter, are unaffected.
>
> Each novel is a closed circle of suspects, so a conditional logistic model comparing
> characters within the same book is natural. It also answers the reader's question:
> whom should Miss Marple accuse? Accusing the top-scoring suspect(s) in each novel,
> family ties plus financial gain names the killer 68% of the time, against 8% by
> chance. Adding the web-based AI guess raises this to 85%, or 76% when each novel is
> held out in turn.
>
> As Lutz notes, the web condition may draw on what the AI already knows about these
> famous books. Mysteries it could not have read would make a fairer test of whether an
> LLM could become a consulting detective.
>
> The full reanalysis, with R code, is at [blog URL].
>
> Michael Friendly, York University, Toronto
