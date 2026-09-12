import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_search_bar.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';
import 'widgets/note_row.dart';

/// The Home search bar with its full-screen search view (DESIGN_SPEC §6
/// "Search mode", CHEESE-25). Typing live-filters across name, creamery,
/// origin, notes, verdict and flavor labels; recent searches show until
/// typing starts and are recorded on result tap or submit.
class NotesSearchAnchor extends ConsumerStatefulWidget {
  const NotesSearchAnchor({super.key});

  static const hint = 'Search your tastings';

  /// Keys on the view's results / recents lists (the Home list stays in
  /// the tree beneath the full-screen view, so tests scope by these).
  static const resultsKey = Key('search-results');
  static const recentsKey = Key('search-recents');

  @override
  ConsumerState<NotesSearchAnchor> createState() => _NotesSearchAnchorState();
}

class _NotesSearchAnchorState extends ConsumerState<NotesSearchAnchor> {
  final _controller = SearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _record(String term) =>
      ref.read(recentSearchesRepositoryProvider).add(term);

  void _openNote(String id, String term) {
    _record(term);
    _controller.closeView(null);
    context.push('/notes/$id');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    return SearchAnchor(
      searchController: _controller,
      isFullScreen: true,
      viewHintText: NotesSearchAnchor.hint,
      viewBackgroundColor: c.surface,
      viewSurfaceTintColor: Colors.transparent,
      dividerColor: c.outlineVariant,
      headerTextStyle: ScribeTheme.ui(size: 15, color: c.onSurface),
      headerHintStyle: ScribeTheme.ui(size: 15, color: x.textTertiary),
      viewLeading: IconButton(
        tooltip: 'Close search',
        onPressed: () => _controller.closeView(null),
        icon: HeroIcon(
          HeroIcons.arrowLeft,
          size: 24,
          color: c.onSurfaceVariant,
        ),
      ),
      viewTrailing: [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: _controller.clear,
                  icon: HeroIcon(
                    HeroIcons.xMark,
                    size: 20,
                    color: c.onSurfaceVariant,
                  ),
                ),
        ),
      ],
      viewOnSubmitted: (q) {
        if (q.trim().isNotEmpty) _record(q.trim());
      },
      builder: (context, controller) => ScribeSearchBar(
        hint: NotesSearchAnchor.hint,
        onTap: controller.openView,
      ),
      suggestionsBuilder: (context, controller) => [
        _SearchBody(
          query: controller.text,
          onPickRecent: (term) => controller.text = term,
          onOpenNote: (id) => _openNote(id, controller.text.trim()),
          onClear: controller.clear,
        ),
      ],
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({
    required this.query,
    required this.onPickRecent,
    required this.onOpenNote,
    required this.onClear,
  });

  final String query;
  final ValueChanged<String> onPickRecent;
  final ValueChanged<String> onOpenNote;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().isEmpty) return _Recents(onPick: onPickRecent);
    final q = NotesQuery(search: query, limit: 50);
    final results = ref.watch(notesPageProvider(q));
    final count = ref.watch(notesCountProvider(q)).asData?.value;
    return switch (results) {
      AsyncData(value: final notes) when notes.isEmpty => _NoResults(
        onClear: onClear,
      ),
      AsyncData(value: final notes) => Padding(
        key: NotesSearchAnchor.resultsKey,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonoLabel(
              '${count ?? notes.length} ${(count ?? notes.length) == 1 ? 'result' : 'results'}',
            ),
            const SizedBox(height: 4),
            for (final (i, n) in notes.indexed) ...[
              if (i > 0) Divider(height: 1, color: context.scribe.rowDivider),
              NoteRow(note: n, onTap: () => onOpenNote(n.id)),
            ],
          ],
        ),
      ),
      AsyncError() => const Padding(
        padding: EdgeInsets.all(16),
        child: ErrorCard(message: "Couldn't search the journal."),
      ),
      _ => const Padding(padding: EdgeInsets.all(16), child: SkeletonList()),
    };
  }
}

class _Recents extends ConsumerWidget {
  const _Recents({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider).asData?.value ?? const [];
    final x = context.scribe;
    if (recents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Text(
          'Search by name, creamery, origin, notes or flavor.',
          textAlign: TextAlign.center,
          style: ScribeTheme.serif(
            size: 13.5,
            italic: true,
            color: x.textTertiary,
          ),
        ),
      );
    }
    return Padding(
      key: NotesSearchAnchor.recentsKey,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: MonoLabel('Recent searches'),
          ),
          const SizedBox(height: 4),
          for (final term in recents)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: HeroIcon(
                HeroIcons.clock,
                size: 20,
                color: x.textTertiary,
              ),
              title: Text(term, style: context.text.bodyMedium),
              trailing: IconButton(
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    ref.read(recentSearchesRepositoryProvider).remove(term),
                icon: HeroIcon(HeroIcons.xMark, size: 18, color: x.textGhost),
              ),
              onTap: () => onPick(term),
            ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('0 results'),
          const SizedBox(height: 8),
          Text(
            'Nothing matches — either a typo or a cheese frontier.',
            style: ScribeTheme.serif(
              size: 13.5,
              italic: true,
              color: context.scribe.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onClear,
              child: const Text('Clear search'),
            ),
          ),
        ],
      ),
    );
  }
}
