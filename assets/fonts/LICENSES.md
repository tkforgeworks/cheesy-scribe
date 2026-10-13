# Bundled fonts

All three families are licensed under the SIL Open Font License 1.1 and are
bundled (not fetched at runtime) so the app renders offline and on first
launch. Per the OFL, the licence text ships alongside the fonts in
`licenses/`; per this repo's `NOTICE`, third-party assets keep their own
licences. Static instances are used rather than variable fonts so that
`FontWeight` in `TextStyle` selects the face directly.

| Family | Files | Source | Licence |
|---|---|---|---|
| Poppins | Regular 400, Medium 500, SemiBold 600, Bold 700 | github.com/google/fonts `ofl/poppins` | `licenses/Poppins-OFL.txt` (Indian Type Foundry) |
| Source Serif 4 | Regular 400, Semibold 600, Italic 400, Semibold Italic 600 | github.com/adobe-fonts/source-serif release 4.005R (TTF) | `licenses/SourceSerif4-OFL.md` (Adobe) |
| JetBrains Mono | Regular 400, Medium 500 | github.com/JetBrains/JetBrainsMono release 2.304 | `licenses/JetBrainsMono-OFL.txt` (JetBrains) |

Weights match the spec's type scale (`DESIGN_SPEC.md` §3). Add a face here and
in `pubspec.yaml` before using a new weight.
