# ChatGPT, 1759 Edition

<!-- Alternative titles:
  - The First LLM? A 1759 Oracle Machine
  - The Oracle Machine: A 1759 Pamphlet That Anticipated AI
  - Verse by Algorithm: Migneret's 1759 Vision of ChatGPT
  - The First LLM? Antoine's Parting Gift
-->

**Working title:** ChatGPT, 1759 Edition  
**Author:** Michael Friendly  
**Series:** History of Statistics / Data Visualization  
**Tone:** Intellectually playful, personally warm — a tribute to a fertile mind

---

## Analysis notes (background — not a post section)

### The Algorithm

1. **Input normalization**: Question reworded to exactly 9 words
   - *"Celui que j'aime deviendra-t-il cette année mon époux?"*

2. **Encoding**: Each letter mapped via the *Table Alphabéti-Numérique* (A=1, B=2 … Z=23).
   Letters within each word are summed → 9 word-sums.

3. **Mod-9 compression**: Each sum divided by 9; remainder kept (remainder 0 → use 9).
   Produces a 9-digit key: `3 5 9 7 2 6 1 3 3`

4. **Triangle transformation**: Repeated adjacent-pair mod-9 operations build a downward
   triangle of 9 rows (9, 8, 7 … 1 digits):
   ```
   3 5 9 7 2 6 1 3 3
   . 8 5 7 9 8 7 4 6
   . . 4 3 7 8 6 2 1
   . . . 7 1 6 5 8 3
   . . . . 8 7 2 4 2
   . . . . . 6 9 6 6
   . . . . . . 6 6 3
   . . . . . . . 3 9
   . . . . . . . . 3
   ```

5. **Column extraction**: 9 vertical columns read from the triangle → 9 index values.

6. **Verse lookup**: Column values index into pre-composed Latin hexameter fragments
   in the book's tables → output oracle response.

### Notes from the Avertissement and Introduction (pp. 7–19)

**Avertissement (pp. vij–viij)**
- Migneret originally planned a large folio volume; the printer refused, saying
  "even if your book were a foolish trifle (*une sottise*) of the moment, I'd be sure
  to sell it" in a small format. A fire then destroyed the larger plan.
- Key word: *sottise*. Migneret adopts it without irony — he's advertising his own work
  as a learned trifle. The satirical frame is declared from the very first page.
- Boast buried in the same section (p.8): "even the most skilled mathematicians of his
  day would perhaps have declared it *impossible* to produce Latin verses by arithmetic."
  This is not false modesty — he's proud of pulling off the impossible.

