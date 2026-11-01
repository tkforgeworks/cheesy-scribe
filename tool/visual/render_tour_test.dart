// Renders the first-use tour's frames (CHEESE-49): one picture of the real
// app per slide, from the demo notebook in tour_demo.dart, in light and
// dark, plus where each slide's highlights sit. Not part of `flutter test`.
//
//   TOUR_OUT=/some/dir flutter test --concurrency=4 tool/visual/render_tour_test.dart
//
// Writes <out>/<theme>-<slide>.png (1080x2400) and, from the light run,
// <out>/rects/<slide>.json: the highlight rectangles as fractions of the
// screen ([left, top, width, height]), measured from the widgets
// themselves so they stay true when a screen changes.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cheesy_scribe/app/shell/scribe_drawer.dart';
import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/feedback/feedback_fab.dart';
import 'package:cheesy_scribe/features/library/library_screen.dart';
import 'package:cheesy_scribe/features/notes/widgets/featured_note_card.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_entry_card.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_list.dart';
import 'package:cheesy_scribe/features/notes/widgets/note_row.dart';
import 'package:cheesy_scribe/features/notes/widgets/texture_meter.dart';
import 'package:cheesy_scribe/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../test/support.dart';
import 'tour_demo.dart';

final _out = Directory(
  Platform.environment['TOUR_OUT'] ?? 'tool/visual/out/tour',
);

const _session = ForgeSession(
  userId: 'chuck',
  email: tourEmail,
  emailConfirmed: true,
  identities: [
    ForgeIdentity(
      id: tourEmail,
      identityId: 'link-email',
      provider: ForgeIdentityProvider.email,
      email: tourEmail,
    ),
    ForgeIdentity(
      id: '1234',
      identityId: 'link-google',
      provider: ForgeIdentityProvider.google,
      email: tourEmail,
    ),
  ],
);

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

/// One highlight: the smallest rectangle around everything [finder]
/// matches, padded a little and kept on screen, as screen fractions.
List<double> _rect(WidgetTester tester, Finder finder) {
  final elements = finder.evaluate().toList();
  if (elements.isEmpty) throw StateError('No highlight target: $finder');
  Rect? r;
  for (final e in elements) {
    final box = e.renderObject! as RenderBox;
    final b = box.localToGlobal(Offset.zero) & box.size;
    r = r == null ? b : r.expandToInclude(b);
  }
  final view = tester.view;
  final screen = Offset.zero & (view.physicalSize / view.devicePixelRatio);
  final padded = r!.inflate(4).intersect(screen);
  double f(double v, double of) => (v / of * 10000).roundToDouble() / 10000;
  return [
    f(padded.left, screen.width),
    f(padded.top, screen.height),
    f(padded.width, screen.width),
    f(padded.height, screen.height),
  ];
}

Future<void> _writeRects(String id, List<List<double>> rects) async {
  final file = File('${_out.path}/rects/$id.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(rects));
}

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is JournalField && w.label == label),
  matching: find.byType(TextField),
);

Finder _cardAround(Finder inner) =>
    find.ancestor(of: inner, matching: find.byType(Card));

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle();

void _scrollToTop(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .jumpTo(0);

/// Scrolls the nearest scrollable so [target] sits near the top. Starts
/// from the top: a lazy list has dropped what scrolled far away.
Future<void> _alignTop(WidgetTester tester, Finder target) async {
  _scrollToTop(tester);
  await _settle(tester);
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  final done = Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.02,
  );
  await _settle(tester);
  await done;
}

