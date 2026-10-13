import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';
import 'mono_label.dart';

/// Note-form input: no box, a 1.5 px dotted underline, mono label above and
/// a serif-italic hint (spec sheet 03 "journal input"). Error state turns the
/// underline `error` and adds a mono error line below ("A CHEESE NEEDS A
/// NAME."). Pass [onTap] with [readOnly] for picker-style fields (date, rind,
/// style).
class JournalField extends StatelessWidget {
  const JournalField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines = 1,
    this.errorText,
    this.trailing,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final String? errorText;
  final Widget? trailing;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    final c = context.colors;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(label),
        const SizedBox(height: 8),
        CustomPaint(
          painter: DottedUnderlinePainter(
            color: hasError ? c.error : x.dottedLine,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onTap: onTap,
                  readOnly: readOnly,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  autofocus: autofocus,
                  style: context.text.bodyMedium,
                  cursorColor: c.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 2, bottom: 8),
                    hintText: hint,
                    hintStyle: ScribeTheme.serif(
                      size: 14,
                      italic: true,
                      color: x.textGhost,
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: trailing,
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!.toUpperCase(),
              style: context.text.labelMedium!.copyWith(color: c.error),
            ),
          ),
      ],
    );
  }
}

/// 1.5 px dotted line along the bottom edge of the child.
class DottedUnderlinePainter extends CustomPainter {
  const DottedUnderlinePainter({
    required this.color,
    this.thickness = 1.5,
    this.gap = 3,
  });

  final Color color;
  final double thickness;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = thickness / 2;
    final y = size.height - r;
    for (var x = r; x < size.width; x += thickness + gap) {
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(DottedUnderlinePainter old) =>
      old.color != color || old.thickness != thickness || old.gap != gap;
}
