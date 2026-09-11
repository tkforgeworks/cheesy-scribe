import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import 'note_dates.dart';
import 'widgets/flavor_entry_card.dart';
import 'widgets/texture_meter.dart';

/// `/notes/:id` (DESIGN_SPEC §6, CHEESE-28). Streams the note so edits
/// show immediately; pops itself if the note is deleted underneath it.
class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(noteProvider(noteId), (previous, next) {
      final hadNote = previous?.asData?.value != null;
      final gone = next is AsyncData<TastingNote?> && next.value == null;
      if (hadNote && gone && context.canPop()) context.pop();
    });
    final async = ref.watch(noteProvider(noteId));
    final note = async.asData?.value;
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
        title: const Text('Tasting note'),
        actions: [
          if (note != null)
            IconButton(
              tooltip: 'Edit',
              onPressed: () => context.push('/notes/$noteId/edit'),
              icon: HeroIcon(
                HeroIcons.pencil,
                size: 22,
                color: c.onSurfaceVariant,
              ),
            ),
        ],
      ),
      body: switch (async) {
        AsyncData(value: final n?) => _NoteBody(note: n),
        AsyncData() => const EmptyState(
          icon: WedgeGlyph(size: 28),
          title: 'This note is gone',
          aside: 'Deleted elsewhere, presumably on purpose.',
        ),
        AsyncError() => const Padding(
          padding: EdgeInsets.all(24),
          child: ErrorCard(message: "Couldn't open this note."),
        ),
        _ => const Padding(padding: EdgeInsets.all(24), child: SkeletonList()),
      },
    );
  }
}

class _NoteBody extends ConsumerWidget {
  const _NoteBody({required this.note});

  final TastingNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final x = context.scribe;
    final styleName = note.cheeseStyleId == null
        ? null
        : ref
              .watch(cheeseStyleProvider(note.cheeseStyleId!))
              .asData
              ?.value
              ?.name;
    final price = note.price == null
        ? null
        : note.priceUnit.format(note.price!);

    final maker = <String>[?note.creamery, ?note.origin].join(' · ');
    final rind = switch (note.rind) {
      null => null,
      RindType.rindless => 'rindless',
      RindType.other => note.rindOther ?? 'other rind',
      final r => '${r.label.toLowerCase()} rind',
    };
    final makerLine = [if (maker.isNotEmpty) maker, ?rind].join(' — ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      children: [
        MonoLabel(
          'Tasted ${formatTastingDate(note.tastedAt)}${price == null ? '' : ' · $price'}',
          size: 9.5,
        ),
        const SizedBox(height: 6),
        Text(
          note.cheeseName,
          style: ScribeTheme.serif(
            size: 27,
            weight: FontWeight.w600,
            height: 1.2,
            color: c.onSurface,
          ),
        ),
        if (makerLine.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            makerLine,
            style: ScribeTheme.ui(size: 13, color: x.textTertiary),
          ),
        ],
        if (note.verdict != null) ...[
          const SizedBox(height: 10),
          Text(
            note.verdict!,
            style: ScribeTheme.serif(
              size: 13.5,
              italic: true,
              color: x.textTertiary,
            ),
          ),
        ],
        if (note.isRated) ...[
          const SizedBox(height: 14),
          StarRating(value: note.rating, size: 22, gap: 3, showScore: true),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            TagCapsule(
              note.milk == MilkType.other
                  ? (note.milkOther ?? 'Other milk')
                  : note.milk.label,
              tone: CapsuleTone.emphasis,
            ),
            if (note.isRaw) const TagCapsule('Raw', tone: CapsuleTone.emphasis),
            if (note.isGrassfed)
              const TagCapsule('Grassfed', tone: CapsuleTone.emphasis),
            if (note.attributeOther != null)
              TagCapsule(note.attributeOther!, tone: CapsuleTone.emphasis),
            TagCapsule(note.texture.label),
            if (price != null) TagCapsule(price),
            if (styleName != null) TagCapsule(styleName),
          ],
        ),
        if (note.notes.isNotEmpty) ...[
          const SizedBox(height: 18),
          _DetailCard(
            label: 'Notes',
            child: Text(note.notes, style: context.text.bodyLarge),
          ),
        ],
        if (note.flavors.isNotEmpty) ...[
          const SizedBox(height: 18),
          FlavorEntryCard(values: note.flavors),
        ],
        const SizedBox(height: 18),
        _DetailCard(
          label: 'Texture',
          child: TextureMeter(value: note.texture),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [MonoLabel(label), const SizedBox(height: 8), child],
      ),
    ),
  );
}
