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
`com.tkforgeworks.cheesy_scribe`. Android platform only; portrait-only via the
manifest and `SystemChrome`.

Layout so far:

- `lib/main.dart` — `ProviderScope` + `ScribeApp` (`MaterialApp.router`;
  creates the router once in its State; `initialLocation` param for tests).
- `lib/app/router.dart` — `createScribeRouter()`: `ShellRoute` for `/notes`
  (initial), `/library`, `/stats`, `/settings` (`NoTransitionPage`), plus
  root-navigator routes `/notes/new` and `/notes/:id/edit` (`slideUpPage`,
  fullscreen dialog), `/notes/:id`, `/library/:styleId`, `/account`,
  `/about`. No `/login`. `new` is declared before `:id`.
- `lib/app/shell/` — `ScribeShell` (Scaffold owning the drawer; screens are
  their own Scaffolds and call `ScribeShell.openDrawer(context)`, not
  `Scaffold.of`), `ScribeDrawer` (`DrawerDestination`/`DrawerPill`; no Sign
  out — local-first), `ScribeSearchBar` (menu icon + avatar), providers
  `appVersionProvider` (package_info_plus) and `displayNameProvider` (null
  until CHEESE-21/34), and `placeholder_screens.dart` — one class per route,
  each naming the ticket that replaces it; delete them as tickets land.
- `lib/data/models/` — `TastingNote`, `CheeseStyle`, `AppSettings`,
  `TastingStats`, enums (`MilkType`, `TextureLevel`, `RindType`,
  `FlavorNote`, `PriceUnit`, each with a `label`); import the `models.dart`
  barrel. Plain immutable classes with `==`, `copyWith` (sentinel-based, so
  `copyWith(price: null)` clears) and JSON matching
  `docs/design_handoff_cheesy_scribe/schema/*.schema.json` — the schemas are
  maintained, and `test/data/models_test.dart` validates emitted JSON
  against them with `json_schema`. `tastedAt` is a local-midnight date
  (`YYYY-MM-DD` in JSON); `createdAt` is UTC date-time.
- `lib/data/db/app_database.dart` — drift schema v1: `notes` (16 `fl_*`
  flavor int columns, ISO text dates, enums by name, a normalised
  `search_text` haystack), `recent_searches`, `settings` (key/value).
  `app_database.g.dart` is generated and committed: after any table change
  run `dart run build_runner build --delete-conflicting-outputs` **then
  `dart format .`** (the generator's output is not format-clean and CI
  checks it). Schema bumps: raise `schemaVersion`, add a `case` to
  `_upgradeTo`; never edit a released case. `search_text.dart` holds
  `normalizeForSearch` (lower-case, diacritics folded, `[a-z0-9 ]` only),
  applied to both the stored haystack and the typed query.
- `lib/data/repositories/` — `NotesRepository` (`NotesQuery` = search +
  minRating + styleId + paging; `watchPage/watchCount/watchNote/
  watchNewest/watchAll/watchStyleCounts/watchTopStyleIds`, `save` is an
  upsert, `newId()`), `SettingsRepository` (`watch/load/save/update`),
  `RecentSearchesRepository` (cap 10). Domain types in, domain types out;
  drift row classes (`NoteRow` etc.) never leave `lib/data`.
- `lib/data/repositories/library_repository.dart` + `assets/data/
  cheese_styles.json` — the bundled read-only library (27 styles, curated
  file order, ids are stable slugs: never rename one after release; add
  new styles at the end). `LibraryRepository.load()` caches; static
  `search()` folds diacritics. The six mocked styles keep the mockup's
  example strings (asserted in `test/data/library_test.dart`, which also
  schema-validates every entry). Tim owns the prose; edit in place.
- `lib/data/providers.dart` — `appDatabaseProvider` (drift_flutter
  `driftDatabase(name: 'cheesy_scribe')`; tests override it), the
  repository providers, `appSettingsProvider` (StreamProvider),
  `cheeseStylesProvider` / `cheeseStyleProvider(id)` (FutureProviders).
  The shell's `displayNameProvider` and `ScribeApp`'s `themeMode` read
  from settings.
