# claude-setup

Personal Claude Code configuration, version-controlled.

## Fresh Machine

```bash
git clone <repo-url> ~/.claude
```

## Existing ~/.claude

```bash
cd ~/.claude
git init
git remote add origin git@github.com:vitaliemaldur/personal-claude-setup.git
git fetch
git checkout -f main
```

The `-f` overwrites tracked config files with repo versions. Runtime files (cache, history, sessions, etc.) are gitignored and left untouched.

## Updating

```bash
cd ~/.claude && git pull
```

## What's Tracked

| File | Purpose |
|------|---------|
| `settings.json` | Permissions, hooks, env vars, preferences |
| `keybindings.json` | Keyboard shortcuts |
| `CLAUDE.md` | Global instructions for all projects |
| `skills/` | Custom slash commands |
| `agents/` | Custom subagents |
| `hooks/` | Hook scripts (referenced by settings.json) |
| `mcp-servers.json` | MCP server definitions (reference, applied via `claude mcp add`) |

## Adding a Skill

```bash
mkdir ~/.claude/skills/my-skill
# Create ~/.claude/skills/my-skill/SKILL.md with frontmatter + instructions
```

## Adding an Agent

```bash
# Create ~/.claude/agents/my-agent.md with frontmatter + instructions
```

## MCP Servers

MCP servers live in `~/.claude.json` (runtime state), so they can't be tracked via git. Define them in `mcp-servers.json` for reference, then add with:

```bash
claude mcp add --transport http <name> <url>
```
