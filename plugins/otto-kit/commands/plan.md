---
description: Plan a feature — generic workflow. Run /otto-kit:establish-project for a version tuned to your project
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Task, AskUserQuestion
---

# Plan a Feature

The user provides a feature name or problem statement. Execute this workflow:

## Phase 1: Gather Requirements

1. Read the user's input. If it's a short name (e.g., "SSO support"), ask clarifying
   questions with AskUserQuestion:
   - What problem does this solve? Who is affected?
   - What does success look like?
   - Any known constraints (technical, timeline, compatibility)?
   - What is explicitly out of scope?

   If the user provided a detailed description, extract these answers from it and
   confirm your understanding.

2. Read AGENTS.md or CLAUDE.md if they exist — note architecture and conventions.
3. Run `git log --oneline -10` for recent context.

Do NOT use a subagent for this phase.

## Phase 2: Assess Complexity

Evaluate the feature against these heuristics:

**Simple** — all of these are true:
- Single area of the codebase affected
- No architectural decisions needed — pattern already exists
- No new dependencies or integrations
- One user story covers it
- Implementation path is obvious

**Complex** — any of these is true:
- Multiple layers or modules affected
- Requires a new pattern, abstraction, or integration
- Multiple user stories or personas
- Ordering constraints between tasks
- Data migration, schema changes, or breaking API changes
- External system coordination

When in doubt, choose complex. Present the assessment to the user and confirm.

## Phase 3: Generate Plan

### Simple tasks

Generate a plan file with these sections:
- **Problem**: what is broken or missing
- **Desired Outcome**: observable behavior after completion
- **Constraints**: technical limits, compatibility requirements
- **Scope**: P0 (must have), P1 (nice to have), Out of Scope
- **Acceptance Criteria**: testable checklist items

Write to `.claude/plans/<slugified-feature>.md`.

### Complex tasks

Spawn an Explore subagent (model: haiku) to investigate the affected areas:
- Find existing patterns in affected areas
- Identify key files and symbols
- Note test patterns

Generate a plan file with these sections:
- **Problem** and **Desired Outcome**
- **Architecture Decisions**: each decision with alternatives and rationale
- **Tasks**: numbered, each with brief, dependencies, and acceptance criteria
- **Build Order**: ASCII dependency graph

Break the feature into tasks where each task:
- Is independently implementable via `/task`
- Has clear acceptance criteria
- Lists dependencies on other tasks

Write to `.claude/plans/<slugified-feature>.md`.

### Review

Present the plan to the user. Ask for approval or modifications.
If they request changes, update the plan file and re-present.

## Phase 4: Next Steps

The plan file is saved at `.claude/plans/<feature>.md`.

Tell the user:
- For simple plans: run `/task` with the plan file to implement
- For complex plans: implement tasks in build order using `/task` for each

> **Tip**: Run `/otto-kit:establish-project` to generate a version
> of this command tuned to your project's stack, architecture, and tracker integration.
