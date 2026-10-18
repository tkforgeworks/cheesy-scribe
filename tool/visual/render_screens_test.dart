// Renders every screen of the real app to PNG, in light and dark, for
// before/after comparison. Not part of `flutter test` (it lives in tool/).
//
//   RENDER_OUT=/some/dir flutter test tool/visual/render_screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../test/support.dart';

final _out = Directory(Platform.environment['RENDER_OUT'] ?? 'tool/visual/out');

final _notes = [
  TastingNote(
    id: 'rogue',
    cheeseName: 'Rogue River Blue',
    tastedAt: DateTime(2026, 8, 12),
    createdAt: DateTime.utc(2026, 8, 12, 18),
    creamery: 'Rogue Creamery',
    origin: 'Oregon, USA',
    rind: RindType.leafWrapped,
    price: 48,
    milk: MilkType.cow,
    isRaw: true,
    rating: 5,
    texture: TextureLevel.semiFirm,
    notes:
        'Pear brandy on the nose, then fudge, then a long blue hum. '
        'The leaves give it a boozy edge that the paste carries well.',
    verdict: 'Tastes like winning an argument.',
    flavors: const {
      FlavorNote.caramel: 5,
      FlavorNote.earthy: 4,
      FlavorNote.moldyBlue: 5,
      FlavorNote.salty: 3,
      FlavorNote.sweet: 3,
      FlavorNote.butteryCreamy: 4,
    },
    cheeseStyleId: 'blue',
  ),
  TastingNote(
    id: 'comte',
    cheeseName: 'Comté 24 mo',
    tastedAt: DateTime(2026, 8, 3),
    createdAt: DateTime.utc(2026, 8, 3, 18),
    creamery: 'Marcel Petite',
    origin: 'Jura, France',
    rind: RindType.natural,
    price: 32,
    isGrassfed: true,
    rating: 4,
    texture: TextureLevel.hard,
    notes: 'Brown butter and hazelnut, crunchy with crystals.',
    flavors: const {
      FlavorNote.nutty: 5,
      FlavorNote.crystalline: 4,
      FlavorNote.caramel: 3,
    },
    cheeseStyleId: 'alpine',
  ),
  TastingNote(
    id: 'fog',
    cheeseName: 'Humboldt Fog',
    tastedAt: DateTime(2026, 7, 27),
    createdAt: DateTime.utc(2026, 7, 27, 18),
    creamery: 'Cypress Grove',
    milk: MilkType.goat,
    rind: RindType.bloomy,
    rating: 4,
    texture: TextureLevel.soft,
    flavors: const {FlavorNote.lemon: 4, FlavorNote.milkyLactic: 3},
    cheeseStyleId: 'bloomy-rind',
  ),
  TastingNote(
    id: 'epoisses',
    cheeseName: 'Époisses',
    tastedAt: DateTime(2026, 7, 14),
    createdAt: DateTime.utc(2026, 7, 14, 18),
    rind: RindType.washed,
    rating: 3,
    texture: TextureLevel.runny,
    flavors: const {FlavorNote.stinky: 5, FlavorNote.robust: 4},
    cheeseStyleId: 'washed-rind',
  ),
  TastingNote(
    id: 'manchego',
    cheeseName: 'Manchego Curado',
    tastedAt: DateTime(2026, 7, 2),
    createdAt: DateTime.utc(2026, 7, 2, 18),
    milk: MilkType.sheep,
    price: 24,
    priceUnit: PriceUnit.eurPerKg,
    rating: 2,
    texture: TextureLevel.firm,
    flavors: const {FlavorNote.nutty: 3, FlavorNote.grassy: 3},
  ),
  TastingNote(
    id: 'plain',
    cheeseName: 'Unrated farmhouse wedge',
    tastedAt: DateTime(2026, 6, 20),
    createdAt: DateTime.utc(2026, 6, 20, 18),
  ),
];

