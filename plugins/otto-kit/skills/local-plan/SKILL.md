---
name: local-plan
description: Organize plan files into a local filesystem task directory with pending/in-progress/done status tracking. Used as a tracker adapter by /plan.
---

# Local Plan Adapter

Sync a plan file into a structured local task directory. This skill is invoked as a sub-agent by `/plan` — it is not user-invocable directly.

## Inputs (provided in sub-agent prompt)

- `PLAN_FILE`: absolute path to the plan file (epic for complex, single file for simple)
- `TASK_DIR`: base directory for tasks (e.g., `docs/tasks`)

For complex plans, a sibling directory with the same name (minus `.md`) contains detailed task files:
```
.claude/plans/2fa-authentication.md        ← PLAN_FILE (epic)
.claude/plans/2fa-authentication/           ← task directory
    01-okta-sdk-setup.md
    02-keychain-service.md
    ...
```

## Directory Structure

```
{TASK_DIR}/
├── INDEX.md
├── pending/
│   ├── TASK-001-login-redirect.md
│   └── TASK-002-auth-middleware.md
├── in-progress/
└── done/
```

## Workflow

### 1. Ensure directory structure exists

Create `{TASK_DIR}/pending/`, `{TASK_DIR}/in-progress/`, and `{TASK_DIR}/done/` if they don't exist.

### 2. Determine next task ID

Read `{TASK_DIR}/INDEX.md` if it exists. Find the highest `TASK-NNN` number. Next ID is that number + 1. If INDEX.md doesn't exist, start at `TASK-001`.

### 3. Parse the plan file

Read the plan file. Extract:
- `feature` from frontmatter — used as the display name
- `type` — `simple` or `complex`

For complex plans, derive the task directory: `${PLAN_FILE%.md}/` and list `*.md` files within it.

### 4. Create task files

**Simple plan**: Create a single task file.

- Filename: `TASK-<NNN>-<slugified-feature>.md` in `{TASK_DIR}/pending/`
- Content: the full plan file content (frontmatter + body), with an added `task_id` field in frontmatter

**Complex plan**: Create one epic file + one task file per file in the task directory.

- Epic file: `TASK-<NNN>-<slugified-feature>.md` in `{TASK_DIR}/pending/`
  - Contains: the plan file content (Problem, Desired Outcome, Architecture Decisions, Build Order, task checklist with assigned IDs)
- Sub-task files: `TASK-<NNN+1>-<slugified-task-title>.md`, `TASK-<NNN+2>-...`, etc. in `{TASK_DIR}/pending/`
  - Content: the corresponding task file content from the plan's task directory, with added frontmatter fields: `task_id: TASK-<NNN+X>`, `parent: TASK-<NNN>`

### 5. Update INDEX.md

Append entries to `{TASK_DIR}/INDEX.md`. Create the file if it doesn't exist.

Format:
```markdown
# Task Index

| ID | Feature | Type | Status | Created |
|----|---------|------|--------|---------|
| TASK-001 | Fix login redirect | simple | pending | 2026-02-14 |
| TASK-002 | User Authentication | complex/epic | pending | 2026-02-14 |
| TASK-003 | Auth middleware setup | complex/task | pending | 2026-02-14 |
| TASK-004 | Token validation | complex/task | pending | 2026-02-14 |
```

### 6. Move the plan files

Move (do not delete) the original plan file into `{TASK_DIR}/pending/` as the epic or single task file. The plan file IS the task — there's no separate tracker to sync to.

- **Simple**: move the plan file, renamed to `TASK-<NNN>-...md`.
- **Complex**: move the epic file (renamed to `TASK-<NNN>-...md`). Remove the plan's task directory after its contents have been used to create the sub-task files in step 4.

### 7. Report

Output a summary:
- Tasks created: list each `TASK-<NNN>` with title and status
- Index updated: `{TASK_DIR}/INDEX.md`
- Files location: `{TASK_DIR}/pending/`

## Task Lifecycle

Tasks move between directories to track status:

- `pending/` — not yet started
- `in-progress/` — actively being worked on (move here when starting `/task TASK-NNN`)
- `done/` — completed (move here after `/task` finishes and verification passes)

The `/task` command handles these moves automatically when configured with local task tracking.
