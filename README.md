# heightmap_lines

<p float="left">
  <img src="https://github.com/sorny/heightmap_lines/blob/main/data/Heightmap.png?raw=true" alt="heightmap example" height="300">
  →
  <img src="https://github.com/sorny/heightmap_lines/blob/main/heightmap_lines.png?raw=true" alt="heightmap_lines example" height="300">
</p>

A browser-based tool that turns a grayscale heightmap image into interactive 3D line art. All controls live in a collapsible side panel — no coding required.

## Live demo

**[sorny.github.io/heightmap_lines](https://sorny.github.io/heightmap_lines)**

## Running locally

Browsers block local image loads over `file://`, so serve it with any static server:

```bash
python3 -m http.server 8000
# open http://localhost:8000
```

Or skip the server entirely — use the **Load Heightmap** button to upload any image directly from your machine.

## Heightmap source

[Tangrams Heightmapper](https://tangrams.github.io/heightmapper) exports grayscale PNGs from OpenStreetMap data. Drop the result into `data/Heightmap.png` to use it as the default.

## Panel controls

### Terrain
| Control | What it does |
|---|---|
| Resolution | Sampling density — higher = more points per line |
| Line spacing | Pixel gap between adjacent lines |
| Elev scale | Multiplies peak height (0 = flat → 5× = dramatic) |
| Blur | Box-blur the heightmap before sampling (integral image, stays fast at any radius) |
| Shift lines / Shift peaks | Sub-pixel sampling offset for fine placement |

### Levels
Visualises the heightmap's brightness histogram. Drag the handles directly on the histogram or use the Shadows / Highlights sliders to clip the brightness range before elevation mapping.

### View
| Control | What it does |
|---|---|
| Tilt | X-axis perspective angle |
| Zoom | Canvas scale (10–400%); also scroll wheel |
| Rotation | Z-axis rotation; ±45° buttons, free slider, auto-rotate toggle |
| Pan | Click-and-hold arrow buttons or W A S D keys |

### Style
| Control | What it does |
|---|---|
| Lines | Toggle line drawing; color picker and stroke weight |
| Points | Toggle point markers; color picker, size, and optional particle animation |
| Draw mode | X · Y · Curves · Cross · Hachure · Contours |
| Curve tightness | Catmull-Rom spline tightness (−5 to 5); Curves mode only |
| Hachure length | Tick length multiplier; Hachure mode only |
| Contour interval | Elevation units between isoline levels; Contours mode only |
| Fill | White terrain surface fill |
| Mesh | Wireframe mesh overlay |
| Background | Canvas background color |
| Elev gradient | Blend line color from base → high-elevation color |
| Wt by elev | Stroke weight increases with elevation; range slider controls spread |
| Opacity/slope | Line alpha driven by local terrain slope |

#### Draw modes
| Mode | Description |
|---|---|
| X / Y | Horizontal or vertical ridge lines with depth-correct white-wall occlusion |
| Curves | Catmull-Rom splines along ridgelines |
| Cross | Both X and Y ridge lines simultaneously |
| Hachure | Slope-perpendicular tick marks; length proportional to gradient magnitude |
| Contours | Marching-squares isolines at fixed elevation intervals |

### Particle animation
Enable under Points → Animate. Particles spring back to their terrain home positions while Brownian noise, damping, and optional gravity keep them in motion. Velocity trails can be toggled on/off.

### Export
| Button | Output |
|---|---|
| SVG | Visibility-aware vector — occluded lines omitted via horizon algorithm |
| DXF | 2D projected LINE entities |
| PNG | Current canvas raster; 1×, 2×, or 4× scale |
| WebM | Records a video of the canvas for the configured duration |
| Preset ↓ / ↑ | Save or load all panel settings as a JSON file |

## Keyboard shortcuts

| Key | Action |
|---|---|
| W A S D | Pan |
| Y / X | Tilt up / down |
| Q | Toggle auto-rotate |
| E | Rotate +45° |
| T | Reset rotation |
| I / K | Decrease / increase resolution |
| J / L | Decrease / increase line spacing |
| B / N | Increase / decrease stroke weight |
| F | Cycle draw mode |
| M | Toggle mesh |
| O | Toggle mesh stroke |
| P | Toggle fill |
| ↑ ↓ | Shift lines |
| ← → | Shift peaks |
| 1 | Export SVG |
| 2 | Export DXF |
| 3 | Export PNG |

## License

MIT
