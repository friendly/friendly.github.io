library(HistData)
data(Langren1644)

####################################################
# Reproduction of Langren's graph overlaid on a map
####################################################

# step 1: draw backgound Google map
  gimage <- readJPEG(system.file("images", "google-toledo-rome3.jpg", package = "HistData"))
  # NB: dimensions from readJPEG are y, x, colors

  gdim <- dim(gimage)[1:2]
  ylim <- c(1, gdim[1])
  xlim <- c(1, gdim[2])
  op <- par(bty = "n", xaxt = "n", yaxt = "n", mar = c(2, 1, 1, 1) + 0.1)
  # NB: necessary to scale the plot to the pixel coordinates, and use asp=1
  plot(xlim, ylim, xlim = xlim, ylim = ylim, type = "n", ann = FALSE, asp = 1)
  rasterImage(gimage, 1, 1, gdim[2], gdim[1])

# 2. Plot labels for Toledo and Rome
  # pixel coordinates of Toledo and Rome in the image, measured from the bottom left corner
  toledo.map <- c(131, 59)
  rome.map   <- c(506, 119)

  # draw points and labels
  points(rbind(toledo.map, rome.map), cex = 2)
  text(131, 95,  "Toledo", cex = 1.5)
  text(506, 104, "Roma",   cex = 1.5)

# 3. Draw van Langren's 1d dot plot
  # set a scale for translation of lat,long to pixel x,y
  scale <- data.frame(x = c(131, 856), y = c(52, 52))
  rownames(scale) <- c(0, 30)

  # translate from degrees longitude to pixels
  xlate <- function(x) {
    131 + x * 726 / 30
  }

  # draw an axis
  lines(scale)
  ticks <- xlate(seq(0, 30, 5))
  segments(ticks, 52, ticks, 45)
  text(ticks, 40, seq(0, 30, 5))
  text(xlate(8), 67, "Grados de la Longitud", cex = 1.7)

  # label the observations with the names
  points(x = xlate(Langren1644$Longitude), y = rep(57, nrow(Langren1644)),
         pch = 25, col = "blue", bg = "blue")
  text(x = xlate(Langren1644$Longitude), y = rep(57, nrow(Langren1644)),
       labels = Langren1644$Name, srt = 90, adj = c(-.1, .5), cex = 0.8)
  par(op)

##############################################################
# ggplot2 Version 1: dot plot overlaid on the Google map
# (initial cut — kept for reference)
##############################################################
library(ggplot2)
library(showtext)

# ── Font selection ───────────────────────────────────────────────────────────
# To try a different font, edit ONE of the blocks below and set font_fam.
#
# Option A — Google Font (downloads automatically):
font_add_google("IM Fell English", "imfell")
font_fam <- "imfell"
#
# Option B — Local / commercial font (P22, Gilbert, etc.):
#   Find installed font files with: sysfonts::font_files()
#   Then load by path, e.g.:
#font_add("gilbert",  regular = "C:/Windows/Fonts/Gilbert-Regular.ttf")
#font_fam <- "gilbert"
#font_add("operina",  regular = "C:/Windows/Fonts/P22Operina-Regular.otf")
#font_fam <- "operina"
# ────────────────────────────────────────────────────────────────────────────
showtext_opts(dpi = 96)   # match screen DPI; fixes size mismatch when exporting
showtext_auto()

langren_px <- transform(Langren1644,
  px = xlate(Longitude),
  py = 57
)

