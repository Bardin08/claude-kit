---
name: plan-reference
description: Reference documentation for the planning system — plan file format specification, complexity assessment, and planning frameworks. Not user-invocable.
user-invocable: false
---

# Planning System Reference

Core reference for the `/plan` command and its tracker adapters. This file defines the contract between plan generation and sync adapters.

## Plan File Format

Plan files are markdown with YAML frontmatter. They live in `{PROJECT_ROOT}/.claude/plans/` and are the contract between `/plan` and tracker adapters (`gh-plan`, `local-plan`, etc.).

### Simple Task

A task that can be implemented in a single focused session without architectural decisions.
Sections: Problem, Desired Outcome, Constraints, Scope (P0/P1/Out of Scope), Acceptance Criteria.

Template: see `assets/simple-plan-template.md` in this skill's directory.

### Complex Task

A feature requiring multiple implementation steps, architectural decisions, or coordination across layers. Produces two artifacts:

1. **Epic file** (`<feature-slug>.md`) — high-level: problem, outcome, architecture decisions, task summary table, build order.
2. **Task directory** (`<feature-slug>/`) — one detailed file per task with objective, approach, files to create/modify, and acceptance criteria.

```
.claude/plans/
├── 2fa-authentication.md              ← epic
└── 2fa-authentication/
    ├── 01-okta-sdk-setup.md           ← detailed task
    ├── 02-keychain-service.md
    ├── 03-okta-auth-service.md
    └── ...
```

Adapters treat the epic file as the parent issue and each task file as a sub-issue — one nesting level.

Templates:
- Epic: see `assets/complex-plan-template.md` in this skill's directory.
- Task: see `assets/complex-task-template.md` in this skill's directory.

## Complexity Assessment

Evaluate the feature request against these heuristics. If **any** complex indicator is true, classify as `complex`.

### Simple indicators
- Single area of the codebase affected
- No architectural decisions needed — the pattern already exists
- No new dependencies or integrations
- Can be described with one user story
- Implementation path is obvious to someone familiar with the codebase

### Complex indicators
- Multiple layers or modules affected (e.g., API + database + UI)
- Requires a new pattern, abstraction, or integration
- Multiple user stories or personas involved
- Has ordering constraints — some work must finish before other work can start
- Requires data migration, schema changes, or breaking API changes
- Needs coordination with external systems or teams

When in doubt, lean toward `complex`. A complex plan that turns out simple is harmless; a simple plan that misses tasks causes rework.

## Planning Frameworks

### Brief format (simple tasks)

1. **State the problem** — not the solution. "Users can't X" not "Add a Y button."
2. **Define the outcome** — observable behavior, not implementation details.
3. **List constraints** — what limits the solution space.
4. **Scope ruthlessly** — P0 is the minimum that solves the core problem. Everything else is P1 or out of scope.
5. **Write testable acceptance criteria** — each one answers "how do I verify this works?"

### Decomposition format (complex tasks)

1. **State the problem and outcome** — same as brief.
2. **Identify decision points** — where does the implementation fork? Document each decision with rationale.
3. **Break into tasks** — each task is independently implementable and testable. A task should be completable in one `/task` session.
4. **Write detailed task files** — for each task, create a file in the task subdirectory with objective, approach (files to create/modify, patterns to follow, key APIs), and acceptance criteria. The task file should give `/task` enough context to skip investigation and go straight to planning.
5. **Assign priorities** — P0 tasks form the minimum viable implementation. P1 tasks improve it.
6. **Map dependencies** — which tasks block others? Draw the build order.
7. **Verify coverage** — walk the acceptance criteria. Every criterion should map to at least one task.
