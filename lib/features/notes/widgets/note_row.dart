import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../note_dates.dart';

/// Home list row (DESIGN_SPEC §5): 42 px initials avatar, title 15/500,
/// "creamery · origin — Aug 3" subtitle, trailing 12 px stars (hidden when
/// unrated) and a mono milk tag. Divider is the caller's.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  final TastingNote note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// First two letters of the name ("CO" for Comté), upper-cased.
  static String initials(String name) {
    final letters = name.runes
        .map(String.fromCharCode)
        .where((ch) => RegExp(r'\p{L}', unicode: true).hasMatch(ch))
        .take(2)
        .join();
    return (letters.isEmpty
            ? name.trim().substring(0, name.trim().length.clamp(0, 2))
            : letters)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final sub = [
      [?note.creamery, ?note.origin].join(' · '),
      formatShortDate(note.tastedAt),
    ].where((s) => s.isNotEmpty).join(' — ');
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials(note.cheeseName),
                style: ScribeTheme.mono(
                  size: 12,
                  weight: FontWeight.w600,
                  color: c.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.cheeseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (note.isRated) StarRating(value: note.rating, size: 12),
                if (note.isRated) const SizedBox(height: 2),
                Text(
                  (note.milk == MilkType.other
                          ? (note.milkOther ?? 'other')
                          : note.milk.label)
                      .toUpperCase(),
                  style: ScribeTheme.mono(
                    size: 9,
                    weight: FontWeight.w500,
                    color: x.textGhost,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
