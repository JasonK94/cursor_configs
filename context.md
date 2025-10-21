# Project-Specific Context for `cursor_configs`

## Primary Goal
The goal of this meta-project is to build and maintain a standardized, efficient, and evolving framework for initiating and executing software projects with an AI pair programmer. This framework is managed through a set of version-controlled scripts and templates, primarily centered around the `cinit` command.

## AI Model
Gemini 2.5 Pro (or the latest powerful model available via Cursor)

## References
- This project's own `README.md` for user-facing documentation.
- The `docs/` directory for detailed design documents.
- The `DEVLOG.md` and `CHANGELOG.md` for project history.

---

## Development Conventions

This project adheres to the following conventions. All AI assistants must follow them.

1.  **Conventional Commits**: All commit messages must follow the [Conventional Commits specification](https://www.conventionalcommits.org/). This is critical for automated versioning and changelog generation.
    -   Use prefixes like `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `build:`, `ci:`.
    -   Use `!` after the type/scope for breaking changes (e.g., `feat(api)!:`).

2.  **Semantic Versioning**: The project's version number, defined in `CHANGELOG.md`, follows [Semantic Versioning 2.0.0](https://semver.org/).
    -   `fix:` commits correspond to `PATCH` version bumps.
    -   `feat:` commits correspond to `MINOR` version bumps.
    -   Commits with `BREAKING CHANGE` in the body or `!` in the header correspond to `MAJOR` version bumps.

3.  **Keep a Changelog**: The `CHANGELOG.md` file must be kept in the format defined by [Keep a Changelog](https://keepachangelog.com/).

4.  **PowerShell Command Chaining**: Do not chain commands using `&&` in `run_terminal_cmd` when the shell is PowerShell. Execute commands one by one to avoid parsing errors. This is a critical environmental constraint.

This is the Single Source of Truth for any AI assistant working on the `cursor_configs` repository itself. The base template for this file's structure can be found in `templates/context.md.template`.
