R packages
================

This page provides overview descriptions of my R packages and those I
have contributed to. The hex icons link to the GitHub repositories.
Links to the package **Documentation** are also provided.

Topics: [Multivariate linear models](#MLM) \|\| [Categorical data
analysis](#CDA) \|\| [Data](#DATA)

## Multivariate linear models

### [heplots](https://github.com/friendly/heplots)

[<img src='https://raw.githubusercontent.com/friendly/heplots/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/heplots)

Provides HE plot and other functions for visualizing hypothesis tests in
multivariate linear models. HE plots represent
sums-of-squares-and-products matrices for linear hypotheses and for
error using ellipses (in two dimensions) and ellipsoids (in three
dimensions). The related ‘candisc’ package provides visualizations in a
reduced-rank canonical discriminant space when there are more than a few
response variables. **Documentation**:
[friendly.github.io/heplots](http://friendly.github.io/heplots/)

### [candisc](https://github.com/friendly/candisc)

[<img src='https://raw.githubusercontent.com/friendly/candisc/master/candisc-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/candisc)

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

### [VisCollin](https://friendly.github.io/VisCollin)

[<img src='https://raw.githubusercontent.com/friendly/VisCollin/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/VisCollin)

Provides methods to calculate diagnostics for multicollinearity among
predictors in a linear or generalized linear model. It also provides
methods to visualize those diagnostics following Friendly & Kwan (2009),
“Where’s Waldo: Visualizing Collinearity Diagnostics”,
<doi:10.1198/tast.2009.0012>. These include better tabular presentation
of collinearity diagnostics that highlight the important numbers, a
semi-graphic tableplot of the diagnostics to make warning and danger
levels more salient, and a “collinearity biplot” of the smallest
dimensions of predictor space, where collinearity is most apparent.
**Documentation**:
[friendly.github.io/VisCollin](https://friendly.github.io/VisCollin)

### [genridge](https://github.com/friendly/genridge)

[<img src='https://raw.githubusercontent.com/friendly/genridge/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/genridge)

The genridge package introduces generalizations of the standard
univariate ridge trace plot used in ridge regression and related
methods. These graphical methods show both bias (actually, shrinkage)
and precision, by plotting the covariance ellipsoids of the estimated
coefficients, rather than just the estimates themselves. 2D and 3D
plotting methods are provided, both in the space of the predictor
variables and in the transformed space of the PCA/SVD of the
predictors.  
**Documentation**:
[friendly.github.io/genridge](https://friendly.github.io/genridge/)

### [mvinfluence](https://github.com/friendly/mvinfluence)

[<img src='https://raw.githubusercontent.com/friendly/mvinfluence/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/mvinfluence)

Computes regression deletion diagnostics for multivariate linear models
and provides some associated diagnostic plots. The diagnostic measures
include hat-values (leverages), generalized Cook’s distance, and
generalized squared ‘studentized’ residuals. Several types of plots to
detect influential observations are provided. **Documentation**:
[friendly.github.io/mvinfluence](https://friendly.github.io/mvinfluence/)

### [matlib](https://github.com/friendly/matlib)

[<img src='https://raw.githubusercontent.com/friendly/matlib/master/matlib-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/matlib)

A collection of matrix functions for teaching and learning matrix linear
algebra as used in multivariate statistical methods. These functions are
mainly for tutorial purposes in learning matrix algebra ideas using R.
In some cases, functions are provided for concepts available elsewhere
in R, but where the function call or name is not obvious. In other
cases, functions are provided to show or demonstrate an algorithm. In
addition, a collection of functions are provided for drawing vector
diagrams in 2D and 3D. **Documentation**:
[friendly.github.io/matlib](https://friendly.github.io/matlib/)

### [gellipsoid](https://github.com/friendly/gellipsoid)

[<img src='https://raw.githubusercontent.com/friendly/gellipsoid/master/man/figures/gellipsoid-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/gellipsoid)

Represents generalized geometric ellipsoids with the “(U,D)”
representation. It allows degenerate and/or unbounded ellipsoids,
together with methods for linear and duality transformations, and for
plotting. Thus ellipsoids are naturally extended to include lines,
hyperplanes, points, cylinders, etc. This permits exploration of a
variety to statistical issues that can be visualized using ellipsoids as
discussed by Friendly, Fox & Monette (2013), Elliptical Insights:
Understanding Statistical Methods Through Elliptical Geometry
<doi:10.1214/12-STS402>. <br/>
<p>
</p>

### [two way](https://github.com/friendly/twoway)

[<img src='https://raw.githubusercontent.com/friendly/twoway/master/twoway-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/twoway)
Carries out analyses of two-way tables with one observation per cell,
together with graphical displays for an additive fit and a diagnostic
plot for removable ‘non-additivity’ via a power transformation of the
response. It implements Tukey’s Exploratory Data Analysis (1973) \<ISBN:
978-0201076165\> methods, including a 1-degree-of-freedom test for
row\*column ‘non-additivity’, linear in the row and column effects.
**Documentation**: [rdrr.io/cran/twoway/](https://rdrr.io/cran/twoway/)

### [ggbiplot](https://github.com/friendly/ggbiplot)

[<img src='https://raw.githubusercontent.com/friendly/ggbiplot/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/ggbiplot)
A ‘ggplot2’ based implementation of biplots, giving a representation of
a dataset in a two dimensional space accounting for the greatest
variance, together with variable vectors showing how the data variables
relate to this space. It provides a replacement for stats::biplot(), but
with many enhancements to control the analysis and graphical display. It
implements biplot and scree plot methods which can be used with the
results of prcomp(), princomp(), FactoMineR::PCA(), ade4::dudi.pca() or
MASS::lda() and can be customized using ‘ggplot2’ techniques.
**Documentation**:
[friendly.github.io/ggbiplot](http://friendly.github.io/ggbiplot/)

## Categorical data analysis

### [vcdExtra](https://github.com/friendly/vcdExtra)

[<img src='https://raw.githubusercontent.com/friendly/vcdExtra/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/vcdExtra)
Provides additional data sets, methods and documentation to complement
the ‘vcd’ package for Visualizing Categorical Data and the ‘gnm’ package
for Generalized Nonlinear Models. In particular, ‘vcdExtra’ extends
mosaic, assoc and sieve plots from ‘vcd’ to handle ‘glm()’ and ‘gnm()’
models and adds a 3D version in ‘mosaic3d’. Additionally, methods are
provided for comparing and visualizing lists of ‘glm’ and ‘loglm’
objects. This package is now a support package for the book, “Discrete
Data Analysis with R” by Michael Friendly and David Meyer.
**Documentation**:
[friendly.github.io/vcdExtra](http://friendly.github.io/vcdExtra/)

### [nestedLogit](https://github.com/friendly/nestedLogit)

[<img src='https://raw.githubusercontent.com/friendly/nestedLogit/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/nestedLogit)
Provides functions for specifying and fitting nested dichotomy logistic
regression models for a multi-category response and methods for
summarising and plotting those models. Nested dichotomies are
statistically independent, and hence provide an additive decomposition
of tests for the overall ‘polytomous’ response. When the dichotomies
make sense substantively, this method can be a simpler alternative to
the standard ‘multinomial’ logistic model which compares response
categories to a reference level. See: J. Fox (2016), “Applied Regression
Analysis and Generalized Linear Models”, 3rd Ed., ISBN 1452205663.
**Documentation**:
[friendly.github.io/nestedLogit](https://friendly.github.io/nestedLogit/)

## Data

### [HistData](https://github.com/friendly/HistData)

[<img src='https://raw.githubusercontent.com/friendly/HistData/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/HistData)
The ‘HistData’ package provides a collection of small data sets that are
interesting and important in the history of statistics and data
visualization. The goal of the package is to make these available, both
for instructional use and for historical research. Some of these present
interesting challenges for graphics or analysis in R. **Documentation**:
[friendly.github.io/HistData/](https://friendly.github.io/HistData/)

### [Guerry](https://github.com/friendly/Guerry)

[<img src='https://raw.githubusercontent.com/friendly/Guerry/master/man/figures/Guerry-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/Guerry)
Maps of France in 1830, multivariate datasets from A.-M. Guerry and
others, and statistical and graphic methods related to Guerry’s “Moral
Statistics of France”. The goal is to facilitate the exploration and
development of statistical and graphic methods for multivariate data in
a geospatial context of historical interest. **Documentation**:
[rdrr.io/cran/Guerry/](https://rdrr.io/cran/Guerry/)

### [WordPools](https://github.com/friendly/WordPools)

[<img src='https://raw.githubusercontent.com/friendly/WordPools/master/man/figures/logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/WordPools)
Collects several classical word pools used most often to provide lists
of words in psychological studies of learning and memory. It provides a
simple function, ‘pickList’ for selecting random samples of words within
given ranges. **Documentation**:
[friendly.github.io/WordPools/](https://friendly.github.io/WordPools/)

### [Lahman](https://github.com/cdalzell/Lahman)

[<img src='https://raw.githubusercontent.com/cdalzell/Lahman/master/man/figures/Lahman_hex.png' height='120' align='left' style="padding:'20px'">](https://github.com/cdalzell/Lahman)
Provides the tables from the ‘Sean Lahman Baseball Database’ as a set of
R data.frames. It uses the data on pitching, hitting and fielding
performance and other tables from 1871 through 2022, as recorded in the
2023 version of the database. Documentation examples show how many
baseball questions can be investigated. **Documentation**:
[rdrr.io/cran/Lahman/](https://rdrr.io/cran/Lahman/)

### [statquotes](https://github.com/friendly/statquotes)

[<img src='https://raw.githubusercontent.com/friendly/statquotes/master/man/figures/statquotes-logo.png' height='120' align='left' style="padding:'20px'">](https://github.com/friendly/statquotes)
Generates a random quotation from a database of quotes on topics in
statistics, data visualization and science. Other functions allow
searching the quotes database by key term tags, or authors or creating a
word cloud. The output is designed to be suitable for use at the
console, in Rmarkdown and LaTeX. **Documentation**:
[rdrr.io/cran/statquotes/](https://rdrr.io/cran/statquotes/)
