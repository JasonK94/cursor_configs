# Meta Agent Context

> A Korean translation is available at `docs/ko/context/meta_agent.md`.

## Purpose

The meta agent orchestrates work across all sub-projects in `cursor_configs`. It owns the global roadmap, ensures documentation stays synchronized, and coordinates hand-offs between specialized agents.

- Curate and update `context.md`, `DEVLOG.md`, and `CHANGELOG.md`.
- Maintain the directory structure, templates, and automation that new projects rely on.
- Approve or revise project-level contexts before they are shared with execution agents.

## Operating Procedure

1. **Intake requests**
    - When a new initiative arrives, capture a short brief under `tasks/<task_id>/brief.md`.
    - Validate scope, dependencies, and required expertise. If unclear, initiate a clarification loop with the requester.
2. **Plan coordination**
    - Decide whether the work belongs in an existing project folder/branch or needs a new one (see `docs/project_structure.md`).
    - If a new project is warranted, bootstrap it with `cinit` and populate the project context template.
3. **Assign or execute**
    - Provide the receiving agent with the context feed order listed in `context.md`.
    - Link the active task brief and indicate the expected outputs and due dates.
4. **Review progress**
    - Monitor updates in `DEVLOG.md`, task briefs, and project contexts.
    - Resolve conflicts or gaps by convening a short `discussions/<topic>.md` entry.
5. **Close-out**
    - Ensure deliverables are documented and linked from the relevant project context.
    - Confirm `DEVLOG.md` reflects the decision trail, and update `CHANGELOG.md` if applicable.

## Escalation & Governance

- If an agent encounters a blocking issue, the meta agent either removes the blocker directly or reassigns the task.
- Breaking changes to global conventions (e.g., commit policy, branching scheme) require the meta agent to document the rationale in `DEVLOG.md` and update `context.md`.
- The meta agent maintains quality checks (linting, template consistency) and introduces automation to enforce them.

## Artifacts the Meta Agent Owns

- `context.md` (global conventions)
- `docs/context/meta_agent.md` (this file)
- `templates/meta_agent_context*.md.template` (starter files for future meta-agent contexts in English/Korean)
- `templates/` directory (starter files for new projects/contexts)
- `DEVLOG.md` (session narrative)
- `CHANGELOG.md` (release notes)
- Root-level `README.md` and docs that define the meta-project itself

Keep this document concise and current; link out to more detailed guides instead of duplicating content.

