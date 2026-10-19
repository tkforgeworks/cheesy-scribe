import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/forge_providers.dart';
import '../data/providers.dart';
import '../data/sync/sync_providers.dart';
import '../data/sync/sync_status.dart';

/// Set by the Account page right before a sign-out or deletion the user
/// asked for, so [SessionGuard] knows the session ending was intended and
/// says nothing. Read once and cleared.
class SignOutIntent extends Notifier<bool> {
  @override
  bool build() => false;

  void mark() => state = true;

  bool take() {
    final marked = state;
    state = false;
    return marked;
  }
}

final signOutIntentProvider = NotifierProvider<SignOutIntent, bool>(
  SignOutIntent.new,
);

/// Ends this phone's session when the account did not end it here
/// (CHEESE-65): the sync reports the account flagged or purged (deleted
/// from the website or another phone), or the auth stream signs out on
/// its own (the session could not be refreshed because the user is gone).
/// Either way the account's notes leave the phone, as a sign-out does, and
/// a snackbar says why. Lives in `ScribeApp`, which calls [watch] from
/// its build.
class SessionGuard {
  SessionGuard(this.ref, this.messenger);

  final WidgetRef ref;
  final GlobalKey<ScaffoldMessengerState> messenger;

  static const accountDeleted =
      'This account was deleted, so this phone has been signed out. Notes '
      'made while signed out are still here.';
  static const sessionEnded =
      'Your session ended, so this phone has been signed out. Sign in again '
      "to see your account's notes.";

  String? _userId;
  bool _ending = false;

  /// Registers both listeners; call from a build.
  void watch() {
    ref.listen(authStateProvider, (_, next) {
      final state = next.asData?.value;
      if (state == null) return;
      final session = state.session;
      if (session != null) {
        _userId = session.userId;
        return;
      }
      final left = _userId;
      _userId = null;
      if (left == null) return;
      final intended = ref.read(signOutIntentProvider.notifier).take();
      _cleanUp(left, intended ? null : sessionEnded);
    });
    ref.listen(syncStatusProvider, (_, next) {
      if (next.asData?.value.phase != SyncPhase.accountGone) return;
      final userId = ref.read(sessionProvider)?.userId;
      if (userId == null || _ending) return;
      _ending = true;
      ref.read(signOutIntentProvider.notifier).mark();
      final auth = ref.read(forgeAuthProvider);
      Future<void>(() async {
        await auth?.signOut();
        await _cleanUp(userId, accountDeleted);
        _ending = false;
      });
    });
  }

  Future<void> _cleanUp(String userId, String? message) async {
    await ref.read(notesRepositoryProvider).removeOwned(userId);
    await ref.read(syncMetaRepositoryProvider).clear();
    if (message != null) {
      messenger.currentState?.showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
      );
    }
  }
}
