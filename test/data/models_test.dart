import 'dart:convert';
import 'dart:io';

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

const schemaDir = 'docs/design_handoff_cheesy_scribe/schema';

JsonSchema loadSchema(String name) => JsonSchema.create(
  jsonDecode(File('$schemaDir/$name').readAsStringSync()),
  schemaVersion: SchemaVersion.draft2020_12,
);

void expectValid(JsonSchema schema, Map<String, dynamic> json) {
  final result = schema.validate(json, validateFormats: true);
  expect(result.errors, isEmpty, reason: result.errors.join('\n'));
}

/// Re-encode through a JSON string so the payload is what disk would hold.
Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

final fullNote = TastingNote(
  id: 'n-1',
  cheeseName: 'Époisses',
  tastedAt: DateTime(2026, 8, 12, 15, 30), // time of day is dropped
  createdAt: DateTime.utc(2026, 8, 12, 19, 30, 5),
  creamery: 'Fromagerie Berthaut',
  origin: 'Burgundy, France',
  rind: RindType.washed,
  price: 28,
  priceUnit: PriceUnit.usdPerLb,
  milk: MilkType.cow,
  isRaw: true,
  attributeOther: 'Cave-aged',
  rating: 4,
  texture: TextureLevel.runny,
  notes: 'Barnyard on the nose. Custard on the tongue! Went back twice.',
  verdict: 'Smells like a dare, tastes like a reward.',
  flavors: const {
    FlavorNote.stinky: 5,
    FlavorNote.butteryCreamy: 4,
    FlavorNote.salty: 3,
    FlavorNote.earthy: 3,
    FlavorNote.sweet: 1,
    FlavorNote.lemon: 0, // dropped
  },
  cheeseStyleId: 'washed-rind',
);

final minimalNote = TastingNote(
  id: 'n-2',
  cheeseName: 'Mystery wedge',
  tastedAt: DateTime(2026, 9, 1),
  createdAt: DateTime.utc(2026, 9, 1, 12),
);

