# Better SVG Creator for Piece Icons

## Goal
The current path editor makes custom pieces look like thick blobs instead of crisp, distinguishable symbols. The fix is to treat every stroke as clean vector path data with controlled width, smoothing, and export rules that preserve legibility at game scale.

## Main improvements to implement
### 1. Finer minimum stroke widths
- Default drawing width should be around 5-7 px instead of 10+
- Use stroke width as a design parameter instead of a blunt blob brush
- Keep the line readable at small piece sizes in-game

### 2. Stroke refinement instead of raw mouse noise
- Filter input points by distance before storing them
- Smooth the stroke with a mild averaging pass
- Simplify the path to reduce unnecessary points without collapsing the silhouette
- Preserve corner clarity for chess-like icons and badges

### 3. Distinguishable icon silhouettes
- Use stronger edge contrast between outline and fill
- Add subtle start/end anchor glints so the path direction is clearer
- Keep strokes separate enough that overlapping lines do not merge into one fat shape

### 4. Better SVG export semantics
- Export single-segment paths with proper line caps and joins
- Keep normalized point data for import/export without scaling distortion
- Preserve stroke order so the silhouette stays readable when recolored in-game
- Support a clean SVG preview before saving

### 5. Tooling features that matter for icon design
- Brush / eraser / line / rectangle / ellipse presets
- Symmetry mode for mirrored icons
- Snap-to-cardinal or 45° angles for crisp geometric marks
- Undo/redo for stroke groups
- Shape guides overlay while drawing
- A center-lock mode for icons that must remain balanced

### 6. Quality-of-life features
- Fill preview for the final piece silhouette
- PNG export as a quick test output
- Import existing SVGs and normalize them into editable strokes
- Small tolerance settings for smoothing, simplification, and stroke noise filtering
- A dark / light / outline preview mode to test readability on all board themes

## Recommended architecture for the editor
- Treat each stroke as a structured path object:
  - points
  - width
  - color
  - smoothing mode
  - tool type
  - symmetry metadata
- Render from refined stroke data instead of raw mouse positions
- Save normalized data to the piece definition, then export to SVG as a clean vector format
- Keep a separate preview layer that does not mutate the stored path until the user confirms it

## Good first implementation milestone
1. Reduce the base stroke width to 6 px
2. Add point filtering and smoothing
3. Apply simplification before drawing/export
4. Export stroke paths with round joins and consistent line width
5. Add symmetry and snap toggles as optional controls

## Future improvements
- Pressure-sensitive width if tablet input is added later
- Layer support for details and base shapes
- Auto-detect if an imported SVG is mostly line art vs a filled silhouette
- Piece icon templates for common chess-like roles

## Notes
This should be a deliberate icon editor, not a freehand paintbrush. The priority is legibility at small game scale and enough structure to keep the result exportable and distinct from the current blob-heavy look.

# Ideas
1. Hovering over an opponents piece shows that piece's available moves
1. Add "Options" to main menu
    1. Add option to change screen resolution
1. 

# Bugs
1. 
1. During a muster phase it appears the player 2 gets 2 turns in a row
1. Muster phase should automatically end and movement phase start when both players have no more pieces in their drop pool

# Visual bugs
1. Container for board setup clips into scroll bar
1. there is a "Status" on the presets menu that doesn't need to be there