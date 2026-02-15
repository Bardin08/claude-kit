---
name: establish-project
description: Bootstrap project-specific AGENTS.md, CLAUDE.md, task workflow, and review agents by detecting tech stack, structure, and conventions. Run once per project, or with "refresh" to regenerate.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion, Task
---

# Establish Project

Generate project-tuned configuration and skills by detecting the project's tech stack, structure, and conventions.

## Skill Asset Paths

All templates and reference files for this plugin are located under:

    SKILL_BASE=!`echo "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/skills"`

Throughout this document, **SKILL_BASE** refers to the resolved path printed above.
When instructions say to read a file at `SKILL_BASE/...`, substitute the actual resolved path.
When spawning Task subagents, pass the resolved SKILL_BASE value so they can locate template and reference files.

## Arguments

- `/establish-project` — generate all missing artifacts
- `/establish-project refresh` — regenerate all artifacts (backs up existing files first)
- `/establish-project <artifact>` — regenerate only one: `agents-md`, `claude-md`, `task`, `plan`, `pr-review`, `commit`, `settings`

## Phase 1: Detect

Scan the project root silently. Do NOT ask questions yet.

### Find project root

```bash
git rev-parse --show-toplevel 2>/dev/null || pwd
```

Store as PROJECT_ROOT.

### Tech stack

| File/Pattern | Stack | Version hint |
|---|---|---|
| `*.csproj`, `*.sln`, `global.json` | .NET | `<TargetFramework>` in csproj |
| `package.json` | Node.js | dependencies: next, react, vue, angular |
| `Cargo.toml` | Rust | edition field |
| `go.mod` | Go | go directive |
| `pyproject.toml`, `requirements.txt` | Python | requires-python |
| `Gemfile` | Ruby | ruby version |
| `Dockerfile`, `docker-compose.yml` | Containerized | — |
| `*.tf`, `terraform/` | IaC/Terraform | — |

### Build, test, lint commands

| Stack | Build | Test | Lint |
|---|---|---|---|
| .NET | `dotnet build` | `dotnet test` | `dotnet format --verify-no-changes` |
| Node.js | `package.json` scripts → `build` | scripts → `test` | scripts → `lint` |
| Rust | `cargo build` | `cargo test` | `cargo clippy` |
| Go | `go build ./...` | `go test ./...` | `golangci-lint run` |
| Python | — | pytest / unittest / tox | ruff / flake8 / mypy |

### Architecture

Look for layered directories: Core, Domain, Application, Infrastructure, Api, Web, Presentation, Services, Handlers, Controllers, Repositories.

Check: `src/` vs flat, test directories (Tests, tests, `__tests__`, spec, test), monorepo indicators (packages/, apps/, libs/, workspace configs).

### Task tracking

- Directories: `docs/tasks/`, `specs/`, `issues/`, `.github/ISSUE_TEMPLATE/`
- Markdown with "Acceptance Criteria", "Requirements", "Scope"
- Naming convention (TASK-XX, issue-NNN, etc.)
- MCP configs: `.mcp.json` — note task management MCPs (Linear, Jira, etc.)

### Plan tracker adapters

Scan for available plan tracker adapters:

```bash
ls -d SKILL_BASE/*-plan/ 2>/dev/null
```

Replace `SKILL_BASE` with the actual resolved path from above.
Extract adapter names (directory basenames, e.g., `gh-plan`, `local-plan`). Store as DETECTED_PLAN_ADAPTERS.

### Conventions

