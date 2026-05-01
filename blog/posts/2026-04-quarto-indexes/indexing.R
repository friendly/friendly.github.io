# indexing.R
# R helper functions for automatic indexing in Quarto books with dual HTML/PDF output.
#
# Each function formats R names (packages, datasets, functions) appropriately per
# output format, and emits LaTeX \index{} entries (via macros) for PDF builds.
#
# Requires:
#   - colorize package  (for pkg() / package() color output)
#   - stringr package   (for dataset() / func() pkg::name parsing)
#   - knitr             (for is_latex_output() / is_html_output())
#
# Corresponding LaTeX macros (place in `preamble.tex`):
#
#   \newcommand{\ixp}[1]{%           % packages
#     \index{#1@\texttt{#1} package}%
#     \index{packages!#1@\texttt{#1}}%
#   }
#   \newcommand{\ixd}[1]{%           % datasets
#     \index{#1@\texttt{#1} data}%
#     \index{datasets!#1@\texttt{#1}}%
#   }
#   \newcommand{\ixfunc}[2]{%        % functions: #1 = sort key, #2 = display text
#     \index{#1@\texttt{#2}}%
#   }
#   \newcommand{\IX}[1]{\index{#1}#1}
#   \newcommand{\ix}[1]{\index{#1}}
#   \newcommand{\ixmain}[1]{\index{#1|textbf}}
#   \newcommand{\ixon}[1]{\index{#1|(}}
#   \newcommand{\ixoff}[1]{\index{#1|)}}
#
# Usage: source("indexing.R") at the top of each chapter, or in a file `_common.R.`

# ---- Helpers -----------------------------------------------------------------

# Escape underscores for LaTeX display text (sort keys keep raw _)
escape <- function(name) gsub("_", "\\_", name, fixed = TRUE)

# Build a makeindex sort@display entry with name in \texttt{}
tt <- function(name) paste0(name, "@\\texttt{", escape(name), "}")

# ---- Configuration -----------------------------------------------------------

pkgname_font  <- "bold"   # "plain" | "ital" | "bold" | "boldital"
pkgname_color <- "brown"  # any color recognised by colorize(); NULL to suppress

# ---- pkg() -------------------------------------------------------------------
#' Format an R package name for inline use and add a PDF index entry.
#'
#' @param package  Package name as a character string.
#' @param cite     If TRUE, append a citation key of the form [@R-package].
#' @return A character string ready for inline `r ...` use.
#'
#' @examples
#' # The `r pkg("ggplot2")` package ...
#' # The `r pkg("dplyr", cite = TRUE)` package ...
pkg <- function(package, cite = FALSE) {
  if (knitr::is_latex_output()) {
    pkgname <- dplyr::case_when(
      pkgname_font == "ital"     ~ paste0("\\texttt{\\textit{", package, "}}"),
      pkgname_font == "bold"     ~ paste0("\\texttt{\\textbf{", package, "}}"),
      pkgname_font == "boldital" ~ paste0("\\texttt{\\textit{\\textbf{", package, "}}}"),
      .default = package
    )
  } else {
    pkgname <- dplyr::case_when(
      pkgname_font == "ital"     ~ paste0("_", package, "_"),
      pkgname_font == "bold"     ~ paste0("**", package, "**"),
      pkgname_font == "boldital" ~ paste0("***", package, "***"),
      .default = paste0("\\texttt{", package, "}}")
    )
  }

  ref <- if (!is.null(pkgname_color)) colorize(pkgname, pkgname_color) else pkgname
  if (cite) ref <- paste0(ref, " [@R-", package, "]")
  # NO \n around macro: multi-line inline output causes pandoc to insert %,
  # which can silently comment out a following \footnote{}.
  if (knitr::is_latex_output()) ref <- paste0(ref, "\\ixp{", package, "}")
  ref
}

# ---- package() ---------------------------------------------------------------
#' Like pkg(), but appends the word "package" after the name.
#'
#' @inheritParams pkg
#' @examples
#' # The `r package("car")` provides ...
package <- function(package, cite = FALSE) {
  if (knitr::is_latex_output()) {
    pkgname <- dplyr::case_when(
      pkgname_font == "ital"     ~ paste0("\\texttt{\\textit{", package, "}}"),
      pkgname_font == "bold"     ~ paste0("\\texttt{\\textbf{", package, "}}"),
      pkgname_font == "boldital" ~ paste0("\\texttt{\\textit{\\textbf{", package, "}}}"),
      .default = paste0("\\texttt{", package, "}}")
    )
  } else {
    pkgname <- dplyr::case_when(
      pkgname_font == "ital"     ~ paste0("_", package, "_"),
      pkgname_font == "bold"     ~ paste0("**", package, "**"),
      pkgname_font == "boldital" ~ paste0("***", package, "***"),
      .default = package
    )
  }

  ref <- if (!is.null(pkgname_color)) paste(colorize(pkgname, pkgname_color), "package") else paste(pkgname, "package")
  if (cite) ref <- paste0(ref, " [@R-", package, "]")
  if (knitr::is_latex_output()) ref <- paste0(ref, "\\ixp{", package, "}")
  ref
}

# ---- dataset() ---------------------------------------------------------------
#' Format a dataset name for inline use and add PDF index entries.
#'
#' Supports bare names or pkg::name syntax; the latter also indexes the package.
#'
#' @param name     Dataset name, optionally as "pkg::name".
#' @param package  Package name (alternative to pkg::name syntax).
#'
#' @examples
#' # The `r dataset("Prestige", "carData")` dataset ...
#' # The `r dataset("carData::Prestige")` dataset ...
dataset <- function(name, package = NULL) {
  dname <- name
  dpkg  <- package
  if (stringr::str_detect(name, "::")) {
    wds   <- stringr::str_split(name, "::", 2)[[1]]
    dname <- wds[2]
    dpkg  <- wds[1]
  }

  if (knitr::is_latex_output()) {
    ref <- paste0("\\texttt{", name, "}")
    # NO \n: see pkg() comment above.
    ref <- paste0(ref, "\\ixd{", dname, "}")
    if (!is.null(dpkg)) ref <- paste0(ref, "\\ixp{", dpkg, "}")
  } else {
    ref <- paste0("`", name, "`")
  }
  ref
}

# ---- func() ------------------------------------------------------------------
#' Format an R function name for inline use and add a PDF index entry.
#'
#' Handles underscores in names (e.g. stat_ellipse()) via escape().
#' Supports pkg::name syntax; the package is NOT separately indexed.
#'
#' @param name     Function name (include parentheses), optionally "pkg::name()".
#' @param package  Package name (alternative to pkg::name syntax; currently unused
#'                 in index entry but reserved for future cross-referencing).
#' @param test     If TRUE, emit index markup even outside LaTeX (for testing).
#'
#' @examples
#' # Use `r func("lm()")` to fit a model.
#' # The `r func("stat_ellipse()")` layer adds ...
func <- function(name, package = NULL, test = FALSE) {
  fname <- name
  if (stringr::str_detect(name, "::")) {
    wds   <- stringr::str_split(name, "::", 2)[[1]]
    fname <- wds[2]
  }

  if (knitr::is_latex_output()) {
    ref <- paste0("\\texttt{", escape(name), "}")
  } else {
    ref <- paste0("`", name, "`")
  }

  if (knitr::is_latex_output() || test) {
    # Two-argument form: sort key keeps raw _ (makeindex sorts on it as plain text);
    # display text uses \_ so LaTeX can typeset it from the .ind file.
    ref <- paste0(ref, "\\ixfunc{", fname, "}{", escape(fname), "}")
  }
  ref
}
