# Cheesy Scribe — Design Spec

A TK ForgeWorks product. Mobile app for cheese tasting notes.
Direction: **1a — cream & rind amber** (light, primary target) with a derived dark theme.
Target: **Flutter, Material 3** (non-strict — journal styling wins where they conflict).

Companion files:
- `lib/theme.dart` — paste-ready `ThemeData` (light + dark), `ColorScheme`, text styles, `ScribeColors` theme extension
- `lib/models.dart` + `schema/*.json` — data model
- `spec-sheet.html` — visual reference of every component with measurements
- `design/Cheese Notes App.dc.html` — the original hi-fi mockups (design reference, not production code)

---

## 1. Brand rules (non-negotiable)

1. **Forge gradient** (`#FBDF19 → #F68F25 → #EE3423`, 135°) appears in exactly three places: the logo badge, the extended FAB, and the 4px top strip on the featured card. Never on ordinary buttons, never as a surface, never for status.
2. **Purple does not appear in this app.** Cheesy Scribe is the one TKFW product that swaps the purple base for cheese-warm neutrals. Voice, type stack, and component shapes stay TKFW.
3. **Type stack:** Poppins (UI), Source Serif 4 (editorial/prose, often italic), JetBrains Mono (journal field labels + tag capsules, always uppercase + letterspaced).
4. **Voice:** sarcastic but warm, first person, sentence case everywhere. No emoji. Em-dashes welcome. Examples in the mocks: "Tastes like winning an argument.", "Verdict: you have a type, and it's cow.", "Your 128 notes go with it. Just saying."
5. **Flat surfaces.** No resting shadows on cards (border only). Shadows exist on: FAB, drawer, slider thumb.

## 2. Color tokens

### Light ("cream & rind amber") — primary target
| Role | Hex | M3 slot |
|---|---|---|
| Page background | `#FAF6EE` | `surface` |
| Card surface | `#FFFDF8` | `surfaceContainerLowest` |
| Search bar / inactive track | `#F2E8D5` | `surfaceContainer` |
| Selected chip / avatar bg | `#F6E5C8` | `primaryContainer` |
| Primary (buttons, stars, slider) | `#B3641B` | `primary` |
| Emphasis text / links / selected | `#93500F` | `onPrimaryContainer`, `tertiary` |
| Text primary | `#35291A` | `onSurface` |
| Text secondary / icons | `#5F5138` | `onSurfaceVariant` |
| Text tertiary / field labels | `#8A7A5F` | ext `textTertiary` |
| Hints / disabled / fine print | `#B5A684` | ext `textGhost` |
| Card border / input outline | `#E6D9BF` | `outline` |
| Row divider | `#EFE4CF` | `outlineVariant` |
| Journal dotted underline | `#C4B18B` | ext `dottedLine` |
| Star inactive | `#E0D2B4` | ext `starInactive` |
| Error / destructive | `#B3382B` | `error` |
| Drawer scrim | `rgba(35,24,8,.38)` | `scrim` |
| Success (badge) | text `#3D7A33` on `#E8F2E5` | — |

### Dark (system-setting support; charcoal chrome from direction 1b)
| Role | Hex |
|---|---|
| Page background | `#211D17` |
| Card surface | `#2B2620` |
| Search bar / inactive track | `#3B342B` |
| Primary (stars, links, slider) | `#F4B656` |
| Selected chip fill | `#EEDBB6` (text `#5C3D0D`) |
| Text primary | `#F3EAD9` |
| Text secondary | `#CBBFA8` |
| Text tertiary | `#A89A80` |
| Hints / fine print | `#7A6F5D` |
| Border | `#4A4237` · divider `#3D362D` · dotted `#6B5F4C` |
| Error | `#E5766A` |

Forge accent (both themes): yellow `#FBDF19`, orange `#F68F25`, red `#EE3423`; FAB gradient starts `#F9A825`.

## 3. Type scale
| Use | Family | Size / weight / extras |
|---|---|---|
| Cheese name, detail header | Source Serif 4 | 27 / 600, line-height 1.2 |
| Cheese name, featured card | Source Serif 4 | 21 / 600 |
| Screen title ("Your tastings") | Poppins | 22 / 600 |
| App bar title | Poppins | 18 / 600 |
| Row title, list items | Poppins | 15 / 500 |
| Body UI, inputs | Poppins | 14 / 400 |
| Notes prose | Source Serif 4 | 14.5 / 400, line-height 1.7 |
| Taglines, hints, wit lines | Source Serif 4 italic | 11.5–14 / 400 |
| Row subtitle / meta | Poppins | 11.5 / 400, tertiary |
| **Journal field label** | JetBrains Mono | 10 / 500, UPPERCASE, tracking 1.4 |
| Tag capsule / stat label | JetBrains Mono | 9.5 / 500, UPPERCASE |
| Flavor wheel spoke label | JetBrains Mono | 8 / 500, UPPERCASE |
| Big stat number | Poppins | 34 / 600, primary color |

