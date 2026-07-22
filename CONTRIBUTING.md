# Contributing

Thanks for helping build Dust Rush.

## Before coding

1. Read `AGENTS.md` and every file in `docs/`.
2. Use or create a small issue with one observable player outcome.
3. Discuss any new dependency, plugin, service, platform-specific path, or scope expansion before implementation.

## Change flow

1. Create a branch from `main`.
2. Keep the change focused and free of generated `.godot/` data or exports.
3. Run the headless editor load and short runtime check documented in `README.md`.
4. Open a pull request and complete the template.
5. Resolve review conversations and security/dependency findings before merge.

Do not commit credentials, customer information, copied commercial assets, or unreviewed third-party packages. Use original placeholder art until an asset's provenance and license are recorded.

## Commit and review quality

- Explain the player-visible result.
- State the exact checks run and any checks that remain unavailable.
- Keep refactors separate from feature changes where practical.
- Do not claim a playable slice from a project-load or structure check alone.
