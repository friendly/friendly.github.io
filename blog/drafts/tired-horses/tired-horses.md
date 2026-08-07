# All the Tired Horses: How am I supposed to get any writing done?
Subtitle: The Curses and Blessings of Writing While Developing and Researching

Image: find what I posted on X -- it was an AI generated image of someone writing at a desk, with a bunch of wild horses running through it

Lyrics from Bob Dylan, 1970, as the pun in the title:

All the tired horses in the sun
How am I supposed to get any riding done?
Mm-mm, mm-mm

Quotes that might be relevant somewhere
  Mao: theory into practice
  Tukey: practical power = stats power x probability anyone will/can use it

Diagram:
  writing --> graphic idea -> implement in software --> explain how it's useful --> illustrate with example

TODO: the diagram should show a loops from illustrate back to implement, and from any of these back to writing.
because this is where the friction arises. 
What you can do with the software doesn't match what you wanted to show.

## Introduction

What this post is about ...

## Where I'm starting from
  
If you are someone like me who thinks about graphical methods for data analysis,
and also wants to see how these methods work ... implementing  ... explaining
part of the diagram above, it is useful to describe what this means for practice:
How to think about and balance the wild horses in your background.

### Vis-MLM
This was the task for my [VIS-MLM book]() on ...
In the process, I often had to take a break from the actual writing
to work up examples I could use in the text. Mostly this worked with existing packages, but
sometimes, there was another detour: Either one of my packages or someone else's showed a limitation, or
worse (BUG!). Then, I had to take a second break: 

* track down my or their code; 
* discover where it was wrong or could be made more general;
* fix it myself (then re-build the package, ...) vs. file an issue or PR for the package author (and wait for follow-up)

In one case, for biplots, used to display 2D views of nD data in a single view that shows the observations and variables
together, I had to fork the existing `ggbiplot` package, work on extending it to show the kinds of plots I wanted to display,
and then negotiate with the original author to merge my enhancements and take over the role of package maintainer.

### Writing history of data visualization

TODO: fill in refs to my papers below

When I write historical papers, such as: Guerry, Langren, Minard, ...
there's a different set of task requirements: I have a general theme/structure for the paper. But then it gets down to
the "devil is in the details" again.

* Find the best reference images available
  + Make sure of sufficient resolution (online vs. print)
  + Make careful note of the actual image source, for attrbution, but also for licensing / permission
    (Note: This is tied to how the images you find are currated. For example davidrumsey.com images are accompanied
    by files describing the exact source, reference and other attributes.)
  
* Track down citations to be used. Often difficult in history. 
  + Make sure to generate the BibTeX reference in a particular `.bib` database (Jabref, Zotero, ..)


## Examples

Should describe some concrete examples of the competing cognitive tasks. This aspect should be brought out in
the Intro.

### Packages

* **heplots** -- not sure what I meant here, but perhaps a story of `noteworthy` or some other aspect used in the book
  - there were also datasets, like: peng, ... (there were others, worth mentioning)

* **ggbiplot** -- mentioned earlier. Maybe that's enough, but could also describe the enhancements made here

### Working with references

- describe the tension between writing & citing: see/find something you want to cite.
  + open your Bib manager (Jabref, Zoterro, ...) to see if it is there somewhere
    + if not, go back to Search and find it -> import
  + copy the BibTeX entry and merge (paste?) into your working `references.bib` for the project.
    (Note: in a LaTeX workflow, this can often be done by giving several system-wide BibTeX databases to search,
    With Zoterro, perhaps this is unnecessary.)

- Why BibTeX? 
- Jabref vs Zotero
- R packages
- Use your style

## How Could AI Help?

### Tasks AI is good at:
  + searching: For images, code, ...
  
### Working with Claude on this post 
describe the process in writing from these rough notes, to a polished post.
  
## Exploding Brain Syndrome

When I'm writing and trying to juggle all the current tasks and their windows on my machine, there is something high-dimensional
about this ...

Diagram:
  Thought --> Find the window --> Edit
  (NB: Do you commit & push here?)

But also, you look at a reference paper or something else anew
  + idea for a blog post
  + a new R package to try; but see if it fits the workflow or thinking
  + ...

## Pushes & Pull
(should be earlier)

With software development, there's another dimension: The different machines you work on, the collaborators in the project,
and how you can all work together without serious clashes (`git blame`). There are several moving parts:

* Syncing your work across machines: should be frictionless, so you always have the most recent version, on your laptop, home desktop
  or office machine. Mention cloud alternatives: Dropbox / iClolud / OneDrive / GoogleDrive
  
* Using version control: SVN (old-school) and git. 
  + How it works
  + How it affects how you think and work
    - who does what?
    - how to comment on work? 
    - branches (or does everyone work on `main`?), issues (on GH?), ...