/// Types the featured note into the new-note form, the way a person would.
Future<void> _fillForm(WidgetTester tester) async {
  final n = tourFeatured;
  await tester.enterText(_field('Cheese name'), n.cheeseName);
  await tester.enterText(_field('Creamery'), n.creamery!);
  await tester.enterText(_field('Origin'), n.origin!);
  await tester.tap(_field('Rind'));
  await _settle(tester);
  await tester.tap(find.text(n.rind!.label).last);
  await _settle(tester);
  await tester.enterText(_field('Price'), '26');
  await tester.tap(_field('Style'));
  await _settle(tester);
  await tester.tap(find.text('Bloomy rind').last);
  await _settle(tester);
  await tester.enterText(_field('Verdict'), n.verdict!);
  // Cow is the default milk; only Raw needs ticking.
  await tester.ensureVisible(find.text('Raw'));
  await _settle(tester);
  await tester.tap(find.text('Raw'));
  final stars = find.descendant(
    of: find.byType(StarRating),
    matching: find.byType(GestureDetector),
  );
  await tester.ensureVisible(find.byType(StarRating));
  await _settle(tester);
  await tester.tap(stars.at(n.rating - 1));
  await tester.ensureVisible(find.byType(Slider));
  await _settle(tester);
  tester.widget<Slider>(find.byType(Slider)).onChanged!(
    n.texture.index.toDouble(),
  );
  await tester.ensureVisible(_field('Notes'));
  await _settle(tester);
  await tester.enterText(_field('Notes'), n.notes);
  // Score the flavors in List mode, then show the wheel again.
  await tester.ensureVisible(find.text('List'));
  await _settle(tester);
  await tester.tap(find.text('List'));
  await _settle(tester);
  for (final MapEntry(key: flavor, value: score) in n.flavors.entries) {
    final pip = find.byKey(FlavorList.pipKey(flavor, score));
    await tester.ensureVisible(pip);
    await _settle(tester);
    await tester.tap(pip);
  }
  await tester.ensureVisible(find.text('Wheel'));
  await _settle(tester);
  await tester.tap(find.text('Wheel'));
  await _settle(tester);
}

/// A slide's body: drives the app to its frame and names what to highlight.
typedef _Slide = Future<List<Finder>> Function(WidgetTester tester);

