library(hexsession)
#library(chromote)  - no longer needed

# pkgs <- c("heplots", "candisc", "mvinfluence", "genridge", "VisCollin",
#           "matlib", "gellipsoid", "twoway",
#           "vcdExtra", "nestedLogit",  # "vcd",
#           "HistData", "Guerry", "Lahman" )

pkgs <- c("heplots", "candisc", "mvinfluence", "genridge", "VisCollin",
          "matlib", "gellipsoid", "twoway", "ggbiplot",
          "vcdExtra", "nestedLogit",
          "HistData", "Guerry", "Lahman", "WordPools"
          )



# load my packages
sapply(pkgs, function(x)require(x, character.only = T))

sessionInfo()

# remove unwanted -- unnecessary, now that we can pass `packages` to `make_tile()`
#pacman::p_unload(unwanted)
# "broom", "car", "carData": cant detach
unwanted <- c("carData", "gnm", "grid", "rgl", "vcd") # "broom": cant detach
for (pkg in unwanted) {
  detach(paste0("package:", pkg), character.only = TRUE)
}

# Make the image
make_tile(packages = pkgs)

# TODO: When run interactively, this prompts for all pkgs that have 'multiple possible logos' --
#       Don't know if this affects running via an agent.
# Package: twoway - Multiple possible logos. Please select the image to use:
#
# 1: logo-old.png
# 2: logo.jpg
# 3: logo.png
# 4: None of the above

# TODO: How to get this into an image or something with the right shape: number of rows? -- Usually manipulate the Viewer width, then take a screenshot
# TODO: make_tile() generates an interactive HTML file. How to use this in my blog?
# TODO: Can we make the background transparent? NB: make_tile() has a`dark_mode` arg, but this just paints the bkgrnd black

snap_tile(here::here("images", "hexsession-mypkgs2.png"))

package_data <- readRDS("C:/Dropbox/R/projects/friendly.github.io/temp_hexsession/package_data.rds")

package_data$logopaths
package_data$urls


