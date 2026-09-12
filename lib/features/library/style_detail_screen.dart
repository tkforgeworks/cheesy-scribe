import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';
import '../notes/widgets/note_row.dart';
import '../notes/widgets/texture_meter.dart';

/// `/library/:styleId` (CHEESE-29): the style's description, its typical
/// profile and the user's notes linked to it, live.
class StyleDetailScreen extends ConsumerWidget {
  const StyleDetailScreen({super.key, required this.styleId});

  final String styleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styleAsync = ref.watch(cheeseStyleProvider(styleId));
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: HeroIcon(
            HeroIcons.arrowLeft,
            size: 24,
            color: c.onSurfaceVariant,
          ),
        ),
        title: const Text('Cheese style'),
      ),
      body: switch (styleAsync) {
        AsyncData(value: final style?) => _StyleBody(style: style),
        AsyncData() => const EmptyState(
          icon: WedgeGlyph(size: 28),
          title: 'This style is off the menu',
          aside: 'No such entry in the library. The link may be stale.',
        ),
        AsyncError() => const Padding(
          padding: EdgeInsets.all(24),
          child: ErrorCard(message: "Couldn't open the library."),
        ),
        _ => const Padding(padding: EdgeInsets.all(24), child: SkeletonList()),
      },
    );
  }
}

class _StyleBody extends ConsumerWidget {
  const _StyleBody({required this.style});

  final CheeseStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final x = context.scribe;
    final notes = ref.watch(
      notesPageProvider(NotesQuery(styleId: style.id, limit: 200)),
    );
    final count = notes.asData?.value.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      children: [
        MonoLabel(
          count == null ? 'Reference style' : '$count tasted',
          size: 9.5,
          emphasis: (count ?? 0) > 0,
          color: (count ?? 0) > 0 ? null : x.textTertiary,
        ),
        const SizedBox(height: 6),
        Text(
          style.name,
          style: ScribeTheme.serif(
            size: 27,
            weight: FontWeight.w600,
            height: 1.2,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          style.examples,
          style: ScribeTheme.serif(
            size: 13.5,
            italic: true,
            color: x.textTertiary,
          ),
        ),
        if (style.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(style.description, style: context.text.bodyLarge),
        ],
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MonoLabel('Typical profile'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in style.typicalMilk)
                      TagCapsule(m.label, tone: CapsuleTone.emphasis),
                  ],
                ),
                const SizedBox(height: 8),
                TextureMeter(value: style.typicalTexture),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const MonoLabel('Your tastings'),
        const SizedBox(height: 4),
        switch (notes) {
          AsyncData(value: final list) when list.isEmpty => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You haven't met this one yet.",
                  style: ScribeTheme.serif(
                    size: 13.5,
                    italic: true,
                    color: x.textTertiary,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 220,
                  child: FilledButton(
                    onPressed: () =>
                        context.push('/notes/new?style=${style.id}'),
                    child: const Text('New tasting note'),
                  ),
                ),
              ],
            ),
          ),
          AsyncData(value: final list) => Column(
            children: [
              for (final (i, n) in list.indexed) ...[
                if (i > 0) Divider(height: 1, color: x.rowDivider),
                NoteRow(note: n, onTap: () => context.push('/notes/${n.id}')),
              ],
            ],
          ),
          AsyncError() => const ErrorCard(
            message: "Couldn't open the journal.",
          ),
          _ => const SkeletonList(),
        },
      ],
    );
  }
}
