import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_search_bar.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';
import 'widgets/featured_note_card.dart';
import 'widgets/note_row.dart';

/// `/notes` (DESIGN_SPEC §6 Home, CHEESE-24): pinned search bar, "Your
/// tastings" + count, filter chips, the featured newest note, then
/// divider-separated rows with paging; FAB hides on scroll-down.
class NotesHomeScreen extends ConsumerStatefulWidget {
  const NotesHomeScreen({super.key});

  static const pageSize = 20;

  @override
  ConsumerState<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends ConsumerState<NotesHomeScreen> {
  int _minRating = 0;
  String? _styleId;
  int _limit = NotesHomeScreen.pageSize;
  bool _fabVisible = true;

  bool get _filtered => _minRating > 0 || _styleId != null;

  NotesQuery get _query =>
      NotesQuery(minRating: _minRating, styleId: _styleId, limit: _limit);

  void _setFilter({int? minRating, Object? styleId = _keep}) {
    setState(() {
      if (minRating != null) _minRating = minRating;
      if (!identical(styleId, _keep)) _styleId = styleId as String?;
      _limit = NotesHomeScreen.pageSize;
    });
  }

  static const _keep = Object();

  void _loadMore(int total) {
    if (_limit >= total) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _limit < total) {
        setState(() => _limit += NotesHomeScreen.pageSize);
      }
    });
  }

  bool _onScroll(UserScrollNotification n) {
    final show = n.direction != ScrollDirection.reverse;
    if (show != _fabVisible) setState(() => _fabVisible = show);
    return false;
  }

  Future<void> _showActions(TastingNote note) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const HeroIcon(HeroIcons.pencil, size: 20),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: HeroIcon(
                HeroIcons.trash,
                size: 20,
                color: context.colors.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: context.colors.error),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      context.push('/notes/${note.id}/edit');
      return;
    }
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete this note?',
      aside: "${note.cheeseName} won't be back.",
      confirmLabel: 'Delete',
      cancelLabel: 'Keep it',
    );
    if (confirmed) await ref.read(notesRepositoryProvider).delete(note.id);
  }

  @override
  Widget build(BuildContext context) {
    final query = _query;
    final page = ref.watch(notesPageProvider(query));
    final count = ref.watch(notesCountProvider(query)).asData?.value;
    final total = ref
        .watch(notesCountProvider(const NotesQuery()))
        .asData
        ?.value;
    final newest = _filtered
        ? null
        : ref.watch(newestNoteProvider).asData?.value;
    final topStyles = ref.watch(topStyleIdsProvider).asData?.value ?? const [];
    final styles = ref.watch(cheeseStylesProvider).asData?.value ?? const [];
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarHeader(
                topPadding: topPadding,
                background: context.colors.surface,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Your tastings',
                          style: context.text.titleLarge,
                        ),
                      ),
                      if (count != null)
                        MonoLabel('$count ${count == 1 ? 'note' : 'notes'}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FilterChips(
                    minRating: _minRating,
                    styleId: _styleId,
                    styles: [
                      for (final id in topStyles)
                        for (final s in styles)
                          if (s.id == id) s,
                    ],
                    onAll: () => _setFilter(minRating: 0, styleId: null),
                    onRating: (on) => _setFilter(minRating: on ? 4 : 0),
                    onStyle: (id) => _setFilter(styleId: id),
                  ),
                  if (newest != null) ...[
                    const SizedBox(height: 14),
                    FeaturedNoteCard(
                      note: newest,
                      onTap: () => context.push('/notes/${newest.id}'),
                      onLongPress: () => _showActions(newest),
                    ),
                  ],
                ],
              ),
            ),
            ...switch (page) {
              AsyncData(value: final notes) => _rows(
                notes,
                count ?? 0,
                total ?? 0,
                newest,
              ),
              AsyncError() => [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: ErrorCard(
                      message: "Couldn't open the journal.",
                      onRetry: () => ref.invalidate(notesPageProvider(query)),
                    ),
                  ),
                ),
              ],
              _ => const [
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(child: SkeletonList()),
                ),
              ],
            },
            const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _fabVisible ? Offset.zero : const Offset(0, 0.4),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _fabVisible ? 1 : 0,
          child: ForgeFab(onPressed: () => context.push('/notes/new')),
        ),
      ),
    );
  }

  List<Widget> _rows(
    List<TastingNote> notes,
    int count,
    int total,
    TastingNote? featured,
  ) {
    // The featured note leads the same ordering; don't list it twice.
    final rows = featured == null
        ? notes
        : notes.where((n) => n.id != featured.id).toList();
    if (total == 0) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: const WedgeGlyph(size: 28),
            title: 'No tastings yet',
            aside: "The cheese isn't going to review itself.",
            action: SizedBox(
              width: 220,
              child: FilledButton(
                onPressed: () => context.push('/notes/new'),
                child: const Text('New tasting notes'),
              ),
            ),
          ),
        ),
      ];
    }
    if (rows.isEmpty && _filtered) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: const EmptyState(
            icon: WedgeGlyph(size: 28),
            title: 'Nothing matches',
            aside: 'Loosen the filters, or go taste something that fits.',
          ),
        ),
      ];
    }
    if (rows.isEmpty) {
      // Exactly one note, and it is the featured card above.
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'One tasting so far. The journal has room.',
              textAlign: TextAlign.center,
              style: ScribeTheme.serif(
                size: 13,
                italic: true,
                color: context.scribe.textTertiary,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        sliver: SliverList.separated(
          itemCount: rows.length,
          itemBuilder: (context, i) {
            if (i == rows.length - 1) _loadMore(count);
            final n = rows[i];
            return NoteRow(
              note: n,
              onTap: () => context.push('/notes/${n.id}'),
              onLongPress: () => _showActions(n),
            );
          },
          separatorBuilder: (context, _) =>
              Divider(height: 1, color: context.scribe.rowDivider),
        ),
      ),
    ];
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.minRating,
    required this.styleId,
    required this.styles,
    required this.onAll,
    required this.onRating,
    required this.onStyle,
  });

  final int minRating;
  final String? styleId;
  final List<CheeseStyle> styles;
  final VoidCallback onAll;
  final ValueChanged<bool> onRating;
  final ValueChanged<String?> onStyle;

  @override
  Widget build(BuildContext context) {
    final none = minRating == 0 && styleId == null;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: none,
            onSelected: (_) => onAll(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('4'),
                HeroIcon(
                  HeroIcons.star,
                  style: HeroIconStyle.solid,
                  size: 12,
                  color: minRating >= 4
                      ? context.colors.onPrimaryContainer
                      : context.scribe.starActive,
                ),
                const Text(' and up'),
              ],
            ),
            selected: minRating >= 4,
            onSelected: onRating,
          ),
          for (final s in styles) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(s.name),
              selected: styleId == s.id,
              onSelected: (on) => onStyle(on ? s.id : null),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pinned search bar: 8 px above, 52 px bar, 6 px below, on the page
/// colour so rows scroll underneath it.
class _SearchBarHeader extends SliverPersistentHeaderDelegate {
  const _SearchBarHeader({required this.topPadding, required this.background});

  final double topPadding;

  /// Passed in (not read in `build`) so a theme change rebuilds the header.
  final Color background;

  @override
  double get minExtent => topPadding + 66;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: context.colors.surface,
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 6),
      child: const ScribeSearchBar(hint: 'Search your tastings'),
    ),
  );

  @override
  bool shouldRebuild(_SearchBarHeader old) =>
      old.topPadding != topPadding || old.background != background;
}
