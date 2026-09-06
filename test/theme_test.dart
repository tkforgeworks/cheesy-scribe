import 'package:cheesy_scribe/app/theme/scribe_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('type scale uses the three bundled families', () {
      expect(t.textTheme.bodyMedium!.fontFamily, 'Poppins');
      expect(t.textTheme.titleLarge!.fontSize, 22);
      expect(t.textTheme.displaySmall!.fontFamily, 'Source Serif 4');
      expect(t.textTheme.displaySmall!.fontSize, 27);
      expect(t.textTheme.bodyLarge!.height, 1.7);
      expect(t.textTheme.labelSmall!.fontFamily, 'JetBrains Mono');
      expect(t.textTheme.labelSmall!.letterSpacing, 1.4);
    });

    test('exposes the journal extension', () {
      final x = t.extension<ScribeColors>()!;
      expect(x.dottedLine, const Color(0xFFC4B18B));
      expect(x.starInactive, const Color(0xFFE0D2B4));
      expect(x.successFg, const Color(0xFF3D7A33));
    });
  });

  group('ScribeTheme.dark', () {
    final t = ScribeTheme.dark();

    test('resolves the charcoal tokens', () {
      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.scaffoldBackgroundColor, const Color(0xFF211D17));
      expect(t.colorScheme.primary, const Color(0xFFF4B656));
      expect(t.colorScheme.surfaceContainerLowest, const Color(0xFF2B2620));
      expect(t.extension<ScribeColors>()!.errorTint, const Color(0xFF3A2320));
    });
  });

  test('forge gradient is the brand spark, unchanged', () {
    expect(ScribeTokens.forgeGradient.colors.last, const Color(0xFFEE3423));
    expect(ScribeTokens.forgeStrip.colors, const [
      Color(0xFFFBDF19),
      Color(0xFFF68F25),
      Color(0xFFEE3423),
    ]);
  });
}
