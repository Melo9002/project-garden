# Project Garden

An original virtual-pet garden game built with Godot, inspired by the atmosphere and creature-raising ideas of the PlayStation game *Pixygarden*.

The vision is a quiet living diorama: tend mysterious pixies, shape their environment, discover what they become, and watch them interact with one another. Project Garden begins with a small garden and grows through playable experiments.

## Current build

**Early development — first foundation batch toward v0.1.**

Implemented:

- One editor-visible 3D garden with a decorative pond, rocks, plants, collisions, spawn markers, and camera viewpoints.
- Four geometric placeholder pixies representing Earth, Fire, Wind, and Water.
- Independent wandering, idling, and gentle hovering.
- Three fixed camera viewpoints and pause/resume controls.
- Separate simulation state and visual presentation.

The current build tests the feel of observing a small inhabited space. Creature care, social interactions, evolution, saving, and the illustrated pixie sprites are not implemented yet. The pond is visual scenery; pixies can move across it.

## Run the project

Requirements: **Godot 4.7 standard edition**, using GDScript and the Compatibility renderer. No .NET SDK or third-party plugins are needed. The foundation was checked with Godot 4.7 on Windows.

1. Clone or download this repository.
2. Open Godot's Project Manager and import the `project.godot` file at the repository root.
3. Open the project and press **F5**.
4. Use **Pause / resume** and **Change viewpoint** in the on-screen panel.

Open `scenes/garden.tscn` to inspect and edit the complete garden layout. The UI and pixy placeholder are reusable child scenes.

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
| `scenes/garden_ui.tscn` | Reusable editor-authored interface |
| `scenes/pixy_placeholder.tscn` | Reusable temporary pixy visual |
| `scripts/garden.gd` | Fixed-step scheduling and scene/simulation coordination |
| `scripts/garden_ui.gd` | UI signals and status presentation |
| `scripts/garden_simulation.gd` | Seeded movement and idle rules |
| `scripts/pixy_state.gd` | Each pixie's identity, location, and movement state |
| `scripts/pixy_view.gd` | Temporary geometry, labels, and cosmetic hovering |
| `scripts/verify_simulation.gd` | Headless simulation contract checks |

## Checks

Run these commands from the repository root with Godot on PATH:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 180
godot --headless --path . --script res://scripts/verify_simulation.gd
```

The simulation check covers movement bounds, same-seed reproducibility, and individual-state isolation across 18,000 ticks. Import and runtime checks passed without script errors in the initial tool environment, which also emitted a system certificate-store warning. The prototype uses no network services.

Visual appearance and button interaction still require a desktop playtest; headless checks do not validate rendering.

## Project documentation

- [PROJECT.md](PROJECT.md) — vision, scope, and creative direction.
- [DESIGN.md](DESIGN.md) — implemented mechanics and proposed experiments.
- [TASKS.md](TASKS.md) — development batches, validation, and playtest observations.
- [DOCUMENTATION.md](DOCUMENTATION.md) — current architecture, ownership, data flow, and extension points.
- [AGENTS.md](AGENTS.md) — working instructions for coding assistants.
