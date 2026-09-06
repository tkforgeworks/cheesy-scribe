import 'package:flutter/material.dart';

/// Font families bundled in `assets/fonts/` (licences in `LICENSES.md` there).
/// Poppins is the UI voice, Source Serif 4 the editorial voice (cheese names,
/// notes prose, taglines — often italic), JetBrains Mono the journal labels
/// and tag capsules (always uppercase, letterspaced).
abstract final class ScribeFonts {
  static const ui = 'Poppins';
  static const serif = 'Source Serif 4';
  static const mono = 'JetBrains Mono';
}

/// Raw brand tokens (DESIGN_SPEC §2). Prefer reading colors through
/// `Theme.of(context).colorScheme` and [ScribeColors]; reach for these only
/// where a role has no slot (the forge gradient, shape radii).
abstract final class ScribeTokens {
  // ---- Light ("cream & rind amber", primary target) ----
  static const cream = Color(0xFFFAF6EE); // page background
  static const creamCard = Color(0xFFFFFDF8); // card surface
  static const creamField = Color(0xFFF2E8D5); // search bar, inactive tracks
  static const amberTint = Color(0xFFF6E5C8); // selected chip fill, avatar bg
  static const rindAmber = Color(
    0xFFB3641B,
  ); // primary: buttons, stars, sliders
  static const rindDeep = Color(0xFF93500F); // links, selected text, emphasis
  static const inkBrown = Color(0xFF35291A); // primary text
  static const inkSoft = Color(0xFF5F5138); // secondary text / icons
  static const inkFaint = Color(0xFF8A7A5F); // tertiary text, field labels
  static const inkGhost = Color(0xFFB5A684); // hints, disabled, fine print
  static const lineBold = Color(0xFFE6D9BF); // card borders, input outlines
  static const lineSoft = Color(0xFFEFE4CF); // row dividers
  static const dottedLine = Color(0xFFC4B18B); // journal dotted underlines
  static const errorRed = Color(0xFFB3382B);

  // ---- Dark (system-setting support; charcoal chrome from direction 1b) ----
  static const charcoal = Color(0xFF211D17); // page background
  static const charcoalCard = Color(0xFF2B2620); // card surface
  static const charcoalField = Color(0xFF3B342B); // search bar, inactive tracks
  static const butterTint = Color(0xFFEEDBB6); // selected chip fill
  static const butterAmber = Color(
    0xFFF4B656,
  ); // primary: stars, links, sliders
  static const parchment = Color(0xFFF3EAD9); // primary text
  static const parchSoft = Color(0xFFCBBFA8); // secondary text / icons
  static const parchFaint = Color(0xFFA89A80); // tertiary text, field labels
  static const parchGhost = Color(0xFF7A6F5D); // hints, disabled, fine print
  static const lineDark = Color(0xFF4A4237); // borders, outlines
  static const lineDarkSoft = Color(0xFF3D362D); // row dividers
  static const dottedDark = Color(0xFF6B5F4C); // journal dotted underlines
  static const errorRedDark = Color(0xFFE5766A);

  // ---- Forge accent (the TK ForgeWorks brand spark) ----
  // ONLY for: the logo badge, the "New tasting notes" FAB gradient, and the
  // 4px top strip on the featured card. Never for status, never as a surface,
  // never on ordinary buttons (DESIGN_SPEC §1 rule 1).
  static const forgeYellow = Color(0xFFFBDF19);
  static const forgeOrange = Color(0xFFF68F25);
  static const forgeRed = Color(0xFFEE3423);
  static const forgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9A825), forgeOrange, forgeRed],
    stops: [0.0, 0.45, 1.0],
  );
  static const forgeStrip = LinearGradient(
    colors: [forgeYellow, forgeOrange, forgeRed],
  );

  // ---- Shape scale (DESIGN_SPEC §4) ----
  static const rCard = 8.0; // cards, buttons, inputs, chips
  static const rChipTag = 4.0; // mono tag capsules
  static const rFab = 16.0; // extended FAB
  static const rSearch = 28.0; // search bar / drawer item pill
}

