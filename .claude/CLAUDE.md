# cheesy-scribe — Claude reference

## What this is

Cheese-tasting notes app modeled on the 33Books tasting notebook: track,
record, and look back at cheeses tasted. Greenfield: **no app code yet.** A
design handoff bundle lives in `docs/design_handoff_cheesy_scribe/`
(`DESIGN_SPEC.md`, Flutter theme + Dart models, JSON schemas, hi-fi HTML
mockups). It targets Flutter / Material 3, but that is a recommendation, not
a locked decision — see "Architecture decisions". Keep this file in sync as
decisions land.

## Stack & commands

Undecided. When the stack is chosen, fill in the org table (install / lint /
typecheck / test / build) from `tkforgeworks/.github/templates/CLAUDE.md`.

- If Flutter: CI is `ci-flutter.yml`, releases `release-flutter.yml`, version
  bumps via `scripts/release/bump-version.{ps1,sh}`. Note `dart format` does
  not honour `analysis_options.yaml` excludes, so the `.dart` files under
  `docs/design_handoff_cheesy_scribe/lib/` must be formatted or moved before
  the format step will pass.
- If Electron: electron-builder, never Forge (user's global standard).

## Repo & process conventions (org standard)

- Branching (`tkforgeworks/.github/docs/branching-and-release.md`): `main` is
  the released state; work accumulates on the current release branch
  `vX.Y.Z/main` (currently **`v0.1.0/main`**); topic branches PR **into the
  release branch**, never into `main`; the release branch reaches `main` via
  a release PR. `main` is empty apart from the repo baseline until the first
  release PR.
- Branch names: `v0.1.0/CHEESE-N-short-topic`, cut from and PR'd into
  `v0.1.0/main`. Delete after merge.
- **Two repository rulesets** (`tkforgeworks/.github/docs/branch-protection-ruleset.md`):
  - `main` (ruleset id 20916528): PR-only (0 approvals, self-merge allowed),
    no force-push or deletion, **no bypass actors** (not even admins).
    **No `required_status_checks` rule yet** — CI does not exist. When CI is
    added: let the check report on at least one PR first, then `PUT` (not
    `PATCH`, which 404s) the ruleset with the full body plus the
    `required_status_checks` rule, context = the CI job name as it appears in
    the Actions run (a nested reusable workflow yields e.g. `ci / ci`).
  - `release-branches` (ruleset id 22367582, applied 2026-09-05): matches
    `refs/heads/v*/main`; deletion + non-fast-forward only. Deliberately no
    PR rule and no required check, because the release bump scripts push
    directly to the release branch.
  - Rulesets are edited with `gh api`; verify with
    `gh api repos/tkforgeworks/cheesy-scribe/rules/branches/<branch>`.
- CI: consume the shared reusable workflow from `tkforgeworks/.github`
  (`ci-flutter.yml` / `ci-electron.yml` / ...) with the canonical trigger
  envelope from `docs/ci-standards.md` — `pull_request.branches` must include
  `main` **and** `'v*/main'`. Don't hand-roll steps that belong in the shared
  workflow.
- **Commit subjects are the changelog.** `CHEESE-N: Imperative summary`; bug
  fixes `CHEESE-N: Fix ...`. Release notes are generated from subjects
  (`release-notes.yml`, `ticket-prefix: CHEESE`).
- Jira project **Cheesy Scribe**, key **`CHEESE`**
  (`https://tkforgeworks.atlassian.net/browse/CHEESE`). Move a ticket to
  *In Progress* when its branch opens. **Never close a ticket unless asked** —
  comment "Actions taken" + commit hash and leave it for the human to verify.
- Releases: **never hand-edit the version or push tags.** No release pipeline
  is wired up yet; adopt `release-flutter.yml` or `release-electron.yml` from
  the org repo when the stack is chosen.
- License: **Apache-2.0** (`LICENSE` is the verbatim Apache text — never edit
  it). Image assets (`.svg`/`.png`/etc.) are **all rights reserved** via
  `NOTICE`. Manifest `license` field (if the toolchain has one) must say
  `Apache-2.0`. Standard: `tkforgeworks/.github/docs/licensing.md`.
- `.claude/settings.json` has a PreToolUse hook that reminds you to review
  this file before any `git commit` — update it as the last step of closing
  any ticket that changed conventions, architecture, or status.

## Architecture decisions (locked)

- None yet. The design handoff recommends Flutter / Material 3; the decision
  is made when CHEESE-1 (decompose the design handoff) produces the work
  items. Record it here with the reason once made.

## Current status

- 2026-09-05: `v0.1.0/main` cut. LICENSE + NOTICE merged in. Both org
  rulesets applied (CHEESE-2). No CI, no app code.
- Open: CHEESE-1 — decompose the design handoff into tickets.
