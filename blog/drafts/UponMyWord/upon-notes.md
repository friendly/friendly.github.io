Title: "Upon My Word": How a Preposition Cracked the Federalist Papers


The setup: 12 of the 85 Federalist essays had disputed authorship - Hamilton or Madison? Frederick Mosteller and David Wallace spent years in the early 1960s hunting for words that varied by author but not by topic - function words like articles, prepositions, and conjunctions, since content words ("war," "senate") just track subject matter, not style.

"Upon" turned out to be one of the best markers they found. Madison almost never used the word "upon," and neither did the author of the disputed papers - while Hamilton used it constantly. It's exactly the kind of word nobody would think to police in their own writing, which is what made it so diagnostic: an unconscious tic, not a stylistic choice.

They built a training set - 99 papers of known authorship, 50 Madison and 49 Hamilton - measured word rates, then used Bayesian methods to turn those rates into odds for each disputed paper. The result: Madison, with odds as high as 12.6 million-to-1 on some papers.

Title logic: double meaning - literally about the word "upon," and "upon my word" is an old oath of sincerity - fitting for a story about catching authors in their unguarded habits.

Source: Ch. 12, The Theory That Would Not Die (McGrayne).

Next steps to consider: work in the Bayesian mechanics of how word rates became odds, or a plot of Hamilton vs. Madison "upon" rates across the corpus.

---

## The other marker words (research notes, 2026-08-26)

Couldn't get inside the book itself yet (see below on availability) — this is
pieced together from secondary sources, so treat the exact numbers as
"probably right, worth checking against the book before publishing."

### Confirmed, with numbers or clear direction

- **"upon"** — Hamilton ~3.24 occurrences per 1,000 words in his known
  writing; Madison ~0.23. This is the one most secondary sources single out
  as the strongest individual discriminator. (Priceonomics; multiple
  secondary sources converge on the same 3.24/0.23 figures, so probably
  drawn from the same original table — worth confirming against the book.)
  
- **"enough"** — Hamilton uses it often, Madison rarely. This is the
  earliest-attested one: Mosteller himself gave this exact example to the
  *Harvard Crimson* in March 1962, while the study was still underway —
  i.e., "enough" and "upon" were apparently among the first markers that
  jumped out, before the full ~30-word Bayesian model existed.
  
- **"while" vs. "whilst"** — Hamilton favored "while," Madison "whilst."
  This one predates Mosteller & Wallace entirely: historian Douglass Adair
  flagged it in his 1944 essay arguing for Madison's authorship of the
  disputed papers, twenty years before the statistical study. Caveat: some
  of the disputed essays use neither word, so it doesn't discriminate
  everywhere.
  
- **"by"** — Madison used it at roughly double Hamilton's rate (direction
  opposite "upon" and "enough" — a Madison-favoring marker, not a
  Hamilton-favoring one).
  
- **"on"** — also skews toward Madison in at least one modern reanalysis
  (see below), though I haven't found a clean number from the original book
  for this one.

### Tried and rejected as discriminators

- **"from"** — usage rate too similar between the two authors to be useful;
  explicitly excluded.
- Ordinary content words in general — "war," "army," "executive" — Mosteller
  told the *Crimson* these track topic, not author, and are useless for this
  purpose. This is the whole rationale for using function words (articles,
  prepositions, conjunctions) instead.

### The larger candidate list

Secondary sources agree M&W started from a large pool of "non-contextual"
function words (one source says 176 initially considered, another describes
"70 preselected function words," and the commonly cited number for the
words that actually went into the final discriminant/Bayesian model is
**~30**) and narrowed it by checking usage-rate stability against each
author's *non-disputed* writing (other Federalist essays, letters, other
documents of known authorship). I was not able to pull a clean, citable
list of exactly which ~30 survived to the final model — the closest I found
was an AI-search-engine synthesis that produced a long word-dump (a, as,
do, has, is, ... upon ... whilst ... etc.) that looked plausible but wasn't
tied to a specific page/table, so I'm not trusting it without checking the
book directly.

### Modern replication

A 2025 arXiv paper ("From Small to Large Language Models: Revisiting the
Federalist Papers," arxiv.org/abs/2503.01869) reran the problem with LASSO
logistic regression trained on the known-authorship papers, and reports
"whilst" as the single highest-coefficient word (|coefficient| = 0.57), with
"upon" also consistently recovered across their different input encodings.
Nice modern confirmation that these two specific words still carry the
signal six decades and different statistical machinery later — could be a
good "and it still holds up" beat for the post.

### On getting the book itself

No freely-downloadable PDF of *Inference and Disputed Authorship: The
Federalist* (1964) — only borrow-only scans on archive.org:
- https://archive.org/details/inferencedispute00most
- https://archive.org/details/inferencedispute0000fred

Also borrow-only: the 1984 follow-up, *Applied Bayesian and Classical
Inference: The Case of the Federalist Papers*
(https://archive.org/details/appliedbayesianc0000most), which has an
updated/expanded version of the same word-rate tables. Worth borrowing
either one (free 14-day loan, archive.org account) to get the actual table
of final marker words and their exact rates before writing the "here are
the other words" section of the post.

### Sources checked

- Priceonomics, "How Statistics Solved a 175-Year-Old Mystery About
  Alexander Hamilton" — https://priceonomics.com/how-statistics-solved-a-175-year-old-mystery-about/
- *Harvard Crimson*, "Mosteller Joins Federalist Query," March 30, 1962 —
  https://www.thecrimson.com/article/1962/3/30/mosteller-joins-federalist-query-ptwelve-of/
- Case study chapter, *Probability and Bayesian Modeling* (Albert) —
  https://bayesball.github.io/BOOK/case-studies.html
- arXiv 2503.01869, "From Small to Large Language Models: Revisiting the
  Federalist Papers" — https://arxiv.org/html/2503.01869
- Wikipedia, Douglass Adair (for the 1944 "while/whilst" priority claim)

