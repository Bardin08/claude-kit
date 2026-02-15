# claude-kit

A curated marketplace of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins for common development workflows.

## Quick Start

Add this marketplace to Claude Code:

```
/plugin marketplace add bardin08/claude-kit
```

Then install any plugin:

```
/plugin install plugin-name@claude-kit
```

## Available Plugins

| Plugin                         | Description                                                                                                                                            |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [otto-kit](./plugins/otto-kit) | OTTO — Open Toolchain & Task Orchestrator. Bootstrap project-specific slash commands, agents, and conventions by detecting tech stack and architecture. |

## Contributing

We welcome new plugins. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the step-by-step guide.

In short:
1. Fork this repo
2. Create your plugin in `plugins/your-plugin-name/`
3. Add it to `.claude-plugin/marketplace.json`
4. Open a PR

## License

[MIT](./LICENSE)
