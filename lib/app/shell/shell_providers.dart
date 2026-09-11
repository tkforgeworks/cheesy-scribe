import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// `X.Y.Z` from the installed package, for the drawer footer and About.
/// Tests seed it with `PackageInfo.setMockInitialValues`.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Local display name for the drawer account row and search-bar avatar.
/// Null until the settings repository (CHEESE-21) and the Account screen
/// (CHEESE-34) wire it up; the shell shows a neutral fallback meanwhile.
final displayNameProvider = Provider<String?>((ref) => null);
