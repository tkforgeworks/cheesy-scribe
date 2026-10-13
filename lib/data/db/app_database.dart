import 'package:drift/drift.dart';

import '../models/models.dart';
import 'search_text.dart';

part 'app_database.g.dart';

/// Tasting notes. Dates are ISO text so they sort as strings: [tastedAt]
/// is `YYYY-MM-DD` (local calendar day), [createdAt] a UTC date-time.
/// Enums store their `name`. The 16 flavor spokes are integer columns
/// (`fl_*`, 0 = unset) so stats and filters can stay in SQL.
@DataClassName('NoteRow')
@TableIndex(name: 'notes_by_date', columns: {#tastedAt, #createdAt})
@TableIndex(name: 'notes_by_style', columns: {#cheeseStyleId})
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get cheeseName => text()();
  TextColumn get tastedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get creamery => text().nullable()();
  TextColumn get origin => text().nullable()();
  TextColumn get rind => textEnum<RindType>().nullable()();
  TextColumn get rindOther => text().nullable()();
  RealColumn get price => real().nullable()();
  TextColumn get priceUnit => textEnum<PriceUnit>()();
  TextColumn get milk => textEnum<MilkType>()();
  TextColumn get milkOther => text().nullable()();
  BoolColumn get isGrassfed => boolean().withDefault(const Constant(false))();
  BoolColumn get isRaw => boolean().withDefault(const Constant(false))();
  TextColumn get attributeOther => text().nullable()();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  TextColumn get texture => textEnum<TextureLevel>()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get verdict => text().nullable()();
  IntColumn get flSalty => integer().withDefault(const Constant(0))();
  IntColumn get flSweet => integer().withDefault(const Constant(0))();
  IntColumn get flSharpTangy => integer().withDefault(const Constant(0))();
  IntColumn get flLemon => integer().withDefault(const Constant(0))();
  IntColumn get flGrassy => integer().withDefault(const Constant(0))();
  IntColumn get flHerbal => integer().withDefault(const Constant(0))();
  IntColumn get flCaramel => integer().withDefault(const Constant(0))();
  IntColumn get flNutty => integer().withDefault(const Constant(0))();
  IntColumn get flEarthy => integer().withDefault(const Constant(0))();
  IntColumn get flMoldyBlue => integer().withDefault(const Constant(0))();
  IntColumn get flStinky => integer().withDefault(const Constant(0))();
  IntColumn get flRobust => integer().withDefault(const Constant(0))();
  IntColumn get flButteryCreamy => integer().withDefault(const Constant(0))();
  IntColumn get flMilkyLactic => integer().withDefault(const Constant(0))();
  IntColumn get flCrumbly => integer().withDefault(const Constant(0))();
  IntColumn get flCrystalline => integer().withDefault(const Constant(0))();
  TextColumn get cheeseStyleId => text().nullable()();
  TextColumn get photoUrl => text().nullable()();

  /// Lower-cased, diacritic-stripped haystack of every searchable field
  /// (see [searchTextFor]); the search box matches against this.
  TextColumn get searchText => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Recent search terms, capped at 10 by the repository.
@DataClassName('RecentSearchRow')
class RecentSearches extends Table {
  TextColumn get term => text()();
  TextColumn get searchedAt => text()();

  @override
  Set<Column> get primaryKey => {term};
}

/// Key/value preferences; keys are `AppSettings.toJson` keys.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Notes, RecentSearches, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump with every table change and add a case to [_upgradeTo]. Never
  /// edit a released case; users upgrade through each step in order.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      for (var target = from + 1; target <= to; target++) {
        await _upgradeTo(m, target);
      }
    },
  );

  Future<void> _upgradeTo(Migrator m, int version) async {
    switch (version) {
      // case 2: await m.addColumn(notes, notes.newColumn);
      default:
        throw StateError('No migration to schema version $version');
    }
  }
}

