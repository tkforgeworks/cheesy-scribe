import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';
import '../feedback/feedback_client.dart';
import '../feedback/feedback_fab.dart';
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
      floatingActionButton: const FeedbackFab(
        source: FeedbackSource.styleDetail,
      ),
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
        AsyncData() => const ForgeEmptyState(
          icon: WedgeGlyph(size: 28),
          title: 'This style is off the menu',
          aside: 'No such entry in the library. The link may be stale.',
        ),
        AsyncError() => const Padding(
          padding: EdgeInsets.all(24),
          child: ForgeErrorCard(message: "Couldn't open the library."),
        ),
        _ => const Padding(
          padding: EdgeInsets.all(24),
          child: ForgeSkeletonList(),
        ),
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
    final x = context.forge;
    final notes = ref.watch(
      notesPageProvider(NotesQuery(styleId: style.id, limit: 200)),
    );
    final count = notes.asData?.value.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        4,
        24,
        // 40 dp feedback button + 16 margin + room (CHEESE-72).
        72,
      ).withNavBarInset(context),
      children: [
        ForgeMonoLabel(
          count == null ? 'Reference style' : '$count tasted',
          size: 9.5,
          emphasis: (count ?? 0) > 0,
          color: (count ?? 0) > 0 ? null : x.textTertiary,
        ),
        const SizedBox(height: 6),
        Text(
          style.name,
          style: ForgeType.serif(
            size: 27,
            weight: FontWeight.w600,
            height: 1.2,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          style.examples,
          style: ForgeType.serif(
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
                const ForgeMonoLabel('Typical profile'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in style.typicalMilk)
                      ForgeTagCapsule(m.label, tone: ForgeCapsuleTone.emphasis),
                  ],
                ),
                const SizedBox(height: 8),
                TextureMeter(value: style.typicalTexture),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const ForgeMonoLabel('Your tastings'),
        const SizedBox(height: 4),
        switch (notes) {
          AsyncData(value: final list) when list.isEmpty => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You haven't met this one yet.",
                  style: ForgeType.serif(
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
          AsyncError() => const ForgeErrorCard(
            message: "Couldn't open the journal.",
          ),
          _ => const ForgeSkeletonList(),
        },
      ],
    );
  }
}
