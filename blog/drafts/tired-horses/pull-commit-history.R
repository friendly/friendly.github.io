# Pull your GitHub commit history via the GraphQL API
#
# What was I working on, and when? How does work on one project relate to
# others? This pulls commit history for a hand-picked list of repos into one
# tidy dataset, so you can answer that with data instead of memory.
#
# ---------------------------------------------------------------------------
# What it does
# ---------------------------------------------------------------------------
# Pulls commits and their attributes from GitHub directly via `gh api
# graphql`, not from local clones -- a local clone can lag behind `origin`
# whenever work happens on more than one machine, which silently makes local
# `git log` an unreliable source of truth.
#
# ---------------------------------------------------------------------------
# Requirements
# ---------------------------------------------------------------------------
# * The GitHub CLI (`gh`), installed and authenticated (`gh auth status`).
#   This script reuses that session -- no token handling here.
#   I ran this in a Claude session, where all this was taken care of.
#
# * R packages: dplyr, purrr, jsonlite, tibble, readr (`tibble`/`readr` are
#   used via `::` below rather than attached, so they just need to be
#   installed).
#
# ---------------------------------------------------------------------------
# What you get
# ---------------------------------------------------------------------------
# A tibble with one row per commit -- repo, sha, date, author name/email,
# additions/deletions/files changed, and the commit subject line -- written
# to `data/commit-history.csv` and `data/commit-history.rds` (relative to
# your working directory; the `data/` folder is created if it doesn't exist).

library(dplyr)
library(purrr)
library(jsonlite)

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---------------------------------------------------------------------------
# Configuration -- edit for your own use
# ---------------------------------------------------------------------------

# How far back to go
since_date <- "2025-09-01T00:00:00Z"

# The repos to pull, as (owner, name) pairs
repos <- tibble::tribble(
  ~owner,     ~name,
  "friendly", "HistData",
  "friendly", "Vis-MLM-book",
  "friendly", "vcdExtra",
  "friendly", "heplots",
  "friendly", "candisc",
  "friendly", "friendly.github.io",
  "friendly", "psy6136"
)

# The GraphQL max page size (100) reliably times out into a 502 on repos with
# large diffs once `additions`/`deletions`/`changedFilesIfAvailable` are
# requested -- hit this live on a book-project repo with big image/PDF
# commits. 25 stays reliable; it costs more round trips, but that's cheap
# next to a 502.
page_size <- 25L

# ---------------------------------------------------------------------------
# The GraphQL query
# ---------------------------------------------------------------------------
# `changedFilesIfAvailable` (not `changedFiles`) is deliberate: the plain
# field errors on commits GitHub hasn't finished computing a file count for,
# where the `IfAvailable` variant just returns null -- handled below via
# `%||%`.

history_query <- '
query($owner: String!, $name: String!, $since: GitTimestamp, $endCursor: String, $first: Int!) {
  repository(owner: $owner, name: $name) {
    defaultBranchRef {
      target {
        ... on Commit {
          history(first: $first, since: $since, after: $endCursor) {
            pageInfo { hasNextPage endCursor }
            nodes {
              oid
              committedDate
              additions
              deletions
              changedFilesIfAvailable
              author { name email }
              messageHeadline
            }
          }
        }
      }
    }
  }
}'

query_file <- tempfile(fileext = ".graphql")
writeLines(history_query, query_file)