- `lib/features/settings/settings_screen.dart` — `SettingsScreen`
  (`/settings`, CHEESE-31): `SettingsGroup` cards (APPEARANCE theme +
  units segmented rows persisting via `SettingsRepository.update`;
  NOTIFICATIONS reminder and DATA export rows disabled at 45 % until
  CHEESE-12 / 32; ABOUT version, `showLicensePage`, link to `/about`).
- `lib/features/library/` — `LibraryScreen` (`/library`, CHEESE-29):
  `ScribeSearchBar` with a controller filters the 2-col `StyleCard` grid
  inline via `LibraryRepository.search`; counts from `styleCountsProvider`.
  `StyleDetailScreen` (`/library/:styleId`): description, TYPICAL PROFILE
  (milk capsules + read-only `TextureMeter`), the user's notes for that
  style (`notesPageProvider(NotesQuery(styleId:))`), untasted state with a
  "New tasting note" CTA → `/notes/new?style=<id>` (the form's
  `initialStyleId`; preselection is not "dirty").
- `lib/features/stats/stats_screen.dart` — `StatsScreen` (`/stats`,
  CHEESE-30) derives `TastingStats.fromNotes(allNotesProvider)`: two
  `StatTile`s, `TopFlavorsCard` (≤ 6 bars, counts = notes scoring ≥ 3),
  `MilkBreakdownCard` (stacked bar in `lightSeries`/`darkSeries`, legend
  with rounded percents, `verdictLine`). Under 3 notes both charts give
  way to `StatsScreen.needMaterial`. Model rules (CHEESE-23) live on
  `TastingStats`: `hasEnoughForCharts`, `milkShares`, `dominantMilk`
  (strict lead, else null), `verdictLine`; `test/fixtures/
  stats_128_notes.json` reproduces the mockup's 128 / 4.2 / 62-22-11-5.
- `lib/features/notes/notes_home_screen.dart` — `NotesHomeScreen` for
  `/notes` (CHEESE-24): pinned search-bar header, "Your tastings" + mono
  count, chips (All · 4★ and up · top style ids from `topStyleIdsProvider`
  named via the library), `FeaturedNoteCard` (newest note, hidden while a
  filter is active, and excluded from the rows), `NoteRow`s with dividers,
  paging by growing `NotesQuery.limit`, long-press sheet Edit / Delete →
  confirm sheet, FAB slides/fades out on scroll-down. Providers:
  `notesPageProvider(query)`, `notesCountProvider(query)`,
  `newestNoteProvider`, `topStyleIdsProvider`. The header's bar is
  `NotesSearchAnchor` (`notes_search.dart`, CHEESE-25): a full-screen
  `SearchAnchor` view; blank query shows recent searches
  (`recentSearchesProvider`, remove per row), typing lists `NoteRow`
  results for `NotesQuery(search:)`, result tap / submit records the
  term, "0 RESULTS" state has a Clear search button. The search haystack
  includes flavor labels scored ≥ 3 only.
