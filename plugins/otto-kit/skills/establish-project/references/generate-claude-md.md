# Generate CLAUDE.md

Claude Code uses CLAUDE.md as its native memory file. Since the project's conventions
live in AGENTS.md (which CC doesn't read automatically), CLAUDE.md bridges the gap
by referencing AGENTS.md and providing a quick-reference summary.

## Inputs available in your Task prompt

- Project name
- Tech stack summary
- Build, test, lint commands

## Instructions

Write a CLAUDE.md to the target path with this structure:

```markdown
# {PROJECT_NAME}

Read [AGENTS.md](./AGENTS.md) for complete project context, conventions, and guidelines.
All AI coding agents working on this project should follow the standards defined there.

## Quick Reference

- **Stack**: {STACK_SUMMARY}
- **Build**: `{BUILD_CMD}`
- **Test**: `{TEST_CMD}`
- **Lint**: `{LINT_CMD}`
```

Replace all `{PLACEHOLDERS}` with actual values. If a command doesn't apply (e.g., no
lint for the stack), omit that line.

Keep it minimal. The point is to redirect to AGENTS.md, not duplicate it.
