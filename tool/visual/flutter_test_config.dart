import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads every font in the app's font manifest, so the renders show real
/// type instead of flutter_test's boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  await testMain();
}
