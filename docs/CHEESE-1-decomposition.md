# CHEESE-1 — Design handoff decomposition

Status: **decided** (2026-09-05). Section-3 questions were answered by Tim the same day; the
answers are recorded inline and the ticket list in section 6 is the one cut into Jira. Source: `docs/design_handoff_cheesy_scribe/`
(README, DESIGN_SPEC.md, lib/theme.dart, lib/models.dart, schema/*.json, hi-fi mockups,
spec sheet). Constraints set by Tim before this analysis:

- **Flutter / Material 3**, as the handoff assumes.
- **Android only.** Release artifact is a signed **APK**; no Windows, Linux, iOS or web targets.
- Org standards apply: version-branch flow, `ci-flutter.yml`, `release-flutter.yml`
  (`build-windows: false`), commit subjects `CHEESE-N: ...`.

This document is the plan the Jira tickets are cut from. Section 3 lists what the handoff
did not answer and how each was resolved.

---

## 1. What the handoff contains

| File | Fidelity | Notes |
|---|---|---|
| `DESIGN_SPEC.md` | High. Tokens, type scale, shape, component → M3 widget map, 9 screens, nav map, states, motion, assets. | The closest thing to a spec. Behaviour is described per screen but not per interaction; no acceptance criteria. |
| `lib/theme.dart` | Paste-ready. `ScribeTokens`, `ScribeColors` `ThemeExtension`, `ScribeTheme.light()/dark()`, text theme. | Depends on `google_fonts`. Comments say the FAB gradient needs a `DecoratedBox` wrapper. Not yet formatted with `dart format`. |
| `lib/models.dart` | Paste-ready plain classes with JSON. `TastingNote`, `CheeseStyle`, `UserProfile`, `AppSettings`, `TastingStats.fromNotes`. | Storage-agnostic. Several fields have no UI (below). |
| `schema/*.schema.json` | Mirrors `models.dart` for the two persisted entities. | Described as "API/storage contract" but there is no API. |
| `design/Cheese Notes App.dc.html` | Hi-fi mockups, directions 1a (ships), 1b (dark source), 1c (remaining screens in 1a). | Sample user "Tyler", 128 notes. Screens: Login, Home, Drawer, New note (wheel and list modes), Detail, Library, Stats, Account, Settings. **Not mocked:** About, style detail, search view, create-account, forgot-password, edit/delete sheet, discard sheet, empty/loading/error states (spec-sheet shows states as components). |
| `design/spec-sheet.html` | Per-component measurements in dp. | Authoritative for sizes where the spec is vague. |
| `design/android-frame.jsx`, `support.js` | Mockup runtime scaffolding. | Not design content. Delete or ignore. |

Brand assets in the bundle: the cheese-wedge glyph exists only as an inline SVG path
(`M2.8 16.8v-4.6L21.2 6v10.8H2.8z` + three circles, 24×24 viewBox). No launcher icon, no
photography, no TKFW anvil mark (it lives in the parent design system; the org repo has the
lockup SVGs under `profile/assets/`).

### Data model as handed off

`TastingNote`: id, cheeseName*, tastedAt*, creamery, origin, rind (enum + rindOther),
pricePerLb, milk (enum, default cow) + milkOther, isGrassfed, isRaw, rating 0–5 whole,
texture (6-level enum), notes, flavors (16 spokes → 0–5), cheeseStyleId, photoUrl.
`CheeseStyle`: id, name, examples, description, typicalMilk[], typicalTexture.
`UserProfile` and `AppSettings` as shown in the Account and Settings screens.
`TastingStats` is derived client-side.

---

## 2. What is already decided

| Decision | Source |
|---|---|
| Flutter, Material 3, direction 1a light + derived dark, theme.dart tokens are final | handoff, Tim |
| Android only; signed APK; no desktop builds | Tim |
| Org CI (`ci-flutter.yml`, pin `flutter-version: '3.47.2'` to match lazy-sleeper-app) and release (`release-flutter.yml` with `build-windows: false`) | org standard |
| Fonts bundled locally, not fetched at runtime (org precedent in lazy-sleeper-app; handoff recommends it) | handoff + precedent |
| Icons: Heroicons outline; `heroicons` pub package (MIT) | handoff |
| Routing: `go_router` with a `ShellRoute` owning Scaffold + drawer for the four top-level routes | handoff |
| Name "Cheesy Scribe" (the mock calls it a working name; the repo, Jira project and NOTICE already use it) | repo state |
| **Local-first v0.1.0: no login, no backend.** Notes in SQLite on the device; app opens on `/notes`. Auth, cloud backup, delete-account deferred | Tim, 2026-09-05 (A1) |
| **Cheese library dataset drafted by Claude (~25–35 styles) for Tim's review** in the PR | Tim (A2) |
| **Weekly reminder deferred**; Settings row shown disabled with a "Coming soon" subtitle | Tim (A3) |
| **Application id `com.tkforgeworks.cheesy_scribe`**, Dart package `cheesy_scribe` | Tim (A4) |
| **STYLE picker added to the note form** (optional, searchable over the library) | Tim (B1) |
| **Optional one-line `verdict` field** added to model and form; featured card shows it, falls back to first sentence of notes | Tim (B2) |
| **Account screen becomes a local profile**: avatar initial, editable display name, "N NOTES" meta. Email/password/providers/sign-out/delete removed until auth ships | Tim |
| **Distribution: signed APK on GitHub Releases now, and prepare for Play Store** (AAB, Play Console, listing, privacy policy) as a separate epic | Tim |

---

## 3. Gaps and open questions

Grouped by how much they changed the ticket list. **A** blocked the breakdown; **B** and **C**
shape individual tickets; **D** are judgment calls applied unless overruled. Resolutions are
marked **Decided:**.

### A. Product scope (blocking)

**A1. Backend, auth and cloud.** The Login screen (email/password, Google, Apple), Account
screen (change password, connected providers, delete account, "member since"), the "Back up
to cloud" switch and `UserProfile` all presuppose a backend and an identity provider. The
handoff specifies none, and the schemas are labelled a storage contract with nothing behind
them. Apple sign-in on an Android-only app is also unusual (web-flow only, and Apple's
requirement to offer it applies to iOS). Options:

1. **Local-first v0.1.0** (recommended). No login; notes live on the device in SQLite; the
   app opens on `/notes`. Login, Account, cloud backup and delete-account move to a later
   version once a backend is chosen. Account screen shrinks to a local display name.
2. **Supabase now.** Auth (email + Google) and a `tasting_notes` table with RLS, offline
   cache on device. The org already runs Supabase for lazy-sleeper. Adds a backend project,
   secrets, sync/conflict handling and auth UI to v0.1.0.
3. **Firebase now.** Same scope as 2 with Firebase Auth + Firestore.

**Decided: option 1, local-first.** `UserProfile` is reduced to a local display name;
Login and the auth parts of Account are out of v0.1.0.

**A2. Cheese library content.** The Library screen shows "69 STYLES"; six are mocked with
name, examples and a tasted count. Nothing else in the bundle defines the library. Someone
has to author id/name/examples/description/typicalMilk/typicalTexture for every style and
it ships as a bundled JSON asset. Options: I draft a reviewed set (~25–35 styles covering
the standard families) for Tim to edit; Tim supplies the list; or v0.1.0 ships the six.

**Decided: Claude drafts the set, Tim reviews it in the PR.**

**A3. Weekly reminder notification** ("Sundays at 5 PM"). Needs
`flutter_local_notifications`, the Android 13+ `POST_NOTIFICATIONS` runtime permission,
exact-alarm handling on Android 12+, and reschedule-after-reboot. Self-contained but not
small. Ship in v0.1.0, or show the row disabled ("Coming soon") and defer?

**Decided: deferred.** Row rendered disabled with a "Coming soon" subtitle.

**A4. Android application id.** Cannot change after the first APK reaches a device.
Precedent: `com.tkforgeworks.lazy_sleeper_app`. Proposal: `com.tkforgeworks.cheesy_scribe`.
**Decided: `com.tkforgeworks.cheesy_scribe`.** Distribution: signed APK on GitHub Releases
from the first RC, **and** prepare for the Play Store (AAB build, Play Console, listing
assets, privacy policy) as its own epic. The org `release-flutter.yml` only uploads
`release/*.apk`, so the AAB needs `build-android.sh` to also produce `release/*.aab` and the
org workflow's artifact/asset globs extended — an org-repo PR.

### B. Data model and behaviour gaps

**B1. No style picker on the note form.** The form has no field that sets
`cheeseStyleId`, yet the Library's "N TASTED" counts, the style detail's filtered notes
and the Home filter chips ("Blue", "Alpine" — "style tags derived from user's data") all
depend on it. Proposal: add a STYLE journal field (dotted line, opens a searchable picker
over the library, optional). **Decided: add the picker.**

**B2. Featured-card quote.** The featured card shows an italic quote ("Wrapped in
pear-brandy leaves. Tastes like winning an argument."). The detail screen's notes prose
for the same cheese begins differently, so the quote is not the first sentence of `notes`
and there is no field for it. Options: derive (first sentence of notes, truncated) or add
an optional one-line `verdict` field to the form and model. **Decided: add `verdict`
(nullable); featured card shows it and falls back to the first sentence of notes.**

**B3. Rind entry.** Model: `RindType` enum + `rindOther`. Mock: RIND is a plain dotted
text line. Proposal: dotted field that opens a bottom-sheet single-select over the enum
with "Other" revealing free text, so the model stands.

**B4. Attribute "Other".** The milk card's second row (Grassfed / Raw / Other) has an
"Other" chip that reveals free text, but the model only has `milkOther` for the milk
enum. Either add `attributeOther: String?` or drop the chip.

**B5. Price and units.** `pricePerLb` is a bare number; Settings offers `$/lb` or `€/kg`.
Currency conversion offline is impossible, so the setting cannot convert stored values.
Proposal: store `price` + `priceUnit` per note, taken from the setting at entry time; the
setting only changes the default and the label. Rename `pricePerLb` accordingly.

**B6. Flavor list pips.** Spec sheet: "6 pips, tap pip N sets score N, tap current to
clear"; wheel: 5 rings, scores 0–5. Six pips would encode 0–6. Proposal: 5 pips, 0 = none.

**B7. Rating 0.** Whole stars 0–5 with 0 the default. Proposal: 0 means unrated; hide the
score on rows and exclude from average rating.

**B8. `tastedAt` precision.** Form is a date picker; model is date-time. Proposal: store
the date at local midnight, display date only, sort by date then created-at.

**B9. Photos.** `photoUrl` is modelled with no UI. Out of scope; keep the field.

**B10. Search.** "Live-filters across name, creamery, origin, notes text, flavor tags" and
"recent searches listed until typing starts". Recent searches persist locally (cap 10).
Substring match, case- and diacritic-insensitive (Époisses).

**B11. CSV export.** "Export my notes (CSV) → share sheet". Column set to define: one row
per note, 16 flavor columns, ISO dates, `share_plus`.

### C. Design details not covered

- Dark-theme values for: milk stacked-bar series, success capsule pair, error-card tint
  (given: `#3A2320`), skeleton shimmer colours. Derive from 1b and confirm in review.
- Copy for: delete-note confirm sheet, sign-out confirm (if auth ships), About paragraph,
  style detail empty state CTA label, create-account / forgot-password (if auth ships).
- Home filter chips beyond "All" and "4★ and up": how many style chips, ordering (by
  count?), and whether milk types are also chips.
- Featured card when the newest note has no notes text: hide the quote line.
- Long-press sheet copy: "Edit" / "Delete". Delete confirm: bottom sheet per §8.
- Launcher icon: not in the bundle. Proposal: adaptive icon, forge-gradient badge with the
  white wedge as foreground, cream `#FAF6EE` background. Needs a 512×512 render.
- Tablets and landscape: mockups are phone portrait. Proposal: portrait-locked phone UI;
  tablets get the phone layout centred with a max width.
- Localisation: English only; `intl` for dates and currency formatting only.

### D. Technical choices (will apply unless overruled)

| Area | Choice | Why |
|---|---|---|
| State | `flutter_riverpod` 3, no codegen | lazy-sleeper-app precedent; constructor-style injection via overrides |
| Persistence | `drift` (SQLite) with a `notes` table, `flavors` as 16 integer columns, `recent_searches`, `settings` | Type-safe SQL for search/filter/sort and stats; migrations from day one |
| Models | Adopt handoff plain classes; drift row ↔ model mappers | Avoids freezed/json_serializable codegen for a small model |
| Library data | Bundled `assets/data/cheese_styles.json` loaded at startup | Read-only reference data; no DB table needed |
| Fonts | Bundle Poppins (static weights), Source Serif 4 and JetBrains Mono (variable; `FontVariation('wght', …)`) | Precedent; offline; startup |
| Icons | `heroicons` package | Matches TKFW; MIT |
| Charts | Hand-painted (`CustomPainter`, `Container` bars) | Spec is simple bars; no chart package |
| Wheel | `CustomPainter` + `GestureDetector` hit-testing spoke×ring; 250 ms polygon animation | Spec |
| Tests | Behaviour-level widget tests with an in-memory drift DB (`NativeDatabase.memory()`); unit tests for stats, search, CSV | Org convention: tests test behaviour |
| Lints | `flutter_lints` + `prefer_single_quotes`; `analyzer.exclude: [build/**, docs/**, android/**]` | Precedent |
| Min SDK | Flutter default (`flutter.minSdkVersion`) | No feature needs higher |
| Orientation | Portrait only | Mockups |
| Handoff `.dart` files | Move `docs/design_handoff_cheesy_scribe/lib/*.dart` to `.dart.txt` (or delete once adopted into `lib/`) | `dart format` in CI checks every `.dart` file including `docs/` |

Local toolchain on this machine: **no Flutter SDK**, Android SDK partial (platform 35,
platform-tools, build-tools), JDK 21. Installing Flutter 3.47.2 and completing the SDK is
the first task.

---

## 4. Proposed architecture

```
lib/
  main.dart                    ProviderScope + ScribeApp
  app/
    theme/                     scribe_theme.dart (from handoff), scribe_text.dart helpers, forge widgets
    router.dart                go_router: ShellRoute(/notes, /library, /stats, /settings) + full-screen routes
    shell/                     ScribeShell (Scaffold + drawer), ScribeDrawer, ScribeSearchBar
    widgets/                   atoms: TagCapsule, StarRating, JournalField, BoxedField, MonoLabel,
                               ForgeFab, StatusCapsule, SkeletonRow, ErrorCard, EmptyState, ConfirmSheet
  data/
    db/                        drift database, tables, migrations, DAOs
    models/                    TastingNote, CheeseStyle, AppSettings, TastingStats (handoff)
    repositories/              NotesRepository, LibraryRepository, SettingsRepository, RecentSearches
    providers.dart             Riverpod providers wiring repositories → features
  features/
    notes/                     home list, search view, note form, note detail, flavor wheel/list, texture meter
    library/                   grid, style detail
    stats/                     tiles, top flavors, milk breakdown
    settings/                  settings screen, about screen, csv export
    account/                   (deferred per A1)
assets/
  fonts/  brand/  data/cheese_styles.json
scripts/release/               bump-version.{sh,ps1}, build-android.sh (vendored from org)
```

---

## 5. Non-functional and release requirements

- CI: `.github/workflows/ci.yml` consuming `ci-flutter.yml@main` with the canonical envelope
  (`push: branches-ignore: [main]`, `pull_request: branches: [main, 'v*/main']`). Once it
  has reported on one PR, `PUT` the `main` ruleset to require `ci / ci`.
- Release: `.github/workflows/release.yml` consuming `release-flutter.yml@main` with
  `ticket-prefix: CHEESE`, `flutter-version: '3.47.2'`, `build-windows: false`,
  `secrets: inherit`. Repo secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
  `ANDROID_KEY_ALIAS` (keystore generated once, stored in 1Password, never regenerated).
  Repo or org variable `JIRA_BASE_URL=https://tkforgeworks.atlassian.net/browse` for
  release-notes ticket links (lazy-sleeper-app has no repo-level one; an org variable may
  exist but is not readable with the current token).
- Play Store readiness (separate epic, not gating v0.1.0 RCs): `flutter build appbundle`
  signed with the same upload key, Play App Signing enrolment, Play Console app record,
  store listing (512 icon, 1024×500 feature graphic, phone screenshots), data-safety form
  (local-only, no data collected), content rating, privacy policy page on tkforgeworks.com,
  target SDK per the current Play requirement.
- `pubspec.yaml` `version: 0.1.0+1` from the first commit (Flutter manifests hold the
  upcoming version; `bump-version.sh rc` derives `0.1.0-rc.1+2` from the branch name).
- Org template files: `.github/CODEOWNERS`, `.github/dependabot.yml` (github-actions +
  pub, weekly, grouped), `.editorconfig`, `.gitattributes`; Flutter additions to
  `.gitignore` (`/build/`, `.dart_tool/`, `/release/`, `android/key.properties`, `*.jks`).
- README: stack, run, test, release sections; License section already present.
- `.claude/CLAUDE.md`: stack table, architecture decisions, current release branch.

---

## 6. Proposed epics and tickets

Ordering is dependency order. Each task is one topic branch `v0.1.0/CHEESE-N-…` and one PR
into `v0.1.0/main`. Numbering is the order of this document; Jira keys are in the map below (created 2026-09-05).

| Epic | Key | Tasks |
|---|---|---|
| Foundation | CHEESE-3 | CHEESE-13 toolchain · 14 scaffold · 15 org templates · 16 CI + required check · 17 theme/fonts/atoms · 18 brand assets · 19 shell/routing |
| Data layer | CHEESE-4 | CHEESE-20 models · 21 drift + repositories · 22 library dataset · 23 stats |
| Tasting notes | CHEESE-5 | CHEESE-24 home · 25 search · 26 flavor wheel · 27 note form · 28 note detail |
| Cheese library | CHEESE-6 | CHEESE-29 grid + style detail |
| Stats & insights | CHEESE-7 | CHEESE-30 stats screen |
| Settings, About, local profile | CHEESE-8 | CHEESE-31 settings · 32 CSV export · 33 about · 34 local profile |
| Release pipeline | CHEESE-9 | CHEESE-38 pipeline + keystore · 39 first RC · 40 close-out |
| Play Store readiness | CHEESE-10 | CHEESE-35 AAB + org globs · 36 Play Console · 37 listing + privacy policy |
| Account and cloud sync (deferred) | CHEESE-11 | — |
| Notifications (deferred) | CHEESE-12 | — |

Suggested order: 13 → 14 → 15 → 16 → 17 → 19 → 20 → 21 → 22 → 23 → 18 → 26 → 27 → 24 → 28 → 25 →
29 → 30 → 31 → 34 → 32 → 33 → 38 → 39 → (35, 36, 37 in parallel with RC testing) → 40.

### Epic: Foundation
1. **Local toolchain** — install Flutter 3.47.2, complete Android SDK (cmdline-tools,
   platform-tools, licences), `flutter doctor` clean for Android. Not a repo change; a
   checklist ticket.
2. **Scaffold the Flutter project** — `flutter create --platforms=android
   --org com.tkforgeworks --project-name cheesy_scribe`, `version: 0.1.0+1`,
   `analysis_options.yaml`, Flutter `.gitignore`, portrait lock, application id (A4),
   handoff `.dart` files renamed so `dart format` passes, empty `main.dart` with a smoke
   test.
3. **Org template files** — CODEOWNERS, dependabot (actions + pub), .editorconfig,
   .gitattributes, `.claude/CLAUDE.md` stack table.
4. **CI** — `ci.yml` consuming `ci-flutter.yml@main`; after first green PR, `PUT` the
   `main` ruleset to require `ci / ci`; record in CLAUDE.md.
5. **Theme, fonts, icons** — adopt `theme.dart` into `lib/app/theme/`, bundle the three
   font families, `heroicons`, text helpers for the mono-uppercase label and serif-italic
   styles, `ForgeFab`, `TagCapsule`, `MonoLabel`. Golden-free widget tests that the theme
   resolves the spec's tokens.
6. **Brand assets** — export the wedge glyph to `assets/brand/wedge.svg`, logo badge
   widget (forge-gradient circle + white wedge), launcher adaptive icon via
   `flutter_launcher_icons`, TKFW anvil mark for About (asset from the org design system;
   all-rights-reserved per NOTICE).
7. **App shell and routing** — `go_router` with `ShellRoute` for `/notes`, `/library`,
   `/stats`, `/settings`; drawer per spec (width 300, pills, account row, pinned footer
   with version from `package_info_plus`); full-screen routes for `/notes/new`,
   `/notes/:id`, `/notes/:id/edit`, `/library/:styleId`, `/account`, `/about`; no
   `/login` (local-first); placeholder screens.

### Epic: Data layer
8. **Domain models** — adopt `models.dart` with the section-B changes: `verdict`
   (nullable), `price` + `priceUnit` replacing `pricePerLb`, `attributeOther`, rating 0 =
   unrated; `UserProfile` reduced to a local display name; `AppSettings` gains
   `displayName`.
9. **Drift database and repositories** — schema, DAOs, `NotesRepository` (CRUD, paged
   list, search, filter, per-style counts), `SettingsRepository`, `RecentSearches`;
   Riverpod providers; in-memory DB test harness.
10. **Cheese library dataset** (A2) — `assets/data/cheese_styles.json`, loader,
    `LibraryRepository`, validation test against `schema/cheese-style.schema.json`.
11. **Stats derivation** — `TastingStats.fromNotes` unit-tested against fixtures,
    including the `< 3 notes` rule and rating-0 exclusion.

### Epic: Tasting notes
12. **Home list** — pinned search bar, header + count, filter chips (All, 4★ and up, top
    style tags), featured card with forge strip, note rows, infinite scroll, FAB
    hide-on-scroll, empty state, skeleton loading, long-press Edit/Delete sheet + delete
    confirm.
13. **Search view** — `SearchAnchor` full-screen view, live filtering across the five
    fields, recent searches, "0 RESULTS" state, clear.
14. **Flavor wheel widget** — `CustomPainter` 16×5, tap-to-score, 250 ms polygon
    animation, read-only mode, list-mode alternative with pips; pure widget with tests.
15. **Note form** — journal fields (name, creamery, origin, date, rind picker, price,
    style picker, verdict), milk card, rating input, texture slider, notes, wheel/list card, Save
    enable rule, validation copy, unsaved-changes discard sheet, edit mode prefilled.
16. **Note detail** — meta line, header, maker line, stars, capsules, notes prose,
    read-only wheel, read-only texture meter, edit action.

### Epic: Library
17. **Library grid and style detail** — search bar variant, header + count + intro,
    2-col cards with tasted counts, style detail with description, typical profile,
    filtered notes, none-tasted state.

### Epic: Stats
18. **Stats screen** — stat tiles, top flavors bar rows, milk stacked bar + legend +
    verdict line, `< 3 notes` treatment.

### Epic: Settings and About
19. **Settings screen** — theme mode (persisted, applied to `MaterialApp.themeMode`),
    units, reminder row disabled ("Coming soon"), backup row removed, export CSV, version,
    licenses.
20. **CSV export** — serializer + `share_plus`, unit-tested column contract.
21. **About screen** — composed per spec §6; link to tkforgeworks.com; licenses.

### Epic: Local profile
22. **Account screen as local profile** — avatar initial, editable display name persisted
    in settings, "MEMBER SINCE <year> · N NOTES" meta from the first note / install date;
    drawer account row reads the name. No auth controls.

### Epic: Account and cloud sync (deferred, later version)
23. Placeholder epic holding the removed scope: login, create account, forgot password,
    Google sign-in, connected providers, sign out, delete account, cloud backup and sync,
    backend selection. Not broken down until a backend is chosen.

### Epic: Notifications (deferred, later version)
24. Placeholder epic: weekly reminder scheduling, permission flow, reboot rescheduling,
    settings toggle. v0.1.0 shows the row disabled.

### Epic: Play Store readiness
25. **App bundle build** — `build-android.sh` also emits `release/*.aab`; org PR extending
    `release-flutter.yml` artifact and release-asset globs to `*.aab`.
26. **Play Console setup** — app record for `com.tkforgeworks.cheesy_scribe`, Play App
    Signing with the upload key, internal-testing track, data-safety form (no data
    collected), content rating questionnaire.
27. **Store listing and policy** — 512 icon, 1024×500 feature graphic, phone screenshots
    from the RC, short/full description in TKFW voice, privacy policy page on
    tkforgeworks.com linked from the listing and the About screen.

### Epic: Release
28. **Release pipeline** — vendor `bump-version.{sh,ps1}` and `build-android.sh`,
    `release.yml` with `build-windows: false`, generate the upload keystore (store in
    1Password), set the three repo secrets and `JIRA_BASE_URL`, `build.gradle.kts`
    signing config as in lazy-sleeper-app, README "Releasing".
29. **First RC** — `bump-version.sh rc` on `v0.1.0/main`; verify the APK installs and
    runs on a device; fix what falls out.
30. **v0.1.0 close-out** — CLAUDE.md status, adopter tables in the org docs, `final`
    bump and release PR.
