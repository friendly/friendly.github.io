library(DiagrammeR); library(DiagrammeRsvg); library(rsvg)
# run from the diagrams/ folder
for (f in list.files(pattern = "[.]dot$")) {
  svg <- export_svg(grViz(paste(readLines(f), collapse = "\n")))
  out <- sub("[.]dot$", ".png", f)
  rsvg_png(charToRaw(svg), out, width = 1400)
  cat("wrote", out, "\n")
}
