# Security baseline

## Repository posture

This public repository contains game source and original project assets only. It must not contain production credentials, private customer information, proprietary engineering data, or copied commercial game assets.

## Development rules

- Keep credentials outside the repository and outside Godot resources.
- Treat imported scenes, addons, models, fonts, audio, and build tools as executable or supply-chain-sensitive input.
- Do not add runtime networking, telemetry, file upload, shell execution, native extensions, or arbitrary mod loading without a reviewed design.
- Pin GitHub Actions to full commit hashes and give each workflow the minimum token permissions it needs.
- Review automated dependency updates before merging.
- Report suspected vulnerabilities privately using the process in `.github/SECURITY.md`.

## GitHub controls

The intended baseline is:

- public secret scanning and push protection;
- dependency graph, Dependabot alerts, security updates, and version updates for GitHub Actions;
- dependency review on pull requests;
- private vulnerability reporting;
- an active default-branch ruleset that blocks force pushes and deletion and requires pull requests;
- CodeQL only when the repository contains a CodeQL-supported language.

GDScript is not a CodeQL-supported language, so enabling CodeQL would not analyze the game source. This limitation must be revisited if a supported language such as C++, C#, JavaScript/TypeScript, Python, or Rust is added.
