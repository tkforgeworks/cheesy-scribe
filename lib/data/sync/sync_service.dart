import 'dart:async';

import 'package:forge_core/forge_core.dart';

import '../models/models.dart';
import '../repositories/notes_repository.dart';
import '../repositories/recent_searches_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/sync_meta_repository.dart';
import 'profile_payload.dart';
import 'sync_status.dart';

/// One account's notes, reconciled between this phone and the server
/// (CHEESE-62): manifest-diff, last write wins per whole note on the
/// device-stamped `updatedAt`, tombstones both ways.
///
/// A [sync] is: list the server's keys changed since the high-water mark
/// (minus [overlap], so a phone whose clock lagged when it wrote is still
/// seen); push local edits ([NotesRepository.dirtyNotes]) and deletions
/// ([NotesRepository.tombstones]) that are newer than the server's copy,
/// dropping the ones that are older; apply remote deletions newer than the
/// local note; fetch and apply remote notes newer than the local copy;
/// record the newest stamp seen. Comparing before pushing is what makes
/// last-write-wins hold in both directions: a stale offline edit cannot
/// undo a newer change or deletion made elsewhere, and a newer local edit
/// resurrects a note another phone deleted earlier. The server's own
/// keep-newer trigger guards the same rule against two phones racing.
/// Single-flight: a call during a run returns that run's result.
///
/// Owns no triggers; `SyncCoordinator` decides when to call [sync].
class SyncService {
  SyncService({
    required this.notes,
    required this.meta,
    required this.remote,
    this.profile,
    this.settings,
    this.searches,
    this.accounts,
    DateTime Function()? now,
    this.overlap = const Duration(days: 1),
  }) : assert(notes.owner != null, 'sync needs a signed-in owner scope'),
       assert(
         profile == null || (settings != null && searches != null),
         'profile sync needs the settings and recent-searches repositories',
       ),
       _now = now ?? DateTime.now;

  /// Scoped to the signed-in account.
  final NotesRepository notes;
  final SyncMetaRepository meta;
  final ForgeEntriesRepository<TastingNote> remote;

  /// The account's one `profiles` row (member since, recent searches);
  /// null skips profile sync. Reconciled after the notes on every run.
  final ForgeEntriesRepository<ProfilePayload>? profile;
  final SettingsRepository? settings;
  final RecentSearchesRepository? searches;

  /// Checked at the start of every run: an account flagged for deletion
  /// or already purged ends in [SyncPhase.accountGone] instead of a sync,
  /// so a deletion made on the website or another phone reaches this one
  /// the next time it looks (CHEESE-65). Null skips the check.
  final ForgeAccounts? accounts;
  final DateTime Function() _now;

  /// How far before the high-water mark the key listing starts, to absorb
  /// clock skew between phones (CHEESE-60 decision 4).
  final Duration overlap;

  static const lastSyncKey = 'last_sync_at';
  static const lastErrorKey = 'last_error';

  /// The server stamp of the profile row this phone last reconciled with.
  static const profileSyncedKey = 'profile_synced_at';

  final _controller = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus(phase: SyncPhase.idle);
  Future<SyncStatus>? _inFlight;

  /// The state right now.
  SyncStatus get status => _status;

  /// Emits [status] first, then every change.
  Stream<SyncStatus> get changes async* {
    yield _status;
    yield* _controller.stream;
  }

  /// Reads the stored high-water mark and pending count into [status]
  /// without talking to the server (app start, before the first sync).
  Future<void> load() async {
    final stored = await meta.get(lastSyncKey);
    final error = await meta.get(lastErrorKey);
    _set(
      SyncStatus(
        phase: error == null ? SyncPhase.idle : SyncPhase.error,
        lastSyncAt: stored == null ? null : DateTime.parse(stored).toUtc(),
        message: error,
        pending: (await notes.dirtyNotes()).length,
      ),
    );
  }

  /// Runs a full reconciliation. Never throws; the outcome is the returned
  /// (and emitted) status.
  Future<SyncStatus> sync() => _inFlight ??= _run().whenComplete(() {
    _inFlight = null;
  });

