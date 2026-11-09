# personal-claude-setup

My personal agent setup as plain files. No plugin, no install script: copy each file to the place the agent reads it from.

## Layout

```
global/                     Shared by every agent (Claude Code, Codex, OpenCode, Pi)
├── AGENTS.md               Global rules
└── skills/<name>/SKILL.md  Skills (Agent Skills standard)

claude/                     Claude Code only
├── settings.json           Permissions, statusline config, etc.
└── statusline-command.sh   Statusline script (settings.json runs it from ~/.claude/)
```

## Requirements

`global/AGENTS.md` tells agents to use these CLI tools, so install them first (macOS, Homebrew):

```bash
brew install gh glab
brew install --cask gcloud-cli   # gcloud + bq
```

Then log in: `gh auth login`, `glab auth login`, `gcloud auth login`.

Also install [herdr](https://herdr.dev), a terminal workspace manager for AI coding agents. Its Claude Code hook is set up after copying the files, see [herdr hook](#herdr-hook).

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

## Where each file goes

| | Global rules (`global/AGENTS.md`) | Skills (`global/skills/*`) |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` (renamed: Claude has no global `AGENTS.md`) | `~/.claude/skills/` |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `~/.agents/skills/` |
| Pi | `~/.pi/agent/AGENTS.md` | `~/.agents/skills/` |

`~/.agents/skills/` is the shared skills folder that Codex, OpenCode and Pi all read, so one copy there serves all three.

## Copy commands

Run these from the repo root. `cp -R global/skills/. <dir>` merges the skills into the folder and keeps any other skills already there.

**Claude Code**

```bash
mkdir -p ~/.claude/skills
cp global/AGENTS.md ~/.claude/CLAUDE.md
cp -R global/skills/. ~/.claude/skills/
cp claude/settings.json claude/statusline-command.sh ~/.claude/
```

> `cp claude/settings.json` **overwrites** your local `~/.claude/settings.json`, including MCP permissions and anything Claude Code wrote there. Compare them first: `diff claude/settings.json ~/.claude/settings.json`.

#### herdr hook

herdr's Claude Code integration adds a `SessionStart` hook that reports each session to herdr, so herdr can restore sessions after a restart. The hook isn't in this repo: herdr's installer writes the script to `~/.claude/hooks/herdr-agent-state.sh` and adds the hook entry to `~/.claude/settings.json` itself.

```bash
herdr integration install claude
herdr integration status
```

Run `herdr integration install claude` **after** copying `settings.json`, and again every time you copy it, because the copy removes herdr's hook entry.

**Codex, OpenCode, Pi**

```bash
mkdir -p ~/.agents/skills ~/.codex ~/.config/opencode ~/.pi/agent
cp -R global/skills/. ~/.agents/skills/
cp global/AGENTS.md ~/.codex/AGENTS.md
cp global/AGENTS.md ~/.config/opencode/AGENTS.md
cp global/AGENTS.md ~/.pi/agent/AGENTS.md
```

## Updating

The copies don't update themselves. After you change something here (or `git pull` on another machine), run the copy commands again. A skill you delete or rename here also has to be removed from the target folder by hand.

## Adding a skill

Create `global/skills/<name>/SKILL.md` with `name` (matching the folder name) and `description` in the frontmatter. Keep it tool-neutral: Claude-only features such as `` !`command` `` preloading show up as literal text in other agents.

## Recommended MCP servers

MCP servers need personal credentials, so they're not in this repo. Install them yourself:

| Server | URL | Claude Code |
|---|---|---|
| [Context7](https://context7.com) (up-to-date library docs) | `https://mcp.context7.com/mcp` | `claude mcp add --scope user --transport http --header "CONTEXT7_API_KEY: <key>" context7 https://mcp.context7.com/mcp` |
| [Atlassian](https://www.atlassian.com/platform/remote-mcp-server) (Jira, Confluence) | `https://mcp.atlassian.com/v1/mcp` | `claude mcp add --scope user --transport http atlassian https://mcp.atlassian.com/v1/mcp` |

For the other agents, add the same URLs to their MCP config: `codex mcp add`, the `mcp` section of `opencode.json`, or a Pi MCP extension.
