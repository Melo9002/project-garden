# Implementation reference

## Entry and ownership
`project.godot` selects the Compatibility renderer and `scenes/garden.tscn`. The scene owns the complete authored garden: world environment, light, terrain, pond, decorations, collision geometry, an interactables container, four spawn markers, three camera viewpoint markers, the active camera, and an instance of `garden_ui.tscn`. A developer can inspect and reposition these nodes without running the game.

`Garden` owns one `GardenSimulation` and an ordered array of runtime `PixyView` instances created from `pixy_placeholder.tscn`. Runtime creation is appropriate here because the simulation determines the active individuals. Their reusable visual structure remains editor-visible in its own scene. The simulation owns individual `PixyState` RefCounted objects. Views do not own or mutate state. Tree nodes are freed with the scene; RefCounted data lives while referenced.

## Data and movement
`pixy_state.gd`: stable identity, element label, location ID, 2D ground position/target, idle timer. X/Y in data map to X/Z in the scene. Each individual has its own object.

`garden_simulation.gd`: seeded RNG selects targets inside a fixed rectangular area and idle durations. Movement advances at 0.38 world units per second. The initial target equals position, so each pixie first picks a target and idles. No rendering, filesystem or global scene access.

`garden.gd`: coordinates authored nodes with the simulation. It reads the ordered `PixySpawns` markers into initial state, instantiates one configured `pixy_scene` per active state under `Pixies`, and cycles the camera through authored viewpoint markers. It accumulates frame time and advances simulation at the Inspector-exposed `simulation_rate` (30 Hz by default). Frame delta is capped at 0.15 to avoid long catch-up after stalls: deliberately not a real-time clock. Identical seeds and tick counts reproduce movement within the same runtime; no cross-platform bitwise guarantee. Pause stops simulation and therefore hover animation. Camera/UI stay interactive.

`pixy_placeholder.tscn` contains the visible body, head and billboard label. `pixy_view.gd` colors them, maps state position to world space and adds cosmetic bobbing. Hover amplitude and speed are Inspector properties on the reusable scene. These are explicit stand-ins, not the approved 2D art. Future sprite references belong here or in presentation definitions. Current palette is in Garden.COLORS; no species Resource system yet because the only species distinction is visual.

## Authored scenery, collisions and UI
The pond is a flat colored surface and does not currently affect navigation. Rocks and plants are explicitly placed under `Environment/Decorations`. `Collisions` contains a ground collider and four boundary colliders for future physics-driven content; current simulated movement still uses numeric bounds. `Interactables` is deliberately empty and provides an editor-visible home for later authored objects. Do not add empty speculative subsystems beyond such immediate level organization.

The orthographic camera copies positions from markers under `CameraRig/Viewpoints` and looks toward the Inspector-exposed `camera_look_target`; no free camera exists. `garden_ui.tscn` owns the complete Control layout and `garden_ui.gd` emits semantic button signals. The garden connects those signals to simulation/camera behavior. No selection, social behavior, environment needs, evolution, audio or persistence exists yet.

## Verification
Import: `godot --headless --path . --editor --import --quit`
Smoke run: `godot --headless --path . --quit-after 180`
Simulation contract check: `godot --headless --path . --script res://scripts/verify_simulation.gd` (passed 18,000 ticks for bounds, reproducibility and independent state).
Human check: F5, observe all four labels, pause/resume, switch all three viewpoints. Actual GPU appearance and interaction require a visual playtest; a headless run alone does not establish them.

For restricted tool runs, APPDATA and LOCALAPPDATA may be redirected for that process into workspace scratch directories to avoid writing global editor state. Normal desktop use needs no such redirection.

## Editor-first authoring rule
Static visual content and authored layouts belong in `.tscn` scenes. Reusable visual objects should become child scenes when reuse or isolated editing is useful. Scripts own behavior and dynamic state. Expose parameters that a designer is expected to tune; keep implementation details private. Use runtime construction only when identity, count, or content truly depends on runtime state.

## Next boundaries
Location state will own per-location conditions and memberships; the existing location ID is only a placeholder for that contract. Introduce species definitions when behavioral preferences arrive. Social rules should emit events; emote display should consume them. Save state, identifiers and RNG state explicitly when persistence is implemented, not scene nodes.
