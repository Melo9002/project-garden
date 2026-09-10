# Roadmap

- Batch 001: runnable editor-visible diorama, reusable UI and pixy scenes, authored camera/spawn markers, separate individual state and seeded wandering, documentation. Implemented; validation below and human visual playtest pending.
- Batch 002: approved 2D placeholder sprite integration; individual selection/inspection; verify readability and grounding.
- Batch 003: care controls plus visible environmental and social responses, four emotes and one friendly interaction.
- Batch 004: shared pupal stage, one development milestone and save/load.
- Batch 005: playtest adjustments, Pedro's replacement art, export verification. Publication separately authorized.
- Later: second location to validate architecture, planets; possible v0.2 ship assistant.

## Experiment 001
Hypothesis: a small quiet diorama with independently moving inhabitants is pleasant to observe for a few minutes.
Observe: camera framing, movement speed, useful idle durations and whether creatures remain distinguishable. Results pending Pedro's playtest.

## Experiment 002 (planned)
Hypothesis: expressions plus subsequent behavior let Pedro identify whether a creature welcomed an environmental or social event without inspecting numerical stats.

## Batch 001 validation
Godot 4.7 imported the project and ran 180 headless frames without script errors. A separate simulation check passed 18,000 ticks (ten simulated minutes): bounds, equal-seed reproducibility and independent individual state. Tool environment emitted a certificate-store warning; no network functionality is used. Visual playtest remains pending.

## Editor-first refactor
Static runtime construction was removed. Terrain, pond, decorations, collisions, an interactables container, spawn markers, lighting and camera viewpoints now live in `garden.tscn`. UI and placeholder visuals are reusable scenes. Runtime instantiation remains only for simulated inhabitants. Preserve this authored-content boundary in future work.
