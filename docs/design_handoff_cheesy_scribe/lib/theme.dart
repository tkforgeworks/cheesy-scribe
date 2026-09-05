// Cheesy Scribe — Flutter theme (Material 3)
// Palette: "Cream & rind amber" (direction 1a) + derived dark theme.
// Fonts: Poppins (UI), Source Serif 4 (editorial/prose), JetBrains Mono (labels/tags).
// Add to pubspec.yaml:  google_fonts: ^6.x   (or bundle the three families locally)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Raw brand tokens. Prefer reading colors via Theme.of(context).colorScheme;
/// reach for these only for the journal-specific extras below.
abstract class ScribeTokens {
  // ---- Light (primary target) ----
  static const cream = Color(0xFFFAF6EE); // page background
  static const creamCard = Color(0xFFFFFDF8); // card surface
  static const creamField = Color(0xFFF2E8D5); // search bar, inactive tracks
  static const amberTint = Color(0xFFF6E5C8); // selected chip fill, avatar bg
  static const rindAmber = Color(0xFFB3641B); // primary: buttons, stars, sliders
  static const rindDeep = Color(0xFF93500F); // links, selected text, emphasis
  static const inkBrown = Color(0xFF35291A); // primary text
  static const inkSoft = Color(0xFF5F5138); // secondary text / icons
  static const inkFaint = Color(0xFF8A7A5F); // tertiary text, field labels
  static const inkGhost = Color(0xFFB5A684); // hints, disabled, fine print
  static const lineBold = Color(0xFFE6D9BF); // card borders, input outlines
  static const lineSoft = Color(0xFFEFE4CF); // row dividers
  static const dottedLine = Color(0xFFC4B18B); // journal dotted underlines
  static const errorRed = Color(0xFFB3382B);

  // ---- Dark (system-setting support; charcoal from direction 1b) ----
  static const charcoal = Color(0xFF211D17); // page background
  static const charcoalCard = Color(0xFF2B2620); // card surface
  static const charcoalField = Color(0xFF3B342B); // search bar, inactive tracks
  static const butterTint = Color(0xFFEEDBB6); // selected chip fill
  static const butterAmber = Color(0xFFF4B656); // primary: stars, links, sliders
  static const parchment = Color(0xFFF3EAD9); // primary text
  static const parchSoft = Color(0xFFCBBFA8); // secondary text / icons
  static const parchFaint = Color(0xFFA89A80); // tertiary text, field labels
  static const parchGhost = Color(0xFF7A6F5D); // hints, disabled, fine print
  static const lineDark = Color(0xFF4A4237); // borders, outlines
  static const lineDarkSoft = Color(0xFF3D362D); // row dividers
  static const dottedDark = Color(0xFF6B5F4C); // journal dotted underlines
  static const errorRedDark = Color(0xFFE5766A);

  // ---- Forge accent (TK ForgeWorks brand spark) ----
  // ONLY for: app logo badge, the "New tasting notes" FAB gradient, and the
  // 4px top strip on the featured "latest tasting" card. Never for status,
  // never as a surface, never on ordinary buttons.
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

  // ---- Shape scale ----
  static const rCard = 8.0; // cards, buttons, inputs, chips
  static const rChipTag = 4.0; // mono tag capsules
  static const rFab = 16.0; // extended FAB
  static const rSearch = 28.0; // search bar / drawer item pill
}

/// Extra journal-flavored roles that ColorScheme has no slot for.
/// Access via Theme.of(context).extension<ScribeColors>()!.
@immutable
class ScribeColors extends ThemeExtension<ScribeColors> {
  const ScribeColors({
    required this.dottedLine,
    required this.rowDivider,
    required this.textTertiary,
    required this.textGhost,
    required this.starActive,
    required this.starInactive,
  });
  final Color dottedLine;
  final Color rowDivider;
  final Color textTertiary;
  final Color textGhost;
  final Color starActive;
  final Color starInactive;

  static const light = ScribeColors(
    dottedLine: ScribeTokens.dottedLine,
    rowDivider: ScribeTokens.lineSoft,
    textTertiary: ScribeTokens.inkFaint,
    textGhost: ScribeTokens.inkGhost,
    starActive: ScribeTokens.rindAmber,
    starInactive: Color(0xFFE0D2B4),
  );
  static const dark = ScribeColors(
    dottedLine: ScribeTokens.dottedDark,
    rowDivider: ScribeTokens.lineDarkSoft,
    textTertiary: ScribeTokens.parchFaint,
    textGhost: ScribeTokens.parchGhost,
    starActive: ScribeTokens.butterAmber,
    starInactive: Color(0xFF4A4237),
  );

