import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/app/session_guard.dart';
import 'package:cheesy_scribe/features/account/account_screen.dart';
import 'package:cheesy_scribe/features/account/auth_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../support.dart';

TastingNote note(String id, String name) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: DateTime(2026, 10, 1),
  createdAt: DateTime.utc(2026, 10, 1, 12),
);

/// The account the fake signs in.
const owner = 'fake-user';

/// The ownership model end to end (CHEESE-62): the Account page's attach
/// offer, the signed-out-notes row, sign-out removing the account's notes,
/// and the coordinator's triggers, all against the fake server.
void main() {
  late FakeForgeAuth auth;
  late FakeForgeEntriesRepository<TastingNote> remote;

  setUp(() {
    auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    remote = FakeForgeEntriesRepository<TastingNote>(auth);
  });

  late FakeForgeAccounts accounts;

  Future<AppDatabase> boot(
    WidgetTester tester, {
    required int anonNotes,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      final anon = NotesRepository(db);
      for (var i = 1; i <= anonNotes; i++) {
        await anon.save(note('a$i', 'Anon $i'));
      }
    });
    accounts = FakeForgeAccounts(auth);
    await pumpApp(
      tester,
      at: '/account',
      db: db,
      auth: auth,
      accounts: accounts,
      remote: remote,
    );
    return db;
  }

  Future<void> signInWithGoogle(WidgetTester tester) async {
    await tester.tap(find.byType(ForgeSignInButton));
    await tester.pumpAndSettle();
  }

  /// Lets the save debounce (3 s) elapse and the sync finish.
  Future<void> settleSync(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testApp('signing in offers the signed-out notes; adding them uploads them', (
    tester,
  ) async {
    await boot(tester, anonNotes: 3);
    expect(find.text('MEMBER SINCE 2026 · 3 NOTES'), findsOneWidget);
    await signInWithGoogle(tester);
    expect(find.text(AccountScreen.attachTitle(3)), findsOneWidget);
    expect(find.text(AccountScreen.attachAside), findsOneWidget);
    await tester.tap(find.text(AccountScreen.attachLabel));
    await tester.pumpAndSettle();
    expect(find.byKey(AccountScreen.unownedRowKey), findsNothing);
    // The notes are the account's now, and the engine pushes them.
    expect(find.text('MEMBER SINCE 2026 · 3 NOTES'), findsOneWidget);
    await settleSync(tester);
    expect(remote.rows.keys, unorderedEquals(['a1', 'a2', 'a3']));
    expect(remote.rows['a1']!.data!.cheeseName, 'Anon 1');
  });

  testApp('Not now hides them while signed in; the Account row re-offers', (
    tester,
  ) async {
    await boot(tester, anonNotes: 2);
    await signInWithGoogle(tester);
    await tester.tap(find.text(AccountScreen.notNowLabel));
    await tester.pumpAndSettle();
    // Hidden: the account's notebook is empty; the row says where they are.
    expect(find.text('MEMBER SINCE 2026 · 0 NOTES'), findsOneWidget);
    expect(find.text(AccountScreen.unownedRowTitle(2)), findsOneWidget);
    expect(remote.rows, isEmpty);
    await tester.tap(find.byKey(AccountScreen.attachKey));
    await tester.pumpAndSettle();
    expect(find.byKey(AccountScreen.unownedRowKey), findsNothing);
    expect(find.text('MEMBER SINCE 2026 · 2 NOTES'), findsOneWidget);
    await settleSync(tester);
    expect(remote.rows.keys, unorderedEquals(['a1', 'a2']));
  });

  testApp(
    "signing out removes the account's notes and restores the signed-out ones",
    (tester) async {
      await boot(tester, anonNotes: 1);
      await signInWithGoogle(tester);
      await tester.tap(find.text(AccountScreen.notNowLabel));
      await tester.pumpAndSettle();
      // The account gets a note of its own, synced down from "another
      // phone" when the app comes back to the foreground.
      remote.remoteUpsert([
        ForgeEntry<TastingNote>(
          id: 'r1',
          data: note('r1', 'From the account'),
          updatedAt: DateTime.utc(2026, 10, 18, 12),
        ),
      ]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('MEMBER SINCE 2026 · 1 NOTE'), findsOneWidget);

      await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
      await tester.pumpAndSettle();
      expect(find.text(AccountScreen.signOutAside), findsOneWidget);
      await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
      await tester.pumpAndSettle();
      expect(auth.signOutCalls, [false]);
      // Signed out: the account's note is gone from the phone, the
      // signed-out note is the notebook again, the server keeps its copy.
      // The user asked for this, so the session guard says nothing.
      expect(find.text(SessionGuard.sessionEnded), findsNothing);
      expect(find.byType(ForgeSignInPanel), findsOneWidget);
      expect(find.text('MEMBER SINCE 2026 · 1 NOTE'), findsOneWidget);
      expect(remote.rows.keys, ['r1']);
      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My tasting notes'));
      await tester.pumpAndSettle();
      expect(find.text('Anon 1'), findsOneWidget);
      expect(find.text('From the account'), findsNothing);
    },
  );

  testApp('signing out with notes not yet backed up warns first', (
    tester,
  ) async {
    final db = await boot(tester, anonNotes: 0);
    await signInWithGoogle(tester);
    // A note the engine cannot deliver: the debounce fires into an outage.
    remote.nextError = ForgeDataError.network;
    await onDb(
      tester,
      () => NotesRepository(db, owner: owner).save(note('o1', 'Owned')),
    );
    await settleSync(tester);
    expect(remote.rows, isEmpty);

    remote.nextError = ForgeDataError.network; // still down at sign-out
    await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(find.text(AccountScreen.unsyncedTitle(1)), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, isEmpty);
    expect(find.byType(ForgeAccountSettings), findsOneWidget);

    // Back online: signing out pushes first and needs no warning.
    await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(find.text(AccountScreen.unsyncedTitle(1)), findsNothing);
    expect(auth.signOutCalls, [false]);
    expect(remote.rows.keys, ['o1']);
    expect(
      await onDb(
        tester,
        () => NotesRepository(db, owner: owner).watchAll().first,
      ),
      isEmpty,
    );
  });

  testApp('edits sync after a short pause; a failure retries with backoff', (
    tester,
  ) async {
    final db = await boot(tester, anonNotes: 0);
    await signInWithGoogle(tester);
    final mine = NotesRepository(db, owner: owner);
    await onDb(tester, () => mine.save(note('o1', 'First')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(remote.rows, isEmpty); // still inside the debounce
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(remote.rows.keys, ['o1']);

    remote.nextError = ForgeDataError.network;
    await onDb(tester, () => mine.save(note('o2', 'Second')));
    await settleSync(tester);
    expect(remote.rows.keys, ['o1']); // the attempt failed
    await tester.pump(const Duration(seconds: 29));
    await tester.pumpAndSettle();
    expect(remote.rows.keys, ['o1']);
    await tester.pump(const Duration(seconds: 1)); // the 30 s retry
    await tester.pumpAndSettle();
    expect(remote.rows.keys, unorderedEquals(['o1', 'o2']));
  });

  testApp('deleting the account needs DELETE typed, then forgets its notes', (
    tester,
  ) async {
    final db = await boot(tester, anonNotes: 1);
    await signInWithGoogle(tester);
    await tester.tap(find.text(AccountScreen.notNowLabel));
    await tester.pumpAndSettle();
    await onDb(
      tester,
      () => NotesRepository(db, owner: owner).save(note('o1', 'Owned')),
    );
    await settleSync(tester);
    expect(remote.rows.keys, ['o1']);

    await tester.ensureVisible(find.byKey(ForgeAccountSettings.deleteKey));
    await tester.tap(find.byKey(ForgeAccountSettings.deleteKey));
    await tester.pumpAndSettle();
    expect(find.text(AccountScreen.deleteTitle), findsOneWidget);
    expect(find.text(AccountScreen.deleteAside), findsOneWidget);
    // The confirm button stays off until the word is typed.
    final confirm = find.widgetWithText(FilledButton, 'Delete account');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'delete');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, [true]);
    expect(find.text(AccountScreen.deletedMessage), findsOneWidget);
    expect(find.byType(ForgeSignInPanel), findsOneWidget);
    // The account's note is gone from the phone; the signed-out one stays.
    expect(find.text('MEMBER SINCE 2026 · 1 NOTE'), findsOneWidget);
    expect(
      await onDb(
        tester,
        () => NotesRepository(db, owner: owner).watchAll().first,
      ),
      isEmpty,
    );
  });

  testApp('a failed deletion keeps the sheet open and the user signed in', (
    tester,
  ) async {
    await boot(tester, anonNotes: 0);
    await signInWithGoogle(tester);
    accounts.nextError = ForgeDataError.network;
    await tester.ensureVisible(find.byKey(ForgeAccountSettings.deleteKey));
    await tester.tap(find.byKey(ForgeAccountSettings.deleteKey));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
    await tester.pumpAndSettle();
    expect(find.text(dataErrorCopy(ForgeDataError.network)), findsOneWidget);
    expect(find.text(AccountScreen.deleteTitle), findsOneWidget);
    expect(auth.signOutCalls, isEmpty);
    expect(accounts.deleteCalls, 1);
  });

  testApp(
    'an account deleted elsewhere signs this phone out on the next sync',
    (tester) async {
      final db = await boot(tester, anonNotes: 1);
      await signInWithGoogle(tester);
      await tester.tap(find.text(AccountScreen.notNowLabel));
      await tester.pumpAndSettle();
      await onDb(
        tester,
        () => NotesRepository(db, owner: owner).save(note('o1', 'Owned')),
      );
      await settleSync(tester);
      expect(remote.rows.keys, ['o1']);

      // The website form (or another phone) flagged the account.
      accounts.deletionRequestedAt = DateTime.utc(2026, 10, 18, 12);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(auth.signOutCalls, [false]);
      expect(find.text(SessionGuard.accountDeleted), findsOneWidget);
      expect(find.byType(ForgeSignInPanel), findsOneWidget);
      expect(find.text('MEMBER SINCE 2026 · 1 NOTE'), findsOneWidget);
      expect(
        await onDb(
          tester,
          () => NotesRepository(db, owner: owner).watchAll().first,
        ),
        isEmpty,
      );
    },
  );

  testApp("a session that ends on its own also clears the account's notes", (
    tester,
  ) async {
    final db = await boot(tester, anonNotes: 0);
    await signInWithGoogle(tester);
    await onDb(
      tester,
      () => NotesRepository(db, owner: owner).save(note('o1', 'Owned')),
    );
    await settleSync(tester);
    // The refresh token is gone (the user was purged): the auth stream
    // signs out without the app asking.
    auth.emit(const ForgeAuthState(event: ForgeAuthEvent.signedOut));
    await tester.pumpAndSettle();
    expect(find.text(SessionGuard.sessionEnded), findsOneWidget);
    expect(find.byType(ForgeSignInPanel), findsOneWidget);
    expect(
      await onDb(
        tester,
        () => NotesRepository(db, owner: owner).watchAll().first,
      ),
      isEmpty,
    );
  });
}
