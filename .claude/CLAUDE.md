# cheesy-scribe — Claude reference

## What this is

Cheese-tasting notes app modeled on the 33Books tasting notebook: track,
record, and look back at cheeses tasted. **v0.2.0 is released** (2026-10-16;
v0.1.0 on 2026-10-12; GitHub release + Play internal testing). The original plan is
`docs/CHEESE-1-decomposition.md` (inventory of the design handoff, decisions,
architecture, and the ticket list mirrored in Jira epics CHEESE-3..12). The
design handoff itself lives in `docs/design_handoff_cheesy_scribe/`
(`DESIGN_SPEC.md`, `lib/theme.dart`, `lib/models.dart`, JSON schemas, hi-fi
HTML mockups). Keep this file in sync as decisions land.

## Stack & commands

Flutter 3.47.5 / Material 3, **Android only** (no desktop, iOS or web
targets). Dart package `cheesy_scribe`, application id
`com.tkforgeworks.cheesy_scribe`. Android platform only; portrait-only via the
manifest and `SystemChrome`.

Layout so far:

- `lib/main.dart` — `ProviderScope` + `ScribeApp` (`MaterialApp.router`;
  creates the router once in its State; `initialLocation` param for tests).
- `lib/app/router.dart` — `createScribeRouter()`: `ShellRoute` for every
  drawer destination, `/notes` (initial), `/library`, `/stats`, `/settings`,
  `/account`, `/about` (`NoTransitionPage`, reached with `context.go`, menu
  icon in the app bar; CHEESE-47 moved Account and About in, against
  DESIGN_SPEC §6/§7's "back app bar"), plus
  root-navigator routes `/notes/new` and `/notes/:id/edit` (`slideUpPage`,
  fullscreen dialog), `/notes/:id`, `/library/:styleId`,
  `/licenses`, `/feedback`, `/glossary`, `/glossary/:section` (`_pushedPage` = Flutter's `MaterialPage`: Android
  slide-and-fade + predictive back). No `/login`. `new` is declared before
  `:id`. **Every root route needs a `pageBuilder`**: go_router 18 looks for
  `material_ui`'s `MaterialApp`, misses ours and gives plain `builder:`
  routes a `NoTransitionPage` (CHEESE-43; `test/app_test.dart` pins it).
- `lib/app/shell/` — `ScribeShell` (Scaffold owning the drawer; screens are
  their own Scaffolds and call `ScribeShell.openDrawer(context)`, not
  `Scaffold.of`. Its `PopScope(canPop: false)` makes system back on a
  destination open the drawer, and back with the drawer open call
  `SystemNavigator.pop()`; pushed screens, sheets and the search view sit
  on navigators go_router pops first, so back stays a real back there.
  Costs the predictive back-to-home preview on destinations), `ScribeDrawer` (`DrawerDestination`/`DrawerPill`; no Sign
  out — local-first), `ScribeSearchBar` (menu icon + avatar), providers
  `appVersionProvider` (package_info_plus) and `displayNameProvider`
  (derived from settings). No placeholder screens remain.
- `lib/data/models/` — `TastingNote`, `CheeseStyle`, `AppSettings`,
  `TastingStats`, enums (`MilkType`, `TextureLevel`, `RindType`,
  `FlavorNote`, `PriceUnit`, each with a `label`); import the `models.dart`
  barrel. Plain immutable classes with `==`, `copyWith` (sentinel-based, so
  `copyWith(price: null)` clears) and JSON matching
  `docs/design_handoff_cheesy_scribe/schema/*.schema.json` — the schemas are
  maintained, and `test/data/models_test.dart` validates emitted JSON
  against them with `json_schema`. `tastedAt` is a local-midnight date
  (`YYYY-MM-DD` in JSON); `createdAt` is UTC date-time; `updatedAt`
  (CHEESE-58) defaults to `createdAt`, is stamped by the repository on
  save, and is **sync metadata excluded from `==`/`hashCode`** so the
  form's dirty check and "stored equals draft" tests are unaffected.
  `NoteTombstone` (id + `deletedAt`) is the deletion marker type.
- `lib/data/db/app_database.dart` — drift schema v3 (v2 changed no
  table, CHEESE-45; v3 added the sync bookkeeping, CHEESE-58): `notes`
  (16 `fl_*` flavor int columns, ISO text dates, enums by name, a
  normalised `search_text` haystack, plus `updated_at` and `dirty`),
  `recent_searches`, `settings` (key/value), `note_tombstones` (id +
  `deleted_at`, kept until sync has pushed the deletion), `sync_meta`
  (key/value for the sync engine; separate from `settings` because
  `SettingsRepository.save` rewrites every row).
  `app_database.g.dart` is generated and committed: after any table change
  run `dart run build_runner build --delete-conflicting-outputs` **then
  `dart format .`** (the generator's output is not format-clean and CI
  checks it). Schema bumps: raise `schemaVersion`, add a `case` to
  `_upgradeTo`; never edit a released case. The haystack stores flavor
  **labels**, so relabelling one means raising `schemaVersion` and
  `AppDatabase.searchTextVersion` together: upgrading from below it
  rebuilds every note's `search_text` after all schema steps
  (`test/data/migration_test.dart`, which starts from the **released DDL
  frozen in the test**, not from `createAll`: a subclass with a lower
  `schemaVersion` would create today's columns and make `addColumn` fail).
  The v3 step backfills `updated_at = created_at` and leaves every existing
  note dirty so a first sign-in uploads it. Enum names are what's stored and
  never change; `FlavorNote.lemon` is labelled CITRUS since CHEESE-45. `search_text.dart` holds
  `normalizeForSearch` (lower-case, diacritics folded, `[a-z0-9 ]` only),
  applied to both the stored haystack and the typed query.
- `lib/data/repositories/` — `NotesRepository` (`NotesQuery` = search +
  minRating + styleId + paging; `watchPage/watchCount/watchNote/
  watchNewest/watchAll/watchStyleCounts/watchTopStyleIds`, `newId()`;
  **`save` stamps `updatedAt` with the injectable `now` and marks the row
  dirty**, returning the stamped note; `delete` leaves a tombstone. Sync
  bookkeeping (CHEESE-58): `watchDirty/dirtyNotes`, `markClean(pushed)`
  (clears only rows whose `updated_at` still matches, so an edit during a
  push stays dirty), `applyRemote(notes)` (keeps the remote stamp, clean),
  `applyRemoteDeletions(ids)` (no tombstone), `tombstones()`,
  `clearTombstones(ids)`), `SyncMetaRepository` (`get/set/watch/clear`;
  `set(key, null)` removes), `SettingsRepository` (`watch/load/save/
  update`), `RecentSearchesRepository` (cap 10). Domain types in, domain
  types out; drift row classes (`NoteRow` etc.) never leave `lib/data`.
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
- `lib/features/account/account_screen.dart` — `AccountScreen`
  (`/account`, CHEESE-34): local profile — 72 px initial avatar, name
  (default "You"), mono `MEMBER SINCE <year> · N NOTES` (year = earliest
  note, else `AppSettings.memberSince`, which the screen stamps on first
  visit), DISPLAY NAME `ForgeBoxedField` saved on blur / Done. The drawer and
  search-bar avatar read the same `displayNameProvider`.
- `lib/features/about/about_screen.dart` — `AboutScreen` (`/about`,
  CHEESE-33): a thin wrapper over forge_ui's `ForgeAboutScreen` (layout
  and the maker line with the tinted mark live in the package; pass
  `tintMark: true`, this palette has no purple). The app supplies the
  badge, version, `AboutScreen.blurb` (TKFW voice; Tim owns the copy),
  `privacyLine`, the menu-icon `leading`, and the link callbacks:
  tkforgeworks.com and the privacy policy (`privacyUri`,
  `https://tkforgeworks.com/privacy/cheesy-scribe/`) via `url_launcher`,
  licences via `context.push('/licenses')`, Send feedback via
  `context.push('/feedback')` (`onSendFeedback`, forge_ui since rc.3). Rows are
  found in tests by the package's keys (`ForgeAboutScreen.licensesKey`,
  `feedbackKey`, …).
