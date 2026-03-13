---
name: v-commit
description: Create a conventional commit, optionally create a branch and open a MR/PR
user-invocable: true
disable-model-invocation: true
argument-hint: [--branch] [--mr] [TASK-ID]
allowed-tools: Bash, Read, Grep, AskUserQuestion
---

Create a conventional commit for the current project.

Arguments received: $ARGUMENTS

## Argument Parsing

Parse `$ARGUMENTS` for:
- `--branch` flag: if present, create a feature branch before committing (Phase 2)
- `--mr` flag: if present, push and create a merge request / pull request after committing (Phase 5)
- **Task ID**: any non-flag token (e.g. `IMP-123`, `PROJ-456`). If not provided, default to `noissue`. Do NOT prompt for it.

## Phase 1 — Analyze Changes

1. Run `git status` to see staged, unstaged, and untracked files.
2. Run `git diff --cached` to see staged changes. Run `git diff` to see unstaged changes.
3. If there are no changes at all (nothing staged, unstaged, or untracked), tell the user "Nothing to commit." and stop.
4. Read relevant changed files to understand WHAT changed and WHY.

## Phase 2 — Compose Full Plan

Based on the analysis, prepare everything the user needs to review in a single step.

5. Determine the conventional commit type from: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `perf`, `build`, `style`.
6. If a scope is obvious from the changes, include it: `feat(auth): ...`
7. Write a clear, concise subject line (imperative mood, under 72 characters, no trailing period). Include the task ID at the end of the subject: `type(scope): description [TASK-ID]` (e.g. `feat(auth): add login endpoint [IMP-123]`).
8. Write a commit body explaining WHAT changed and WHY. Do NOT put the task ID in the body — it belongs only in the subject.
9. If `--branch` is in the arguments, ALWAYS create a new branch — regardless of which branch is currently checked out. Derive the branch name: `type/TASK-ID/slug` (e.g. `feat/IMP-123/add-user-auth`).
10. If `--mr` is in the arguments, draft the MR/PR title using the exact same format as the commit subject (including the task ID), and a short MR/PR description summarizing the changes. The MR/PR title must match the commit subject because it becomes a commit message when merged.

## Phase 3 — Single Confirmation

Present EVERYTHING in one block for the user to review and edit. Use this exact format:

    **Branch** (only if `--branch`):
    `type/TASK-ID/slug`

    **Commit message:**
    ```
    type(scope): subject line [TASK-ID]

    Body explaining what and why.
    ```

    **Files to stage:**
    - `path/to/file.ts` (modified)
    - `path/to/new-file.ts` (new)
    - ...

    **MR/PR** (only if `--mr`):
    - Title: `type(scope): subject line [TASK-ID]`
    - Description:
      ## Summary
      - bullet points

11. Ask the user to confirm or request changes. They can edit ANY part: branch name, commit message, file list, MR/PR title/description. Do NOT proceed without explicit approval.
12. If the user requests changes, update the relevant parts and re-present. Repeat until approved.

## Phase 4 — Execute

Once approved, execute all steps without further prompts:

13. If `--branch`: create the branch with `git checkout -b <approved-branch-name>`.
14. Stage files individually with `git add <file>` for each approved file. NEVER use `git add -A` or `git add .`. Skip and warn about any files that look like secrets or credentials (`.env`, tokens, keys, certificates, credentials files).
15. Create the commit using a heredoc to preserve formatting:
    ```bash
    git commit -m "$(cat <<'EOF'
    type(scope): subject line [TASK-ID]

    Body explaining what and why.
    EOF
    )"
    ```
16. Run `git status` to verify the commit succeeded.
17. If `--mr`:
    a. Detect platform from `git remote -v`:
       - URL contains `github.com` → use `gh`
       - URL contains `gitlab` → use `glab`
       - If unclear, ask the user.
    b. Push: `git push -u origin HEAD`
    c. Create MR/PR with the approved title and description:
       - GitHub: `gh pr create --title "..." --body "..."`
       - GitLab: `glab mr create --title "..." --description "..."`
    d. Show the MR/PR URL to the user.
18. Confirm completion and show final status.