**Sur les Oracles / Moyenne Proportionnelle (pp. 1–9)**
- Core thesis (stated explicitly, approx. p.7):
  > *"Les prêtres des payens ne forgeoient pas non plus les oracles. Ils ne faisoient que
  > les tirer d'une table numérique, & la combinaison résultante de diverses opérations
  > arithmétiques, faisoit avoir une réponse vaguement relative au sujet de la question."*
  ("The pagan priests did not forge the oracles. They merely drew them from a numerical
  table, and the combination resulting from various arithmetical operations produced a
  response vaguely related to the subject of the question.")
- Oracle responses were *"réponses vagues, accommodées à l'alternative de l'événement"* —
  vague answers calibrated to fit either outcome. The 1759 version of "hallucination."
- Elaborate fictional frame: ancient bronze tablets found in a cave near Rome, two-layer
  plates with numbers on top and unknown characters below, translated by scholars, declared
  "the most valuable antiquities ever found." Obvious fiction — mocks the discovery rhetoric
  of serious antiquarians.
- Secondary, educational purpose (p.9): the machine "offers the further advantage of
  inspiring, through curiosity and the pleasure of amusement, the desire to learn arithmetic
  or to advance one's skill in those who already know it, because to work a Latin verse on
  this little loom, one must of necessity employ the four basic rules of Arithmetic."
  → The oracle game is also an arithmetic teaching tool.
- Reference to two predecessors on oracles: Wan-Dale and Fontenelle (*Histoire des Oracles*,
  1687). Migneret positions himself as adding the *demonstrative* step they lacked: not just
  arguing oracles were fraud, but *showing the mechanism*.

**Avantages des Mathématiques (pp. 10–19)**
- Pages 10–19 are a full Enlightenment manifesto: mathematics as the foundation of all
  knowledge — every art, every science, every correct judgment.
- Key argument (p.11): mathematics is the *most error-free* science, therefore the most true
  and the easiest. The prejudice that it's hard comes from a false opinion about universality
  implying difficulty.
- Mathematics as the basis of aesthetics (pp.12–14): the fine arts succeed only insofar as
  they imitate nature's proportions. Judgment = comparison = ratio. Even poetic similes
  ("*autant, aussi, égal, de même*") are expressions of mathematical equality.
- Syllogism reduced to equation (p.15): "All men are animals; Pierre is a man; therefore
  Pierre is an animal" → Homme=Animal, Pierre=homme → Pierre = animal. Logic is arithmetic.
- Named heroes who demonstrate mathematics as the key to everything:
  - **Fontenelle** (p.16, footnote a): the "illustrious savant" who earned the reputation
    of a universal man through his mathematical knowledge
  - **Voltaire** (p.16, footnote b): "philosophical works and translations of Newton assure
    him the reputation of a geometer, illustrious poet, learned man of letters and profound
    geometer — any one of these would suffice to make him illustrious, and he combines all three"
  - **Diderot & d'Alembert** (p.18, footnote a): the two supreme mathematical geniuses
    responsible for the Encyclopédie (p.17 footnote: "*L'Encyclopédie*" is the "admirable
    execution" that belonged to "the two foremost mathematical geniuses we have")
  - **Rameau** (p.18, footnote b): the "musician-geometer" who reformed music by reducing
    it to mathematical principles
  - **Gassendi, Descartes, the Bernoullis, Newton, Galileo** (p.18): the physicists who
    assigned mathematics its principles, banishing "thick darkness" and occult causes
- Closing statement (p.19): mathematics "has brought philosophy out of the darkness where
  it was buried, unveiled nature to our eyes, shows us its mechanism, enlightens us in all
  sciences, gives us the rules and certain principles for operating in all the arts."

**What this means for the post:**
- Migneret is not a crank with a party trick. He's a committed Encyclopédiste writing a
  demonstration piece — proof by construction — that the oracle tradition is no different
  from arithmetic. The machine *is* the argument.
- The educational framing (arithmetic via amusement) gives him cover; the philosophical
  framing (mathematics defeats superstition) gives him ambition. Both are sincere.
- The Diderot/d'Alembert/Encyclopédie reference places him in the innermost circle of
  Enlightenment thought. The *Encyclopédie* was still appearing (final volumes 1765) —
  this pamphlet (1759) was written *during* that project.
- Voltaire is described in identical terms to the Encyclopédistes — philosopher, poet,
  mathematician. Migneret sees no split between literary and mathematical genius.
- The logic-as-equation passage (pp.14-15) is important: Migneret explicitly argues that
  *all reasoning* reduces to arithmetic. His oracle machine is therefore not a toy — it's
  a demonstration of a general claim about the nature of thought.
- Quotable for section 2: the printer's *sottise* line; the "impossible" boast; the
  explicit oracle-as-lookup-table thesis; the educational purpose.
- Quotable for section 5: the closing sentence of p.19 (mathematics vs. darkness) maps
  perfectly onto the AI debate — swap "mathematics" for "LLMs" and half the tech press
  would sign it.

---

### The LLM Parallel

| Migneret (1759)               | Modern LLM                        |
|-------------------------------|-----------------------------------|
| Reword question to 9 words    | Tokenization / prompt formatting  |
| Letter → number table         | Token embeddings                  |
| Word sums                     | Weighted feature aggregation      |
| Triangle mod-9 operations     | Layer-by-layer transformation     |
| Column index lookup           | Sampling from output distribution |
| Pre-compiled verse table      | Learned weight matrix             |

Both systems take natural language in, run a mechanical transformation, and produce
fluent-seeming language out. Neither "understands" the question. The responses are
calibrated to be vague enough to fit almost anything — exactly what modern critics
say about LLM outputs.

The satirical point is Migneret's main argument: he exposes ancient oracles as fraud —
not divine inspiration but a combinatorial trick. Antoine's insight is that the same
critique applies to ChatGPT. Migneret wasn't *building* a proto-LLM approvingly;
he was *debunking* the oracle tradition by showing how mechanically it could be
replicated.

What's genuinely remarkable: in 1759 Migneret anticipated — as a joke — the core
architecture of tokenization, numerical embedding, multi-layer transformation, and
lookup-based generation. The joke took 265 years to become a $100B industry.

The real difference: scale and generality. Migneret's table is finite and hand-crafted;
an LLM's "table" has been learned from essentially all of human writing. Impressive —
but the same category of trick.

---

## 1. Opening: A letter from a friend

- Antoine de Falguerolles sends an email in the context of exchanges about ChatGPT
- His characteristic framing: "a non-serious contribution" — but of course it is serious
- Brief sketch of Antoine: statistician, historian of ideas, the kind of person who reads
  1759 pamphlets for fun and emails you about them
- The discovery arrived as a gift; gifts from departed friends deserve to be shared
- Keep short, warm — not elegiac; let the intellectual delight carry the tribute

## 2. Migneret and his pamphlet

- Pierre-Jean Migneret: mathematics teacher, accountant, one-time pamphleteer
- Full title: *Invention d'une Manufacture et Fabrique de Vers, au Petit Métier, ou
  l'Art de Versifier par les Seules Règles du Calcul Numérique* (Amsterdam, 1759)
- The fake Amsterdam imprint (Arkstée & Merkus existed but didn't publish this)
- Satirical premise: "anyone can now be the Pythia and sit on the sacred tripod
  to deliver oracles" — the oracle tradition exposed as a mechanical trick
- Enlightenment context: Migneret is a committed Encyclopédiste — Diderot, d'Alembert,
  Voltaire, Fontenelle all named approvingly in pp.10–19. He demystifies oracles by
  *reproducing* them algorithmically — proof by construction, not just assertion.
- Secondary intent: an arithmetic teaching tool ("four basic rules of arithmetic" are
  all one needs to operate the machine — inspires learners through amusement)
- The boast: best mathematicians of his day would have declared it *impossible* to make
  Latin verses by arithmetic. He's proud of the trick.
- Include image of title page (Mignaret-cover.jpg)

## 3. The algorithm: walking through an example

- The *Instruction sur la manière de travailler* (pp. 20–34 of the pamphlet)
- Step 1 — **Input normalization**: question reduced to exactly 9 words
  - Example: *"Celui que j'aime deviendra-t-il cette année mon époux?"*
- Step 2 — **Letter encoding**: Table Alphabéti-Numérique (A=1 … Z=23)
  - Include table as a figure
- Step 3 — **Word sums**: letters within each word summed → 9 values
  - e.g., *Celui* → C(3)+e(5)+l(11)+u(20)+i(9) = 48
- Step 4 — **Mod-9 compression**: each sum divided by 9, remainder kept (0 → 9)
  - 9-digit key: `3 5 9 7 2 6 1 3 3`
- Step 5 — **Triangle transformation**: repeated adjacent-pair mod-9 operations
  building a downward triangle (9 rows: 9, 8, 7 … 1 digits)
  - Show the triangle as printed in the pamphlet
- Step 6 — **Column extraction**: 9 vertical column values read from the triangle
- Step 7 — **Verse lookup**: column values index into pre-composed Latin
  hexameter fragments → output oracle response
- Antoine's example Q&A pairs (from antoine-chatgpt.txt):
  - Q: *Celui que j'aime deviendra-t-il mon époux?*
    A: *Ecce equidem licitae praedicit talia numen.*
  - Q: *La paix sera-t-elle prochaine et avantageuse aux Français?*
    A: *Credo satis licitae, donabit foedera numen...*

## 4. The LLM parallel

- Side-by-side comparison table:

  | Migneret (1759)               | Modern LLM                        |
  |-------------------------------|-----------------------------------|
  | Reword question to 9 words    | Tokenization / prompt formatting  |
  | Letter → number table         | Token embeddings                  |
  | Word sums                     | Weighted feature aggregation      |
  | Triangle mod-9 operations     | Layer-by-layer transformation     |
  | Column index lookup           | Sampling from output distribution |
  | Pre-compiled verse table      | Learned weight matrix             |

- Key insight: both produce the *appearance* of meaning through mechanical
  transformation — neither understands the question
- The "knowledge" in Migneret lives in the pre-compiled verse table;
  in an LLM it lives in billions of learned weights — same architecture,
  nine orders of magnitude larger

## 5. The critique, then and now

- Migneret's joke: oracles weren't divine — they were an algorithm
- The same argument, unmodified, applies to ChatGPT
- The reverse reading: if Migneret's machine seems clever for 1759, maybe
  the LLM deserves more credit than its debunkers allow
- The real difference: scale and generality — Migneret's table is finite and
  hand-crafted; an LLM's "table" has been learned from essentially all of
  human writing. Impressive, but the same category of trick.

## 6. Coda: Antoine

- What it means to receive this kind of discovery as a gift
- The mind that keeps finding these things — in 1759 pamphlets, in statistics,
  in the history of ideas — and shares them with characteristic lightness
- "A non-serious contribution" that turns out to illuminate something large


## Notes from reading

? Here's what those pages add:

  Pages 8–9 (end of "Sur les Oracles") give two things worth quoting directly: Migneret's boast that even the best
  mathematicians of his era would have declared it impossible to make Latin verses by arithmetic — and his explicit
  educational purpose: the machine teaches the four basic rules of arithmetic through amusement. That secondary motive
  (fun ? math skills) is completely separate from the satirical argument and worth a sentence in section 2.

  Pages 10–19 ("Avantages des Mathématiques") are the real surprise. This isn't just an introduction — it's a full
  Encyclopédiste manifesto arguing that mathematics is the foundation of every art, science, and correct judgment. Logic
  is arithmetic (he reduces the syllogism to an equation on p.15). Beauty is ratio. Even poetic similes are expressions
  of mathematical equality. Migneret names his heroes in footnotes: Fontenelle, Voltaire, Diderot & d'Alembert (the
  Encyclopédie itself is called "l'exécution admirable"), Rameau, Newton, Galileo.

  The implication for the post: Migneret is not an eccentric with a party trick. He's a committed Encyclopédiste writing
  a proof by construction — if oracles were just a lookup table, and all reasoning reduces to arithmetic, then the
  appearance of divine knowledge is nothing but arithmetic. The oracle machine is the demonstration of a general claim
  about the nature of thought. That makes the parallel to LLMs much sharper: same philosophical claim, 265 years apart,
  vastly different scale.

  The closing line of p.19 is quotable for section 5 — swap "mathematics" for "LLMs" and it reads like a 2024 tech press
  release.

---

### Notes from the Application section (pp. 49–55)

These pages contain the fully worked example and reveal the complete architecture of the lookup tables.

**The two-table lookup (pp. 49–52)**

Steps 5–6 are more intricate than a simple "column lookup." There are in fact two tables:

1. **Tabula Prima Numerica** (fold-out, upper half): a 9×7 grid (rows I–IX, columns A–G). Each cell contains
   a small range of numbers (e.g., row 1, column B = 11, 14, 17). Given an index from the triangle, you locate
   which column (A–G) it falls in for its row — this gives you a *bande* (section) label and position.

2. **Tabula Secunda Litteralis** (fold-out, lower half): same 9×7 structure, but cells contain letters
   (and some digrams: *qu*, *ra*, *te*, *di*, *ci*) plus "+" placeholders. Given the bande and row from the
   numerical table, you read the corresponding letter or letter-pair.

The "+" symbol means: skip this cell, move to the next. It allows variable-length words to fit within a
fixed table structure — short words leave some cells unused.

**The verse is assembled letter by letter, not phrase by phrase**

The triangle produces six "lignes" (I–VI), each corresponding to one word of the Latin hexameter. Each ligne
uses one bande and looks up 6 candidate cells, taking letters and skipping +'s:

- Ligne I (bande 3): 18→*e*, 27→+, 33→*c*, 42→*c*, 57→+, 60→*e* → **ecce**
- Ligne II (bande 9): 27→*e*, 33→*qu*, 42→*i*, 48→*d*, 57→*e*, 66→*m* → **equidem**
- Ligne III (bande 3): 15→*l*, 30→*i*, 39→*c*, 42→+, 54→*i*, 63→*te* → **licitæ**
- Ligne IV (bande 6): 31→*p*, 33→*ra*, 39→*e*, 45→*di*, 57→*ci*, 69→*t* → **prædicit**
- Ligne V (bande 2): 13→*t*, 22→+, 34→*a*, 46→*l*, 55→*i*, 64→*a* → **talia**
- Ligne VI (bande 3): 15→*n*, 24→+, 36→*u*, 42→*m*, 54→*e*, 60→*n* → **numen**

Concatenated: *Ecce equidem licitæ prædicit talia numen.* ✓ Confirmed.

Migneret then confirms on p.52: "Toutes les lettres ayant été écrites de suite dans l'ordre qu'elles auront
été trouvées en les cherchant, formeront le vers, *Ecce equidem licitæ prædicit talia numen,* qui est le
résultat des différentes opérations numériques qui ont été faites, & la réponse à la question: *Celui que
j'aime deviendra-t-il cette année mon époux?*"

**Second question worked (p.53)**

"La paix sera-t-elle prochaine et avantageuse aux François?" Triangle:
```
3 1 6 5 4 6 2 6 9
 4 7 2 9 1 8 8 6
  2 9 2 1 9 7 5
   2 3 1 7 3
    4 5 4 8 1
     9 9 3 9
      9 3 3
       3 6
        9
```
Output verse (confirmed p.55): *Credo satis licité, donabit fœdera numen.* The pamphlet ends here: "FIN."

**What this changes for the post**

The "pre-compiled verse table" described in Section 4's LLM parallel table is more precisely described as
a **sub-word letter table**. Migneret's stored units are not whole verse phrases but individual letters
and digrams (qu, ra, te, di, ci). This is strikingly close to modern **byte-pair encoding (BPE)** —
the tokenization method used by GPT-2 onwards — which also stores a vocabulary of subword units (single
characters up to common letter-pairs and longer fragments) and assembles outputs by concatenating them.

The + placeholder (skip cell) is effectively a null token or padding token — the same concept modern
tokenizers use to handle variable-length sequences within fixed-size batches.

So the "vocabulary" parallel is tighter than previously described:
| Migneret | Modern LLM |
|----------|-----------|
| Letter table cells (single letters + digrams: qu, ra, te, di, ci) | BPE vocabulary (single chars + common subwords) |
| "+" placeholder = skip | Padding token |
| 6 lignes × 6 lookups = 36 positions → one hexameter | Context window of token positions → one output |

**Editorial implications**
- Step 6 description in the post should say "letter by letter" not "verse fragment by verse fragment"
- Section 4's table row "Pre-compiled verse table → Learned weight matrix" could be sharpened:
  "Sub-word letter table (letters + digrams) → BPE token vocabulary"
- The + placeholder as padding token is a nice additional touch, but may be too technical for the post
- The fold-out image (Tabula Prima/Secunda, page 54) would make an excellent figure — it is the
  complete Oracle Machine on one page

---

## Assets

- `Mignaret-cover.jpg` — title page image
- `Mignaret1759.pdf` — full pamphlet (French); INSTRUCTION section pp. 20–34
- `antoine-chatgpt.txt` — Antoine's notes and example Q&A pairs
- `first-chatGPT.md` — stub for this post (to be developed)

## Notes / questions to resolve

- Should we include a reproduction of the triangle computation for the example?
- Is there a translation of the full oracle response to include?
- Any other Migneret biographical details available?
- Should the verse lookup tables from the pamphlet be shown?
  (They would need more pages of the PDF)