  @override
  ScribeColors copyWith({
    Color? dottedLine, Color? rowDivider, Color? textTertiary,
    Color? textGhost, Color? starActive, Color? starInactive,
  }) => ScribeColors(
    dottedLine: dottedLine ?? this.dottedLine,
    rowDivider: rowDivider ?? this.rowDivider,
    textTertiary: textTertiary ?? this.textTertiary,
    textGhost: textGhost ?? this.textGhost,
    starActive: starActive ?? this.starActive,
    starInactive: starInactive ?? this.starInactive,
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
    );
  }
}

abstract class ScribeTheme {
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

  // ---------- Typography ----------
  // Poppins = UI voice. Source Serif 4 = editorial (cheese names, notes prose,
  // taglines — often italic). JetBrains Mono = journal field labels & tags.
  static TextTheme _textTheme(ColorScheme c, ScribeColors x) {
    final ui = GoogleFonts.poppinsTextTheme();
    TextStyle p(TextStyle? s) => s!.copyWith(color: c.onSurface);
    return TextTheme(
      // Editorial display — cheese names on detail/featured cards
      displaySmall: GoogleFonts.sourceSerif4(
          fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, color: c.onSurface),
      headlineSmall: GoogleFonts.sourceSerif4(
          fontSize: 21, fontWeight: FontWeight.w600, color: c.onSurface),
      // UI headers
      titleLarge: p(ui.titleLarge).copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: p(ui.titleMedium).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: p(ui.titleSmall).copyWith(fontSize: 15, fontWeight: FontWeight.w500),
      // Body
      bodyLarge: GoogleFonts.sourceSerif4(
          fontSize: 14.5, height: 1.7, color: c.onSurface), // notes prose
      bodyMedium: p(ui.bodyMedium).copyWith(fontSize: 14),
      bodySmall: p(ui.bodySmall).copyWith(fontSize: 11.5, color: x.textTertiary),
      // Journal field labels — always: JetBrains Mono, uppercase in content,
      // letterSpacing 1.4, tertiary color
      labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 10, fontWeight: FontWeight.w500,
          letterSpacing: 1.4, color: x.textTertiary),
      labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 9.5, fontWeight: FontWeight.w500,
          letterSpacing: 0.5, color: x.textTertiary), // tag capsules
      labelLarge: p(ui.labelLarge).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData _base(ColorScheme c, ScribeColors x) {
    final text = _textTheme(c, x);
    final isDark = c.brightness == Brightness.dark;
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
      cardTheme: CardTheme(
        color: c.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rCard),
          side: BorderSide(color: c.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScribeTokens.rSearch))),
        constraints: const BoxConstraints(minHeight: 52),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScribeTokens.rCard)),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: c.outline),
          foregroundColor: c.onSurfaceVariant,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScribeTokens.rCard)),
          textStyle: text.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brightness == Brightness.light
              ? ScribeTokens.rindDeep : ScribeTokens.butterAmber,
          textStyle: text.labelLarge?.copyWith(fontSize: 13),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: c.primaryContainer,
        side: BorderSide(color: c.outline),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScribeTokens.rCard)),
        labelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500, color: c.onSurfaceVariant),
        secondaryLabelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500, color: c.onPrimaryContainer),
        showCheckmark: true,
        checkmarkColor: c.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rCard),
          borderSide: BorderSide(color: c.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rCard),
          borderSide: BorderSide(color: c.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScribeTokens.rCard),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.sourceSerif4(
            fontStyle: FontStyle.italic, fontSize: 14, color: x.textGhost),
        labelStyle: text.labelSmall,
      ),
      dividerTheme: DividerThemeData(color: x.rowDivider, thickness: 1, space: 1),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? ScribeTokens.charcoalCard : c.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
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
            borderRadius: BorderRadius.circular(ScribeTokens.rSearch)),
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
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? c.primary : c.surfaceContainer),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // The FAB carries the forge gradient — Flutter's FAB can't paint a
      // gradient natively, so wrap: see ForgeFab in the spec (DecoratedBox with
      // ScribeTokens.forgeGradient + FloatingActionButton.extended inside,
      // backgroundColor: Colors.transparent, elevation 0).
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        extendedTextStyle: text.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScribeTokens.rFab)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScribeTokens.rCard)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light() => _base(lightScheme, ScribeColors.light);
  static ThemeData dark() => _base(darkScheme, ScribeColors.dark);
}

// Usage:
// MaterialApp(
//   theme: ScribeTheme.light(),
//   darkTheme: ScribeTheme.dark(),
//   themeMode: ThemeMode.system, // Settings > Appearance > Theme overrides this
// )
