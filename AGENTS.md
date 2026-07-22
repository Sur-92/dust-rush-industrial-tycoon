# Dust Rush contributor instructions

1. Read `docs/` before changing code; the documents there are authoritative.
2. Stop and report any conflict between documentation and implementation.
3. Keep the game cross-platform and compatible with Godot 4.7.1 or newer 4.7 patch releases.
4. Build the smallest playable ten-minute loop first; do not add tycoon systems without an approved ticket.
5. Keep gameplay rules in typed GDScript data and scripts, separate from presentation scenes and assets.
6. Reuse existing scenes, resources, signals, themes, and utilities instead of creating parallel systems.
7. Do not add plugins, network access, telemetry, native extensions, or platform-specific code without approval.
8. Match the documented clean, readable, fixed-isometric art and interface direction.
9. Never commit credentials, personal data, generated imports, build outputs, or unlicensed assets.
10. Keep changes small, run the documented checks, and state exactly what was verified.
