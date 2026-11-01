import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import 'tour_highlights.dart';
import 'tour_slides.dart';

/// `/tour` (CHEESE-49): the first-use tour, a slide show of pictures of
/// the real app with the part each slide is about left bright. Opens by
/// itself on launch until this phone has finished or skipped the current
/// [version] (`AppSettings.tourVersion`), and from Settings at any time.
class TourScreen extends ConsumerStatefulWidget {
  const TourScreen({super.key});

  static const path = '/tour';

  /// Raise it when the tour changes enough that everyone should see it
  /// once more.
  static const version = 1;

  static const skipKey = Key('tour-skip');
  static const backKey = Key('tour-back');
  static const nextKey = Key('tour-next');
  static const pagesKey = Key('tour-pages');

  static const writeLabel = 'Write my first note';

  /// Where a slide's picture lives, for [brightness].
  static String asset(String frame, Brightness brightness) =>
      'assets/tour/${brightness.name}-$frame.webp';

  @override
  ConsumerState<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends ConsumerState<TourScreen> {
  final _pages = PageController();
  int _page = 0;

  bool get _isLast => _page == tourSlides.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAround(_page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Decodes the neighbours' pictures ahead of a swipe. Not all of them:
  /// each one is several megabytes once decoded.
  void _precacheAround(int page) {
    final brightness = Theme.of(context).brightness;
    for (final i in [page - 1, page, page + 1]) {
      if (i < 0 || i >= tourSlides.length) continue;
      for (final frame in tourSlides[i].frames) {
        precacheImage(AssetImage(TourScreen.asset(frame, brightness)), context);
      }
    }
  }

  void _go(int page) => _pages.animateToPage(
    page,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
  );

  /// Finishing and skipping are the same as far as the phone is
  /// concerned: this version has been seen.
  void _close({bool writeNote = false}) {
    ref
        .read(settingsRepositoryProvider)
        .update((s) => s.copyWith(tourVersion: TourScreen.version));
    final router = GoRouter.of(context);
    router.pop();
    if (writeNote) router.push('/notes/new');
  }

  @override
  Widget build(BuildContext context) {
    final slide = tourSlides[_page];
    final inChapter = [
      for (final s in tourSlides)
        if (s.chapter == slide.chapter) s,
    ];
    final colors = context.colors;
    return PopScope(
      canPop: false,
      // System back steps back a slide; on the first one it leaves.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_page > 0) {
          _go(_page - 1);
        } else {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ForgeMonoLabel(
                        '${slide.chapter.index + 1} · ${slide.chapter.label}',
                      ),
                    ),
                    TextButton(
                      key: TourScreen.skipKey,
                      onPressed: _close,
                      child: Text(_isLast ? 'Done' : 'Skip'),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    key: TourScreen.pagesKey,
                    controller: _pages,
                    itemCount: tourSlides.length,
                    onPageChanged: (page) {
                      setState(() => _page = page);
                      _precacheAround(page);
                    },
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SlideView(slide: tourSlides[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Dots(
                        count: inChapter.length,
                        current: inChapter.indexOf(slide),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          // forge_ui's buttons fill their width.
                          Expanded(
                            child: OutlinedButton(
                              key: TourScreen.backKey,
                              onPressed: _page == 0
                                  ? null
                                  : () => _go(_page - 1),
                              child: const Text('Back'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              key: TourScreen.nextKey,
                              onPressed: _isLast
                                  ? () => _close(writeNote: true)
                                  : () => _go(_page + 1),
                              child: Text(
                                _isLast ? TourScreen.writeLabel : 'Next',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One slide: its picture (or two side by side), then the words.
class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final TourSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, frame) in slide.frames.indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Flexible(child: _Frame(frame: frame)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.title,
          style: ForgeType.ui(
            size: 20,
            weight: FontWeight.w600,
            height: 1.25,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slide.body,
          style: ForgeType.serif(
            size: 16,
            height: 1.45,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A picture of the app at the phone's own proportions, dimmed except
/// where this frame's highlights are.
class _Frame extends StatelessWidget {
  const _Frame({required this.frame});

  final String frame;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    return Center(
      child: AspectRatio(
        aspectRatio: 1080 / 2400,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(
              foregroundPainter: TourHighlightPainter(
                rects: tourHighlights[frame] ?? const [],
                dim: brightness == Brightness.dark
                    ? const Color(0x99000000)
                    : const Color(0x851E1408),
                ring: colors.primary,
              ),
              child: Image.asset(
                TourScreen.asset(frame, brightness),
                fit: BoxFit.cover,
                // The words under the picture say what it shows.
                excludeFromSemantics: true,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dims everything but [rects] (fractions of the picture) and rings them.
class TourHighlightPainter extends CustomPainter {
  const TourHighlightPainter({
    required this.rects,
    required this.dim,
    required this.ring,
  });

  final List<Rect> rects;
  final Color dim;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    if (rects.isEmpty) return;
    final holes = [
      for (final r in rects)
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            r.left * size.width,
            r.top * size.height,
            r.width * size.width,
            r.height * size.height,
          ),
          const Radius.circular(6),
        ),
    ];
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final h in holes) {
      shade.addRRect(h);
    }
    canvas.drawPath(shade, Paint()..color = dim);
    final stroke = Paint()
      ..color = ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final h in holes) {
      canvas.drawRRect(h, stroke);
    }
  }

  @override
  bool shouldRepaint(TourHighlightPainter old) =>
      old.rects != rects || old.dim != dim || old.ring != ring;
}

/// Where this slide sits in its chapter.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == current ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == current ? colors.primary : colors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
