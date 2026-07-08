# Lightweight analytics via GoatCounter


Add to your top-level _quarto.yml:

```
format:
html:
include-in-header:
text: |
<script data-goatcounter="https://YOURCODE.goatcounter.com/count"
async src="//gc.zgo.at/count.js"></script>
```
## Setup steps:

  1. Sign up free at goatcounter.com, pick a site code (this becomes YOURCODE above).
  2. Replace YOURCODE in the snippet with your actual GoatCounter code.
  3. Add the block above to _quarto.yml (or per-series _metadata.yml if you only want tracking on one series).
  4. Render and push — no cookie banner needed, it's cookieless/privacy-friendly by default.

Dashboard then shows per-page views, referrers, and browser/OS breakdown — nothing heavier than that.

This can sit in the same _quarto.yml alongside the citation metadata setup from the earlier email — they don't conflict, just two separate top-level keys (format vs citation).

