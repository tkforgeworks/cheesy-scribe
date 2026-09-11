import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import 'note_dates.dart';
import 'widgets/flavor_entry_card.dart';
import 'widgets/pickers.dart';

/// `/notes/new` and `/notes/:id/edit` (DESIGN_SPEC §6, CHEESE-27): the
/// slide-up journal page. Save is enabled once the cheese has a name; the
/// X / back asks before discarding edits; edit mode prefills everything
/// and saves in place.
class NoteFormScreen extends ConsumerStatefulWidget {
  const NoteFormScreen({super.key, this.noteId});

  /// Null for a new note.
  final String? noteId;

  bool get isEditing => noteId != null;

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  static const _gap = SizedBox(height: 18);

  final _name = TextEditingController();
  final _creamery = TextEditingController();
  final _origin = TextEditingController();
  final _rindOther = TextEditingController();
  final _price = TextEditingController();
  final _verdict = TextEditingController();
  final _milkOther = TextEditingController();
  final _attributeOther = TextEditingController();
  final _notes = TextEditingController();
  // Display-only controllers for the picker fields.
  final _dateText = TextEditingController();
  final _rindText = TextEditingController();
  final _styleText = TextEditingController();

  late String _id;
  late DateTime _createdAt;
  DateTime _tastedAt = TastingNote.dateOnly(DateTime.now());
  RindType? _rind;
  PriceUnit _priceUnit = PriceUnit.usdPerLb;
  MilkType _milk = MilkType.cow;
  bool _isGrassfed = false;
  bool _isRaw = false;
  int _rating = 0;
  TextureLevel _texture = TextureLevel.semiSoft;
  Map<FlavorNote, int> _flavors = const {};
  String? _cheeseStyleId;
  String? _photoUrl;

