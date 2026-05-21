## Partial Variable Plots: Visualizing Partial Correlations

Working code: `C:\R\Projects\Vis-MLM-book\R\pvPlot.R`  
Test cases: `C:\R\Projects\Vis-MLM-book\test\pvPlot-test.R`  
Book context: `child/04-network.qmd`, section "Visualizing partial correlations"  
Target home: eventually `heplots` package

### The idea

A partial variable plot shows the partial correlation between two variables $x_i$ and $x_j$
after removing the linear effects of all other variables $Z$. 
It is simply a scatterplot of the residuals $e_i = x_i - \hat{x}_i$ vs $e_j = x_j - \hat{x}_j$,
where each variable is regressed on all the others.

These plots are produced by SAS `PROC CORR` with the `PARTIAL` and `SCATTER` statements —
worth showing the R equivalent is straightforward and richer.

Closely related to `car::avPlots()` (added-variable plots for a linear model), but operates
directly on a data frame rather than a fitted model.

### Key points to make

- The slope of the regression line in the plot *is* the partial correlation coefficient.
- The data ellipse visualizes the bivariate distribution of the residuals; its shape
  reflects the partial correlation.
- Point labels (`id` argument) identify observations that are unusual in the partial space
  but may look ordinary in the marginal scatterplot.
- The partial r can differ substantially from the marginal r — good examples needed.

### Good examples

- `crime` data (ggbiplot): burglary/larceny, auto/robbery — crimes that are positively
  correlated marginally but less so (or differently) after controlling for others.
- Maybe a dataset where a marginal correlation reverses sign (Simpson-like).

### Things to show / demo

- Basic plot with data ellipse and partial r label
- `ellipse = FALSE` to just see the residual scatter
- `id = list(n = 5)` to flag unusual states/cases
- `ellipse.args = list(col = "red")` vs point `col` — independent control
- Multiple `levels` for nested ellipses
- Robust ellipse vs classical
- Side-by-side: marginal scatterplot vs partial variable plot

### Connections to develop

- Link to the geometry: the AVP ellipse is the "shadow" of the full data ellipse onto
  the partial residual space (Fox & Weisberg).
- Mention `car::avPlots()` and explain when pvPlot is the better tool.
- SAS PROC CORR precedent — audience likely knows it.

### Code notes

- `pvPlot()` uses `car::dataEllipse()` under the hood; patched version in `test/Ellipse.R`
  fixes a duplicate-`cex` bug in `label.ellipse()` — worth a brief aside or footnote.
- `ellipse = FALSE` implemented via `levels = numeric(0)` (not an `ellipse` arg to
  dataEllipse, which doesn't have one).
