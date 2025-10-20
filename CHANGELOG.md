# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
