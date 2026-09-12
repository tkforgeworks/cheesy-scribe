import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/scribe_search_bar.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/library_repository.dart';

/// `/library` (DESIGN_SPEC §6, CHEESE-29): the bundled styles as a two-column
/// card grid with live "N TASTED" counts; the bar filters by name/examples.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stylesAsync = ref.watch(cheeseStylesProvider);
    final counts = ref.watch(styleCountsProvider).asData?.value ?? const {};
    final x = context.scribe;
    final all = stylesAsync.asData?.value ?? const <CheeseStyle>[];
    final shown = LibraryRepository.search(all, _query.text);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: [
                  ScribeSearchBar(
                    hint: 'Search the library',
                    controller: _query,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Cheese library',
                          style: context.text.titleLarge,
                        ),
                      ),
                      if (stylesAsync.hasValue)
                        MonoLabel(
                          '${all.length} ${all.length == 1 ? 'style' : 'styles'}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Reference styles to taste against — the 'what am I even eating' section.",
                    style: ScribeTheme.serif(
                      size: 12.5,
                      italic: true,
                      color: x.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (stylesAsync.isLoading)
              const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(child: SkeletonList()),
              )
            else if (stylesAsync.hasError)
              const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: ErrorCard(message: "Couldn't open the library."),
                ),
              )
            else if (shown.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: const WedgeGlyph(size: 28),
                  title: 'No such style',
                  aside:
                      'Nothing matches — either a typo or a cheese frontier.',
                  action: TextButton(
                    onPressed: () => setState(_query.clear),
                    child: const Text('Clear search'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 112,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => StyleCard(
                    style: shown[i],
                    tasted: counts[shown[i].id] ?? 0,
                    onTap: () => context.push('/library/${shown[i].id}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Library grid card: name 15/600 → mono "N TASTED" (emphasis when > 0,
/// tertiary when 0) → italic serif examples.
class StyleCard extends StatelessWidget {
  const StyleCard({
    super.key,
    required this.style,
    required this.tasted,
    required this.onTap,
  });

  final CheeseStyle style;
  final int tasted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ScribeTheme.ui(
                  size: 15,
                  weight: FontWeight.w600,
                  color: c.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              MonoLabel(
                '$tasted tasted',
                size: 9.5,
                emphasis: tasted > 0,
                color: tasted > 0 ? null : x.textTertiary,
              ),
              const SizedBox(height: 6),
              Text(
                style.examples,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ScribeTheme.serif(
                  size: 11.5,
                  italic: true,
                  color: x.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