  /// What the form held when it opened; the dirty check compares to it.
  TastingNote? _initial;
  bool _loaded = false;
  bool _missing = false;
  bool _saving = false;
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_onEdit);
    }
    _load();
  }

  List<TextEditingController> get _controllers => [
    _name,
    _creamery,
    _origin,
    _rindOther,
    _price,
    _verdict,
    _milkOther,
    _attributeOther,
    _notes,
  ];

  Future<void> _load() async {
    final repo = ref.read(notesRepositoryProvider);
    if (widget.isEditing) {
      final note = await repo.getNote(widget.noteId!);
      if (!mounted) return;
      if (note == null) {
        setState(() => _missing = true);
        return;
      }
      _apply(note);
      if (note.cheeseStyleId != null) {
        final style = await ref
            .read(libraryRepositoryProvider)
            .byId(note.cheeseStyleId!);
        if (!mounted) return;
        _styleText.text = style?.name ?? '';
      }
    } else {
      final settings = await ref.read(settingsRepositoryProvider).load();
      if (!mounted) return;
      _id = repo.newId();
      _createdAt = DateTime.now().toUtc();
      _priceUnit = settings.units;
    }
    _dateText.text = formatTastingDate(_tastedAt);
    _rindText.text = _rind?.label ?? '';
    setState(() {
      _initial = _build();
      _loaded = true;
    });
  }

  void _apply(TastingNote n) {
    _id = n.id;
    _createdAt = n.createdAt;
    _name.text = n.cheeseName;
    _creamery.text = n.creamery ?? '';
    _origin.text = n.origin ?? '';
    _tastedAt = n.tastedAt;
    _rind = n.rind;
    _rindOther.text = n.rindOther ?? '';
    _price.text = n.price == null ? '' : _formatPrice(n.price!);
    _priceUnit = n.priceUnit;
    _milk = n.milk;
    _milkOther.text = n.milkOther ?? '';
    _isGrassfed = n.isGrassfed;
    _isRaw = n.isRaw;
    _attributeOther.text = n.attributeOther ?? '';
    _rating = n.rating;
    _texture = n.texture;
    _notes.text = n.notes;
    _verdict.text = n.verdict ?? '';
    _flavors = n.flavors;
    _cheeseStyleId = n.cheeseStyleId;
    _photoUrl = n.photoUrl;
  }

  static String _formatPrice(double p) =>
      p == p.roundToDouble() ? p.toStringAsFixed(0) : p.toString();

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  /// Price as typed, or null when blank; NaN when unparseable.
  double? _parsePrice() {
    final t = _price.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t) ?? double.nan;
  }

  /// The note as the form currently describes it.
  TastingNote _build() {
    final price = _parsePrice();
    return TastingNote(
      id: _id,
      cheeseName: _name.text.trim(),
      tastedAt: _tastedAt,
      createdAt: _createdAt,
      creamery: _text(_creamery),
      origin: _text(_origin),
      rind: _rind,
      rindOther: _rind == RindType.other ? _text(_rindOther) : null,
      price: price == null || price.isNaN || price < 0 ? null : price,
      priceUnit: _priceUnit,
      milk: _milk,
      milkOther: _milk == MilkType.other ? _text(_milkOther) : null,
      isGrassfed: _isGrassfed,
      isRaw: _isRaw,
      attributeOther: _text(_attributeOther),
      rating: _rating,
      texture: _texture,
      notes: _notes.text.trim(),
      verdict: _text(_verdict),
      flavors: _flavors,
      cheeseStyleId: _cheeseStyleId,
      photoUrl: _photoUrl,
    );
  }

  bool get _dirty => _loaded && _build() != _initial;
  bool get _canSave => _loaded && !_saving && _name.text.trim().isNotEmpty;

  void _onEdit() {
    if (_nameError != null && _name.text.trim().isNotEmpty) _nameError = null;
    if (_priceError != null) _priceError = null;
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [..._controllers, _dateText, _rindText, _styleText]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- actions ----

  Future<void> _close() async {
    if (!_dirty) {
      context.pop();
      return;
    }
    final discard = await showConfirmSheet(
      context,
      title: 'Discard this note?',
      aside: 'The cheese deserved better.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep writing',
    );
    if (discard && mounted) context.pop();
  }

  Future<void> _save() async {
    var ok = true;
    if (_name.text.trim().isEmpty) {
      _nameError = 'A cheese needs a name.';
      ok = false;
    }
    final price = _parsePrice();
    if (price != null && (price.isNaN || price < 0)) {
      _priceError = price.isNaN ? 'Numbers only.' : "Price can't be negative.";
      ok = false;
    }
    if (!ok) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    final note = _build();
    await ref.read(notesRepositoryProvider).save(note);
    if (!mounted) return;
    _initial = note; // no discard prompt on the way out
    if (widget.isEditing) {
      context.pop();
    } else {
      context.pushReplacement('/notes/${note.id}');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tastedAt,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      _tastedAt = TastingNote.dateOnly(picked);
      _dateText.text = formatTastingDate(_tastedAt);
    });
  }

  Future<void> _pickRind() async {
    final result = await showRindPicker(context, selected: _rind);
    if (result == null) return;
    _setRind(result.cleared ? null : result.value);
  }

  void _setRind(RindType? rind) => setState(() {
    _rind = rind;
    _rindText.text = rind?.label ?? '';
  });

  Future<void> _pickStyle() async {
    final styles = await ref.read(cheeseStylesProvider.future);
    if (!mounted) return;
    final result = await showStylePicker(
      context,
      styles: styles,
      selectedId: _cheeseStyleId,
    );
    if (result == null) return;
    _setStyle(result.cleared ? null : result.value);
  }

  void _setStyle(CheeseStyle? style) => setState(() {
    _cheeseStyleId = style?.id;
    _styleText.text = style?.name ?? '';
  });

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = widget.isEditing ? 'Edit tasting note' : 'New tasting note';
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            onPressed: _close,
            icon: HeroIcon(
              HeroIcons.xMark,
              size: 24,
              color: c.onSurfaceVariant,
            ),
          ),
          title: Text(title),
          actions: [
            TextButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _missing
            ? const EmptyState(
                icon: WedgeGlyph(size: 28),
                title: 'This note is gone',
                aside: 'Deleted elsewhere, presumably on purpose.',
              )
            : !_loaded
            ? const SizedBox.shrink()
            : _form(context),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        JournalField(
          label: 'Cheese name',
          hint: 'Start with what the label says',
          controller: _name,
          autofocus: !widget.isEditing,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          errorText: _nameError,
        ),
        _gap,
        JournalField(
          label: 'Creamery',
          controller: _creamery,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        _gap,
        JournalField(
          label: 'Origin',
          controller: _origin,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        _gap,
        JournalField(
          label: 'Date',
          readOnly: true,
          onTap: _pickDate,
          controller: _dateText,
        ),
        _gap,
        JournalField(
          label: 'Rind',
          hint: 'Natural, bloomy, washed…',
          readOnly: true,
          onTap: _pickRind,
          controller: _rindText,
          trailing: _rind == null
              ? null
              : _ClearButton(onTap: () => _setRind(null)),
        ),
        if (_rind == RindType.other) ...[
          _gap,
          JournalField(
            label: 'Rind (other)',
            hint: 'Describe it',
            controller: _rindOther,
            textInputAction: TextInputAction.next,
          ),
        ],
        _gap,
        JournalField(
          label: 'Price',
          hint: 'Optional',
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          errorText: _priceError,
          trailing: MonoLabel(_priceUnit.label),
        ),
        _gap,
        JournalField(
          label: 'Style',
          hint: 'Pick from the library',
          readOnly: true,
          onTap: _pickStyle,
          controller: _styleText,
          trailing: _cheeseStyleId == null
              ? null
              : _ClearButton(onTap: () => _setStyle(null)),
        ),
        _gap,
        JournalField(
          label: 'Verdict',
          hint: "One sentence you'd say out loud.",
          controller: _verdict,
          textInputAction: TextInputAction.next,
        ),
        _gap,
        _MilkCard(
          milk: _milk,
          onMilk: (m) => setState(() => _milk = m),
          milkOther: _milkOther,
          isGrassfed: _isGrassfed,
          isRaw: _isRaw,
          onGrassfed: (v) => setState(() => _isGrassfed = v),
          onRaw: (v) => setState(() => _isRaw = v),
          attributeOther: _attributeOther,
        ),
        _gap,
        _FormCard(
          label: 'Rating',
          child: StarRating(
            value: _rating,
            size: 30,
            gap: 6,
            showScore: true,
            onChanged: (v) => setState(() => _rating = v),
          ),
        ),
        _gap,
        _FormCard(
          label: 'Texture meter',
          child: _TextureMeter(
            value: _texture,
            onChanged: (t) => setState(() => _texture = t),
          ),
        ),
        _gap,
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: JournalField(
              label: 'Notes',
              hint: 'What did it taste like? Be honest.',
              controller: _notes,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
        ),
        _gap,
        FlavorEntryCard(
          values: _flavors,
          onChanged: (v) => setState(() => _flavors = v),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save to journal'),
        ),
      ],
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Clear',
    visualDensity: VisualDensity.compact,
    onPressed: onTap,
    icon: HeroIcon(
      HeroIcons.xMark,
      size: 18,
      color: context.scribe.textTertiary,
    ),
  );
}

