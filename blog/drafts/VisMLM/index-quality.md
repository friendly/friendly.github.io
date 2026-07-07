Subject Index Quality: Problem & Proposals


THE PROBLEM


A back-of-book subject index lacks an established, validated quantitative quality metric. Formal standards (ISO 999, ANSI/NISO Z39.4, Chicago 18) define what should be present — main entries, subentries, cross-references, accurate locators — but these are checklists, not scores. A commercial "Indexing Standards Benchmark" exists as the first attempt at auditable compliance scoring, but it's vendor-driven, not an academic instrument.


For the Vis-MLM-book index specifically, two open questions matter:

1. Coverage/quality — is the index complete, well-discriminated, and useful for navigation?

2. Term frequency distribution — do mentions of index terms follow an expected statistical pattern?


PROPOSED QUALITY PROXIES (since no single metric exists)


- Coverage: fraction of substantive concepts in the text that get an index entry (check by sampling chapters against key terms — Hotelling's T², collinearity, ridge regression, etc.)

- Specificity: ratio of subentries to main entries; too few subentries on a heavily-used term signals poor discrimination

- Cross-reference density: see-also links per 100 entries

- Locator precision: tight page ranges vs. sprawling ones (a term whose only locator is "45-95" is nearly useless)


PROPOSED DIAGNOSTIC: RANK-FREQUENCY (ZIPF) ANALYSIS


Index term frequencies in a well-formed index typically follow a Zipfian/power-law distribution — a few core terms accumulate many locators, with a long tail of once- or twice-mentioned terms. This mirrors Zipf's law in natural language generally.


Diagnostic use: plot rank vs. frequency on log-log axes.

- Roughly linear -> natural, healthy structure

- Flat distribution (everything mentioned 1-2 times) -> under-specification, missing subentries

- Too few high-frequency anchor terms -> core concepts aren't being consistently tagged throughout the book


An R script (tidyverse-based) was started to take a CSV of term/locator-count pairs and produce this rank-frequency plot for empirical checking once your index is drafted.


