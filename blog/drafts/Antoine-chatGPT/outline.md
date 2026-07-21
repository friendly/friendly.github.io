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
- Enlightenment context: the *Encyclopédistes* were demystifying everything;
  Migneret demystifies oracles by *reproducing* them algorithmically
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
