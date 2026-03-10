# Global Claude Code Instructions

<!-- These instructions apply to ALL projects. Keep them general. -->
<!-- Project-specific instructions belong in each project's own CLAUDE.md. -->

## Interaction
- If it is not a trivial change always explain how it works and why. Help me learn.
- If the requirements I give you are ambiguous, ask clarifying questions before proceeding.

## Coding
- Always use the official docs to see how to use a specific package or framework for a specifc version (with Context7 MCP if needed or directly online).
- Verify all applied changes (edge cases, imports, types, configs) and run relevant tests (if possible) before you finish. Prove that they work.

## Available CLI Tools
- `git` - Git CLI. Use for repo inspection and interaction.
- `gh` — GitHub CLI. Use for GitHub operations (PRs, issues, repos, actions).
- `glab` — GitLab CLI. Use for GitLab operations (MRs, issues, pipelines).
- `gcloud` — Google Cloud CLI. Use for GCP resource management, auth, and configuration.
- `bq` — BigQuery CLI. Use for BigQuery queries, dataset/table management.
