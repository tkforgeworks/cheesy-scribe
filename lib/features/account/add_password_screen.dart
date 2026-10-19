import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../data/forge_providers.dart';
import 'auth_copy.dart';

/// `/account/add-password` (CHEESE-64): "Set a password" on an account
/// that only has Google, pushed from the Account page. The same forge_ui
/// form as the reset flow, but the session is a normal one, so leaving
/// without saving changes nothing.
class AddPasswordScreen extends ConsumerStatefulWidget {
  const AddPasswordScreen({super.key});

  static const path = '/account/add-password';
  static const title = 'Set a password';
  static const heading = 'Add a password to your account';
  static const blurb =
      'Sign in with your email and this password too, in case Google is '
      'ever not an option. At least 8 characters.';
  static const savedMessage = 'Password set. Email sign-in is on.';

  @override
  ConsumerState<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends ConsumerState<AddPasswordScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _submit(String password) async {
    final auth = ref.read(forgeAuthProvider);
    if (auth == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await auth.setPassword(password);
    if (!mounted) return;
    switch (result) {
      case ForgeAuthSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AddPasswordScreen.savedMessage)),
        );
        context.pop();
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
  Widget build(BuildContext context) => ForgeSetPasswordScreen(
    title: AddPasswordScreen.title,
    heading: AddPasswordScreen.heading,
    blurb: AddPasswordScreen.blurb,
    busy: _busy,
    errorText: _error,
    onSubmit: _submit,
  );
}
