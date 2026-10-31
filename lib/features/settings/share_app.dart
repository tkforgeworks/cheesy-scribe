import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// The app's page on tkforgeworks.com (CHEESE-71). It sends each visitor to
/// the right store, so the app itself never carries a store URL.
const shareAppUrl = 'https://tkforgeworks.com/apps/cheesy-scribe/';

/// What the share sheet carries. Tim owns the copy.
const shareAppMessage =
    'I keep my cheese tasting notes in Cheesy Scribe. Try it: $shareAppUrl';

typedef ShareText = Future<void> Function(String text, {String? subject});

/// Opens the platform share sheet. Tests replace it (see `pumpApp`).
final shareAppProvider = Provider<ShareText>(
  (ref) =>
      (text, {subject}) =>
          SharePlus.instance.share(ShareParams(text: text, subject: subject)),
);
