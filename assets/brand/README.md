# Brand assets

All files in this directory are **all rights reserved** (see `NOTICE` at the
repo root); they are not covered by the Apache-2.0 grant.

| File | What it is |
|---|---|
| `wedge.svg` | The Cheesy Scribe cheese-wedge glyph: the mockups' 24×24 Heroicons-style outline (1.8 px stroke, round caps, `currentColor`). `WedgeGlyph` in `lib/app/widgets/forge_logo_badge.dart` paints the same geometry. |
| `tkforgeworks-mark.svg` | The TK ForgeWorks hammer-and-anvil mark from the parent design system (same file as lazy-sleeper-app and the website's `icon.svg`). `ForgeWorksMark` in `lib/app/widgets/forgeworks_mark.dart` paints it; About shows it once, next to "A TK ForgeWorks product", and nowhere else. |
| `launcher/icon-legacy.png` | 512×512 legacy launcher icon (API < 26): cream rounded square with the forge badge. |
| `launcher/icon-foreground.png` | 512×512 adaptive-icon foreground: the forge badge filling the 66 dp safe zone (90 % of the canvas, because flutter_launcher_icons adds a 16 % inset) on a transparent canvas. Background colour is `#FAF6EE` (cream) in `pubspec.yaml`. |
| `launcher/icon-monochrome.png` | 512×512 adaptive-icon monochrome layer (Android 13 themed icons): the wedge outline in black on transparent. |

## Regenerating the launcher icon

The PNG sources are rendered from the Flutter widgets themselves so the icon
always matches the in-app badge:

```sh
flutter test tool/brand/render_launcher_sources_test.dart
dart run flutter_launcher_icons
```

The first command rewrites the three PNGs under `launcher/`; the second
regenerates `android/app/src/main/res/mipmap-*` and
`mipmap-anydpi-v26/ic_launcher.xml` from them. Commit both.
