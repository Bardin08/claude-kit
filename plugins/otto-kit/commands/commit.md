---
description: Create a well-formatted commit — generic workflow. Run /otto-kit:establish-project for a version tuned to your project
allowed-tools: Bash, Read, Grep
---

# Commit

Create a well-formatted commit for staged changes.

## Steps

1. Run `git status` to see staged and unstaged changes.
2. Run `git diff --cached` to review what's staged.
3. If nothing is staged, show unstaged changes and ask what to stage.
   Stage specific files by name — never use `git add -A` or `git add .`.
4. Run `git log --oneline -5` to see recent style for reference.
5. Analyze the staged diff and draft a commit message following the project's convention.
   If no convention is detectable, default to: `<type>: <short description>`
   Types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `test`
6. Present the message to the user for approval or editing.
7. Create the commit with the approved message.
8. Show `git log -1` to confirm.

## Rules

- Never amend previous commits unless the user explicitly asks.
- Never force push.
- Never skip pre-commit hooks (no `--no-verify`).
- Never add AI co-author lines.
- If changes span multiple unrelated concerns, suggest splitting into separate commits.

> **Tip**: Run `/otto-kit:establish-project` to generate a version
> of this command with your project's commit convention and pre-commit checks.
