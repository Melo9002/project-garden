# Current design

## Implemented
One editor-visible garden, four independently wandering sprite inhabitants named Earth, Fire, Wind and Water, pause, and a smooth side-scrolling perspective camera. The camera pans with A/D or arrow keys, right/middle mouse drag, and three button-accessible garden stops; the mouse wheel controls restrained zoom. Pixies have gentle daily needs and elemental development values. All creatures hover above the scenery; the foreground lake is traversable and contributes Water exposure. Terrain, layered hills, forest edge, distant mountains, decoration, collision boundaries, spawn markers, lighting, camera limits and UI are editable in normal Godot scenes.

Pixies can be clicked through a reusable `Area3D`. Hovering gives a small scale cue; selection adds a ground ring and fills a compact inspector with identity, derived mood, current activity, qualitative needs and affinity development.

The scene contains explicit `PlacementRegions`: a reachable meadow, water and a scenic-only backline. Flower placement validates against matching rules in the shared garden definition. These regions do not constrain pixy movement.

The first clearing is an authored lakeshore: broad foreground water, a gently irregular grassy bank, an open meadow, wooded side slopes, crossed-card pines with 3D trunks, three distant forest layers and hazy mountain silhouettes. Perspective supplies parallax; oversized scenery hides finite map edges. This is an authored illusion of continuation, not a procedural world. The lower perspective camera keeps reachable foreground water visible across its pan/zoom limits.

## Planned experiments
Environmental change should produce readable behavior and reaction faces. Start with four reactions: happy, unamused, curious, distressed. Test one friendly social encounter. Cooldowns prevent reaction spam; presentation consumes semantic reaction events rather than deciding simulation rules.

The first care experiment is implemented narrowly: the player can preview and place a flower patch on reachable dry meadow. A green or red ring communicates validity; the pond and outside bounds reject placement. Nearby pixies briefly display `?`. Flowers persist in saves, attract pixies with low curiosity, restore curiosity/comfort and provide localized Earth exposure.

The daily-life foundation gives every pixy energy, comfort and curiosity in a normalized 0–1 range. The inspector deliberately translates these into qualitative words. Mood is derived from the three needs. Pixies wander, rest when tired, investigate water when a wandering target overlaps it, and seek the nearest flower when curiosity becomes low. Rest restores energy; time near flowers restores curiosity and comfort. Water additionally seeks the foreground lake below 0.72 comfort, plays in the shallows for 8–12 simulated seconds, recovers comfort/curiosity and then resumes ordinary wandering. A small surface ripple makes water occupancy readable. This is hovering/playing, not a swimming or pathfinding system. These rates are provisional and gentle: there is no death, sickness or permanent neglect consequence.

Save/load stores simulation data as readable JSON: elapsed garden time, deterministic RNG state, each pixy's state and placed flower positions. It does not currently advance time while the game is closed.

The first elemental-development experiment tracks Earth, Fire, Wind and Water energy on both each pixy and the garden. The first clearing maps flowers to Earth, constant daylight to Fire, open foreground meadow to Wind and the foreground lake to Water. Local exposure grows the corresponding pixy value; matching its innate element also improves comfort. Natural sources and pixy exposure slowly raise the garden's four values toward provisional scenario targets. Values, rates, targets and source meanings are explicitly unbalanced.

Element generation is represented by short-lived rising flares: a colored glow, cyan/magenta fringe and narrow vertical streak inspired by the reference game's lens-like motes. Pixies show the strongest element currently present at their position; the pond or placed flowers occasionally emit ambient motes. Effects communicate existing simulation output and never modify energy themselves.

Shared pupal form develops toward four elemental forms. Exact evolution thresholds remain undecided. Temperature, water and light are provisional controls, not verified PS1 mechanics. No mortality or food rules are assumed.

## Presentation
Simple 3D diorama with 2D billboard pixie sprites. The current SVG is a replaceable placeholder that demonstrates the presentation contract without deciding final creature art. Frame artwork at actual gameplay scale before refining it.
