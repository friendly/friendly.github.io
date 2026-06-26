library(magick)

setwd(here::here("blog", "drafts", "BeachScience"))
beach <- image_read("images/LeucatePlage.jpg")   # replace extension if needed
pool  <- image_read("images/pool-son-juanedajpeg.jpeg") |> image_orient()

# Resize both to the same height, keeping aspect ratio
target_height <- 400

beach <- image_resize(beach, paste0("x", target_height))
pool  <- image_resize(pool,  paste0("x", target_height))

# Join side by side
banner <- image_append(c(beach, pool), stack = FALSE)

# Save
image_write(banner, "images/beach-pool-banner.jpg", quality = 90)
message("Saved: images/beach-pool-banner.jpg  (",
        image_info(banner)$width, " x ", image_info(banner)$height, ")")
