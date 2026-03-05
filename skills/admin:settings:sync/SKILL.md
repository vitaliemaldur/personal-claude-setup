---
name: admin:settings:sync
description: Sync local Claude Code config changes to remote git
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

Sync local changes in `~/.claude` to the remote git repository.

Follow these steps exactly:

1. Pull latest from remote: `git -C ~/.claude pull --rebase`. If this fails (e.g., conflicts), show the error and stop.
2. Run `git -C ~/.claude status --porcelain` to check for local changes.
3. If there are no changes, tell the user "Already up to date, no local changes." and stop.
4. Run `git -C ~/.claude diff`, `git -C ~/.claude diff --cached`, and `git -C ~/.claude status` to show the full picture.
5. For each changed or new file, read its contents and explain what it does and why it matters.
6. Present a clear summary of all changes to the user.
7. Ask the user to confirm before proceeding. Do NOT commit without explicit confirmation.
8. If confirmed, stage changes file by file (do NOT use `git add -A`). Skip any files that look like secrets or credentials (.env, tokens, keys).
9. Create a descriptive commit with a conventional prefix (e.g., `feat:`, `fix:`, `chore:`) and push to remote.
