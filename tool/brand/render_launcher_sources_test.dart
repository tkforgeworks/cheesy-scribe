// Renders the launcher-icon source PNGs in assets/brand/launcher/ from the
// app's own brand widgets, so the icon always matches the in-app badge.
//
//   flutter test tool/brand/render_launcher_sources_test.dart
//   dart run flutter_launcher_icons
//
// Not part of the regular suite (it lives outside test/). See
// assets/brand/README.md.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cheesy_scribe/app/theme/scribe_theme.dart';
import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Source canvas. flutter_launcher_icons wraps the foreground and monochrome
/// drawables in a 16 % inset on every side, so this canvas maps onto the
/// central 68 % (73.44 dp) of the 108 dp adaptive-icon canvas. [dp] converts
/// adaptive-icon dp to source pixels on that basis; the 66 dp safe zone (what
/// every launcher mask keeps) is then 90 % of the canvas.
const canvas = 512.0;
const dp = canvas / (108 * 0.68);
const outDir = 'assets/brand/launcher';

void main() {
  testWidgets('render launcher icon sources', (tester) async {
    tester.view.physicalSize = const Size(canvas, canvas);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Adaptive foreground: the forge badge filling the safe zone, on a
    // transparent canvas. The background colour lives in pubspec.yaml.
    await render(
      tester,
      'icon-foreground.png',
      const Center(child: ForgeLogoBadge(size: 66 * dp)),
    );

    // Monochrome layer (Android 13 themed icons): the wedge outline alone,
    // nudged down a touch because the glyph sits high in its 24-box.
    await render(
      tester,
      'icon-monochrome.png',
      Center(
        child: Transform.translate(
          offset: const Offset(0, 0.6 / 24 * 64 * dp),
          child: const WedgeGlyph(
            size: 64 * dp,
            color: Colors.black,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );

    // Legacy icon (API < 26): cream rounded square with the badge.
    await render(
      tester,
      'icon-legacy.png',
      Padding(
        padding: const EdgeInsets.all(canvas * 0.04),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ScribeTokens.cream,
            borderRadius: BorderRadius.circular(canvas * 0.2),
          ),
          child: const Center(child: ForgeLogoBadge(size: canvas * 0.62)),
        ),
      ),
    );
  });
}

Future<void> render(WidgetTester tester, String name, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: SizedBox(width: canvas, height: canvas, child: child),
    ),
  );
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$outDir/$name')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    expect(image.width, canvas.toInt());
    expect(image.height, canvas.toInt());
  });
}
