import 'package:flutter/foundation.dart';

import 'enums.dart';

/// A reference style in the cheese library ("Alpine", "Blue", ...). Bundled
/// read-only data (`assets/data/cheese_styles.json`, CHEESE-22); [id] is a
/// stable slug that notes link to and is never renamed after release.
@immutable
class CheeseStyle {
  const CheeseStyle({
    required this.id,
    required this.name,
    required this.examples,
    this.description = '',
    this.typicalMilk = const [MilkType.cow],
    this.typicalTexture = TextureLevel.semiFirm,
  });

  final String id;
  final String name;

  /// Comma list shown on library cards ("Comté, Gruyère, Appenzeller").
  final String examples;
  final String description;
  final List<MilkType> typicalMilk;
  final TextureLevel typicalTexture;

  factory CheeseStyle.fromJson(Map<String, dynamic> json) => CheeseStyle(
    id: json['id'] as String,
    name: json['name'] as String,
    examples: json['examples'] as String? ?? '',
    description: json['description'] as String? ?? '',
    typicalMilk: List.unmodifiable(
      (json['typicalMilk'] as List<dynamic>? ?? ['cow']).map(
        (m) => MilkType.values.byName(m as String),
      ),
    ),
    typicalTexture: TextureLevel.values.byName(
      json['typicalTexture'] as String? ?? 'semiFirm',
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'examples': examples,
    'description': description,
    'typicalMilk': typicalMilk.map((m) => m.name).toList(),
    'typicalTexture': typicalTexture.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheeseStyle &&
          other.id == id &&
          other.name == name &&
          other.examples == examples &&
          other.description == description &&
          listEquals(other.typicalMilk, typicalMilk) &&
          other.typicalTexture == typicalTexture;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    examples,
    description,
    Object.hashAll(typicalMilk),
    typicalTexture,
  );

  @override
  String toString() => 'CheeseStyle($id)';
}
