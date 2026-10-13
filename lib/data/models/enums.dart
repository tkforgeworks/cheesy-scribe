/// Closed vocabularies shared by the notes, the library and settings.
/// JSON and the database store the enum `name`; never reorder or rename a
/// value once released — add new ones at the end.
library;

enum MilkType { cow, goat, sheep, buffalo, other }

extension MilkTypeLabel on MilkType {
  /// Chip / capsule label ("Cow", "Buffalo").
  String get label => switch (this) {
    MilkType.cow => 'Cow',
    MilkType.goat => 'Goat',
    MilkType.sheep => 'Sheep',
    MilkType.buffalo => 'Buffalo',
    MilkType.other => 'Other',
  };
}

/// The six stops of the texture meter, runny → hard.
enum TextureLevel { runny, soft, semiSoft, semiFirm, firm, hard }

extension TextureLevelLabel on TextureLevel {
  /// Mono meter label ("SEMI-SOFT").
  String get label => switch (this) {
    TextureLevel.runny => 'RUNNY',
    TextureLevel.soft => 'SOFT',
    TextureLevel.semiSoft => 'SEMI-SOFT',
    TextureLevel.semiFirm => 'SEMI-FIRM',
    TextureLevel.firm => 'FIRM',
    TextureLevel.hard => 'HARD',
  };
}

enum RindType { natural, bloomy, washed, waxed, leafWrapped, rindless, other }

extension RindTypeLabel on RindType {
  String get label => switch (this) {
    RindType.natural => 'Natural',
    RindType.bloomy => 'Bloomy',
    RindType.washed => 'Washed',
    RindType.waxed => 'Waxed',
    RindType.leafWrapped => 'Leaf-wrapped',
    RindType.rindless => 'Rindless',
    RindType.other => 'Other',
  };
}

/// The 16 spokes of the flavor wheel, in wheel order (12 o'clock, clockwise).
enum FlavorNote {
  salty,
  sweet,
  sharpTangy,
  lemon,
  grassy,
  herbal,
  caramel,
  nutty,
  earthy,
  moldyBlue,
  stinky,
  robust,
  butteryCreamy,
  milkyLactic,
  crumbly,
  crystalline,
}

extension FlavorNoteLabel on FlavorNote {
  /// Mono uppercase label as printed on the wheel and capsules.
  String get label => switch (this) {
    FlavorNote.sharpTangy => 'SHARP/TANGY',
    FlavorNote.moldyBlue => 'MOLDY/BLUE',
    FlavorNote.butteryCreamy => 'BUTTERY/CREAMY',
    FlavorNote.milkyLactic => 'MILKY/LACTIC',
    _ => name.toUpperCase(),
  };
}

/// Price unit captured with each note at entry time (decision B5: no
/// offline currency conversion, so the setting only changes the default).
enum PriceUnit { usdPerLb, eurPerKg }

extension PriceUnitLabel on PriceUnit {
  /// Mono meta label ("$/LB").
  String get label => switch (this) {
    PriceUnit.usdPerLb => r'$/LB',
    PriceUnit.eurPerKg => '€/KG',
  };

  /// Currency symbol for the price itself ("$28").
  String get symbol => switch (this) {
    PriceUnit.usdPerLb => r'$',
    PriceUnit.eurPerKg => '€',
  };

  /// Weight part of the label ("LB", "KG").
  String get perUnit => label.split('/').last;

  /// "$28/LB", "€12.50/KG" — whole numbers drop the decimals.
  String format(double price) {
    final n = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '$symbol$n/$perUnit';
  }
}
