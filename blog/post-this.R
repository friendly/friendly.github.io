# Post announcing "Van Langren's Secret, Finally Told"
# https://friendly.github.io/blog/posts/2026-07-van-langren/
#
# Run from the repo root (or anywhere `here::here()` can find the project).
# Both calls default to dry_run = TRUE -- flip to FALSE once you're happy
# with the text.

source(here::here("blog", "post-bskyr.R"))

# -- main announcement --
# NOTE: still 309 chars (9 over Bluesky's 300 limit) even with the bit.ly link.
# Also has a typo -- "findinglon gitude" should be "finding longitude" (same
# length, so fixing it alone won't get you under the limit).
post_text <- paste0(
  "#datavis #history #rstats \U0001F4CA\n\n",
  "BREAKING: An historical puzzle bugging me for 16 years finally solved! ",
  "M.F. van Langren's secret code,\n\n",
  "accompanying the 1st statistical graph, has been cracked. Turns out his method of ",
  "findinglon gitude was based on a water clock, not his famous moon map.\n\n",
  "https://bit.ly/4fRfOBl"
)
nchar(post_text)

bsky_post(post_text, dry_run = TRUE)

# -- follow-up image skeet --
image_text <- paste0(
  "Page 8 of van Langren's 1644 \"La Verdadera Longitud\" -- the printed ",
  "cipher exactly as his readers first saw it. Stumped everyone for 393 years.\n\n",
  "https://friendly.github.io/blog/posts/2026-07-van-langren/"
)
nchar(image_text)

bsky_post_image(
  text       = image_text,
  image_path = here::here("blog/drafts/vanLangren/images/verdadera-cipher.jpg"),
  alt_text   = paste(
    "Page 8 of van Langren's 1644 book, showing his printed cipher:",
    "dense space-separated groups of letters and digits, justified",
    "across seventeen lines of type."
  ),
  dry_run = TRUE
)
