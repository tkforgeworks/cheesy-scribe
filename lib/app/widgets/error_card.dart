import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Inline error card (not a toast): error-tint background, one plain
/// statement, optional Retry text button (DESIGN_SPEC §8).
class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: context.scribe.errorTint,
        borderRadius: BorderRadius.circular(ScribeTokens.rCard),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: context.text.bodyMedium)),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: c.error),
              child: Text(retryLabel),
            ),
        ],
      ),
    );
  }
}
