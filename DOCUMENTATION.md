# Implementation reference

## Entry and ownership
`project.godot` selects the Compatibility renderer and `scenes/garden.tscn`. The scene owns the complete authored garden: world environment, light, terrain, pond, layered hills, forest edge, distant mountains, decorations, collision geometry, placement-region volumes, an interactables container, four spawn markers, the camera rig, and an instance of `garden_ui.tscn`. A developer can inspect and reposition these nodes without running the game.

`Garden` owns one `GardenSimulation` and an ordered array of runtime `PixyView` instances created from `pixy_placeholder.tscn`. Runtime creation is appropriate here because the simulation determines the active individuals. Their reusable visual structure remains editor-visible in its own scene. The simulation owns individual `PixyState` RefCounted objects. Views do not own or mutate state. Tree nodes are freed with the scene; RefCounted data lives while referenced.

## Data and movement
`pixy_state.gd`: stable identity, element label, location ID, 2D ground position/target, idle timer, current activity, temporary presentation reaction, and normalized energy/comfort/curiosity. X/Y in data map to X/Z in the scene. Each individual has its own object. Mood and qualitative need labels are derived methods, so display text cannot become a second source of simulation truth.

`first_garden_definition.tres` is the shared spatial contract: reachable rectangle, ordered shoreline points (X/Z), land/water heights and elemental tuning. `surface_at()` checks reachability first, then interpolates the shoreline: increasing Z is toward the camera and water. `random_water_point()` selects inside that reachable lake strip. Its boundary points match the editor-visible `CSGPolygon3D` meadow in `scenes/lakeshore.tscn`; `verify_lakeshore.gd` asserts this agreement. Keep both point lists aligned when editing the shore.

`garden_simulation.gd`: seeded RNG asks the supplied garden definition for reachable targets and independently selects idle durations. Movement advances at 0.38 world units per second. The initial target equals position, so each pixy first picks a target and idles. No rendering, filesystem or global scene access.

The daily-life rules are intentionally direct functions in `GardenSimulation`. Needs decay slowly and remain clamped from 0 to 1. Low energy chooses a timed rest. Low curiosity chooses the nearest registered flower; arrival changes the activity to enjoying flowers and restores curiosity/comfort during the idle period. Ordinary targets that fall on water are labeled as water investigation. Water additionally chooses `Seeking the lake` below 0.72 comfort; arrival becomes `Playing in the shallows` for 8–12 simulated seconds. That activity restores 0.008 comfort and 0.018 curiosity per second, in addition to existing local affinity absorption. Rest still takes priority when choosing a destination; after playing, Water gets an ordinary wandering choice instead of immediately reselecting the lake. This is behavior selection, not pathfinding or a general AI framework.

Elemental development is also explicit in `GardenSimulation`. Every `PixyState` and the garden hold a dictionary with the four named values. `GardenDefinition.elemental_exposure_at()` defines the current map's sources: flower radius for Earth, daylight for Fire, the open foreground threshold for Wind and the foreground lake for Water. Each tick grows exposed pixy values and garden values; exposure matching `PixyState.element` gives a small comfort benefit. The HUD compares garden values to the four scenario targets authored in `first_garden_definition.tres`. This is test balance, not final design.

`element_flare.tscn` is reusable presentation containing two billboard SVG layers. `element_flare.gd` owns only lifetime, vertical motion, lateral drift, scale envelope and fading; lifetime and rise speed are Inspector properties. `garden.gd` samples one pixy's strongest current exposure every 0.72 real seconds and occasionally selects an authored source position. This cadence deliberately uses frame delta rather than accelerated simulation time, preventing F3 speeds from producing particle floods. Flares never feed values back into `GardenSimulation`.

`garden.gd`: coordinates authored nodes with the simulation. It reads the ordered `PixySpawns` markers into initial state, instantiates one configured `pixy_scene` per active state under `Pixies`, and asks `GardenCamera` to move between three normalized quick stops. It accumulates frame time and advances simulation at the Inspector-exposed `simulation_rate` (30 Hz by default). Frame delta is capped at 0.15 to avoid long catch-up after stalls: deliberately not a real-time clock. Identical seeds and tick counts reproduce movement within the same runtime; no cross-platform bitwise guarantee. Pause stops simulation and therefore hover animation. Camera/UI stay interactive.

