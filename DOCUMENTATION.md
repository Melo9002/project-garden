# Implementation reference

## Entry and ownership
`project.godot` selects the Compatibility renderer and `scenes/garden.tscn`. The scene has one root with `scripts/garden.gd`, which assembles scenery and UI at runtime. Thus the editor scene tree is sparse until running; this keeps the initial diorama compact, but reusable scenery can move into editable scenes later.

`Garden` owns one `GardenSimulation` and an ordered array of `PixyView` nodes. The simulation owns individual `PixyState` RefCounted objects. Views do not own or mutate state. Tree nodes are freed with the scene; RefCounted data lives while referenced.

## Data and movement
`pixy_state.gd`: stable identity, element label, location ID, 2D ground position/target, idle timer. X/Y in data map to X/Z in the scene. Each individual has its own object.

`garden_simulation.gd`: seeded RNG selects targets inside a fixed rectangular area and idle durations. Movement advances at 0.38 world units per second. The initial target equals position, so each pixie first picks a target and idles. No rendering, filesystem or global scene access.

`garden.gd`: accumulates frame time and advances simulation in fixed 1/30-second increments. Frame delta is capped at 0.15 to avoid long catch-up after stalls: deliberately not a real-time clock. Identical seeds and tick counts reproduce movement within the same runtime; no cross-platform bitwise guarantee. Pause stops simulation and therefore hover animation. Camera/UI stay interactive.

`pixy_view.gd`: colored geometry and billboard text label. `sync` maps state position to world space and adds cosmetic bobbing. These are explicit stand-ins, not the approved 2D art. Future sprite references belong here or in presentation definitions. Current palette is in Garden.COLORS; no species Resource system yet because the only species distinction is visual.

## Scenery and UI
The pond is a flat colored surface. Rocks/plants are seeded decorative meshes. Orthographic camera provides three positions; no free camera. UI uses a CanvasLayer so it stays in screen space. Buttons change pause and camera state. No navigation mesh, collisions, selection, social behavior, environment needs, evolution, audio or persistence exists yet.

## Verification
Import: `godot --headless --path . --editor --import --quit`
Smoke run: `godot --headless --path . --quit-after 180`
Simulation contract check: `godot --headless --path . --script res://scripts/verify_simulation.gd` (passed 18,000 ticks for bounds, reproducibility and independent state).
Human check: F5, observe all four labels, pause/resume, switch all three viewpoints. Actual GPU appearance and interaction require a visual playtest; a headless run alone does not establish them.

For restricted tool runs, APPDATA and LOCALAPPDATA may be redirected for that process into workspace scratch directories to avoid writing global editor state. Normal desktop use needs no such redirection.

## Next boundaries
Location state will own per-location conditions and memberships; the existing location ID is only a placeholder for that contract. Introduce species definitions when behavioral preferences arrive. Social rules should emit events; emote display should consume them. Save state, identifiers and RNG state explicitly when persistence is implemented, not scene nodes.