Minimum tap target: 44×44. Text never below 8px (wheel labels only); UI text ≥ 11.5.

## 4. Shape & spacing
- Radii: **8** cards/buttons/inputs/chips · **4** mono tag capsules · **16** FAB · **28** search bar + drawer item pill · **full** avatars, toggles, status capsules.
- Screen gutter **16** (list screens) / **20–28** (forms, login). Card padding **16–18**. Vertical rhythm: 14–18 between blocks, 8 label→field.
- Borders 1px `outline`. Dividers 1px `outlineVariant`. Dotted journal underlines: 1.5px dotted `dottedLine`.

## 5. Component inventory → M3 widget mapping

| Component | M3 base | Deviations from stock M3 |
|---|---|---|
| Search bar | `SearchBar` in `SearchAnchor` | h52, radius 28, `surfaceContainer` fill, leading menu icon opens drawer, trailing avatar (32px circle, `primaryContainer` bg, initial in Poppins 600 13) |
| Filter chips | `FilterChip` | radius 8 (not stock full), selected = `primaryContainer` fill + `primary` border + checkmark; unselected = transparent + `outline` border |
| Featured card | `Card` + custom | 4px forge-gradient top strip (`ClipRRect` + `Container(decoration: forgeStrip)`); anatomy: mono meta line → serif 21 name → maker line → stars+score → tag capsules → italic serif quote |
| Note row | `ListTile` (or custom row) | 42px circle avatar with 2-letter mono initials, title 15/500, subtitle 11.5 tertiary, trailing column: stars 12px + milk tag mono 9 |
| Tag capsule | custom `Container` | radius 4, `surfaceContainer` fill (info) or `primaryContainer` fill + `onPrimaryContainer` text (emphasis), JetBrains Mono 9.5 uppercase, padding 4–5 × 8–9 |
| Extended FAB | `FloatingActionButton.extended` | wrapped in `DecoratedBox` with `forgeGradient` + radius 16 + shadow `0 6 18 rgba(238,52,35,.35)`; FAB itself transparent/elevation 0. Label: "New tasting notes" |
| Nav drawer | `NavigationDrawer` | width 300, right radius 16 only; header = logo badge + wordmark, then account row (divider-bounded); items are radius-28 pills, selected = `primaryContainer` fill + emphasis text; footer pinned: Sign out + mono fine print "A TK FORGEWORKS PRODUCT · V0.1.0" |
| Text input (auth/account) | `TextField` | filled `surfaceContainerLowest`, radius 8, outline border; label OUTSIDE the field as mono uppercase label (not floating M3 label) |
| Journal input (note form) | custom | no box — 1.5px dotted bottom border only; hint in italic serif `textGhost`; mono label above |
| Primary button | `FilledButton` | h50, radius 8, `primary` fill |
| Social auth buttons | `OutlinedButton` | h48, radius 8, side-by-side in a `Row` with 12 gap |
| Star rating | custom | 5 glyphs, active `starActive`, inactive `starInactive`; input 30px, display 12–22px; numeric score in mono beside |
| Texture meter | `Slider` (discrete, 6 stops) | track 4px, active `primary`; 6 mono labels below (RUNNY…HARD), active label emphasized; thumb 18px white-ringed |
| Milk/attr chips | `FilterChip` | single-select group (milk: Buffalo/Cow/Goat/Sheep/Other) + multi-select row (Grassfed/Raw/Other), dotted divider between groups, wrapped in one card |
| Flavor wheel | custom `CustomPainter` | 16 spokes, 5 rings; tap spoke ring to score; polygon fill `primary` @18%, stroke `primary`, 2.6px dots; labels mono 8 |
| Flavor list (alt entry) | custom rows | Wheel/List segmented toggle in card header; each row: mono label + 6 tappable pips (●○), dotted dividers |
| Segmented toggle | `SegmentedButton` | compact: radius 8, selected `primaryContainer` + emphasis text, 5–6px × 12 padding |
| Switch | `Switch` | track `primary` on / `surfaceContainer` off, white thumb, no outline |
| Settings/account rows | `ListTile` in bordered `Card` | groups titled by mono uppercase labels; trailing chevron / switch / segmented / status capsule |
| Status capsule | custom | radius full, mono 9.5: CONNECTED = green pair, NOT CONNECTED = `surfaceContainer` + tertiary |
| Stat tile | `Card` | Poppins 34/600 primary number + mono 9.5 label, 2-col grid, gap 12 |
| Bar chart row | custom | mono label w82 + 8px rounded track (`surfaceContainer` bg, `primary` fill) + mono count |
| Milk breakdown | custom | 14px stacked bar, radius 7; segments `#B3641B`/`#DFA04B`/`#F0CF95`/`#F2E8D5`; mono legend with ● swatches |
| Grey-out (SSO) | — | disabled rows at 45% opacity + explainer subtitle ("Managed by Google sign-in") |

