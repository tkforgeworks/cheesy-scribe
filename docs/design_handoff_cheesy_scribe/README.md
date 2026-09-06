# Handoff: Cheesy Scribe — cheese tasting notes app

A TK ForgeWorks product. This bundle contains everything needed to implement
the app in **Flutter with Material 3**.

## Overview
Cheesy Scribe is a mobile journal for cheese tastings: sign in, log a tasting
(rating, milk, texture, 16-spoke flavor wheel, prose notes), browse/search
past notes, reference a cheese-style library, and see derived stats. Full
product/UX detail lives in `DESIGN_SPEC.md`.

## About the design files
The HTML files in `design/` are **design references created in HTML** — hi-fi
prototypes showing intended look and behavior, not production code. The task
is to **recreate these designs in Flutter** using the theme and specs in this
bundle. `design/Cheese Notes App.dc.html` shows all screens in two palette
directions; **direction 1a (cream & rind amber) is the one that ships** —
ignore the 1b charcoal frames except as the source of the dark theme.
`spec-sheet.html` is a per-component visual reference with measurements.

## Fidelity
**High-fidelity.** Colors, type, spacing, radii, and copy are final. Recreate
pixel-faithfully using the provided `ThemeData`; where stock Material 3
defaults conflict with the spec (e.g. chip radius, label placement), the spec
wins — `theme.dart` already encodes most of these deviations.

> The two Dart reference files carry a `.txt` suffix so the org CI's
> repo-wide `dart format` check skips them; strip it to use them.

## Contents
| Path | What it is |
|---|---|
| `DESIGN_SPEC.md` | Master spec: brand rules, tokens, type scale, component → M3 widget mapping, screen-by-screen layout, navigation map, empty/loading/error states, motion |
| `lib/theme.dart.txt` | Paste-ready `ThemeData` light + dark, `ColorScheme`s, `TextTheme`, `ScribeColors` ThemeExtension, forge-gradient constants |
| `lib/models.dart.txt` | Dart data model: `TastingNote`, `CheeseStyle`, `UserProfile`, `AppSettings`, `TastingStats` (derived), enums incl. the 16 `FlavorNote` spokes |
| `schema/*.schema.json` | JSON Schema for notes and styles (API/storage contract) |
| `design/Cheese Notes App.dc.html` | Hi-fi mockups, all screens (open in a browser) |
| `design/spec-sheet.html` | Component spec sheet with measurements (open in a browser) |

## Implementation notes
- `theme.dart` depends on `google_fonts` (Poppins, Source Serif 4,
  JetBrains Mono); bundle the fonts locally for offline/startup wins.
- Wire `MaterialApp(theme: ScribeTheme.light(), darkTheme: ScribeTheme.dark(),
  themeMode: ...)` — Settings > Appearance > Theme selects light/dark/system.
- Icons: **Heroicons outline** (2px stroke, `currentColor`), not Material
  Icons glyphs — matches the TK ForgeWorks system.
- The forge gradient appears in exactly three places (logo badge, extended
  FAB, featured-card strip). The parent brand's purple does not appear.
- Custom-painted widgets: flavor wheel (`CustomPainter`, spec-sheet section
  04), star rating, pip list rows, milk stacked bar. Everything else is
  themed stock M3.
- Voice matters: state/empty/error copy is specified in `DESIGN_SPEC.md` §8 —
  keep the dry TKFW tone; no emoji, no "Oops!".
- Suggested packages: `go_router` (nav map in §7), `google_fonts`,
  `flutter_svg` or `heroicons`.

## Assets
No real photography exists yet (`TastingNote.photoUrl` is modeled). The
cheese-wedge logo glyph is an SVG path inside the design files — export from
there or redraw at 24×24, 1.8px stroke. TKFW hammer/anvil mark: About screen
only, from the parent design system.
