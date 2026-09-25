# Notation as a Tool for Thought

* Resurrects Ken Iverson's 1979 Turing Award Address, of the same title

In 1979, Kenneth Iverson received the Turing Award from the Association for Computing Machinery for
his invention of the array-oriented computing language APL ("A Programming Language").
His acceptance address, on Oct. 29, 1979 had the same title as this post,
"Notation as a Tool for Thought", and focused on the ideas for efficicient expression of computing in APL
that 

https://www.eecg.utoronto.ca/~jzhu/csc326/readings/iverson.pdf

* Quotes:
By relieving the brain of all unnecessary work, a good notation sets it free to
concentrate on more advanced problems, and in effect increases the mental power
of the race.
---A. N. Whitehead

## Brief history

* Idea of numbers and symbols for them
  + Counting: fingers/toes, up to 20.
  + Stonehenge: needed to count the days of the year
  + Use images from HistDate book, `numbers/`

* Arithmetic: symbols for +, -, *, /; \pi, e
* Matrices: single symbol for a vector or table
* Algebraic geometry: idea of v1 \perp v2 ...
* Musical notation

## Statistical models

* Wilkinson, Rogers -> GLIM -> R lm(y ~ x1 + x2 + A*B, data=, subset=, na.action=)
  Allowed easy translation of math notation directly into a computation

## Data processing: titdyverse

* plyr: split, ..., combine
* dplyr: verbs

## Graphics notation

* Base R: plot(), points(), lines(), ...
  + Re-imagined in tinyplot
* GoG -> ggplot -> ggplot2
  + Re-imagined in tidyplot

## SEMs

TODO: diagram here, showing ellipses for "SEM diagram", "Equations", "Code", with arrows.
  Code --> "R (sem, lavaan)" --> Output
  Add loops back to the diagram and Equations
  
* Equivalents between SEM diagrams & equations (Bollen, \S 2.3.3)
* sem, lavaan -> different ways of translating into code
* How does this help you think about a data problem?
  - what's connected to what?
  - what's observed & what's latent?
  - where is measurement error?
* What's missing?
  - A unified Grammar of Structural Models
  - Where is the "data analysis" in this -- data reduced to means, covariance matrix

## DAGs

* Help identify the legitimate paths to causal claims from observational data
  - Colliders, back-door paths, instrumental variables, ...

* Tools for this


---

# Working structure (added 2026-09-25)

## Decisions so far

* Venue: blog post first; may grow into an article later.
* Not a post *about* SEM. SEM is the **case study** where the general ideas
  from the earlier sections get applied.
* Live R examples: yes, but only after the structure is settled.
* Use **conceptual diagrams** to show how representations relate (like the
  hand sketches), and use a consistent visual style for all of them.
* The loop back from Output to Diagram/Equations = **model revision**: you
  look at the output and go back and change the model.

## Thesis (draft)

A model or idea lives in several representations at once (diagram, symbols,
code, picture). Much of the thinking happens in the *translation* between
them. A good notation makes these translations easy, suggestive, and
reversible, and a missing or weak notation shows up as a translation you
can't make, or one you can make in only one direction.

## Outline (draft, order not fixed)

1. **Hook**: reading Bollen, *Elements of SEM* (new ed.), §2.3.3: SEM diagrams and equations are
   equivalent, and you can move back and forth between them. Why does this
   matter? What can we learn from this more generally about how to think about
   complex statistical models. MF: I reach back to what I learned from the programming language
   APL, where matrix inversion was a single symbol, "quad-divide" and what I've learned since ....
   
2. **Iverson and "Notation as a Tool for Thought"**: the Whitehead quote, plus
   Iverson's properties of good notation:
   - ease of expressing constructs
   - suggestivity
   - subordination of detail
   - economy
   - amenability to formal proofs

   Possibly use these as a lens for each later example (still undecided).
3. **A short history**: numbers and counting, arithmetic symbols, matrices, calculus,
   musical notation. Keep it brief, but it should be a section, with brief examples.
    (Images from the HistData book, `numbers/`?)
   MF: Should mention how each of these solved some problems of thinking about phenomena,
   and using this productively e.g., Newton's fluxions were largely opaque; Leibnitz notation made the ideas clearer. 
   
4. **General cases**, each with a small representation diagram:
   - Matrix algebra: statistical idea <-> matrix notation <-> geometry
     (link to the Vis-MLM series, MF: and to our paper @Friendly-etal:ellipses:2012 on elliptical insights)
   - Model formulas: math <-> Wilkinson-Rogers `y ~ x1 + A*B` (GLIM -> S -> R)
     MF: The idea of computational equivalence --> results you can work with (summary, tables, plots)
     
   - Data processing: split/apply/combine (plyr) -> nouns & verbs (dplyr)
   - Graphics: base R commands (-> tinyplot) vs. grammar (GoG -> ggplot2;
     tidyplot)
   - Common thread: formulas, data verbs, and graphics each ended up with a
     *grammar* (small parts that combine).
     
5. **Case study: SEM**
   - The representation cycle: Diagram <-> Equations -> Code (sem, lavaan)
     -> R -> Output --(revise)--> Diagram / Equations
   - What the notation helps you think about: what's connected to what?
     what's observed and what's latent? where is measurement error?
   - Apply the earlier ideas: which of Iverson's properties does each
     representation have? Where is the grammar?
   - What's missing:
     + no unified *grammar* of structural models (diagram conventions and
       several code dialects instead)
     + little *data analysis*: data are reduced to means and a covariance
       matrix before modeling begins
   - The revision loop: it is real, and risky (modification indices ->
     capitalizing on chance).
