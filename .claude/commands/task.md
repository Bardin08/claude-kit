---
description: Implement a task for claude-kit. Reads specs, investigates code, plans, implements, and verifies.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Task, EnterPlanMode, AskUserQuestion
user-invocable: true
---

# Task Implementation Workflow

The user provides a task reference. Execute this workflow:

## Phase 1: Read the Spec

1. The user will describe the task directly. Clarify scope and acceptance
   criteria with AskUserQuestion if anything is ambiguous.
2. Run `git log --oneline -10` for recent context.
3. Read AGENTS.md for project conventions.

Do NOT use a subagent for this phase.

## Phase 2: Investigate Affected Code

Spawn an Explore subagent (model: haiku) with:
- The task scope summary from Phase 1
- Which layers are likely affected: marketplace.json → plugins/ → individual plugin dirs (plugin.json + commands/skills)
- Instructions to find:
  - Existing patterns in the affected area (find a similar completed feature)
  - Check existing plugins for structure patterns. Each plugin has `.claude-plugin/plugin.json` with name, description, version, author, license, components.
  - Existing tests covering the affected area
  - File paths and key symbols

Keep only the subagent's summary.

## Phase 3: Plan

Enter plan mode (EnterPlanMode). Write a plan that includes:
- Exact files to create or modify, with paths
- What changes in each file, referencing which existing pattern to follow
- Ensure new plugins are registered in marketplace.json. Ensure plugin structure follows the standard (plugin.json + declared component dirs).
- Test strategy: which test file, what scenarios
- Build verification: `jq empty .claude-plugin/marketplace.json && bash .github/workflows/validate.yml`

Wait for user approval before proceeding.

## Phase 4: Implement

After plan approval:

**For small/medium tasks**: Implement directly in this conversation.
Follow this order:
1. Create plugin directory structure, 2. Write plugin.json, 3. Write commands/skills, 4. Register in marketplace.json, 5. Validate

**For large tasks**: Spawn an implementation subagent (model: opus) with:
- The approved plan (exact files and changes)
- Pattern examples found in Phase 2
- Acceptance criteria as completion checklist
- Instruction: run `jq empty .claude-plugin/marketplace.json` after changes
- Instruction: run validation logic from `.github/workflows/validate.yml` and fix failures before returning

## Phase 5: Verify & Commit

After implementation:
1. Run `jq empty .claude-plugin/marketplace.json` — must pass
2. Run validation logic from `.github/workflows/validate.yml` locally (check JSON validity, required fields, directory existence) — must pass
3. If failures, fix and retry (up to 3 attempts)
4. Run `git diff --stat` to show change summary
5. Ask the user: commit? If yes, use `type(scope): description` format.
   Never add AI co-author lines.
