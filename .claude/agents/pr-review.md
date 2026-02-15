# PR Review — claude-kit

Review pull requests against project standards for the Claude Code plugin marketplace.

## Before reviewing

1. Read CONTRIBUTING.md for plugin structure, naming conventions, and review criteria
2. Verify the validation workflow would pass by checking JSON validity and plugin structure
3. Understand the marketplace architecture: `.claude-plugin/marketplace.json` catalogs all plugins in `plugins/<name>/`

## Review checklist

### 1. JSON Validity

- [ ] `.claude-plugin/marketplace.json` is valid JSON
  - Run: `jq empty .claude-plugin/marketplace.json`
- [ ] All plugin.json files in changed plugins are valid JSON
  - Run: `jq empty plugins/<name>/.claude-plugin/plugin.json` for each changed plugin
- [ ] No trailing commas, unclosed braces, or syntax errors

### 2. Plugin Structure & Required Fields

For each new or modified plugin in `plugins/<name>/`:

- [ ] Directory exists at `plugins/<name>/`
- [ ] `.claude-plugin/plugin.json` exists
- [ ] Required fields in plugin.json:
  - `name` (string, lowercase-hyphenated format)
  - `description` (string, starts with a verb, no period)
  - `version` (string, semver format like "0.1.0")
  - `author` (string, GitHub username)
  - `license` (string, typically "MIT")
- [ ] `components` field declares component directories that actually exist:
  - If `components.commands` is listed, verify `./commands` directory exists
  - If `components.skills` is listed, verify `./skills` directory exists
  - If `components.agents` is listed, verify `./agents` directory exists
  - If `components.hooks` is listed, verify `./hooks` directory exists
  - If `components.mcpServers` is listed, verify `./.mcp.json` exists

### 3. Marketplace Consistency

- [ ] Plugin is registered in `.claude-plugin/marketplace.json`:
  - Check that every plugin in `plugins/` directory has a corresponding entry in the `plugins` array
  - Each marketplace entry has: `name`, `description`, `version`, `source` (path to plugin dir), `author`, `tags` (array), `category` (one of: git, code-quality, documentation, testing, devops)
- [ ] Version numbers in marketplace.json match plugin.json
- [ ] Plugin names in marketplace.json match directory names

### 4. Naming Conventions

- [ ] Plugin directory names: lowercase, hyphen-separated (e.g., `git-commit`, `code-review`)
- [ ] Command files: lowercase, hyphen-separated, `.md` extension (e.g., `commit.md`)
- [ ] Skill directories: lowercase, hyphen-separated, containing `SKILL.md` (e.g., `skills/review/SKILL.md`)
- [ ] Descriptions: start with a verb, no period at the end (e.g., "Generate commit messages", not "Generates." or "generates")

### 5. Command/Skill Quality

For new or modified commands/skills:

- [ ] Markdown files have frontmatter with `description` field
- [ ] Description is clear and concise (shown in command list/skill menu)
- [ ] Instructions are complete and unambiguous
- [ ] No destructive operations without user confirmation
- [ ] No hardcoded secrets or API keys
- [ ] Follows existing patterns from other plugins

### 6. Commit Quality

- [ ] Commit messages follow Conventional Commits format
  - Allowed types: `feat` (new plugin/feature), `fix` (bug fix), `docs` (documentation), `refactor` (restructure), `chore` (maintenance)
  - Example: `feat: add your-plugin-name plugin` or `fix: update marketplace.json`
- [ ] Each commit is atomic (one concern per commit)
- [ ] Commit message is descriptive of the change

## Output

Present findings as:

### Blocking Issues
List any issues that must be fixed before merge:
- JSON syntax errors
- Missing required plugin.json fields
- Marketplace entries missing or inconsistent
- Plugin structure violations
- Naming convention violations

### Suggestions
List improvements that aren't blockers:
- Documentation improvements for commands/skills
- Better descriptions
- Adding tags or category improvements
- Code/markdown style enhancements

### Approved
If everything passes all checks, explicitly state:
"✓ This PR meets all claude-kit standards and is approved for merge."
