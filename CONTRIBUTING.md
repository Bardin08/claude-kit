# Contributing to claude-kit

## Adding a New Plugin

### 1. Fork and clone

```sh
gh repo fork bardin08/claude-kit --clone
cd claude-kit
```

### 2. Create the plugin directory

```sh
mkdir -p plugins/your-plugin-name/.claude-plugin
```

### 3. Add `plugin.json`

Create `plugins/your-plugin-name/.claude-plugin/plugin.json`:

```json
{
  "name": "your-plugin-name",
  "description": "What your plugin does in one sentence",
  "version": "0.1.0",
  "author": "your-github-username",
  "license": "MIT",
  "components": {
    "commands": ["./commands"],
    "skills": ["./skills"]
  }
}
```

Include only the component types your plugin uses (`commands`, `skills`, `agents`, `hooks`, `mcpServers`).

### 4. Add your commands or skills

**For commands** (user-invoked with `/claude-kit:command-name`):

Create `plugins/your-plugin-name/commands/command-name.md`:

```markdown
---
description: Brief description shown in command list
---

Instructions for what Claude should do when this command is invoked.
```

**For skills** (Claude can invoke automatically when relevant):

Create `plugins/your-plugin-name/skills/skill-name/SKILL.md`:

```markdown
---
description: Brief description of when this skill should activate
---

Detailed instructions for the skill behavior.
```

### 5. Register in the marketplace

Add your plugin to `.claude-plugin/marketplace.json` in the `plugins` array:

```json
{
  "name": "your-plugin-name",
  "description": "What your plugin does",
  "version": "0.1.0",
  "source": "./plugins/your-plugin-name",
  "author": "your-github-username",
  "tags": ["relevant", "tags"],
  "category": "category-name"
}
```

### 6. Test locally

```sh
claude --plugin-dir ./plugins/your-plugin-name
```

Verify your command or skill works as expected.

### 7. Open a PR

```sh
git checkout -b add-your-plugin-name
git add .
git commit -m "feat: add your-plugin-name plugin"
git push origin add-your-plugin-name
gh pr create
```

## Plugin Structure Reference

```
plugins/your-plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Required: plugin metadata
├── commands/                 # Optional: slash commands
│   └── command-name.md
├── skills/                   # Optional: auto-invoked skills
│   └── skill-name/
│       └── SKILL.md
├── agents/                   # Optional: agent definitions
├── hooks/                    # Optional: lifecycle hooks
│   └── hooks.json
└── .mcp.json                 # Optional: MCP server config
```

## Naming Conventions

- **Plugin names**: lowercase, hyphen-separated (`git-commit`, `code-review`)
- **Command files**: lowercase, hyphen-separated, `.md` extension
- **Skill directories**: lowercase, hyphen-separated, containing `SKILL.md`
- **Descriptions**: start with a verb, no period at the end

## Categories

Use one of the existing categories or propose a new one:

- `git` — Git workflow tools
- `code-quality` — Linting, review, formatting
- `documentation` — Docs generation and maintenance
- `testing` — Test generation and execution
- `devops` — CI/CD, deployment, infrastructure

## Review Criteria

PRs are reviewed for:

1. **Usefulness** — Does the plugin solve a real workflow problem?
2. **Quality** — Are the instructions clear and complete?
3. **Scope** — Does it do one thing well?
4. **Safety** — No destructive operations without confirmation, no secrets exposure
5. **Naming** — Clear, descriptive, follows conventions
