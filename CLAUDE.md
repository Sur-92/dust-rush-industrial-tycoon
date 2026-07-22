# Claude Code working agreement

Claude Code implements small, approved Dust Rush tickets. The product direction belongs to `docs/GAME_VISION.md`; do not invent a broader game while completing a ticket.

## Read before every task

1. `AGENTS.md`
2. `docs/GAME_VISION.md`
3. `docs/ARCHITECTURE.md`
4. The ticket and any other document it explicitly names
5. `docs/SECURITY_BASELINE.md` when the change touches dependencies, files, networking, builds, imports, or external data
6. `docs/ENGINEERING_MODEL.md` when the change displays or calculates CFM, duct sizing, velocity, pressure, fan performance, or safety guidance

If these sources conflict, stop and describe the conflict before changing code. A ticket narrows the work; it does not silently rewrite the game vision or architecture.

## Implementation rules

- Work on one observable player outcome at a time.
- Start from current `main` on a focused branch; never push directly to protected `main`.
- Inspect the existing scene, script, resource, signal, and theme patterns before adding a new system.
- Use typed GDScript. Keep gameplay rules and state in scripts/resources rather than embedding them in presentation scenes.
- UI emits intent; gameplay code decides outcomes and updates state.
- Use simple original placeholders when final art is missing. Do not delay the playable loop for decorative art.
- Add no plugin, addon, native extension, service, telemetry, network access, or platform-specific path without approval.
- Do not add features just because they are realistic. Add only what strengthens a fast, legible ten-minute decision.
- Preserve unrelated changes and keep the diff limited to the ticket.

## Completion standard

Before reporting a ticket complete:

1. Load the project in the Godot 4.7.1 headless editor.
2. Run the short headless runtime check.
3. Run any focused test added for the changed gameplay rule.
4. Check the diff for generated files, credentials, private data, and unlicensed assets.
5. Open a pull request and wait for Godot validation, dependency review, and CodeQL workflow analysis.

Report the player-visible result, files changed, exact checks passed, and anything that remains unverified. A project-load check is not proof that the gameplay is fun or that a full run works.
