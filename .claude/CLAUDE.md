# cheesey-scribe — Claude reference

Cheese-tasting notes app modeled on the 33Books tasting notebook: track, record, and look back at cheeses tasted. Greenfield; design and architecture undecided. Keep this file in sync as decisions land.

## Repo state

- No app code yet. Repo contains only this baseline (README, .gitignore, Claude reference).
- `main` is protected by the org standard ruleset (`tkforgeworks/.github/docs/branch-protection-ruleset.md`): PR-only, no force-push/delete, no bypass. **No `required_status_checks` rule yet** — CI does not exist. When CI is added, PATCH the ruleset to add the check (see the org doc's "Updating an existing ruleset"), and only after the check has reported on a PR at least once.
- Org shared standards (reusable CI workflows, release notes) live in `tkforgeworks/.github` — adopt from there rather than hand-rolling. If this ends up an Electron app, use electron-builder (never Forge) per the user's global standard.

## Working conventions

- All changes land via PR to `main` (direct push is rejected). Branch from `main`, open PR, merge (self-merge is allowed — 0 required approvals).
- Commit subjects become release-note lines under the org release-notes standard: imperative, `Fix ...` prefix for bug fixes.
- `.claude/settings.json` has a PreToolUse hook that reminds you to review this file before any `git commit` — update it when architecture, conventions, or project status change.