## 6. Screens

Common: gutter 16 unless noted; app bar flat, no elevation change on scroll (`scrolledUnderElevation: 0`).

### Login (`/login`)
Column, gutter 28, no app bar. Centered: 64px forge-gradient logo circle → wordmark Poppins 700 30 → italic serif tagline ("Tasting notes for cheese you'll pretend to remember.", max-w 260, centered). Then mono-labeled email + password fields (gap 14), right-aligned "Forgot password?" text button, full-width Sign in `FilledButton`, "OR CONTINUE WITH" mono divider, Google/Apple `OutlinedButton` row. Pinned bottom: "New here? **Create an account**" + mono fine print "A TK FORGEWORKS PRODUCT". Scrolls under keyboard (`SingleChildScrollView` + `resizeToAvoidBottomInset`).

### Home / My tasting notes (`/notes`)
`CustomScrollView`. Pinned `SearchBar` (opens search view on tap; menu icon opens drawer). Header row: "Your tastings" (22/600) + mono count ("128 NOTES"). Horizontally scrolling filter chips (All · 4★ and up · style tags — derived from user's data). Featured card = most recent note (forge strip). Then note rows, divider-separated, infinite scroll. FAB bottom-right, 16 inset; hides on scroll-down, returns on scroll-up. Tap row → detail. Long-press row → bottom sheet (Edit / Delete).

**Search mode:** full-screen `SearchAnchor` view; live-filters across name, creamery, origin, notes text, flavor tags. Recent searches listed until typing starts.

### New / edit tasting note (`/notes/new`, `/notes/:id/edit`)
Full-screen dialog (slide-up route). App bar: close X · "New tasting note" · **Save** text button (disabled until cheeseName non-empty). Scroll body, gutter 20, blocks gap 18:
1. Journal fields, stacked full-width, dotted underlines: CHEESE NAME (serif italic hint "Start with what the label says"), CREAMERY, ORIGIN, DATE (defaults today, opens date picker), RIND, PRICE.
2. MILK card: single-select chips Buffalo/Cow/Goat/Sheep/Other + dotted divider + multi chips Grassfed/Raw/Other. "Other" reveals a dotted free-text field inline.
3. RATING card: 30px star input + mono score.
4. TEXTURE METER card: 6-stop slider + mono labels.
5. NOTES card: italic serif hint "What did it taste like? Be honest." — multiline, dotted ruled lines.
6. FLAVOR WHEEL card: Wheel/List segmented toggle top-right. Wheel: tap spoke×ring. List: 16 rows of 6 pips. Same data, both directions.
7. Full-width "Save to journal" `FilledButton`.
Unsaved-changes guard: back/X with edits → confirm sheet ("Discard this note? The cheese deserved better." / Keep writing · Discard).

### Note detail (`/notes/:id`)
App bar: back + edit (pencil). Gutter 24. Mono meta ("TASTED AUG 12, 2026 · $28/LB") → serif 27 name → maker/rind line → 22px stars + score → tag capsules (milk/raw = emphasis fill; texture/price = neutral) → NOTES card (serif prose 14.5/1.7) → FLAVOR WHEEL card (read-only, filled polygon) → TEXTURE card (read-only meter).

### Cheese library (`/library`)
Search bar variant ("Search the library"). Header + mono count ("69 STYLES") + italic serif intro ("Reference styles to taste against — the 'what am I even eating' section."). 2-col card grid (gap 12): style name 15/600 → mono "12 TASTED" in emphasis color → italic serif examples line. Tap → style detail: description, typical profile, and the user's notes filtered to that style. "N TASTED" comes from notes with matching `cheeseStyleId`.

### Stats & insights (`/stats`)
App bar (menu + title). Blocks gap 12: 2-col stat tiles (CHEESES TASTED · AVERAGE RATING) → TOP FLAVORS card (bar rows, counts = notes scoring that flavor ≥3) → MILK BREAKDOWN card (stacked bar + legend + italic serif verdict line, e.g. "Verdict: you have a type, and it's cow."). All derived client-side (`TastingStats.fromNotes`).

### Account (`/account`)
Back app bar. Centered: 72px avatar, name 17/600, mono meta ("MEMBER SINCE 2026 · 128 NOTES"). Editable DISPLAY NAME + EMAIL fields (mono labels, boxed inputs). Bordered group card: Change password (greyed at 45% + "Managed by Google sign-in" subtitle when `passwordAuth == false`), Google row + CONNECTED capsule, Apple row + NOT CONNECTED capsule. Then: Sign out (emphasis text), Delete account (error text) + italic serif warning "Your 128 notes go with it. Just saying." Delete → confirm dialog typing "DELETE".

### Settings (`/settings`)
Back app bar. Mono-labeled groups of bordered cards:
- APPEARANCE: Theme (Light/Dark/System segmented — writes `AppSettings.themeMode`), Units ($/lb · €/kg)
- NOTIFICATIONS: "Weekly 'go eat cheese' reminder" + subtitle "Sundays at 5 PM. You're welcome." (switch)
- DATA: Export my notes (CSV) chevron → share sheet; Back up to cloud (switch)
- ABOUT: Version (mono value), Open-source licenses chevron → `showLicensePage`

### About Cheesy Scribe (`/about`)
Logo badge, app name, version, one-paragraph serif description in TKFW voice, link to tkforgeworks.com, licenses link. (Not mocked — compose from the above vocabulary.)

## 7. Navigation map

```
/login  (unauthenticated root)
   └─ sign in → /notes
/notes  (authenticated root; drawer home)
   ├─ search view (in-place)
   ├─ /notes/new      (fullscreen dialog, slide-up)
   ├─ /notes/:id      → /notes/:id/edit (same form, prefilled)
   ├─ /library        → /library/:styleId
   ├─ /stats
   ├─ /account
   ├─ /settings
   └─ /about
```

Drawer (width 300, right-rounded 16, scrim `scrim`):
logo+wordmark header → account row → **My tasting notes** (/notes) · New tasting note (/notes/new) · Cheese library (/library) · Stats & insights (/stats) → divider → Account (/account) · Settings (/settings) · About Cheesy Scribe (/about) → spacer → Sign out → mono fine print.
Selected item = pill fill `primaryContainer` + text `onPrimaryContainer`. Drawer is available on the four top-level destinations; detail/form screens use back/close instead. Suggested: `go_router` with a `ShellRoute` owning the `Scaffold`+drawer for the four top-level routes.

## 8. Empty / loading / error states

Voice rule: every state message = one plain statement + one dry aside. Never "Oops!".

| State | Treatment |
|---|---|
| Notes list, empty (new user) | Centered: 56px wedge icon in `primaryContainer` circle → "No tastings yet" (18/600) → italic serif "The cheese isn't going to review itself." → inline `FilledButton` "New tasting notes" (FAB also present) |
| Search, no results | Mono "0 RESULTS" + italic serif "Nothing matches — either a typo or a cheese frontier." + "Clear search" text button |
| Library style, none tasted | Card shows mono "0 TASTED" in tertiary (not emphasis); detail shows "You haven't met this one yet." + CTA |
| Stats, < 3 notes | Tiles show real numbers; charts replaced by italic serif "Come back after a few more cheeses — the charts need material." |
| Loading, list | 3 skeleton rows: circle + two text bars in `surfaceContainer`, 1.2s shimmer to `primaryContainer` @ 40% |
| Loading, action | Button label swaps to 18px spinner (`onPrimary`), button stays full-size |
| Error, network | Inline card (not toast): error-tint bg `#FBEDEA`/dark `#3A2320`, "Couldn't reach the cellar." + Retry text button |
| Error, form validation | Field border → `error`, mono 9.5 error line below ("A cheese needs a name.") |
| Error, sign-in | Inline above button: "Wrong email or password. It happens." |
| Destructive confirms | Bottom sheet, radius 16 top, actions: neutral `OutlinedButton` + error-colored `FilledButton` |

## 9. Motion
Colors/fills transition 200ms ease (TKFW rule: hover/state color shifts only — no bounces, no entry animations). Drawer/dialog/bottom-sheet use stock M3 transitions. FAB hide-on-scroll: 200ms fade+slide. Wheel polygon animates 250ms `easeOut` on score change. No parallax, no hero animations between list and detail (simple fade-through is fine).

## 10. Assets & icons
- Icons: **Heroicons outline** (24×24, 2px stroke, round caps, `currentColor`) — matches TKFW. Flutter: bundle the SVGs (`flutter_svg`) or use the `heroicons` pub package. Do not mix filled variants; do not use Material Icons glyphs where a Heroicon exists.
- Logo badge: forge-gradient circle + white cheese-wedge glyph (wedge with 3 holes — SVG path in the mockups; export from `design/Cheese Notes App.dc.html`). The TKFW hammer/anvil mark belongs to the parent brand — use it only in "About", next to "A TK ForgeWorks product".
- Photos: none yet. `TastingNote.photoUrl` is in the model; when added, 16:9, radius 8, warm/natural per TKFW imagery rules.
- Fonts: Google Fonts (Poppins 400–700, Source Serif 4 400/600 + italics, JetBrains Mono 400/500) — `google_fonts` package or bundle locally.
