# Banner Image — Working Folder

A 4-zone horizontal strip (1400 × 300 px target) moving left → right:

| Zone | Content | Source |
|---|---|---|
| 1. Far left | Original historical figure (scan) | Wikimedia / HistData vignettes |
| 2. Left-center | R/HistData reproduction of same data | `HistData` + `ggplot2` |
| 3. Right-center | HistData used in modern analysis | `HistData` + regression/ellipse |
| 4. Far right | heplots HE-plot ellipsoids | `heplots` |

See `../banner.md` for full brainstorming notes and tool recommendations.

## Candidate figures

### Left side (historical)
- [ ] Minard's Napoleon march — `HistData::Minard.troops` + original scan
- [ ] Nightingale coxcomb — `HistData::Nightingale`
- [ ] Playfair wheat & wages — `HistData::Wheat`

### Right side (modern)
- [ ] HE plot — `heplots::heplot()`, e.g. iris or Rohwer data
- [ ] genridge traces — `genridge`
- [ ] Mosaic plot — `vcdExtra`

## Files to collect here

- `scans/`   — original historical image scans (PNG/JPG)
- `plots/`   — R-generated panel images (export at 2× resolution)
- `*.R`      — R scripts to reproduce each panel

## Composition script (to write)

`compose-banner.R` — reads panel images, blends with `magick`, crops to final size
