import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/account/account_screen.dart';
import 'package:cheesy_scribe/features/account/backup_status_row.dart';
import 'package:cheesy_scribe/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';

import '../../support.dart';

const signedIn = ForgeAuthState(
  event: ForgeAuthEvent.initial,
  session: ForgeSession(userId: 'tim', email: 'tim@example.com'),
);

TastingNote note(String id) => TastingNote(
  id: id,
  cheeseName: id,
  tastedAt: DateTime(2026, 10, 1),
  createdAt: DateTime.utc(2026, 10, 1, 12),
);

void main() {
  test('relativeTime reads naturally', () {
    final now = DateTime.utc(2026, 10, 18, 12);
    expect(
      relativeTime(now.subtract(const Duration(seconds: 5)), now),
      'just now',
    );
    expect(
      relativeTime(now.subtract(const Duration(minutes: 1)), now),
      '1 minute ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(minutes: 4)), now),
      '4 minutes ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(hours: 3)), now),
      '3 hours ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(hours: 30)), now),
      'yesterday',
    );
    expect(relativeTime(DateTime.utc(2026, 8, 3), now), startsWith('on Aug'));
  });

  testApp('Settings: no backend shows the unavailable line', (tester) async {
    await pumpApp(tester, at: '/settings', backup: false);
    expect(find.text('BACKUP'), findsOneWidget);
    expect(find.text(AccountScreen.backupUnavailable), findsOneWidget);
    expect(find.byKey(SettingsScreen.signInRowKey), findsNothing);
  });

  testApp('Settings: signed out offers sign-in and goes to Account', (
    tester,
  ) async {
    await pumpApp(tester, at: '/settings');
    expect(find.text(SettingsScreen.signInTitle), findsOneWidget);
    expect(find.byKey(BackupStatusRow.rowKey), findsNothing);
    await tester.tap(find.byKey(SettingsScreen.signInRowKey));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
  });

  testApp('Settings: signed in shows the status, the account and Sync now', (
    tester,
  ) async {
    final auth = FakeForgeAuth(initial: signedIn);
    addTearDown(auth.dispose);
    final remote = FakeForgeEntriesRepository<TastingNote>(auth);
    final db = openTestDatabase();
    await onDb(
      tester,
      () => NotesRepository(db, owner: 'tim').save(note('n1')),
    );
    await pumpApp(tester, at: '/settings', db: db, auth: auth, remote: remote);
    // The first sync ran at start: the note is up.
    expect(remote.rows.keys, ['n1']);
    expect(find.text(BackupStatusRow.upToDate), findsOneWidget);
    expect(find.textContaining('Last synced'), findsOneWidget);
    expect(find.text('tim@example.com'), findsOneWidget);
    final before = remote.calls.length;
    await tester.tap(find.byKey(BackupStatusRow.syncNowKey));
    await tester.pumpAndSettle();
    expect(remote.calls.length, greaterThan(before));
    await tester.tap(find.byKey(SettingsScreen.accountRowKey));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    // Account carries the same row under BACKUP.
    expect(find.text('BACKUP'), findsOneWidget);
    expect(find.byKey(BackupStatusRow.rowKey), findsOneWidget);
  });

  testApp('offline and error states use plain copy, never the raw message', (
    tester,
  ) async {
    final auth = FakeForgeAuth(initial: signedIn);
    addTearDown(auth.dispose);
    final remote = FakeForgeEntriesRepository<TastingNote>(auth);
    remote.nextError = ForgeDataError.network;
    final db = openTestDatabase();
    await onDb(
      tester,
      () => NotesRepository(db, owner: 'tim').save(note('n1')),
    );
    await pumpApp(tester, at: '/settings', db: db, auth: auth, remote: remote);
    expect(find.text(BackupStatusRow.offline), findsOneWidget);
    expect(find.textContaining(BackupStatusRow.offlineHint), findsOneWidget);
    expect(find.textContaining(BackupStatusRow.pendingLine(1)), findsOneWidget);
    expect(find.textContaining('network'), findsNothing);

    remote.nextError = ForgeDataError.invalid;
    await tester.tap(find.byKey(BackupStatusRow.syncNowKey));
    await tester.pumpAndSettle();
    expect(find.text(BackupStatusRow.failed), findsOneWidget);
    expect(find.textContaining(BackupStatusRow.failedHint), findsOneWidget);
    expect(find.textContaining('invalid'), findsNothing);

    // A good run clears it.
    await tester.tap(find.byKey(BackupStatusRow.syncNowKey));
    await tester.pumpAndSettle();
    expect(find.text(BackupStatusRow.upToDate), findsOneWidget);
    expect(remote.rows.keys, ['n1']);
  });
}
