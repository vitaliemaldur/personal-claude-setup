---
name: v-settings-sync
description: Sync local Claude Code config changes to remote git
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

Pull remote changes into `~/.claude` and detect local drift.
This skill NEVER commits or pushes from `~/.claude`. Changes flow one way: remote → local.

The project repo is `~/Projects/personal-claude-setup`.

## Git State (auto-collected)

!`git -C ~/.claude status`
!`git -C ~/.claude diff --stat`
!`git -C ~/.claude log --oneline -5`

## Phase 1 — Pull Remote Changes

1. Review the auto-collected git state above.
2. Capture current HEAD: `old_head=$(git -C ~/.claude rev-parse HEAD)`.
3. If the working tree is dirty (modified or staged files), stash local changes first:
   ```bash
   git -C ~/.claude stash push -m "v-settings-sync: auto-stash before pull"
   ```
4. Pull latest from remote:
   ```bash
   git -C ~/.claude pull --rebase
   ```
   - If the rebase has conflicts: show the conflicting files with `git -C ~/.claude diff --name-only --diff-filter=U`, explain the conflict, and ask the user whether to resolve or abort (`git -C ~/.claude rebase --abort`). Do NOT proceed automatically.
5. If changes were stashed in step 3, restore them:
   ```bash
   git -C ~/.claude stash pop
   ```
   - If stash pop conflicts: show the conflicting files, explain what collided (remote vs local), and help the user resolve. Do NOT discard changes without asking.
6. If the pull fetched new commits (`old_head` differs from current HEAD), run:
   ```bash
   git -C ~/.claude log --oneline --stat $old_head..HEAD
   ```
   For each changed file, read it and briefly explain what the incoming changes do and why they matter.

## Phase 2 — Detect Local Drift

7. Run `git -C ~/.claude status --porcelain` and `git -C ~/.claude diff` to check for local changes.
8. If there are no local changes, tell the user "Synced and clean." and stop.
9. For each changed or new file:
   - Show the diff
   - Read the file and explain what drifted from the remote version
10. Present a clear summary of all drift.

## Phase 3 — Advise (Never Push)

For each drifted file, present options:

- **Keep the change**: tell the user to copy it to `~/Projects/personal-claude-setup/<same-path>`, commit and push there, then re-run `/v-settings-sync` to pull it back.
- **Discard the change**: run `git -C ~/.claude checkout -- <file>` (only after user confirms).

11. Ask the user what to do with each drifted file (or all at once if they prefer).
12. Execute the user's choice.
13. NEVER run `git commit` or `git push` from `~/.claude`. If the user asks to push, remind them to use the project repo instead.
