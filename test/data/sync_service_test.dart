import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/data/repositories/recent_searches_repository.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:cheesy_scribe/data/repositories/sync_meta_repository.dart';
import 'package:cheesy_scribe/data/sync/profile_payload.dart';
import 'package:cheesy_scribe/data/sync/sync_payload.dart';
import 'package:cheesy_scribe/data/sync/sync_service.dart';
import 'package:cheesy_scribe/data/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';

import '../support.dart';

/// One phone: its own database and clock, the shared server.
class Device {
  Device(
    this.name,
    this.remote, {
    required DateTime start,
    this.profile,
    this.accounts,
  }) : now = start {
    db = openTestDatabase();
    notes = NotesRepository(db, now: () => now, owner: 'tim');
    meta = SyncMetaRepository(db);
    settings = SettingsRepository(db);
    searches = RecentSearchesRepository(db, now: () => now);
    service = SyncService(
      notes: notes,
      meta: meta,
      remote: remote,
      profile: profile,
      settings: profile == null ? null : settings,
      searches: profile == null ? null : searches,
      accounts: accounts,
      now: () => now,
    );
    addTearDown(service.dispose);
  }

  final String name;
  final FakeForgeEntriesRepository<TastingNote> remote;
  final FakeForgeEntriesRepository<ProfilePayload>? profile;
  final FakeForgeAccounts? accounts;
  DateTime now;
  late final AppDatabase db;
  late final NotesRepository notes;
  late final SyncMetaRepository meta;
  late final SettingsRepository settings;
  late final RecentSearchesRepository searches;
  late final SyncService service;

  Future<List<String>> ids() async =>
      (await notes.watchAll().first).map((n) => n.id).toList();

  void tick([Duration d = const Duration(minutes: 1)]) => now = now.add(d);
}

TastingNote note(String id, String name) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: DateTime(2026, 10, 1),
  createdAt: DateTime.utc(2026, 10, 1, 12),
);

