import 'package:flutter/foundation.dart';

import 'enums.dart';

/// One tasting, as written in the journal. Plain immutable class with JSON
/// round-tripping (`schema/tasting-note.schema.json`).
///
/// Handoff model amended per CHEESE-1 §3 B1–B8: [verdict], [price] +
/// [priceUnit] (was `pricePerLb`), [attributeOther], [rating] 0 = unrated,
/// [tastedAt] is a date (local midnight), [createdAt] breaks ordering ties.
/// [updatedAt] is sync metadata (CHEESE-58): stamped by the repository on
/// save, excluded from [==].
@immutable
class TastingNote {
  TastingNote({
    required this.id,
    required this.cheeseName,
    required DateTime tastedAt,
    required this.createdAt,
    DateTime? updatedAt,
    this.creamery,
    this.origin,
    this.rind,
    this.rindOther,
    this.price,
    this.priceUnit = PriceUnit.usdPerLb,
    this.milk = MilkType.cow,
    this.milkOther,
    this.isGrassfed = false,
    this.isRaw = false,
    this.attributeOther,
    this.rating = 0,
    this.texture = TextureLevel.semiSoft,
    this.notes = '',
    this.verdict,
    Map<FlavorNote, int> flavors = const {},
    this.cheeseStyleId,
  }) : assert(rating >= 0 && rating <= 5, 'rating is 0 (unrated) to 5'),
       assert(price == null || price >= 0, 'price is never negative'),
       tastedAt = dateOnly(tastedAt),
       updatedAt = updatedAt ?? createdAt,
       flavors = Map.unmodifiable({
         for (final e in flavors.entries)
           if (e.value > 0) e.key: e.value.clamp(0, 5),
       });

  final String id;
  final String cheeseName;

  /// The tasting date at local midnight; the form is a date picker (B8).
  final DateTime tastedAt;

  /// When the note was first saved; orders notes tasted on the same day.
  final DateTime createdAt;

  /// Last local change, UTC. The repository stamps it on every save and
  /// sync compares it (last write wins). Defaults to [createdAt]. Metadata:
  /// not part of [==], so a re-saved note still equals its draft.
  final DateTime updatedAt;
  final String? creamery;
  final String? origin;
  final RindType? rind;

  /// Free text when [rind] is [RindType.other].
  final String? rindOther;

  /// Price in [priceUnit]; null when not recorded.
  final double? price;
  final PriceUnit priceUnit;
  final MilkType milk;

  /// Free text when [milk] is [MilkType.other].
  final String? milkOther;
  final bool isGrassfed;
  final bool isRaw;

  /// Free text for the "Other" chip on the Grassfed / Raw / Other row (B4).
  final String? attributeOther;

  /// Whole stars 1–5; 0 means unrated (hidden, excluded from averages).
  final int rating;
  final TextureLevel texture;
  final String notes;

  /// One-line quote for the featured card (B2).
  final String? verdict;

  /// Flavor wheel scores 1–5 per spoke; a missing spoke is 0.
  final Map<FlavorNote, int> flavors;

  /// Library link (`CheeseStyle.id`), set by the STYLE picker (B1).
  final String? cheeseStyleId;

  /// Whether the note carries a star rating at all (B7).
  bool get isRated => rating > 0;

  /// Score for a spoke; 0 when unset.
  int flavorScore(FlavorNote f) => flavors[f] ?? 0;