  Future<SyncStatus> _run() async {
    final dirty = await notes.dirtyNotes();
    _set(_status.copyWith(phase: SyncPhase.syncing, pending: dirty.length));

    // 0. Is the account still there? Row-level security would hide the
    //    data of a flagged account anyway, but silently: an empty key
    //    listing looks like "nothing new", not "you were deleted".
    if (accounts case final accounts?) {
      switch (await accounts.getAccount()) {
        case ForgeFailed(:final error, :final message):
          return _fail(error, message);
        case ForgeOk(:final value):
          if (value == null || value.isPendingDeletion) {
            _set(
              _status.copyWith(
                phase: SyncPhase.accountGone,
                message: value == null
                    ? 'account purged'
                    : 'deletion requested',
                pending: dirty.length,
              ),
            );
            return _status;
          }
      }
    }

    // 1. The server's side of the diff: everything changed there since we
    //    last looked (minus the overlap). Fetched before pushing so a local
    //    edit older than the server's copy is never pushed over it: last
    //    write wins in both directions, and a stale offline edit cannot
    //    undo a newer deletion made elsewhere.
    final stored = await meta.get(lastSyncKey);
    final lastSync = stored == null ? null : DateTime.parse(stored).toUtc();
    final listed = await remote.listKeys(since: lastSync?.subtract(overlap));
    final List<ForgeEntryKey> keys;
    switch (listed) {
      case ForgeOk(:final value):
        keys = value;
      case ForgeFailed(:final error, :final message):
        return _fail(error, message);
    }
    final serverStamp = {for (final k in keys) k.id: k};

    // 2. Push local edits the server has nothing newer for.
    final toPush = [
      for (final n in dirty)
        if (serverStamp[n.id] case final k?
            when k.updatedAt.isAfter(n.updatedAt))
          // The server wins; step 4 applies its version (or its deletion).
          null
        else
          n,
    ].nonNulls.toList();
    if (toPush.isNotEmpty) {
      final pushed = await remote.upsertAll([
        for (final n in toPush)
          ForgeEntry<TastingNote>(
            id: n.id,
            data: n,
            updatedAt: n.updatedAt,
            createdAt: n.createdAt,
          ),
      ]);
      if (pushed case ForgeFailed(:final error, :final message)) {
        return _fail(error, message);
      }
      await notes.markClean(toPush);
    }

    // 3. Push local deletions, each with its own time so "deletion wins
    //    only when newer" holds on the server too. A deletion older than
    //    the server's copy is dropped instead; step 4 brings the note back.
    for (final t in await notes.tombstones()) {
      final k = serverStamp[t.id];
      if (k == null || !k.updatedAt.isAfter(t.deletedAt)) {
        final deleted = await remote.markDeleted([t.id], t.deletedAt.toUtc());
        if (deleted case ForgeFailed(:final error, :final message)) {
          return _fail(error, message);
        }
      }
      await notes.clearTombstones([t.id]);
    }

    // 4. Pull what the server has that is newer than this phone's copy.
    final local = await notes.syncStamps(keys.map((k) => k.id));
    final toDelete = <String>[];
    final toFetch = <String>[];
    var highWater = lastSync;
    for (final key in keys) {
      if (highWater == null || key.updatedAt.isAfter(highWater)) {
        highWater = key.updatedAt;
      }
      final mine = local[key.id];
      if (key.isDeleted) {
        // Deletion wins only when newer than the local copy; a newer local
        // edit was just pushed and stands.
        if (mine != null && !mine.updatedAt.isAfter(key.updatedAt)) {
          toDelete.add(key.id);
        }
      } else if (mine == null || key.updatedAt.isAfter(mine.updatedAt)) {
        toFetch.add(key.id);
      }
    }
    if (toDelete.isNotEmpty) await notes.applyRemoteDeletions(toDelete);
    if (toFetch.isNotEmpty) {
      final fetched = await remote.fetchByIds(toFetch);
      switch (fetched) {
        case ForgeFailed(:final error, :final message):
          return _fail(error, message);
        case ForgeOk(:final value):
          final live = <TastingNote>[];
          final gone = <String>[];
          for (final e in value) {
            final data = e.data;
            if (e.isDeleted || data == null) {
              gone.add(e.id);
            } else {
              live.add(data);
            }
          }
          if (live.isNotEmpty) await notes.applyRemote(live);
          if (gone.isNotEmpty) await notes.applyRemoteDeletions(gone);
      }
    }

    // 5. The profile row: recent searches follow the later side, member
    //    since is the earlier date, and a difference is pushed.
    final profileFailure = await _syncProfile();
    if (profileFailure != null) return profileFailure;

    // The newest server stamp seen, or what we pushed, is the new mark.
    for (final n in toPush) {
      if (highWater == null || n.updatedAt.isAfter(highWater)) {
        highWater = n.updatedAt;
      }
    }
    if (highWater != null) {
      await meta.set(lastSyncKey, highWater.toIso8601String());
    }
    await meta.set(lastErrorKey, null);
    _set(
      SyncStatus(
        phase: SyncPhase.idle,
        lastSyncAt: highWater ?? _now().toUtc(),
        pending: (await notes.dirtyNotes()).length,
      ),
    );
    return _status;
  }

