import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/providers.dart';

/// `X.Y.Z` from the installed package, for the drawer footer and About.
/// Tests seed it with `PackageInfo.setMockInitialValues`.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Local display name for the drawer account row and search-bar avatar;
/// null (or blank) until set on the Account screen (CHEESE-34).
final displayNameProvider = Provider<String?>((ref) {
  final name = ref.watch(appSettingsProvider).asData?.value.displayName?.trim();
  return name == null || name.isEmpty ? null : name;
});