- `lib/features/notes/note_form_screen.dart` — `NoteFormScreen({noteId})`
  for `/notes/new` and `/notes/:id/edit` (CHEESE-27): controllers per text
  field, picker fields (date, rind, style) use display-only controllers,
  `_build()` assembles a `TastingNote` from state and the dirty check is
  `_build() != _initial` (model equality). Save → upsert; new notes
  `pushReplacement` to `/notes/:id`, edits `pop`. `PopScope` + close X
  share the discard sheet. `note_dates.dart` `formatTastingDate` ("Aug 12,
  2026"; English only, no intl). `widgets/pickers.dart`: `showRindPicker`,
  `showStylePicker` (searchable) returning `PickResult` (cleared vs value
  vs dismissed).
- `lib/features/notes/note_detail_screen.dart` — `NoteDetailScreen`
  (CHEESE-28) streams `noteProvider(id)`; pops itself when the note is
  deleted underneath it (`ref.listen`: had data → `AsyncData(null)`);
  unknown id shows the "This note is gone" empty state with no pencil.
  Sections hide when empty (stars if unrated, NOTES, wheel). Shows the
  verdict as an italic line under the maker line (not in the mockup; the
  field otherwise never surfaces outside the featured card).
- `lib/features/notes/widgets/texture_meter.dart` — `TextureMeter`
  (Slider when `onChanged` is set, painted track + thumb when read-only)
  shared by form and detail. `PriceUnit.format(28)` → `$28/LB`.
- `lib/features/notes/widgets/` — `FlavorWheel` (+ `FlavorWheelGeometry`:
  spec-sheet SVG maths scaled to width; `hitTest` → (spoke, ring), ring 0 =
  clear; polygon animates 250 ms; `onChanged == null` = read-only),
  `FlavorList` (5 pips per row, `FlavorList.pipKey(flavor, n)` for tests),
  `FlavorEntryCard` (Wheel/List toggle, helper line; read-only card when
  `onChanged` is null). Both modes edit one `Map<FlavorNote,int>`; zeros
  are removed from the map, never stored.
- `lib/app/theme/scribe_theme.dart` — tokens, `ScribeColors` extension
  (incl. `wheelGrid`), `ScribeTheme.light()/dark()`,
  `ScribeTheme.ui/serif/mono` helpers, `context.colors/text/scribe`
  shorthands, component themes (drawer, segmented button, chips, …).
- `lib/app/widgets/` — the DESIGN_SPEC §5 atoms (`MonoLabel`, `TagCapsule`,
  `StatusCapsule`, `StarRating`, `JournalField`, `BoxedField`, `ForgeFab`,
  `ForgeLogoBadge`/`WedgeGlyph`, `SkeletonRow`, `ErrorCard`, `EmptyState`,
  `showConfirmSheet`); import the `widgets.dart` barrel.
- Tests: `test/support.dart` — `wrap()` (themed MaterialApp for atoms),
  `openTestDatabase()` (in-memory drift, closed on teardown), `pumpApp()`
  (real app on an in-memory DB, optional seeded `AppSettings`, mocked
  package info) and **`testApp()`**, which must replace `testWidgets` for
  any test that calls `pumpApp`: it unmounts the tree and pumps 1 ms so
  drift's stream-cancel timer fires before flutter_test's pending-timer
  check (otherwise the test fails and `db.close()` hangs the runner).
  Repository tests use plain `test()` against `openTestDatabase()`.
  **Inside a widget-test body, every direct DB call goes through
  `onDb(tester, () => …)`** (`tester.runAsync`): a drift stream read such
  as `.first` on the fake clock leaves state that makes `db.close()` hang
  at teardown (symptom: the test "did not complete" and the per-test
  timeout never fires because `pumpAndSettle`/the binding spin). `pumpApp`
  pre-loads the cheese library on the real loop and overrides
  `libraryRepositoryProvider`; `LibraryRepository.load()` answers from
  memory once loaded so providers resolve under `pumpAndSettle`. Form tests
  set a tall viewport (`tallScreen`) so the whole `ListView` is built.

Local toolchain (Tim's machine): Flutter 3.47.2 at `~/develop/flutter`, on
PATH only through the shell rc — agent shells must
`export PATH="$HOME/develop/flutter/bin:$PATH"` first. Android SDK 37 in
`~/Android/Sdk`, JDK 21. AVDs `Pixel_10_Pro`, `Pixel_8`, `Pixel_7a` are set
to software GPU (hardware GL segfaults on this box). From an agent shell,
launch detached with `nohup ~/Android/Sdk/emulator/emulator -avd Pixel_10_Pro
-gpu swiftshader_indirect -no-boot-anim -no-audio &` and poll
`adb shell getprop sys.boot_completed`; `flutter emulators --launch` never
returns. Emulation is slow on this hardware — prefer widget-test PNG renders
for routine visual checks and the emulator for confirmation. **Never run
a Gradle build and the emulator at the same time** (15 GB box; both get
OOM-killed): build, `pkill -f "[G]radleDaemon"`, then launch. Release
APKs are debug-signed until the CHEESE-38 keystore exists, so
`flutter build apk --release` (~100 s, ~63 MB) is installable; copies
live in `~/cheesy-scribe-builds/`. Drive the emulator with
`adb shell input tap/text/swipe` (Pixel_8: 1080×2400 @ 420 dpi) and
`adb exec-out screencap -p`. Bracket `pkill -f` patterns
(`"[e]mulator -avd"`) or the shell kills itself.

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
`analysis_options.yaml` excludes, so the handoff's remaining reference Dart
file is `docs/design_handoff_cheesy_scribe/lib/theme.dart.txt` (models.dart
was adopted and deleted in CHEESE-20; theme.dart.txt can go once nothing
else refers to it).

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
  `tastedAt` date-only + `createdAt` tiebreak, `UserProfile` dropped in
  favour of `AppSettings.displayName` (CHEESE-20, 2026-09-11). No freezed.
- **STYLE picker on the note form** sets `cheeseStyleId`; the library's
  "N TASTED", style-detail notes and Home style chips depend on it.
- **Cheese library is a bundled JSON asset** (~25–35 styles drafted by Claude,
  reviewed by Tim). Read-only reference data, no DB table.
- **Fonts bundled as static instances** (`assets/fonts/`, OFL, licences in
  `LICENSES.md` there): Poppins 400/500/600/700, Source Serif 4 400/600 +
  italics, JetBrains Mono 400/500. Static rather than variable so
  `FontWeight` selects the face directly (lazy-sleeper-app went variable +
  `FontVariation`; this repo does not). Icons via the `heroicons` package.
- **Weekly reminder deferred** (CHEESE-12); Settings row shown disabled.
- **Portrait-only phone UI**; English only.
- Tests are behaviour-level widget tests with an in-memory drift DB.
- **Riverpod 3 does not export `Override`**, so helpers cannot take a
  `List<Override>`; seed state through the DB instead (`pumpApp(settings:)`).

## Current status

- 2026-09-05: `v0.1.0/main` cut. LICENSE + NOTICE merged in. Both org
  rulesets applied (CHEESE-2). Design handoff decomposed (CHEESE-1): plan in
  `docs/CHEESE-1-decomposition.md`, epics CHEESE-3..12 with tasks in Jira.
  No CI, no app code.
- 2026-09-06: toolchain verified (CHEESE-13), Android-only Flutter scaffold
  (CHEESE-14), org template files (CHEESE-15), CI + required `ci / ci` check
  on `main` (CHEESE-16), theme + bundled fonts + shared atoms (CHEESE-17).
- 2026-09-11: app shell — go_router ShellRoute + drawer + placeholder
  screens, riverpod and package_info_plus added (CHEESE-19). CHEESE-18
  brand assets still open. Domain models + maintained JSON schemas
  (CHEESE-20). Drift DB + repositories + providers, settings wired into
  the shell (CHEESE-21). Bundled cheese library + loader (CHEESE-22).
  Flavor wheel / list / entry card (CHEESE-26). Note form, new + edit
  (CHEESE-27). Note detail (CHEESE-28). Home list (CHEESE-24). All of
  #8–#16 merged into `v0.1.0/main` the same day and the tickets closed;
  the end-to-end goal (enter a note, view it) was confirmed on the
  Pixel_8 emulator and on Tim's Pixel 10 Pro Fold via a debug-signed
  release APK. Stacked-PR lesson: retarget dependents with the REST API
  (`gh api -X PATCH …/pulls/N -f base=…`) before deleting a merged base
  branch, or GitHub closes them; `gh pr edit --base` is broken by a
  GraphQL deprecation. Search view (CHEESE-25, merged) and library grid +
  style detail (CHEESE-29, merged). Stats screen + stats fixtures
  (CHEESE-30 + 23). Next: 31 settings, 33 about, 34 account, 18 brand
  assets, 32 CSV, then 38 release pipeline (needs Tim's keystore) → 39
  rc.1.
