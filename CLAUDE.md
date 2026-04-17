# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A browser-based p5.js (WEBGL) sketch that renders a grayscale heightmap as interactive 3D line art. Everything lives in a single file: `index.html`.

## Running

Browsers block `file://` image loads, so a local HTTP server is required for the default heightmap:

```bash
python3 -m http.server 8000
# open http://localhost:8000
```

The **Load Heightmap** button bypasses this — it reads a file via `FileReader` and never touches the network.

## Architecture

### Data flow

1. `preload()` — loads `data/Heightmap.png` via p5.js
2. `initHeightmap()` — extracts greyscale pixels into a `willReadFrequently` canvas (`extractHeightmapPixels()`), runs `computeBlurredPixels()`, `computeHistogram()`, then `calcTerrain()`
3. `calcTerrain()` — samples `blurredPixels || heightmapPixels` at `scl`-pixel intervals (offset by `shiftPeaks`/`shiftLines`), clamps to `[blackPoint, whitePoint]`, maps to elevation `[−50, 50] × elevScale`, stores in `terrain[rows][cols]`, tracks `terrainMinZ/MaxZ/MaxSlope`, sets all geometry dirty flags
4. `draw()` — applies `scale(zoom)` → `rotateX(tiltDeg)` → `rotateZ(rotation)` → `translate` to centre, dispatches to the active renderer

### Renderers

- **`drawRidgelines()`** — handles `lines-x`, `lines-y`, `curves`, `crosshatch` modes. Reads from `ridgelineRowPtsX/Y` + `ridgelineWallPtsX/Y` caches. Draws a background-coloured `TRIANGLE_STRIP` wall per row for depth-correct occlusion, then the line/curve on top. Crosshatch renders both X and Y directions via an inner `renderDir()` helper.
- **`drawHachures()`** — hachure mode. Draws occluding terrain surface, then tick marks from `hachureGeomPts` cache (7 floats per segment: `ax,ay,az, bx,by,bz, slope`). Tick direction is perpendicular to gradient; length ∝ gradient magnitude × `hachureLength`.
- **`drawContours()`** — contours mode. Draws occluding terrain surface, then isolines from `contourGeomPts` (flat) or `contourLevels` (grouped by level, used when visual effects are active for O(levels) draw calls).
- **`drawPoints3D()`** — point markers at every terrain vertex for the active mode; handles all geometry cache strides correctly (ridgeline stride 3, hachure stride 7).

### Geometry cache

Terrain geometry is stored in `Float32Array`s and rebuilt only when terrain or layout parameters change — never on view changes (tilt, rotation, pan, zoom).

- `ridgelineRowPtsX[i]` — `Float32Array(innerCount × 3)` world-space xyz per row (X direction)
- `ridgelineWallPtsX[i]` — `Float32Array(innerCount × 6)` top+bottom pairs for occluder (X direction)
- `ridgelineRowPtsY` / `ridgelineWallPtsY` — same for Y direction; populated for `lines-y` and `crosshatch` modes
- `hachureGeomPts` — `Float32Array` of 7-float segments: `[ax,ay,az, bx,by,bz, slopePerGridStep, ...]`
- `contourGeomPts` — `Float32Array` of 6-float segment pairs from marching squares (flat, for simple render path)
- `contourLevels` — `[{level, pts: Float32Array}, ...]` grouped by elevation level (for O(levels) effects render path)
- Dirty flags: `ridgelineDirty`, `contourDirty`, `hachureDirty` — set by any call that changes terrain shape or line layout. `particlesDirty` triggers particle home rebuild.

### Redraw model

`noLoop()` is called in `setup()`; canvas only redraws on state change via `markDirty()` → `redraw()`. `checkLoop()` enables `loop()` when `rotating || particlesActive`. WebM recording also calls `loop()` for the duration of the capture.

### Cached derived values

Updated only in their setters, never recomputed per frame:

- `_lineStep` — `max(1, round(linePx / scl))`; updated in `setScl()` and `setLinePx()`
- `rgbBg`, `rgbLine`, `rgbLineHigh` — `[r,g,b]` arrays from `hexToRGB()`; updated in `setBgColor()`, `setLineColor()`, `setLineColorHigh()`

### Visual effects per row/segment

`getRowStroke(avgZ, avgSlope)` and `getRowStrokeWeight(avgZ)` compute per-row color/alpha/weight using `normalizeElevation(z)` (0–1 fraction), `rgbLine`/`rgbLineHigh` caches, and `terrainMaxSlope` for normalisation. Called once per ridgeline row, once per contour level, or once per hachure segment depending on mode.

### Key state variables

| Variable | Purpose |
|---|---|
| `scl` | Pixels between sampled points along a line; affects `cols`/`rows` |
| `_lineStep` | `max(1, round(linePx/scl))` — cached grid step; update in `setScl`/`setLinePx` |
| `linePx` | Pixel gap between adjacent lines |
| `shiftLines` / `shiftPeaks` | Sub-pixel sampling offset (0 … scl−1) |
| `drawMode` | `'lines-x'` \| `'lines-y'` \| `'curves'` \| `'crosshatch'` \| `'hachure'` \| `'contours'` |
| `elevScale` | Elevation multiplier (0–5×) |
| `blackPoint` / `whitePoint` | Brightness clip range (0–255) applied in `calcTerrain()` |
| `blurRadius` | Box-blur radius (0–10); `computeBlurredPixels()` uses integral image — O(W×H) |
| `tiltDeg` | X-axis perspective angle in degrees |
| `rotation` | Z-axis rotation in degrees |
| `zoom` | Canvas scale factor (0.1–4.0) |
| `tightness` | Catmull-Rom spline tightness (−5 to 5); curves mode only |
| `contourInterval` | Elevation units between contour levels |
| `hachureLength` | Tick length multiplier for hachure mode |
| `bgColor` / `lineColor` / `lineColorHigh` | Hex color strings; corresponding `rgbBg/rgbLine/rgbLineHigh` are the cached `[r,g,b]` arrays |
| `lineGradient` | Lerp line color from `rgbLine` → `rgbLineHigh` by elevation |
| `strokeByElev` / `strokeElevRange` | Scale stroke weight by elevation fraction |
| `slopeOpacity` | Drive line alpha from local slope / `terrainMaxSlope` |
| `terrainMinZ` / `terrainMaxZ` / `terrainMaxSlope` | Computed in `calcTerrain()`; used for normalisation in effects |

### SVG / DXF / PNG / WebM export

- **SVG**: `svgRidgelinesOccluded()` runs a horizon algorithm — front-to-back, tracks min screen-Y per pixel column, emits only above-horizon segments back-to-front. Works for all ridgeline modes including crosshatch (runs twice). Contour and hachure modes project cached geometry directly. When particle animation is active, exports current particle screen positions.
- **DXF**: 2D projected LINE entities via `project3D()`. No Z output.
- **PNG**: `exportHighResPNG()` temporarily scales canvas by `pngScale` (1×/2×/4×) before `saveCanvas()`.
- **WebM**: `compositeCanvas` (off-screen 2D canvas) composites the WEBGL canvas + particle overlay each frame; `MediaRecorder` streams it.
- **Presets**: `savePreset()` / `loadPreset()` serialise/deserialise all state variables to/from JSON.

`project3D(vx, vy, vz)` mirrors the draw-loop transform stack: translate → rotateZ → rotateX → perspective divide (60° FOV, matching p5's default camera) → zoom scale.
