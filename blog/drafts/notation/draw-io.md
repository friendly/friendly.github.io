# draw.io for blog and presentation diagrams

Notes from a discussion with Claude (2026-09-29) about whether to use draw.io,
and its MCP server, for diagrams like the ones in `diagrams/`.

## Current workflow: Graphviz

- Each diagram is a small `.dot` text file (e.g. `diagrams/sem-cycle.dot`), with the
  shared visual vocabulary documented in a comment at the top.
- `diagrams/render-dots.R` renders every `.dot` file to PNG via
  DiagrammeR → SVG → rsvg.
- Pros: plain text, clean git diffs, reproducible, and easy for Claude to read and edit.
- Con: layout control. `sem-cycle.dot` already pins every node with `pos="x,y!"`
  under `neato`, which is a sign of fighting the automatic layout. Fine-tuning edge
  curves and label positions by eye is awkward.
- Alternative: Quarto can render `{dot}` code blocks inline in the `.qmd`, which would
  make the separate render script unnecessary.

## What draw.io adds

- **Layout by hand.** Claude writes a first draft of the diagram as XML; you open it in
  draw.io and drag boxes, bend arrows and move labels by eye.
- A `.drawio` file is still text (XML), so it can live in the repo next to the
  exported image.
- Exports to SVG, PNG and PDF from the command line using **draw.io Desktop**.

## The draw.io MCP server

<https://github.com/mcp/io.draw/mcp>

