# Design notes

* I like the style used by Danielle Navarro: https://code.djnavarro.net/ for package descriptions

* Defines useful functions for doing cards:

https://github.com/djnavarro/code/blob/main/index.qmd
https://raw.githubusercontent.com/djnavarro/code/refs/heads/main/index.qmd

card <- function(title, text, buttons, image) {
  lines <- c(
    '<div class="g-col-12 g-col-md-6 g-col-xl-4">',
    '<div class="card h-100">',
    image,
    '<div class="card-body">',
    paste0('<h2 class="card-title">', title, '</h2>'),
    paste0('<p class="card-text">', text, '</p>'),
    '</div>',
    '<div class="card-footer">',
    unlist(buttons),
    '</div>',
    '</div>',
    '</div>'
  )
  cat(lines, sep="\n")
}

image <- function(src, url, alt, make = TRUE) {
  if (make) make_image(src)
  paste0(
    '<a href="', url, '"><img src="', src, '"', 'alt = "', alt, '"', 'class="card-img-top"></a>'
  )
}

button <- function(url, text) {
  paste0('<a href="', url, '" class="btn btn-primary">', text, '</a>')
}

Then: 

#| echo: false
#| results: asis

card(
  title = "sessioncheck", 
  text = "Simple tools for checking the state of the R session. Very early-stage package (not on CRAN), intended as a drop-in replacement for the heuristic method of using `rm()` to clear the global environment at the top of a script; aimed at intermediate-level R users that may not be ready for advanced session management tools", 
  buttons = list(
    button("https://sessioncheck.djnavarro.net/", "docs"),
    button("https://github.com/djnavarro/sessioncheck", "repo")
  ),
  image = image(
    src = "img/sessioncheck.png", 
    url = "https://sessioncheck.djnavarro.net/", 
    alt = "Abstract generative art"
  )
)