ggplot(langren_px, aes(x = px, y = py)) +
  annotation_raster(gimage,
    xmin = 1, xmax = gdim[2],
    ymin = 1, ymax = gdim[1]) +
  annotate("point", x = c(131, 506), y = c(59, 119), size = 3) +
  annotate("text", x = 131, y = 95,  label = "Toledo", family = font_fam, size = 5) +
  annotate("text", x = 506, y = 104, label = "Roma",   family = font_fam, size = 5) +
  annotate("segment", x = 131, xend = 856, y = 52, yend = 52) +
  annotate("segment",
    x    = xlate(seq(0, 30, 5)), xend = xlate(seq(0, 30, 5)),
    y    = 52,                   yend = 45) +
  annotate("text",
    x = xlate(seq(0, 30, 5)), y = 40,
    label = seq(0, 30, 5), family = font_fam, size = 4) +
  annotate("text", x = xlate(8), y = 17,
    label = "Grados de la Longitud", family = font_fam, size = 5.5) +
  geom_point(shape = 25, fill = "blue", color = "blue", size = 2.5) +
  geom_text(aes(label = Name),
    angle = 90, hjust = -0.1, vjust = 0.5,
    family = font_fam, size = 2.8) +
  coord_fixed(ratio = 1,
    xlim = c(1, gdim[2]), ylim = c(1, gdim[1]),
    expand = FALSE) +
  theme_void()

##############################################################
# ggplot2 Version 2: standalone reproduction of the original
##############################################################

# van Langren centred "ROMA" above ~23.5°; the true distance (16°31') was unknown at the time
roma_x <- 23.5

# Snowman = two stacked open circles, body (larger) sitting on the axis.
# body_y: centre of body — set to approx one body-radius above y=0 so the
#   bottom of the circle rests on the axis line.
# head_y: centre of head — set so it clears the top of the body.
# Both are in data units and depend on figure width; tune if needed.
body_size <- 4.0
head_size <- 2.5
body_y    <- 0.50   # ≈ body radius in data units (figure ~7 in wide)
head_y    <- 0.80   # ≈ body_y + body_radius + head_radius; decrease if gap persists

ggplot(Langren1644, aes(x = Longitude)) +
  # axis line
  annotate("segment", x = 0, xend = 32, y = 0, yend = 0,
    linewidth = 0.6) +
  # minor tick marks every 1°
  annotate("segment",
    x = seq(0, 32, 1), xend = seq(0, 32, 1),
    y = 0, yend = -0.15, linewidth = 0.3) +
  # major ticks at 10°, 20°, 30°
  annotate("segment",
    x = c(10, 20, 30), xend = c(10, 20, 30),
    y = 0, yend = -0.35, linewidth = 0.6) +
  # tick labels
  annotate("text",
    x = c(10, 20, 30), y = -0.6,
    label = c("10.", "20.", "30."),
    family = font_fam, size = 3.5) +
  # snowman bodies (filled circle, bottom resting on axis)
  geom_point(aes(y = body_y),
    shape = 21, size = body_size, fill = "black", color = "black", stroke = 0.8) +
  # snowman heads (smaller circle, above body)
  geom_point(aes(y = head_y),
    shape = 21, size = head_size, fill = "white", color = "black", stroke = 0.8) +
  # Toledo snowman at the origin (Toledo is the x = 0 reference, not a data row)
  annotate("point", x = 0, y = body_y,
    shape = 21, size = body_size, fill = "black", color = "black", stroke = 0.8) +
  annotate("point", x = 0, y = head_y,
    shape = 21, size = head_size, fill = "white", color = "black", stroke = 1.0) +
  # astronomer names, rotated 90°, starting above the head
  geom_text(aes(y = head_y + 0.35, label = paste0(Name, ".")),
    angle = 90, hjust = 0, vjust = 0.5,
    family = font_fam, size = 4, fontface = "italic") +
  # "TOLEDO." written vertically at the left edge
  annotate("text", x = -0.8, y = 3.5,
    label = "TOLEDO.", angle = 90,
    family = font_fam, size = 4.2, fontface = "bold") +
  # "ROMA" below the axis at van Langren's believed position
  annotate("text", x = roma_x, y = 0,
    label = "ROMA", family = font_fam, size = 4.2,
    fontface = "bold", vjust = 2.0) +
  # "Grados de la Longitud." ~20% larger and ~20% lower than before
  annotate("text", x = 6, y = 2.8,
    label  = "Grados de la Longitud.",
    family = font_fam, size = 6.6, hjust = 0, fontface = "italic") +
  coord_fixed(ratio = 1, xlim = c(-2, 33), ylim = c(-1.0, 6.5), expand = FALSE) +
  theme_void()
