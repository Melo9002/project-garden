# Roadmap

- Batch 001: runnable editor-visible diorama, reusable UI and pixy scenes, authored camera/spawn markers, separate individual state and seeded wandering, documentation. Implemented; validation below and human visual playtest pending.
- Camera/environment follow-up: implemented a smooth bounded side-scrolling perspective camera, keyboard and drag panning, wheel zoom, three quick stops, a camera-position strip, wider layered nature scenery, billboard pixy placeholders and authored future placement regions. GPU capture and headless checks passed; hands-on control feel still needs Pedro's playtest.
- Endless-map illusion follow-up: superseded visually by the lakeshore rework; its useful principle remains oversized authored terrain plus layered 2D perspective parallax. Keep procedural generation as a later experiment after this map is validated.
- Batch 002: 2D placeholder sprite integration and individual selection/inspection implemented. Each pixy has a forgiving click volume, hover emphasis, selection ring, and a live inspector showing element, mood and activity. GPU layout and startup validation passed; Pedro's click/readability playtest remains.
- Batch 003: the care/social vertical slice now includes three persisted objects, whole-object red/green placement feedback, stable five-value personalities, personality-shaped needs/movement/item choices, one reciprocal friendly encounter and three-slot relationship memory. Save format 3 and the garden menu preserve this individuality. Still needed after playtesting: avoidant/negative reactions and richer encounters.
- Daily-life foundation: implemented energy, comfort and curiosity; derived qualitative moods; autonomous wandering, resting, water investigation and flower visits; persistent flower benefits; readable JSON save/load for pixies, flowers, time and RNG state. Validation passed; tuning and save/load interaction need Pedro's playtest. Offline elapsed-time simulation is intentionally deferred.
- Debug foundation: F3 opens the developer panel and pauses simulation. It exposes exact selected-pixy values, pause/1x/5x/30x simulation speed, a one-minute step, and low-energy/low-curiosity forcing for focused behavior tests. Elemental affinities and balancing remain the next separate task.
- Elemental foundation: implemented four per-pixy development values, four garden-development values, provisional first-clearing sources and scenario targets, affinity-based comfort, HUD progress, debug visibility and save/load. Source meanings and rates are intentionally unbalanced pending playtest.
- Element feedback: implemented a reusable billboard flare with chromatic fringe, rising streak, drift and fade. Pixies emit their strongest local exposure; lake/flowers emit occasional ambient motes. Spawn cadence uses real time and stays capped under debug acceleration. GPU sequence verified.
- Foundation follow-up: first-garden spatial rules now live in one editor-editable `GardenDefinition` resource shared by wandering, surface classification and placement. Contract checks cover meadow/water/outside classification and flower validity; do not generalize this into a location framework until a second map proves what must vary.
- Lakeshore rework: implemented a reachable foreground lake, irregular bank, textured meadow, side hills, reusable crossed-card pines, layered SVG forests/mountains, sky/fog and restrained water ripples. Water seeks the lake when comfort dips and plays there; surface-aware hovering and a ripple ring show occupancy. Old flowers overtaken by the new shore relocate onto dry ground on load without rewriting the save. Godot import, 18,000-tick regression, focused spatial/affinity/save-migration/camera tests and GPU center/edge captures passed. Pedro's hand-on camera/placement playtest remains; this is not final art or a procedural map.
- Individuality foundation: implemented personality generation/persistence, temperament labels, personality-shaped wandering and decay, friendly social visits, reciprocal capped bonds, a startup/save/load/new-game menu, mossy resting stones, wind chimes and full red illegal previews. Deterministic simulation and scene-level menu/placement/item checks pass; hands-on pacing and interaction readability remain to be playtested.
- Batch 004: shared pupal stage and one development milestone. Initial save/load is already implemented; extend its versioned data when development arrives.
- Batch 005: playtest adjustments, Pedro's replacement art, export verification. Publication separately authorized.
- Later: second location to validate architecture, planets; possible v0.2 ship assistant.

## Experiment 001
Hypothesis: a small quiet diorama with independently moving inhabitants is pleasant to observe for a few minutes.
Observe: camera framing, movement speed, useful idle durations and whether creatures remain distinguishable. Results pending Pedro's playtest.

## Experiment 002 (planned)
Hypothesis: expressions plus subsequent behavior let Pedro identify whether a creature welcomed an environmental or social event without inspecting numerical stats.

## Batch 001 validation
Godot 4.7.2 imported the project and ran 180 headless frames without script errors. A separate simulation check passed 18,000 ticks (ten simulated minutes): expanded bounds, equal-seed reproducibility and independent individual state. A real NVIDIA/OpenGL frame capture also completed successfully. Hands-on camera feel and interaction still require Pedro's playtest.

## Editor-first refactor
Static runtime construction was removed. Garden composition, reusable scenery/items, collision references, spawns, lighting and camera remain editor-visible scenes. Runtime instantiation is limited to active inhabitants, placed item instances and transient effects. Preserve this authored-content boundary.