- Tools: `create_diagram` (takes draw.io XML and shows an interactive diagram in chat,
  or opens it in the draw.io web editor) and `search_shapes` (searches shape libraries;
  mostly AWS, Azure and GCP icons, which these diagrams don't need).
- Can also accept Mermaid or CSV, save `.drawio` files, and export PNG, SVG or PDF.
  Export runs through a locally installed draw.io Desktop.
- Setup options:
  - Hosted: add `https://mcp.draw.io/mcp` as a connector in claude.ai (no install).
    Useful for sketching diagrams in the claude.ai chat.
  - Local: `npx @drawio/mcp` (needs Node.js) or the `jgraph/drawio-mcp` Docker image.
- **Verdict:** not needed for this workflow. With draw.io Desktop installed, Claude can
  write `.drawio` files directly and export them from the command line. The MCP server
  mainly adds in-chat previews.

## Recommendation

1. Keep Graphviz for diagrams whose automatic layout is good enough.
2. Use draw.io for diagrams you want to fine-tune by hand. Keep the `.drawio` source
   and the exported `.svg` or `.png` together in `diagrams/`.
3. Add the MCP server only if in-chat previews turn out to be worth it.

On this machine (as of 2026-09-29), neither draw.io Desktop nor Node.js was installed.

## What a `.drawio` file looks like

A small version of part of `sem-cycle`, using the same visual vocabulary: a blue box for
code, a blue ellipse for R, a blue square-cornered box for output, a green cylinder for
data, solid arrows for translations done by software, and a red dashed arrow for the
revision loop.

```xml
<mxfile host="drawio">
  <diagram name="sem-mini" id="sem-mini">
    <mxGraphModel grid="1" gridSize="10" page="0">
      <root>
        <!-- cells 0 and 1 are required boilerplate: the root and the default layer -->
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- nodes (vertex="1"): value = label, style = look, geometry = position/size -->
        <mxCell id="code" value="Code&lt;br&gt;(sem, lavaan)" vertex="1" parent="1"
          style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E3EEF8;strokeColor=#555555;fontFamily=Helvetica;fontSize=13;">
          <mxGeometry x="40" y="40" width="120" height="50" as="geometry"/>
        </mxCell>

        <mxCell id="R" value="R" vertex="1" parent="1"
          style="ellipse;whiteSpace=wrap;html=1;fillColor=#E3EEF8;strokeColor=#555555;fontFamily=Helvetica;fontSize=13;">
          <mxGeometry x="220" y="40" width="70" height="50" as="geometry"/>
        </mxCell>

        <mxCell id="output" value="Output&lt;br&gt;(estimates, fit)" vertex="1" parent="1"
          style="rounded=0;whiteSpace=wrap;html=1;fillColor=#E3EEF8;strokeColor=#555555;fontFamily=Helvetica;fontSize=13;">
          <mxGeometry x="350" y="40" width="130" height="50" as="geometry"/>
        </mxCell>

        <mxCell id="data" value="Data" vertex="1" parent="1"
          style="shape=cylinder3;boundedLbl=1;size=8;whiteSpace=wrap;html=1;fillColor=#E6F2E0;strokeColor=#555555;fontFamily=Helvetica;fontSize=13;">
          <mxGeometry x="220" y="150" width="70" height="60" as="geometry"/>
        </mxCell>

        <!-- edges (edge="1"): connect source and target ids; draw.io routes them -->
        <mxCell id="e1" edge="1" parent="1" source="code" target="R"
          style="endArrow=classic;html=1;strokeWidth=2;strokeColor=#333333;">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="e2" edge="1" parent="1" source="R" target="output"
          style="endArrow=classic;html=1;strokeWidth=2;strokeColor=#333333;">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="e3" value="reduced to means, S" edge="1" parent="1" source="data" target="R"
          style="endArrow=classic;html=1;strokeColor=#333333;fontSize=10;fontColor=#555555;">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- revision loop: red, dashed, curved back over the top -->
        <mxCell id="e4" value="revise" edge="1" parent="1" source="output" target="code"
          style="endArrow=classic;html=1;dashed=1;curved=1;strokeWidth=1.6;strokeColor=#C0392B;fontColor=#C0392B;fontSize=10;">
          <mxGeometry relative="1" as="geometry">
            <Array as="points"><mxPoint x="260" y="-10"/></Array>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

How it's put together:

- Everything is an `mxCell`. Nodes have `vertex="1"` and an `mxGeometry` with
  `x, y, width, height` in pixels; edges have `edge="1"` and `source`/`target` ids.
- `style` is a `key=value;` list and does the work that node and edge attributes do in
  Graphviz: `rounded`, `fillColor`, `strokeColor`, `dashed`, `strokeWidth`, `fontSize`,
  and `shape` (e.g. `ellipse`, `shape=cylinder3`).
- Labels are HTML when `html=1`, so a line break is `&lt;br&gt;` (an escaped `<br>`).
- Waypoints (`Array as="points"`) bend an edge; this is what you'd normally adjust by
  dragging in the editor.
- An easy way to learn a style: style something in the editor, then look at
  **Edit Style** (Ctrl+E) to see its style string.

## Exporting with draw.io Desktop

**On this machine** draw.io was installed from the Microsoft Store (version 31.5.3,
checked 2026-09-29). That means:

- It is not on the PATH, and there is no `draw.io` command alias.
- The executable is inside a folder whose name includes the version number, so the
  path changes with every update. Look it up at run time instead:

  ```powershell
  $drawio = "$((Get-AppxPackage draw.io.draw.ioDiagrams).InstallLocation)\app\draw.io.exe"
  Start-Process $drawio -ArgumentList '-x','-f','png','-s','2','-b','10','-o','out.png','in.drawio' -Wait -NoNewWindow
  ```

- Calling it with `& $drawio ...` runs but prints nothing. `Start-Process -NoNewWindow`
  shows its messages. Error lines like `Unable to move the cache: Access is denied`
  are harmless; the export still works.
- Tested with the `sem-mini` example above: it exported a correct PNG.

With an ordinary installer (default path `C:\Program Files\draw.io\draw.io.exe`), the
same program exports from the command line:

```sh
# SVG (best for the blog: sharp at any size)
draw.io -x -f svg -o diagrams/sem-mini.svg diagrams/sem-mini.drawio

# PNG at 2x scale with a transparent background and a 10px border
draw.io -x -f png -s 2 -t -b 10 -o diagrams/sem-mini.png diagrams/sem-mini.drawio

# PDF, cropped to the diagram (for slides / LaTeX)
draw.io -x -f pdf --crop -o diagrams/sem-mini.pdf diagrams/sem-mini.drawio
```

- `-e` (`--embed-diagram`) stores the diagram inside the exported PNG, SVG or PDF, so
  the image itself can be reopened and edited in draw.io. Files named `*.drawio.svg`
  or `*.drawio.png` are a common convention for this, and can replace the separate
  `.drawio` source.
- Run `draw.io --help` to check the options for the installed version.
- In Quarto: `![Caption](diagrams/sem-mini.svg){width=80%}`.
- An optional extra: the VS Code extension "Draw.io Integration" edits `.drawio` files
  inside VS Code.

## Next steps

- Install draw.io Desktop and try it out.
- Possibly redo `sem-cycle` as a `.drawio` file in the same style, to compare how easy
  it is to edit with the Graphviz version.
