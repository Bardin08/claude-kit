# Generate Task Command

Create a project-specific `/task` command that encodes the project's stack, task tracking
system, architecture, and conventions so the user doesn't have to explain them every time.

## Inputs available in your Task prompt

- Full detection summary (stack, architecture, layers, build/test/lint, conventions)
- Task tracking details (file location, naming format, or external tool + MCP)
- Template file path to read
- **SKILL_BASE** — the resolved path to the plugin's skills directory

## Instructions

1. Read the template at `SKILL_BASE/establish-project/assets/templates/task-command-template.md`
   (replace `SKILL_BASE` with the actual path provided in the Task prompt)
2. Replace every `{PLACEHOLDER}` with the actual detected value
3. Resolve all `{IF}` / `{ELSE}` / `{ELSE IF}` / `{END IF}` control flow:
   - Evaluate each condition against the detection data
   - Keep only the matching branch
   - Remove the control flow markers entirely
4. Write the result to the target path provided in the Task prompt

## Quality checks

- The output must be valid markdown with proper YAML frontmatter
- No template syntax (`{PLACEHOLDER}`, `{IF}`, etc.) should remain
- The command must be self-contained — no references back to otto-kit
- All commands must be actual commands for this project, not generic examples
- The description must mention the project name
