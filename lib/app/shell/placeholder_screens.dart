/// Placeholder bodies for every route until the feature tickets land.
/// Each names the ticket that replaces it; delete the class with the ticket.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';
import '../widgets/widgets.dart';

/// Centered "arrives with CHEESE-N" body shared by the placeholders.
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.title, required this.ticket});

  final String title;
  final String ticket;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: const WedgeGlyph(size: 28),
      title: title,
      aside: 'Arrives with $ticket. The shell got here first.',
    );
  }
}

/// App bar for full-screen routes: back arrow (or close X for dialogs).
AppBar _backAppBar(
  BuildContext context,
  String title, {
  bool close = false,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
    tooltip: close ? 'Close' : 'Back',
    onPressed: () => context.pop(),
    icon: HeroIcon(
      close ? HeroIcons.xMark : HeroIcons.arrowLeft,
      size: 24,
      color: context.colors.onSurfaceVariant,
    ),
  ),
  title: Text(title),
  actions: actions,
);

// ---- Shell destinations ----

/// `/account` — CHEESE-34 (local profile).
class AccountPlaceholderScreen extends StatelessWidget {
  const AccountPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _backAppBar(context, 'Account'),
      body: const PlaceholderBody(title: 'Account', ticket: 'CHEESE-34'),
    );
  }
}
