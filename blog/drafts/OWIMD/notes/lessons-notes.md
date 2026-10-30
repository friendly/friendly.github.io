# Notes on "What I learned" and "Lessons"

From my session with Claude, 2026-10-30. Both sections are written in `index.qmd`, based on these
suggestions. Look at this again when taking the post up.

## Wording to check: Claude wrote these about me

They are guesses about my own experience, not facts from the analysis. Keep, change or cut.

- "I have been drawing HE plots for a long time"
- One predictor with many responses being "a setup I had not thought much about"
- The profiles coming "from wanting to compare across the OWID panels"
- The defaults point being "the one I would most like others to know about"
- The last line of Lessons, that the picture "keeps you honest about what the model has left out".
  It's a little grand, so maybe trim it.

## What I learned: the reasoning

The idea is to keep this separate from Lessons. *What I learned* covers methods that were new to me.
*Lessons* covers what any reader can take to their own data.

- **Splines:** one df gives a degenerate H "ellipse", a line. A few spline df let it open up, and
  how much it opens shows how far the relation departs from linear. So it also works as a visual
  check for curvature.
- **A grouping variable:** region gives the plot something to separate at a given income. GDP stays
  nearly one-dimensional while region doesn't, and you can see that contrast directly. It also makes
  this a MANCOVA, with its caveat about unequal slopes.
- **Adjusted means and scores:** perhaps the least obvious point. The H ellipse for region is adjusted
  for GDP, but the default `heplot()` means and the `candisc()` scores are not. Left alone, the plots
  mostly show income again (Can1 correlates -0.86 with log GDP). Using the residuals as the responses
  fixes this.
- **Residual PCA:** taking out the known common factor first turns a PCA that rediscovers income into
  one that asks who does better than their money predicts.
- **Development profiles:** I haven't seen this display before, so it belongs here too.

## Lessons: the candidates

Six were suggested, for writing as a short closing passage rather than bullets. All but the ceiling
point are in the current text.

- **Remove the common factor first.** Raw correlations average .81 with little structure; partial
  correlations average .37 with a lot. The OWID chart is in effect nine views of one fact.
- **Scales are choices that tell stories.** Doctors goes from second to last in the development
  sequence between the transformed and raw scales (`tbl-thresholds`).
- **A residual is only relative to its model.** Guyana looks like a failure because its GDP changed
  faster than everything else, and 9 of the 24 countries in the performance ranking change under a
  quadratic. Outliers can reflect data vintage or quality as much as real achievement.
- **A single covariance matrix is an average.** This is where to qualify "life satisfaction goes its
  own way", since that holds mainly below about $41,000.
- **Use ceilings as a warning.** A transformation can't separate countries that all report 100%.
  *Not in the current Lessons; it is covered in the covariance and whole-data sections.*
- **Order matters, and models and pictures work together.** The sorted heatmap shows many of the same
  exceptions the models found. The model says how far out of line a country is, and the picture shows
  where to look.

The ending suggested was: remove the common factor, residuals are relative to their model, the qualified
life satisfaction result, then models and pictures. The old bullet "Orientation, transformation and
standardization come first" is folded into the point about scales.

## See also

- `README.md`: the steps to publication and the open items.
- `OWIMD-with-notes.qmd.txt`: the original "Points to make" and TODOs.
- `../references.bib`: not connected to `index.qmd` yet.
