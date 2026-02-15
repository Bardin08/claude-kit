# Generate Plan Command

Create a project-specific `/plan` command that encodes the project's architecture, tracker adapter,
and conventions so the user gets a tuned planning workflow.

## Inputs available in your Task prompt

- Full detection summary (stack, architecture, layers, build/test/lint, conventions)
- Tracker adapter name (e.g., `gh-plan`, `local-plan`) or `none`
- Tracker configuration (project number, task directory path, etc.)
- Architecture layers detected
- Template file path to read
- **SKILL_BASE** — the resolved path to the plugin's skills directory

## Instructions

1. Read the template at `SKILL_BASE/establish-project/assets/templates/plan-command-template.md`
   (replace `SKILL_BASE` with the actual path provided in the Task prompt)
2. Replace every `{PLACEHOLDER}` with the actual detected value:

### Placeholder mapping

| Placeholder | Source |
|---|---|
| `{PROJECT_NAME}` | Project directory name or repo name |
| `{PLAN_DIR}` | Always `.claude/plans` (relative to project root) |
| `{SKILL_BASE}` | The resolved SKILL_BASE path from the Task prompt — embed the actual path value |
| `{TRACKER_SKILL}` | Adapter name: `gh-plan`, `local-plan`, or empty |
| `{TRACKER_CONFIG}` | Adapter-specific config passed to the sub-agent (see below) |
| `{ARCHITECTURE_LAYERS}` | Comma-separated list of detected layers (e.g., "Api, Application, Domain, Infrastructure") |

### Tracker config by adapter type

**gh-plan**:
- `PLAN_FILE: <path>` — filled at runtime, use `{PLAN_FILE}` in template
- `PROJECT_NUMBER: <N>` — the GitHub Project number if provided, omit line if not

**local-plan**:
- `PLAN_FILE: <path>` — filled at runtime, use `{PLAN_FILE}` in template
- `TASK_DIR: <path>` — the task directory path (e.g., `docs/tasks`)

**none**:
- Remove the entire sync phase from the output

3. Resolve all `{IF}` / `{ELSE}` / `{ELSE IF}` / `{END IF}` control flow:
   - `{IF HAS_TRACKER}` — true if a tracker adapter was selected
   - `{IF TRACKER_IS_GH}` — true if adapter is `gh-plan`
   - `{IF TRACKER_IS_LOCAL}` — true if adapter is `local-plan`
   - Evaluate each condition against the detection data
   - Keep only the matching branch
   - Remove the control flow markers entirely

4. Write the result to the target path provided in the Task prompt

## Quality checks

- The output must be valid markdown with proper YAML frontmatter
- No template syntax (`{PLACEHOLDER}`, `{IF}`, etc.) should remain
- The command must be self-contained — no references back to otto-kit
- All layer names must be actual layers from this project
- The description must mention the project name
- All `SKILL_BASE` references must be replaced with the actual resolved path (not the variable name)
