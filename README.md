# Dust Rush: Industrial Tycoon

Dust Rush is a compact Godot 2D industrial-management game: solve dust-collection jobs, improve the factory, and get as far as possible before a ten-minute clock expires.

This repository is the secure proof-of-concept scaffold. It currently opens to the cabinet-shop design screen, where the ten-minute clock runs and the player can inspect the three shop machines, choose a collector, choose a route per machine, watch the isometric duct network appear, read a live proposal review, and open **Show the math** for the airflow behind it. Committing the proposal, installation, and scoring are **not** implemented yet.

## Start here

1. Install [Godot 4.7.1](https://godotengine.org/download/archive/4.7.1-stable/) or a newer 4.7 patch release.
2. Import `project.godot` from the Godot project manager.
3. Run the project with **F6/F5**.

For command-line verification:

```sh
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 3
godot --headless --path . -s res://tests/test_proposal.gd
godot --headless --path . -s res://tests/test_duct_engineering.gd
godot --headless --path . -s res://tests/test_design_screen.gd
```

The three test commands run the deterministic gameplay, engineering, and design-screen
checks. Each exits non-zero on failure. Note that the runtime check above exits 0 even
when a script error is printed, so read its output rather than trusting its exit code.

## Direction

- [Game vision](docs/GAME_VISION.md)
- [First proof-of-concept slice](docs/GAME_DESIGN.md)
- [Verified engineering layer](docs/ENGINEERING_MODEL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security baseline](docs/SECURITY_BASELINE.md)
- [Claude Code working agreement](CLAUDE.md)
- [Contributing](CONTRIBUTING.md)
- [Security reports](.github/SECURITY.md)

Read `CLAUDE.md`, `AGENTS.md`, and `docs/GAME_VISION.md` before implementation. Keep the first change narrow: one customer, three machines, three collector choices, simple route decisions, visible results, scoring, and instant restart.

## Repository security

The repository uses GitHub secret protection, dependency monitoring, dependency review, private vulnerability reporting, pinned Actions, and protected pull-request flow. See [GitHub security status](docs/GITHUB_SECURITY.md) for the verified controls and known platform limitations.

## License

No open-source license has been selected yet. The code is publicly visible, but no permission to copy, modify, or redistribute it is granted until the owner chooses a license.
