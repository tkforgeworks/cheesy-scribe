import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../data/forge_providers.dart';
import 'auth_copy.dart';

/// `/auth/set-password` (CHEESE-61): pushed by `ScribeApp` when the app
/// opens from a password-reset link (the auth state reports
/// `passwordRecovery`). Saving the new password keeps the user signed in
/// and pops back to wherever they were.
///
/// The reset link is itself a sign-in: Supabase opens a session the moment
/// it is verified, so someone who backs out of this screen would be left
/// signed in without ever typing a password (seen on rc.3). Leaving
/// without saving therefore signs that recovery session out again; the
/// blurb says so.
class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  static const path = '/auth/set-password';
  static const savedMessage = 'Password saved. You are signed in.';
  static const blurb =
      'At least 8 characters. Save it to finish signing in; leaving this '
      'screen without saving signs you out again.';
  static const leftMessage = 'No new password saved. You are signed out.';

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  bool _busy = false;
  String? _error;

  /// Set once the new password is stored, so popping after success does
  /// not sign out.
  bool _saved = false;

  /// Back (system or app bar) without a saved password: end the recovery
  /// session so the link alone never leaves the user signed in.
  void _onLeave(bool didPop, Object? _) {
    if (!didPop || _saved) return;
    final auth = ref.read(forgeAuthProvider);
    if (auth == null || !auth.current.isSignedIn) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    auth.signOut().then((_) {
      messenger?.showSnackBar(
        const SnackBar(content: Text(SetPasswordScreen.leftMessage)),
      );
    });
  }

  Future<void> _submit(String password) async {
    final auth = ref.read(forgeAuthProvider);
    if (auth == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await auth.updatePassword(password);
    if (!mounted) return;
    switch (result) {
      case ForgeAuthSuccess():
        _saved = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SetPasswordScreen.savedMessage)),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/account');
        }
      case ForgeAuthFailure(:final error):
        setState(() {
          _busy = false;
          _error = authErrorCopy(error);
        });
      case ForgeAuthEmailSent() || ForgeAuthCancelled():
        setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    // No leaving mid-save: the outcome decides whether to sign out.
    canPop: !_busy,
    onPopInvokedWithResult: _onLeave,
    child: ForgeSetPasswordScreen(
      blurb: SetPasswordScreen.blurb,
      busy: _busy,
      errorText: _error,
      onSubmit: _submit,
    ),
  );
}