  /// Top flavors for tag capsules (score >= 3, highest first, max 3).
  List<FlavorNote> get topFlavors {
    final entries = flavors.entries.where((e) => e.value >= 3).toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        return byScore != 0 ? byScore : a.key.index.compareTo(b.key.index);
      });
    return entries.take(3).map((e) => e.key).toList();
  }

  /// The italic line on the featured card: [verdict], else the first
  /// sentence of [notes], else null (B2).
  String? get featuredQuote {
    final v = verdict?.trim();
    if (v != null && v.isNotEmpty) return v;
    final text = notes.trim();
    if (text.isEmpty) return null;
    final match = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(text);
    final sentence = (match?.group(0) ?? text).trim();
    const max = 120;
    if (sentence.length <= max) return sentence;
    return '${sentence.substring(0, max - 1).trimRight()}…';
  }

  /// Local midnight of [d]'s calendar day.
  static DateTime dateOnly(DateTime d) {
    final local = d.isUtc ? d.toLocal() : d;
    return DateTime(local.year, local.month, local.day);
  }

  TastingNote copyWith({
    String? id,
    String? cheeseName,
    DateTime? tastedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? creamery = _unset,
    Object? origin = _unset,
    Object? rind = _unset,
    Object? rindOther = _unset,
    Object? price = _unset,
    PriceUnit? priceUnit,
    MilkType? milk,
    Object? milkOther = _unset,
    bool? isGrassfed,
    bool? isRaw,
    Object? attributeOther = _unset,
    int? rating,
    TextureLevel? texture,
    String? notes,
    Object? verdict = _unset,
    Map<FlavorNote, int>? flavors,
    Object? cheeseStyleId = _unset,
  }) {
    return TastingNote(
      id: id ?? this.id,
      cheeseName: cheeseName ?? this.cheeseName,
      tastedAt: tastedAt ?? this.tastedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creamery: _pick(creamery, this.creamery),
      origin: _pick(origin, this.origin),
      rind: _pick(rind, this.rind),
      rindOther: _pick(rindOther, this.rindOther),
      price: _pick(price, this.price),
      priceUnit: priceUnit ?? this.priceUnit,
      milk: milk ?? this.milk,
      milkOther: _pick(milkOther, this.milkOther),
      isGrassfed: isGrassfed ?? this.isGrassfed,
      isRaw: isRaw ?? this.isRaw,
      attributeOther: _pick(attributeOther, this.attributeOther),
      rating: rating ?? this.rating,
      texture: texture ?? this.texture,
      notes: notes ?? this.notes,
      verdict: _pick(verdict, this.verdict),
      flavors: flavors ?? this.flavors,
      cheeseStyleId: _pick(cheeseStyleId, this.cheeseStyleId),
    );
  }

  factory TastingNote.fromJson(Map<String, dynamic> json) => TastingNote(
    id: json['id'] as String,
    cheeseName: json['cheeseName'] as String,
    tastedAt: parseDate(json['tastedAt'] as String),
    createdAt: json['createdAt'] == null
        ? parseDate(json['tastedAt'] as String)
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    creamery: json['creamery'] as String?,
    origin: json['origin'] as String?,
    rind: json['rind'] == null
        ? null
        : RindType.values.byName(json['rind'] as String),
    rindOther: json['rindOther'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    priceUnit: PriceUnit.values.byName(
      json['priceUnit'] as String? ?? 'usdPerLb',
    ),
    milk: MilkType.values.byName(json['milk'] as String? ?? 'cow'),
    milkOther: json['milkOther'] as String?,
    isGrassfed: json['isGrassfed'] as bool? ?? false,
    isRaw: json['isRaw'] as bool? ?? false,
    attributeOther: json['attributeOther'] as String?,
    rating: json['rating'] as int? ?? 0,
    texture: TextureLevel.values.byName(
      json['texture'] as String? ?? 'semiSoft',
    ),
    notes: json['notes'] as String? ?? '',
    verdict: json['verdict'] as String?,
    flavors: (json['flavors'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(FlavorNote.values.byName(k), v as int),
    ),
    cheeseStyleId: json['cheeseStyleId'] as String?,
    // A `photoUrl` key from a build before CHEESE-82 is ignored: photos were
    // modelled but never built, and are out of scope for good.
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cheeseName': cheeseName,
    'tastedAt': formatDate(tastedAt),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    if (creamery != null) 'creamery': creamery,
    if (origin != null) 'origin': origin,
    if (rind != null) 'rind': rind!.name,
    if (rindOther != null) 'rindOther': rindOther,
    if (price != null) 'price': price,
    'priceUnit': priceUnit.name,
    'milk': milk.name,
    if (milkOther != null) 'milkOther': milkOther,
    'isGrassfed': isGrassfed,
    'isRaw': isRaw,
    if (attributeOther != null) 'attributeOther': attributeOther,
    'rating': rating,
    'texture': texture.name,
    'notes': notes,
    if (verdict != null) 'verdict': verdict,
    'flavors': flavors.map((k, v) => MapEntry(k.name, v)),
    if (cheeseStyleId != null) 'cheeseStyleId': cheeseStyleId,
  };

  /// `YYYY-MM-DD` (JSON Schema `date`).
  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Accepts `YYYY-MM-DD` or a full date-time (older payloads); either way
  /// the result is local midnight of that calendar day.
  static DateTime parseDate(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }
    return dateOnly(DateTime.parse(s));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TastingNote &&
          other.id == id &&
          other.cheeseName == cheeseName &&
          other.tastedAt == tastedAt &&
          other.createdAt == createdAt &&
          other.creamery == creamery &&
          other.origin == origin &&
          other.rind == rind &&
          other.rindOther == rindOther &&
          other.price == price &&
          other.priceUnit == priceUnit &&
          other.milk == milk &&
          other.milkOther == milkOther &&
          other.isGrassfed == isGrassfed &&
          other.isRaw == isRaw &&
          other.attributeOther == attributeOther &&
          other.rating == rating &&
          other.texture == texture &&
          other.notes == notes &&
          other.verdict == verdict &&
          mapEquals(other.flavors, flavors) &&
          other.cheeseStyleId == cheeseStyleId;

  @override
  int get hashCode => Object.hash(
    id,
    cheeseName,
    tastedAt,
    createdAt,
    creamery,
    origin,
    rind,
    rindOther,
    price,
    priceUnit,
    milk,
    milkOther,
    isGrassfed,
    isRaw,
    attributeOther,
    rating,
    texture,
    notes,
    verdict,
    Object.hashAllUnordered(
      flavors.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() => 'TastingNote($id, $cheeseName, ${formatDate(tastedAt)})';
}

const _unset = Object();

T? _pick<T>(Object? value, T? current) =>
    identical(value, _unset) ? current : value as T?;
