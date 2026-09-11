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
  List<CheeseStyle>? _styles;
  Future<List<CheeseStyle>>? _loading;

  /// Every style in file order (the curated display order). Once loaded,
  /// answers from memory with a future created in the caller's zone (so
  /// widget tests on the fake clock resolve it too).
  Future<List<CheeseStyle>> load() {
    final loaded = _styles;
    if (loaded != null) return Future.value(loaded);
    return _loading ??= _load().then((s) => _styles = s);
  }

  /// The styles if [load] has completed, else null.
  List<CheeseStyle>? get loadedStyles => _styles;

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
