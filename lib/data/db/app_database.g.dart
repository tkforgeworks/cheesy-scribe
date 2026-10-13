// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cheeseNameMeta = const VerificationMeta(
    'cheeseName',
  );
  @override
  late final GeneratedColumn<String> cheeseName = GeneratedColumn<String>(
    'cheese_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tastedAtMeta = const VerificationMeta(
    'tastedAt',
  );
  @override
  late final GeneratedColumn<String> tastedAt = GeneratedColumn<String>(
    'tasted_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creameryMeta = const VerificationMeta(
    'creamery',
  );
  @override
  late final GeneratedColumn<String> creamery = GeneratedColumn<String>(
    'creamery',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RindType?, String> rind =
      GeneratedColumn<String>(
        'rind',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RindType?>($NotesTable.$converterrindn);
  static const VerificationMeta _rindOtherMeta = const VerificationMeta(
    'rindOther',
  );
  @override
  late final GeneratedColumn<String> rindOther = GeneratedColumn<String>(
    'rind_other',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PriceUnit, String> priceUnit =
      GeneratedColumn<String>(
        'price_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PriceUnit>($NotesTable.$converterpriceUnit);
  @override
  late final GeneratedColumnWithTypeConverter<MilkType, String> milk =
      GeneratedColumn<String>(
        'milk',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MilkType>($NotesTable.$convertermilk);
  static const VerificationMeta _milkOtherMeta = const VerificationMeta(
    'milkOther',
  );
  @override
  late final GeneratedColumn<String> milkOther = GeneratedColumn<String>(
    'milk_other',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGrassfedMeta = const VerificationMeta(
    'isGrassfed',
  );
  @override
  late final GeneratedColumn<bool> isGrassfed = GeneratedColumn<bool>(
    'is_grassfed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_grassfed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRawMeta = const VerificationMeta('isRaw');
  @override
  late final GeneratedColumn<bool> isRaw = GeneratedColumn<bool>(
    'is_raw',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_raw" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attributeOtherMeta = const VerificationMeta(
    'attributeOther',
  );
  @override
  late final GeneratedColumn<String> attributeOther = GeneratedColumn<String>(
    'attribute_other',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TextureLevel, String> texture =
      GeneratedColumn<String>(
        'texture',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TextureLevel>($NotesTable.$convertertexture);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flSaltyMeta = const VerificationMeta(
    'flSalty',
  );
  @override
  late final GeneratedColumn<int> flSalty = GeneratedColumn<int>(
    'fl_salty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flSweetMeta = const VerificationMeta(
    'flSweet',
  );
  @override
  late final GeneratedColumn<int> flSweet = GeneratedColumn<int>(
    'fl_sweet',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flSharpTangyMeta = const VerificationMeta(
    'flSharpTangy',
  );
  @override
  late final GeneratedColumn<int> flSharpTangy = GeneratedColumn<int>(
    'fl_sharp_tangy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flLemonMeta = const VerificationMeta(
    'flLemon',
  );
  @override
  late final GeneratedColumn<int> flLemon = GeneratedColumn<int>(
    'fl_lemon',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flGrassyMeta = const VerificationMeta(
    'flGrassy',
  );
  @override
  late final GeneratedColumn<int> flGrassy = GeneratedColumn<int>(
    'fl_grassy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flHerbalMeta = const VerificationMeta(
    'flHerbal',
  );
  @override
  late final GeneratedColumn<int> flHerbal = GeneratedColumn<int>(
    'fl_herbal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flCaramelMeta = const VerificationMeta(
    'flCaramel',
  );
  @override
  late final GeneratedColumn<int> flCaramel = GeneratedColumn<int>(
    'fl_caramel',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flNuttyMeta = const VerificationMeta(
    'flNutty',
  );
  @override
  late final GeneratedColumn<int> flNutty = GeneratedColumn<int>(
    'fl_nutty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flEarthyMeta = const VerificationMeta(
    'flEarthy',
  );
  @override
  late final GeneratedColumn<int> flEarthy = GeneratedColumn<int>(
    'fl_earthy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flMoldyBlueMeta = const VerificationMeta(
    'flMoldyBlue',
  );
  @override
  late final GeneratedColumn<int> flMoldyBlue = GeneratedColumn<int>(
    'fl_moldy_blue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flStinkyMeta = const VerificationMeta(
    'flStinky',
  );
  @override
  late final GeneratedColumn<int> flStinky = GeneratedColumn<int>(
    'fl_stinky',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flRobustMeta = const VerificationMeta(
    'flRobust',
  );
  @override
  late final GeneratedColumn<int> flRobust = GeneratedColumn<int>(
    'fl_robust',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flButteryCreamyMeta = const VerificationMeta(
    'flButteryCreamy',
  );
  @override
  late final GeneratedColumn<int> flButteryCreamy = GeneratedColumn<int>(
    'fl_buttery_creamy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flMilkyLacticMeta = const VerificationMeta(
    'flMilkyLactic',
  );
  @override
  late final GeneratedColumn<int> flMilkyLactic = GeneratedColumn<int>(
    'fl_milky_lactic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flCrumblyMeta = const VerificationMeta(
    'flCrumbly',
  );
  @override
  late final GeneratedColumn<int> flCrumbly = GeneratedColumn<int>(
    'fl_crumbly',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _flCrystallineMeta = const VerificationMeta(
    'flCrystalline',
  );
  @override
  late final GeneratedColumn<int> flCrystalline = GeneratedColumn<int>(
    'fl_crystalline',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cheeseStyleIdMeta = const VerificationMeta(
    'cheeseStyleId',
  );
  @override
  late final GeneratedColumn<String> cheeseStyleId = GeneratedColumn<String>(
    'cheese_style_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    flSalty,
    flSweet,
    flSharpTangy,
    flLemon,
    flGrassy,
    flHerbal,
    flCaramel,
    flNutty,
    flEarthy,
    flMoldyBlue,
    flStinky,
    flRobust,
    flButteryCreamy,
    flMilkyLactic,
    flCrumbly,
    flCrystalline,
    cheeseStyleId,
    photoUrl,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cheese_name')) {
      context.handle(
        _cheeseNameMeta,
        cheeseName.isAcceptableOrUnknown(data['cheese_name']!, _cheeseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_cheeseNameMeta);
    }
    if (data.containsKey('tasted_at')) {
      context.handle(
        _tastedAtMeta,
        tastedAt.isAcceptableOrUnknown(data['tasted_at']!, _tastedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_tastedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('creamery')) {
      context.handle(
        _creameryMeta,
        creamery.isAcceptableOrUnknown(data['creamery']!, _creameryMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('rind_other')) {
      context.handle(
        _rindOtherMeta,
        rindOther.isAcceptableOrUnknown(data['rind_other']!, _rindOtherMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('milk_other')) {
      context.handle(
        _milkOtherMeta,
        milkOther.isAcceptableOrUnknown(data['milk_other']!, _milkOtherMeta),
      );
    }
    if (data.containsKey('is_grassfed')) {
      context.handle(
        _isGrassfedMeta,
        isGrassfed.isAcceptableOrUnknown(data['is_grassfed']!, _isGrassfedMeta),
      );
    }
    if (data.containsKey('is_raw')) {
      context.handle(
        _isRawMeta,
        isRaw.isAcceptableOrUnknown(data['is_raw']!, _isRawMeta),
      );
    }
    if (data.containsKey('attribute_other')) {
      context.handle(
        _attributeOtherMeta,
        attributeOther.isAcceptableOrUnknown(
          data['attribute_other']!,
          _attributeOtherMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    }
    if (data.containsKey('fl_salty')) {
      context.handle(
        _flSaltyMeta,
        flSalty.isAcceptableOrUnknown(data['fl_salty']!, _flSaltyMeta),
      );
    }
    if (data.containsKey('fl_sweet')) {
      context.handle(
        _flSweetMeta,
        flSweet.isAcceptableOrUnknown(data['fl_sweet']!, _flSweetMeta),
      );
    }
    if (data.containsKey('fl_sharp_tangy')) {
      context.handle(
        _flSharpTangyMeta,
        flSharpTangy.isAcceptableOrUnknown(
          data['fl_sharp_tangy']!,
          _flSharpTangyMeta,
        ),
      );
    }
    if (data.containsKey('fl_lemon')) {
      context.handle(
        _flLemonMeta,
        flLemon.isAcceptableOrUnknown(data['fl_lemon']!, _flLemonMeta),
      );
    }
    if (data.containsKey('fl_grassy')) {
      context.handle(
        _flGrassyMeta,
        flGrassy.isAcceptableOrUnknown(data['fl_grassy']!, _flGrassyMeta),
      );
    }
    if (data.containsKey('fl_herbal')) {
      context.handle(
        _flHerbalMeta,
        flHerbal.isAcceptableOrUnknown(data['fl_herbal']!, _flHerbalMeta),
      );
    }
    if (data.containsKey('fl_caramel')) {
      context.handle(
        _flCaramelMeta,
        flCaramel.isAcceptableOrUnknown(data['fl_caramel']!, _flCaramelMeta),
      );
    }
    if (data.containsKey('fl_nutty')) {
      context.handle(
        _flNuttyMeta,
        flNutty.isAcceptableOrUnknown(data['fl_nutty']!, _flNuttyMeta),
      );
    }
    if (data.containsKey('fl_earthy')) {
      context.handle(
        _flEarthyMeta,
        flEarthy.isAcceptableOrUnknown(data['fl_earthy']!, _flEarthyMeta),
      );
    }
    if (data.containsKey('fl_moldy_blue')) {
      context.handle(
        _flMoldyBlueMeta,
        flMoldyBlue.isAcceptableOrUnknown(
          data['fl_moldy_blue']!,
          _flMoldyBlueMeta,
        ),
      );
    }
    if (data.containsKey('fl_stinky')) {
      context.handle(
        _flStinkyMeta,
        flStinky.isAcceptableOrUnknown(data['fl_stinky']!, _flStinkyMeta),
      );
    }
    if (data.containsKey('fl_robust')) {
      context.handle(
        _flRobustMeta,
        flRobust.isAcceptableOrUnknown(data['fl_robust']!, _flRobustMeta),
      );
    }
    if (data.containsKey('fl_buttery_creamy')) {
      context.handle(
        _flButteryCreamyMeta,
        flButteryCreamy.isAcceptableOrUnknown(
          data['fl_buttery_creamy']!,
          _flButteryCreamyMeta,
        ),
      );
    }
    if (data.containsKey('fl_milky_lactic')) {
      context.handle(
        _flMilkyLacticMeta,
        flMilkyLactic.isAcceptableOrUnknown(
          data['fl_milky_lactic']!,
          _flMilkyLacticMeta,
        ),
      );
    }
    if (data.containsKey('fl_crumbly')) {
      context.handle(
        _flCrumblyMeta,
        flCrumbly.isAcceptableOrUnknown(data['fl_crumbly']!, _flCrumblyMeta),
      );
    }
    if (data.containsKey('fl_crystalline')) {
      context.handle(
        _flCrystallineMeta,
        flCrystalline.isAcceptableOrUnknown(
          data['fl_crystalline']!,
          _flCrystallineMeta,
        ),
      );
    }
    if (data.containsKey('cheese_style_id')) {
      context.handle(
        _cheeseStyleIdMeta,
        cheeseStyleId.isAcceptableOrUnknown(
          data['cheese_style_id']!,
          _cheeseStyleIdMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cheeseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheese_name'],
      )!,
      tastedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tasted_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      creamery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creamery'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      rind: $NotesTable.$converterrindn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rind'],
        ),
      ),
      rindOther: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rind_other'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      priceUnit: $NotesTable.$converterpriceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}price_unit'],
        )!,
      ),
      milk: $NotesTable.$convertermilk.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}milk'],
        )!,
      ),
      milkOther: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milk_other'],
      ),
      isGrassfed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_grassfed'],
      )!,
      isRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_raw'],
      )!,
      attributeOther: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribute_other'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      texture: $NotesTable.$convertertexture.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}texture'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      ),
      flSalty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_salty'],
      )!,
      flSweet: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_sweet'],
      )!,
      flSharpTangy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_sharp_tangy'],
      )!,
      flLemon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_lemon'],
      )!,
      flGrassy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_grassy'],
      )!,
      flHerbal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_herbal'],
      )!,
      flCaramel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_caramel'],
      )!,
      flNutty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_nutty'],
      )!,
      flEarthy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_earthy'],
      )!,
      flMoldyBlue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_moldy_blue'],
      )!,
      flStinky: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_stinky'],
      )!,
      flRobust: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_robust'],
      )!,
      flButteryCreamy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_buttery_creamy'],
      )!,
      flMilkyLactic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_milky_lactic'],
      )!,
      flCrumbly: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_crumbly'],
      )!,
      flCrystalline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fl_crystalline'],
      )!,
      cheeseStyleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheese_style_id'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RindType, String, String> $converterrind =
      const EnumNameConverter<RindType>(RindType.values);
  static JsonTypeConverter2<RindType?, String?, String?> $converterrindn =
      JsonTypeConverter2.asNullable($converterrind);
  static JsonTypeConverter2<PriceUnit, String, String> $converterpriceUnit =
      const EnumNameConverter<PriceUnit>(PriceUnit.values);
  static JsonTypeConverter2<MilkType, String, String> $convertermilk =
      const EnumNameConverter<MilkType>(MilkType.values);
  static JsonTypeConverter2<TextureLevel, String, String> $convertertexture =
      const EnumNameConverter<TextureLevel>(TextureLevel.values);
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String cheeseName;
  final String tastedAt;
  final String createdAt;
  final String? creamery;
  final String? origin;
  final RindType? rind;
  final String? rindOther;
  final double? price;
  final PriceUnit priceUnit;
  final MilkType milk;
  final String? milkOther;
  final bool isGrassfed;
  final bool isRaw;
  final String? attributeOther;
  final int rating;
  final TextureLevel texture;
  final String notes;
  final String? verdict;
  final int flSalty;
  final int flSweet;
  final int flSharpTangy;
  final int flLemon;
  final int flGrassy;
  final int flHerbal;
  final int flCaramel;
  final int flNutty;
  final int flEarthy;
  final int flMoldyBlue;
  final int flStinky;
  final int flRobust;
  final int flButteryCreamy;
  final int flMilkyLactic;
  final int flCrumbly;
  final int flCrystalline;
  final String? cheeseStyleId;
  final String? photoUrl;

  /// Lower-cased, diacritic-stripped haystack of every searchable field
  /// (see [searchTextFor]); the search box matches against this.
  final String searchText;
  const NoteRow({
    required this.id,
    required this.cheeseName,
    required this.tastedAt,
    required this.createdAt,
    this.creamery,
    this.origin,
    this.rind,
    this.rindOther,
    this.price,
    required this.priceUnit,
    required this.milk,
    this.milkOther,
    required this.isGrassfed,
    required this.isRaw,
    this.attributeOther,
    required this.rating,
    required this.texture,
    required this.notes,
    this.verdict,
    required this.flSalty,
    required this.flSweet,
    required this.flSharpTangy,
    required this.flLemon,
    required this.flGrassy,
    required this.flHerbal,
    required this.flCaramel,
    required this.flNutty,
    required this.flEarthy,
    required this.flMoldyBlue,
    required this.flStinky,
    required this.flRobust,
    required this.flButteryCreamy,
    required this.flMilkyLactic,
    required this.flCrumbly,
    required this.flCrystalline,
    this.cheeseStyleId,
    this.photoUrl,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cheese_name'] = Variable<String>(cheeseName);
    map['tasted_at'] = Variable<String>(tastedAt);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || creamery != null) {
      map['creamery'] = Variable<String>(creamery);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || rind != null) {
      map['rind'] = Variable<String>($NotesTable.$converterrindn.toSql(rind));
    }
    if (!nullToAbsent || rindOther != null) {
      map['rind_other'] = Variable<String>(rindOther);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    {
      map['price_unit'] = Variable<String>(
        $NotesTable.$converterpriceUnit.toSql(priceUnit),
      );
    }
    {
      map['milk'] = Variable<String>($NotesTable.$convertermilk.toSql(milk));
    }
    if (!nullToAbsent || milkOther != null) {
      map['milk_other'] = Variable<String>(milkOther);
    }
    map['is_grassfed'] = Variable<bool>(isGrassfed);
    map['is_raw'] = Variable<bool>(isRaw);
    if (!nullToAbsent || attributeOther != null) {
      map['attribute_other'] = Variable<String>(attributeOther);
    }
    map['rating'] = Variable<int>(rating);
    {
      map['texture'] = Variable<String>(
        $NotesTable.$convertertexture.toSql(texture),
      );
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || verdict != null) {
      map['verdict'] = Variable<String>(verdict);
    }
    map['fl_salty'] = Variable<int>(flSalty);
    map['fl_sweet'] = Variable<int>(flSweet);
    map['fl_sharp_tangy'] = Variable<int>(flSharpTangy);
    map['fl_lemon'] = Variable<int>(flLemon);
    map['fl_grassy'] = Variable<int>(flGrassy);
    map['fl_herbal'] = Variable<int>(flHerbal);
    map['fl_caramel'] = Variable<int>(flCaramel);
    map['fl_nutty'] = Variable<int>(flNutty);
    map['fl_earthy'] = Variable<int>(flEarthy);
    map['fl_moldy_blue'] = Variable<int>(flMoldyBlue);
    map['fl_stinky'] = Variable<int>(flStinky);
    map['fl_robust'] = Variable<int>(flRobust);
    map['fl_buttery_creamy'] = Variable<int>(flButteryCreamy);
    map['fl_milky_lactic'] = Variable<int>(flMilkyLactic);
    map['fl_crumbly'] = Variable<int>(flCrumbly);
    map['fl_crystalline'] = Variable<int>(flCrystalline);
    if (!nullToAbsent || cheeseStyleId != null) {
      map['cheese_style_id'] = Variable<String>(cheeseStyleId);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      cheeseName: Value(cheeseName),
      tastedAt: Value(tastedAt),
      createdAt: Value(createdAt),
      creamery: creamery == null && nullToAbsent
          ? const Value.absent()
          : Value(creamery),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      rind: rind == null && nullToAbsent ? const Value.absent() : Value(rind),
      rindOther: rindOther == null && nullToAbsent
          ? const Value.absent()
          : Value(rindOther),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      priceUnit: Value(priceUnit),
      milk: Value(milk),
      milkOther: milkOther == null && nullToAbsent
          ? const Value.absent()
          : Value(milkOther),
      isGrassfed: Value(isGrassfed),
      isRaw: Value(isRaw),
      attributeOther: attributeOther == null && nullToAbsent
          ? const Value.absent()
          : Value(attributeOther),
      rating: Value(rating),
      texture: Value(texture),
      notes: Value(notes),
      verdict: verdict == null && nullToAbsent
          ? const Value.absent()
          : Value(verdict),
      flSalty: Value(flSalty),
      flSweet: Value(flSweet),
      flSharpTangy: Value(flSharpTangy),
      flLemon: Value(flLemon),
      flGrassy: Value(flGrassy),
      flHerbal: Value(flHerbal),
      flCaramel: Value(flCaramel),
      flNutty: Value(flNutty),
      flEarthy: Value(flEarthy),
      flMoldyBlue: Value(flMoldyBlue),
      flStinky: Value(flStinky),
      flRobust: Value(flRobust),
      flButteryCreamy: Value(flButteryCreamy),
      flMilkyLactic: Value(flMilkyLactic),
      flCrumbly: Value(flCrumbly),
      flCrystalline: Value(flCrystalline),
      cheeseStyleId: cheeseStyleId == null && nullToAbsent
          ? const Value.absent()
          : Value(cheeseStyleId),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      searchText: Value(searchText),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      cheeseName: serializer.fromJson<String>(json['cheeseName']),
      tastedAt: serializer.fromJson<String>(json['tastedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      creamery: serializer.fromJson<String?>(json['creamery']),
      origin: serializer.fromJson<String?>(json['origin']),
      rind: $NotesTable.$converterrindn.fromJson(
        serializer.fromJson<String?>(json['rind']),
      ),
      rindOther: serializer.fromJson<String?>(json['rindOther']),
      price: serializer.fromJson<double?>(json['price']),
      priceUnit: $NotesTable.$converterpriceUnit.fromJson(
        serializer.fromJson<String>(json['priceUnit']),
      ),
      milk: $NotesTable.$convertermilk.fromJson(
        serializer.fromJson<String>(json['milk']),
      ),
      milkOther: serializer.fromJson<String?>(json['milkOther']),
      isGrassfed: serializer.fromJson<bool>(json['isGrassfed']),
      isRaw: serializer.fromJson<bool>(json['isRaw']),
      attributeOther: serializer.fromJson<String?>(json['attributeOther']),
      rating: serializer.fromJson<int>(json['rating']),
      texture: $NotesTable.$convertertexture.fromJson(
        serializer.fromJson<String>(json['texture']),
      ),
      notes: serializer.fromJson<String>(json['notes']),
      verdict: serializer.fromJson<String?>(json['verdict']),
      flSalty: serializer.fromJson<int>(json['flSalty']),
      flSweet: serializer.fromJson<int>(json['flSweet']),
      flSharpTangy: serializer.fromJson<int>(json['flSharpTangy']),
      flLemon: serializer.fromJson<int>(json['flLemon']),
      flGrassy: serializer.fromJson<int>(json['flGrassy']),
      flHerbal: serializer.fromJson<int>(json['flHerbal']),
      flCaramel: serializer.fromJson<int>(json['flCaramel']),
      flNutty: serializer.fromJson<int>(json['flNutty']),
      flEarthy: serializer.fromJson<int>(json['flEarthy']),
      flMoldyBlue: serializer.fromJson<int>(json['flMoldyBlue']),
      flStinky: serializer.fromJson<int>(json['flStinky']),
      flRobust: serializer.fromJson<int>(json['flRobust']),
      flButteryCreamy: serializer.fromJson<int>(json['flButteryCreamy']),
      flMilkyLactic: serializer.fromJson<int>(json['flMilkyLactic']),
      flCrumbly: serializer.fromJson<int>(json['flCrumbly']),
      flCrystalline: serializer.fromJson<int>(json['flCrystalline']),
      cheeseStyleId: serializer.fromJson<String?>(json['cheeseStyleId']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cheeseName': serializer.toJson<String>(cheeseName),
      'tastedAt': serializer.toJson<String>(tastedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'creamery': serializer.toJson<String?>(creamery),
      'origin': serializer.toJson<String?>(origin),
      'rind': serializer.toJson<String?>(
        $NotesTable.$converterrindn.toJson(rind),
      ),
      'rindOther': serializer.toJson<String?>(rindOther),
      'price': serializer.toJson<double?>(price),
      'priceUnit': serializer.toJson<String>(
        $NotesTable.$converterpriceUnit.toJson(priceUnit),
      ),
      'milk': serializer.toJson<String>(
        $NotesTable.$convertermilk.toJson(milk),
      ),
      'milkOther': serializer.toJson<String?>(milkOther),
      'isGrassfed': serializer.toJson<bool>(isGrassfed),
      'isRaw': serializer.toJson<bool>(isRaw),
      'attributeOther': serializer.toJson<String?>(attributeOther),
      'rating': serializer.toJson<int>(rating),
      'texture': serializer.toJson<String>(
        $NotesTable.$convertertexture.toJson(texture),
      ),
      'notes': serializer.toJson<String>(notes),
      'verdict': serializer.toJson<String?>(verdict),
      'flSalty': serializer.toJson<int>(flSalty),
      'flSweet': serializer.toJson<int>(flSweet),
      'flSharpTangy': serializer.toJson<int>(flSharpTangy),
      'flLemon': serializer.toJson<int>(flLemon),
      'flGrassy': serializer.toJson<int>(flGrassy),
      'flHerbal': serializer.toJson<int>(flHerbal),
      'flCaramel': serializer.toJson<int>(flCaramel),
      'flNutty': serializer.toJson<int>(flNutty),
      'flEarthy': serializer.toJson<int>(flEarthy),
      'flMoldyBlue': serializer.toJson<int>(flMoldyBlue),
      'flStinky': serializer.toJson<int>(flStinky),
      'flRobust': serializer.toJson<int>(flRobust),
      'flButteryCreamy': serializer.toJson<int>(flButteryCreamy),
      'flMilkyLactic': serializer.toJson<int>(flMilkyLactic),
      'flCrumbly': serializer.toJson<int>(flCrumbly),
      'flCrystalline': serializer.toJson<int>(flCrystalline),
      'cheeseStyleId': serializer.toJson<String?>(cheeseStyleId),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  NoteRow copyWith({
    String? id,
    String? cheeseName,
    String? tastedAt,
    String? createdAt,
    Value<String?> creamery = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    Value<RindType?> rind = const Value.absent(),
    Value<String?> rindOther = const Value.absent(),
    Value<double?> price = const Value.absent(),
    PriceUnit? priceUnit,
    MilkType? milk,
    Value<String?> milkOther = const Value.absent(),
    bool? isGrassfed,
    bool? isRaw,
    Value<String?> attributeOther = const Value.absent(),
    int? rating,
    TextureLevel? texture,
    String? notes,
    Value<String?> verdict = const Value.absent(),
    int? flSalty,
    int? flSweet,
    int? flSharpTangy,
    int? flLemon,
    int? flGrassy,
    int? flHerbal,
    int? flCaramel,
    int? flNutty,
    int? flEarthy,
    int? flMoldyBlue,
    int? flStinky,
    int? flRobust,
    int? flButteryCreamy,
    int? flMilkyLactic,
    int? flCrumbly,
    int? flCrystalline,
    Value<String?> cheeseStyleId = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    String? searchText,
  }) => NoteRow(
    id: id ?? this.id,
    cheeseName: cheeseName ?? this.cheeseName,
    tastedAt: tastedAt ?? this.tastedAt,
    createdAt: createdAt ?? this.createdAt,
    creamery: creamery.present ? creamery.value : this.creamery,
    origin: origin.present ? origin.value : this.origin,
    rind: rind.present ? rind.value : this.rind,
    rindOther: rindOther.present ? rindOther.value : this.rindOther,
    price: price.present ? price.value : this.price,
    priceUnit: priceUnit ?? this.priceUnit,
    milk: milk ?? this.milk,
    milkOther: milkOther.present ? milkOther.value : this.milkOther,
    isGrassfed: isGrassfed ?? this.isGrassfed,
    isRaw: isRaw ?? this.isRaw,
    attributeOther: attributeOther.present
        ? attributeOther.value
        : this.attributeOther,
    rating: rating ?? this.rating,
    texture: texture ?? this.texture,
    notes: notes ?? this.notes,
    verdict: verdict.present ? verdict.value : this.verdict,
    flSalty: flSalty ?? this.flSalty,
    flSweet: flSweet ?? this.flSweet,
    flSharpTangy: flSharpTangy ?? this.flSharpTangy,
    flLemon: flLemon ?? this.flLemon,
    flGrassy: flGrassy ?? this.flGrassy,
    flHerbal: flHerbal ?? this.flHerbal,
    flCaramel: flCaramel ?? this.flCaramel,
    flNutty: flNutty ?? this.flNutty,
    flEarthy: flEarthy ?? this.flEarthy,
    flMoldyBlue: flMoldyBlue ?? this.flMoldyBlue,
    flStinky: flStinky ?? this.flStinky,
    flRobust: flRobust ?? this.flRobust,
    flButteryCreamy: flButteryCreamy ?? this.flButteryCreamy,
    flMilkyLactic: flMilkyLactic ?? this.flMilkyLactic,
    flCrumbly: flCrumbly ?? this.flCrumbly,
    flCrystalline: flCrystalline ?? this.flCrystalline,
    cheeseStyleId: cheeseStyleId.present
        ? cheeseStyleId.value
        : this.cheeseStyleId,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    searchText: searchText ?? this.searchText,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      cheeseName: data.cheeseName.present
          ? data.cheeseName.value
          : this.cheeseName,
      tastedAt: data.tastedAt.present ? data.tastedAt.value : this.tastedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      creamery: data.creamery.present ? data.creamery.value : this.creamery,
      origin: data.origin.present ? data.origin.value : this.origin,
      rind: data.rind.present ? data.rind.value : this.rind,
      rindOther: data.rindOther.present ? data.rindOther.value : this.rindOther,
      price: data.price.present ? data.price.value : this.price,
      priceUnit: data.priceUnit.present ? data.priceUnit.value : this.priceUnit,
      milk: data.milk.present ? data.milk.value : this.milk,
      milkOther: data.milkOther.present ? data.milkOther.value : this.milkOther,
      isGrassfed: data.isGrassfed.present
          ? data.isGrassfed.value
          : this.isGrassfed,
      isRaw: data.isRaw.present ? data.isRaw.value : this.isRaw,
      attributeOther: data.attributeOther.present
          ? data.attributeOther.value
          : this.attributeOther,
      rating: data.rating.present ? data.rating.value : this.rating,
      texture: data.texture.present ? data.texture.value : this.texture,
      notes: data.notes.present ? data.notes.value : this.notes,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      flSalty: data.flSalty.present ? data.flSalty.value : this.flSalty,
      flSweet: data.flSweet.present ? data.flSweet.value : this.flSweet,
      flSharpTangy: data.flSharpTangy.present
          ? data.flSharpTangy.value
          : this.flSharpTangy,
      flLemon: data.flLemon.present ? data.flLemon.value : this.flLemon,
      flGrassy: data.flGrassy.present ? data.flGrassy.value : this.flGrassy,
      flHerbal: data.flHerbal.present ? data.flHerbal.value : this.flHerbal,
      flCaramel: data.flCaramel.present ? data.flCaramel.value : this.flCaramel,
      flNutty: data.flNutty.present ? data.flNutty.value : this.flNutty,
      flEarthy: data.flEarthy.present ? data.flEarthy.value : this.flEarthy,
      flMoldyBlue: data.flMoldyBlue.present
          ? data.flMoldyBlue.value
          : this.flMoldyBlue,
      flStinky: data.flStinky.present ? data.flStinky.value : this.flStinky,
      flRobust: data.flRobust.present ? data.flRobust.value : this.flRobust,
      flButteryCreamy: data.flButteryCreamy.present
          ? data.flButteryCreamy.value
          : this.flButteryCreamy,
      flMilkyLactic: data.flMilkyLactic.present
          ? data.flMilkyLactic.value
          : this.flMilkyLactic,
      flCrumbly: data.flCrumbly.present ? data.flCrumbly.value : this.flCrumbly,
      flCrystalline: data.flCrystalline.present
          ? data.flCrystalline.value
          : this.flCrystalline,
      cheeseStyleId: data.cheeseStyleId.present
          ? data.cheeseStyleId.value
          : this.cheeseStyleId,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('cheeseName: $cheeseName, ')
          ..write('tastedAt: $tastedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('creamery: $creamery, ')
          ..write('origin: $origin, ')
          ..write('rind: $rind, ')
          ..write('rindOther: $rindOther, ')
          ..write('price: $price, ')
          ..write('priceUnit: $priceUnit, ')
          ..write('milk: $milk, ')
          ..write('milkOther: $milkOther, ')
          ..write('isGrassfed: $isGrassfed, ')
          ..write('isRaw: $isRaw, ')
          ..write('attributeOther: $attributeOther, ')
          ..write('rating: $rating, ')
          ..write('texture: $texture, ')
          ..write('notes: $notes, ')
          ..write('verdict: $verdict, ')
          ..write('flSalty: $flSalty, ')
          ..write('flSweet: $flSweet, ')
          ..write('flSharpTangy: $flSharpTangy, ')
          ..write('flLemon: $flLemon, ')
          ..write('flGrassy: $flGrassy, ')
          ..write('flHerbal: $flHerbal, ')
          ..write('flCaramel: $flCaramel, ')
          ..write('flNutty: $flNutty, ')
          ..write('flEarthy: $flEarthy, ')
          ..write('flMoldyBlue: $flMoldyBlue, ')
          ..write('flStinky: $flStinky, ')
          ..write('flRobust: $flRobust, ')
          ..write('flButteryCreamy: $flButteryCreamy, ')
          ..write('flMilkyLactic: $flMilkyLactic, ')
          ..write('flCrumbly: $flCrumbly, ')
          ..write('flCrystalline: $flCrystalline, ')
          ..write('cheeseStyleId: $cheeseStyleId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    flSalty,
    flSweet,
    flSharpTangy,
    flLemon,
    flGrassy,
    flHerbal,
    flCaramel,
    flNutty,
    flEarthy,
    flMoldyBlue,
    flStinky,
    flRobust,
    flButteryCreamy,
    flMilkyLactic,
    flCrumbly,
    flCrystalline,
    cheeseStyleId,
    photoUrl,
    searchText,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.cheeseName == this.cheeseName &&
          other.tastedAt == this.tastedAt &&
          other.createdAt == this.createdAt &&
          other.creamery == this.creamery &&
          other.origin == this.origin &&
          other.rind == this.rind &&
          other.rindOther == this.rindOther &&
          other.price == this.price &&
          other.priceUnit == this.priceUnit &&
          other.milk == this.milk &&
          other.milkOther == this.milkOther &&
          other.isGrassfed == this.isGrassfed &&
          other.isRaw == this.isRaw &&
          other.attributeOther == this.attributeOther &&
          other.rating == this.rating &&
          other.texture == this.texture &&
          other.notes == this.notes &&
          other.verdict == this.verdict &&
          other.flSalty == this.flSalty &&
          other.flSweet == this.flSweet &&
          other.flSharpTangy == this.flSharpTangy &&
          other.flLemon == this.flLemon &&
          other.flGrassy == this.flGrassy &&
          other.flHerbal == this.flHerbal &&
          other.flCaramel == this.flCaramel &&
          other.flNutty == this.flNutty &&
          other.flEarthy == this.flEarthy &&
          other.flMoldyBlue == this.flMoldyBlue &&
          other.flStinky == this.flStinky &&
          other.flRobust == this.flRobust &&
          other.flButteryCreamy == this.flButteryCreamy &&
          other.flMilkyLactic == this.flMilkyLactic &&
          other.flCrumbly == this.flCrumbly &&
          other.flCrystalline == this.flCrystalline &&
          other.cheeseStyleId == this.cheeseStyleId &&
          other.photoUrl == this.photoUrl &&
          other.searchText == this.searchText);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> cheeseName;
  final Value<String> tastedAt;
  final Value<String> createdAt;
  final Value<String?> creamery;
  final Value<String?> origin;
  final Value<RindType?> rind;
  final Value<String?> rindOther;
  final Value<double?> price;
  final Value<PriceUnit> priceUnit;
  final Value<MilkType> milk;
  final Value<String?> milkOther;
  final Value<bool> isGrassfed;
  final Value<bool> isRaw;
  final Value<String?> attributeOther;
  final Value<int> rating;
  final Value<TextureLevel> texture;
  final Value<String> notes;
  final Value<String?> verdict;
  final Value<int> flSalty;
  final Value<int> flSweet;
  final Value<int> flSharpTangy;
  final Value<int> flLemon;
  final Value<int> flGrassy;
  final Value<int> flHerbal;
  final Value<int> flCaramel;
  final Value<int> flNutty;
  final Value<int> flEarthy;
  final Value<int> flMoldyBlue;
  final Value<int> flStinky;
  final Value<int> flRobust;
  final Value<int> flButteryCreamy;
  final Value<int> flMilkyLactic;
  final Value<int> flCrumbly;
  final Value<int> flCrystalline;
  final Value<String?> cheeseStyleId;
  final Value<String?> photoUrl;
  final Value<String> searchText;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.cheeseName = const Value.absent(),
    this.tastedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.creamery = const Value.absent(),
    this.origin = const Value.absent(),
    this.rind = const Value.absent(),
    this.rindOther = const Value.absent(),
    this.price = const Value.absent(),
    this.priceUnit = const Value.absent(),
    this.milk = const Value.absent(),
    this.milkOther = const Value.absent(),
    this.isGrassfed = const Value.absent(),
    this.isRaw = const Value.absent(),
    this.attributeOther = const Value.absent(),
    this.rating = const Value.absent(),
    this.texture = const Value.absent(),
    this.notes = const Value.absent(),
    this.verdict = const Value.absent(),
    this.flSalty = const Value.absent(),
    this.flSweet = const Value.absent(),
    this.flSharpTangy = const Value.absent(),
    this.flLemon = const Value.absent(),
    this.flGrassy = const Value.absent(),
    this.flHerbal = const Value.absent(),
    this.flCaramel = const Value.absent(),
    this.flNutty = const Value.absent(),
    this.flEarthy = const Value.absent(),
    this.flMoldyBlue = const Value.absent(),
    this.flStinky = const Value.absent(),
    this.flRobust = const Value.absent(),
    this.flButteryCreamy = const Value.absent(),
    this.flMilkyLactic = const Value.absent(),
    this.flCrumbly = const Value.absent(),
    this.flCrystalline = const Value.absent(),
    this.cheeseStyleId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String cheeseName,
    required String tastedAt,
    required String createdAt,
    this.creamery = const Value.absent(),
    this.origin = const Value.absent(),
    this.rind = const Value.absent(),
    this.rindOther = const Value.absent(),
    this.price = const Value.absent(),
    required PriceUnit priceUnit,
    required MilkType milk,
    this.milkOther = const Value.absent(),
    this.isGrassfed = const Value.absent(),
    this.isRaw = const Value.absent(),
    this.attributeOther = const Value.absent(),
    this.rating = const Value.absent(),
    required TextureLevel texture,
    this.notes = const Value.absent(),
    this.verdict = const Value.absent(),
    this.flSalty = const Value.absent(),
    this.flSweet = const Value.absent(),
    this.flSharpTangy = const Value.absent(),
    this.flLemon = const Value.absent(),
    this.flGrassy = const Value.absent(),
    this.flHerbal = const Value.absent(),
    this.flCaramel = const Value.absent(),
    this.flNutty = const Value.absent(),
    this.flEarthy = const Value.absent(),
    this.flMoldyBlue = const Value.absent(),
    this.flStinky = const Value.absent(),
    this.flRobust = const Value.absent(),
    this.flButteryCreamy = const Value.absent(),
    this.flMilkyLactic = const Value.absent(),
    this.flCrumbly = const Value.absent(),
    this.flCrystalline = const Value.absent(),
    this.cheeseStyleId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required String searchText,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cheeseName = Value(cheeseName),
       tastedAt = Value(tastedAt),
       createdAt = Value(createdAt),
       priceUnit = Value(priceUnit),
       milk = Value(milk),
       texture = Value(texture),
       searchText = Value(searchText);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? cheeseName,
    Expression<String>? tastedAt,
    Expression<String>? createdAt,
    Expression<String>? creamery,
    Expression<String>? origin,
    Expression<String>? rind,
    Expression<String>? rindOther,
    Expression<double>? price,
    Expression<String>? priceUnit,
    Expression<String>? milk,
    Expression<String>? milkOther,
    Expression<bool>? isGrassfed,
    Expression<bool>? isRaw,
    Expression<String>? attributeOther,
    Expression<int>? rating,
    Expression<String>? texture,
    Expression<String>? notes,
    Expression<String>? verdict,
    Expression<int>? flSalty,
    Expression<int>? flSweet,
    Expression<int>? flSharpTangy,
    Expression<int>? flLemon,
    Expression<int>? flGrassy,
    Expression<int>? flHerbal,
    Expression<int>? flCaramel,
    Expression<int>? flNutty,
    Expression<int>? flEarthy,
    Expression<int>? flMoldyBlue,
    Expression<int>? flStinky,
    Expression<int>? flRobust,
    Expression<int>? flButteryCreamy,
    Expression<int>? flMilkyLactic,
    Expression<int>? flCrumbly,
    Expression<int>? flCrystalline,
    Expression<String>? cheeseStyleId,
    Expression<String>? photoUrl,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cheeseName != null) 'cheese_name': cheeseName,
      if (tastedAt != null) 'tasted_at': tastedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (creamery != null) 'creamery': creamery,
      if (origin != null) 'origin': origin,
      if (rind != null) 'rind': rind,
      if (rindOther != null) 'rind_other': rindOther,
      if (price != null) 'price': price,
      if (priceUnit != null) 'price_unit': priceUnit,
      if (milk != null) 'milk': milk,
      if (milkOther != null) 'milk_other': milkOther,
      if (isGrassfed != null) 'is_grassfed': isGrassfed,
      if (isRaw != null) 'is_raw': isRaw,
      if (attributeOther != null) 'attribute_other': attributeOther,
      if (rating != null) 'rating': rating,
      if (texture != null) 'texture': texture,
      if (notes != null) 'notes': notes,
      if (verdict != null) 'verdict': verdict,
      if (flSalty != null) 'fl_salty': flSalty,
      if (flSweet != null) 'fl_sweet': flSweet,
      if (flSharpTangy != null) 'fl_sharp_tangy': flSharpTangy,
      if (flLemon != null) 'fl_lemon': flLemon,
      if (flGrassy != null) 'fl_grassy': flGrassy,
      if (flHerbal != null) 'fl_herbal': flHerbal,
      if (flCaramel != null) 'fl_caramel': flCaramel,
      if (flNutty != null) 'fl_nutty': flNutty,
      if (flEarthy != null) 'fl_earthy': flEarthy,
      if (flMoldyBlue != null) 'fl_moldy_blue': flMoldyBlue,
      if (flStinky != null) 'fl_stinky': flStinky,
      if (flRobust != null) 'fl_robust': flRobust,
      if (flButteryCreamy != null) 'fl_buttery_creamy': flButteryCreamy,
      if (flMilkyLactic != null) 'fl_milky_lactic': flMilkyLactic,
      if (flCrumbly != null) 'fl_crumbly': flCrumbly,
      if (flCrystalline != null) 'fl_crystalline': flCrystalline,
      if (cheeseStyleId != null) 'cheese_style_id': cheeseStyleId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? cheeseName,
    Value<String>? tastedAt,
    Value<String>? createdAt,
    Value<String?>? creamery,
    Value<String?>? origin,
    Value<RindType?>? rind,
    Value<String?>? rindOther,
    Value<double?>? price,
    Value<PriceUnit>? priceUnit,
    Value<MilkType>? milk,
    Value<String?>? milkOther,
    Value<bool>? isGrassfed,
    Value<bool>? isRaw,
    Value<String?>? attributeOther,
    Value<int>? rating,
    Value<TextureLevel>? texture,
    Value<String>? notes,
    Value<String?>? verdict,
    Value<int>? flSalty,
    Value<int>? flSweet,
    Value<int>? flSharpTangy,
    Value<int>? flLemon,
    Value<int>? flGrassy,
    Value<int>? flHerbal,
    Value<int>? flCaramel,
    Value<int>? flNutty,
    Value<int>? flEarthy,
    Value<int>? flMoldyBlue,
    Value<int>? flStinky,
    Value<int>? flRobust,
    Value<int>? flButteryCreamy,
    Value<int>? flMilkyLactic,
    Value<int>? flCrumbly,
    Value<int>? flCrystalline,
    Value<String?>? cheeseStyleId,
    Value<String?>? photoUrl,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      cheeseName: cheeseName ?? this.cheeseName,
      tastedAt: tastedAt ?? this.tastedAt,
      createdAt: createdAt ?? this.createdAt,
      creamery: creamery ?? this.creamery,
      origin: origin ?? this.origin,
      rind: rind ?? this.rind,
      rindOther: rindOther ?? this.rindOther,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      milk: milk ?? this.milk,
      milkOther: milkOther ?? this.milkOther,
      isGrassfed: isGrassfed ?? this.isGrassfed,
      isRaw: isRaw ?? this.isRaw,
      attributeOther: attributeOther ?? this.attributeOther,
      rating: rating ?? this.rating,
      texture: texture ?? this.texture,
      notes: notes ?? this.notes,
      verdict: verdict ?? this.verdict,
      flSalty: flSalty ?? this.flSalty,
      flSweet: flSweet ?? this.flSweet,
      flSharpTangy: flSharpTangy ?? this.flSharpTangy,
      flLemon: flLemon ?? this.flLemon,
      flGrassy: flGrassy ?? this.flGrassy,
      flHerbal: flHerbal ?? this.flHerbal,
      flCaramel: flCaramel ?? this.flCaramel,
      flNutty: flNutty ?? this.flNutty,
      flEarthy: flEarthy ?? this.flEarthy,
      flMoldyBlue: flMoldyBlue ?? this.flMoldyBlue,
      flStinky: flStinky ?? this.flStinky,
      flRobust: flRobust ?? this.flRobust,
      flButteryCreamy: flButteryCreamy ?? this.flButteryCreamy,
      flMilkyLactic: flMilkyLactic ?? this.flMilkyLactic,
      flCrumbly: flCrumbly ?? this.flCrumbly,
      flCrystalline: flCrystalline ?? this.flCrystalline,
      cheeseStyleId: cheeseStyleId ?? this.cheeseStyleId,
      photoUrl: photoUrl ?? this.photoUrl,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cheeseName.present) {
      map['cheese_name'] = Variable<String>(cheeseName.value);
    }
    if (tastedAt.present) {
      map['tasted_at'] = Variable<String>(tastedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (creamery.present) {
      map['creamery'] = Variable<String>(creamery.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rind.present) {
      map['rind'] = Variable<String>(
        $NotesTable.$converterrindn.toSql(rind.value),
      );
    }
    if (rindOther.present) {
      map['rind_other'] = Variable<String>(rindOther.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (priceUnit.present) {
      map['price_unit'] = Variable<String>(
        $NotesTable.$converterpriceUnit.toSql(priceUnit.value),
      );
    }
    if (milk.present) {
      map['milk'] = Variable<String>(
        $NotesTable.$convertermilk.toSql(milk.value),
      );
    }
    if (milkOther.present) {
      map['milk_other'] = Variable<String>(milkOther.value);
    }
    if (isGrassfed.present) {
      map['is_grassfed'] = Variable<bool>(isGrassfed.value);
    }
    if (isRaw.present) {
      map['is_raw'] = Variable<bool>(isRaw.value);
    }
    if (attributeOther.present) {
      map['attribute_other'] = Variable<String>(attributeOther.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (texture.present) {
      map['texture'] = Variable<String>(
        $NotesTable.$convertertexture.toSql(texture.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (flSalty.present) {
      map['fl_salty'] = Variable<int>(flSalty.value);
    }
    if (flSweet.present) {
      map['fl_sweet'] = Variable<int>(flSweet.value);
    }
    if (flSharpTangy.present) {
      map['fl_sharp_tangy'] = Variable<int>(flSharpTangy.value);
    }
    if (flLemon.present) {
      map['fl_lemon'] = Variable<int>(flLemon.value);
    }
    if (flGrassy.present) {
      map['fl_grassy'] = Variable<int>(flGrassy.value);
    }
    if (flHerbal.present) {
      map['fl_herbal'] = Variable<int>(flHerbal.value);
    }
    if (flCaramel.present) {
      map['fl_caramel'] = Variable<int>(flCaramel.value);
    }
    if (flNutty.present) {
      map['fl_nutty'] = Variable<int>(flNutty.value);
    }
    if (flEarthy.present) {
      map['fl_earthy'] = Variable<int>(flEarthy.value);
    }
    if (flMoldyBlue.present) {
      map['fl_moldy_blue'] = Variable<int>(flMoldyBlue.value);
    }
    if (flStinky.present) {
      map['fl_stinky'] = Variable<int>(flStinky.value);
    }
    if (flRobust.present) {
      map['fl_robust'] = Variable<int>(flRobust.value);
    }
    if (flButteryCreamy.present) {
      map['fl_buttery_creamy'] = Variable<int>(flButteryCreamy.value);
    }
    if (flMilkyLactic.present) {
      map['fl_milky_lactic'] = Variable<int>(flMilkyLactic.value);
    }
    if (flCrumbly.present) {
      map['fl_crumbly'] = Variable<int>(flCrumbly.value);
    }
    if (flCrystalline.present) {
      map['fl_crystalline'] = Variable<int>(flCrystalline.value);
    }
    if (cheeseStyleId.present) {
      map['cheese_style_id'] = Variable<String>(cheeseStyleId.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('cheeseName: $cheeseName, ')
          ..write('tastedAt: $tastedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('creamery: $creamery, ')
          ..write('origin: $origin, ')
          ..write('rind: $rind, ')
          ..write('rindOther: $rindOther, ')
          ..write('price: $price, ')
          ..write('priceUnit: $priceUnit, ')
          ..write('milk: $milk, ')
          ..write('milkOther: $milkOther, ')
          ..write('isGrassfed: $isGrassfed, ')
          ..write('isRaw: $isRaw, ')
          ..write('attributeOther: $attributeOther, ')
          ..write('rating: $rating, ')
          ..write('texture: $texture, ')
          ..write('notes: $notes, ')
          ..write('verdict: $verdict, ')
          ..write('flSalty: $flSalty, ')
          ..write('flSweet: $flSweet, ')
          ..write('flSharpTangy: $flSharpTangy, ')
          ..write('flLemon: $flLemon, ')
          ..write('flGrassy: $flGrassy, ')
          ..write('flHerbal: $flHerbal, ')
          ..write('flCaramel: $flCaramel, ')
          ..write('flNutty: $flNutty, ')
          ..write('flEarthy: $flEarthy, ')
          ..write('flMoldyBlue: $flMoldyBlue, ')
          ..write('flStinky: $flStinky, ')
          ..write('flRobust: $flRobust, ')
          ..write('flButteryCreamy: $flButteryCreamy, ')
          ..write('flMilkyLactic: $flMilkyLactic, ')
          ..write('flCrumbly: $flCrumbly, ')
          ..write('flCrystalline: $flCrystalline, ')
          ..write('cheeseStyleId: $cheeseStyleId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<String> searchedAt = GeneratedColumn<String>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [term, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {term};
  @override
  RecentSearchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearchRow(
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearchRow extends DataClass implements Insertable<RecentSearchRow> {
  final String term;
  final String searchedAt;
  const RecentSearchRow({required this.term, required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['term'] = Variable<String>(term);
    map['searched_at'] = Variable<String>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      term: Value(term),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearchRow(
      term: serializer.fromJson<String>(json['term']),
      searchedAt: serializer.fromJson<String>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'term': serializer.toJson<String>(term),
      'searchedAt': serializer.toJson<String>(searchedAt),
    };
  }

  RecentSearchRow copyWith({String? term, String? searchedAt}) =>
      RecentSearchRow(
        term: term ?? this.term,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearchRow copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearchRow(
      term: data.term.present ? data.term.value : this.term,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchRow(')
          ..write('term: $term, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(term, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearchRow &&
          other.term == this.term &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearchRow> {
  final Value<String> term;
  final Value<String> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.term = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String term,
    required String searchedAt,
    this.rowid = const Value.absent(),
  }) : term = Value(term),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearchRow> custom({
    Expression<String>? term,
    Expression<String>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (term != null) 'term': term,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<String>? term,
    Value<String>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      term: term ?? this.term,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<String>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('term: $term, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index notesByDate = Index(
    'notes_by_date',
    'CREATE INDEX notes_by_date ON notes (tasted_at, created_at)',
  );
  late final Index notesByStyle = Index(
    'notes_by_style',
    'CREATE INDEX notes_by_style ON notes (cheese_style_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notes,
    recentSearches,
    settings,
    notesByDate,
    notesByStyle,
  ];
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String cheeseName,
  required String tastedAt,
  required String createdAt,
  Value<String?> creamery,
  Value<String?> origin,
  Value<RindType?> rind,
  Value<String?> rindOther,
  Value<double?> price,
  required PriceUnit priceUnit,
  required MilkType milk,
  Value<String?> milkOther,
  Value<bool> isGrassfed,
  Value<bool> isRaw,
  Value<String?> attributeOther,
  Value<int> rating,
  required TextureLevel texture,
  Value<String> notes,
  Value<String?> verdict,
  Value<int> flSalty,
  Value<int> flSweet,
  Value<int> flSharpTangy,
  Value<int> flLemon,
  Value<int> flGrassy,
  Value<int> flHerbal,
  Value<int> flCaramel,
  Value<int> flNutty,
  Value<int> flEarthy,
  Value<int> flMoldyBlue,
  Value<int> flStinky,
  Value<int> flRobust,
  Value<int> flButteryCreamy,
  Value<int> flMilkyLactic,
  Value<int> flCrumbly,
  Value<int> flCrystalline,
  Value<String?> cheeseStyleId,
  Value<String?> photoUrl,
  required String searchText,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> cheeseName,
  Value<String> tastedAt,
  Value<String> createdAt,
  Value<String?> creamery,
  Value<String?> origin,
  Value<RindType?> rind,
  Value<String?> rindOther,
  Value<double?> price,
  Value<PriceUnit> priceUnit,
  Value<MilkType> milk,
  Value<String?> milkOther,
  Value<bool> isGrassfed,
  Value<bool> isRaw,
  Value<String?> attributeOther,
  Value<int> rating,
  Value<TextureLevel> texture,
  Value<String> notes,
  Value<String?> verdict,
  Value<int> flSalty,
  Value<int> flSweet,
  Value<int> flSharpTangy,
  Value<int> flLemon,
  Value<int> flGrassy,
  Value<int> flHerbal,
  Value<int> flCaramel,
  Value<int> flNutty,
  Value<int> flEarthy,
  Value<int> flMoldyBlue,
  Value<int> flStinky,
  Value<int> flRobust,
  Value<int> flButteryCreamy,
  Value<int> flMilkyLactic,
  Value<int> flCrumbly,
  Value<int> flCrystalline,
  Value<String?> cheeseStyleId,
  Value<String?> photoUrl,
  Value<String> searchText,
  Value<int> rowid,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cheeseName => $composableBuilder(
    column: $table.cheeseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tastedAt => $composableBuilder(
    column: $table.tastedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creamery => $composableBuilder(
    column: $table.creamery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RindType?, RindType, String> get rind =>
      $composableBuilder(
        column: $table.rind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get rindOther => $composableBuilder(
    column: $table.rindOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PriceUnit, PriceUnit, String> get priceUnit =>
      $composableBuilder(
        column: $table.priceUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MilkType, MilkType, String> get milk =>
      $composableBuilder(
        column: $table.milk,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get milkOther => $composableBuilder(
    column: $table.milkOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGrassfed => $composableBuilder(
    column: $table.isGrassfed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRaw => $composableBuilder(
    column: $table.isRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributeOther => $composableBuilder(
    column: $table.attributeOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TextureLevel, TextureLevel, String>
  get texture => $composableBuilder(
    column: $table.texture,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flSalty => $composableBuilder(
    column: $table.flSalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flSweet => $composableBuilder(
    column: $table.flSweet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flSharpTangy => $composableBuilder(
    column: $table.flSharpTangy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flLemon => $composableBuilder(
    column: $table.flLemon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flGrassy => $composableBuilder(
    column: $table.flGrassy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flHerbal => $composableBuilder(
    column: $table.flHerbal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flCaramel => $composableBuilder(
    column: $table.flCaramel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flNutty => $composableBuilder(
    column: $table.flNutty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flEarthy => $composableBuilder(
    column: $table.flEarthy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flMoldyBlue => $composableBuilder(
    column: $table.flMoldyBlue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flStinky => $composableBuilder(
    column: $table.flStinky,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flRobust => $composableBuilder(
    column: $table.flRobust,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flButteryCreamy => $composableBuilder(
    column: $table.flButteryCreamy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flMilkyLactic => $composableBuilder(
    column: $table.flMilkyLactic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flCrumbly => $composableBuilder(
    column: $table.flCrumbly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flCrystalline => $composableBuilder(
    column: $table.flCrystalline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cheeseStyleId => $composableBuilder(
    column: $table.cheeseStyleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cheeseName => $composableBuilder(
    column: $table.cheeseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tastedAt => $composableBuilder(
    column: $table.tastedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creamery => $composableBuilder(
    column: $table.creamery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rind => $composableBuilder(
    column: $table.rind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rindOther => $composableBuilder(
    column: $table.rindOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceUnit => $composableBuilder(
    column: $table.priceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milk => $composableBuilder(
    column: $table.milk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milkOther => $composableBuilder(
    column: $table.milkOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGrassfed => $composableBuilder(
    column: $table.isGrassfed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRaw => $composableBuilder(
    column: $table.isRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributeOther => $composableBuilder(
    column: $table.attributeOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texture => $composableBuilder(
    column: $table.texture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flSalty => $composableBuilder(
    column: $table.flSalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flSweet => $composableBuilder(
    column: $table.flSweet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flSharpTangy => $composableBuilder(
    column: $table.flSharpTangy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flLemon => $composableBuilder(
    column: $table.flLemon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flGrassy => $composableBuilder(
    column: $table.flGrassy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flHerbal => $composableBuilder(
    column: $table.flHerbal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flCaramel => $composableBuilder(
    column: $table.flCaramel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flNutty => $composableBuilder(
    column: $table.flNutty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flEarthy => $composableBuilder(
    column: $table.flEarthy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flMoldyBlue => $composableBuilder(
    column: $table.flMoldyBlue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flStinky => $composableBuilder(
    column: $table.flStinky,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flRobust => $composableBuilder(
    column: $table.flRobust,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flButteryCreamy => $composableBuilder(
    column: $table.flButteryCreamy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flMilkyLactic => $composableBuilder(
    column: $table.flMilkyLactic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flCrumbly => $composableBuilder(
    column: $table.flCrumbly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flCrystalline => $composableBuilder(
    column: $table.flCrystalline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cheeseStyleId => $composableBuilder(
    column: $table.cheeseStyleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cheeseName => $composableBuilder(
    column: $table.cheeseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tastedAt =>
      $composableBuilder(column: $table.tastedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get creamery =>
      $composableBuilder(column: $table.creamery, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RindType?, String> get rind =>
      $composableBuilder(column: $table.rind, builder: (column) => column);

  GeneratedColumn<String> get rindOther =>
      $composableBuilder(column: $table.rindOther, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PriceUnit, String> get priceUnit =>
      $composableBuilder(column: $table.priceUnit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MilkType, String> get milk =>
      $composableBuilder(column: $table.milk, builder: (column) => column);

  GeneratedColumn<String> get milkOther =>
      $composableBuilder(column: $table.milkOther, builder: (column) => column);

  GeneratedColumn<bool> get isGrassfed => $composableBuilder(
    column: $table.isGrassfed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRaw =>
      $composableBuilder(column: $table.isRaw, builder: (column) => column);

  GeneratedColumn<String> get attributeOther => $composableBuilder(
    column: $table.attributeOther,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TextureLevel, String> get texture =>
      $composableBuilder(column: $table.texture, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<int> get flSalty =>
      $composableBuilder(column: $table.flSalty, builder: (column) => column);

  GeneratedColumn<int> get flSweet =>
      $composableBuilder(column: $table.flSweet, builder: (column) => column);

  GeneratedColumn<int> get flSharpTangy => $composableBuilder(
    column: $table.flSharpTangy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flLemon =>
      $composableBuilder(column: $table.flLemon, builder: (column) => column);

  GeneratedColumn<int> get flGrassy =>
      $composableBuilder(column: $table.flGrassy, builder: (column) => column);

  GeneratedColumn<int> get flHerbal =>
      $composableBuilder(column: $table.flHerbal, builder: (column) => column);

  GeneratedColumn<int> get flCaramel =>
      $composableBuilder(column: $table.flCaramel, builder: (column) => column);

  GeneratedColumn<int> get flNutty =>
      $composableBuilder(column: $table.flNutty, builder: (column) => column);

  GeneratedColumn<int> get flEarthy =>
      $composableBuilder(column: $table.flEarthy, builder: (column) => column);

  GeneratedColumn<int> get flMoldyBlue => $composableBuilder(
    column: $table.flMoldyBlue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flStinky =>
      $composableBuilder(column: $table.flStinky, builder: (column) => column);

  GeneratedColumn<int> get flRobust =>
      $composableBuilder(column: $table.flRobust, builder: (column) => column);

  GeneratedColumn<int> get flButteryCreamy => $composableBuilder(
    column: $table.flButteryCreamy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flMilkyLactic => $composableBuilder(
    column: $table.flMilkyLactic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flCrumbly =>
      $composableBuilder(column: $table.flCrumbly, builder: (column) => column);

  GeneratedColumn<int> get flCrystalline => $composableBuilder(
    column: $table.flCrystalline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cheeseStyleId => $composableBuilder(
    column: $table.cheeseStyleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cheeseName = const Value.absent(),
                Value<String> tastedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> creamery = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<RindType?> rind = const Value.absent(),
                Value<String?> rindOther = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<PriceUnit> priceUnit = const Value.absent(),
                Value<MilkType> milk = const Value.absent(),
                Value<String?> milkOther = const Value.absent(),
                Value<bool> isGrassfed = const Value.absent(),
                Value<bool> isRaw = const Value.absent(),
                Value<String?> attributeOther = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<TextureLevel> texture = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<int> flSalty = const Value.absent(),
                Value<int> flSweet = const Value.absent(),
                Value<int> flSharpTangy = const Value.absent(),
                Value<int> flLemon = const Value.absent(),
                Value<int> flGrassy = const Value.absent(),
                Value<int> flHerbal = const Value.absent(),
                Value<int> flCaramel = const Value.absent(),
                Value<int> flNutty = const Value.absent(),
                Value<int> flEarthy = const Value.absent(),
                Value<int> flMoldyBlue = const Value.absent(),
                Value<int> flStinky = const Value.absent(),
                Value<int> flRobust = const Value.absent(),
                Value<int> flButteryCreamy = const Value.absent(),
                Value<int> flMilkyLactic = const Value.absent(),
                Value<int> flCrumbly = const Value.absent(),
                Value<int> flCrystalline = const Value.absent(),
                Value<String?> cheeseStyleId = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                cheeseName: cheeseName,
                tastedAt: tastedAt,
                createdAt: createdAt,
                creamery: creamery,
                origin: origin,
                rind: rind,
                rindOther: rindOther,
                price: price,
                priceUnit: priceUnit,
                milk: milk,
                milkOther: milkOther,
                isGrassfed: isGrassfed,
                isRaw: isRaw,
                attributeOther: attributeOther,
                rating: rating,
                texture: texture,
                notes: notes,
                verdict: verdict,
                flSalty: flSalty,
                flSweet: flSweet,
                flSharpTangy: flSharpTangy,
                flLemon: flLemon,
                flGrassy: flGrassy,
                flHerbal: flHerbal,
                flCaramel: flCaramel,
                flNutty: flNutty,
                flEarthy: flEarthy,
                flMoldyBlue: flMoldyBlue,
                flStinky: flStinky,
                flRobust: flRobust,
                flButteryCreamy: flButteryCreamy,
                flMilkyLactic: flMilkyLactic,
                flCrumbly: flCrumbly,
                flCrystalline: flCrystalline,
                cheeseStyleId: cheeseStyleId,
                photoUrl: photoUrl,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cheeseName,
                required String tastedAt,
                required String createdAt,
                Value<String?> creamery = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<RindType?> rind = const Value.absent(),
                Value<String?> rindOther = const Value.absent(),
                Value<double?> price = const Value.absent(),
                required PriceUnit priceUnit,
                required MilkType milk,
                Value<String?> milkOther = const Value.absent(),
                Value<bool> isGrassfed = const Value.absent(),
                Value<bool> isRaw = const Value.absent(),
                Value<String?> attributeOther = const Value.absent(),
                Value<int> rating = const Value.absent(),
                required TextureLevel texture,
                Value<String> notes = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<int> flSalty = const Value.absent(),
                Value<int> flSweet = const Value.absent(),
                Value<int> flSharpTangy = const Value.absent(),
                Value<int> flLemon = const Value.absent(),
                Value<int> flGrassy = const Value.absent(),
                Value<int> flHerbal = const Value.absent(),
                Value<int> flCaramel = const Value.absent(),
                Value<int> flNutty = const Value.absent(),
                Value<int> flEarthy = const Value.absent(),
                Value<int> flMoldyBlue = const Value.absent(),
                Value<int> flStinky = const Value.absent(),
                Value<int> flRobust = const Value.absent(),
                Value<int> flButteryCreamy = const Value.absent(),
                Value<int> flMilkyLactic = const Value.absent(),
                Value<int> flCrumbly = const Value.absent(),
                Value<int> flCrystalline = const Value.absent(),
                Value<String?> cheeseStyleId = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                required String searchText,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                cheeseName: cheeseName,
                tastedAt: tastedAt,
                createdAt: createdAt,
                creamery: creamery,
                origin: origin,
                rind: rind,
                rindOther: rindOther,
                price: price,
                priceUnit: priceUnit,
                milk: milk,
                milkOther: milkOther,
                isGrassfed: isGrassfed,
                isRaw: isRaw,
                attributeOther: attributeOther,
                rating: rating,
                texture: texture,
                notes: notes,
                verdict: verdict,
                flSalty: flSalty,
                flSweet: flSweet,
                flSharpTangy: flSharpTangy,
                flLemon: flLemon,
                flGrassy: flGrassy,
                flHerbal: flHerbal,
                flCaramel: flCaramel,
                flNutty: flNutty,
                flEarthy: flEarthy,
                flMoldyBlue: flMoldyBlue,
                flStinky: flStinky,
                flRobust: flRobust,
                flButteryCreamy: flButteryCreamy,
                flMilkyLactic: flMilkyLactic,
                flCrumbly: flCrumbly,
                flCrystalline: flCrystalline,
                cheeseStyleId: cheeseStyleId,
                photoUrl: photoUrl,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  BaseReferences<_$AppDatabase, $NotesTable, NoteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required String term,
      required String searchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<String> term,
      Value<String> searchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearchRow,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearchRow,
            BaseReferences<
              _$AppDatabase,
              $RecentSearchesTable,
              RecentSearchRow
            >,
          ),
          RecentSearchRow,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> term = const Value.absent(),
                Value<String> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                term: term,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String term,
                required String searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                term: term,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearchRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearchRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearchRow,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearchRow,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearchRow>,
      ),
      RecentSearchRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
