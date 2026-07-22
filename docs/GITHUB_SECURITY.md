# GitHub security status

Verified on 2026-07-21 against `Sur-92/dust-rush-industrial-tycoon`.

## Enabled and verified

- The repository is public and the default branch is `main`.
- Secret scanning and push protection are enabled.
- The dependency graph and Dependabot alerts are enabled.
- Dependabot security updates are enabled and not paused.
- Dependabot checks weekly for GitHub Actions version updates.
- Pull requests run dependency review and fail for vulnerabilities of moderate severity or higher.
- Private vulnerability reporting is enabled and `.github/SECURITY.md` is published.
- CodeQL default setup uses the extended query suite to analyze GitHub Actions workflow files.
- The `Protect main` ruleset is active with no bypass actors.

The ruleset requires:

- all changes to arrive through pull requests;
- review conversations to be resolved;
- squash-only, linear history;
- the branch to be current before merge;
- `Validate Godot project` and `Dependency review` checks to pass;
- CodeQL to report no high-or-higher security alerts or error-level quality alerts;
- no force pushes or deletion of `main`.

GitHub Actions are pinned to full commit hashes and run with read-only repository permissions. The Godot workflow downloads the official 4.7.1 Linux binary and verifies its SHA-512 checksum before use.

## Platform and language limitations

- GitHub reports that Advanced Security is always available for public repositories, so its umbrella switch cannot be toggled through the repository API.
- CodeQL supports the repository's GitHub Actions workflows but does not support GDScript. Game scripts therefore receive Godot load/runtime validation, dependency controls, and secret scanning—not CodeQL semantic analysis.
- Non-provider secret patterns and validity checks remain unavailable on this user-owned public repository. GitHub documents those controls for organization-owned repositories with GitHub Secret Protection.
- The repository API did not expose a verifiable AI-detected-secrets status for this account/repository, so it is not represented as enabled.
- No Godot addon/package manager is present. Dependency review currently covers GitHub Actions; revisit dependency coverage before adding an addon or native extension.

These limitations should be rechecked if the repository moves to an eligible organization plan or adds a CodeQL-supported game language.
