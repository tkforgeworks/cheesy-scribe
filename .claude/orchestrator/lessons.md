# Orchestrator lessons: cheesy-scribe

## Standing brief context
- Shell: `export PATH="$HOME/flutter/bin:$PATH"` first. Tests: `flutter test --concurrency=4`, never the default.
- Widget tests over `pumpApp` use `testApp`, not `testWidgets`; DB calls inside a widget test go through `onDb`.
- Riverpod 3 exports no `Override`: fakes are injected by adding a named parameter to `pumpApp` in `test/support.dart`.
- The orchestrator runs the full suite and `tool/visual` renders; agents run only their slice.
- Website repo (TKForgeWorks_website): no CLAUDE.md; checks are `npm run lint`, `npm run typecheck`, `npm run build`; branches `feature/TKFW-N-topic` into `main`.

## Never delegate
- Commits, PRs, merges, Jira writes, version bumps (org rules).
- Cross-repo contracts (field names, URLs): decided in the main thread and written into every brief.

## Tier calibration
| Task shape | Tier | Evidence |
|---|---|---|
| Single-file edit spelled out statement by statement | T1 haiku | T-003: exact, 28 s, no rework |
| New widget row + provider + test inside existing patterns, Flutter | T2 sonnet | T-001: done first pass, all checks pass, 83 s |
| Form field + payload + tests inside an existing screen, Flutter | T2 sonnet | T-004: done first pass, one sensible test deviation, 102 s |
| New widget placed on 8 screens + animation coexistence + tests, Flutter | T3 opus | T-005: done first pass, good 'noticed' list (padding, forge_ui slot), 295 s |
| New page + client component with platform branching, Next.js | T3 opus | T-002: done first pass, good judgement on a wrong brief assumption, 117 s |

## Brief gaps found
- T-005: the brief asked for a `static const key` on a widget, which clashes with `Widget.key`; and named `context.forge.textSecondary`, which does not exist (use `colors.onSurfaceVariant`). Check token names against forge_ui before naming them in a brief. Also: fixing the shared contract inline first (enum + route) let two agents run in parallel on one ticket with no file conflicts; worth repeating. (2026-10-31)
- T-002 (TKFW-88): the brief told the agent to link `content/projects/cheesy-scribe.md` without checking it exists (it does not; the site has no Cheesy Scribe project page or icon asset). Verify every file a brief names with `ls` before dispatch. The agent handled it well (conditional link, reported it) rather than inventing a page. (2026-10-31)

## User preferences
- Assets that belong to another repo (app icons) are fetched at build time, never copied into a second repo (Tim, 2026-10-31, TKFW-88).
- Wants parallel work across repos so the app ticket is not held up by the website tickets. (2026-10-31)

- T1 haiku on a fully specified single-file edit (T-003, TKFW-89): exact, no rework, 28 s. Right tier when the brief spells out every statement. (2026-10-31)
- Cloudflare Pages preview builds can fail on next/font/google resolution with nothing in the diff touching fonts (2026-10-31, PR #32); a retry through the Pages API (`POST .../deployments/<id>/retry`) passed. Check the build log before treating it as a real failure.
- Cloudflare Pages does not create GitHub deployment objects for this repo; watch production through the Pages API deployments list, not `gh api .../deployments`.
- The 1Password SSH agent can refuse to sign mid-session (auth prompt unanswered); fall back to `git fetch https://…` + `gh api -X DELETE .../git/refs/heads/<branch>` for cleanup.
- A worker that papers over a missing shared-package slot (Stack overlay on a forge_ui screen) has done the right thing for its brief, but the main thread owns the follow-up: open the upstream ticket at once rather than leaving a "later" note in CLAUDE.md. FU-8 took under an hour end to end (2026-10-31).