void main() {
  // The debug ribbon would cover the app bar's actions.
  WidgetsApp.debugAllowBannerOverride = false;

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    void slide(
      String id,
      String at,
      _Slide body, {
      bool seeded = true,
      bool signedIn = false,
    }) {
      testApp('${mode.name} $id', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        final auth = FakeForgeAuth(
          initial: signedIn
              ? const ForgeAuthState(
                  event: ForgeAuthEvent.initial,
                  session: _session,
                )
              : ForgeAuthState.signedOut,
        );
        addTearDown(auth.dispose);
        final db = openTestDatabase();
        if (seeded) {
          await tester.runAsync(() async {
            final repo = NotesRepository(
              db,
              owner: signedIn ? _session.userId : null,
            );
            for (final n in tourNotes) {
              await repo.save(n);
            }
          });
        }
        await pumpApp(
          tester,
          at: at,
          db: db,
          settings: AppSettings(
            displayName: tourDisplayName,
            themeMode: mode,
            memberSince: DateTime(2026, 6, 1),
          ),
          auth: auth,
          version: tourAppVersion,
        );
        final targets = await body(tester);
        FocusManager.instance.primaryFocus?.unfocus();
        await _settle(tester);
        await _shot(tester, '${mode.name}-$id');
        if (mode == ThemeMode.light) {
          await tester.runAsync(
            () => _writeRects(id, [for (final t in targets) _rect(tester, t)]),
          );
        }
      });
    }

    Future<void> openDrawer(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Open menu'));
      await _settle(tester);
    }

    // Chapter 1: your first note.
    slide('empty', '/notes', (tester) async {
      return [find.byType(ForgeFab)];
    }, seeded: false);
    slide('details', '/notes/new', (tester) async {
      await _fillForm(tester);
      _scrollToTop(tester);
      await _settle(tester);
      return [
        find.byWidgetPredicate(
          (w) =>
              w is JournalField &&
              const {
                'Cheese name',
                'Creamery',
                'Origin',
                'Date',
                'Rind',
                'Price',
                'Style',
                'Verdict',
              }.contains(w.label),
        ),
      ];
    });
    final milkCard = _cardAround(find.text('Grassfed'));
    slide('milk-rating', '/notes/new', (tester) async {
      await _fillForm(tester);
      await _alignTop(tester, milkCard);
      return [milkCard, _cardAround(find.byType(StarRating))];
    });
    slide('tasting', '/notes/new', (tester) async {
      await _fillForm(tester);
      final texture = _cardAround(find.byType(TextureMeter));
      await _alignTop(tester, texture);
      return [texture, find.byType(FlavorEntryCard)];
    });
    // One slide, two frames side by side: the same scores on the wheel and
    // in the list.
    slide('flavors-wheel', '/notes/new', (tester) async {
      await _fillForm(tester);
      await _alignTop(tester, find.byType(FlavorEntryCard));
      return [find.byType(FlavorEntryCard)];
    });
    slide('flavors-list', '/notes/new', (tester) async {
      await _fillForm(tester);
      // Switch after scrolling: a card the lazy list rebuilds starts on the
      // wheel again.
      await _alignTop(tester, find.byType(FlavorEntryCard));
      await tester.tap(find.text('List'));
      await _settle(tester);
      // The list is taller than the wheel; bring all sixteen rows up.
      final done = Scrollable.ensureVisible(
        tester.element(find.byType(FlavorEntryCard)),
        alignment: 0.02,
      );
      await _settle(tester);
      await done;
      return [find.byType(FlavorEntryCard)];
    });
    slide('terms', '/notes', (tester) async {
      await openDrawer(tester);
      await tester.tap(find.text('Tasting terms'));
      await _settle(tester);
      return [
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('glossary-row-'),
        ),
      ];
    });
    slide('saved', '/notes/${tourFeatured.id}', (tester) async {
      return [
        find.byWidgetPredicate(
          (w) =>
              w is ForgeTagCapsule ||
              (w is Text && w.data == tourFeatured.cheeseName),
        ),
      ];
    });
    slide('journal', '/notes', (tester) async {
      return [find.byType(FilterChip), find.byType(FeaturedNoteCard)];
    });
    slide('hold', '/notes', (tester) async {
      await tester.longPress(find.text('Époisses'));
      await _settle(tester);
      return [find.byType(BottomSheet)];
    });
    slide('search', '/notes', (tester) async {
      await tester.tap(find.byType(SearchBar).first);
      await _settle(tester);
      await tester.enterText(find.byType(TextField).last, 'France');
      await _settle(tester);
      // The journal's rows sit under the search view; Brie is only a row
      // in the results (the journal shows it as the featured card).
      return [
        find.byType(TextField).last,
        find.ancestor(
          of: find.text(tourFeatured.cheeseName),
          matching: find.byType(NoteRow),
        ),
      ];
    });

    // Chapter 2: find your way around.
    slide('drawer', '/notes', (tester) async {
      await openDrawer(tester);
      return [find.byType(DrawerPill)];
    });
    slide('library', '/library', (tester) async {
      return [
        find.ancestor(
          of: find.text('Bloomy rind'),
          matching: find.byType(StyleCard),
        ),
      ];
    });
    slide('style', '/library/bloomy-rind', (tester) async {
      return [
        find.byWidgetPredicate(
          (w) =>
              w is NoteRow ||
              (w is Text && w.data?.toLowerCase() == 'your tastings'),
        ),
      ];
    });
    slide('untasted', '/library/smoked', (tester) async {
      return [
        find.byWidgetPredicate(
          (w) =>
              (w is Text && w.data == "You haven't met this one yet.") ||
              w is FilledButton,
        ),
      ];
    });
    slide('settings', '/settings', (tester) async {
      return [
        find.byWidgetPredicate(
          (w) => w is ForgeSettingsGroup && w.label == 'Appearance',
        ),
        find.byKey(SettingsScreen.tourRowKey),
      ];
    });

    // Chapter 3: backup, if you want it.
    slide('optional', '/account', (tester) async {
      return [find.byType(ForgeSignInPanel)];
    });
    slide('delete', '/account', (tester) async {
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -900),
        warnIfMissed: false,
      );
      await _settle(tester);
      await tester.ensureVisible(find.byKey(ForgeAccountSettings.deleteKey));
      await _settle(tester);
      await tester.tap(find.byKey(ForgeAccountSettings.deleteKey));
      await _settle(tester);
      await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DEL');
      await _settle(tester);
      return [find.byType(ForgeConfirmSheet)];
    }, signedIn: true);

    // Chapter 4: tell us.
    slide('button', '/notes', (tester) async {
      return [find.byType(FeedbackFab)];
    });
    slide('feedback', '/notes', (tester) async {
      await tester.tap(find.byType(FeedbackFab));
      await _settle(tester);
      return [find.byType(FilterChip)];
    });
  }
}
