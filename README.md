# gaiia-systems/agent-plugins-official

A [Claude Code](https://claude.com/claude-code) plugin marketplace for interacting with the [gaiia](https://gaiia.com/) platform.

## Available Plugins

| Plugin | Description |
|---|---|
| **gaiia-api** | Explore and query the Gaiia GraphQL API — schema exploration, query construction, mutation discovery, and execution. |

## Install

Add this marketplace to Claude Code:

```
/plugin marketplace add gaiia-systems/agent-plugins-official
```

Then install a plugin:

```
/plugin install gaiia-api@agent-plugins-official
```

## Usage

Once installed, plugin skills are namespaced under the plugin name. For example:

```
/gaiia-api:graphql
```

Or just ask Claude something that matches the skill description — it will load automatically:

> "Find all subscriptions for customer X in the Gaiia API"

## Contributing

Each plugin lives in `plugins/<plugin-name>/` and follows the [Claude Code plugin structure](https://code.claude.com/docs/en/plugins):

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest (name, description, version)
└── skills/
    └── <skill-name>/
        ├── SKILL.md        # Skill instructions (required)
        └── ...             # Supporting files (scripts, references, etc.)
```

The marketplace catalog is at `.claude-plugin/marketplace.json`.
