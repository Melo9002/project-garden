# Implementation reference

## Entry and ownership
`project.godot` selects the Compatibility renderer and `scenes/garden.tscn`. The scene owns the complete authored garden: world environment, light, terrain, pond, layered hills, forest edge, distant mountains, decorations, collision geometry, placement-region volumes, an interactables container, four spawn markers, the camera rig, and an instance of `garden_ui.tscn`. A developer can inspect and reposition these nodes without running the game.

`Garden` owns one `GardenSimulation` and an ordered array of runtime `PixyView` instances created from `pixy_placeholder.tscn`. Runtime creation is appropriate here because the simulation determines the active individuals. Their reusable visual structure remains editor-visible in its own scene. The simulation owns individual `PixyState` RefCounted objects. Views do not own or mutate state. Tree nodes are freed with the scene; RefCounted data lives while referenced.

## Data and movement
`pixy_state.gd`: stable identity, element label, location ID, 2D ground position/target, idle timer. X/Y in data map to X/Z in the scene. Each individual has its own object.

`garden_simulation.gd`: seeded RNG selects targets inside a fixed rectangular area and idle durations. Movement advances at 0.38 world units per second. The initial target equals position, so each pixie first picks a target and idles. No rendering, filesystem or global scene access.

`garden.gd`: coordinates authored nodes with the simulation. It reads the ordered `PixySpawns` markers into initial state, instantiates one configured `pixy_scene` per active state under `Pixies`, and asks `GardenCamera` to move between three normalized quick stops. It accumulates frame time and advances simulation at the Inspector-exposed `simulation_rate` (30 Hz by default). Frame delta is capped at 0.15 to avoid long catch-up after stalls: deliberately not a real-time clock. Identical seeds and tick counts reproduce movement within the same runtime; no cross-platform bitwise guarantee. Pause stops simulation and therefore hover animation. Camera/UI stay interactive.

`pixy_placeholder.tscn` contains a billboard `Sprite3D` using `art/pixy_placeholder.svg` and a billboard label. `pixy_view.gd` tints it, maps state position to world space and adds cosmetic bobbing. Hover amplitude and speed are Inspector properties on the reusable scene. This is an explicit stand-in, not final 2D art. Replacement sprite references belong here or in later presentation definitions. Current palette is in Garden.COLORS; no species Resource system yet because the only species distinction is visual.

The reusable pixy scene also owns its `PickArea` and authored `SelectionRing`. `pixy_view.gd` converts left-click input into a semantic `selected(view)` signal and owns hover/selection presentation. `garden.gd` maps the selected view to the corresponding ordered `PixyState`; `garden_ui.gd` only formats that state for display. `PixyState.get_activity()` derives the current label from existing movement state, avoiding a second activity value that could become inconsistent.

`garden_camera.gd`: owns presentation-only camera navigation. A/D and arrow input move a bounded horizontal target, right/middle mouse dragging pans it, and the wheel changes perspective distance within conservative limits. Exponential smoothing makes keyboard, drag and quick-stop movement converge consistently. Its normalized position signal drives the UI strip; neither the camera nor UI affects simulation state.

## Authored scenery, collisions and UI
The pond is a flat colored surface and does not currently affect navigation. Rocks and plants are explicitly placed under `Environment/Decorations`; the larger scenic layers are under clearly named authored containers. `Collisions` contains a ground collider and four boundary colliders for future physics-driven content; current simulated movement still uses numeric bounds. `PlacementRegions/ReachableMeadow` and `ScenicBackline` are inactive `Area3D` volumes documenting the intended later placement split. `Interactables` is deliberately empty and provides an editor-visible home for later authored objects. No placement controller, grid or validation rules exist yet.

`Environment/HorizonForest` repeats an SVG silhouette behind the 3D forest edge. It is intentionally a 2D authored layer: because it sits farther from the perspective camera than the playable meadow, it moves more slowly during camera travel and supplies parallax without a custom parallax system. `ForegroundFrame` and the oversized 26-unit terrain conceal the reachable camera limits. These layers are separate so a later procedural experiment can generate foreground, playable surface, midground and horizon independently without coupling generation to the simulation.

`PlacementRegions/Water` records `surface_type = "water"` and `traversable_by_pixies = true`. It is currently documentation in the scene rather than active behavior. A later surface-query contract can use this region to select hover, wade, swim or ripple presentation without turning the pond into a movement obstacle.

The perspective camera travels horizontally within authored limits; no free camera exists. `garden_ui.tscn` owns the complete Control layout and `garden_ui.gd` emits semantic button signals or presents supplied state. The garden connects those signals to simulation/camera behavior. Selection exists, but social behavior, changing moods, environment needs, evolution, audio and persistence do not yet.

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
