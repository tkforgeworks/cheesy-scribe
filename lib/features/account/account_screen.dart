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
import '../../data/sync/sync_providers.dart';
import '../../data/sync/sync_status.dart';
import 'add_password_screen.dart';
import 'auth_copy.dart';
import 'backup_status_row.dart';
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

  /// The row offering to attach notes made while signed out (CHEESE-62).
  static const unownedRowKey = Key('account-unowned-notes');
  static const attachKey = Key('account-attach-unowned');

  static String attachTitle(int n) =>
      'Add your $n ${n == 1 ? 'note' : 'notes'} to this account?';
  static const attachAside =
      'They were written while signed out. Adding them backs them up with '
      'everything else; leaving them out keeps them on this phone, out of '
      'sight until you sign out.';
  static const attachLabel = 'Add them';
  static const notNowLabel = 'Not now';

  static String unownedRowTitle(int n) =>
      '$n ${n == 1 ? 'note' : 'notes'} from when you were signed out';
  static const unownedRowSubtitle = 'Add them to this account to back them up.';

  static String unsyncedTitle(int n) =>
      '$n ${n == 1 ? "change hasn't" : "changes haven't"} been backed up yet';
  static const unsyncedAside =
      "Signing out removes this account's notes from the phone; anything "
      'not backed up would be lost. Try again with a connection, or sign '
      'out anyway.';
  static const signOutAnywayLabel = 'Sign out anyway';
  static const signOutAside =
      "This account's notes leave the phone; the account keeps them. "
      'Notes made while signed out stay.';

  /// Delete account (CHEESE-65): typed-DELETE confirm, then forge_core's
  /// `deleteAccount()`, which flags the account for the purge and signs out
  /// everywhere. The server removes everything within minutes (the privacy
  /// policy says the same); this phone forgets the account's notes like a
  /// sign-out does, and notes made while signed out stay.
  static const deleteTitle = 'Delete your account?';
  static const deleteAside =
      'Everything in the account is removed within minutes: your notes, '
      'your username and your sign-in. This phone forgets the account\'s '
      'notes as well; notes made while signed out stay here.';
  static const deletedMessage =
      'Your account is being deleted. You are signed out.';

  /// Under DISPLAY NAME (CHEESE-64): the two names are different things.
  static const displayNameHint =
      'Shows in the drawer and on the search bar. Saved when you leave the '
      'field.';
  static const displayNameSignedInHint =
      ' Lives on this phone; your account\'s username is below.';
  static const usernameSavedMessage = 'Username saved.';

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

  /// Sign-out under the ownership model (CHEESE-62): push what is still
  /// dirty, warn if that failed, end the session, then forget the
  /// account's notes on this phone (the server keeps them). Notes made
  /// while signed out are untouched and become the notebook again.
  Future<void> _signOut({required bool eraseLocal}) async {
    final auth = ref.read(forgeAuthProvider);
    final userId = ref.read(sessionProvider)?.userId;
    if (auth == null || userId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final notes = ref.read(notesRepositoryProvider);
    final meta = ref.read(syncMetaRepositoryProvider);
    final coordinator = ref.read(syncCoordinatorProvider);
    if (coordinator != null) {
      final status = await coordinator.syncNow();
      if (!mounted) return;
      // Only what would be lost counts: dirty notes and unpushed
      // deletions. A failed sync with nothing pending has nothing to warn
      // about.
      final unsynced = status.phase == SyncPhase.idle
          ? 0
          : status.pending + (await notes.tombstones()).length;
      if (!mounted) return;
      if (unsynced > 0) {
        final anyway = await showForgeConfirmSheet(
          context,
          title: AccountScreen.unsyncedTitle(unsynced),
          aside: AccountScreen.unsyncedAside,
          confirmLabel: AccountScreen.signOutAnywayLabel,
        );
        if (!anyway) {
          if (mounted) setState(() => _busy = false);
          return;
        }
      }
    }
    await auth.signOut();
    await notes.removeOwned(userId);
    await meta.clear();
    if (mounted) setState(() => _busy = false);
  }

  /// Right after a sign-in, offer the notes made while signed out
  /// (CHEESE-62). Declining keeps them on the phone, hidden until sign-out;
  /// the Account row re-offers them meanwhile.
  Future<void> _offerAttach(String userId) async {
    final notes = ref.read(notesRepositoryProvider);
    final count = await notes.unownedCount();
    if (count == 0 || !mounted) return;
    final yes = await showForgeConfirmSheet(
      context,
      title: AccountScreen.attachTitle(count),
      aside: AccountScreen.attachAside,
      confirmLabel: AccountScreen.attachLabel,
      cancelLabel: AccountScreen.notNowLabel,
      destructive: false,
    );
    if (yes && mounted) await notes.attachUnownedTo(userId);
  }

  Future<void> _attachNow() async {
    final userId = ref.read(sessionProvider)?.userId;
    if (userId == null) return;
    await ref.read(notesRepositoryProvider).attachUnownedTo(userId);
  }

  // --- Signed-in account management (CHEESE-64) --------------------------

  Future<void> _saveUsername(String? value) async {
    final accounts = ref.read(forgeAccountsProvider);
    if (accounts == null) return;
    setState(() => _error = null);
    final result = await accounts.setUsername(value);
    if (!mounted) return;
    switch (result) {
      case ForgeOk():
        ref.invalidate(accountProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AccountScreen.usernameSavedMessage)),
        );
      case ForgeFailed(:final error):
        setState(() => _error = dataErrorCopy(error));
    }
  }

  /// Runs inside forge_ui's typed confirmation sheet: null closes it,
  /// a message keeps it open.
  Future<String?> _deleteAccount() async {
    final accounts = ref.read(forgeAccountsProvider);
    final userId = ref.read(sessionProvider)?.userId;
    if (accounts == null || userId == null) return null;
    final notes = ref.read(notesRepositoryProvider);
    final meta = ref.read(syncMetaRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final result = await accounts.deleteAccount();
    switch (result) {
      case ForgeFailed(:final error):
        return dataErrorCopy(error);
      case ForgeOk():
        await notes.removeOwned(userId);
        await meta.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text(AccountScreen.deletedMessage)),
        );
        return null;
    }
  }

  void _link(ForgeSignInProvider provider) {
    if (provider != ForgeSignInProvider.google) return;
    _run((auth) => auth.linkGoogle());
  }

  void _setPassword() => context.push(AddPasswordScreen.path);

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      final state = next.asData?.value;
      if (state?.event == ForgeAuthEvent.signedIn && state?.session != null) {
        _offerAttach(state!.session!.userId);
      }
    });
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
            AccountScreen.displayNameHint +
                (authState?.isSignedIn ?? false
                    ? AccountScreen.displayNameSignedInHint
                    : ''),
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
    final unowned = ref.watch(unownedNotesCountProvider).asData?.value ?? 0;
    final account = ref.watch(accountProvider).asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ForgeAccountSettings(
          email: session.email ?? 'Signed in',
          username: account?.username,
          onUsernameChanged: _saveUsername,
          linked: [
            for (final identity in session.identities)
              if (_providerOf(identity) case final provider?)
                ForgeLinkedSignIn(provider: provider, email: identity.email),
          ],
          onLink: _link,
          onSetPassword: _setPassword,
          busy: _busy,
          errorText: _error,
          status: const BackupStatusRow(),
          statusLabel: 'Backup',
          offerLocalErase: false,
          signOutAside: AccountScreen.signOutAside,
          onSignOut: _signOut,
          onDeleteAccount: _deleteAccount,
          deleteTitle: AccountScreen.deleteTitle,
          deleteAside: AccountScreen.deleteAside,
        ),
        if (unowned > 0) ...[
          const SizedBox(height: 20),
          ForgeSettingsGroup(
            label: 'Signed-out notes',
            children: [
              ListTile(
                key: AccountScreen.unownedRowKey,
                leading: HeroIcon(
                  HeroIcons.documentPlus,
                  color: context.forge.textTertiary,
                ),
                title: Text(AccountScreen.unownedRowTitle(unowned)),
                subtitle: const Text(AccountScreen.unownedRowSubtitle),
                trailing: TextButton(
                  key: AccountScreen.attachKey,
                  onPressed: _busy ? null : _attachNow,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ],
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