/// Bordered card with a mono label and one child (rating, texture).
class _FormCard extends StatelessWidget {
  const _FormCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [MonoLabel(label), const SizedBox(height: 12), child],
      ),
    ),
  );
}

class _MilkCard extends StatelessWidget {
  const _MilkCard({
    required this.milk,
    required this.onMilk,
    required this.milkOther,
    required this.isGrassfed,
    required this.isRaw,
    required this.onGrassfed,
    required this.onRaw,
    required this.attributeOther,
  });

  final MilkType milk;
  final ValueChanged<MilkType> onMilk;
  final TextEditingController milkOther;
  final bool isGrassfed;
  final bool isRaw;
  final ValueChanged<bool> onGrassfed;
  final ValueChanged<bool> onRaw;
  final TextEditingController attributeOther;

  /// Order from the mockup: Buffalo · Cow · Goat · Sheep · Other.
  static const _milks = [
    MilkType.buffalo,
    MilkType.cow,
    MilkType.goat,
    MilkType.sheep,
    MilkType.other,
  ];

  @override
  Widget build(BuildContext context) {
    final showAttributeOther = attributeOther.text.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _AttributeRows(
          milk: milk,
          onMilk: onMilk,
          milkOther: milkOther,
          isGrassfed: isGrassfed,
          isRaw: isRaw,
          onGrassfed: onGrassfed,
          onRaw: onRaw,
          attributeOther: attributeOther,
          initiallyShowOther: showAttributeOther,
        ),
      ),
    );
  }
}