void main() {
  group('TastingNote', () {
    test('normalises tastedAt to local midnight and drops zero flavors', () {
      expect(fullNote.tastedAt, DateTime(2026, 8, 12));
      expect(fullNote.flavors.containsKey(FlavorNote.lemon), isFalse);
      expect(fullNote.flavorScore(FlavorNote.lemon), 0);
      expect(fullNote.flavors[FlavorNote.stinky], 5);
    });

    test('JSON round-trips a full and a minimal note', () {
      for (final n in [fullNote, minimalNote]) {
        final json = roundTrip(n.toJson());
        expect(TastingNote.fromJson(json), n);
        expect(TastingNote.fromJson(json).hashCode, n.hashCode);
      }
      final json = fullNote.toJson();
      expect(json['tastedAt'], '2026-08-12');
      expect(json['createdAt'], '2026-08-12T19:30:05.000Z');
      expect(json['price'], 28);
      expect(json.containsKey('pricePerLb'), isFalse);
      expect(minimalNote.toJson().containsKey('verdict'), isFalse);
    });

    test('validates against the schema', () {
      final schema = loadSchema('tasting-note.schema.json');
      expectValid(schema, roundTrip(fullNote.toJson()));
      expectValid(schema, roundTrip(minimalNote.toJson()));
      final bad = roundTrip(fullNote.toJson())..['pricePerLb'] = 3;
      expect(schema.validate(bad).errors, isNotEmpty);
    });

    test('parses legacy date-time tastedAt and missing createdAt', () {
      final n = TastingNote.fromJson({
        'id': 'x',
        'cheeseName': 'Old',
        'tastedAt': '2026-03-04T23:59:00.000',
      });
      expect(n.tastedAt, DateTime(2026, 3, 4));
      expect(n.createdAt, DateTime(2026, 3, 4));
    });

    test('rating 0 is unrated', () {
      expect(minimalNote.isRated, isFalse);
      expect(fullNote.isRated, isTrue);
      expect(() => fullNote.copyWith(rating: 6), throwsAssertionError);
    });

    test('topFlavors takes score >= 3, highest first, wheel order on ties', () {
      expect(fullNote.topFlavors, [
        FlavorNote.stinky,
        FlavorNote.butteryCreamy,
        FlavorNote.salty,
      ]);
      expect(minimalNote.topFlavors, isEmpty);
    });

    test('featuredQuote prefers verdict, then first sentence, else null', () {
      expect(
        fullNote.featuredQuote,
        'Smells like a dare, tastes like a reward.',
      );
      expect(
        fullNote.copyWith(verdict: null).featuredQuote,
        'Barnyard on the nose.',
      );
      expect(
        fullNote
            .copyWith(verdict: '  ', notes: 'No punctuation here')
            .featuredQuote,
        'No punctuation here',
      );
      expect(minimalNote.featuredQuote, isNull);
      final long = 'A' * 200;
      expect(minimalNote.copyWith(notes: long).featuredQuote!.length, 120);
    });

    test('copyWith clears nullable fields explicitly', () {
      final cleared = fullNote.copyWith(price: null, cheeseStyleId: null);
      expect(cleared.price, isNull);
      expect(cleared.cheeseStyleId, isNull);
      expect(cleared.verdict, fullNote.verdict);
      expect(fullNote.copyWith(), fullNote);
    });
  });

  group('CheeseStyle', () {
    const alpine = CheeseStyle(
      id: 'alpine',
      name: 'Alpine',
      examples: 'Comté, Gruyère, Appenzeller',
      description: 'Big wheels, long ages, nutty and brothy.',
      typicalMilk: [MilkType.cow],
      typicalTexture: TextureLevel.firm,
    );

    test('JSON round-trips and validates', () {
      final json = roundTrip(alpine.toJson());
      expect(CheeseStyle.fromJson(json), alpine);
      expectValid(loadSchema('cheese-style.schema.json'), json);
    });

    test('schema rejects non-slug ids', () {
      final bad = roundTrip(alpine.toJson())..['id'] = 'Alpine Style';
      expect(
        loadSchema('cheese-style.schema.json').validate(bad).errors,
        isNotEmpty,
      );
    });
  });

  group('AppSettings', () {
    test('defaults, JSON round-trip and schema', () {
      const defaults = AppSettings();
      expect(defaults.themeMode, ThemeMode.system);
      expect(defaults.units, PriceUnit.usdPerLb);
      expect(defaults.displayName, isNull);
      const set = AppSettings(
        displayName: 'Tim',
        themeMode: ThemeMode.dark,
        units: PriceUnit.eurPerKg,
      );
      final schema = loadSchema('app-settings.schema.json');
      for (final s in [defaults, set]) {
        final json = roundTrip(s.toJson());
        expect(AppSettings.fromJson(json), s);
        expectValid(schema, json);
      }
      expect(AppSettings.fromJson(const {}), defaults);
      expect(set.copyWith(displayName: null).displayName, isNull);
      expect(set.copyWith().displayName, 'Tim');
    });
  });

  group('TastingStats', () {
    test('empty list gives the empty stats', () {
      expect(TastingStats.fromNotes(const []), TastingStats.empty);
    });

    test('excludes unrated notes from the average, counts flavors >= 3', () {
      final goat = minimalNote.copyWith(
        id: 'n-3',
        milk: MilkType.goat,
        rating: 2,
        flavors: {FlavorNote.lemon: 3, FlavorNote.salty: 2},
      );
      final stats = TastingStats.fromNotes([fullNote, minimalNote, goat]);
      expect(stats.totalNotes, 3);
      expect(stats.ratedNotes, 2);
      expect(stats.averageRating, 3.0);
      expect(stats.flavorCounts[FlavorNote.salty], 1);
      expect(stats.flavorCounts[FlavorNote.lemon], 1);
      expect(stats.flavorCounts.containsKey(FlavorNote.sweet), isFalse);
      expect(stats.milkBreakdown[MilkType.cow], closeTo(2 / 3, 1e-9));
      expect(stats.milkBreakdown[MilkType.goat], closeTo(1 / 3, 1e-9));
      expect(stats.topFlavors.first.key, FlavorNote.salty);
    });
  });

  test('enum labels', () {
    expect(FlavorNote.sharpTangy.label, 'SHARP/TANGY');
    expect(FlavorNote.nutty.label, 'NUTTY');
    expect(TextureLevel.semiSoft.label, 'SEMI-SOFT');
    expect(PriceUnit.eurPerKg.label, '€/KG');
    expect(RindType.leafWrapped.label, 'Leaf-wrapped');
  });
}
