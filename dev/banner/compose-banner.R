# compose-banner.R
# Assemble the 4-zone banner strip from individual panel images
# Target: 1400 x 300 px (save at 2x = 2800 x 600 for retina)
#
# Panels (generate separately, save to plots/):
#   panel-1-historical-scan.png   -- original scanned figure
#   panel-2-histdata-repro.png    -- HistData + ggplot2 reproduction
#   panel-3-histdata-modern.png   -- HistData in modern analysis
#   panel-4-heplot.png            -- heplots HE-plot

library(magick)

PANEL_HEIGHT <- 600L   # px (2x for retina)
PANEL_WIDTH  <- 700L   # px each (4 panels = 2800 total)

# --- Load panels ---
p1 <- image_read("plots/panel-1-historical-scan.png")
p2 <- image_read("plots/panel-2-histdata-repro.png")
p3 <- image_read("plots/panel-3-histdata-modern.png")
p4 <- image_read("plots/panel-4-heplot.png")

# Resize all to same height, keeping aspect ratio
panels <- c(p1, p2, p3, p4) |>
  image_resize(paste0("x", PANEL_HEIGHT))

# Optionally: trim to uniform width and apply dissolve at boundaries
# (gradient mask approach — refine once panels are final)

# Simple side-by-side assembly
banner <- image_append(panels)

# Crop/pad to exact target dimensions
banner <- image_resize(banner, paste0(PANEL_WIDTH * 4, "x", PANEL_HEIGHT, "!"))

# Write output
image_write(banner, "banner-draft.png")
message("Written: banner-draft.png  (",
        image_info(banner)$width, " x ", image_info(banner)$height, " px)")
