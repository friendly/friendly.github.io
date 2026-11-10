# Notes on Lutz (2026): Statistical sleuths versus AI

Sharon M. Lutz, "Statistical sleuths versus AI: Unmasking the killer in Agatha Christie
novels", *Significance* 23(6), 10–15, November 2026.
Paper: `C:\Users\friendly\Dropbox\Documents\papers\Lutz-AgathaChristie-AI.pdf`
Data: <https://github.com/SharonLutz/Stats-vs-AI-whodunnit> →
`AgathaChristie_MissMarple_MainCharacters_v2.csv` (downloaded 2026-11-10)

*Notes by Claude (Opus 5.5), 2026-11-10.*

## Files in this folder

Moved on 2026-11-10 from `C:\Dropbox\R\AgathaChristie` to the blog repo, as
`blog/drafts/AgathaChristie/` (`draft: true`).

| File | What |
|---|---|
| `AgathaChristie_MissMarple_MainCharacters_v2.csv` | Lutz's data |
| `AgathaChristie.R` | Reproduction + reanalysis; run standalone, writes `figs/*.png` |
| `index.qmd` / `.html` | The blog draft; reads the script's `## ---- label` chunks via `knitr::read_chunk()`. Key-model code shown, the rest folded ("Show the code") |
| `figs/` | fourfold, effects, mosaic, and doubledecker plots |
| `notes-for-Gavin.md` | ggfourfold vs. `vcd::fourfold()` feedback for Gavin Klorfine |

Render in place from this folder: `quarto render index.qmd`. Drafts are excluded from the
site build, and the output stays here rather than going to `docs/`.

## The data

- 166 main characters (Miss Marple excluded) in the 12 Miss Marple novels; 14 killers
  (two novels have 2 killers). 11–19 characters per novel.