- `lib/features/feedback/` (CHEESE-51) — `FeedbackScreen` (`/feedback`):
  topic chips (`FeedbackTopic`), optional 1-5 `StarRating`, required
  comments (≤ 4,000), optional reply email, a "Sent with your feedback"
  card showing app version, Android version and device model
  (`feedbackDeviceProvider`, `device_info_plus`), discard sheet,
  `ForgeErrorCard` with retry on failure, snackbar + pop on success.
  `FeedbackClient` POSTs JSON to `https://tkforgeworks.com/api/feedback`,
  the relay in the TKForgeWorks_website repo (`functions/api/feedback.ts`,
  TKFW-82) that holds the Resend key and emails
  `support@tkforgeworks.com` from `feedback+cheesy-scribe@`. The JSON
  shape and the `cheesy-scribe` app id must match that function. This is
  the app's only network call; it is why the release manifest declares
  `INTERNET`, and the privacy policy describes it.
- `lib/features/about/licenses_screen.dart` — `LicensesScreen`
  (`/licenses`, CHEESE-41), opened from About and Settings: a wrapper
  over `ForgeLicensesScreen` (app Apache-2.0 + GitHub `sourceUri`,
  Flutter/packages, OFL fonts, all-rights-reserved brand line) with
  "View all notices" → `showLicensePage`
  (`ForgeLicensesScreen.allNoticesKey`). It takes the app bar's automatic
  back button, so it only has one when pushed. Don't trim that full list:
  the engine and packages compiled into the APK need their notices
  shipped. Flutter's generated `NOTICES` also lists dev_dependencies
  (build_runner, drift_dev, …; ~2 % of it) and there is no supported way
  to drop them. The fonts aren't in `NOTICES`, so `main()` calls
  forge_ui's `registerForgeFontLicenses()` to add them to
  `LicenseRegistry`.