/// Row → domain.
TastingNote noteFromRow(NoteRow row) => TastingNote(
  id: row.id,
  cheeseName: row.cheeseName,
  tastedAt: TastingNote.parseDate(row.tastedAt),
  createdAt: DateTime.parse(row.createdAt),
  creamery: row.creamery,
  origin: row.origin,
  rind: row.rind,
  rindOther: row.rindOther,
  price: row.price,
  priceUnit: row.priceUnit,
  milk: row.milk,
  milkOther: row.milkOther,
  isGrassfed: row.isGrassfed,
  isRaw: row.isRaw,
  attributeOther: row.attributeOther,
  rating: row.rating,
  texture: row.texture,
  notes: row.notes,
  verdict: row.verdict,
  flavors: {
    FlavorNote.salty: row.flSalty,
    FlavorNote.sweet: row.flSweet,
    FlavorNote.sharpTangy: row.flSharpTangy,
    FlavorNote.lemon: row.flLemon,
    FlavorNote.grassy: row.flGrassy,
    FlavorNote.herbal: row.flHerbal,
    FlavorNote.caramel: row.flCaramel,
    FlavorNote.nutty: row.flNutty,
    FlavorNote.earthy: row.flEarthy,
    FlavorNote.moldyBlue: row.flMoldyBlue,
    FlavorNote.stinky: row.flStinky,
    FlavorNote.robust: row.flRobust,
    FlavorNote.butteryCreamy: row.flButteryCreamy,
    FlavorNote.milkyLactic: row.flMilkyLactic,
    FlavorNote.crumbly: row.flCrumbly,
    FlavorNote.crystalline: row.flCrystalline,
  },
  cheeseStyleId: row.cheeseStyleId,
  photoUrl: row.photoUrl,
);

/// Domain → row (all columns set, for upsert).
NotesCompanion noteToCompanion(TastingNote note) => NotesCompanion(
  id: Value(note.id),
  cheeseName: Value(note.cheeseName),
  tastedAt: Value(TastingNote.formatDate(note.tastedAt)),
  createdAt: Value(note.createdAt.toUtc().toIso8601String()),
  creamery: Value(note.creamery),
  origin: Value(note.origin),
  rind: Value(note.rind),
  rindOther: Value(note.rindOther),
  price: Value(note.price),
  priceUnit: Value(note.priceUnit),
  milk: Value(note.milk),
  milkOther: Value(note.milkOther),
  isGrassfed: Value(note.isGrassfed),
  isRaw: Value(note.isRaw),
  attributeOther: Value(note.attributeOther),
  rating: Value(note.rating),
  texture: Value(note.texture),
  notes: Value(note.notes),
  verdict: Value(note.verdict),
  flSalty: Value(note.flavorScore(FlavorNote.salty)),
  flSweet: Value(note.flavorScore(FlavorNote.sweet)),
  flSharpTangy: Value(note.flavorScore(FlavorNote.sharpTangy)),
  flLemon: Value(note.flavorScore(FlavorNote.lemon)),
  flGrassy: Value(note.flavorScore(FlavorNote.grassy)),
  flHerbal: Value(note.flavorScore(FlavorNote.herbal)),
  flCaramel: Value(note.flavorScore(FlavorNote.caramel)),
  flNutty: Value(note.flavorScore(FlavorNote.nutty)),
  flEarthy: Value(note.flavorScore(FlavorNote.earthy)),
  flMoldyBlue: Value(note.flavorScore(FlavorNote.moldyBlue)),
  flStinky: Value(note.flavorScore(FlavorNote.stinky)),
  flRobust: Value(note.flavorScore(FlavorNote.robust)),
  flButteryCreamy: Value(note.flavorScore(FlavorNote.butteryCreamy)),
  flMilkyLactic: Value(note.flavorScore(FlavorNote.milkyLactic)),
  flCrumbly: Value(note.flavorScore(FlavorNote.crumbly)),
  flCrystalline: Value(note.flavorScore(FlavorNote.crystalline)),
  cheeseStyleId: Value(note.cheeseStyleId),
  photoUrl: Value(note.photoUrl),
  searchText: Value(searchTextFor(note)),
);
