---
name: v-settings-sync
description: Sync local Claude Code config changes to remote git
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

Sync local changes in `~/.claude` to the remote git repository.

Follow these steps exactly:

1. Capture current HEAD: `old_head=$(git -C ~/.claude rev-parse HEAD)`.
2. Pull latest from remote: `git -C ~/.claude pull --rebase`. If this fails (e.g., conflicts), show the error and stop.
3. If the pull fetched new commits (`old_head` differs from current HEAD), run `git -C ~/.claude log --oneline --stat $old_head..HEAD` to see what changed. For each changed file, read it and briefly explain what the incoming changes do and why they matter.
4. Run `git -C ~/.claude status --porcelain` to check for local changes.
5. If there are no changes, tell the user "Already up to date, no local changes." and stop.
6. Run `git -C ~/.claude diff`, `git -C ~/.claude diff --cached`, and `git -C ~/.claude status` to show the full picture.
7. For each changed or new file, read its contents and explain what it does and why it matters.
8. Present a clear summary of all changes to the user.
9. Ask the user to confirm before proceeding. Do NOT commit without explicit confirmation.
10. If confirmed, stage changes file by file (do NOT use `git add -A`). Skip any files that look like secrets or credentials (.env, tokens, keys).
11. Create a descriptive commit with a conventional prefix (e.g., `feat:`, `fix:`, `chore:`) and push to remote.