- `lib/features/glossary/` (CHEESE-45) — `GlossaryScreen` (`/glossary`,
  pushed; "Tasting terms" in the drawer, a `pushes` entry like New tasting
  note) is the index: one row per `GlossarySection` (title, `summary`, term
  count) pushing `GlossarySectionScreen` (`/glossary/:section`, the enum
  `name`; unknown → "No such section"). The two routes are top-level
  siblings, not nested, so the note form's `?` (`GlossaryButton(section:)`:
  Rind field trailing, Milk and Texture card labels, `FlavorEntryCard.help`)
  pushes the section page alone and back returns straight to the form,
  which stays mounted with its draft. `glossary_terms.dart` holds all the
  copy (`glossaryTerms(section)`, exhaustive `definition` switches on the
  enums, so a new term doesn't compile without one); Tim owns the prose,
  edit in place. Keys: `GlossaryScreen.rowKey`,
  `GlossarySectionScreen.termKey`; tooltips `GlossaryButton.tooltipFor`
  ("Texture terms").
- `lib/features/settings/settings_screen.dart` — `SettingsScreen`
  (`/settings`, CHEESE-31): `ForgeSettingsGroup` cards (APPEARANCE theme +
  units segmented rows persisting via `SettingsRepository.update`;
  NOTIFICATIONS reminder row disabled at 45 % until CHEESE-12; ABOUT
  version, `showLicensePage`, link to `/about`). No DATA group: CSV export
  (CHEESE-32) was dropped on 2026-10-14 and its placeholder removed in
  CHEESE-55; account backup (CHEESE-11) will bring its own section.
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
- **`forge_ui`** (CHEESE-48) — the shared tkforgeworks package
  (`tkforgeworks/forge-ui`, a git dependency pinned to an exact tag,
  `v0.1.0`, its first stable release; local checkout `~/Projects/forge-ui`;
  Jira project `FU` since 2026-10-17, forge-core's is `FC`). It owns the theme
  builder, type, radii, the forge gradient, every component theme, the
  bundled fonts and the shared atoms. A defect in any of that is fixed in
  forge-ui and the pin moved to the tag that carries the fix, never
  patched here. Import `package:forge_ui/forge_ui.dart`.
- `lib/app/theme/scribe_theme.dart` — this app's palette only:
  `ScribeTokens` (raw colours), `ScribeTheme.light()/dark()`, which call
  `forgeTheme(colorScheme:, tokens:, extensions:)` with the hand-tuned
  schemes and `ForgeTokens`, and the `ScribeColors` extension for the four
  roles forge_ui has no slot for (`dottedLine`, `starActive`,
  `starInactive`, `wheelGrid`). Read colours through `context.colors`,
  `context.forge` (`textTertiary`, `rowDivider`, …) and `context.scribe`;
  text styles through `context.text` and `ForgeType.ui/serif/mono`.
- `lib/app/widgets/` — the atoms that are this app's own: `StarRating`,
  `JournalField`, `ForgeLogoBadge`/`WedgeGlyph`; import the `widgets.dart`
  barrel. The rest of DESIGN_SPEC §5 comes from forge_ui:
  `ForgeMonoLabel`, `ForgeTagCapsule`, `ForgeStatusCapsule`,
  `ForgeBoxedField`, `ForgeFab` (needs a `label`), `ForgeSkeletonList`,
  `ForgeErrorCard`, `ForgeEmptyState`, `ForgeSettingsGroup`,
  `showForgeConfirmSheet`, `ForgeWorksMark`, and the
  `EdgeInsets.withNavBarInset(context)` extension. Android draws
  edge-to-edge and a scroll view with an explicit `padding` drops the
  MediaQuery inset, so every bottom-reaching scroll padding uses
  `withNavBarInset` (CHEESE-44).
- `assets/brand/` (CHEESE-18; all rights reserved via `NOTICE`, not
  bundled): `wedge.svg`, `tkforgeworks-mark.svg` (verbatim from the parent
  design system), `launcher/*.png` (512² adaptive foreground / monochrome /
  legacy sources) and a README with the regenerate recipe: `flutter test
  tool/brand/render_launcher_sources_test.dart` renders the PNGs from the
  app's own painters (note flutter_launcher_icons adds a 16 % inset, so the
  66 dp safe zone is 90 % of the source canvas), then `dart run
  flutter_launcher_icons` (config in `pubspec.yaml`; background `#FAF6EE`)
  rewrites `android/app/src/main/res/mipmap-*`, `drawable-*dpi/
  ic_launcher_*`, `mipmap-anydpi-v26/ic_launcher.xml` and `values/
  colors.xml`. Launch (splash) background is cream / charcoal at night
  (`drawable-v21` + `drawable-night-v21/launch_background.xml`).
- Tests: `test/support.dart` — `wrap()` (themed MaterialApp for atoms),
  `openTestDatabase()` (in-memory drift, closed on teardown), `pumpApp()`
  (real app on an in-memory DB, optional seeded `AppSettings`, mocked
  package info, `testDevice` for the feedback form, and `feedbackHttp:` a
  `MockClient` for the relay; without one any network call fails the
  test) and **`testApp()`**, which must replace `testWidgets` for
  any test that calls `pumpApp`: it unmounts the tree and pumps 1 ms so
  drift's stream-cancel timer fires before flutter_test's pending-timer
  check (otherwise the test fails and `db.close()` hangs the runner).
  Repository tests use plain `test()` against `openTestDatabase()`.
  `systemBack(tester)` sends the engine's `popRoute` (the Android back
  button), unlike `tester.pageBack()`, which taps the app-bar arrow.
  **Inside a widget-test body, every direct DB call goes through
  `onDb(tester, () => …)`** (`tester.runAsync`): a drift stream read such
  as `.first` on the fake clock leaves state that makes `db.close()` hang
  at teardown (symptom: the test "did not complete" and the per-test
  timeout never fires because `pumpAndSettle`/the binding spin). `pumpApp`
  pre-loads the cheese library on the real loop and overrides
  `libraryRepositoryProvider`; `LibraryRepository.load()` answers from
  memory once loaded so providers resolve under `pumpAndSettle`. Form tests
  set a tall viewport (`tallScreen`) so the whole `ListView` is built.
