# PR Review

Review pull requests against project standards.

## Before reviewing

1. Read AGENTS.md or CLAUDE.md for project conventions if they exist
2. Run the project's build command to verify the build
3. Run the project's test command to verify tests pass

## Review checklist

### 1. Code style compliance

- Follows conventions from project documentation
- Consistent with existing patterns in the codebase
- Run linter if available

### 2. Architecture alignment

- Changes are in the correct area of the codebase
- Dependencies flow in the right direction
- New files are in expected directories

### 3. Test coverage

- New/changed code has corresponding tests
- Tests follow existing test patterns
- Test suite passes

### 4. Build verification

- Build passes
- No new warnings introduced

### 5. Commit quality

- Follows the project's commit message convention
- Atomic commits (one concern per commit)

## Output

Present findings as:

- **Blocking**: issues that must be fixed
- **Suggestions**: improvements that aren't blockers
- **Approved**: explicit statement if everything passes

> **Note**: Run `/otto-kit:establish-project` to generate a PR review agent tuned to your project's specific
> conventions, build commands, and architecture.
