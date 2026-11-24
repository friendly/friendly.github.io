# 3D graphs: how to show things that should be seen in 3D

*2026-11-24.* Notes for follow-up. The topic came up while working on *On Extending `lm()` Methods
to `"mlm"`* (published) and *How Big Is My Matrix?* (`blog/drafts/How-big/`). It could become a
section of How-big, a sidebar, or a post of its own. Not decided.

## The problem

Many of the objects in these posts live in 3D or higher: data ellipsoids, HE plots for three
responses, the vector geometry of regression, the space of three coefficients. On a page or a
screen, a 3D plot is always rendered in 2D. So the question is which depth cues to keep, and what
the reader can do with the result: look at it, rotate it, or compare it across views.

## A possible framing: a 3D graph on a page is already a shadow

This ties straight into "ellipses have shadows" in How-big (section 5a of the notes):

- An ellipsoid's shadows on the coordinate planes are 2D ellipses, and their shadows on the axes
  are 1D intervals. That's the ladder of dimensions again, one rung at a time.
- *Any* 3D rendering is a projection, a shadow chosen by the camera. A static 3D plot picks one
  shadow for you; a rotating one shows a sequence of them; an interactive one lets the reader
  choose.
- So the design question becomes **which shadows to show, and how to let the reader find the
  informative one**, rather than "how do I make it look 3D?"

Precept, in the style of the posts: *Every 3D plot on a page is a shadow; choose it, or let
the reader choose.*

## Ways to show depth, from least to most interactive

1. **Static, with depth cues**: perspective, shading and lighting, occlusion, depth-sorted
   transparency, drop lines or shadows on a floor. Works in print and PDF. One fixed view.
2. **Several static views**: small multiples of projections, or a 3D view next to its three
   2D shadows (a "cube with its faces"). Honest about what each view loses.
3. **Animated rotation** (GIF or video): kinetic depth effect, so the eye recovers the shape.
   Works anywhere an image does, but the reader can't stop at the view they want.
4. **Interactive (WebGL)**: drag to rotate and zoom. Best for exploring, but needs a browser,
   doesn't print, and the reader may never find the revealing view.
5. **Beyond 3D**: tours (`tourr`, `detourr`, `langevitour`) animate a sequence of 2D projections of
   *p*-dimensional data. The same shadow idea, without stopping at three.

## Tools

| Tool | What it does well | Limitations / notes |
|---|---|---|
| `rgl` | Real 3D with lighting; `rglwidget()` embeds a WebGL widget in Quarto HTML; used throughout my packages | Separate graphics system, no ggplot2 theming; static images need `snapshot3d()` (via `webshot2` + Chrome when headless); `movie3d()` for GIFs; widgets add page weight and don't work with `freeze`/PDF in the obvious way |
| `car::scatter3d()` | Quick 3D scatterplot with fitted surface(s) and data ellipsoid; also `avPlot3d()`, `crPlot3d()` | Built on `rgl`, so same output issues |
| `heplots::heplot3d()` | HE plots for 3 responses: **H** and **E** ellipsoids | `rgl`; also `candisc::heplot3d()` for canonical space |
| `matlib` | Vector geometry: `vectors3d()`, `arrows3d()`, `regvec3d()` (regression as vectors), `plotEqn3d()` (planes of linear equations), `circle3d()`, `cone3d()` | `rgl`; teaching-oriented |
| `ggcube` (Matthew Kling; CRAN 0.3.0, 2026-09-05) | ggplot2 extension: add `coord_3d()` to a plot with a `z` aesthetic; 3D geoms (points, paths, surfaces, hulls, voxels, ridgelines, text), lighting, depth sorting; `animate_3d()` for rotation; `orbit_3d()` for drag-to-rotate | New. Most standard 2D geoms don't render correctly under `coord_3d()` (`geom_point()` is the exception). Has a **position for projecting layers onto the cube faces**, which is exactly "shadows" |
| `plot3D` (base graphics) | `scatter3D()`, `persp3D()`, `surf3D()`, etc.; static, printable | Static only; base-graphics look |
| `plotly` | Interactive WebGL in HTML; hover | Another visual system; heavy pages |

Check how the Vis-MLM book handles this: some chunks use `knitr::knit_hooks$set(webgl = hook_webgl)`,
and `options(rgl.useNULL = TRUE)` with snapshots through `webshot2` + Chrome. See e.g.
`Vis-MLM-book/R/pollen-eureka-frames.R` and `R/parenting.R`.

## Ideas to try

- **ggcube ellipsoid with its shadows.** Can ggcube draw a data ellipsoid? It has "sphere surface
  points"; a sphere mapped through `L` (from `chol(S)`) plus the mean gives an ellipsoid. Then
  use its project-to-faces position to drop the three 2D ellipses onto the walls of the cube.
  That one picture would show "ellipses have shadows" in 3D, in ggplot2 style, matching the
  other figures (blue #4C78A8, orange #F58518, grey #9D9D9D).
- **Same figure in `rgl`**, for comparison: `rgl::ellipse3d()` plus
  projected ellipses on the planes; static `snapshot3d()` and an embedded `rglwidget()`.
- **A 3D HE plot** (three responses, e.g. Pottery Al, Fe, Mg) with its three 2D HE-plot
  shadows: `heplot3d()` vs. `pairs()` of the 2D HE plots. Which tells you more?
- **Animated rotation as a GIF** (`animate_3d()` or `rgl::movie3d()`): kinetic depth for the blog,
  with one static frame for print.
- **The "find the view" problem**: the canonical view (candisc) is the best 2D shadow for
  separating groups. That's a precise answer to "which shadow should you show?", and it belongs
  in How-big already.

## Questions to settle

- Does this belong in How-big (as part of "ellipses have shadows"), in a separate post, or both?
- In a blog post, what's the right default: static PNG, GIF, or an embedded widget? Widgets need
  care with Quarto `freeze: auto` and page size.
- Is ggcube mature enough to use in a post now, or worth a short "first look" of its own?
- Unchecked: whether ggcube can take an arbitrary mesh (e.g. an `rgl::ellipse3d()` mesh) as a
  surface, and how its projection-to-faces works with surfaces rather than points.

## Sources

- ggcube on CRAN: <https://cran.r-project.org/web/packages/ggcube/index.html>; vignette
  <https://cran.r-project.org/web/packages/ggcube/vignettes/ggcube.html>; site
  <https://matthewkling.github.io/ggcube/>
- Installed versions checked 2026-11-24: matlib 1.0.1, heplots 1.8.6, car 3.1-5, candisc 1.1.2,
  rgl 1.3.36, plot3D 1.4.2, plotly 4.12.1. ggcube is not installed yet.
