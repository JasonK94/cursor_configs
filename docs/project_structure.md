# Documentation Structure: Model vs. Project

This document clarifies how the `cursor_configs` repository is organized and how the generated project artifacts differ from the model documents that live here. A Korean translation is available in `docs/ko/project_structure.md`.

## 1. Model Documents (inside `cursor_configs`)

These files establish the default process for every Cursor-led project. You interact with them when improving the meta framework itself.

- **Location**: The cloned `cursor_configs` repository (default `~/.cursor_configs` after running `install`).
- **Purpose**: Serve as reusable, version-controlled blueprints. Updating them changes the defaults for all future projects.
- **Examples**:
  - `context.md`: Repository-wide conventions and multi-agent hierarchy.
  - `docs/`: Guides such as `cursor_workflow.md`, `multi_os_support.md`, and their Korean counterparts under `docs/ko/`.
  - `docs/context/meta_agent.md`: Responsibilities of the coordinating meta agent.
- `templates/`: Markdown templates copied by `cinit` (now provided in English and Korean variants), including `cursor_configs_context*.md.template` for the repository meta-context.
  - `scripts/`: Tooling that provides `cinit` (project init) and `cupdate` (framework update).
- **How to Modify**: Only change these files to improve the standard process for *future* projects. Document decisions in `DEVLOG.md` (and optionally `DEVLOG_KO.md`) and summarize releases in `CHANGELOG.md`.

## 2. Project Documents (generated per project)

When you run `cinit` inside a new project folder, the tool copies relevant templates, personalizes them, and asks for language preference.

- **Location**: The root directory of the project you are building (e.g., `~/projects/amazon_scraper`).
- **Purpose**: Capture the unique goals, scope, and evolving context of that single project. They are the primary source of truth for agents working on the project.
- **Examples**:
- `context.md`: Generated from `templates/cursor_configs_context*.md.template`; includes project goal, AI model, references.
  - `project_context.md`: Optional narrative status file created from `templates/project_context*.md.template`.
  - `DEVLOG.md` / `CHANGELOG.md`: Project-specific logs copied from the matching templates and maintained locally.
  - `README.md` / `README_Korean.md`: Selected based on the language option you choose during `cinit`.
- **How to Modify**:
  - Update these files freely as the project evolves—add decisions, adjust constraints, log work.
  - They are independent from the model documents; editing them does **not** affect the templates in `cursor_configs`.
  - Re-run `cinit` if you need to regenerate missing files; the script will preserve existing content and only add what is absent.

## 3. Keeping Your Local Framework Updated

- `cupdate`: Pulls the latest `cursor_configs` repository into `~/.cursor_configs`.
- After running `cupdate`, existing projects continue to use their current files, but you can manually copy over new templates if desired.
- To start from scratch with the newest defaults, call `cinit` in a fresh directory and choose the appropriate language (1 = both, 2 = English only, 3 = Korean only).

## Summary Diagram

```
[cursor_configs Repo]                    [Your Project Repo]
---------------------                    --------------------
- docs/ (guides)                         - context.md (per-project)
- docs/ko/ (Korean guides)               - project_context.md (optional)
- templates/ (en & ko)   --cinit-->      - README(.md / _Korean.md)
- scripts/ (cinit, cupdate)              - DEVLOG(.md) / CHANGELOG(.md)
```
