# Architecture

## Runtime

- Engine: Godot 4.7.1, standard build
- Language: typed GDScript
- Rendering: Godot 2D with a fixed, fake-isometric presentation
- Target platforms: macOS, Windows, Linux, and web where the same project remains compatible

Godot 4.7.1 is the baseline current stable patch when this repository was created. Avoid relying on unstable 4.8 features.

## Boundaries

- `scenes/` composes presentation and interaction nodes.
- `scripts/` owns gameplay state, timing, scoring, and orchestration.
- `data/` will hold typed `Resource` definitions for jobs, collectors, and machines.
- `assets/` holds original or properly licensed visual and audio source assets.
- `tests/` will hold deterministic gameplay tests as systems appear.

`docs/ENGINEERING_MODEL.md` owns the source hierarchy, formulas, units, scenario-input boundary, and safety limitations for any engineering detail shown to the player. Engineering inputs and coefficients belong in typed resources with provenance; deterministic scripts own calculations; scenes only present the resulting receipt.

Scenes may emit intent through signals, but should not become a second home for scoring or simulation rules. Scripts must not reach into unrelated scene internals when a signal or explicit method can define the boundary.

## Scaffold behavior

The initial scene proves only that the project opens and runs:

- a title and one-line product promise are visible;
- a ten-minute countdown begins automatically;
- pause/resume and restart controls work;
- no external asset or plugin is required.

This is an integration seam for Claude Code, not a claim that the gameplay slice is complete.

## Dependency policy

Prefer the engine and standard library. Any addon, native extension, action, or external service requires an issue explaining the need, license, maintenance state, permissions, and removal plan before it is added.
