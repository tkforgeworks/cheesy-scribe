// Cheesy Scribe — data model (Dart classes)
// Plain classes with JSON round-tripping; see schema/ for JSON Schema files.
// Swap in freezed/json_serializable later if you prefer codegen.

enum MilkType { cow, goat, sheep, buffalo, other }

enum TextureLevel { runny, soft, semiSoft, semiFirm, firm, hard }

enum RindType { natural, bloomy, washed, waxed, leafWrapped, rindless, other }

/// The 16 spokes of the flavor wheel, in wheel order (12 o'clock, clockwise).
enum FlavorNote {
  salty, sweet, sharpTangy, lemon, grassy, herbal, caramel, nutty,
  earthy, moldyBlue, stinky, robust, butteryCreamy, milkyLactic,
  crumbly, crystalline,
}

extension FlavorNoteLabel on FlavorNote {
  String get label => switch (this) {
        FlavorNote.sharpTangy => 'SHARP/TANGY',
        FlavorNote.moldyBlue => 'MOLDY/BLUE',
        FlavorNote.butteryCreamy => 'BUTTERY/CREAMY',
        FlavorNote.milkyLactic => 'MILKY/LACTIC',
        _ => name.toUpperCase(),
      };
}

class TastingNote {
  const TastingNote({
    required this.id,
    required this.cheeseName,
    required this.tastedAt,
    this.creamery,
    this.origin,
    this.rind,
    this.rindOther,
    this.pricePerLb,
    this.milk = MilkType.cow,
    this.milkOther,
    this.isGrassfed = false,
    this.isRaw = false,
    this.rating = 0, // 0–5, whole stars
    this.texture = TextureLevel.semiSoft,
    this.notes = '',
    this.flavors = const {}, // FlavorNote -> 0..5; absent = 0
    this.cheeseStyleId, // -> CheeseStyle.id (library link)
    this.photoUrl,
  });

  final String id;
  final String cheeseName;
  final DateTime tastedAt;
  final String? creamery;
  final String? origin;
  final RindType? rind;
  final String? rindOther; // free text when rind == RindType.other
  final double? pricePerLb;
  final MilkType milk;
  final String? milkOther; // free text when milk == MilkType.other
  final bool isGrassfed;
  final bool isRaw;
  final int rating;
  final TextureLevel texture;
  final String notes;
  final Map<FlavorNote, int> flavors;
  final String? cheeseStyleId;
  final String? photoUrl;