class _AttributeRows extends StatefulWidget {
  const _AttributeRows({
    required this.milk,
    required this.onMilk,
    required this.milkOther,
    required this.isGrassfed,
    required this.isRaw,
    required this.onGrassfed,
    required this.onRaw,
    required this.attributeOther,
    required this.initiallyShowOther,
  });

  final MilkType milk;
  final ValueChanged<MilkType> onMilk;
  final TextEditingController milkOther;
  final bool isGrassfed;
  final bool isRaw;
  final ValueChanged<bool> onGrassfed;
  final ValueChanged<bool> onRaw;
  final TextEditingController attributeOther;
  final bool initiallyShowOther;

  @override
  State<_AttributeRows> createState() => _AttributeRowsState();
}

class _AttributeRowsState extends State<_AttributeRows> {
  late bool _otherOpen = widget.initiallyShowOther;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoLabel('Milk'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _MilkCard._milks)
              FilterChip(
                label: Text(m.label),
                selected: widget.milk == m,
                onSelected: (_) => widget.onMilk(m),
              ),
          ],
        ),
        if (widget.milk == MilkType.other) ...[
          const SizedBox(height: 12),
          JournalField(
            label: 'Which milk?',
            hint: 'Yak, camel, a blend…',
            controller: widget.milkOther,
          ),
        ],
        const SizedBox(height: 14),
        CustomPaint(
          size: const Size(double.infinity, 1.5),
          painter: DottedUnderlinePainter(color: context.scribe.dottedLine),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Grassfed'),
              selected: widget.isGrassfed,
              onSelected: widget.onGrassfed,
            ),
            FilterChip(
              label: const Text('Raw'),
              selected: widget.isRaw,
              onSelected: widget.onRaw,
            ),
            FilterChip(
              label: const Text('Other'),
              selected: _otherOpen,
              onSelected: (v) {
                setState(() => _otherOpen = v);
                if (!v) widget.attributeOther.clear();
              },
            ),
          ],
        ),
        if (_otherOpen) ...[
          const SizedBox(height: 12),
          JournalField(
            label: 'Other attribute',
            hint: 'Cave-aged, organic, a story…',
            controller: widget.attributeOther,
          ),
        ],
      ],
    );
  }
}

/// Six-stop slider with mono labels; the active label is emphasised.
class _TextureMeter extends StatelessWidget {
  const _TextureMeter({required this.value, required this.onChanged});

  final TextureLevel value;
  final ValueChanged<TextureLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.index.toDouble(),
          min: 0,
          max: (TextureLevel.values.length - 1).toDouble(),
          divisions: TextureLevel.values.length - 1,
          label: value.label,
          onChanged: (v) => onChanged(TextureLevel.values[v.round()]),
        ),
        Row(
          children: [
            for (final t in TextureLevel.values)
              Expanded(
                child: MonoLabel(
                  t.label,
                  size: 8.5,
                  emphasis: t == value,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
