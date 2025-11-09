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

5.  **Conversation Context Management**: At the end of a significant task or decision-making process, summarize the key points of the conversation and record them in `DEVLOG.md`. This ensures that important context is not lost when the conversation window is cleared.

This is the Single Source of Truth for any AI assistant working on the `cursor_configs` repository itself. The base template for this file's structure can be found in `templates/cursor_configs_context.md.template`.

---

## Context Hierarchy & Roles

Multiple agents may collaborate on this repository. To keep contexts portable (drag-and-drop friendly) while avoiding duplication, adhere to this layered model:

1. **Meta Agent Context** — `docs/context/meta_agent.md`
    - Describes how the meta agent coordinates projects, assigns tasks, and curates shared knowledge (e.g., `context.md`, `DEVLOG.md`, `CHANGELOG.md`).
    - Must be reviewed before assigning or reassigning work to other agents.
2. **Project Contexts** — `projects/<project_name>/context.md` (or another path documented in `docs/project_structure.md`)
    - Each active sub-project maintains its own context file, summarizing goals, constraints, dependencies, and current status.
    - When branching, prefer `proj/<project_name>` as the base branch name; agent-specific experiments should nest under it (`chore/<project>/<agent>/<topic>`).
3. **Agent-Specific Notes (Optional)** — `docs/context/agent_<handle>.md`
    - Captures working style, shortcuts, or personal TODOs for a given agent.
    - Reference from project contexts only when those notes affect execution.

**Feeding order when spinning up a new agent**

1. `context.md` (this file)
2. `docs/context/meta_agent.md`
3. Relevant project context(s)
4. Latest entries in `DEVLOG.md` and `CHANGELOG.md`
5. Any task briefs under `tasks/<task_id>/`

Keep each file scoped to its layer—avoid repeating the same instruction across layers. When a layer changes, update higher layers with a link rather than duplicating content.
If a collaborator prefers Korean materials, provide the paired files (for example `context_Korean.md`, `README_Korean.md`, `DEVLOG_Korean.md`) alongside their English counterparts.

---

## Logging & Hand-off Protocol

- Significant decisions, blocked states, and hand-offs must be recorded in `DEVLOG.md` with cross-links to project contexts or task briefs.
- For live collaboration, capture questions and resolutions in `discussions/<topic>.md`, then summarize the outcome in the relevant context file.
- Before finishing a task, update the associated project context to reflect the new state and list any open follow-ups.