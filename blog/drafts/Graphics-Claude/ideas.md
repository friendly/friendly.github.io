# Designing Graphics with Claude — ideas

Seeded 2026-11-28 from a `ggsprings` session (reviving a dormant package and getting it CRAN-ready).
Notes only, not a draft yet.

## The one-line idea

Designing a statistical graphic with an AI isn't "write me a plot". It's a back-and-forth in
which the human owns the *meaning* (what the picture should say, what the parameters mean, what's
good enough) and the AI makes the options *visible*: it renders the alternatives, checks the
numbers and keeps the to-do list. That loop is what I've learned to do, and it's what's
worth writing about.

## The ggsprings session as the running example

Arc of the day, roughly in order. Each step is a candidate vignette for the post:

1. **Survey before touching anything.** I asked for an inventory of a project I'd left in April
   2025: bugs, TODOs, and "there was a grouping/faceting issue I never resolved". Claude
   reproduced the problem in R rather than guessing. The springs were computed in *data units*,
   so the coils were distorted whenever x and y had different scales, and their size changed from
   facet to facet. It wrote all this into `issues/TASKS.md`.
   - TASKS.md became the shared memory for the rest of the day (cf. Detour 4 in *tired-horses*).

2. **"You are using roxygen, right?"** A check-in question, not a correction. It caught leftover
   Rd macros that broke my own rule. Small, but typical: the human audits *conventions*.

3. **Interrupting is steering.** I stopped it mid-command twice: once when it was about to install
   into my library, once when it was about to re-knit the README to fix ugly examples. Each time
   the right response was to ask what I wanted, not to retry. Interruptions carry information.

4. **The design decision was mine, but presented as pictures.** The redesign turned on two
   questions only I could answer:
   - Should spring *diameter* be in data units, a fraction of the panel, or mm on the screen?
   - What should "tension" mean? In the original code it was really a coil-*pitch* fudge factor,
     and every example I'd written hand-tuned `tension = distance / 5` to make it look right.

   Claude laid these out as a multiple-choice question with small code/ASCII previews and a
   recommendation for each, so I chose with the trade-offs in view. The answers were mm and a
   fixed number of `coils`: longer springs then *look* more stretched automatically, which is
   Hooke's law made visual. A `weight` aesthetic for stiffness gives weighted least squares for
   free.
   - **Point for the post:** the important design decision was semantic, not technical. Getting
     the meaning of a parameter right removed a whole category of hand-tuning from every example.

5. **The AI has to *look* at what it draws.** It rendered PNGs and read them back, made contact
   sheets of animation frames, and compared side-by-side variants (coil shapes at three "loop"
   settings). It also caught a bug in its *own* prototype because the three panels looked
   identical: the parameter wasn't being passed through. Code that runs is not a graphic that
   works.

6. **Taste is the human's job.** Long, stretched springs came out as cusped scallops. Claude
   flagged this as an open question rather than "fixing" it unasked. I said "make them look like
   a wave". It then prototyped two fades and kept the one with no cusps in the transition.

7. **Knowing when to stop.** I said "don't get stuck in a perfection rabbit hole", and later
   "leave the spring shape in the README examples to later... even though a few of the examples
   are really ugly". Triage is a design skill. The ugly bits went into a *Later* list in
   TASKS.md, not into another hour of fiddling.

8. **The big one: the animated rod.** "Try a gganimate example of the line settling. If
   relatively easy, do it." Claude wrote a small physics simulation: a rigid rod pulled by
   Hooke's-law springs, with net force and torque, plus damping. It rendered that with gganimate
   and *checked* that the rod came to rest at `lm()`'s solution (slope 0.687 vs 0.685). The
   equilibrium conditions are exactly the normal equations, so the animation *is* the argument
   in the vignette, now made visible. It's the picture I'd wanted for years (cf. the Matlab PCA
   animation and the Gaines & Palfrey machine).

8b. **...and then PCA, in one more step.** "Try the PCA version of the animation." It used the same
   simulation, with one change: the springs are perpendicular to the rod (their feet slide along
   it), and the rod pivots at the centroid. The torque, k·Σ dᵢ pᵢ, vanishes only along the
   eigenvectors of the covariance matrix, so the rod settles on PC1, checked against `prcomp()`
   (25.97° vs 25.80°). It worked first time.
   - **Point for the post:** the pair of animations is itself the argument. The *only* difference
     between regression and PCA is the direction of the springs, vertical vs. perpendicular. That
     is a classic teaching point (errors in y vs. errors in both), and here it is made literally
     visible, side by side.
   - It finally recreates the Matlab PCA-by-springs animation I'd pointed to in the README for
     years, now in R with real springs.
   - A cost of success: the vignette now covers history, Hooke's law, mean, centroid, regression,
     smoothers and PCA. I said it "may be enough or too much for one vignette", which is
     scope creep as a side effect of things becoming easy. Worth a paragraph?

