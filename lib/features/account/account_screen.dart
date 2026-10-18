import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/widgets/widgets.dart';
import '../../data/forge_providers.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/notes_repository.dart';
import 'auth_copy.dart';
import 'check_email_screen.dart';

/// `/account`: the local profile (CHEESE-34) with, beneath it, the optional
/// account (CHEESE-61). Signed out, forge_ui's sign-in panel offers Google
/// and email/password; signed in, `ForgeAccountSettings` shows the account
/// and its sign-in methods with Sign out. The display name stays local
/// either way (the drawer and search bar read it from settings). A build
/// with no backend configuration says so instead of offering sign-in.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const defaultName = 'You';

  /// The line shown in place of the sign-in panel when the build has no
  /// Supabase configuration (CI, `flutter run` without `config/dev.json`).
  static const backupUnavailable =
      'Backup isn\'t available in this build. Your notes live on this phone.';

  static const signInHeading = 'Back up your notes';
  static const signInBlurb =
      'Optional. Sign in and your tastings get a copy in the cloud, ready '
      'for a new phone. Nothing changes if you never do.';

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _name = TextEditingController();
  final _focus = FocusNode();
  bool _seeded = false;

  /// A sign-in call is in flight; the panel disables itself meanwhile.
  bool _busy = false;

  /// The last attempt's failure, in the app's words; cleared on the next.
  String? _error;

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

  /// Runs one auth call with the busy flag and routes its result: success
  /// and cancellation need nothing (the session stream re-renders the
  /// page), a sent mail opens the check-email screen, a failure shows its
  /// copy. Signing in to an unconfirmed account also goes to check-email,
  /// since the confirmation link is the only way forward.
  Future<void> _run(
    Future<ForgeAuthResult> Function(ForgeAuth auth) call, {
    String? email,
  }) async {
    final auth = ref.read(forgeAuthProvider);
    if (auth == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await call(auth);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case ForgeAuthSuccess() || ForgeAuthCancelled():
        break;
      case ForgeAuthEmailSent(:final email, :final purpose):
        _openCheckEmail(
          email,
          purpose == ForgeMailPurpose.confirmation
              ? ForgeEmailPurpose.confirm
              : ForgeEmailPurpose.reset,
        );
      case ForgeAuthFailure(:final error):
        if (error == ForgeAuthError.emailNotConfirmed && email != null) {
          _openCheckEmail(email, ForgeEmailPurpose.confirm);
        } else {
          setState(() => _error = authErrorCopy(error));
        }
    }
  }

  void _openCheckEmail(String email, ForgeEmailPurpose purpose) =>
      context.push(CheckEmailScreen.location(email, purpose));

  Future<void> _signOut({required bool eraseLocal}) async {
    // CHEESE-65 adds the erase option and the sync-state reset; until then
    // signing out only ends the session and the notes stay as they are.
    final auth = ref.read(forgeAuthProvider);
    if (auth == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await auth.signOut();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
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
    final backup = ref.watch(backupAvailableProvider);
    final authState = ref.watch(authStateProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open menu',
          onPressed: () => ScribeShell.openDrawer(context),
          icon: HeroIcon(HeroIcons.bars3, size: 24, color: c.onSurfaceVariant),
        ),
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32,
        ).withNavBarInset(context),
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
                      style: ForgeType.ui(
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
            style: ForgeType.ui(
              size: 17,
              weight: FontWeight.w600,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ForgeMonoLabel(
            'Member since $sinceYear · ${count ?? 0} ${count == 1 ? 'note' : 'notes'}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ForgeBoxedField(
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
          if (!backup)
            Text(
              AccountScreen.backupUnavailable,
              textAlign: TextAlign.center,
              style: ForgeType.serif(
                size: 13.5,
                italic: true,
                color: x.textTertiary,
              ),
            )
          else if (authState != null)
            _account(authState),
        ],
      ),
    );
  }

  /// Signed in: the account body. Signed out: the sign-in panel. Username,
  /// linking, set-password, backup status and deletion arrive with
  /// CHEESE-63 to 65, so their slots are left null here.
  Widget _account(ForgeAuthState state) {
    final session = state.session;
    if (session == null) {
      return ForgeSignInPanel(
        heading: AccountScreen.signInHeading,
        blurb: AccountScreen.signInBlurb,
        busy: _busy,
        errorText: _error,
        onGoogle: () => _run((auth) => auth.signInWithGoogle()),
        onEmailSignIn: (email, password) =>
            _run((auth) => auth.signInWithEmail(email, password), email: email),
        onEmailCreate: (email, password) =>
            _run((auth) => auth.signUpWithEmail(email, password), email: email),
        onForgotPassword: (email) =>
            _run((auth) => auth.sendPasswordReset(email), email: email),
      );
    }
    return ForgeAccountSettings(
      email: session.email ?? 'Signed in',
      linked: [
        for (final identity in session.identities)
          if (_providerOf(identity) case final provider?)
            ForgeLinkedSignIn(provider: provider, email: identity.email),
      ],
      busy: _busy,
      errorText: _error,
      offerLocalErase: false,
      signOutAside: 'Your notes stay on this phone.',
      onSignOut: _signOut,
    );
  }

  static ForgeSignInProvider? _providerOf(ForgeIdentity identity) =>
      switch (identity.provider) {
        ForgeIdentityProvider.google => ForgeSignInProvider.google,
        ForgeIdentityProvider.email => ForgeSignInProvider.email,
        ForgeIdentityProvider.apple => ForgeSignInProvider.apple,
        ForgeIdentityProvider.other => null,
      };
}
