import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';
import 'models/models.dart';
import 'repositories/library_repository.dart';
import 'repositories/notes_repository.dart';
import 'repositories/recent_searches_repository.dart';
import 'repositories/settings_repository.dart';

/// The on-device SQLite database (`cheesy_scribe.sqlite` in the app's
/// support directory via drift_flutter). Tests override this with
/// `AppDatabase(NativeDatabase.memory())` — see `test/support.dart`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'cheesy_scribe'));
  ref.onDispose(db.close);
  return db;
});

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>(
  (ref) => RecentSearchesRepository(ref.watch(appDatabaseProvider)),
);

/// One note, live; emits null once it is deleted.
final noteProvider = StreamProvider.family<TastingNote?, String>(
  (ref, id) => ref.watch(notesRepositoryProvider).watchNote(id),
);

/// Live settings; `AppSettings()` defaults until the first row exists.
final appSettingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(),
);

/// The bundled cheese library, in curated order.
final cheeseStylesProvider = FutureProvider<List<CheeseStyle>>(
  (ref) => ref.watch(libraryRepositoryProvider).load(),
);

/// One style by id; null when the id is unknown (a note may outlive a
/// renamed style only if we break the "ids are stable" rule — don't).
final cheeseStyleProvider = FutureProvider.family<CheeseStyle?, String>(
  (ref, id) => ref.watch(libraryRepositoryProvider).byId(id),
);

/// One page of notes for the home list / search (query = filters + paging).
final notesPageProvider = StreamProvider.family<List<TastingNote>, NotesQuery>(
  (ref, query) => ref.watch(notesRepositoryProvider).watchPage(query),
);

/// Total notes matching a query's filters (paging ignored).
final notesCountProvider = StreamProvider.family<int, NotesQuery>(
  (ref, query) => ref.watch(notesRepositoryProvider).watchCount(query),
);

/// The featured card's note.
final newestNoteProvider = StreamProvider<TastingNote?>(
  (ref) => ref.watch(notesRepositoryProvider).watchNewest(),
);

/// Style ids by note count, for the Home filter chips.
final topStyleIdsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(notesRepositoryProvider).watchTopStyleIds(),
);

/// Recent search terms, most recent first (cap 10).
final recentSearchesProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(recentSearchesRepositoryProvider).watch(),
);
