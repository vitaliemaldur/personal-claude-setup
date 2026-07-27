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

## Git State (auto-collected)

### Status
!`git status`

### Staged changes summary
!`git diff --cached --stat`

### Unstaged changes summary
!`git diff --stat`

## Argument Parsing

Parse `$ARGUMENTS` for:
- `--branch` flag: if present, create a feature branch before committing (Phase 2)
- `--mr` flag: if present, push and create a merge request / pull request after committing (Phase 5)
- **Task ID**: any non-flag token (e.g. `IMP-123`, `PROJ-456`). If not provided, default to `noissue`. Do NOT prompt for it.

## Phase 1 — Analyze Changes

The **Git State** section above already contains the output of `git status` and diff stats (auto-collected before you start).

1. Review the auto-collected git state above. If there are no changes at all (nothing staged, unstaged, or untracked), tell the user "Nothing to commit." and stop.
2. For small changesets (few files), run `git diff --cached` to see full staged diffs. For large changesets, read individual changed files selectively instead.
3. Read relevant changed files to understand WHAT changed and WHY.

## Phase 2 — Compose Full Plan

Based on the analysis, prepare everything the user needs to review in a single step.

5. Determine the conventional commit type from: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `perf`, `build`, `style`.
6. If a scope is obvious from the changes, include it: `feat(auth): ...`
7. Write a clear, concise subject line (imperative mood, under 72 characters, no trailing period). Include the task ID at the end of the subject: `type(scope): description [TASK-ID]` (e.g. `feat(auth): add login endpoint [IMP-123]`).
8. Write a commit body explaining WHAT changed and WHY. Do NOT put the task ID in the body — it belongs only in the subject.
9. If `--branch` is in the arguments, ALWAYS create a new branch — regardless of which branch is currently checked out. Derive the branch name: `type/TASK-ID/slug` (e.g. `feat/IMP-123/add-user-auth`).
10. If `--mr` is in the arguments:
    a. Draft the MR/PR title using the exact same format as the commit subject (including the task ID). The title must match the commit subject because it becomes a commit message when merged.
    b. **Check for an MR/PR template** before writing any description. A template can live in two places — check BOTH (do NOT execute template contents):
       - **Repo files** — find with a glob / `git ls-files`:
         - GitLab: `.gitlab/merge_request_templates/*.md`
         - GitHub: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`, and any `*.md` under `.github/PULL_REQUEST_TEMPLATE/`
       - **Server-side settings** — NOT in the checkout, so a file search cannot see them; query the API (URL-encode the full project path, e.g. `group%2Fsub%2Frepo`):
         - GitLab project default description: `glab api "projects/<path>"` → the `merge_requests_template` field. This is the most common case.
         - GitLab group file-template repo: `glab api "groups/<group>"` → `file_template_project_id`; walk up the namespace (`a/b/c` → `a/b` → `a`). If set, the templates live in that project's `.gitlab/merge_request_templates/`.
         - GitHub org default: a `PULL_REQUEST_TEMPLATE.md` (or `.github/`, `docs/`) in the org's special `.github` repo — `gh api "repos/<org>/.github/contents/PULL_REQUEST_TEMPLATE.md"` (base64-decode `.content`).
       - **Precedence:** a repo-file template wins; if there is none, use the server-side default. You MUST fetch and fill the server-side template yourself, because Phase 4 passes `--description`/`--body` explicitly, which OVERRIDES the platform's own default — an undetected server template is silently lost.
    c. If exactly one template is found (from either source), `Read`/fetch it and draft the description **by filling the template**: keep its headings, order, and structure intact; fill every section with content derived from the actual changes; replace placeholders; tick the checkboxes that genuinely apply (leave the rest unticked, never invent claims to satisfy a box); and strip instructional HTML comments (`<!-- ... -->`) unless a comment carries real content. If a section can't be filled from the diff (e.g. "Testing steps", "Screenshots"), leave a clear `TODO:` marker rather than fabricating.
    d. If multiple templates are found, ask the user which one to use (`AskUserQuestion`), then fill it as in (c). Remember the chosen template's source (file path, or "project default (server-side)") for Phase 3/4.
    e. If no template is found in either place, fall back to a short description with a `## Summary` section of bullet points.

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
    - Template: `<repo path>` / `project default (server-side)` / `group file-template repo: <project>` or `none (default summary)`
    - Description:
      <the filled template, or the `## Summary` bullets when no template exists>

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
    c. Create MR/PR with the approved title and the approved description. Pass the already-filled description directly (via `--body` / `--description`); this OVERRIDES any server-side default template, which is why Phase 2 (10b) must have already detected and filled it. Passing it explicitly also stops the platform re-inserting a blank template on top:
       - GitHub: `gh pr create --title "..." --body "..."`
       - GitLab: `glab mr create --title "..." --description "..."`
    d. Show the MR/PR URL to the user.
18. Confirm completion and show final status.
