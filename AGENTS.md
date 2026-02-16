# Purpose

A curated marketplace of Claude Code plugins for common development workflows. A GitHub repository that serves as a distribution hub for Claude Code plugins.
Stack: Markdown (.md) and JSON (.json) files defining plugin commands, skills, and metadata.

# Setup

Clone the repository:

```sh
git clone https://github.com/bardin08/claude-kit.git
cd claude-kit
```

Add the marketplace to Claude Code:

```sh
claude --plugin-dir ./plugins/plugin-name
```

Or install from the marketplace:

```sh
/plugin marketplace add bardin08/claude-kit
/plugin install plugin-name@claude-kit
```

# Architecture

Marketplace structure:

- `.claude-plugin/marketplace.json` — marketplace catalog listing all available plugins
- `plugins/` — each subdirectory is a standalone plugin
- `plugins/{plugin-name}/.claude-plugin/plugin.json` — plugin metadata (required)
- `plugins/{plugin-name}/commands/` — slash command definitions (.md files)
- `plugins/{plugin-name}/skills/` — auto-invoked skill definitions (SKILL.md files)
- `plugins/{plugin-name}/agents/` — agent definitions
- `plugins/{plugin-name}/hooks/` — lifecycle hooks
- `plugins/{plugin-name}/.mcp.json` — MCP server configuration

Each plugin in the marketplace:

1. Listed in `.claude-plugin/marketplace.json` with name, description, version, source path, author, tags, category
2. Has a `plugin.json` at `{source}/.claude-plugin/plugin.json` with required fields: name, description, version
3. Declares component directories in `plugin.json` (commands, skills, agents, hooks, mcpServers)
4. Component directories must exist if declared

# Code style

File naming:

- Plugin directory names: lowercase, hyphen-separated (e.g., `git-commit`, `code-review`)
- Command files: lowercase, hyphen-separated, `.md` extension (e.g., `commit.md`, `pr-desc.md`)
- Skill directories: lowercase, hyphen-separated, containing `SKILL.md` (e.g., `skills/review/SKILL.md`)

JSON formatting:

- 2-space indentation
- Required fields in `marketplace.json`: name, description, version, source, author, tags, category
- Required fields in `plugin.json`: name, description, version

Markdown conventions:

- Command and skill descriptions: start with a verb, no period at the end
- Frontmatter format:
  ```markdown
  ---
  description: Brief description
  ---
  ```

# Working rules

- Before adding a new plugin, examine existing plugins for structure and naming patterns
- Prefer minimal changes — do not refactor existing plugins without explicit approval
- Do not add dependencies or build tooling — this is a content-only repository
- Do not modify `.github/workflows/validate.yml` without explicit approval
- Do not expose example credentials or API keys in plugin instructions
- Plugin instructions must not include destructive operations without explicit user confirmation

# Testing

Validation is performed by GitHub Actions in `.github/workflows/validate.yml`:

1. `.claude-plugin/marketplace.json` exists and is valid JSON
2. Every plugin listed in `marketplace.json` has a valid `plugin.json` at the declared source path
3. Every `plugin.json` contains required fields: name, description, version
4. All component directories declared in `plugin.json` exist (commands, skills, agents, hooks, mcpServers)

To validate locally before committing:

```sh
jq empty .claude-plugin/marketplace.json
```

For each plugin listed in marketplace.json:

```sh
jq empty plugins/{plugin-name}/.claude-plugin/plugin.json
jq -r '.name, .description, .version' plugins/{plugin-name}/.claude-plugin/plugin.json
```

# Commits & PRs

Commit message format: Conventional Commits

```
<type>(<scope>): <description>
```

Examples:

- `feat: add git-commit plugin`
- `fix(code-review): correct skill activation pattern`
- `docs: update contributing guide`

Types: `feat`, `fix`, `docs`, `chore`, `refactor`

One logical change per commit.

PR title format: same as commit message format.

# CI / Checks

CI system: GitHub Actions

Runs on: pull requests to `master`, pushes to `master`

Checks:

1. Validate marketplace.json exists and is valid JSON
2. Validate plugin structure:
   - Each plugin has `plugin.json` at declared source
   - `plugin.json` is valid JSON
   - Required fields present: name, description, version
   - Declared component directories exist

All checks must pass before merge.

# Playbooks

## Adding a new plugin

1. Read existing plugins to understand structure and naming patterns
2. Create plugin directory: `plugins/{plugin-name}/`
3. Create `plugins/{plugin-name}/.claude-plugin/plugin.json` with required fields:
   ```json
   {
     "name": "plugin-name",
     "description": "Brief description",
     "version": "0.1.0",
     "author": {
       "name": "github-username"
     },
     "license": "MIT",
     "commands": ["./commands"]
   }
   ```
4. Add commands or skills in declared component directories
5. Add plugin entry to `.claude-plugin/marketplace.json` in the `plugins` array
6. Validate JSON locally with `jq empty` on both files
7. Test plugin locally: `claude --plugin-dir ./plugins/{plugin-name}`
8. Commit with conventional commit message: `feat: add {plugin-name} plugin`
9. Open PR with same title as commit message

## Reviewing a plugin submission PR

Check structure:

- Plugin directory name is lowercase, hyphen-separated
- `plugin.json` exists at correct path
- `plugin.json` contains required fields: name, description, version
- Component directories declared in `plugin.json` exist
- Command files are `.md` with lowercase, hyphen-separated names
- Skill directories contain `SKILL.md`

Check marketplace.json:

- Plugin entry added to `plugins` array
- Entry contains: name, description, version, source, author, tags, category
- Source path matches actual plugin directory
- Version in marketplace.json matches version in plugin.json

Check content quality:

- Description is clear and starts with a verb
- Instructions are complete and safe (no destructive ops without confirmation)
- Plugin solves a real workflow problem
- Plugin does one thing well

Check commit and PR:

- Commit message follows conventional commits format
- PR title matches commit message
- One logical change (single plugin addition)

Verify CI passes all validation checks.

## Fixing marketplace issues

If marketplace.json is invalid:

1. Run `jq empty .claude-plugin/marketplace.json` to identify syntax error
2. Fix JSON syntax (common issues: trailing commas, unquoted strings)
3. Verify all plugin entries have required fields
4. Commit: `fix: correct marketplace.json syntax`

If plugin.json is invalid:

1. Run `jq empty plugins/{plugin-name}/.claude-plugin/plugin.json`
2. Fix JSON syntax
3. Verify required fields: name, description, version
4. Commit: `fix({plugin-name}): correct plugin.json`

If component directories are missing:

1. Check `plugin.json` for declared component paths
2. Create missing directories or remove declarations from `plugin.json`
3. Commit: `fix({plugin-name}): add missing component directories`

If versions are mismatched:

1. Update version in `plugin.json` to match `marketplace.json` or vice versa
2. Follow semver for version bumps
3. Commit: `chore({plugin-name}): sync version to {version}`