  /// Returns a failure status, or null when the profile is reconciled.
  Future<SyncStatus?> _syncProfile() async {
    final profile = this.profile;
    if (profile == null) return null;
    final userId = notes.owner!;
    final fetched = await profile.fetchByIds([userId]);
    final ForgeEntry<ProfilePayload>? remoteRow;
    switch (fetched) {
      case ForgeFailed(:final error, :final message):
        return _fail(error, message);
      case ForgeOk(:final value):
        remoteRow = value.where((e) => !e.isDeleted).firstOrNull;
    }
    final stored = await meta.get(profileSyncedKey);
    final syncedAt = stored == null ? null : DateTime.parse(stored).toUtc();

    var local = await _localProfile();
    final localTerms = await searches!.entries();
    final localChangedAt = localTerms.isEmpty ? null : localTerms.first.$2;
    final remotePayload = remoteRow?.data;
    if (remoteRow != null &&
        remotePayload != null &&
        (syncedAt == null || remoteRow.updatedAt.isAfter(syncedAt))) {
      // The server changed since we last looked. Searches: the later side
      // wins. Member since: the earlier date is the truth.
      if (localChangedAt == null ||
          !localChangedAt.isAfter(remoteRow.updatedAt)) {
        await searches!.replaceAll(
          remotePayload.recentSearches,
          at: remoteRow.updatedAt,
        );
      }
      final earliest = _earliest(local.memberSince, remotePayload.memberSince);
      if (earliest != local.memberSince) {
        await settings!.update((s) => s.copyWith(memberSince: earliest));
      }
      await meta.set(profileSyncedKey, remoteRow.updatedAt.toIso8601String());
      local = await _localProfile();
    }
    if (remotePayload == null || local != remotePayload) {
      final stamp = _now().toUtc();
      final pushed = await profile.upsertAll([
        ForgeEntry<ProfilePayload>(id: userId, data: local, updatedAt: stamp),
      ]);
      if (pushed case ForgeFailed(:final error, :final message)) {
        return _fail(error, message);
      }
      await meta.set(profileSyncedKey, stamp.toIso8601String());
    }
    return null;
  }

  Future<ProfilePayload> _localProfile() async => ProfilePayload(
    memberSince: (await settings!.load()).memberSince,
    recentSearches: [for (final e in await searches!.entries()) e.$1],
  );

  static DateTime? _earliest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return b.isBefore(a) ? b : a;
  }

  Future<SyncStatus> _fail(ForgeDataError error, String message) async {
    final phase = switch (error) {
      ForgeDataError.network => SyncPhase.offline,
      ForgeDataError.accountInactive => SyncPhase.accountGone,
      _ => SyncPhase.error,
    };
    if (phase == SyncPhase.error) await meta.set(lastErrorKey, message);
    _set(
      _status.copyWith(
        phase: phase,
        message: message,
        pending: (await notes.dirtyNotes()).length,
      ),
    );
    return _status;
  }

  void _set(SyncStatus status) {
    _status = status;
    if (!_controller.isClosed) _controller.add(status);
  }

  Future<void> dispose() => _controller.close();
}
