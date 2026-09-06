# cheesy-scribe — Claude reference

## What this is

Cheese-tasting notes app modeled on the 33Books tasting notebook: track,
record, and look back at cheeses tasted. **No app code yet**; the plan is
`docs/CHEESE-1-decomposition.md` (inventory of the design handoff, decisions,
architecture, and the ticket list mirrored in Jira epics CHEESE-3..12). The
design handoff itself lives in `docs/design_handoff_cheesy_scribe/`
(`DESIGN_SPEC.md`, `lib/theme.dart`, `lib/models.dart`, JSON schemas, hi-fi
HTML mockups). Keep this file in sync as decisions land.

## Stack & commands

Flutter 3.47.2 / Material 3, **Android only** (no desktop, iOS or web
targets). Dart package `cheesy_scribe`, application id
`com.tkforgeworks.cheesy_scribe`. Scaffolded 2026-09-06 (CHEESE-14): Android
platform only, `lib/main.dart` is a bare `ScribeApp` until the theme
(CHEESE-17) and shell (CHEESE-19) land. Portrait-only via the manifest and
`SystemChrome`.

Local toolchain (Tim's machine): Flutter 3.47.2 at `~/develop/flutter`, on
PATH only through the shell rc — agent shells must
`export PATH="$HOME/develop/flutter/bin:$PATH"` first. Android SDK 37 in
`~/Android/Sdk`, JDK 21, `Pixel_10_Pro` AVD.

| Task | Command |
|---|---|
| Install | `flutter pub get` |
| Format | `dart format --output=none --set-exit-if-changed .` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Build | `flutter build apk --release` (via `scripts/release/build-android.sh` once vendored) |

CI is `ci-flutter.yml`, releases `release-flutter.yml` with
`build-windows: false`, version bumps via
`scripts/release/bump-version.{ps1,sh}`. `dart format` does not honour
`analysis_options.yaml` excludes, so the handoff's reference Dart files are
`docs/design_handoff_cheesy_scribe/lib/*.dart.txt`. Delete them once adopted
into `lib/` (CHEESE-17, CHEESE-20).

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
    **Required check `ci / ci`** (strict: branch must be up to date with
    `main`), added 2026-09-06 (CHEESE-16) after the check first reported on
    PR #6. To change it, `PUT` (not `PATCH`, which 404s) the ruleset with the
    full body; the context must match the job name as shown in the Actions
    run.
  - `release-branches` (ruleset id 22367582, applied 2026-09-05): matches
    `refs/heads/v*/main`; deletion + non-fast-forward only. Deliberately no
    PR rule and no required check, because the release bump scripts push
    directly to the release branch.
  - Rulesets are edited with `gh api`; verify with
    `gh api repos/tkforgeworks/cheesy-scribe/rules/branches/<branch>`.
- CI: `.github/workflows/ci.yml` consumes
  `tkforgeworks/.github/.github/workflows/ci-flutter.yml@main`
  (`flutter-version: '3.47.2'`) with the canonical envelope — `push` on every
  branch but `main`, `pull_request` into `main` and `'v*/main'`. Contract from
  the repo root: `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze`, `flutter test`. Don't hand-roll steps that belong in the
  shared workflow.
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

Decided 2026-09-05 during CHEESE-1; reasoning in `docs/CHEESE-1-decomposition.md` §3.

- **Flutter / Material 3, Android only, signed APK** on GitHub Releases; Play
  Store readiness is a separate epic (CHEESE-10). Because the app is
  mobile-only by intent and the handoff is Flutter-shaped.
- **Local-first v0.1.0: no login, no backend.** Notes in SQLite (`drift`) on
  the device; app opens on `/notes`. Auth, cloud backup, delete-account are
  deferred (CHEESE-11) because the handoff names no backend and identity adds
  a project's worth of scope.
- **State: `flutter_riverpod` 3 without codegen; routing `go_router` with a
  `ShellRoute` for the four top-level destinations.** lazy-sleeper-app
  precedent.
- **Models: the handoff's plain classes**, amended: nullable `verdict` (one-line
  quote for the featured card), `price` + `priceUnit` replacing `pricePerLb`
  (no offline currency conversion), `attributeOther`, rating 0 = unrated,
  `UserProfile` reduced to a local display name. No freezed.
- **STYLE picker on the note form** sets `cheeseStyleId`; the library's
  "N TASTED", style-detail notes and Home style chips depend on it.
- **Cheese library is a bundled JSON asset** (~25–35 styles drafted by Claude,
  reviewed by Tim). Read-only reference data, no DB table.
- **Fonts bundled** (Poppins static weights; Source Serif 4 and JetBrains Mono
  variable, `FontVariation('wght', …)`); icons via the `heroicons` package.
- **Weekly reminder deferred** (CHEESE-12); Settings row shown disabled.
- **Portrait-only phone UI**; English only.
- Tests are behaviour-level widget tests with an in-memory drift DB.

## Current status

- 2026-09-05: `v0.1.0/main` cut. LICENSE + NOTICE merged in. Both org
  rulesets applied (CHEESE-2). Design handoff decomposed (CHEESE-1): plan in
  `docs/CHEESE-1-decomposition.md`, epics CHEESE-3..12 with tasks in Jira.
  No CI, no app code.
- 2026-09-06: toolchain verified (CHEESE-13), Android-only Flutter scaffold
  (CHEESE-14), org template files (CHEESE-15), CI + required `ci / ci` check
  on `main` (CHEESE-16). Next: CHEESE-17 theme/fonts/atoms, CHEESE-19 shell.
