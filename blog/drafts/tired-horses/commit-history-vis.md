# Notes: a cross-project commit history visualization

Working notes toward a possible companion visualization for "All the Tired
Horses" — the post is about getting pulled into detours across projects while
writing; a timeline of *actual* commit activity across projects might make that
concrete rather than anecdotal.

## What GitHub already shows

Two built-in views, neither of which does what we want directly:

1. **Profile contribution calendar** (`github.com/<user>`) — the familiar
   green-square heatmap. Aggregates commits/PRs/issues/reviews across *all*
   repos into one calendar. Good for "was I active that day" at a glance, but
   it's a single merged signal — you can't tell which project a square belongs
   to, and it can't be filtered to a hand-picked subset of repos.
2. **Per-repo Insights → Contributors** graph — a weekly commit bar/line chart,
   scoped to one repo at a time, with a per-author breakdown. This is the
   closest thing to "commit timeline," but it only ever shows one repo. Insights
   → Pulse gives a similar but coarser summary for a single recent period
   (week/month), also one repo at a time.

Neither offers a *side-by-side, custom-date-range, multi-repo* view. That's the
gap this note is about: putting several projects' timelines on one shared axis
so the switching between them is visible.

## Project list (final, for now)

Seven repos: `Vis-MLM-book`, `vcdExtra`, `heplots`, `candisc`, `HistData`,
`friendly.github.io` (the blog itself), and `psy6136` (the Categorical Data
Analysis course, taught Winter term 2026 — a lot of material lives there too,
and it's on GitHub at `friendly/psy6136`, same as the R packages).

## Initial rough pass (local `git log`, since 2025-09-01)

Before pulling authoritative data (see below), a quick pass across local
clones, filtered to my own commits, bucketed by ISO week, showed the pattern
worth designing for: candisc's burst ends exactly as heplots' begins;
vcdExtra's huge Jan-2026 spike lines up with a Vis-MLM-book lull; several
weeks have two or three projects active simultaneously. That overlap/handoff
pattern is the actual story — worth designing the chart to make *that*
legible, not just raw volume per project.

**Caveat that motivated pulling from GitHub instead:** local `git log` only
reflects what's pulled into *this* machine's clone. We hit this exact gap
that same day with HistData (local was 4 commits behind `origin/master` from
work done on another machine) — local history can't be trusted as
authoritative when work happens across machines.

## Authoritative pull: done

`pull-commit-history.R` (this folder) pulls the full commit history for all
seven repos directly from GitHub via `gh api graphql` (not local clones, not
filtered to one author — the raw dataset carries `author_name`/`author_email`
so authorship can still be filtered in R later). Output:
`data/commit-history.csv` / `data/commit-history.rds`, one row per commit:

`repo, sha, date, author_name, author_email, additions, deletions,
files_changed, message, week (ISO year-week), week_start (Monday date)`

Current pull: **1,472 commits**, 2025-09-01 through today.

| Project | Commits |
|---|---|
| Vis-MLM-book | 555 |
| vcdExtra | 455 |
| friendly.github.io | 178 |
| candisc | 82 |
| psy6136 | 71 |
| HistData | 69 |
| heplots | 62 |

**Gotchas hit building the puller (documented in the script's comments too,
since it'll get re-run to refresh data before publication):**

- `gh api graphql --paginate` concatenates raw pages into invalid
  multi-document JSON for this query shape rather than merging them — paginate
  manually instead (one call per page, following `pageInfo.hasNextPage`).
  
- The GraphQL query string and the pagination cursor both need to go through
  the `-F field=@file` (typed field, file-read) form, not `-f field=value`
  inline — the query is multi-line and the cursor can contain a literal space
  (e.g. `"<sha> 99"`), and both break Windows argv parsing when passed as a
  plain inline argument.
  
- Capturing `gh`'s stdout via `system2(..., stdout = TRUE)` silently corrupts
  multi-byte UTF-8 in commit messages (R re-encodes through the Windows native
  locale on the way in) — write to a file and read it back via
  `file(path, encoding = "UTF-8")` instead.
  
- Requesting `additions`/`deletions`/`changedFilesIfAvailable` at the GraphQL
  max page size (100) times out into a plain-nginx 502 on repos with large
  diffs (hit this on Vis-MLM-book, a book project with big image/PDF commits).
  Dropped to a page size of 25 — more round trips, but reliable.

## Form options (per the dataviz skill's form-first procedure)

Six-ish series (soft cap territory — legend or small multiples, not a single
overlaid chart with 6 hues fighting for attention). Three candidate forms:

**A. GitHub-style calendar heatmap, stacked as small multiples**
One calendar row per project, all sharing the same week columns, sequential
color = commits that day. Most literally mirrors "what GitHub's view looks
like," extended across projects. Downside: calendar-grid layout (7 rows ×
~49 columns per project) gets tall and wide fast for 6 projects, and it
encodes daily granularity we don't really have a strong reason to need (these
are R packages/writing, not daily-cadence work).

**B. Small-multiple weekly area/bar strips, one per project, shared x-axis**
One thin horizontal strip per project (weekly commit count as bar height or
area), all stacked vertically against the *same* continuous week axis (no
calendar wrapping). Reads like a set of sparklines. Directly shows bursts,
gaps, and — critically, since rows share an axis — vertical alignment shows
when two projects were active in the same week. This is the closest form to
what the table above already suggests is the real story.

**C. Continuous swimlane / strip-plot timeline**
x = date (continuous), y = project (categorical row), a mark per active
week (dot or tick), sized/opacity by commit count. Similar information to B
but even more minimal — good for emphasizing *presence/absence* (was I in this
project this week, yes/no) over exact volume. Better than B specifically for
selling the "which horse am I riding this week" narrative; worse if volume
differences matter to the point being made.

**Recommendation:** B as the primary chart — small multiples, shared
continuous week axis, one hue per project row (categorical, fixed order,
≤6 series is within the soft cap so this is fine — see
`references/choosing-a-form.md` in the dataviz skill), sequential lightness
within each row's hue for weekly volume. Layering C's presence/absence framing
as annotation (e.g., a thin marker row at the bottom showing "which project
was most active this week") could reinforce the post's point without a second
full chart.

## Public gist

`pull-commit-history.R` published as a standalone public gist (2026-08-10):
<https://gist.github.com/friendly/22b0ce148eaa2318fafd74526a155eea> -- link to
use for a BlueSky mention and/or to cite from the tired-horses post itself
alongside the ridgeline figures (`figures/commits-ridgeline.png`,
`figures/commits-ridgeline-files.png`).

## Still to decide / do

- Granularity: weekly, confirmed.
- Build the chart itself (form B from above: small-multiple weekly strips, 7
  rows now instead of 6 — still comfortably within the soft cap).
- Run the palette through `validate_palette.js` once colors are chosen for the
  7 project rows.
- Where does this live: embedded in the "Tired Horses" post itself, or a
  separate short post/page it links to?
- Before final publication, re-run `pull-commit-history.R` to pick up any
  last-minute commits (cheap — ~2-3 min for all seven repos).
