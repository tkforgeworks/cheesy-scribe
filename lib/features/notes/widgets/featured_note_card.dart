import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../note_dates.dart';

/// The newest tasting, highlighted (DESIGN_SPEC §5 "Featured card"): 4 px
/// forge strip, mono "LATEST TASTING · AUG 12", serif 21 name, maker
/// line, 16 px stars + score (hidden when unrated), top-flavor capsules
/// and the italic featured quote (hidden when null).
class FeaturedNoteCard extends StatelessWidget {
  const FeaturedNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  final TastingNote note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final maker = [?note.creamery, ?note.origin].join(' — ');
    final quote = note.featuredQuote;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: ScribeTokens.forgeStrip,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonoLabel(
                    'Latest tasting · ${formatShortDate(note.tastedAt)}',
                    size: 9.5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.cheeseName,
                    style: ScribeTheme.serif(
                      size: 21,
                      weight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                  if (maker.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      maker,
                      style: ScribeTheme.ui(size: 12.5, color: x.textTertiary),
                    ),
                  ],
                  if (note.isRated) ...[
                    const SizedBox(height: 8),
                    StarRating(value: note.rating, size: 16, showScore: true),
                  ],
                  if (note.topFlavors.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final f in note.topFlavors) TagCapsule(f.label),
                      ],
                    ),
                  ],
                  if (quote != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '“$quote”',
                      style: ScribeTheme.serif(
                        size: 13,
                        italic: true,
                        color: c.onSecondaryContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
