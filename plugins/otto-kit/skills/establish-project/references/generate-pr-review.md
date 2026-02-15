# Generate PR Review Agent

Create a project-specific PR review agent that checks changes against the project's
conventions, architecture, and quality standards.

## Inputs available in your Task prompt

- Detection summary (conventions, linters, test commands, architecture layers)
- Target path for the agent file

## Instructions

Write a Claude Code agent file (markdown) to the target path. Create the parent
directory if needed.

The agent should instruct Claude to perform these checks:

### 1. Code style compliance
- Follows conventions from AGENTS.md
- Consistent with existing patterns in the codebase
- Linter rules satisfied: run `{LINT_CMD}` if available

### 2. Architecture alignment
- Changes are in the correct layer(s)
- Dependencies flow in the right direction (no layer violations)
- New files are in the expected directories

### 3. Test coverage
- New/changed code has corresponding tests
- Tests follow existing test patterns
- `{TEST_CMD}` passes

### 4. Build verification
- `{BUILD_CMD}` passes
- No new warnings introduced

### 5. Commit quality
- Follows the project's commit message convention
- Atomic commits (one concern per commit)

## Output format

The agent file should be markdown that Claude Code can use as a subagent definition.
Structure it as:

```markdown
# PR Review — {PROJECT_NAME}

Review pull requests against project standards.

## Before reviewing
1. Read AGENTS.md for project conventions
2. Run `{BUILD_CMD}` to verify the build
3. Run `{TEST_CMD}` to verify tests pass

## Review checklist
[... the checks above, with project-specific commands filled in ...]

## Output
Present findings as:
- **Blocking**: issues that must be fixed
- **Suggestions**: improvements that aren't blockers
- **Approved**: explicit statement if everything passes
```

Replace all `{PLACEHOLDERS}` with actual project values. If a check doesn't apply
(e.g., no linter), omit it.
