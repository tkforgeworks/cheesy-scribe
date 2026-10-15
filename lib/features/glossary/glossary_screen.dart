import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import 'glossary_terms.dart';

/// `/glossary` (CHEESE-45): the glossary's index, reached from the drawer.
/// One row per section; each opens [GlossarySectionScreen] on its own page.
class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  /// Key of a section's row.
  static Key rowKey(GlossarySection s) => ValueKey('glossary-row-${s.name}');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    final sections = GlossarySection.values;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasting terms')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          32,
        ).withNavBarInset(context),
        children: [
          Text(glossaryIntro, style: context.text.bodyLarge),
          const SizedBox(height: 18),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, s) in sections.indexed) ...[
                  if (i > 0) Divider(height: 1, color: x.rowDivider),
                  InkWell(
                    key: rowKey(s),
                    onTap: () => context.push('/glossary/${s.name}'),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: ForgeType.serif(
                                    size: 18,
                                    weight: FontWeight.w600,
                                    height: 1.2,
                                    color: c.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.summary,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: c.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ForgeMonoLabel(
                                  '${glossaryTerms(s).length} terms',
                                  color: x.textTertiary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          HeroIcon(
                            HeroIcons.chevronRight,
                            size: 18,
                            color: x.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `/glossary/:section` (CHEESE-45): one section's intro and its terms.
/// Pushed from the index, or straight from the note form's `?`, which
/// stays mounted underneath with its draft so back returns to it.
class GlossarySectionScreen extends StatelessWidget {
  const GlossarySectionScreen({super.key, required this.section});

  /// Null for an unknown path segment.
  final GlossarySection? section;

  /// Key of one term's entry; [term] is an enum value or a milk attribute
  /// name (`'raw'`, `'grassfed'`).
  static Key termKey(Object term) =>
      ValueKey('glossary-term-${term is Enum ? term.name : term}');

  @override
  Widget build(BuildContext context) {
    final s = section;
    return Scaffold(
      appBar: AppBar(title: Text(s?.title ?? 'Tasting terms')),
      body: s == null
          ? const ForgeEmptyState(
              icon: HeroIcon(HeroIcons.questionMarkCircle, size: 28),
              title: 'No such section',
              aside: 'The link may be stale. The drawer has the full list.',
            )
          : _SectionBody(section: s),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section});

  final GlossarySection section;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final terms = glossaryTerms(section);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        32,
      ).withNavBarInset(context),
      children: [
        Text(
          section.intro,
          style: context.text.bodyLarge?.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, t) in terms.indexed) ...[
                if (i > 0) Divider(height: 1, color: context.forge.rowDivider),
                Padding(
                  key: GlossarySectionScreen.termKey(t.key),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForgeMonoLabel(t.label, emphasis: true),
                      const SizedBox(height: 6),
                      Text(t.definition, style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