- 0/1 variables: `Killer`, `Female`, `Employed`, `Related` (to the main victim), `Financial`
  (gained from the murder; spouse's gain counts), and three AI guesses from Harvard AI
  Sandbox (GPT 5.1/5.6): `AIch1passage` (Chapter 1 pasted in), `AIch1web` (asked to read
  Chapter 1 on the web), `AIch20p` (the chapter at ~20% of the novel pasted in).
- Recurring characters are counted only in their first novel.

## What the paper does and finds

- Univariate logistic regressions of Killer on each variable, and AUCs. Four multivariable
  models: Related + Financial, each with/without one AI predictor.
- Gender and employment don't matter (AUC ≈ 0.5). Related (AUC 0.80) and Financial (0.83)
  are the best single predictors. AI alone: 0.66 (20%) to 0.78 (web).
- Related + Financial: AUC 0.89; + AI web: 0.97 (best).
- The AI did *better* with Chapter 1 than with ~20% of the novel: more text, more red
  herrings. The web condition beat pasting in the same chapter, which Lutz suspects means
  outside knowledge.

## Problems found

1. **Table 1's odds ratios are wrong.** They are exactly exp(β) from a *linear*
   probability model (gaussian GLM), i.e. exp(difference in proportions), not logistic ORs.
   Correct ORs (profile-likelihood 95% CI):

   | Predictor | Lutz "OR" | Logistic OR | 95% CI |
   |---|---|---|---|
   | Employed | 1.01 | 1.1 | 0.4–3.8 |
   | Female | 0.98 | 0.8 | 0.3–2.4 |
   | AI ~20% pasted | 1.23 | 6.0 | 1.8–19 |
   | AI Ch.1 pasted | 1.44 | 14.2 | 4.1–50 |
   | AI Ch.1 web | 1.45 | 19.2 | 5.8–71 |
   | Related | 1.43 | 21.3 | 6.3–85 |
   | Financial gain | 1.75 | 51.8 | 14–233 |

   The p-values and AUCs in Table 1 are fine. With binary predictors the AUC is the same
   either way. The text's interpretation ("strong predictors") is right, but the numbers
   understate the effects by more than an order of magnitude.

2. **Independence.** Characters are treated as independent, but novels are matched sets
   (a fixed cast, 1–2 killers each). Conditional logit, `strata(Title)`, is the natural model.

3. **Optimism.** The 0.97 AUC is in-sample, from 14 events, with no cross-validation.

4. Minor: the reported Pearson χ² = 58.3 for Related × Financial is the Yates-corrected
   value (uncorrected 63.8). Expected counts are small anyway; OR = (137·14)/(3·12) ≈ 53.

## Reanalysis results (`AgathaChristie.R`)

- **All non-AI predictors** (glm): Financial dominates (LR χ² = 12.9, p < .001); Related
  is marginal once Financial is in (p = .10); Female and Employed add nothing (joint LR
  p = .14). Significant Related × Financial interaction (p = .02): only 3 unrelated
  characters gained financially, and 2 of them were killers.
- 2×2×2 table of Related × Financial × Killer has **no empty cells** (killers: 2/137, 2/3,
  2/12, 8/14), so no separation in the pooled glm. *(My earlier claim that there was
  near-separation here was wrong.)*
- **Conditional logit**: Financial gain is **perfectly separated within novels**. In
  every novel where an innocent character gains financially (*Pocket Full of Rye*, *Body in
  the Library*, *Vicarage*), the killer gains too. The conditional OR is ∞, so use LR tests
  (Financial LR χ² = 42.5; Related 30.4, OR ≈ 69). In the full model: Financial LR
  χ² = 16.5, Related 6.9 (p = .009), Female and Employed n.s.
- **AI added to Related + Financial**: in glm, ch1-web (LR p < .001) and ch1-pasted
  (p = .01) help; 20% doesn't (p = .14). In clogit only **ch1-web** helps (p = .003).
- **"Whom would Miss Marple accuse?"** Accuse each novel's top-scoring suspect(s), and
  score the chance of picking the killer, averaged over novels:
  chance 8% · AI 20% 38% · AI ch1 43% · Related 44% · AI web 53% · Financial 57% ·
  Related + Financial 68% · + AI ch1 or 20% 75% · + AI web **85%**.

- **Leave-one-novel-out CV** (added 2026-11-10; no extra packages). Fit to 11 novels,
  score the 12th:

  | Model | AUC in | AUC CV | hit glm in/CV | hit clogit in/CV |
  |---|---|---|---|---|
  | AI ch1 pasted | .72 | .70 | .43 / .43 | .43 / .43 |
  | AI ch1 web | .78 | .76 | .53 / .53 | .53 / .53 |
  | AI 20% | .66 | .64 | .38 / .38 | .38 / .38 |
  | Related + Financial | .89 | .88 | .68 / .68 | .68 / .68 |
  | All non-AI | .91 | .83 | .72 / .63 | .72 / .55 |
  | R + F + AI ch1 pasted | .90 | .88 | .67 / .67 | .75 / .75 |
  | R + F + AI ch1 web | .97 | **.94** | .76 / .76 | .85 / **.76** |
  | R + F + AI 20% | .92 | .89 | .75 / .67 | .75 / .75 |

  Lutz's best model survives CV. Female + Employed are pure overfitting. **Gotcha:** CV
  scores must use slopes only. With the fold intercept included, the pooled CV AUC is
  biased down, because the intercept drops exactly when the held-out novel's killer is
  missing from training (single-AI AUCs fell to 0.51–0.64, an artifact).

## Figures

- `fourfold.png`: Killer × each of the 7 predictors, with OR in each title. Drawn with
  **ggfourfold** 0.1.0 (CRAN; Gavin Klorfine), faceting a long-format data frame.
- `effects-full.png`: effect plot for the four-predictor glm. Effects are computed with
  `effects::Effect()` (averaging over the other predictors) on a factor refit, and drawn
  with ggplot on a common logit y-scale. `ggeffects::predict_response()` was rejected
  because it fixes the other factors at "No". `plot.efflist()` was rejected because its
  layout and axis arguments fought back. Employed's adjusted OR ≈ 4.6 (p = .16) against
  1.1 alone: 6 of the 7 employed characters with financial gain are killers.
- `mosaic-rel-fin.png`: Killer | Related × Financial, residual shading.
- `doubledecker-ai-web.png`, `doubledecker-ai-pasted.png`: proportion of killers by
  Related, Gain and AI guess.

**Render gotcha (in the old Dropbox location):** `quarto render` sometimes failed at
cleanup, because Dropbox locked `AgathaChristie_files/`. Deleting that folder and rendering
again fixed it. This shouldn't happen here, since `C:\R\Projects` is not in Dropbox.

## Possible next steps

- Firth-penalized logit / clogit (`logistf`, `coxphf`; neither installed) for finite
  estimates of the separated Financial effect.
- A short note to Lutz about Table 1, or a blog post (good teaching example: the OR
  mix-up, matched-set data, separation, fourfold/mosaic displays).
