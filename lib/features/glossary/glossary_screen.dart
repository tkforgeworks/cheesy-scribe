import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../data/models/models.dart';
import 'glossary_terms.dart';

/// `/glossary` (CHEESE-45): what the note form's tasting terms mean. Pushed
/// over whatever opened it (the drawer, or a help button on the note form,
/// which stays mounted underneath with its draft), so it has a back arrow.
/// [initialSection] opens it scrolled to that section.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key, this.initialSection});

  final GlossarySection? initialSection;

  static Key sectionKey(GlossarySection s) => ValueKey('glossary-${s.name}');

  /// Key of one term's entry; [term] is an enum value or a milk attribute
  /// name (`'raw'`, `'grassfed'`).
  static Key termKey(Object term) =>
      ValueKey('glossary-term-${term is Enum ? term.name : term}');

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _sections = {for (final s in GlossarySection.values) s: GlobalKey()};

  @override
  void initState() {
    super.initState();
    final target = widget.initialSection;
    if (target != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _sections[target]!.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasting terms')),
      // Not a lazy list: every section must be laid out for the initial
      // jump, and the whole page is a few dozen short entries.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          32,
        ).withNavBarInset(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(glossaryIntro, style: context.text.bodyLarge),
            for (final s in GlossarySection.values) ...[
              const SizedBox(height: 22),
              _Section(
                key: _sections[s],
                section: s,
                terms: switch (s) {
                  GlossarySection.flavor => [
                    for (final f in FlavorNote.values)
                      (f, f.label, f.definition),
                  ],
                  GlossarySection.texture => [
                    for (final t in TextureLevel.values)
                      (t, t.label, t.definition),
                  ],
                  GlossarySection.rind => [
                    for (final r in RindType.values) (r, r.label, r.definition),
                  ],
                  GlossarySection.milk => const [
                    ('raw', 'Raw', rawDefinition),
                    ('grassfed', 'Grassfed', grassfedDefinition),
                  ],
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.section, required this.terms});

  final GlossarySection section;

  /// (key object, label, definition).
  final List<(Object, String, String)> terms;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      key: GlossaryScreen.sectionKey(section),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          style: ForgeType.serif(
            size: 22,
            weight: FontWeight.w600,
            height: 1.2,
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          section.intro,
          style: context.text.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, (term, label, definition)) in terms.indexed) ...[
                if (i > 0) Divider(height: 1, color: context.forge.rowDivider),
                Padding(
                  key: GlossaryScreen.termKey(term),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForgeMonoLabel(label, emphasis: true),
                      const SizedBox(height: 6),
                      Text(definition, style: context.text.bodyMedium),
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
