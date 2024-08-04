## Multivariate linear models

### [heplots](https://github.com/friendly/heplots)
[<img src='https://raw.githubusercontent.com/friendly/heplots/master/man/figures/logo.png' height='100' align='left' style="padding:'20px'">](https://github.com/friendly/heplots)

Provides HE plot and other functions for visualizing hypothesis tests in
multivariate linear models. HE plots represent
sums-of-squares-and-products matrices for linear hypotheses and for
error using ellipses (in two dimensions) and ellipsoids (in three
dimensions). The related â€˜candiscâ€™ package provides visualizations in a
reduced-rank canonical discriminant space when there are more than a few
response variables. **Documentation**:
[friendly.github.io/heplots](http://friendly.github.io/heplots/)

### [candisc](https://github.com/friendly/candisc)
[<img src='https://raw.githubusercontent.com/friendly/candisc/master/candisc-logo.png' height='100' align='left' style="padding:'20px'">](https://github.com/friendly/candisc)

Functions for computing and visualizing generalized canonical
discriminant analyses and canonical correlation analysis for a
multivariate linear model. Traditional canonical discriminant analysis
is restricted to a one-way ‘MANOVA’ design and is equivalent to
canonical correlation analysis between a set of quantitative response
variables and a set of dummy variables coded from the factor variable.
The ‘candisc’ package generalizes this to higher-way ‘MANOVA’ designs
for all factors in a multivariate linear model, computing canonical
scores and vectors for each term. The graphic functions provide low-rank
(1D, 2D, 3D) visualizations of terms in an ‘mlm’ via the ‘plot.candisc’
and ‘heplot.candisc’ methods. Related plots are now provided for
canonical correlation analysis when all predictors are quantitative.
**Documentation**:
[friendly.github.io/candisc](https://friendly.github.io/candisc/)

### [VisCollin](https://github.com/friendly/VisCollin)
[<img src='https://raw.githubusercontent.com/friendly/VisCollin/master/man/figures/logo.png' height='100' align='left' style="padding:'20px'">](https://github.com/friendly/VisCollin)

Provides methods to calculate diagnostics for multicollinearity among
predictors in a linear or generalized linear model. It also provides
methods to visualize those diagnostics following Friendly & Kwan (2009),
“Where’s Waldo: Visualizing Collinearity Diagnostics”,
<doi:10.1198/tast.2009.0012>. These include better tabular presentation
of collinearity diagnostics that highlight the important numbers, a
semi-graphic tableplot of the diagnostics to make warning and danger
levels more salient, and a “collinearity biplot” of the smallest
dimensions of predictor space, where collinearity is most apparent.
**Documentation**:[rdrr.io/cran/VisCollin/](https://rdrr.io/cran/VisCollin/)

### [genridge](https://github.com/friendly/genridge)

[<img src='https://raw.githubusercontent.com/friendly/genridge/master/man/figures/logo.png' height='100' align='left' style="padding:'20px'">](https://github.com/friendly/genridge)

The genridge package introduces generalizations of the standard
univariate ridge trace plot used in ridge regression and related
methods. These graphical methods show both bias (actually, shrinkage)
and precision, by plotting the covariance ellipsoids of the estimated
coefficients, rather than just the estimates themselves. 2D and 3D
plotting methods are provided, both in the space of the predictor
variables and in the transformed space of the PCA/SVD of the
predictors.  
**Documentation**: [friendly.github.io/genridge](https://friendly.github.io/genridge/)

## [job: free your RStudio console](https://lindeloev.github.io/job)
An R package that allows the user to run code chunks as RStudio jobs. The console is then free to continue working, enabling an uninterrupted coding experience.



## [Common statistical tests are linear models (or: how to teach stats)](https://lindeloev.github.io/tests-as-linear/)
Demonstrates that almost all of the stats 101 tests are special cases of (simple) linear models, including "non-parametric" tests to some approximation. To establish this, I simulated the rank-correspondence between parametric tests and non-parametric equivalents:

 * [Kruskal-Wallis is (almost) a one-way ANOVA on ranked data](https://lindeloev.github.io/tests-as-linear/simulations/simulate_kruskall.html)
 * [Mann-Whitney is (almost) an independent-sample t-test on ranks](https://lindeloev.github.io/tests-as-linear/simulations/simulate_mannwhitney.html)
 * [Spearman is (almost) a Pearson on ranks](https://lindeloev.github.io/tests-as-linear/simulations/simulate_spearman.htmll)
 * [Wilcoxon is (almost) a one-sample t-test on signed ranks](https://lindeloev.github.io/tests-as-linear/simulations/simulate_wilcoxon.html)


