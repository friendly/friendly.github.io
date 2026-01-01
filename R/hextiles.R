#library(hexsession)
#library(chromote)

pkgs <- c("heplots", "candisc", "mvinfluence", "genridge", "VisCollin",
          "matlib", "gellipsoid", "twoway",
          "vcdExtra", "nestedLogit",  # "vcd",
          "HistData", "Guerry", "Lahman" )



# load my packages
sapply(pkgs, function(x)require(x, character.only = T))

sessionInfo()

# remove unwanted
#pacman::p_unload(unwanted)
# "broom", "car", "carData": cant detach
unwanted <- c("carData", "gnm", "grid", "rgl", "vcd") # "broom": cant detach
for (pkg in unwanted) {
  detach(paste0("package:", pkg), character.only = TRUE)
}

hexsession::make_tile()

package_data <- readRDS("C:/Dropbox/R/projects/friendly.github.io/temp_hexsession/package_data.rds")

package_data$logopaths
package_data$urls


