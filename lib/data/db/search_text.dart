import '../models/models.dart';

/// Folds text for substring search: lower case, common Latin diacritics
/// stripped ("Époisses" → "epoisses"), punctuation collapsed to spaces.
/// Applied to both the stored haystack and the typed query (B10).
String normalizeForSearch(String input) {
  final sb = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    sb.write(_folded[ch] ?? ch);
  }
  return sb
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r' {2,}'), ' ');
}

/// Query words that must all appear in the haystack.
List<String> searchTokens(String query) {
  final n = normalizeForSearch(query);
  return n.isEmpty ? const [] : n.split(' ');
}

/// The haystack stored in `notes.search_text`.
String searchTextFor(TastingNote n) => normalizeForSearch(
  [
    n.cheeseName,
    n.creamery,
    n.origin,
    n.notes,
    n.verdict,
    n.rindOther,
    n.milkOther,
    n.attributeOther,
    // Flavor labels count once they are a real note, not a whisper (≥ 3).
    for (final e in n.flavors.entries)
      if (e.value >= 3) e.key.label,
  ].whereType<String>().join(' '),
);

const _folded = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'æ': 'ae',
  'ç': 'c',
  'č': 'c',
  'ć': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ě': 'e',
  'ę': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'œ': 'oe',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ů': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'š': 's',
  'ś': 's',
  'ß': 'ss',
  'ž': 'z',
  'ź': 'z',
  'ż': 'z',
  'ł': 'l',
  'ð': 'd',
  'þ': 'th',
};
