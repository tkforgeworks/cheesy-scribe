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
class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  static const path = '/auth/set-password';
  static const savedMessage = 'Password saved. You are signed in.';

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  bool _busy = false;
  String? _error;

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
  Widget build(BuildContext context) =>
      ForgeSetPasswordScreen(busy: _busy, errorText: _error, onSubmit: _submit);
}