`pixy_placeholder.tscn` contains a billboard `Sprite3D` using `art/pixy_placeholder.svg` and a billboard label. `pixy_view.gd` tints it, maps state position to world space and adds cosmetic bobbing. Garden supplies the local surface height and whether the pixy is over reachable water; the view lowers toward the lake surface and displays its reusable ripple ring. Neither the sprite nor the ripple determines water affinity. Hover amplitude and speed are Inspector properties on the reusable scene. This is an explicit stand-in, not final 2D art. Replacement sprite references belong here or in later presentation definitions. Current palette is in Garden.COLORS; no species Resource system yet because the only species distinction is visual.

The reusable pixy scene also owns its `PickArea` and authored `SelectionRing`. `pixy_view.gd` converts left-click input into a semantic `selected(view)` signal and owns hover/selection presentation. `garden.gd` maps the selected view to the corresponding ordered `PixyState`; `garden_ui.gd` only formats that state for display. `PixyState.get_activity()` derives the current label from existing movement state, avoiding a second activity value that could become inconsistent.

`garden_camera.gd`: owns presentation-only camera navigation. A/D and arrow input move a bounded horizontal target, right/middle mouse dragging pans it, and the wheel changes perspective distance within conservative limits. Exponential smoothing makes keyboard, drag and quick-stop movement converge consistently. Its normalized position signal drives the UI strip; neither the camera nor UI affects simulation state.

## Authored scenery, collisions and UI
The static scenery is isolated in `scenes/lakeshore.tscn`, instanced under `Garden/Environment`. Open that scene to edit the land polygon, hill scales, pines, rocks, lily pads, grass cards and background layers. No runtime scenery generator was introduced.

- `Meadow` is a CSG polygon rotated 90 degrees around X. CSG extrudes along local negative Z, so its node sits at Y = -0.38 with depth 0.44: the top surface is Y = 0.06. Its last nine vertices are the shoreline points in reverse order.
- `ForegroundLake` is an oversized plane at Y = -0.16. `shaders/lake.gdshader` uses world-space ripples and colored glints, without screen-space refraction or renderer-specific dependencies. These are stylized reflections, not a reflection of actual scene objects.
- `shaders/meadow.gdshader` provides editable grass/moss colors and fine world-space variation. It does not displace terrain or decide surfaces.
- `shore_pine.tscn` combines a simple 3D trunk with two crossed, alpha-tested SVG needle cards. Reposition/scale scene instances in the editor; edit or replace the SVG independently.
- Three broad forest cards and a mountain card sit at distinct depths. Their parallax is ordinary perspective, not a custom scrolling script. Their lower edges are buried beneath the terrain. Lighting, sky and distance fog remain in `garden.tscn`.
- Shore grass, stones and lily pads are decorative. They do not block pixies or contribute new elemental sources in this batch.

`Collisions/Ground` is a flat placement-ray collider at meadow height. Placement then asks the definition for validity and preview height, so lake positions still show a rejected flower preview. `PlacementRegions` contains inactive editor reference volumes, not authoritative collision or navigation rules; the water box is only an approximate envelope of the exact shore. Reachable bounds are X = -7..7 and Z = -3..4. Scenic trees/hills beyond this rectangle are inaccessible.

The camera's scene overrides use height 3.4, initial distance 11, zoom distances 9.5–13 and look height 0.9. The foreground lake remains visible at both zoom limits. Water-plane edges are outside the bottom-corner rays at both horizontal stops.

## First placement and reaction slice
`flower_patch.tscn` is a reusable authored object containing its flower geometry and separate valid/invalid preview rings. Its small `flower_patch.gd` script only switches preview presentation; it has no knowledge of the garden or pixies.

`GardenPlacement` owns the current one-object placement interaction. The flower button begins a preview, a camera ray places it against existing collision geometry, left click confirms, and Escape or right click cancels. It asks the shared `GardenDefinition` whether the point is meadow instead of duplicating map coordinates. A later placement catalog can add object-specific surface requirements without putting those policies into the flower scene.

