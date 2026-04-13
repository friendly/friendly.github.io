# Design notes

* The design of the packages page, `packages.qmd` is very awkward to work with, modify and maintain because it uses
  many nested `:::` divs. 
  
* I like the style used by Danielle Navarro: https://code.djnavarro.net/ for package descriptions

* Defines useful functions for doing cards in `index.qmd`

https://github.com/djnavarro/code/blob/main/index.qmd
https://raw.githubusercontent.com/djnavarro/code/refs/heads/main/index.qmd


```{r}
#| echo: false
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

# other functions, to make a shaded strip at the top of each card; not needed here
```

Then cards are done with code chunks, like so:

::: {.grid}

```{r}
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

card(
  title = "emaxnls", 
  text = "Inspired by the BayesERtools and rstanemax packages I've worked on with Kenta Yoshida, I started thinking about what a lightweight frequentist (yes, frequentist. sue me) tool for Emax regression in R would look like. It would be an act of utter madness to use this package in its current form, but I love the idea enough that I'm listing it on this page anyway", 
  buttons = list(
    button("https://emaxnls.djnavarro.net/", "docs"),
    button("https://github.com/djnavarro/emaxnls", "repo")
  ),
  image = image(
    src = "img/emaxnls.png", 
    url = "https://emaxnls.djnavarro.net/", 
    alt = "Abstract generative art"
  )
)

  ...

:::


* Instead of the colored strips she uses for the cards, I'd like to use the hex logos for my packages.

* You need not use the same div class paramerters she does, like `<div class="g-col-12 g-col-md-6 g-col-xl-4">`

