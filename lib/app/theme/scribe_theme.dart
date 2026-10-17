import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';

/// This app's palette (DESIGN_SPEC §2): cream & rind amber, and the charcoal
/// dark scheme. Prefer reading colors through `context.colors`,
/// `context.forge` and [ScribeColors]. Type, radii, the forge gradient and
/// every component theme come from `forge_ui`.
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
}

/// Colour roles of this app's own that neither [ColorScheme] nor
/// `ForgeTokens` has a slot for. Read via `context.scribe`.
@immutable
class ScribeColors extends ThemeExtension<ScribeColors> {
  const ScribeColors({
    required this.dottedLine,
    required this.starActive,
    required this.starInactive,
    required this.wheelGrid,
  });

  /// Journal dotted underlines.
  final Color dottedLine;
  final Color starActive;
  final Color starInactive;

  /// Flavor wheel rings and spokes (spec sheet 04).
  final Color wheelGrid;

  static const light = ScribeColors(
    dottedLine: ScribeTokens.dottedLine,
    starActive: ScribeTokens.rindAmber,
    starInactive: Color(0xFFE0D2B4),
    wheelGrid: Color(0xFFD9CBAA),
  );

  // Dark values derived from direction 1b.
  static const dark = ScribeColors(
    dottedLine: ScribeTokens.dottedDark,
    starActive: ScribeTokens.butterAmber,
    starInactive: Color(0xFF4A4237),
    wheelGrid: Color(0xFF4A4237),
  );

  static ScribeColors of(BuildContext context) =>
      Theme.of(context).extension<ScribeColors>() ?? light;

  @override
  ScribeColors copyWith({
    Color? dottedLine,
    Color? starActive,
    Color? starInactive,
    Color? wheelGrid,
  }) => ScribeColors(
    dottedLine: dottedLine ?? this.dottedLine,
    starActive: starActive ?? this.starActive,
    starInactive: starInactive ?? this.starInactive,
    wheelGrid: wheelGrid ?? this.wheelGrid,
  );

  @override
  ScribeColors lerp(ScribeColors? other, double t) {
    if (other == null) return this;
    return ScribeColors(
      dottedLine: Color.lerp(dottedLine, other.dottedLine, t)!,
      starActive: Color.lerp(starActive, other.starActive, t)!,
      starInactive: Color.lerp(starInactive, other.starInactive, t)!,
      wheelGrid: Color.lerp(wheelGrid, other.wheelGrid, t)!,
    );
  }
}

/// `context.scribe.dottedLine`. The scheme, text theme and shared roles are
/// `context.colors`, `context.text` and `context.forge`, from `forge_ui`.
extension ScribeContext on BuildContext {
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

  // ---------- forge_ui roles, hand-tuned to the palette ----------
  static const ForgeTokens lightTokens = ForgeTokens(
    accent: ScribeTokens.rindDeep,
    link: ScribeTokens.rindDeep,
    textTertiary: ScribeTokens.inkFaint,
    textGhost: ScribeTokens.inkGhost,
    rowDivider: ScribeTokens.lineSoft,
    successContainer: Color(0xFFE8F2E5),
    onSuccessContainer: Color(0xFF3D7A33),
    errorTint: Color(0xFFFBEDEA),
    skeletonBase: ScribeTokens.creamField,
    skeletonHighlight: Color(0xFFF8EDD9), // amberTint @40% over creamField
  );

  // Derived from direction 1b; the spec gives only the error tint.
  static const ForgeTokens darkTokens = ForgeTokens(
    accent: ScribeTokens.butterTint,
    link: ScribeTokens.butterAmber,
    textTertiary: ScribeTokens.parchFaint,
    textGhost: ScribeTokens.parchGhost,
    rowDivider: ScribeTokens.lineDarkSoft,
    successContainer: Color(0xFF2B3D28),
    onSuccessContainer: Color(0xFF9CCB8F),
    errorTint: Color(0xFF3A2320),
    skeletonBase: ScribeTokens.charcoalField,
    skeletonHighlight: Color(0xFF4A3F2F),
  );

  static ThemeData light() => forgeTheme(
    seed: ScribeTokens.rindAmber,
    colorScheme: lightScheme,
    tokens: lightTokens,
    extensions: const [ScribeColors.light],
  );

  static ThemeData dark() => forgeTheme(
    seed: ScribeTokens.rindAmber,
    colorScheme: darkScheme,
    tokens: darkTokens,
    extensions: const [ScribeColors.dark],
  );
}
