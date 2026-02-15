---
description: Implement a task — generic workflow. Run /otto-kit:establish-project for a version tuned to your project
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Task, EnterPlanMode, AskUserQuestion
---

# Task Implementation Workflow

The user provides a task reference. Execute this workflow:

## Phase 1: Read the Spec

1. The user will describe the task directly. Clarify scope and acceptance
   criteria with AskUserQuestion if anything is ambiguous.
2. Run `git log --oneline -10` for recent context.
3. Read AGENTS.md or CLAUDE.md for project conventions if they exist.

Do NOT use a subagent for this phase.

## Phase 2: Investigate Affected Code

Spawn an Explore subagent (model: haiku) with:
- The task scope summary from Phase 1
- Instructions to find:
  - Existing patterns in the affected area (find a similar completed feature)
  - Existing tests covering the affected area
  - File paths and key symbols

Keep only the subagent's summary.

## Phase 3: Plan

Enter plan mode (EnterPlanMode). Write a plan that includes:
- Exact files to create or modify, with paths
- What changes in each file, referencing which existing pattern to follow
- Test strategy: which test file, what scenarios
- Build verification commands

Wait for user approval before proceeding.

## Phase 4: Implement

After plan approval:

**For small/medium tasks**: Implement directly in this conversation.

**For large tasks**: Spawn an implementation subagent (model: opus) with:
- The approved plan (exact files and changes)
- Pattern examples found in Phase 2
- Acceptance criteria as completion checklist
- Instruction: run build and test commands after changes and fix failures before returning

## Phase 5: Verify & Commit

After implementation:
1. Run build command — must pass
2. Run test command — must pass
3. If failures, fix and retry (up to 3 attempts)
4. Run `git diff --stat` to show change summary
5. Ask the user: commit? If yes, follow the project's commit convention.
   Never add AI co-author lines.

> **Tip**: Run `/otto-kit:establish-project` to generate a version
> of this command tuned to your project's stack, architecture, and conventions.
