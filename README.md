# Project Garden

An original virtual-pet garden game built with Godot, inspired by the atmosphere and creature-raising ideas of the PlayStation game *Pixygarden*.

The vision is a quiet living diorama: tend mysterious pixies, shape their environment, discover what they become, and watch them interact with one another. Project Garden begins with a small garden and grows through playable experiments.

## Current build

**Early development — first foundation batch toward v0.1.**

Implemented:

- One editor-visible 3D garden with a reachable foreground lake, rocks, plants, collisions, spawn markers, placement regions, and a bounded camera rig.
- Layered 3D scenery and a 2D horizon forest create perspective parallax; oversized ground and foreground vegetation hide the map edges.
- Four replaceable 2D billboard placeholder pixies representing Earth, Fire, Wind, and Water.
- Click selection with a visible ring and a compact live identity/activity inspector.
- Flower, mossy resting-stone and wind-chime placement with full-object red invalid previews and dry-ground validation.
- Gentle energy, comfort and curiosity needs with autonomous resting, water investigation and flower visits.
- Readable JSON save/load for individual pixies, personalities, relationships, typed placed items, elapsed time and deterministic simulation state.
- A garden menu for Continue, New Garden, Save, Load and Return. New gardens roll persistent personalities without erasing the previous save until explicitly saved.
- Five personality values shape movement, need changes, item preference and social initiative. Pixies greet one another, build reciprocal affection/familiarity and remember at most three meaningful bonds.
- F3 developer panel with exact needs, accelerated simulation, minute stepping and forced behavior-test conditions.
- Provisional Earth, Fire, Wind and Water development for individual pixies and the first garden, with visible scenario targets.
- Rising chromatic elemental flares that make active pixy and environmental energy sources visible.
- Independent wandering, idling, and gentle hovering.
- Smooth bounded perspective camera with keyboard/drag panning, wheel zoom, three quick stops, and pause/resume controls.
- Separate simulation state and visual presentation.

The current build tests the feel of observing and gently influencing a small inhabited space. Social interactions, evolution, offline progress and final illustrated pixie sprites are not implemented yet. Pixies can hover across the foreground lake. Water seeks it when comfort dips and plays in its shallows, restoring comfort and curiosity.

## Run the project

Requirements: **Godot 4.7 standard edition**, using GDScript and the Compatibility renderer. No .NET SDK or third-party plugins are needed. The foundation was checked with Godot 4.7 on Windows.

1. Clone or download this repository.
2. Open Godot's Project Manager and import the `project.godot` file at the repository root.
3. Open the project and press **F5**.
4. Use **Pause / resume** and **Change viewpoint** in the on-screen panel.

Open `scenes/garden.tscn` for the complete garden and `scenes/lakeshore.tscn` for the static scenery. Shoreline coordinates and habitat rules live in `first_garden_definition.tres`; the visual land polygon is checked against those points by `verify_lakeshore.gd`. The UI and pixy placeholder are reusable child scenes.

If Godot is on your PATH, you can also launch from the repository root:

```sh
godot --path . --editor
```

## Direction for v0.1

- Simple 2D pixies within a small 3D environment.
- Environmental care with visible responses.
- Pixie-to-pixie encounters and expressive reaction faces.
- A shared pupal form and an initial development milestone.
- Save/load and a focused playtest loop.

Multiple locations, planetary development, and an in-world assistant are later possibilities. See [TASKS.md](TASKS.md) for the working roadmap and experiment results.

## Art direction

Distinct elemental silhouettes, angular anime shapes, expressive faces, limited palettes, and readable cel shading guide the character designs. Their simplicity is intentional: each pixie should remain recognizable at garden scale.

AI-assisted concept studies serve as temporary drawing references. Pedro will draw the final 2D artwork before public prototype release. The current geometric placeholders are temporary; simple 3D scenery keeps the focus on the inhabitants.

## Development approach

Work proceeds in small runnable batches. Related tasks can be combined to test a shared hypothesis, followed by playtesting and revision. Design ideas remain provisional until they have been tried.

The code keeps individual state and simulation rules independent of scene nodes and artwork. This makes it easier to replace visuals and introduce additional locations as the game develops.

| File | Responsibility |
| --- | --- |
| `scenes/garden.tscn` | Editor-authored garden, lighting, collisions, spawns and viewpoints |
| `scenes/lakeshore.tscn` | Authored land, foreground lake and layered scenery |
| `scenes/shore_pine.tscn` | Reusable 3D trunk and crossed SVG needle cards |
| `scenes/garden_ui.tscn` | Reusable editor-authored interface |
| `scenes/pixy_placeholder.tscn` | Reusable temporary pixy visual |
| `scripts/garden.gd` | Fixed-step scheduling and scene/simulation coordination |
| `scripts/garden_ui.gd` | UI signals and status presentation |
| `scripts/garden_definition.gd` | Shared meadow, water, and placement rules for one garden |
| `scripts/garden_simulation.gd` | Seeded movement, daily needs, activities, and snapshot data |
| `scripts/pixy_state.gd` | Each pixy's identity, needs, activity, and movement state |
| `scripts/pixy_view.gd` | Temporary geometry, labels, and cosmetic hovering |
| `scripts/garden_save.gd` | Plain JSON persistence boundary |
| `scripts/verify_simulation.gd` | Headless simulation contract checks |
| `scripts/verify_individuality.gd` | Menu, new-game, item reconstruction and invalid-preview checks |

## Checks

Run these commands from the repository root with Godot on PATH:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 180
godot --headless --path . --script res://scripts/verify_simulation.gd
godot --headless --path . --script res://scripts/verify_lakeshore.gd
godot --headless --path . --script res://scripts/verify_individuality.gd
```

The checks cover movement bounds, same-seed reproducibility, personality and relationship persistence, item effects, shoreline agreement, new-game reconstruction and placement feedback. The prototype uses no network services and the verification scripts do not touch the player's save.

Visual appearance and button interaction still require a desktop playtest; headless checks do not validate rendering.

## Project documentation

- [PROJECT.md](PROJECT.md) — vision, scope, and creative direction.
- [DESIGN.md](DESIGN.md) — implemented mechanics and proposed experiments.
- [TASKS.md](TASKS.md) — development batches, validation, and playtest observations.
- [DOCUMENTATION.md](DOCUMENTATION.md) — current architecture, ownership, data flow, and extension points.
- [AGENTS.md](AGENTS.md) — working instructions for coding assistants.
