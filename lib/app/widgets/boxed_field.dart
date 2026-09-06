import 'package:flutter/material.dart';

import 'mono_label.dart';

/// Boxed input for auth / account / settings screens: the theme's filled,
/// outlined `TextField` with the mono label OUTSIDE the field (no floating
/// M3 label). Spec sheet 03 "boxed input".
class BoxedField extends StatelessWidget {
  const BoxedField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.errorText,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, errorText: errorText),
        ),
      ],
    );
  }
}
