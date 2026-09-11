import 'dart:convert';

import 'package:flutter/services.dart';

import '../db/search_text.dart';
import '../models/models.dart';

/// The bundled, read-only cheese library (`assets/data/cheese_styles.json`,
/// CHEESE-22). Loaded once from the asset bundle and cached; no DB table.
class LibraryRepository {
  LibraryRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/cheese_styles.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  Future<List<CheeseStyle>>? _cache;

  /// Every style in file order (the curated display order).
  Future<List<CheeseStyle>> load() => _cache ??= _load();

  Future<List<CheeseStyle>> _load() async {
    final raw = await _bundle.loadString(assetPath);
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => CheeseStyle.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    assert(
      list.map((s) => s.id).toSet().length == list.length,
      'cheese_styles.json has duplicate ids',
    );
    return List.unmodifiable(list);
  }

  Future<CheeseStyle?> byId(String id) async {
    for (final s in await load()) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Styles whose name or examples contain every word of [query]
  /// (case- and diacritic-insensitive); all styles for a blank query.
  static List<CheeseStyle> search(List<CheeseStyle> styles, String query) {
    final tokens = searchTokens(query);
    if (tokens.isEmpty) return styles;
    return styles.where((s) {
      final hay = normalizeForSearch('${s.name} ${s.examples}');
      return tokens.every(hay.contains);
    }).toList();
  }
}
