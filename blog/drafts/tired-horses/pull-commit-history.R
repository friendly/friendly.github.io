# Pull commit history for the "tired horses" cross-project timeline.
#
# Pulls from GitHub directly (GraphQL API via the `gh` CLI), not local clones --
# local clones can lag origin (we hit exactly this with HistData on 2026-08-07:
# local was 4 commits behind after work done on another machine). `gh` must
# already be authenticated (`gh auth status`); this reuses that session, no
# token handling needed here.
#
# One row per commit: repo, sha, date, author, additions/deletions/files
# changed, and the commit subject line. Written to data/commit-history.csv
# and .rds.

library(dplyr)
library(purrr)
library(jsonlite)

`%||%` <- function(x, y) if (is.null(x)) y else x

since_date <- "2025-09-01T00:00:00Z"

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

# Page size of 100 (the GraphQL max) times out into a 502 on repos with large
# diffs once `additions`/`deletions`/`changedFilesIfAvailable` are requested --
# hit this live on Vis-MLM-book (a book project with big image/PDF commits).
# 25 stays reliable; costs more round trips but that's cheap next to a 502.
page_size <- 25L

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
#' Manual pagination (not `gh --paginate`): that flag concatenates raw pages
#' back-to-back into invalid multi-document JSON for this query shape, rather
#' than merging them -- confirmed by testing against candisc (82 commits ->
#' 2 pages -> "trailing garbage" JSON parse error). One call per page instead.
#' The query is passed via `@file` (not inline) because Windows argv parsing
#' mangles a multi-line string passed directly as a `system2()` argument.
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
    # Cursor values can contain a literal space (e.g. "<sha> 2"), which breaks
    # Windows argv parsing when passed inline as `-f endCursor=<cursor>". Route
    # it through a file too, same as the query.
    cursor_file <- tempfile(fileext = ".txt")
    writeChar(cursor, cursor_file, useBytes = TRUE, eos = NULL)
    on.exit(unlink(cursor_file), add = TRUE)
    args <- c(args, "-F", paste0("endCursor=@", cursor_file))
  }
  # gh writes straight to a file, then we read it back forcing UTF-8: capturing
  # via system2(stdout = TRUE) re-encodes through R's native/Windows locale and
  # silently corrupts multi-byte UTF-8 bytes in commit messages (observed as
  # stray characters spliced into otherwise-plain fields like committedDate).
  out_file <- tempfile(fileext = ".json")
  on.exit(unlink(out_file), add = TRUE)

  # GitHub's API occasionally 502s transiently; retry with backoff before
  # giving up (seen live while pulling Vis-MLM-book's ~550-commit history).
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
