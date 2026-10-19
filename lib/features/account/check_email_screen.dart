import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../data/forge_providers.dart';
import 'auth_copy.dart';

/// `/account/check-email?email=…&purpose=confirm|reset` (CHEESE-61): the
/// waiting state after a sign-up or a reset request, over the Account
/// page. "Send again" repeats the mail; when the confirmation link is
/// opened on this phone the session arrives and the screen pops itself,
/// leaving Account signed in. A reset link's `passwordRecovery` state is
/// handled by `ScribeApp`, which swaps this screen for set-password.
class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key, required this.email, this.purpose});

  static const path = '/account/check-email';

  /// The route for [email] and [purpose].
  static String location(String email, ForgeEmailPurpose purpose) => Uri(
    path: path,
    queryParameters: {'email': email, 'purpose': purpose.name},
  ).toString();

  /// Parses the `purpose` query value; unknown or missing reads as confirm.
  static ForgeEmailPurpose purposeOf(String? name) =>
      ForgeEmailPurpose.values.asNameMap()[name] ?? ForgeEmailPurpose.confirm;

  final String email;
  final ForgeEmailPurpose? purpose;

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> {
  bool _busy = false;
  String? _error;

  ForgeEmailPurpose get _purpose => widget.purpose ?? ForgeEmailPurpose.confirm;

  Future<void> _resend() async {
    final auth = ref.read(forgeAuthProvider);
    if (auth == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = switch (_purpose) {
      ForgeEmailPurpose.confirm => await auth.resendConfirmation(widget.email),
      ForgeEmailPurpose.reset => await auth.sendPasswordReset(widget.email),
    };
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case ForgeAuthFailure(:final error)) {
        _error = authErrorCopy(error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      if (next.asData?.value.event == ForgeAuthEvent.signedIn &&
          context.canPop()) {
        context.pop();
      }
    });
    return ForgeCheckEmailScreen(
      email: widget.email,
      purpose: _purpose,
      busy: _busy,
      errorText: _error,
      onResend: _resend,
      onChangeEmail: () => context.pop(),
      onDone: () => context.pop(),
    );
  }
}