9. **Checking runs both ways.** While rewriting the README, Claude noticed that my
   potential-energy diagram said F(x) = 2X where it should be −X, because P = ½X². It also
   investigated a "label not found" warning and concluded it was a *false alarm* rather than
   "fixing" something that wasn't broken. Diagnosis before repair.

10. **Etiquette and attribution.** "Don't co-author everything — only when you do significant
    design/code work." Who gets credit in a commit is a small version of the AI-disclosure
    question (→ *validating-AI.md*). It saved that preference so it applies in future sessions.

11. **Permissions on outward-facing actions.** Commit, push and turning on GitHub Pages each got
    an explicit OK. It proposed the `gh` command and waited instead of just doing it. That's the
    right default, and worth a sentence.

## Themes to develop

- **Division of labour.** Human: meaning, taste, priorities, "good enough", and the domain
  knowledge (what a spring diagram is *for*). AI: enumerating options, rendering and comparing,
  checking against ground truth (`lm()`, `R CMD check`, tests), bookkeeping. Neither side alone
  would have produced the animated rod in an afternoon.
- **Graphics need a visual feedback loop.** Text-only code generation for graphics fails quietly,
  so the AI has to render and inspect. This may be the most generalizable lesson for statistical
  graphics specifically.
- **Semantics before pixels.** The tension → coils change is a nice compact example of
  "get the encoding right and the aesthetics follow" (cf. Bertin; Wilkinson's grammar; my own
  "graphics should be designed for a purpose").
- **External memory.** TASKS.md, the memory files, and the parked "Later" items let work carry
  across sessions. This links to *tired-horses* Detour 4 (several crews, no coordination).
- **Community, then AI.** The project began as a "help wanted" post in the ggplot2 extenders
  club (discussion #83). Teun van den Brand fixed the docs via PRs (and politely declined to be a
  collaborator — PRs as *consent*). Gina Reynolds contributed the residual-spring functions. What
  did the human community give that the AI didn't, and vice versa? (Ideas, encouragement and a
  sense of what others need, vs. stamina, checking and implementation.) Careful and generous
  here: it isn't a replacement story.
- **Which model?** I asked mid-session whether a different model would be better. The answer was
  roughly: the default was fine for this; a more capable model was worth it only for the hardest
  piece (the screen-space redesign). Possibly a footnote.

## Possible structure

- Hook: the GIF of the rod settling (it's the payoff, so show it first?) or the old Loftus plot
  next to the new one.
- "A dormant package and a bug I never fixed"
- "Asking, not telling": the design questions (tension → coils, mm)
- "Looking at the pictures": the visual feedback loop
- "Knowing when to stop": triage, parking ugly things
- "The rod settles": physics → normal equations → animation, validated against `lm()`
- "Who did what": attribution, checking in both directions
- Coda: what I'd tell another statistician/graphics person starting to work this way

House style: an emoji on each `##` heading (see SKILL.md). The voice should be closer to
*tired-horses* than to the Beach Science pieces.

## Open questions

- How much transcript to show? (→ *validating-AI.md*: the exchange, not the prompt, carries the
  reasoning.) Maybe 3–4 short quoted exchanges: the design multiple-choice, "make it a wave",
  "don't get stuck in a rabbit hole", "don't co-author everything".
- Before/after figures: the distorted residual springs on `mtcars` (data-unit coils) vs. after;
  scallops vs. waves; the gapminder plot then (hand-tuned) vs. now (one function call).
- Is "Designing Graphics with Claude" the title, or is it more general ("Designing with an AI
  collaborator")? Possible subtitle: "Taste is the human's job".
- Other examples from earlier work to fold in: tired-horses (writing while developing), the
  GeneralWoolf/vcdExtra session (validating-AI), the heplots `noteworthy` story?

## Materials

- Repo: <https://github.com/friendly/ggsprings>, site: <https://friendly.github.io/ggsprings/>
- Commits from 2026-11-28: `45ebc4c` (redesign + site), `4f19b93` (waves, README), `b7bd95c`
  (gapminder), `f8cd65c` (regression animation), `63d1240` (PCA animation)
- `ggsprings/issues/TASKS.md`: survey + progress log (a record of the day)
- `ggsprings/man/figures/least-squares-springs.gif`, `pca-springs.gif`; `examples/animate-regression.R`, `animate-pca.R`
- ggplot2 extenders discussion #83:
  <https://github.com/ggplot2-extenders/ggplot-extension-club/discussions/83>
- Related drafts: `drafts/validating-AI.md`, `drafts/tired-horses/` (Detour 4, "How could AI help?")
