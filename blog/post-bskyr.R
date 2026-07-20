# Post to Bluesky from R using the atrrr package
#
# FIRST-TIME SETUP (run once in the R console, not this script):
#   1. Add your handle to ~/.Renviron:  BSKY_HANDLE=datavisfriendly.bsky.social
#   2. Run: atrrr::auth(Sys.getenv("BSKY_HANDLE"))
#      -- it will prompt for your Bluesky app password (not your login password).
#      -- get one at: Bluesky > Settings > Privacy & Security > App Passwords
#      -- the token is stored encrypted on disk; you won't be prompted again.
#
# USAGE: source this file, then call bsky_post() or bsky_post_image().
# -----------------------------------------------------------------------

library(atrrr)

# Re-authenticate (only needed if the stored token has expired).
bsky_reauth <- function() {
  auth(Sys.getenv("BSKY_HANDLE"), overwrite = TRUE)
}

# Post plain text (≤ 300 chars). Returns the post URI invisibly.
# atrrr uses the stored token automatically; no auth call needed per-post.
bsky_post <- function(text, dry_run = FALSE) {
  stopifnot(nchar(text) <= 300)
  if (dry_run) {
    message("--- DRY RUN ---")
    message(text)
    message(sprintf("(%d chars)", nchar(text)))
    return(invisible(NULL))
  }
  result <- post_skeet(text = text)
  message("Posted: ", result$uri)
  invisible(result$uri)
}

# Post text with an image file (PNG/JPG). alt_text is strongly recommended.
bsky_post_image <- function(text, image_path, alt_text = "", dry_run = FALSE) {
  stopifnot(nchar(text) <= 300, file.exists(image_path))
  if (dry_run) {
    message("--- DRY RUN ---")
    message(text)
    message(sprintf("Image: %s  |  Alt: %s", image_path, alt_text))
    return(invisible(NULL))
  }
  result <- post_skeet(text = text,
                       images     = image_path,
                       image_alts = alt_text)
  message("Posted: ", result$uri)
  invisible(result$uri)
}

# -----------------------------------------------------------------------
# Examples (uncomment to use):

# -- plain text post --
# bsky_post("Hello from R! #rstats. I'm just giving the `atrrr` pkg a try.", dry_run = TRUE)
# bsky_post("Hello from R! #rstats. I'm just giving the `atrrr` pkg a try.")

# -- post with image --
# bsky_post_image(
#   text       = "New plot from my blog post. #rstats",
#   image_path = "blog/posts/2026-07-determinant-distributions/images/determinant_distribution_comparison.png",
#   alt_text   = "Distribution of determinants of 3x3 permutation matrices",
#   dry_run    = TRUE
# )

# -- the determinants post announcement --
# bsky_post(paste0(
#   "Extended my blog post on determinant distributions to 2×2 and 4×4 matrices. ",
#   "The 2×2 is perfectly uniform — no zeros possible. ",
#   "The 4×4 is *more* leptokurtic, not less (surprising!). ",
#   "Monte Carlo finds the shape; hill-climbing finds the extremes.\n\n",
#   "https://friendly.github.io/blog/posts/2026-07-determinant-distributions/\n\n",
#   "#rstats #linearalgebra"
# ))