- Read AGENTS.md, CLAUDE.md, CONTRIBUTING.md if they exist
- `git log --oneline -10` for commit message format
- Config files: `.editorconfig`, `.eslintrc*`, `.prettierrc*`, `rustfmt.toml`, etc.
- CI: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`

Collect all findings into a compact detection summary.

## Phase 2: Confirm

Present what you detected as a summary. Use AskUserQuestion only for what you couldn't confidently detect:

1. **Tech stack** — "I detected [X]. Correct?"
2. **Architecture** — "I see [pattern]. Is this the structure to follow?"
3. **Task tracking** — "How do you track tasks?" (file-based, Linear, Jira, GitHub Issues, freeform?)
4. **Commit convention** — "I see commits like [format]. Follow this?"
5. **Existing artifacts** — if AGENTS.md/CLAUDE.md already exist AND the user didn't pass "refresh", ask whether to regenerate.
6. **Plan tracker** — if DETECTED_PLAN_ADAPTERS is non-empty: "Want to set up `/plan` with a tracker? Options: [list detected adapter names], none."
   - If `gh-plan`: ask "GitHub Project number to add issues to? (optional, press enter to skip)"
   - If `local-plan`: ask "Task directory path? (default: `docs/tasks`)"
   - Store the chosen adapter as PLAN_TRACKER and any config as PLAN_TRACKER_CONFIG.
   - If no adapters detected, skip this question silently.

If everything is clear from detection, present the summary and ask for a single confirmation.

## Phase 3: Determine artifacts to generate

```
ALL_ARTIFACTS = [agents-md, claude-md, task, plan, pr-review, commit, settings]
```

- **Argument is "refresh"**: generate all. Back up each existing file to `<name>.establish-backup`.
- **Argument is a specific name**: generate only that one. Back up if it exists.
- **No argument**: generate only artifacts that don't already exist. Warn about skipped ones.

## Phase 4: Validate prerequisites

Run checks **only** for artifacts and adapters that are in the generation list. Skip silently for artifacts not being generated.

| Condition | Check | Remediation |
|---|---|---|
| Any artifact selected | `git rev-parse --git-dir 2>/dev/null` | "Not a git repo. Initialize with `git init`?" |
| `commit` or `pr-review` | `git log -1 2>/dev/null` | "No commits yet — commit and PR commands need git history. Skipping for now." |
| `pr-review` | `gh auth status 2>/dev/null` | "gh CLI not authenticated. Run `gh auth login` to enable PR reviews." |
| PLAN_TRACKER = `gh-plan` | `command -v gh >/dev/null 2>&1` | "gh CLI not found. Install from https://cli.github.com" |
| PLAN_TRACKER = `gh-plan` | `gh auth status 2>/dev/null` | "gh CLI not authenticated. Run `gh auth login`." |
| PLAN_TRACKER = `gh-plan` | `gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null` | "No GitHub remote detected. Push to GitHub first, or switch to `local-plan`." |
| PLAN_TRACKER = `gh-plan` + PROJECT_NUMBER set | `gh api graphql -f query='query($n:Int!){viewer{projectV2(number:$n){id}}}' -F n=<N> 2>/dev/null` | "GitHub Project #N not found or not accessible. Continuing without project integration." |

### Handling failures

- **Hard failures** (no git, no gh CLI when gh-plan selected): ask the user whether to fix now, skip the affected artifact, or abort.
- **Soft failures** (no git history, project number not found): warn and degrade gracefully — skip the affected feature but continue generating the artifact without it.
- If the user chose `gh-plan` and gh auth fails, offer to fall back to `local-plan` or `none` instead of just skipping `plan` entirely.

Update PLAN_TRACKER and the artifact list based on any fallback decisions before proceeding.

## Phase 5: Generate

For each artifact, spawn a Task subagent. Pass the detection summary as compact text in the prompt.
**Always include the resolved SKILL_BASE path** in every subagent prompt so it can locate templates and references.
Run independent subagents in parallel.

### AGENTS.md

- **model**: sonnet
- **subagent_type**: general-purpose
- **prompt**: Include the detection summary AND instruct the subagent to read
  `SKILL_BASE/establish-project/references/generate-agents-md.md` for generation instructions.
  Target: `{PROJECT_ROOT}/AGENTS.md`.
  If refreshing, include current file content so the subagent can preserve intentional customizations.

### CLAUDE.md

- **model**: haiku
- **subagent_type**: general-purpose
- **prompt**: Include basic project info (name, stack, build/test/lint commands) AND instruct
  the subagent to read `SKILL_BASE/establish-project/references/generate-claude-md.md`.
  Target: `{PROJECT_ROOT}/CLAUDE.md`.

### Task command

- **model**: sonnet
- **subagent_type**: general-purpose
- **prompt**: Include the full detection summary AND instruct the subagent to read both:
  - `SKILL_BASE/establish-project/references/generate-task-command.md` (instructions)
  - `SKILL_BASE/establish-project/assets/templates/task-command-template.md` (template)
  Fill in all `{PLACEHOLDERS}`, resolve `{IF}/{END IF}` blocks, and write the result to
  `{PROJECT_ROOT}/.claude/commands/task.md`.
  Include task tracking details (format, location, MCP tools).

### PR review agent

- **model**: haiku
- **subagent_type**: general-purpose
- **prompt**: Include detection summary (conventions, linters, test commands) AND instruct
  the subagent to read `SKILL_BASE/establish-project/references/generate-pr-review.md`.
  Target: `{PROJECT_ROOT}/.claude/agents/pr-review.md`.

### Commit command

- **model**: haiku
- **subagent_type**: general-purpose
- **prompt**: Include commit convention (format description + 3-5 example messages from `git log`)
  AND instruct the subagent to read the template at
  `SKILL_BASE/establish-project/assets/templates/commit-command-template.md`.
  Fill in all `{PLACEHOLDERS}`, resolve `{IF}/{END IF}` blocks, and write the result to
  `{PROJECT_ROOT}/.claude/commands/commit.md`.
  Include pre-commit check commands if the project has them (lint, format, etc.).

### Plan command

- **model**: haiku
- **subagent_type**: general-purpose
- **prompt**: Include the full detection summary AND instruct the subagent to read both:
  - `SKILL_BASE/establish-project/references/generate-plan-command.md` (instructions)
  - `SKILL_BASE/establish-project/assets/templates/plan-command-template.md` (template)
  Fill in all `{PLACEHOLDERS}`, resolve `{IF}/{END IF}` blocks, and write the result to
  `{PROJECT_ROOT}/.claude/commands/plan.md`.
  Include:
  - Tracker adapter name (`PLAN_TRACKER` from Phase 2, or empty if none)
  - Tracker config (`PLAN_TRACKER_CONFIG` — project number, task dir, etc.)
  - Architecture layers detected
  - **SKILL_BASE** — so the generated plan command can reference plan templates and tracker adapter skills at the correct path

### Settings (`.claude/settings.json`)

Generate this **inline** — no subagent needed. It's a deterministic mapping from detected stack.

Write `{PROJECT_ROOT}/.claude/settings.json` with permissions based on the detected stack:

| Stack | Allow rules |
|---|---|
| .NET | `Bash(dotnet *)`, `Bash(git *)` |
| Node.js | `Bash(npm *)`, `Bash(npx *)`, `Bash(node *)`, `Bash(git *)` |
| Rust | `Bash(cargo *)`, `Bash(git *)` |
| Go | `Bash(go *)`, `Bash(git *)` |
| Python | `Bash(python *)`, `Bash(pip *)`, `Bash(uv *)`, `Bash(pytest *)`, `Bash(git *)` |

Combine rules if multiple stacks are detected. Always include `Bash(git *)`.

If `.claude/settings.json` already exists, **merge** — add missing allow rules without removing existing ones. Show the user the diff before writing.

#### Auto-format hook (conditional)

Only add if a formatter is **confidently detected** — meaning a config file or explicit dependency exists, not just a guess from the stack. Skip silently otherwise.

Evidence required:

| Formatter | Confident signal |
|---|---|
| Prettier | `.prettierrc*` exists OR `prettier` in `package.json` devDependencies |
| rustfmt | `rustfmt.toml` exists OR project uses Rust (rustfmt ships with toolchain) |
| gofmt | Project uses Go (gofmt ships with toolchain) |
| dotnet format | Project uses .NET 6+ |
| Ruff | `ruff` in `pyproject.toml` dependencies or `ruff.toml` exists |
| Black | `black` in `pyproject.toml` or `[tool.black]` section exists |

If confident, add to settings under `hooks`. The hook receives JSON on stdin with the tool input; use `jq` to extract the file path.

Example for Prettier:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // .tool_input.file_path' | xargs npx prettier --write 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

Adapt the command for the detected formatter:

| Formatter | Command |
|---|---|
| Prettier | `jq -r '.tool_input.file_path' \| xargs npx prettier --write 2>/dev/null \|\| true` |
| rustfmt | `jq -r '.tool_input.file_path' \| xargs rustfmt 2>/dev/null \|\| true` |
| gofmt | `jq -r '.tool_input.file_path' \| xargs gofmt -w 2>/dev/null \|\| true` |
| dotnet format | `jq -r '.tool_input.file_path' \| xargs -I {} dotnet format --include {} 2>/dev/null \|\| true` |
| Ruff | `jq -r '.tool_input.file_path' \| xargs ruff format 2>/dev/null \|\| true` |
| Black | `jq -r '.tool_input.file_path' \| xargs black 2>/dev/null \|\| true` |

The `|| true` ensures a formatter failure on a non-applicable file doesn't block Claude.

### .gitignore (always, inline)

Check if `{PROJECT_ROOT}/.gitignore` exists. If it does, check whether `.claude/` entries are present.
If not, ask the user: "Should `.claude/` be committed (team sharing) or gitignored (personal only)?"

If gitignored, append:
```
# Claude Code local config
.claude/settings.json
.claude/plans/
```

Note: skills and commands are NOT gitignored by default — the user likely wants to share `/task`, `/commit`, and the PR review agent with the team.

## Phase 6: Summary

After all subagents complete, report:

- **Created**: list each file with its absolute path
- **Skipped**: already existed (if any)
- **Usage**:
  - `AGENTS.md` — automatically picked up by compatible AI coding tools
  - `CLAUDE.md` — automatically picked up by Claude Code
  - `/plan <feature>` — invoke to plan a feature, decompose into tasks, and sync to tracker
  - `/task <reference>` — invoke to implement a task
  - `/commit` — invoke to create a well-formatted commit
  - PR review — used when Claude reviews PRs
  - `settings.json` — pre-approved tool permissions, active immediately
- **Reminder**: commit AGENTS.md, CLAUDE.md, and `.claude/commands/` + `.claude/agents/` to share with team.
