# Cursor Collaboration Workflow

> Korean translation: `docs/ko/cursor_workflow.md`

This guide explains how to launch a new Cursor-driven development effort after running `cinit`. Share it with both human collaborators and AI agents.

## 1. Quick Start (5-minute setup)

1. **Review generated files**
    - `context.md` (global conventions)
    - Project-specific context under `projects/<project_name>/context.md` (if already created)
    - `DEVLOG.md`, `CHANGELOG.md`, and any `tasks/` briefs
    - Language-specific artifacts (`README.md`, `README_Korean.md`, etc.) based on the option selected during `cinit`
2. **Prepare the initial prompt**
    - Drag-and-drop files in the order defined in `context.md` → *Context Hierarchy & Roles*.
    - Include the current TODO list or task brief.
3. **Confirm the plan**
    - Ask the agent to summarize its understanding and proposed steps.
    - Record the session start in `DEVLOG.md`.

## 2. Detailed Manual

### 2.1 Bootstrap

1. Run `cinit` (or project-specific initializer).
2. When prompted, choose the documentation language: `1 = both`, `2 = English only`, `3 = Korean only`.
3. Review templates in `templates/` and copy the relevant ones into the project (README, context, task brief) if additional files are needed.
4. Populate metadata (project name, scope, milestones) before handing off to another agent.
- `cupdate`: Refreshes the local `cursor_configs` framework (`~/.cursor_configs`). Run this before important work to ensure you have the latest templates and scripts.

### 2.2 Provide Context to Agents

1. Follow the feed order (root context → meta agent context → project context → logs → task briefs).
2. Optionally add domain-specific docs (designs, APIs) **after** the mandatory set.
3. Make sure each file contains up-to-date information; update before sharing if needed.

### 2.3 Work Execution

1. The agent creates a TODO plan (unless trivial) and shares it for confirmation.
2. Implementation proceeds in small, reviewable steps with frequent summaries.
3. After major milestones, the agent updates:
    - `DEVLOG.md` with decisions, blockers, next steps.
    - Project context with new status or constraints.
    - `CHANGELOG.md` when user-visible behaviour changes.

### 2.4 Handoff & Closure

1. Before ending a session, the agent posts a status update in the relevant task brief.
2. If work is incomplete, list remaining steps and risks.
3. Human collaborator reviews changes, runs tests, and merges according to repo policy.

## 3. Roles & Responsibilities

- **Meta Agent**: Owns repository-wide conventions (`context.md`, `DEVLOG.md`, templates).
- **Project Agent(s)**: Execute scoped tasks within a project; maintain project context accuracy.
- **Human Maintainer**: Validates outputs, approves merges, ensures operational quality.

## 4. Tips for Smooth Collaboration

- Keep docs concise and link out instead of duplicating.
- Use consistent branch naming (`proj/<project>` and `chore/<project>/<agent>/<topic>`).
- Automate recurring checks (lint, format, template validation) wherever possible.

Keep this document updated as the workflow evolves. Note major revisions in `DEVLOG.md`.

