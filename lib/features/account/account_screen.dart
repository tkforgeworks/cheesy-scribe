import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';

/// `/account` (CHEESE-34): the local profile. No email, password, provider
/// rows, sign-out or delete-account until auth ships (CHEESE-11).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const defaultName = 'You';

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _name = TextEditingController();
  final _focus = FocusNode();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(settingsRepositoryProvider);
    final trimmed = _name.text.trim();
    final current = await repo.load();
    final next = trimmed.isEmpty ? null : trimmed;
    if (current.displayName == next) return;
    await repo.update((s) => s.copyWith(displayName: next));
  }

  /// First visit stamps "member since" so the meta line has a year even
  /// before the first note.
  void _stampMemberSince(AppSettings settings) {
    if (settings.memberSince != null) return;
    final today = TastingNote.dateOnly(DateTime.now());
    ref
        .read(settingsRepositoryProvider)
        .update(
          (s) => s.memberSince == null ? s.copyWith(memberSince: today) : s,
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final settingsAsync = ref.watch(appSettingsProvider);
    final settings = settingsAsync.asData?.value;
    if (settings != null && !_seeded) {
      _seeded = true;
      _name.text = settings.displayName ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _stampMemberSince(settings);
      });
    }
    final count = ref
        .watch(notesCountProvider(const NotesQuery()))
        .asData
        ?.value;
    final notes = ref.watch(allNotesProvider).asData?.value;
    final earliest = notes == null || notes.isEmpty
        ? null
        : notes.last.tastedAt;
    final sinceYear =
        (earliest ?? settings?.memberSince ?? DateTime.now()).year;
    final name = (settings?.displayName?.trim().isNotEmpty ?? false)
        ? settings!.displayName!.trim()
        : AccountScreen.defaultName;
    final initial = settings?.displayName?.trim().isNotEmpty ?? false
        ? name.characters.first.toUpperCase()
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: HeroIcon(
            HeroIcons.arrowLeft,
            size: 24,
            color: c.onSurfaceVariant,
          ),
        ),
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: initial != null
                  ? Text(
                      initial,
                      style: ScribeTheme.ui(
                        size: 26,
                        weight: FontWeight.w600,
                        color: c.onPrimaryContainer,
                      ),
                    )
                  : WedgeGlyph(size: 32, color: c.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: ScribeTheme.ui(
              size: 17,
              weight: FontWeight.w600,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          MonoLabel(
            'Member since $sinceYear · ${count ?? 0} ${count == 1 ? 'note' : 'notes'}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          BoxedField(
            label: 'Display name',
            hint: 'What should the drawer call you?',
            controller: _name,
            focusNode: _focus,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 10),
          Text(
            'Shows in the drawer and on the search bar. Saved when you leave the field.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 28),
          Text(
            'No account, no sign-in, no cloud. Your notes live on this phone; '
            'accounts arrive in a later version.',
            textAlign: TextAlign.center,
            style: ScribeTheme.serif(
              size: 13.5,
              italic: true,
              color: x.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