Future<void> _shot(WidgetTester tester, String name) async {
  RenderObject ro = tester.binding.rootElement!.renderObject!;
  while (!ro.isRepaintBoundary) {
    ro = ro.parent!;
  }
  await tester.runAsync(() async {
    final layer = ro.debugLayer! as OffsetLayer;
    final image = await layer.toImage(ro.paintBounds);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${_out.path}/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

typedef _Scene = Future<void> Function(WidgetTester tester, String prefix);

/// The account a signed-in scene shows (CHEESE-61): email and Google.
const _session = ForgeSession(
  userId: 'tim',
  email: 'tim@example.com',
  emailConfirmed: true,
  identities: [
    ForgeIdentity(
      id: 'tim@example.com',
      identityId: 'link-email',
      provider: ForgeIdentityProvider.email,
      email: 'tim@example.com',
    ),
    ForgeIdentity(
      id: '1234',
      identityId: 'link-google',
      provider: ForgeIdentityProvider.google,
      email: 'tim@example.com',
    ),
  ],
);

/// The fake backend of the scene being rendered, for bodies that drive it.
late FakeForgeAuth _auth;

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode.name;

    Future<void> boot(
      WidgetTester tester, {
      required String at,
      bool seeded = true,
      bool signedIn = false,
      bool backup = true,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      _auth = FakeForgeAuth();
      addTearDown(_auth.dispose);
      if (signedIn) _auth.signIn(_session);
      final db = openTestDatabase();
      if (seeded) {
        await tester.runAsync(() async {
          final repo = NotesRepository(db);
          for (final n in _notes) {
            await repo.save(n);
          }
        });
      }
      await pumpApp(
        tester,
        at: at,
        db: db,
        settings: AppSettings(
          displayName: 'Tim',
          themeMode: mode,
          memberSince: DateTime(2026, 6, 1),
        ),
        auth: _auth,
        backup: backup,
      );
    }

    Future<void> scroll(WidgetTester tester, double dy) async {
      await tester.drag(
        find.byType(Scrollable).first,
        Offset(0, -dy),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }

    void scene(
      String name,
      String at,
      _Scene body, {
      bool seeded = true,
      bool signedIn = false,
      bool backup = true,
    }) {
      testApp('$m $name', (tester) async {
        await boot(
          tester,
          at: at,
          seeded: seeded,
          signedIn: signedIn,
          backup: backup,
        );
        await body(tester, '$m-$name');
      });
    }

    Future<void> plain(WidgetTester tester, String p) => _shot(tester, p);

    Future<void> scrolled(WidgetTester tester, String p) async {
      await _shot(tester, '$p-1');
      await scroll(tester, 700);
      await _shot(tester, '$p-2');
      await scroll(tester, 700);
      await _shot(tester, '$p-3');
    }

    scene('notes-empty', '/notes', plain, seeded: false);
    scene('notes', '/notes', scrolled);
    scene('notes-drawer', '/notes', (tester, p) async {
      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('notes-search', '/notes', (tester, p) async {
      await tester.tap(find.byType(SearchBar).first);
      await tester.pumpAndSettle();
      await _shot(tester, '$p-recents');
      await tester.enterText(find.byType(TextField).last, 'blue');
      await tester.pumpAndSettle();
      await _shot(tester, '$p-results');
      await tester.enterText(find.byType(TextField).last, 'zzzz');
      await tester.pumpAndSettle();
      await _shot(tester, '$p-none');
    });
    scene('notes-sheets', '/notes', (tester, p) async {
      await tester.longPress(find.text('Comté 24 mo'));
      await tester.pumpAndSettle();
      await _shot(tester, '$p-actions');
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      await _shot(tester, '$p-confirm');
    });
    scene('form-new', '/notes/new', scrolled);
    scene('form-edit', '/notes/rogue/edit', scrolled);
    scene('form-discard', '/notes/rogue/edit', (tester, p) async {
      await tester.enterText(find.byType(TextField).first, 'Changed');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('detail', '/notes/rogue', scrolled);
    scene('detail-sparse', '/notes/plain', plain);
    scene('detail-gone', '/notes/nope', plain);
    scene('library', '/library', scrolled);
    scene('style-tasted', '/library/blue', scrolled);
    scene('style-untasted', '/library/fresh', scrolled);
    scene('stats', '/stats', scrolled);
    scene('stats-empty', '/stats', plain, seeded: false);
    scene('settings', '/settings', plain);
    // CHEESE-61: signed out (the sign-in panel under the profile), a build
    // with no backend, signed in, the sign-out sheet, a failed attempt,
    // the two check-email states and the set-password screen.
    scene('account', '/account', scrolled);
    scene('account-unavailable', '/account', plain, backup: false);
    scene('account-signed-in', '/account', scrolled, signedIn: true);
    scene('account-sign-out', '/account', (tester, p) async {
      await tester.ensureVisible(find.byKey(ForgeAccountSettings.signOutKey));
      await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    }, signedIn: true);
    scene('account-sign-in-error', '/account', (tester, p) async {
      _auth.googleResult = const ForgeAuthFailure(
        ForgeAuthError.noGoogleAccount,
        'No credential available',
      );
      await tester.tap(find.byType(ForgeSignInButton));
      await tester.pumpAndSettle();
      await scroll(tester, 700);
      await _shot(tester, p);
    });
    scene('check-email', '/account', (tester, p) async {
      await tester.tap(find.byKey(ForgeSignInPanel.switchModeKey));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(ForgeSignInPanel.emailFieldKey),
        'tim@example.com',
      );
      await tester.enterText(
        find.byKey(ForgeSignInPanel.passwordFieldKey),
        'hunter2222',
      );
      await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('check-email-reset', '/account', (tester, p) async {
      await tester.tap(find.byKey(ForgeSignInPanel.forgotKey));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(ForgeSignInPanel.emailFieldKey),
        'tim@example.com',
      );
      await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('set-password', '/notes', (tester, p) async {
      _auth.startPasswordRecovery(_session);
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('about', '/about', scrolled);
    // Pushed from About, as in the app, so the app bar has its back button.
    scene('licenses', '/about', (tester, p) async {
      await tester.ensureVisible(find.text('Open-source licenses'));
      await tester.tap(find.text('Open-source licenses'));
      await tester.pumpAndSettle();
      await scrolled(tester, p);
    });
    // CHEESE-51: pushed from About's "Send feedback" row.
    Future<void> openFeedback(WidgetTester tester) async {
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();
    }

    scene('feedback', '/about', (tester, p) async {
      await openFeedback(tester);
      await scrolled(tester, p);
    });
    scene('feedback-invalid', '/about', (tester, p) async {
      await openFeedback(tester);
      await tester.enterText(find.byType(TextField).last, 'not-an-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Send feedback'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, 2000),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await scrolled(tester, p);
    });
    // CHEESE-45: the index from the drawer, then each section from it.
    Future<void> openGlossary(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasting terms'));
      await tester.pumpAndSettle();
    }

    scene('glossary', '/notes', (tester, p) async {
      await openGlossary(tester);
      await _shot(tester, p);
    });
    for (final s in ['flavor', 'texture', 'rind', 'milk']) {
      scene('glossary-$s', '/notes', (tester, p) async {
        await openGlossary(tester);
        await tester.tap(find.byKey(ValueKey('glossary-row-$s')));
        await tester.pumpAndSettle();
        await scrolled(tester, p);
      });
    }
    // From the note form's `?`, straight to its section.
    scene('glossary-from-form', '/notes/new', (tester, p) async {
      final help = find.byTooltip('Texture terms');
      await tester.scrollUntilVisible(
        help,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(help);
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    // Material's own surfaces, where the theme's default font and action
    // icons show.
    scene('dlg-date', '/notes/rogue/edit', (tester, p) async {
      await tester.tap(find.text('Aug 12, 2026'));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('dlg-rind', '/notes/new', (tester, p) async {
      await tester.tap(find.textContaining('Natural, bloomy'));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('dlg-style', '/notes/new', (tester, p) async {
      await tester.tap(find.text('Pick from the library'));
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
    scene('dlg-notices', '/licenses', (tester, p) async {
      await tester.tap(find.text('View all notices'));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await tester.pumpAndSettle();
      await _shot(tester, p);
    });
  }
}
