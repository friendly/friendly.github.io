library(colorspace)

n <- 25

jet <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                           "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))(n)

heat <- heat.colors(n)

viridis <- hcl.colors(n, "Viridis")

magma <- viridisLite::magma(n)

png("test-swatch.png", width = 900, height = 450, res = 120)

swatchplot(
  jet     = jet,
  heat    = heat,
  viridis = viridis,
  magma   = magma
)

dev.off()