- `tool/visual/render_screens_test.dart` (CHEESE-48) — renders every
  screen of the real app, seeded, in light and dark, to PNG with the real
  fonts (134 files; not part of `flutter test`): `RENDER_OUT=<dir> flutter
  test --concurrency=4 tool/visual/render_screens_test.dart`, default
  `tool/visual/out/` (gitignored). Runs are deterministic within a day
  (the new-note form defaults to today's date, so it and the rind dialog
  over it differ between days), so render before and after a change and
  compare with ImageMagick `compare -metric
  AE`: zero means pixel-identical. Use it for any change meant to leave
  the look alone, and add a scene when a screen is added.

Local toolchain (Tim's machine, reinstalled 2026-09-26): Flutter 3.47.5
(Dart 3.13.4; the same version CI and release builds pin since CHEESE-54)
at `~/flutter`, on PATH only through `.bashrc` — agent
shells must `export PATH="$HOME/flutter/bin:$PATH"` first. Android SDK 37
in `~/Android/Sdk`; Java 25 (system Corretto, and Android Studio's bundled
JBR runs Gradle). One AVD, `Medium_Phone` (API 37, Play Store image,
1080×2400 @ 420 dpi), whose config says GPU `auto`: always pass the
software-GPU flag (hardware GL segfaulted on this box). From an agent
shell, launch detached with `nohup ~/Android/Sdk/emulator/emulator -avd
Medium_Phone -gpu swiftshader_indirect -no-boot-anim -no-audio &` and poll
`adb shell getprop sys.boot_completed` (~2 min cold, ~30 s warm). The
running process is `qemu-system-x86_64 -avd Medium_Phone …`, so a liveness
check must match `"[q]emu-system.*Medium_Phone"`, not `emulator -avd`.
Stop it with `adb emu kill`. Since 2026-10-03 its QEMU process has
segfaulted (`coredumpctl`) within a minute or so once the app runs page
transitions under SwiftShader, and a crash rolls back to the boot snapshot
(installs are lost; `-no-snapshot` cold-boots). Use widget-test frame
renders for motion and Tim's phone for the device pass. `flutter emulators --launch` never returns.
Emulator screenshots look soft from display scaling; that is not an app
bug. Emulation is slow on this hardware — prefer widget-test PNG renders
for routine visual checks and the emulator for confirmation. **Run tests
with `flutter test --concurrency=4` on this machine**: the default (one
runner per core, 20) peaks at 4.4 GB against 2.3 GB, and on 2026-10-13
that pushed RAM and the 4 GB zram swap past 90 %, so `systemd-oomd`
killed the whole desktop session. **Never run
a Gradle build and the emulator at the same time** (15 GB box; both get
OOM-killed): build, `pkill -f "[G]radleDaemon"`, then launch. Release
APKs are debug-signed until the CHEESE-38 keystore exists, so
`flutter build apk --release` (~100 s, ~63 MB) is installable; copies
live in `~/cheesy-scribe-builds/`. Drive the emulator with
`adb shell input tap/text/swipe` (1080×2400 px) and
`adb exec-out screencap -p`; `adb shell uiautomator dump` exposes Flutter
text as `content-desc`, handy for finding rows. Bracket `pkill -f`
patterns (`"[q]emu-system"`) or the shell kills itself.

| Task | Command |
|---|---|
| Install | `flutter pub get` |
| Format | `dart format --output=none --set-exit-if-changed .` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Build | `scripts/release/build-android.sh` (→ `release/cheesy-scribe-<v>-android.apk` + `.aab`; `ANDROID_SIGNING=debug` for a debug-signed dry run) |

CI is `ci-flutter.yml`. Releases: `.github/workflows/release.yml` calls the
org `release-flutter.yml` (`build-windows: false`, `java-version: '21'`,
`ticket-prefix: CHEESE`) on every push to `main` / `v*/main`; it self-gates
on the pubspec version (RC on the release branch → prerelease; stable on
`main` → release; else no-op) and creates the tag when it publishes. Bumps
only via `scripts/release/bump-version.sh <rc|final>` (vendored from the
org, unchanged). `scripts/release/new-android-keystore.sh` makes the
upload keystore + `key.properties` once (both gitignored, 1Password). **Signing
is live (2026-09-12):** Tim created the keystore with the script and set
`ANDROID_KEYSTORE_BASE64` / `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS`;
`v0.1.0-rc.2` and rc.3 are keystore-signed (rc.2 still carried the
`optional` line, which is moot once the secrets exist). rc.1 was a
keystore-less dry run via `android-signing: optional` (an input added to
the org workflow for that): CI builds the debug-signed fallback, named
`-debugsigned`, with a **per-runner throwaway debug key**, so such an APK
never installs over another build (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`).
Repo
variable `JIRA_BASE_URL` is set for release-notes linking. **Play upload
(CHEESE-42):** `release.yml`'s second job, `play-store`, calls the org
`release-play-store.yml` once `release` reports `released == 'true'`: it
uploads the release's AAB to internal testing and rolls it out (What's new
= the release-note bullets, links stripped, ≤ 500 chars). Keyless auth via
Workload Identity Federation (the Cheesy Scribe Google Cloud project, repo
variables `GCP_WORKLOAD_IDENTITY_PROVIDER` + `PLAY_SERVICE_ACCOUNT`; key
creation is blocked by org policy, so no JSON key). A failed upload leaves
the GitHub release in place; re-run just that job. `dart format` does not honour
`analysis_options.yaml` excludes, so the handoff's remaining reference Dart
file is `docs/design_handoff_cheesy_scribe/lib/theme.dart.txt` (models.dart
was adopted and deleted in CHEESE-20; theme.dart.txt can go once nothing
else refers to it).

## Repo & process conventions (org standard)

- Branching (`tkforgeworks/.github/docs/branching-and-release.md`): `main` is
  the released state; work accumulates on the current release branch
  `vX.Y.Z/main` (currently **`v0.3.0/main`**, cut from `main` after the
  v0.2.0 release PR, #50); topic branches PR **into the release branch**,
  never into `main`; the release branch reaches `main` via a release PR.
  The release branch does not start on the new version: the first
  `bump-version.sh rc` takes it from the branch name.
- Branch names: `v0.3.0/CHEESE-N-short-topic`, cut from and PR'd into
  `v0.3.0/main`. GitHub deletes the remote branch when its PR merges (repo
  setting `delete_branch_on_merge`, on since 2026-10-12; it is a repository
  setting, not a ruleset rule). A branch whose PR was closed unmerged is
  still deleted by hand, as is the local copy. The exception is a release
  PR's head: the `release-branches` ruleset blocks its deletion, so a
  finished `vX.Y.Z/main` stays until it is removed with the ruleset-toggle
  runbook in the org `branch-protection-ruleset.md` (disable, delete,
  re-enable at once, verify).
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
  (`flutter-version: '3.47.5'`, as does `release.yml`; it matches the local
  toolchain and forge-ui's CI, whose goldens are pinned to it, so move all
  three together. `environment.sdk` stays `^3.13.2`: nothing needs a newer
  floor, and a lower floor costs nothing) with the canonical envelope — `push` on every
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
- Releases: **never hand-edit the version or push tags.** The pipeline is
  the org `release-flutter.yml` (see "Stack & commands"); RCs are cut with
  `scripts/release/bump-version.sh rc` on the release branch.
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
  Store readiness is a separate epic (CHEESE-10). Every release also
  publishes the signed AAB for the Play Console (CHEESE-35). Because the app is
  mobile-only by intent and the handoff is Flutter-shaped.
- **Local-first v0.1.0: no login, no backend.** Notes in SQLite (`drift`) on
  the device; app opens on `/notes`. Auth, cloud backup, delete-account are
  deferred (CHEESE-11) because the handoff names no backend and identity adds
  a project's worth of scope. The one exception (CHEESE-51, 2026-10-14): the
  feedback form posts what the user writes, on Send only, to the website's
  relay.
- **0.3.0 account and sync** (Tim, 2026-10-17, CHEESE-57; spec revised in
  forge-core FC-1, the canonical copy at
  `forge-core/docs/forge-ui_forge-core_Shared_Flutter_Packages_Spec.md`):
  Supabase through **`forge_core`** (git dependency like forge_ui), on a Pro
  org, us-east-1; Tim created the project. **Google and email/password**
  sign-in (confirmation required, forgot-password, Resend as Supabase SMTP,
  Google + email linking); Apple waits for an iOS app. **Sign-in stays
  optional**, reached from Account, and only turns on backup. Sync is
  app-side: last-write-wins per note with tombstones as a manifest diff,
  needing schema v3 first (`updated_at`, `dirty`, a tombstones table, a
  `sync_meta` table — not `settings`, whose save rewrites every row). Note
  ids are already UUID v4 and become the server `entries.id`. In-app
  deletion types DELETE; sign-out and deletion keep local notes with an
  "also erase this phone" option; the web deletion form is a website Pages
  Function at `/privacy/cheesy-scribe/delete-account/`. Sign-in and
  deletion ship in the same build (Play). Supabase URL, publishable key and
  Google web client ID arrive as `--dart-define`s (release-pipeline input,
  gitignored local define file), never committed; CI's `-debugsigned`
  builds can never sign in (no OAuth client for their key). Theme and units
  stay per device; the display name is not prefilled and is stored as
  `accounts.username` once entered. forge-ui builds the sign-in and account
  screens first (v0.2), high-reuse screens are shared-first now.
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
- **Fonts bundled as static instances**, since CHEESE-48 by forge_ui
  rather than this repo (families resolve as `packages/forge_ui/Poppins`
  and so on; the files are byte-identical to the ones this repo carried):
  Poppins 400/500/600/700, Source Serif 4 400/600 + italics, JetBrains
  Mono 400/500, all OFL. Static rather than variable so `FontWeight`
  selects the face directly (lazy-sleeper-app went variable +
  `FontVariation`; this repo does not). Icons via the `heroicons` package.
- **The look comes from forge_ui, pinned to an exact tag** (CHEESE-48,
  2026-10-13). The app keeps its palette and the widgets only it has;
  shared code is changed upstream and released, then the pin moves.
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
  screens, riverpod and package_info_plus added (CHEESE-19). Domain models + maintained JSON schemas
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
  style detail (CHEESE-29, merged). Stats + fixtures
  (CHEESE-30 + 23). Settings (31), About (33), Account (34) — all merged;
  every route is real now. Brand assets (CHEESE-18): wedge + TKFW mark
  SVGs, adaptive launcher icon, About mark, cream launch background.
- 2026-09-12: CSV export (CHEESE-32) deferred out of v0.1.0 by Tim. Release
  pipeline wired (CHEESE-38) in keystore-less dry-run mode; org
  `release-flutter.yml` gained the `android-signing` input for it (org PR
  #10). `v0.1.0-rc.1` cut the same night (CHEESE-39, `60e8fab`, run
  34674193787): tag created server-side, notes generated with Jira links,
  debug-signed APK published and verified on the Pixel_8 emulator. Tim then
  made the keystore, set the secrets and cut rc.2 and rc.3 (both
  keystore-signed; rc.3 also dropped the `optional` line). rc.3 was
  installed on his phone after one uninstall. Next:
  Tim's device pass on rc.3 → CHEESE-40 close-out.
- 2026-09-26: Play Console developer account confirmed and the app record
  created (CHEESE-36 underway, Tim). CHEESE-35: `build-android.sh` also
  builds the AAB; org `release-flutter.yml` uploads/publishes `release/*.aab`
  (org PR). Privacy policy hosted on the website
  (`TKForgeWorks_website` `content/privacy/cheesy-scribe.md` →
  `https://tkforgeworks.com/privacy/cheesy-scribe/`, the URL for the Play
  Console field) and linked from About. Flutter 3.47.2 defaults to
  targetSdk 36 / minSdk 24, which meets Play's API 36 requirement. First
  AAB to Play arrives with the next RC. Later that day: rc.4 carried the
  first AAB; Play Console internal testing is live and installs on Tim's
  test phone (CHEESE-36), listing assets are in the Console (CHEESE-37);
  35/36/37 and epics 5–8 + 10 closed (3 and 4 left for Tim). CSV
  export (CHEESE-32) is an orphan task now, no epic or fix version.
  Testers are on rc.4.
- 2026-09-27 to 2026-10-08: rc.5 (CHEESE-41 licences summary, CHEESE-42 Play
  upload job), rc.6 (CHEESE-43 page transitions, CHEESE-44 nav-bar inset),
  rc.7 (CHEESE-47 Account/About in the shell + system back).
- 2026-10-12: **v0.1.0 released** (CHEESE-40). `bump-version.sh final` →
  `0.1.0+9` (`e326eb7`), release PR #34 merged into `main` (`ff34cc6`), the
  first stable release through the pipeline (run 38333242641: GitHub
  release with APK + AAB, Play internal upload); same code as rc.7. The
  generated notes read "No notable changes": with no earlier stable tag the
  org generator diffed against rc.7. The release body was corrected by hand
  and the generator fixed in org PR #18; Play's "What's new" for build 9
  is the upload job's fallback, "Bug fixes and improvements."
  `v0.2.0/main` cut from `main`. `v0.1.0/main` was deleted the same day:
  the `release-branches` ruleset blocks deletion and has no bypass, so it
  was disabled, the branch deleted, and the ruleset re-enabled at once (the
  runbook is in the org `branch-protection-ruleset.md`). That rule also
  stops the release PR's head being auto-deleted on merge (seen with the
  0.2.0 release PR). Scope agreed the same day. **0.2.0** (the closed-testing release): CHEESE-45 glossary of tasting
  terms, CHEESE-32 CSV export (pulled forward from 1.0.0; dropped
  2026-10-14, placeholder removed in CHEESE-55), CHEESE-51 "Send
  feedback" link in About, CHEESE-48 forge_ui adoption, CHEESE-50 opening
  the Play closed testing track (Console work; promoted from internal by
  hand), CHEESE-53 the Dependabot updates in one bundled change plus a pub
  `groups` entry, done last before the final bump (Dependabot PRs target
  `main` and are never merged there directly). **1.0.0** (the public store release): CHEESE-46 production track,
  CHEESE-49 guided first-use tour, CHEESE-52 choosing the Play track from
  the pipeline, CHEESE-11 account + sync, CHEESE-12 weekly reminder
  (CHEESE-11 moved to its own 0.3.0 on 2026-10-16).
- 2026-10-13: forge_ui adopted (CHEESE-48): theme, fonts, shared atoms,
  About and licences now come from `forge_ui`; 26 files and
  `assets/fonts/` deleted. Pinned to `v0.1.0-rc.2`: rc.1 required Dart
  `^3.13.4`, which CI's Flutter 3.47.2 (Dart 3.13.2) could not resolve and
  the local 3.47.5 could, so a green local run does not prove `pub get`
  works in CI. forge-ui lowered its floor (forge-ui PR #9); moving this
  repo's own Flutter pin is CHEESE-54. Checked with `tool/visual` renders against the
  pre-adoption build, 94 per run: 90 pixel-identical, 4 intended (the date
  picker's headline is now Poppins instead of the platform font, and
  Flutter's licence page gets the Heroicons back arrow). `v0.2.0-rc.1`
  shipped it; Tim's device pass on rc.1 found it matching (2026-10-14).
- 2026-10-14: CHEESE-51 rescoped by Tim from a mailto link to an in-app
  form that submits itself. forge-ui PR #10 added
  `ForgeAboutScreen.onSendFeedback` (released as `v0.1.0-rc.3`); TKFW-82 adds the website relay (PR #26, Resend key in the Pages
  secret `RESEND_API_KEY`, WAF rate limit 3 per 10 s per IP on
  `/api/feedback`) and the privacy-policy update (PR #27, a draft to merge
  when the RC with the form is cut). Preview deploys sit behind
  Cloudflare Access, so the relay is tested from a logged-in browser.
  The Play Data safety form must be updated in the Console before that RC
  reaches testers.
- 2026-10-14: CHEESE-45 glossary. Tim reviewed the terms first: no change
  to the set of flavors, textures, rinds or milks; LEMON relabelled CITRUS
  (search text rebuilt by the v2 migration); CRUMBLY / CRYSTALLINE stay on
  the wheel and are defined as textures; STINKY stays informal (definition
  says pungent); ROBUST = savory with richness and depth; GRASSY = the farm
  and barnyard, HERBAL = its more floral cousin. Claude drafted the copy in
  Tim's voice; Tim kept it. Shipped in rc.3 as one long page; after the
  device pass Tim asked for an index plus a page per section, with the
  form's `?` going straight to its section (PR #45, rc.4); Tim passed it
  on rc.4.
- 2026-10-14: CSV export (CHEESE-32) dropped by Tim in favour of
  account-based cloud backup (CHEESE-11); it may return only if a web or
  desktop app is spun off. CHEESE-55 removes the Settings placeholder.
- 2026-10-16: Flutter pin moved 3.47.2 → 3.47.5 in CI and release
  (CHEESE-54; Tim chose 3.47.5 over the newer 3.47.7 so local, CI and
  forge-ui stay on one version). Local renders were already on 3.47.5, so
  the first build on the new engine to check is the next RC on a device.
- 2026-10-16: Dependabot's five pub PRs (#35–39, against `main`) taken
  as one change on `v0.2.0/main` (CHEESE-53): build_runner 2.16.2, drift
  2.35.2, drift_dev 2.35.1, url_launcher 6.3.3, go_router 18.1.0 (one minor
  past the PR's 18.0.2). Regenerated drift code was identical; renders
  pixel-identical. `.github/dependabot.yml`'s pub block now has a
  `pub-minor-patch` group, effective once it reaches `main` with the 0.2.0
  release PR. Future Dependabot PRs still target `main` and are handled
  the same way: bundled on the release branch, never merged into `main`.
- 2026-10-14: forge_ui `v0.1.0` released (forge-ui PRs #11 status, #12
  release; the package code is identical to rc.3) and re-pinned here under
  CHEESE-48. No RC was cut for the re-pin; it ships with the next one.
- 2026-10-16: rc.5 (CHEESE-53, 54, 55 and the forge_ui re-pin) passed
  Tim's device pass; the Play Data safety form was updated for the
  feedback form and sent for review. **v0.2.0 released**:
  `bump-version.sh final` → `0.2.0+15` (`8c2a531`), release PR #50 merged
  into `main` (`dd39d21`), run 38987356589 (GitHub release with APK + AAB,
  Play internal upload); same code as rc.5. The notes diffed against
  v0.1.0 as intended (org PR #18). Dependabot's grouping took effect at
  once: one grouped PR, #51 (package_info_plus 10.2.2), against `main`,
  left open and bundled on the release branch before the 0.3.0 final, as
  CHEESE-53 did. Old branches cleared with the runbook: here
  `v0.2.0/main`; in forge-ui `v0.0.1/main`, `v0.1.0/main` and six merged
  `v0.1.0/*` topic branches (forge-ui now has only `main`).
- 2026-10-16: **0.3.0 split out** by Tim: account and cloud sync
  (CHEESE-11) is big enough to test on the closed track by itself before
  the store release, so it is the whole of 0.3.0. 1.0.0 keeps CHEESE-46,
  49, 52 and 12. `v0.3.0/main` cut from `main` at `dd39d21` (CHEESE-56).
  CHEESE-50 (closed track) is still Tim's to open.
- 2026-10-17: **0.3.0 plan settled** (CHEESE-57). Tim answered the ten
  decisions (recorded as a comment there; summary under "Architecture
  decisions"). Jira projects `FC` (forge-core) and `FU` (forge-ui) created.
  Spec revised in forge-core FC-1 (PR #7 into its `v0.1.0/main`), forge-ui's
  copy replaced by a pointer in FU-1 (PR #13; `v0.2.0/main` cut there).
  CHEESE-11 retitled "Account and cloud sync (0.3.0)" with the agreed scope.
  Tickets created 2026-10-18 (CHEESE-57 comment has the map and order):
  FC-2..12, FU-2..6, CHEESE-58..67 under CHEESE-11, TKFW-83 (website
  deletion page) and TKFW-84 (`release-flutter.yml` dart-define input).
  Tim authorised merging own PRs once CI passes, except any cheesy-scribe
  PR that preps an RC.
- 2026-10-18: schema v3 sync bookkeeping (CHEESE-58): `updated_at` +
  `dirty` on notes, `note_tombstones`, `sync_meta`, the repository's sync
  calls, `TastingNote.updatedAt`; migration test rebuilt on frozen released
  DDL. Renders pixel-identical. The sync engine (CHEESE-62) builds on it
  once forge-core FC-8 exists.
