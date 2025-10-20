# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.0] - 2025-10-20
### Added
- **Linux & macOS Support**: Created parallel Bash scripts (`install.sh`, `init_project.sh`) to provide full functionality on Unix-like systems.
- New documentation for multi-OS support design and Docker usage for testing.
- The `init_project` scripts now generate a `NEXT_STEPS.md` file to guide the user's first interaction with the AI.

### Changed
- **Major**: The project is now cross-platform.
- The `README.md` has been updated with separate installation instructions for Windows and Linux/macOS.
- The `cinit` script now intelligently reuses existing values from `context.md` when run in an existing project.


## [0.1.0] - 2025-10-20
### Added
- Initial project scaffolding and `context_general.md`.
- `scripts/install.ps1` with idempotent install/update, alias, and PATH shim.
- `scripts/init_project.ps1` for interactive initialization.
- README with setup and usage instructions.

### Changed
- Installer writes to multiple PowerShell profiles for wider compatibility.

### Notes
- PATH-based shim `cinit.cmd` ensures command availability even when profiles do not load.
