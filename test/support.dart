import 'package:cheesy_scribe/app/theme/scribe_theme.dart';
import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/providers.dart';
import 'package:cheesy_scribe/data/repositories/library_repository.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:cheesy_scribe/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Wraps [child] in a themed MaterialApp + Scaffold for atom tests.
Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: ScribeTheme.light(),
  darkTheme: ScribeTheme.dark(),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(body: Center(child: child)),
);

/// A fresh in-memory database, closed when the test ends.
AppDatabase openTestDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// Boots the real app on an in-memory database with mocked package info.
/// [settings] is saved before the first frame. The bundled cheese library
/// is pre-loaded on the real event loop (asset I/O never completes on the
/// fake clock) so style pickers and counts resolve under `pumpAndSettle`.
/// Returns the database so tests can seed or inspect it.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  String at = '/notes',
  AppDatabase? db,
  AppSettings? settings,
}) async {
  final database = db ?? openTestDatabase();
  final library = LibraryRepository();
  await tester.runAsync(() async {
    if (settings != null) await SettingsRepository(database).save(settings);
    await library.load();
  });
  PackageInfo.setMockInitialValues(
    appName: 'Cheesy Scribe',
    packageName: 'com.tkforgeworks.cheesy_scribe',
    version: '0.1.0',
    buildNumber: '1',
    buildSignature: '',
  );
  // Fresh keys so a second pumpApp in the same test is a real restart
  // (otherwise the old State, and its router, would be reused).
  final restart = UniqueKey();
  await tester.pumpWidget(
    ProviderScope(
      key: restart,
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        libraryRepositoryProvider.overrideWithValue(library),
      ],
      child: ScribeApp(key: ValueKey(restart), initialLocation: at),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

/// `testWidgets` for tests that call [pumpApp]. Drift schedules a
/// zero-length timer when its query streams are cancelled, which happens
/// when the tree is torn down; flutter_test then fails on "pending timers"
/// and `db.close()` waits forever on the fake clock. Unmounting the app
/// and pumping once inside the test flushes it first.
void testApp(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      // A zero-length timer only fires when the fake clock advances.
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}

/// Runs a database call from inside a widget test. Drift's futures and
/// stream cancellations must not run on flutter_test's fake clock: a
/// stream read with `.first` on the fake zone leaves `db.close()` waiting
/// forever at teardown. `runAsync` executes [op] on the real event loop.
Future<T> onDb<T>(WidgetTester tester, Future<T> Function() op) async =>
    (await tester.runAsync(op)) as T;