  /// Top flavors for tag capsules (score >= 3, highest first, max 3).
  List<FlavorNote> get topFlavors {
    final entries = flavors.entries.where((e) => e.value >= 3).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).map((e) => e.key).toList();
  }

  factory TastingNote.fromJson(Map<String, dynamic> json) => TastingNote(
        id: json['id'] as String,
        cheeseName: json['cheeseName'] as String,
        tastedAt: DateTime.parse(json['tastedAt'] as String),
        creamery: json['creamery'] as String?,
        origin: json['origin'] as String?,
        rind: json['rind'] == null
            ? null
            : RindType.values.byName(json['rind'] as String),
        rindOther: json['rindOther'] as String?,
        pricePerLb: (json['pricePerLb'] as num?)?.toDouble(),
        milk: MilkType.values.byName(json['milk'] as String? ?? 'cow'),
        milkOther: json['milkOther'] as String?,
        isGrassfed: json['isGrassfed'] as bool? ?? false,
        isRaw: json['isRaw'] as bool? ?? false,
        rating: json['rating'] as int? ?? 0,
        texture: TextureLevel.values
            .byName(json['texture'] as String? ?? 'semiSoft'),
        notes: json['notes'] as String? ?? '',
        flavors: (json['flavors'] as Map<String, dynamic>? ?? {}).map(
            (k, v) => MapEntry(FlavorNote.values.byName(k), v as int)),
        cheeseStyleId: json['cheeseStyleId'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cheeseName': cheeseName,
        'tastedAt': tastedAt.toIso8601String(),
        if (creamery != null) 'creamery': creamery,
        if (origin != null) 'origin': origin,
        if (rind != null) 'rind': rind!.name,
        if (rindOther != null) 'rindOther': rindOther,
        if (pricePerLb != null) 'pricePerLb': pricePerLb,
        'milk': milk.name,
        if (milkOther != null) 'milkOther': milkOther,
        'isGrassfed': isGrassfed,
        'isRaw': isRaw,
        'rating': rating,
        'texture': texture.name,
        'notes': notes,
        'flavors': flavors.map((k, v) => MapEntry(k.name, v)),
        if (cheeseStyleId != null) 'cheeseStyleId': cheeseStyleId,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}

/// A reference style in the cheese library ("Alpine", "Blue", ...).
class CheeseStyle {
  const CheeseStyle({
    required this.id,
    required this.name,
    required this.examples, // "Comté, Gruyère, Appenzeller"
    this.description = '',
    this.typicalMilk = const [MilkType.cow],
    this.typicalTexture = TextureLevel.semiFirm,
  });

  final String id;
  final String name;
  final String examples;
  final String description;
  final List<MilkType> typicalMilk;
  final TextureLevel typicalTexture;

  factory CheeseStyle.fromJson(Map<String, dynamic> json) => CheeseStyle(
        id: json['id'] as String,
        name: json['name'] as String,
        examples: json['examples'] as String? ?? '',
        description: json['description'] as String? ?? '',
        typicalMilk: (json['typicalMilk'] as List<dynamic>? ?? ['cow'])
            .map((m) => MilkType.values.byName(m as String))
            .toList(),
        typicalTexture: TextureLevel.values
            .byName(json['typicalTexture'] as String? ?? 'semiFirm'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'examples': examples,
        'description': description,
        'typicalMilk': typicalMilk.map((m) => m.name).toList(),
        'typicalTexture': typicalTexture.name,
      };
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.memberSince,
    this.googleConnected = false,
    this.appleConnected = false,
    this.passwordAuth = true, // false => SSO-only; grey out "Change password"
  });

  final String id;
  final String displayName;
  final String email;
  final DateTime? memberSince;
  final bool googleConnected;
  final bool appleConnected;
  final bool passwordAuth;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        memberSince: json['memberSince'] == null
            ? null
            : DateTime.parse(json['memberSince'] as String),
        googleConnected: json['googleConnected'] as bool? ?? false,
        appleConnected: json['appleConnected'] as bool? ?? false,
        passwordAuth: json['passwordAuth'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        if (memberSince != null)
          'memberSince': memberSince!.toIso8601String(),
        'googleConnected': googleConnected,
        'appleConnected': appleConnected,
        'passwordAuth': passwordAuth,
      };
}

class AppSettings {
  const AppSettings({
    this.themeMode = 'system', // 'light' | 'dark' | 'system'
    this.units = 'usd_lb', // 'usd_lb' | 'eur_kg'
    this.weeklyReminder = true,
    this.cloudBackup = true,
  });

  final String themeMode;
  final String units;
  final bool weeklyReminder;
  final bool cloudBackup;

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: json['themeMode'] as String? ?? 'system',
        units: json['units'] as String? ?? 'usd_lb',
        weeklyReminder: json['weeklyReminder'] as bool? ?? true,
        cloudBackup: json['cloudBackup'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'units': units,
        'weeklyReminder': weeklyReminder,
        'cloudBackup': cloudBackup,
      };
}

/// Derived, never stored — computed from the notes list for Stats & insights.
class TastingStats {
  const TastingStats({
    required this.totalNotes,
    required this.averageRating,
    required this.flavorCounts, // flavor -> # of notes scoring it >= 3
    required this.milkBreakdown, // milk -> fraction 0..1
  });
  final int totalNotes;
  final double averageRating;
  final Map<FlavorNote, int> flavorCounts;
  final Map<MilkType, double> milkBreakdown;

  factory TastingStats.fromNotes(List<TastingNote> notes) {
    if (notes.isEmpty) {
      return const TastingStats(
          totalNotes: 0, averageRating: 0, flavorCounts: {}, milkBreakdown: {});
    }
    final flavorCounts = <FlavorNote, int>{};
    final milkCounts = <MilkType, int>{};
    var ratingSum = 0;
    for (final n in notes) {
      ratingSum += n.rating;
      milkCounts[n.milk] = (milkCounts[n.milk] ?? 0) + 1;
      n.flavors.forEach((f, v) {
        if (v >= 3) flavorCounts[f] = (flavorCounts[f] ?? 0) + 1;
      });
    }
    return TastingStats(
      totalNotes: notes.length,
      averageRating: ratingSum / notes.length,
      flavorCounts: flavorCounts,
      milkBreakdown:
          milkCounts.map((k, v) => MapEntry(k, v / notes.length)),
    );
  }
}