6. **DAGs**: notation that directly tells you which causal claims are
   legitimate (colliders, back-door paths, instrumental variables).
   Tools: dagitty, ggdag. Maybe paired with SEM (a DAG is an SEM with the
   distributional assumptions removed?), or kept as its own short section.
7. **Coda**: what would a grammar of structural models look like? 
  MF: Maybe something fanciful like "The SEM Machine" -- yes, work from a verbal theory
  to an explanatory, structural model. But the machine is powered by an LLM, "Bollen 3.0 <name of some star>"
    - It doesn't do your thinking for you.
    - Rather, it asks questions along the path of making your thinking and model explicit, computational, and ultimately publishable.
    - It can spot equivalent models, whose interpretation is different.
    - It can propose data plots and model plots to shed light on assumptions or other model defects.
    - ...
    
  </name>"

## Conceptual diagram style (proposal)

One visual vocabulary for all the representation diagrams:

* **Nodes** = representations (rounded shapes, like the sketches)
* **Solid arrows** = translation done by software (code -> R -> output)
* **Dashed/hand-drawn arrows** = translation done in your head
  (diagram <-> equations, idea <-> geometry)
* **Loop arrow** from output back to the model = revision
* A **missing arrow** (drawn faded or with "?") = a translation the notation
  doesn't support. This is how "what's missing" becomes visible, e.g.
  Output -> Diagram, or Data -> anything in SEM.

Candidates to draw: SEM cycle, idea/matrix/geometry triangle, and possibly a
summary figure placing all the domains side by side.

## References to track down

* Iverson, K. E. (1980). Notation as a tool for thought. *CACM*, 23(8), 444-465.
* Bollen, K. A. *Elements of Structural Equation Models* (new edition), §2.3.3.
  (Check the full citation.)
* Wilkinson & Rogers (1973), symbolic description of factorial models.
* Wilkinson, *The Grammar of Graphics*; Wickham (2010), layered grammar.
* Wickham (2011), split-apply-combine.
* Box (1976), "Science and Statistics" (the iterative model-building loop),
  as backing for the revision loop.
  
  MF: Build a .bib file here

## Open questions

* Use Iverson's properties as an explicit scorecard, or just in the background? -- MF: Just in the background, but keep the idea of a scorecard in mind
* How long should the history section be? MF: Can easily be a few paragraphs, because I want to get the more general ideas across
* DAGs: standalone section, or folded into the SEM case study? MF: DAGs in a separate section, 
  because tools for DAGs (`daggity`) allow you to "ask questions" of a diagram
* For live code: one dataset carried through all sections, or the best
  example for each? One dataset would be better, but this will depend on what is written

---

# Round 2 (2026-09-25): decisions from MF notes, diagram prototypes

## Settled (from MF answers above)

* Iverson's properties stay **in the background**; keep a scorecard in mind
  but don't impose it section by section.
* History gets its **own section of a few paragraphs**, each example showing
  how a notation solved a problem of thinking (Newton's fluxions vs.
  Leibniz's dy/dx is the model case).
* **DAGs get their own section**, because dagitty lets you *ask questions* of
  a diagram (adjustment sets, implied independencies). The notation is
  queryable, which is a step beyond SEM diagrams.
* Live code: one dataset if possible, depending on what gets written.
* Personal thread for the hook: APL, where matrix inversion was one symbol
  (quad-divide, ⌹).
* Model formulas: stress **computational equivalence**. The fitted object is
  something you can keep working with (summary, anova, plots, update).
* Coda: "The SEM Machine" (LLM-powered, "Bollen 3.0"). It doesn't think for
  you; it asks questions that make your theory explicit, spots equivalent
  models, and proposes data plots and model plots.

Note: Iverson's actual title is "Notation as a Tool **of** Thought". The post
can still use "for" as its own title, but quote his correctly.

## Local bibliography: `notation.bib`

Copied from the canonical files: Friendly-etal:ellipses:2012,
WilkinsonRogers1973, Wilkinson:05, Wickham:2010:gog, Wickham2011.
Not found in the canonical files, so added as *proposed* entries (verify):
Iverson:1980, Box:1976. Bollen (new edition) is a TODO.

## Diagram prototypes: `diagrams/*.dot` (+ .png previews)

Graphviz sources; these can go straight into Quarto `{dot}` chunks.

| File | Shows |
|---|---|
| `sem-cycle.dot` | diagram <-> equations -> code -> R -> output, data reduced to S, revise loops, missing links |
| `idea-matrix-geometry.dot` | idea <-> matrix <-> geometry triangle; matrix -> R -> plot -> geometry |
| `model-formula.dot` | model <-> formula -> fitted object -> summary/plots; revise via update() |

Visual vocabulary as implemented:

* cream rounded box = representation you think in
* blue box = what the computer handles (square corners = output)
* green cylinder = data
* solid = software; dashed = in your head; red = revise; grey dotted "?" = missing

Still to decide: the dataviz-style look (Graphviz) vs. a hand-drawn look closer to
the sketches; whether to put semPlot's output -> diagram arrow back into the
SEM diagram (dropped for clarity); and whether to add candidates for data verbs,
graphics, and DAGs.

To re-render the PNGs: `diagrams/render-dots.R`, run from `diagrams/` (DiagrammeR ->
DiagrammeRsvg -> rsvg). Note: DiagrammeR chokes on apostrophes in labels.

## Pick up here next session

Open questions from the diagram round:

1. **Look**: keep the clean Graphviz style, or aim for a hand-drawn look closer
   to the original sketches?
2. **SEM revise loop**: arrows back to both diagram *and* equations (as now; the
   diagram arrow crosses "transcribe"), or just one?
3. **Next diagrams**: data verbs, graphics (base/tinyplot vs. grammar), and a
   DAG, where the new element is an arrow that *queries* the diagram
   (dagitty -> adjustment sets).
