# Life at different levels of GDP — notes

Source chart: `Life-GDP.jpg` (Our World in Data, "How is life at different levels of GDP per
capita?", Oct 2026, CC-BY). 12 indicators, each plotted against GDP per capita (PPP, log scale),
one dot per country, latest available year.

Status (2026-10-29): asked Max Roser for the data; meanwhile rebuilt it from OWID's public grapher
CSVs (see below).

## (a) Data

### Why not digitize the chart

Digitizing is possible but not worth it. The 12 panels are separate scatterplots with no country
labels, so a digitized point in "Doctors" can't be matched to the same country in "Life
expectancy". We would get 12 *marginal* bivariate clouds and lose the joint (multivariate)
structure, which is exactly what the multivariate methods need.

### What we did instead

Every panel is a standard OWID grapher series, downloadable as
`https://ourworldindata.org/grapher/<slug>.csv`. `get-LifeGDP.R` downloads the 13 series to
`data-raw/`, keeps each country's **latest non-missing year** per indicator, keeps only ISO3
countries, adds the OWID region, and writes:

| file | contents |
|---|---|
| `LifeGDP.csv`, `LifeGDP.RData` | 198 countries × (`country, code, region, GDP` + 12 responses) |
| `LifeGDP-year.csv` (`LifeGDP_year`) | year each value comes from, same layout |
| `LifeGDP-replica.png` | ggplot replica of the OWID figure (with loess fits), as a check |

The replica matches the original panel by panel (same ranges, shapes and n).

| variable | OWID slug | units | n |
|---|---|---|---|
| GDP | gdp-per-capita-worldbank | PPP int-$ (const.) | 198 |
| ChildMort | youth-mortality-rate | % dying before 15 | 187 |
| Stillbirth | stillbirth-rate | per 100 births | 187 |
| MatMort | maternal-mortality | per 100,000 births | 181 |
| Stunting | share-of-children-younger-than-5-who-suffer-from-stunting | % under-5 | 157 |
| Doctors | physicians-per-1000-people | per 1,000 | 194 |
| LifeExp | life-expectancy | years | 198 |
| Literacy | cross-country-literacy-rates | % adults | 189 |
| SchoolYrs | expected-years-of-schooling | years | 187 |
| TestScores | average-harmonized-learning-outcome-scores | score | 171 |
| Electricity | share-of-the-population-with-access-to-electricity | % | 198 |
| Water | proportion-using-safely-managed-drinking-water | % | 140 |
| LifeSat | happiness-cantril-ladder | 0–10 | 159 |

### Caveats

- **Literacy:** for 28 countries (most of W. Europe, US, Canada, Japan, ...) the "latest" value is
  a **1950** historical estimate (e.g., 98.5%). Djibouti's 3% (the outlier in the replica) is from
  1950 as well. Options: set values before about 2000 to NA, or impute ~99% for high-income
  countries. Ask Max which vintage the chart used.
- Stunting and Doctors also have some old values (back to 1995 and 1980). Check them with
  `LifeGDP_year`.
- **Missing data:** only 98 countries are complete on all 12 responses. Dropping Literacy,
  TestScores and Stunting leaves 121 complete on 9. Water (n = 140) and LifeSat (n = 159) are the
  next-worst. This is a natural case for multiple imputation (`mice`) and a missingness-pattern
  display.
- Mixed scales: three log-scaled rates, several bounded percentages with a **ceiling at 100%**
  (Electricity, Literacy, Water), and counts and scores.

## (b) Ideas: p responses vs. one predictor

The OWID display is p separate regressions of y_j on x. It shows each marginal relation well
(form, saturation, spread) but hides how the responses relate to each other once GDP is taken
into account. That gap is what the multivariate framework fills. The model is the MLM

    Y (n × p) = f(log GDP) B + E,   E ~ N(0, Σ)

so the questions are about the fitted part f(x)B and the residual covariance Σ.

### 1. Transform and align the responses first

- log for the three rates (as OWID does), and logit (or empirical logit) for the bounded
  percentages to remove the ceiling. Try `car::powerTransform()` on the whole response set.
- **Reverse the "bad" outcomes** (mortality, stillbirth, stunting) so that "+" means better on
  every response. Profiles, parallel coordinates and biplots become much easier to read.
- Standardize the responses (z-scores) so they share a common scale.

### 2. One panel instead of twelve: "development profiles"

Put all p standardized (or percentile-ranked) fitted curves ŷ_j(log GDP) on **one** axis, with
direct labels. This shows the order in which things improve with income:

- Electricity saturates early (around $5–10k).
- Doctors barely move until about $10k, then rise steeply.
- Test scores and life satisfaction keep rising across the whole range.

A summary could give, for each indicator, the GDP at which it reaches half (or 90%) of its range,
shown as a dot plot of "development thresholds".

### 3. Test the shape jointly (MLM)

Preliminary results, 9 responses, n = 121, standardized:

- Linear vs. quadratic in log GDP: Pillai = 0.54, F(9, 110) = 14.2, p < 1e-14. Curvature matters
  jointly. Per response, R² hardly changes except **Electricity (0.53 → 0.76)**, the ceiling effect.
- `ns(logGDP, 3) + region`: both terms are highly significant (Pillai 1.40 and 1.27). **Region
  matters beyond GDP.**
- **HE plots**: with a single 1-df predictor, the H ellipse degenerates to a line. A spline basis
  gives a proper H ellipsoid of dimension ≤ 3. Adding `region` is where HE plots get interesting
  (`heplot`, `pairs.mlm`, `heplot3d`), with GDP as a covariate. Also test homogeneity of slopes,
  `ns(logGDP,3):region`: is the GDP gradient the same in Africa and Asia?
- Canonical view: `candisc` on the region term after adjusting for GDP shows how regions differ
  in the residual outcome space.

### 4. What's left after GDP: residual structure

Residual correlations, partialling out quadratic log GDP (n = 121):

- The **mortality block** (ChildMort, Stillbirth, MatMort) stays strongly intercorrelated
  (r = .63–.77).
- These correlate negatively with Water (≈ −.4 to −.6), LifeExp and Doctors.
- **Life satisfaction is nearly independent of everything else** once GDP is controlled
  (|r| ≤ .30).

Displays:

- residual scatterplot matrix with data ellipses
- corrgram of the residual correlations
- side-by-side raw vs. partial correlation matrices: GDP is the "common factor" that inflates
  every raw correlation (raw r with log GDP is .73–.88 in absolute value)

### 5. Residual PCA / biplot: who does better or worse than their GDP predicts?

PCA of the oriented residuals: PC1 = 44% of the variance, and all loadings have the same sign. So
PC1 is a general "performance relative to income" score.

- **Better than predicted:** Greece, Tajikistan, Mozambique, Palestine, Belarus, Portugal, Spain,
  Kyrgyzstan.
- **Worse than predicted:** Guyana, Nigeria, Botswana, Qatar, Côte d'Ivoire, Dominican Rep.,
  Eswatini, Zimbabwe. These are mostly resource or oil economies, where GDP overstates broad
  welfare.

PC2 (13%) contrasts LifeSat, Doctors and SchoolYrs with Electricity, LifeExp and Water.

A **residual biplot** colored by region would make a strong figure. Also compare it with the
ordinary PCA/biplot of Y, with log GDP projected as a supplementary vector: PC1 of Y ≈ GDP.

### 6. Multivariate outliers and influence

- Use the chi-square QQ plot of residual Mahalanobis D² (`heplots::cqplot`). The largest D² are
  Palestine and Afghanistan (≈ 37), then Turkmenistan, Greece, Belarus, Nigeria, Guyana and
  Lebanon (≈ 20–24). Several are data-quality or conflict cases worth checking.
- `mvinfluence::influencePlot` for the MLM.

### 7. Does the covariance structure change with development?

- Group countries by GDP tercile or quartile (or World Bank income group), then compare residual
  covariance matrices: `heplots::boxM`, `covEllipses`, and the `boxM` plot of log determinants.
- Expect heteroscedasticity: spread in Doctors fans out with GDP, while the ceiling variables
  collapse at high GDP. This shows a real limitation of a homoscedastic MLM and motivates the
  transformations in (1).

### 8. Other whole-dataset displays

- **Ordered heatmap** (a tableplot): countries sorted by GDP (rows) × responses (columns,
  seriated), with standardized and oriented cells. Countries that break the gradient show up as
  off-color rows.
- **Parallel coordinates**, axes ordered by correlation with GDP, lines colored by log GDP.
- Glyphs or star plots positioned along the GDP axis, one per region.

### Possible uses

- Book example for "multivariate response, single quantitative predictor" (with region as a
  factor: MANCOVA).
- Candidate dataset for heplots (OWID data are CC-BY; cite OWID and the underlying sources: UN
  IGME, UN MMEIG, WHO/UNICEF, UN WPP, UNESCO, UNDP, Gallup, World Bank). The Literacy vintage issue
  needs resolving first.

### Questions for Max Roser

- Which literacy series and year cut-off did the chart use?
- Is there a minimum-year rule for "latest available"?
- Is a country-identified version of the chart data available? It appears to be the grapher
  series above.
