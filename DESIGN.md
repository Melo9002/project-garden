# Current design

## Implemented
One editor-visible garden, four independently wandering sprite inhabitants named Earth, Fire, Wind and Water, pause, and a smooth side-scrolling perspective camera. The camera pans with A/D or arrow keys, right/middle mouse drag, and three button-accessible garden stops; the mouse wheel controls restrained zoom. Movement has no care consequences yet. All creatures hover above the scenery; the pond is decorative and does not block movement. Terrain, layered hills, forest edge, distant mountains, decoration, collision boundaries, spawn markers, lighting, camera limits and UI are editable in normal Godot scenes.

Pixies can be clicked through a reusable `Area3D`. Hovering gives a small scale cue; selection adds a ground ring and fills a compact inspector with identity, element, mood and current activity. Mood is currently a neutral placeholder and activity is derived from wandering state rather than stored separately.

The scene contains explicit `PlacementRegions`: a reachable meadow and a scenic-only backline. They establish an editor-visible boundary for a later item-placement system but do not yet validate placement or constrain pixy movement.

The first clearing now uses an oversized ground plane, foreground trees, 3D midground scenery and repeated 2D forest silhouettes at the horizon. Perspective supplies natural parallax between those layers and the camera stops before the oversized terrain can expose an edge. This is an authored illusion of continuation, not an endless or procedural map. The oval pond has a semantic water region and remains traversable by hovering pixies.

## Planned experiments
Environmental change should produce readable behavior and reaction faces. Start with four reactions: happy, unamused, curious, distressed. Test one friendly social encounter. Cooldowns prevent reaction spam; presentation consumes semantic reaction events rather than deciding simulation rules.

The first care experiment is implemented narrowly: the player can preview and place a flower patch on reachable dry meadow. A green or red ring communicates validity; the pond and outside bounds reject placement. Pixies within 2.4 world units become `Curious about flowers` for five simulated seconds and display a `?`. Flowers do not yet exert persistent influence, change elemental values, attract movement or save with the garden.

Shared pupal form develops toward four elemental forms. Exact evolution thresholds remain undecided. Temperature, water and light are provisional controls, not verified PS1 mechanics. No mortality or food rules are assumed.

## Presentation
Simple 3D diorama with 2D billboard pixie sprites. The current SVG is a replaceable placeholder that demonstrates the presentation contract without deciding final creature art. Frame artwork at actual gameplay scale before refining it.
