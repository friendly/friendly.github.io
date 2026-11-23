# Diagram: coming down the ladder for the Pottery MANOVA, Y -> H, E -> lambda -> V -> p.
# Draws images/reducing-ladder.png. Run from the post folder:
#   Rscript R/reducing-ladder.R
# Companion to R/dimension-ladder.R (same palette): each step keeps fewer numbers,
# and the grey text under each arrow says what that step sets aside.
# The numbers are computed here, not typed in.

library(ggplot2)

col_y   <- "#4C78A8"   # data
col_h   <- "#F58518"   # hypothesis
col_e   <- "#9D9D9D"   # error
col_red <- "#54A24B"   # the reduced numbers
col_bg  <- "#EEF2F7"   # the funnel

# ---- the numbers ----
data(Pottery, package = "carData")
fit <- lm(cbind(Al, Fe, Mg, Ca, Na) ~ Site, data = Pottery)
aov <- car::Anova(fit)
H <- aov$SSP$Site
E <- aov$SSPE
n <- nrow(Pottery); q <- ncol(H)
s <- min(q, aov$df[["Site"]])
ev <- Re(eigen(solve(E, H), only.values = TRUE)$values)   # all q roots; car:::Pillai needs them
lambda <- ev[1:s]
pil <- car:::Pillai(ev, q = aov$df[["Site"]], df = aov$error.df)  # stat, F, df1, df2
V <- sum(lambda / (1 + lambda))
Fv <- pil[2]; df1 <- pil[3]; df2 <- pil[4]
pval <- pf(Fv, df1, df2, lower.tail = FALSE)

# ---- layout ----
# one cell per row: x, y = lower-left corner
cells <- function(nr, nc, x0, ytop, size, fill, alpha = 1) {
  g <- expand.grid(r = seq_len(nr), c = seq_len(nc))
  data.frame(xmin = x0 + (g$c - 1) * size, xmax = x0 + g$c * size,
             ymin = ytop - g$r * size, ymax = ytop - (g$r - 1) * size,
             fill = fill, alpha = if (is.function(alpha)) alpha(g$r, g$c) else alpha)
}
tri <- function(r, c) ifelse(r >= c, 1, 0.25)   # lower triangle: the distinct elements

ycs <- 0.4                                       # cell size for Y, so that 26 rows fit
x <- c(Y = 0, H = 6, E = 12, L = 21, V = 28.6, P = 36.2)
wN <- 2.6                                         # width of a cell holding a number

d <- rbind(
  cells(n, q, x[["Y"]], n * ycs / 2, ycs, "y"),
  cells(q, q, x[["H"]], q / 2, 1, "h", tri),
  cells(q, q, x[["E"]], q / 2, 1, "e", tri),
  cells(s, 1, x[["L"]], s / 2, 1, "r"),
  cells(1, 1, x[["V"]], 0.5, 1, "r"),
  cells(1, 1, x[["P"]], 0.5, 1, "r")
)
num <- d$fill == "r"                              # number cells are wider
d$xmax[num] <- d$xmin[num] + wN

vals <- data.frame(
  x = c(rep(x[["L"]], s), x[["V"]], x[["P"]]) + wN / 2,
  y = c(s / 2 - seq_len(s) + 0.5, 0, 0),
  label = c(ifelse(lambda < 0.1, sprintf("%.3f", lambda), sprintf("%.2f", lambda)),
            sprintf("%.3f", V), format(signif(pval, 2), scientific = TRUE))
)

right <- c(Y = x[["Y"]] + q * ycs, E = x[["E"]] + q, L = x[["L"]] + wN, V = x[["V"]] + wN)
arrows <- data.frame(x = right + 0.5, xend = c(x[["H"]], x[["L"]], x[["V"]], x[["P"]]) - 0.5)
aside <- data.frame(
  x = (arrows$x + arrows$xend) / 2, y = -0.8,
  label = c("cases,\ngrand means", "units,\ndirections",
            "how the size\nis spread over\ndimensions", "the size\nitself")
)

ytop <- 6.4; ybot <- -6.2
centers <- c(x[["Y"]] + q * ycs / 2, x[["H"]] + q / 2, x[["E"]] + q / 2,
             x[["L"]] + wN / 2, x[["V"]] + wN / 2, x[["P"]] + wN / 2)
heads <- data.frame(x = centers, y = ytop,
                    label = c("bold(Y)", "bold(H)", "bold(E)", "lambda[i]",
                              "Pillai~italic(V)", "italic(p)"))
counts <- data.frame(x = centers, y = ybot,
                     label = c(sprintf("%d × %d = %d", n, q, n * q),
                               "15 distinct", "15 distinct", sprintf("s = %d", s), "1",
                               sprintf("F = %.2f
on (%d, %d) df", Fv, df1, df2)))
rows <- data.frame(x = -2, y = c(ytop, ybot, -0.8),
                   label = c("object", "numbers", "set aside"))

xr <- x[["P"]] + wN + 0.6
funnel <- data.frame(x = c(-0.6, xr, xr, -0.6), y = c(5.7, 1.1, -1.1, -5.7))

p <- ggplot() +
  geom_polygon(data = funnel, aes(x, y), fill = col_bg) +
  geom_rect(data = d, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                          fill = fill, alpha = alpha),
            colour = "white", linewidth = 0.4) +
  scale_fill_manual(values = c(y = col_y, h = col_h, e = col_e, r = col_red), guide = "none") +
  scale_alpha_identity() +
  geom_text(data = vals, aes(x, y, label = label), colour = "white", size = 4,
            fontface = "bold") +
  geom_segment(data = arrows, aes(x = x, xend = xend, y = 0, yend = 0),
               arrow = arrow(length = unit(0.12, "inches"), type = "closed"),
               colour = "grey40", linewidth = 0.7) +
  geom_text(data = aside, aes(x, y, label = label), vjust = 1, size = 3.4,
            fontface = "italic", colour = "grey35", lineheight = 0.9) +
  geom_text(data = heads, aes(x, y, label = label), parse = TRUE, size = 5.5) +
  geom_text(data = counts, aes(x, y, label = label), vjust = 0.8, size = 3.8, lineheight = 0.9) +
  geom_text(data = rows, aes(x, y, label = label), hjust = 1, size = 3.8,
            fontface = "bold", colour = "grey20") +
  coord_equal(xlim = c(-6, xr), ylim = c(-7.4, 7), clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(10, 15, 10, 10))

ragg::agg_png("images/reducing-ladder.png", width = 11.5, height = 4.1, units = "in", res = 200)
print(p)
invisible(dev.off())
