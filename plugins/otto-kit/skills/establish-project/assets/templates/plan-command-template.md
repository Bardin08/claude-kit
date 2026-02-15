---
description: Plan a feature for {PROJECT_NAME}. Gathers requirements, assesses complexity, generates a structured plan, and syncs to tracker.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Task, AskUserQuestion
user-invocable: true
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
- Multiple layers affected: {ARCHITECTURE_LAYERS}
- Requires a new pattern, abstraction, or integration
- Multiple user stories or personas
- Ordering constraints between tasks
- Data migration, schema changes, or breaking API changes
- External system coordination

When in doubt, choose complex. Present the assessment to the user and confirm.

## Phase 3: Generate Plan

### Simple tasks

Read the template at `{SKILL_BASE}/plan-reference/assets/simple-plan-template.md`.
Generate a plan file following that format.
Write it to `{PLAN_DIR}/<slugified-feature>.md`.

### Complex tasks

Spawn an Explore subagent (model: haiku) to investigate the affected areas:
- Architecture layers: {ARCHITECTURE_LAYERS}
- Find existing patterns in affected areas
- Identify key files and symbols
- Note test patterns

Read both templates:
- Epic: `{SKILL_BASE}/plan-reference/assets/complex-plan-template.md`
- Task: `{SKILL_BASE}/plan-reference/assets/complex-task-template.md`

Generate:
1. An epic plan file following the epic template.
   Write to `{PLAN_DIR}/<slugified-feature>.md`.
2. A task directory at `{PLAN_DIR}/<slugified-feature>/`.
   For each task, create `<NN>-<slugified-task-title>.md` following the task template.
   Each task file includes objective, approach (files to create/modify, patterns to follow,
   key APIs), and acceptance criteria — enough for `/task` to implement without investigation.

### Review

Present the plan to the user. Ask for approval or modifications.
If they request changes, update the plan file and re-present.

{IF HAS_TRACKER}
## Phase 4: Sync to Tracker

After the user approves the plan, sync it using the tracker adapter.

Spawn a general-purpose subagent (model: haiku) with:
- Instructions to read `{SKILL_BASE}/{TRACKER_SKILL}/SKILL.md`
- `PLAN_FILE`: the absolute path to the plan file just created
{TRACKER_CONFIG}
- Instruction: follow the adapter's workflow exactly

Report the sync results to the user.
{ELSE}
## Phase 4: Next Steps

The plan file is saved at `{PLAN_DIR}/<feature>.md`.

Tell the user:
- For simple plans: run `/task` with the plan file to implement
- For complex plans: implement tasks in build order using `/task` for each
- To set up automatic tracker sync, run `/otto-kit:establish-project`
{END IF}
