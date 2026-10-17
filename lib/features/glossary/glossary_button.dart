import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import 'glossary_terms.dart';

/// The note form's `?` beside a section (CHEESE-45): pushes that
/// section's glossary page. Pushing leaves the form mounted, draft and all,
/// so back returns to it as it was.
class GlossaryButton extends StatelessWidget {
  const GlossaryButton({super.key, required this.section});

  final GlossarySection section;

  /// "Rind terms", "Flavor wheel terms", …; also how tests find it.
  static String tooltipFor(GlossarySection s) => '${s.title} terms';

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltipFor(section),
    // Narrow, so it fits between the flavor card's title and its toggle.
    visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
    onPressed: () => context.push('/glossary/${section.name}'),
    icon: HeroIcon(
      HeroIcons.questionMarkCircle,
      size: 18,
      color: context.forge.textTertiary,
    ),
  );
}
