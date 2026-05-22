# How to Manage Your Chunks

OK, you've written an R-based book with extensive code examples, all the output from analyses and all figures
are reproducible. But now, for publication--- online and in print--- you ask: Is it necessary to show all that code
inline? 

With Quarto, for HTML, it is easy to use the chunk option  `code-fold: {true, false, show}` to hide some in the online
version where they interfere with the flow of reading, while allowing the interested reader to unhide them.
But what about the printed PDF version? Here, you can use a `knitr` trick, `echo=knitr::is_html_output()` in the ` ```r{}`
chunk header to suppress code code you don't want to appear in the print version.

*Example here showing both code-fold and is_html_output in a simple context*

But there are other things you might want to keep track of in a large book project to make editing and review easier:

* Use of Quarto options like `#| label:` vs. old-style knitr chunk labels, ` ```r{label, }`
* Figure sizes, set by `#| fig-height:`, `#| fig-width:`, `#| out-width:`, ...

...

Wouldn't it be nice to scan your text and create a chunk database?



