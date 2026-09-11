import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/library_repository.dart';

/// Result of a picker sheet: [cleared] when the user chose "none", a
/// [value] when they picked one. A dismissed sheet returns null instead.
class PickResult<T> {
  const PickResult.of(this.value) : cleared = false;
  const PickResult.cleared() : value = null, cleared = true;

  final T? value;
  final bool cleared;
}

/// RIND: single-select bottom sheet over [RindType] with a "not noted" row.
Future<PickResult<RindType>?> showRindPicker(
  BuildContext context, {
  RindType? selected,
}) => showModalBottomSheet<PickResult<RindType>>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: MonoLabel('Rind'),
        ),
        _PickRow(
          label: 'Not noted',
          selected: selected == null,
          onTap: () =>
              Navigator.pop(context, const PickResult<RindType>.cleared()),
        ),
        for (final r in RindType.values)
          _PickRow(
            label: r.label,
            selected: r == selected,
            onTap: () => Navigator.pop(context, PickResult.of(r)),
          ),
      ],
    ),
  ),
);

/// STYLE: searchable bottom sheet over the bundled library, with a
/// "no style" row to clear the link (decision B1).
Future<PickResult<CheeseStyle>?> showStylePicker(
  BuildContext context, {
  required List<CheeseStyle> styles,
  String? selectedId,
}) => showModalBottomSheet<PickResult<CheeseStyle>>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) =>
      _StylePickerSheet(styles: styles, selectedId: selectedId),
);

class _StylePickerSheet extends StatefulWidget {
  const _StylePickerSheet({required this.styles, this.selectedId});

  final List<CheeseStyle> styles;
  final String? selectedId;

  @override
  State<_StylePickerSheet> createState() => _StylePickerSheetState();
}

class _StylePickerSheetState extends State<_StylePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = LibraryRepository.search(widget.styles, _query);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonoLabel('Style'),
                  const SizedBox(height: 8),
                  SearchBar(
                    hintText: 'Search the library',
                    autoFocus: false,
                    leading: HeroIcon(
                      HeroIcons.magnifyingGlass,
                      size: 20,
                      color: context.scribe.textTertiary,
                    ),
                    onChanged: (q) => setState(() => _query = q),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                children: [
                  if (_query.trim().isEmpty)
                    _PickRow(
                      label: 'No style',
                      selected: widget.selectedId == null,
                      onTap: () => Navigator.pop(
                        context,
                        const PickResult<CheeseStyle>.cleared(),
                      ),
                    ),
                  for (final s in matches)
                    _PickRow(
                      label: s.name,
                      subtitle: s.examples,
                      selected: s.id == widget.selectedId,
                      onTap: () => Navigator.pop(context, PickResult.of(s)),
                    ),
                  if (matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Nothing matches — either a typo or a cheese frontier.',
                        textAlign: TextAlign.center,
                        style: ScribeTheme.serif(
                          size: 13.5,
                          italic: true,
                          color: context.scribe.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      selected: selected,
      selectedTileColor: c.primaryContainer,
      selectedColor: c.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScribeTokens.rCard),
      ),
      title: Text(label),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: ScribeTheme.serif(
                size: 12.5,
                italic: true,
                color: selected
                    ? c.onPrimaryContainer
                    : context.scribe.textTertiary,
              ),
            ),
      trailing: selected
          ? HeroIcon(HeroIcons.check, size: 18, color: c.onPrimaryContainer)
          : null,
      onTap: onTap,
    );
  }
}