/// Journal-flavoured colour roles that [ColorScheme] has no slot for.
/// Read via `context.scribe` (see [ScribeContext]).
@immutable
class ScribeColors extends ThemeExtension<ScribeColors> {
  const ScribeColors({
    required this.dottedLine,
    required this.rowDivider,
    required this.textTertiary,
    required this.textGhost,
    required this.starActive,
    required this.starInactive,
    required this.successFg,
    required this.successBg,
    required this.errorTint,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  final Color dottedLine;
  final Color rowDivider;
  final Color textTertiary;
  final Color textGhost;
  final Color starActive;
  final Color starInactive;

  /// CONNECTED status capsule pair (spec sheet 03) — status only, never text.
  final Color successFg;
  final Color successBg;

  /// Inline error card background (DESIGN_SPEC §8).
  final Color errorTint;

  /// Skeleton rows shimmer between these two (1.2 s, DESIGN_SPEC §8).
  final Color skeletonBase;
  final Color skeletonHighlight;

  static const light = ScribeColors(
    dottedLine: ScribeTokens.dottedLine,
    rowDivider: ScribeTokens.lineSoft,
    textTertiary: ScribeTokens.inkFaint,
    textGhost: ScribeTokens.inkGhost,
    starActive: ScribeTokens.rindAmber,
    starInactive: Color(0xFFE0D2B4),
    successFg: Color(0xFF3D7A33),
    successBg: Color(0xFFE8F2E5),
    errorTint: Color(0xFFFBEDEA),
    skeletonBase: ScribeTokens.creamField,
    skeletonHighlight: Color(0xFFF8EDD9), // amberTint @40% over creamField
  );

  // Dark values derived from direction 1b; the spec gives only the error tint.
  static const dark = ScribeColors(
    dottedLine: ScribeTokens.dottedDark,
    rowDivider: ScribeTokens.lineDarkSoft,
    textTertiary: ScribeTokens.parchFaint,
    textGhost: ScribeTokens.parchGhost,
    starActive: ScribeTokens.butterAmber,
    starInactive: Color(0xFF4A4237),
    successFg: Color(0xFF9CCB8F),
    successBg: Color(0xFF2B3D28),
    errorTint: Color(0xFF3A2320),
    skeletonBase: ScribeTokens.charcoalField,
    skeletonHighlight: Color(0xFF4A3F2F),
  );

  static ScribeColors of(BuildContext context) =>
      Theme.of(context).extension<ScribeColors>() ?? light;

  @override
  ScribeColors copyWith({
    Color? dottedLine,
    Color? rowDivider,
    Color? textTertiary,
    Color? textGhost,
    Color? starActive,
    Color? starInactive,
    Color? successFg,
    Color? successBg,
    Color? errorTint,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) => ScribeColors(
    dottedLine: dottedLine ?? this.dottedLine,
    rowDivider: rowDivider ?? this.rowDivider,
    textTertiary: textTertiary ?? this.textTertiary,
    textGhost: textGhost ?? this.textGhost,
    starActive: starActive ?? this.starActive,
    starInactive: starInactive ?? this.starInactive,
    successFg: successFg ?? this.successFg,
    successBg: successBg ?? this.successBg,
    errorTint: errorTint ?? this.errorTint,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
  );

  @override
  ScribeColors lerp(ScribeColors? other, double t) {
    if (other == null) return this;
    return ScribeColors(
      dottedLine: Color.lerp(dottedLine, other.dottedLine, t)!,
      rowDivider: Color.lerp(rowDivider, other.rowDivider, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textGhost: Color.lerp(textGhost, other.textGhost, t)!,
      starActive: Color.lerp(starActive, other.starActive, t)!,
      starInactive: Color.lerp(starInactive, other.starInactive, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
    );
  }
}

/// Shorthands so screens read `context.colors.primary`, `context.scribe
/// .dottedLine`, `context.text.titleSmall` instead of the `Theme.of` chain.
extension ScribeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  ScribeColors get scribe => ScribeColors.of(this);
}

abstract final class ScribeTheme {
  // ---------- Color schemes ----------
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ScribeTokens.rindAmber,
    onPrimary: Colors.white,
    primaryContainer: ScribeTokens.amberTint,
    onPrimaryContainer: ScribeTokens.rindDeep,
    secondary: ScribeTokens.inkSoft,
    onSecondary: Colors.white,
    secondaryContainer: ScribeTokens.creamField,
    onSecondaryContainer: Color(0xFF6B5A3D),
    tertiary: ScribeTokens.rindDeep,
    onTertiary: Colors.white,
    error: ScribeTokens.errorRed,
    onError: Colors.white,
    surface: ScribeTokens.cream,
    onSurface: ScribeTokens.inkBrown,
    surfaceContainerLowest: ScribeTokens.creamCard, // cards
    surfaceContainerLow: ScribeTokens.cream,
    surfaceContainer: ScribeTokens.creamField, // search bar
    surfaceContainerHigh: ScribeTokens.amberTint,
    surfaceContainerHighest: ScribeTokens.amberTint,
    onSurfaceVariant: ScribeTokens.inkSoft,
    outline: ScribeTokens.lineBold,
    outlineVariant: ScribeTokens.lineSoft,
    shadow: Color(0x2E35291A),
    scrim: Color(0x61231808), // drawer scrim rgba(35,24,8,.38)
    inverseSurface: ScribeTokens.inkBrown,
    onInverseSurface: ScribeTokens.cream,
    inversePrimary: ScribeTokens.butterAmber,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ScribeTokens.butterAmber,
    onPrimary: Color(0xFF3A2606),
    primaryContainer: Color(0xFF5C4315),
    onPrimaryContainer: ScribeTokens.butterTint,
    secondary: ScribeTokens.parchSoft,
    onSecondary: ScribeTokens.charcoal,
    secondaryContainer: ScribeTokens.charcoalField,
    onSecondaryContainer: ScribeTokens.parchSoft,
    tertiary: ScribeTokens.butterTint,
    onTertiary: Color(0xFF3A2606),
    error: ScribeTokens.errorRedDark,
    onError: Color(0xFF2B0906),
    surface: ScribeTokens.charcoal,
    onSurface: ScribeTokens.parchment,
    surfaceContainerLowest: ScribeTokens.charcoalCard,
    surfaceContainerLow: ScribeTokens.charcoal,
    surfaceContainer: ScribeTokens.charcoalField,
    surfaceContainerHigh: Color(0xFF453D32),
    surfaceContainerHighest: Color(0xFF4F463A),
    onSurfaceVariant: ScribeTokens.parchSoft,
    outline: ScribeTokens.lineDark,
    outlineVariant: ScribeTokens.lineDarkSoft,
    shadow: Color(0x66000000),
    scrim: Color(0x8014100A),
    inverseSurface: ScribeTokens.parchment,
    onInverseSurface: ScribeTokens.charcoal,
    inversePrimary: ScribeTokens.rindAmber,
  );

  // ---------- Text style helpers ----------
  // The three voices, for styles the TextTheme slots don't cover.

  /// Poppins UI text.
  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: ScribeFonts.ui,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  /// Source Serif 4 — cheese names, prose; pass `italic: true` for wit lines,
  /// hints and taglines (DESIGN_SPEC §3 "taglines, hints, wit lines").
  static TextStyle serif({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: ScribeFonts.serif,
    fontSize: size,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    height: height,
  );

  /// JetBrains Mono — journal labels and capsules. Callers uppercase the
  /// content themselves (see `MonoLabel` / `TagCapsule`).
  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 1.4,
    Color? color,
  }) => TextStyle(
    fontFamily: ScribeFonts.mono,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    color: color,
  );

  // ---------- Typography (DESIGN_SPEC §3) ----------
  static TextTheme _textTheme(ColorScheme c, ScribeColors x) {
    return TextTheme(
      // Editorial display — cheese names on detail / featured cards
      displaySmall: serif(
        size: 27,
        weight: FontWeight.w600,
        height: 1.2,
        color: c.onSurface,
      ),
      headlineSmall: serif(
        size: 21,
        weight: FontWeight.w600,
        color: c.onSurface,
      ),
      // UI headers
      titleLarge: ui(size: 22, weight: FontWeight.w600, color: c.onSurface),
      titleMedium: ui(size: 18, weight: FontWeight.w600, color: c.onSurface),
      titleSmall: ui(size: 15, weight: FontWeight.w500, color: c.onSurface),
      // Body
      bodyLarge: serif(size: 14.5, height: 1.7, color: c.onSurface), // prose
      bodyMedium: ui(size: 14, color: c.onSurface),
      bodySmall: ui(size: 11.5, color: x.textTertiary), // row meta
      // Journal field labels — JetBrains Mono, uppercase content, tracking 1.4
      labelSmall: mono(size: 10, color: x.textTertiary),
      // Tag capsules / stat labels
      labelMedium: mono(size: 9.5, letterSpacing: 0.5, color: x.textTertiary),
      // Button labels
      labelLarge: ui(size: 14, weight: FontWeight.w600, color: c.onSurface),
    );
  }

  static ThemeData _base(ColorScheme c, ScribeColors x) {
    final text = _textTheme(c, x);
    final isDark = c.brightness == Brightness.dark;
    final cardRadius = BorderRadius.circular(ScribeTokens.rCard);
    return ThemeData(
      useMaterial3: true,
      colorScheme: c,
      scaffoldBackgroundColor: c.surface,
      textTheme: text,
      extensions: [x],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? ScribeTokens.charcoalCard : c.surface,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleMedium,
      ),
      // Flat surfaces: border only, no resting shadow (DESIGN_SPEC §1 rule 5).
      cardTheme: CardThemeData(
        color: c.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: c.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScribeTokens.rSearch),
          ),
        ),
        constraints: const BoxConstraints(minHeight: 52),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: c.outline),
          foregroundColor: c.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          textStyle: text.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? ScribeTokens.butterAmber
              : ScribeTokens.rindDeep,
          textStyle: text.labelLarge?.copyWith(fontSize: 13),
        ),
      ),
      // Filter chips: radius 8 (not stock full), selected = primaryContainer
      // fill + primary border + checkmark (spec sheet 03).
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: c.primaryContainer,
        side: BorderSide(color: c.outline),
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        labelStyle: ui(
          size: 12,
          weight: FontWeight.w500,
          color: c.onSurfaceVariant,
        ),
        secondaryLabelStyle: ui(
          size: 12,
          weight: FontWeight.w500,
          color: c.onPrimaryContainer,
        ),
        showCheckmark: true,
        checkmarkColor: c.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      ),
      // Boxed inputs (auth / account screens). The mono label sits OUTSIDE the
      // field (see `BoxedField`), so no floating label here.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: cardRadius,
          borderSide: BorderSide(color: c.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: cardRadius,
          borderSide: BorderSide(color: c.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: cardRadius,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: cardRadius,
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: cardRadius,
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
        hintStyle: serif(size: 14, italic: true, color: x.textGhost),
        labelStyle: text.labelSmall,
        errorStyle: text.labelMedium?.copyWith(color: c.error),
      ),
      dividerTheme: DividerThemeData(
        color: x.rowDivider,
        thickness: 1,
        space: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark
            ? ScribeTokens.charcoalCard
            : c.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        width: 300,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: x.textTertiary,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        indicatorColor: c.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rSearch),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.surfaceContainer,
        thumbColor: c.primary,
        trackHeight: 4,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(c.surfaceContainerLowest),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.primary : c.surfaceContainer,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // The FAB carries the forge gradient, which a FAB can't paint natively:
      // `ForgeFab` wraps a transparent, elevation-0 FAB in a DecoratedBox.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        extendedTextStyle: text.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rFab),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light() => _base(lightScheme, ScribeColors.light);
  static ThemeData dark() => _base(darkScheme, ScribeColors.dark);
}
