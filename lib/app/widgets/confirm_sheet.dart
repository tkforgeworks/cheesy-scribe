import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Destructive / discard confirmation as a bottom sheet (radius 16 top):
/// title, optional serif-italic aside, neutral `OutlinedButton` + a
/// `FilledButton` coloured `error` when [destructive] (DESIGN_SPEC §8).
/// Resolves to `true` on confirm, `false` on cancel or dismiss.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  String? aside,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = true,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (_) => ConfirmSheet(
      title: title,
      aside: aside,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    super.key,
    required this.title,
    this.aside,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = true,
  });

  final String title;
  final String? aside;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleMedium),
            if (aside != null) ...[
              const SizedBox(height: 6),
              Text(
                aside!,
                style: ScribeTheme.serif(
                  size: 13.5,
                  italic: true,
                  color: context.scribe.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: destructive
                        ? FilledButton.styleFrom(
                            backgroundColor: c.error,
                            foregroundColor: c.onError,
                          )
                        : null,
                    child: Text(confirmLabel),
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