#' Fetch one page of commit history via `gh api graphql`.
#'
#' Pagination is manual (not `gh --paginate`): that flag concatenates raw
#' pages back-to-back into invalid multi-document JSON for this query shape,
#' rather than merging them -- confirmed by testing against a repo with 82
#' commits (2 pages), which failed with a "trailing garbage" JSON parse
#' error. One `gh` call per page instead.
#'
#' The query and the pagination cursor are both passed via `-F field=@file`
#' (a file read), not inline via `-f field=value`: the query is multi-line,
#' and the cursor can contain a literal space (e.g. `"<sha> 2"`) -- both break
#' argv parsing on Windows when passed as a plain inline argument. This is a
#' Windows-only workaround, but it's harmless on macOS/Linux too.
fetch_page <- function(owner, name, since, cursor = NULL, max_tries = 4) {
  args <- c(
    "api", "graphql",
    "-F", paste0("query=@", query_file),
    "-f", paste0("owner=", owner),
    "-f", paste0("name=", name),
    "-f", paste0("since=", since),
    "-F", paste0("first=", page_size)
  )
  if (!is.null(cursor)) {
    cursor_file <- tempfile(fileext = ".txt")
    writeChar(cursor, cursor_file, useBytes = TRUE, eos = NULL)
    on.exit(unlink(cursor_file), add = TRUE)
    args <- c(args, "-F", paste0("endCursor=@", cursor_file))
  }
  # `gh` writes straight to a file, which we then read back forcing UTF-8:
  # capturing via `system2(stdout = TRUE)` instead re-encodes through R's
  # native/Windows locale and silently corrupts multi-byte UTF-8 in commit
  # messages (shows up as stray characters spliced into otherwise-plain
  # fields).
  out_file <- tempfile(fileext = ".json")
  on.exit(unlink(out_file), add = TRUE)

  # GitHub's API occasionally 502s transiently; retry with backoff before
  # giving up (seen live pulling a repo with ~550 commits of history).
  for (attempt in seq_len(max_tries)) {
    status <- system2("gh", args, stdout = out_file, stderr = out_file)
    if (status == 0) break
    msg <- paste(readLines(out_file, warn = FALSE), collapse = "\n")
    if (attempt == max_tries) {
      stop("gh api graphql failed for ", owner, "/", name, ":\n", msg)
    }
    wait <- 2^attempt
    message("  transient error, retrying in ", wait, "s: ",
            substr(gsub("\n", " ", msg), 1, 120))
    Sys.sleep(wait)
  }
  fromJSON(file(out_file, encoding = "UTF-8"), simplifyVector = FALSE)
}

#' Fetch full (since-filtered) commit history for one repo, all pages.
fetch_repo_history <- function(owner, name, since) {
  message("Fetching ", owner, "/", name, " ...")
  all_nodes <- list()
  cursor <- NULL
  repeat {
    page <- fetch_page(owner, name, since, cursor)
    target <- page$data$repository$defaultBranchRef$target
    if (is.null(target)) {
      warning("No default-branch commit history for ", owner, "/", name)
      break
    }
    hist <- target$history
    all_nodes <- c(all_nodes, hist$nodes)
    message("  ", length(all_nodes), " commits so far",
            if (hist$pageInfo$hasNextPage) "..." else " (done)")
    if (!hist$pageInfo$hasNextPage) break
    cursor <- hist$pageInfo$endCursor
  }

  if (length(all_nodes) == 0) {
    return(tibble::tibble(
      repo = character(), sha = character(), date = as.POSIXct(character()),
      author_name = character(), author_email = character(),
      additions = integer(), deletions = integer(), files_changed = integer(),
      message = character()
    ))
  }

  map_dfr(all_nodes, function(n) {
    tibble::tibble(
      repo = name,
      sha = n$oid,
      date = as.POSIXct(n$committedDate, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      author_name = n$author$name %||% NA_character_,
      author_email = n$author$email %||% NA_character_,
      additions = n$additions %||% NA_integer_,
      deletions = n$deletions %||% NA_integer_,
      files_changed = n$changedFilesIfAvailable %||% NA_integer_,
      message = n$messageHeadline %||% NA_character_
    )
  })
}

# ---------------------------------------------------------------------------
# Run it
# ---------------------------------------------------------------------------

commit_history <- pmap_dfr(repos, function(owner, name) {
  fetch_repo_history(owner, name, since_date)
})

commit_history <- commit_history %>%
  arrange(repo, date) %>%
  mutate(
    week = strftime(date, "%G-W%V", tz = "UTC"),
    week_start = as.Date(cut(as.Date(date), "week", start.on.monday = TRUE))
  )

dir.create("data", showWarnings = FALSE)
readr::write_csv(commit_history, "data/commit-history.csv")
saveRDS(commit_history, "data/commit-history.rds")

message(
  "\nWrote ", nrow(commit_history), " commits across ",
  dplyr::n_distinct(commit_history$repo), " repos to data/commit-history.{csv,rds}"
)

print(
  commit_history %>%
    count(repo, name = "n_commits") %>%
    arrange(desc(n_commits))
)