After confirmation, `GardenPlacement` emits the flower's 2D ground position. `GardenSimulation.notice_flower()` registers the flower and gives nearby pixies a temporary `?` reaction. `PixyView` renders that reaction while mood remains a longer-lived description derived from needs. Registered flowers can later attract curious pixies and restore curiosity and comfort.

## Persistence
`garden_save.gd` is the filesystem boundary and writes `user://garden_save.json`. `GardenSimulation.to_dictionary()` and `load_dictionary()` own the versioned data shape. Each `PixyState` serializes only plain values, including elemental development; garden energy is saved alongside flowers and RNG state. Scene nodes, resources and artwork never enter the save. Loading rebuilds placed flower scenes from saved ground positions. Current version 1 restores elapsed simulation time but deliberately performs no offline catch-up. When an older flower position is now underwater or outside the revised meadow, loading projects it to nearby dry ground and retargets any flower visits. This changes only the loaded state; the source save file is untouched until the player saves again.

## Debugging daily life
F3 toggles `garden_ui.tscn`'s developer panel. Opening it always pauses the simulation. Its speed buttons set a multiplier used only when `garden.gd` fills the fixed-step accumulator; they do not modify `Engine.time_scale`, so camera and UI input remain normal. `Advance 1 simulated minute` runs exactly 1,800 simulation ticks at the default 30 Hz while remaining paused.

The panel shows selected energy (`E`), comfort (`C`) and curiosity (`Q`) as exact normalized values. `Low energy` and `Low curiosity` set the selected value to 0.15 and make the pixy choose again immediately. Low energy should produce resting. Low curiosity should produce a flower visit when at least one flower exists. These are developer mutations and are intentionally kept out of `GardenSimulation`'s normal behavior API.

The perspective camera travels horizontally within authored limits; no free camera exists. `garden_ui.tscn` owns the complete Control layout and `garden_ui.gd` emits semantic button signals or presents supplied state. The garden connects those signals to simulation/camera behavior. Selection, daily needs, mood, elemental exposure and persistence exist. Social behavior, evolution, audio and offline progression remain deferred.

## Verification
Import: `godot --headless --path . --editor --import --quit`
Smoke run: `godot --headless --path . --quit-after 180`
Simulation contract check: `godot --headless --path . --script res://scripts/verify_simulation.gd` (passed 18,000 ticks for surface classification, placement validity, movement/need bounds, reproducibility, independent state, temporary reactions, and save-data round trips).
Lakeshore contracts: `godot --headless --path . --script res://scripts/verify_lakeshore.gd`. Checks scene/data shore agreement, mesh heights, dry/wet placement boundaries, reachable Water targets, comfort/energy recovery, old flower migration and camera projection limits. Add `-- --preview west` or `-- --preview east near` on a GPU run for a paused, twenty-second visual snapshot without touching player saves; `clean` hides the HUD in that preview only.

Human check: F5; watch Water seek the foreground lake, then pan and zoom across the shore; try placing flowers on both sides of the bank; press F3 and confirm it pauses; select a pixy; test exact-value updates, 1x/5x/30x, one-minute stepping, forced rest and forced flower seeking; then check ordinary selection, camera, placement, save and load. Actual GPU appearance and interaction require a visual playtest; a headless run alone does not establish them.

For restricted tool runs, APPDATA and LOCALAPPDATA may be redirected for that process into workspace scratch directories to avoid writing global editor state. Normal desktop use needs no such redirection.

## Editor-first authoring rule
Static visual content and authored layouts belong in `.tscn` scenes. Reusable visual objects should become child scenes when reuse or isolated editing is useful. Scripts own behavior and dynamic state. Expose parameters that a designer is expected to tune; keep implementation details private. Use runtime construction only when identity, count, or content truly depends on runtime state.

## Next boundaries
Location state will own per-location conditions and memberships; the existing location ID is only a placeholder for that contract. Introduce species definitions when behavioral preferences arrive. Social rules should emit events; emote display should consume them. Continue saving explicit state, identifiers and RNG state, never scene nodes.
