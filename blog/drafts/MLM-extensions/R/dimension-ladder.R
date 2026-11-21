# Diagram: going from lm to mlm, every object gains a dimension.
# Draws figures/dimension-ladder.png. Run from the post folder:
#   Rscript R/dimension-ladder.R
# Cells from the univariate (lm) object are blue; cells added by the extra
# response dimension are orange. Example sizes: p = 3 coefficients, q = 3 responses.

library(ggplot2)

col_lm  <- "#4C78A8"   # the lm object
col_new <- "#F58518"   # added by the extra dimension

# one cell per row of a data frame: x, y = lower-left corner; fill = which kind
cells <- function(nr, nc, x0, y0, fill, dx = 0, dy = 0) {
  g <- expand.grid(r = seq_len(nr), c = seq_len(nc))
  data.frame(xmin = x0 + g$c - 1 + dx, ymin = y0 - g$r + dy,
             fill = if (is.function(fill)) fill(g$r, g$c) else fill)
}

y1 <- 0; y2 <- -3; y3 <- -8.3      # top of each rung
xl <- 0; xr <- 7                 # left (lm) and right (mlm) columns
q   <- 3                         # number of responses drawn
off <- 0.45                      # offset between layers of the 3-way array

d <- rbind(
  # rung 1: scalar -> vector (a residual e_i -> q residuals)
  cells(1, 1, xl, y1, "lm"),
  cells(1, q, xr, y1, function(r, c) ifelse(c == 1, "lm", "new")),
  # rung 2: vector -> matrix (coefficients b -> B)
  cells(3, 1, xl, y2, "lm"),
  cells(3, q, xr, y2, function(r, c) ifelse(c == 1, "lm", "new")),
  # rung 3: matrix -> 3-way array (CIs: p x 2 -> p x 2 x q); back layer first
  cells(3, 2, xl, y3, "lm"),
  # q - 1 back layers, drawn back to front, each offset up and to the right
  do.call(rbind, lapply((q - 1):1, function(k)
    cells(3, 2, xr, y3, paste0("back", k), dx = k * off, dy = k * off))),
  cells(3, 2, xr, y3, "lm")
)
d$xmax <- d$xmin + 1
d$ymax <- d$ymin + 1

lab <- data.frame(
  x = c(xl, xr, xl, xr, xl, xr),
  y = c(y1 - 1, y1 - 1, y2 - 3, y2 - 3, y3 - 3, y3 - 3) - 0.25,
  label = c("e[i]:~scalar", "bold(e)[i]:~q~vector",
            "bold(b):~p~vector", "bold(B):~p%*%q~matrix",
            "CI~'for'~bold(b):~p%*%2~(list(lwr,~upr))", "CI~'for'~bold(B):~p%*%2%*%q~array")
)
mid <- c(y1 - 0.5, y2 - 1.5, y3 - 1.5)   # vertical centers of the rungs
rung <- data.frame(x = -0.6, y = mid,
                   label = c("scalar → vector", "vector → matrix",
                             "matrix → 3-way array"))
arrows <- data.frame(x = 3.2, xend = 5.8, y = mid)
heads  <- data.frame(x = c(xl + 1, xr + 1.5), y = 2.3,
                     label = c("lm:  one response", "mlm:  q responses"))

p <- ggplot() +
  geom_rect(data = d, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill),
            colour = "white", linewidth = 0.8) +
  scale_fill_manual(values = c(lm = col_lm, new = col_new,
                               back1 = col_new, back2 = "#F8B26A"),  # farther back = lighter
                    guide = "none") +
  geom_segment(data = arrows, aes(x = x, xend = xend, y = y, yend = y),
               arrow = arrow(length = unit(0.12, "inches"), type = "closed"),
               colour = "grey40", linewidth = 0.7) +
  geom_text(data = lab, aes(x, y, label = label), parse = TRUE,
            hjust = 0, vjust = 1, size = 4.2) +
  geom_text(data = rung, aes(x, y, label = label), hjust = 1, size = 5.5,
            fontface = "bold", colour = "grey20") +
  geom_text(data = heads, aes(x, y, label = label), hjust = 0.5, size = 6, fontface = "bold") +
  coord_equal(xlim = c(-7, 12.5), ylim = c(-12.4, 2.8), clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(10, 10, 10, 10))

ragg::agg_png("figures/dimension-ladder.png", width = 8, height = 6.8, units = "in", res = 200)
print(p)
invisible(dev.off())
