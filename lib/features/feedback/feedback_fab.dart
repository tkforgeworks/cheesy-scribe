import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import 'feedback_client.dart';
import 'feedback_screen.dart';

/// The small feedback button on browse-only screens (CHEESE-72): opens the
/// feedback form with [source] attached. Quiet on purpose, a bordered
/// surface button, so it reads as secondary beside the gradient [ForgeFab].
/// Screens with text entry don't get one.
class FeedbackFab extends StatelessWidget {
  const FeedbackFab({super.key, required this.source});

  /// On the button inside, for tests.
  static const buttonKey = Key('feedback-fab');
  static const tooltip = 'Send feedback';

  /// Two FABs share Home's route, so this one needs its own hero tag.
  static const heroTag = 'feedback-fab';

  final FeedbackSource source;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    return FloatingActionButton.small(
      key: buttonKey,
      heroTag: heroTag,
      tooltip: tooltip,
      onPressed: () => context.push(FeedbackScreen.location(source)),
      backgroundColor: c.surface,
      foregroundColor: c.onSurfaceVariant,
      elevation: 1,
      focusElevation: 1,
      hoverElevation: 1,
      highlightElevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: x.rowDivider),
      ),
      child: HeroIcon(
        HeroIcons.chatBubbleLeftEllipsis,
        size: 20,
        color: c.onSurfaceVariant,
      ),
    );
  }
}
