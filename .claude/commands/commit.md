---
description: Create a commit following claude-kit conventions
allowed-tools: Bash, Read, Grep
user-invocable: true
---

# Commit

Create a well-formatted commit for staged changes.

## Convention

Conventional Commits format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`
- Scope: area affected (e.g., `marketplace`, `git-commit`, `code-review`, `ci`)
- Description: imperative mood, lowercase, no period
- Body (optional): explain why, not what

Examples from this project's history:
```
9d28070 Initial commit
```

Additional example formats:
```
feat(git-commit): add smart commit message plugin
fix(marketplace): correct source path for code-review
docs: update contributing guide with skill examples
chore(ci): add JSON validation to workflow
```

## Steps

1. Run `git status` to see staged and unstaged changes.
2. Run `git diff --cached` to review what's staged.
3. If nothing is staged, show unstaged changes and ask what to stage.
   Stage specific files by name — never use `git add -A` or `git add .`.
4. Run `git log --oneline -5` to see recent style for reference.
5. Analyze the staged diff and draft a commit message following the convention above.
6. Present the message to the user for approval or editing.
7. Create the commit with the approved message.
8. Show `git log -1` to confirm.

## Rules

- Never amend previous commits unless the user explicitly asks.
- Never force push.
- Never skip pre-commit hooks (no `--no-verify`).
- Never add AI co-author lines.
- If changes span multiple unrelated concerns, suggest splitting into separate commits.
