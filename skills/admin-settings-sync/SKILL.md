---
name: admin:settings:sync
description: Sync local Claude Code config changes to remote git
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

Sync local changes in `~/.claude` to the remote git repository.

Follow these steps exactly:

1. Run `git -C ~/.claude status --porcelain` to check for local changes.
2. If there are no changes, tell the user "No changes to sync." and stop.
3. Pull latest from remote: `git -C ~/.claude pull --rebase`.
4. Run `git -C ~/.claude diff` and `git -C ~/.claude diff --cached` and `git -C ~/.claude status` to show the full picture.
5. Present a clear summary of what changed to the user.
6. Ask the user to confirm before proceeding. Do NOT commit without explicit confirmation.
7. If confirmed, stage all changes, create a descriptive commit, and push to remote.