void main() {
  late FakeForgeAuth auth;
  late FakeForgeEntriesRepository<TastingNote> remote;
  late Device a;
  late Device b;

  setUp(() {
    auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    auth.signIn(const ForgeSession(userId: 'tim', email: 't@example.com'));
    remote = FakeForgeEntriesRepository<TastingNote>(auth);
    a = Device('a', remote, start: DateTime.utc(2026, 10, 18, 12));
    b = Device('b', remote, start: DateTime.utc(2026, 10, 18, 12));
  });

  test('payload carries schemaVersion and round-trips', () {
    final n = note('x', 'X');
    final payload = noteToPayload(n);
    expect(payload['schemaVersion'], 1);
    expect(payload['cheeseName'], 'X');
    expect(payload.containsKey('searchText'), isFalse);
    expect(noteFromPayload(payload), n);
  });

  test(
    'first sync uploads every local note; a second device pulls them',
    () async {
      await a.notes.save(note('1', 'One'));
      a.tick();
      await a.notes.save(note('2', 'Two'));
      final status = await a.service.sync();
      expect(status.phase, SyncPhase.idle);
      expect(status.pending, 0);
      expect(remote.rows.keys, unorderedEquals(['1', '2']));
      expect(await a.notes.dirtyNotes(), isEmpty);
      expect(remote.rows['2']!.updatedAt, a.now);
      expect(await a.meta.get(SyncService.lastSyncKey), isNotNull);

      expect(await b.service.sync(), isA<SyncStatus>());
      expect(await b.ids(), ['1', '2']);
      // Pulled rows are clean and keep the other phone's stamp.
      expect(await b.notes.dirtyNotes(), isEmpty);
      expect((await b.notes.getNote('2'))!.updatedAt, a.now);
    },
  );

  test('the newer edit wins, in either direction', () async {
    await a.notes.save(note('1', 'Original'));
    await a.service.sync();
    await b.service.sync();

    // Edited on both while apart: b later than a.
    a.tick(const Duration(minutes: 1));
    await a.notes.save(note('1', 'From A'));
    b.tick(const Duration(minutes: 2));
    await b.notes.save(note('1', 'From B'));
    await a.service.sync();
    await b.service.sync();
    await a.service.sync();
    expect((await a.notes.getNote('1'))!.cheeseName, 'From B');
    expect((await b.notes.getNote('1'))!.cheeseName, 'From B');
    expect(remote.rows['1']!.data!.cheeseName, 'From B');

    // Now a edits again, later still: a wins everywhere.
    a.tick(const Duration(minutes: 5));
    await a.notes.save(note('1', 'A again'));
    await a.service.sync();
    await b.service.sync();
    expect((await b.notes.getNote('1'))!.cheeseName, 'A again');
  });

  test('a local edit newer than the server copy is not overwritten', () async {
    await a.notes.save(note('1', 'Original'));
    await a.service.sync();
    await b.service.sync();
    b.tick(const Duration(minutes: 1));
    await b.notes.save(note('1', 'From B'));
    await b.service.sync();
    // a edits offline, later than b's change, and syncs: its edit stands
    // and goes up; the pull must not clobber it.
    a.tick(const Duration(minutes: 3));
    await a.notes.save(note('1', 'From A, later'));
    await a.service.sync();
    expect((await a.notes.getNote('1'))!.cheeseName, 'From A, later');
    expect(remote.rows['1']!.data!.cheeseName, 'From A, later');
  });

  test('deletions travel both ways; a newer edit resurrects', () async {
    await a.notes.save(note('1', 'One'));
    await a.notes.save(note('2', 'Two'));
    await a.service.sync();
    await b.service.sync();

    // a deletes 1: b loses it; the tombstone is cleared once pushed.
    a.tick();
    await a.notes.delete('1');
    expect(await a.notes.tombstones(), hasLength(1));
    await a.service.sync();
    expect(await a.notes.tombstones(), isEmpty);
    expect(remote.rows['1']!.isDeleted, isTrue);
    await b.service.sync();
    expect(await b.ids(), ['2']);
    expect(await b.notes.tombstones(), isEmpty); // remote deletion, no stone

    // b edits 2 at 12:05; a deleted 2 at 12:03 (a deletion older than the
    // edit): the edit wins and the note comes back on a.
    b.tick(const Duration(minutes: 5));
    await b.notes.save(note('2', 'Two, edited'));
    a.now = DateTime.utc(2026, 10, 18, 12, 3);
    await a.notes.delete('2');
    await a.service.sync(); // pushes the deletion stamped 12:03
    await b.service.sync(); // b's edit (12:05) is newer: stays, pushed
    expect(remote.rows['2']!.isDeleted, isFalse);
    await a.service.sync();
    expect((await a.notes.getNote('2'))?.cheeseName, 'Two, edited');
  });

  test(
    'a deletion newer than the local copy removes a dirty local edit too',
    () async {
      await a.notes.save(note('1', 'One'));
      await a.service.sync();
      await b.service.sync();
      b.tick(const Duration(minutes: 1));
      await b.notes.save(note('1', 'Edited on b'));
      a.tick(const Duration(minutes: 2));
      await a.notes.delete('1');
      await a.service.sync();
      // b's edit (12:01) is older than the deletion (12:02); b pushes the
      // edit first, then learns of the newer deletion and drops the note.
      await b.service.sync();
      expect(await b.ids(), isEmpty);
      expect(remote.rows['1']!.isDeleted, isTrue);
    },
  );

  test('a network failure reports offline and keeps the notes dirty', () async {
    await a.notes.save(note('1', 'One'));
    remote.nextError = ForgeDataError.network;
    final status = await a.service.sync();
    expect(status.phase, SyncPhase.offline);
    expect(status.pending, 1);
    expect(await a.notes.dirtyNotes(), hasLength(1));
    expect(await a.meta.get(SyncService.lastErrorKey), isNull);
    // Other failures are errors and are remembered across restarts.
    remote.nextError = ForgeDataError.invalid;
    expect((await a.service.sync()).phase, SyncPhase.error);
    expect(await a.meta.get(SyncService.lastErrorKey), isNotNull);
    // The next good sync clears it.
    expect((await a.service.sync()).phase, SyncPhase.idle);
    expect(await a.meta.get(SyncService.lastErrorKey), isNull);
    expect(remote.rows.keys, ['1']);
  });

  test('concurrent sync calls share one run', () async {
    await a.notes.save(note('1', 'One'));
    final first = a.service.sync();
    final second = a.service.sync();
    expect(identical(first, second), isTrue);
    await first;
    expect(remote.calls.where((c) => c.$1 == 'upsertAll'), hasLength(1));
  });

  test('load restores the stored status without touching the server', () async {
    await a.notes.save(note('1', 'One'));
    await a.service.sync();
    final restarted = SyncService(
      notes: a.notes,
      meta: a.meta,
      remote: remote,
      now: () => a.now,
    );
    addTearDown(restarted.dispose);
    final before = remote.calls.length;
    await restarted.load();
    expect(restarted.status.phase, SyncPhase.idle);
    expect(restarted.status.lastSyncAt, isNotNull);
    expect(restarted.status.pending, 0);
    expect(remote.calls.length, before);
  });

  test(
    'the key listing overlaps the high-water mark to absorb clock skew',
    () async {
      await a.notes.save(note('1', 'One'));
      await a.service.sync();
      // b's clock is 10 minutes behind a's; its write is stamped "before"
      // a's high-water mark, yet a still sees it on the next sync.
      b.now = a.now.subtract(const Duration(minutes: 10));
      await b.notes.save(note('2', 'Two, from a slow clock'));
      await b.service.sync();
      await a.service.sync();
      expect(await a.ids(), unorderedEquals(['1', '2']));
    },
  );

  group('profile row (CHEESE-63)', () {
    late FakeForgeEntriesRepository<ProfilePayload> profiles;
    late Device a;
    late Device b;

    setUp(() {
      profiles = FakeForgeEntriesRepository<ProfilePayload>(auth);
      a = Device(
        'a',
        remote,
        start: DateTime.utc(2026, 10, 18, 12),
        profile: profiles,
      );
      b = Device(
        'b',
        remote,
        start: DateTime.utc(2026, 10, 18, 12),
        profile: profiles,
      );
    });

    test('payload round-trips with schemaVersion', () {
      final p = ProfilePayload(
        memberSince: DateTime(2026, 6, 1),
        recentSearches: const ['blue', 'comté'],
      );
      final json = p.toJson();
      expect(json['schemaVersion'], 1);
      expect(json['memberSince'], '2026-06-01');
      expect(ProfilePayload.fromJson(json), p);
      expect(ProfilePayload.fromJson({}), const ProfilePayload());
    });

    test('first sync pushes the profile; the other phone pulls it', () async {
      await a.settings.update(
        (s) => s.copyWith(memberSince: DateTime(2026, 6, 1)),
      );
      await a.searches.add('blue');
      await a.service.sync();
      final row = profiles.rows['tim']!;
      expect(row.data!.recentSearches, ['blue']);
      expect(row.data!.memberSince, DateTime(2026, 6, 1));
      expect(row.updatedAt, a.now);

      await b.service.sync();
      expect(await b.searches.watch().first, ['blue']);
      expect((await b.settings.load()).memberSince, DateTime(2026, 6, 1));
      // Nothing to push back: the pulled profile equals the server's.
      final pushes = profiles.calls.where((c) => c.$1 == 'upsertAll').length;
      await b.service.sync();
      expect(profiles.calls.where((c) => c.$1 == 'upsertAll').length, pushes);
    });

    test(
      'searches follow the later side; member since the earlier date',
      () async {
        await a.settings.update(
          (s) => s.copyWith(memberSince: DateTime(2026, 6, 1)),
        );
        await a.searches.add('blue');
        await a.service.sync();
        await b.service.sync();
        // b searches later than a's last change: b's list wins everywhere.
        b.tick(const Duration(minutes: 5));
        await b.searches.add('gouda');
        await b.settings.update(
          (s) => s.copyWith(memberSince: DateTime(2024, 1, 1)),
        );
        await b.service.sync();
        await a.service.sync();
        expect(await a.searches.watch().first, ['gouda', 'blue']);
        expect((await a.settings.load()).memberSince, DateTime(2024, 1, 1));
        // a's older local search list does not overwrite b's newer one.
        expect(profiles.rows['tim']!.data!.recentSearches, ['gouda', 'blue']);
      },
    );

    test('a profile failure reports like a notes failure', () async {
      profiles.nextError = ForgeDataError.network;
      expect((await a.service.sync()).phase, SyncPhase.offline);
      expect((await a.service.sync()).phase, SyncPhase.idle);
    });
  });

  group('account status (CHEESE-65)', () {
    test('a flagged or purged account ends the run as accountGone', () async {
      final accounts = FakeForgeAccounts(auth);
      final a = Device(
        'a',
        remote,
        start: DateTime.utc(2026, 10, 18, 12),
        accounts: accounts,
      );
      await a.notes.save(note('1', 'One'));
      expect((await a.service.sync()).phase, SyncPhase.idle);
      expect(remote.rows.keys, ['1']);

      accounts.deletionRequestedAt = DateTime.utc(2026, 10, 18, 12, 30);
      a.tick();
      await a.notes.save(note('2', 'Two'));
      final calls = remote.calls.length;
      final status = await a.service.sync();
      expect(status.phase, SyncPhase.accountGone);
      expect(status.pending, 1);
      // Nothing was pushed or pulled for a dead account.
      expect(remote.calls.length, calls);
      // The server refusing a write the same way (RLS, 42501) reads alike.
      accounts.deletionRequestedAt = null;
      remote.nextError = ForgeDataError.accountInactive;
      expect((await a.service.sync()).phase, SyncPhase.accountGone);
    });
  });
}
