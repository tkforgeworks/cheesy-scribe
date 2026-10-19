import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';

import '../forge_providers.dart';
import '../models/models.dart';
import '../providers.dart';
import 'profile_payload.dart';
import 'sync_coordinator.dart';
import 'sync_payload.dart';
import 'sync_service.dart';
import 'sync_status.dart';

/// The account's `notes` table on the server, or null in a build with no
/// backend. Tests override it with `FakeForgeEntriesRepository`.
final remoteNotesProvider = Provider<ForgeEntriesRepository<TastingNote>?>(
  (ref) => ref
      .watch(forgeCoreProvider)
      ?.entries<TastingNote>(
        table: 'notes',
        kind: 'tasting_note',
        fromJson: noteFromPayload,
        toJson: noteToPayload,
      ),
);

/// The account's `profiles` row on the server (member since, recent
/// searches), or null in a build with no backend.
final remoteProfileProvider = Provider<ForgeEntriesRepository<ProfilePayload>?>(
  (ref) => ref
      .watch(forgeCoreProvider)
      ?.entries<ProfilePayload>(
        table: 'profiles',
        kind: 'profile',
        fromJson: ProfilePayload.fromJson,
        toJson: (p) => p.toJson(),
      ),
);

/// The engine for the signed-in session, or null when signed out or without
/// a backend. A new session gets a new service (and the repository it
/// wraps is already scoped to that owner).
final syncServiceProvider = Provider<SyncService?>((ref) {
  final remote = ref.watch(remoteNotesProvider);
  final notes = ref.watch(notesRepositoryProvider);
  if (remote == null || notes.owner == null) return null;
  return SyncService(
    notes: notes,
    meta: ref.watch(syncMetaRepositoryProvider),
    remote: remote,
    profile: ref.watch(remoteProfileProvider),
    settings: ref.watch(settingsRepositoryProvider),
    searches: ref.watch(recentSearchesRepositoryProvider),
  );
});

/// Keeps the engine running while someone is signed in: `ScribeApp`
/// watches this so it exists for the app's lifetime. Null when there is
/// nothing to coordinate.
final syncCoordinatorProvider = Provider<SyncCoordinator?>((ref) {
  final service = ref.watch(syncServiceProvider);
  if (service == null) return null;
  final coordinator = SyncCoordinator(
    service: service,
    notes: ref.watch(notesRepositoryProvider),
  );
  ref.onDispose(coordinator.dispose);
  coordinator.start();
  return coordinator;
});

/// Live sync state for the status rows; signed out when there is no engine.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  // Watching the coordinator keeps it alive from wherever the status shows.
  ref.watch(syncCoordinatorProvider);
  return service?.changes ?? Stream.value(SyncStatus.signedOut);
});
