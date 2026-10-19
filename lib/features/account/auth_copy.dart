import 'package:forge_core/forge_core.dart';

/// What the Account page says for each way a sign-in call can fail
/// (CHEESE-61). forge_core reports the cause as a [ForgeAuthError]; the
/// server's own wording stays in logs. Tim owns the prose; edit in place.
String authErrorCopy(ForgeAuthError error) => switch (error) {
  ForgeAuthError.noGoogleAccount =>
    'There is no Google account on this phone to sign in with. '
        'Add one in Android settings, or use your email instead.',
  ForgeAuthError.googleUnavailable =>
    'Google sign-in could not open. Try again in a moment, '
        'or use your email instead.',
  ForgeAuthError.misconfigured =>
    'Sign-in is not set up for this build of the app.',
  ForgeAuthError.network =>
    'Could not reach the server. Check your connection.',
  ForgeAuthError.invalidCredentials =>
    'That email and password did not match. Try again, '
        'or use "Forgot password?".',
  ForgeAuthError.emailNotConfirmed =>
    'That account has not confirmed its email yet. '
        'Check your inbox for the confirmation link.',
  ForgeAuthError.emailTaken =>
    'That address already has an account. Sign in instead.',
  ForgeAuthError.weakPassword =>
    'That password is too easy to guess. Use at least 8 characters '
        'that are not on the common-passwords list.',
  ForgeAuthError.invalidEmail => 'That does not look like an email address.',
  ForgeAuthError.rateLimited =>
    'Too many attempts for now. Wait a minute and try again.',
  ForgeAuthError.linkExpired =>
    'That link has expired or was already used. Ask for a new one.',
  ForgeAuthError.samePassword =>
    'That is already your password. Pick a new one.',
  ForgeAuthError.sessionMissing =>
    'You are not signed in. Open the link from the email again.',
  ForgeAuthError.identityAlreadyLinked =>
    'That Google account already belongs to a different account.',
  ForgeAuthError.lastSignInMethod =>
    'That is the only way to sign in to this account, so it stays.',
  ForgeAuthError.unknown => 'Something went wrong. Try again.',
};

/// The same for the account and data calls (`ForgeResult` failures).
String dataErrorCopy(ForgeDataError error) => switch (error) {
  ForgeDataError.sessionMissing => 'You are signed out. Sign in and try again.',
  ForgeDataError.accountInactive =>
    'This account is being deleted, so it can no longer be changed.',
  ForgeDataError.invalid =>
    'That was not accepted. A username is at most 40 characters.',
  ForgeDataError.network =>
    'Could not reach the server. Check your connection.',
  ForgeDataError.unknown => 'Something went wrong. Try again.',
};

/// Shown at the bottom of the screen when a mail link has done its job
/// (CHEESE-68): forge_core verifies the token on arrival, and without a
/// word the user would just find themselves in the app.
const emailConfirmedMessage = "Email confirmed. You're signed in.";
const resetLinkVerifiedMessage = 'Reset link verified. Choose a new password.';
