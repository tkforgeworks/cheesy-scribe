import 'package:cheesy_scribe/app/theme/scribe_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

void main() {
  group('ScribeTheme.light', () {
    final t = ScribeTheme.light();

    test('resolves the cream & rind amber tokens', () {
      expect(t.scaffoldBackgroundColor, const Color(0xFFFAF6EE));
      expect(t.colorScheme.primary, const Color(0xFFB3641B));
      expect(t.colorScheme.onPrimaryContainer, const Color(0xFF93500F));
      expect(t.colorScheme.surfaceContainerLowest, const Color(0xFFFFFDF8));
      expect(t.colorScheme.outline, const Color(0xFFE6D9BF));
    });

    test('cards and chips use radius 8 with a border and no elevation', () {
      final card = t.cardTheme.shape as RoundedRectangleBorder;
      expect(card.borderRadius, BorderRadius.circular(8));
      expect(card.side.color, t.colorScheme.outline);
      expect(t.cardTheme.elevation, 0);
      final chip = t.chipTheme.shape as RoundedRectangleBorder;
      expect(chip.borderRadius, BorderRadius.circular(8));
    });

    test("type scale uses forge_ui's three families", () {
      expect(t.textTheme.bodyMedium!.fontFamily, 'packages/forge_ui/Poppins');
      expect(t.textTheme.titleLarge!.fontSize, 22);
      expect(
        t.textTheme.displaySmall!.fontFamily,
        'packages/forge_ui/Source Serif 4',
      );
      expect(t.textTheme.displaySmall!.fontSize, 27);
      expect(t.textTheme.bodyLarge!.height, 1.7);
      expect(
        t.textTheme.labelSmall!.fontFamily,
        'packages/forge_ui/JetBrains Mono',
      );
      expect(t.textTheme.labelSmall!.letterSpacing, 1.4);
    });

    test("exposes the app's own roles and the hand-tuned forge tokens", () {
      final x = t.extension<ScribeColors>()!;
      expect(x.dottedLine, const Color(0xFFC4B18B));
      expect(x.starInactive, const Color(0xFFE0D2B4));
      final f = t.extension<ForgeTokens>()!;
      expect(f.onSuccessContainer, const Color(0xFF3D7A33));
      expect(f.textTertiary, const Color(0xFF8A7A5F));
      expect(f.link, const Color(0xFF93500F));
    });
  });

  group('ScribeTheme.dark', () {
    final t = ScribeTheme.dark();

    test('resolves the charcoal tokens', () {
      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.scaffoldBackgroundColor, const Color(0xFF211D17));
      expect(t.colorScheme.primary, const Color(0xFFF4B656));
      expect(t.colorScheme.surfaceContainerLowest, const Color(0xFF2B2620));
      expect(t.extension<ForgeTokens>()!.errorTint, const Color(0xFF3A2320));
      expect(t.extension<ForgeTokens>()!.link, const Color(0xFFF4B656));
    });
  });
}
