---
description: Implement a task for {PROJECT_NAME}. Reads specs, investigates code, plans, implements, and verifies.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Task, EnterPlanMode, AskUserQuestion
user-invocable: true
---

# Task Implementation Workflow

The user provides a task reference. Execute this workflow:

## Phase 1: Read the Spec

{IF TASK_FILES}
1. Find the task file. Task files live in `{TASK_DIR}`.
   {TASK_ID_FORMAT_DESCRIPTION}. Use Glob to find it.
2. Read the task file completely. Extract objectives, scope, requirements,
   acceptance criteria, and dependencies.
3. If dependencies are listed, verify they exist in the codebase.
{ELSE IF EXTERNAL_TASK_TOOL}
1. Fetch the task using {TASK_TOOL_INSTRUCTION}.
2. Extract objectives, scope, requirements, acceptance criteria.
{ELSE}
1. The user will describe the task directly. Clarify scope and acceptance
   criteria with AskUserQuestion if anything is ambiguous.
{END IF}
4. Run `git log --oneline -10` for recent context.
5. Read AGENTS.md for project conventions.

Do NOT use a subagent for this phase.

## Phase 2: Investigate Affected Code

Spawn an Explore subagent (model: haiku) with:
- The task scope summary from Phase 1
- Which layers are likely affected: {ARCHITECTURE_LAYERS}
- Instructions to find:
  - Existing patterns in the affected area (find a similar completed feature)
  - {STACK_SPECIFIC_PATTERNS}
  - Existing tests covering the affected area
  - File paths and key symbols

Keep only the subagent's summary.

## Phase 3: Plan

Enter plan mode (EnterPlanMode). Write a plan that includes:
- Exact files to create or modify, with paths
- What changes in each file, referencing which existing pattern to follow
- {STACK_SPECIFIC_PLAN_ITEMS}
- Test strategy: which test file, what scenarios
- Build verification: `{BUILD_CMD} && {TEST_CMD}`

{IF TASK_FILES}
Map each plan item to the acceptance criteria from the task file.
{END IF}
{IF EXTERNAL_TASK_TOOL}
Map each plan item to the acceptance criteria from the task.
{END IF}
Wait for user approval before proceeding.

## Phase 4: Implement

After plan approval:

**For small/medium tasks**: Implement directly in this conversation.
Follow this order:
{IMPLEMENTATION_ORDER}

**For large tasks**: Spawn an implementation subagent (model: opus) with:
- The approved plan (exact files and changes)
- Pattern examples found in Phase 2
- Acceptance criteria as completion checklist
- Instruction: run `{BUILD_CMD}` after changes
- Instruction: run `{TEST_CMD}` and fix failures before returning

## Phase 5: Verify & Commit

After implementation:
1. Run `{BUILD_CMD}` — must pass
2. Run `{TEST_CMD}` — must pass
3. If failures, fix and retry (up to 3 attempts)
4. Run `git diff --stat` to show change summary
{IF TASK_FILES}
5. Walk through acceptance criteria from the task file
{END IF}
{IF EXTERNAL_TASK_TOOL}
5. Walk through acceptance criteria from the task
{END IF}
6. Ask the user: commit? If yes, use `{COMMIT_FORMAT}` format.
   Never add AI co-author lines.
