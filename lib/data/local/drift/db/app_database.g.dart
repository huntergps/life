// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    nameEs,
    nameEn,
    iconName,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEsMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String slug;
  final String nameEs;
  final String nameEn;
  final String? iconName;
  final int sortOrder;
  const Category({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.nameEn,
    this.iconName,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['name_es'] = Variable<String>(nameEs);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      slug: Value(slug),
      nameEs: Value(nameEs),
      nameEn: Value(nameEn),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'nameEs': serializer.toJson<String>(nameEs),
      'nameEn': serializer.toJson<String>(nameEn),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({
    int? id,
    String? slug,
    String? nameEs,
    String? nameEn,
    Value<String?> iconName = const Value.absent(),
    int? sortOrder,
  }) => Category(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    nameEs: nameEs ?? this.nameEs,
    nameEn: nameEn ?? this.nameEn,
    iconName: iconName.present ? iconName.value : this.iconName,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, slug, nameEs, nameEn, iconName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameEs == this.nameEs &&
          other.nameEn == this.nameEn &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> nameEs;
  final Value<String> nameEn;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String nameEs,
    required String nameEn,
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : slug = Value(slug),
       nameEs = Value(nameEs),
       nameEn = Value(nameEn);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? nameEs,
    Expression<String>? nameEn,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameEs != null) 'name_es': nameEs,
      if (nameEn != null) 'name_en': nameEn,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? nameEs,
    Value<String>? nameEn,
    Value<String?>? iconName,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameEs: nameEs ?? this.nameEs,
      nameEn: nameEn ?? this.nameEn,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $IslandsTable extends Islands with TableInfo<$IslandsTable, Island> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IslandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaKm2Meta = const VerificationMeta(
    'areaKm2',
  );
  @override
  late final GeneratedColumn<double> areaKm2 = GeneratedColumn<double>(
    'area_km2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
    'area_ha',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parkIdMeta = const VerificationMeta('parkId');
  @override
  late final GeneratedColumn<String> parkId = GeneratedColumn<String>(
    'park_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _islandTypeMeta = const VerificationMeta(
    'islandType',
  );
  @override
  late final GeneratedColumn<String> islandType = GeneratedColumn<String>(
    'island_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPopulatedMeta = const VerificationMeta(
    'isPopulated',
  );
  @override
  late final GeneratedColumn<bool> isPopulated = GeneratedColumn<bool>(
    'is_populated',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_populated" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameEs,
    nameEn,
    latitude,
    longitude,
    areaKm2,
    areaHa,
    descriptionEs,
    descriptionEn,
    parkId,
    islandType,
    classification,
    isPopulated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'islands';
  @override
  VerificationContext validateIntegrity(
    Insertable<Island> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEsMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('area_km2')) {
      context.handle(
        _areaKm2Meta,
        areaKm2.isAcceptableOrUnknown(data['area_km2']!, _areaKm2Meta),
      );
    }
    if (data.containsKey('area_ha')) {
      context.handle(
        _areaHaMeta,
        areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta),
      );
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    if (data.containsKey('park_id')) {
      context.handle(
        _parkIdMeta,
        parkId.isAcceptableOrUnknown(data['park_id']!, _parkIdMeta),
      );
    }
    if (data.containsKey('island_type')) {
      context.handle(
        _islandTypeMeta,
        islandType.isAcceptableOrUnknown(data['island_type']!, _islandTypeMeta),
      );
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    }
    if (data.containsKey('is_populated')) {
      context.handle(
        _isPopulatedMeta,
        isPopulated.isAcceptableOrUnknown(
          data['is_populated']!,
          _isPopulatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Island map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Island(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      areaKm2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_km2'],
      ),
      areaHa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_ha'],
      ),
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
      parkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}park_id'],
      ),
      islandType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}island_type'],
      ),
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      ),
      isPopulated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_populated'],
      ),
    );
  }

  @override
  $IslandsTable createAlias(String alias) {
    return $IslandsTable(attachedDatabase, alias);
  }
}

class Island extends DataClass implements Insertable<Island> {
  final int id;
  final String nameEs;
  final String nameEn;
  final double? latitude;
  final double? longitude;
  final double? areaKm2;
  final double? areaHa;
  final String? descriptionEs;
  final String? descriptionEn;
  final String? parkId;
  final String? islandType;
  final String? classification;
  final bool? isPopulated;
  const Island({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    this.latitude,
    this.longitude,
    this.areaKm2,
    this.areaHa,
    this.descriptionEs,
    this.descriptionEn,
    this.parkId,
    this.islandType,
    this.classification,
    this.isPopulated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_es'] = Variable<String>(nameEs);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || areaKm2 != null) {
      map['area_km2'] = Variable<double>(areaKm2);
    }
    if (!nullToAbsent || areaHa != null) {
      map['area_ha'] = Variable<double>(areaHa);
    }
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    if (!nullToAbsent || parkId != null) {
      map['park_id'] = Variable<String>(parkId);
    }
    if (!nullToAbsent || islandType != null) {
      map['island_type'] = Variable<String>(islandType);
    }
    if (!nullToAbsent || classification != null) {
      map['classification'] = Variable<String>(classification);
    }
    if (!nullToAbsent || isPopulated != null) {
      map['is_populated'] = Variable<bool>(isPopulated);
    }
    return map;
  }

  IslandsCompanion toCompanion(bool nullToAbsent) {
    return IslandsCompanion(
      id: Value(id),
      nameEs: Value(nameEs),
      nameEn: Value(nameEn),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      areaKm2: areaKm2 == null && nullToAbsent
          ? const Value.absent()
          : Value(areaKm2),
      areaHa: areaHa == null && nullToAbsent
          ? const Value.absent()
          : Value(areaHa),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
      parkId: parkId == null && nullToAbsent
          ? const Value.absent()
          : Value(parkId),
      islandType: islandType == null && nullToAbsent
          ? const Value.absent()
          : Value(islandType),
      classification: classification == null && nullToAbsent
          ? const Value.absent()
          : Value(classification),
      isPopulated: isPopulated == null && nullToAbsent
          ? const Value.absent()
          : Value(isPopulated),
    );
  }

  factory Island.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Island(
      id: serializer.fromJson<int>(json['id']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      areaKm2: serializer.fromJson<double?>(json['areaKm2']),
      areaHa: serializer.fromJson<double?>(json['areaHa']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
      parkId: serializer.fromJson<String?>(json['parkId']),
      islandType: serializer.fromJson<String?>(json['islandType']),
      classification: serializer.fromJson<String?>(json['classification']),
      isPopulated: serializer.fromJson<bool?>(json['isPopulated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameEs': serializer.toJson<String>(nameEs),
      'nameEn': serializer.toJson<String>(nameEn),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'areaKm2': serializer.toJson<double?>(areaKm2),
      'areaHa': serializer.toJson<double?>(areaHa),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
      'parkId': serializer.toJson<String?>(parkId),
      'islandType': serializer.toJson<String?>(islandType),
      'classification': serializer.toJson<String?>(classification),
      'isPopulated': serializer.toJson<bool?>(isPopulated),
    };
  }

  Island copyWith({
    int? id,
    String? nameEs,
    String? nameEn,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> areaKm2 = const Value.absent(),
    Value<double?> areaHa = const Value.absent(),
    Value<String?> descriptionEs = const Value.absent(),
    Value<String?> descriptionEn = const Value.absent(),
    Value<String?> parkId = const Value.absent(),
    Value<String?> islandType = const Value.absent(),
    Value<String?> classification = const Value.absent(),
    Value<bool?> isPopulated = const Value.absent(),
  }) => Island(
    id: id ?? this.id,
    nameEs: nameEs ?? this.nameEs,
    nameEn: nameEn ?? this.nameEn,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    areaKm2: areaKm2.present ? areaKm2.value : this.areaKm2,
    areaHa: areaHa.present ? areaHa.value : this.areaHa,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
    parkId: parkId.present ? parkId.value : this.parkId,
    islandType: islandType.present ? islandType.value : this.islandType,
    classification: classification.present
        ? classification.value
        : this.classification,
    isPopulated: isPopulated.present ? isPopulated.value : this.isPopulated,
  );
  Island copyWithCompanion(IslandsCompanion data) {
    return Island(
      id: data.id.present ? data.id.value : this.id,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      areaKm2: data.areaKm2.present ? data.areaKm2.value : this.areaKm2,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      parkId: data.parkId.present ? data.parkId.value : this.parkId,
      islandType: data.islandType.present
          ? data.islandType.value
          : this.islandType,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      isPopulated: data.isPopulated.present
          ? data.isPopulated.value
          : this.isPopulated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Island(')
          ..write('id: $id, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('areaKm2: $areaKm2, ')
          ..write('areaHa: $areaHa, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('parkId: $parkId, ')
          ..write('islandType: $islandType, ')
          ..write('classification: $classification, ')
          ..write('isPopulated: $isPopulated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameEs,
    nameEn,
    latitude,
    longitude,
    areaKm2,
    areaHa,
    descriptionEs,
    descriptionEn,
    parkId,
    islandType,
    classification,
    isPopulated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Island &&
          other.id == this.id &&
          other.nameEs == this.nameEs &&
          other.nameEn == this.nameEn &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.areaKm2 == this.areaKm2 &&
          other.areaHa == this.areaHa &&
          other.descriptionEs == this.descriptionEs &&
          other.descriptionEn == this.descriptionEn &&
          other.parkId == this.parkId &&
          other.islandType == this.islandType &&
          other.classification == this.classification &&
          other.isPopulated == this.isPopulated);
}

class IslandsCompanion extends UpdateCompanion<Island> {
  final Value<int> id;
  final Value<String> nameEs;
  final Value<String> nameEn;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> areaKm2;
  final Value<double?> areaHa;
  final Value<String?> descriptionEs;
  final Value<String?> descriptionEn;
  final Value<String?> parkId;
  final Value<String?> islandType;
  final Value<String?> classification;
  final Value<bool?> isPopulated;
  const IslandsCompanion({
    this.id = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.areaKm2 = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.parkId = const Value.absent(),
    this.islandType = const Value.absent(),
    this.classification = const Value.absent(),
    this.isPopulated = const Value.absent(),
  });
  IslandsCompanion.insert({
    this.id = const Value.absent(),
    required String nameEs,
    required String nameEn,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.areaKm2 = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.parkId = const Value.absent(),
    this.islandType = const Value.absent(),
    this.classification = const Value.absent(),
    this.isPopulated = const Value.absent(),
  }) : nameEs = Value(nameEs),
       nameEn = Value(nameEn);
  static Insertable<Island> custom({
    Expression<int>? id,
    Expression<String>? nameEs,
    Expression<String>? nameEn,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? areaKm2,
    Expression<double>? areaHa,
    Expression<String>? descriptionEs,
    Expression<String>? descriptionEn,
    Expression<String>? parkId,
    Expression<String>? islandType,
    Expression<String>? classification,
    Expression<bool>? isPopulated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEs != null) 'name_es': nameEs,
      if (nameEn != null) 'name_en': nameEn,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (areaKm2 != null) 'area_km2': areaKm2,
      if (areaHa != null) 'area_ha': areaHa,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (parkId != null) 'park_id': parkId,
      if (islandType != null) 'island_type': islandType,
      if (classification != null) 'classification': classification,
      if (isPopulated != null) 'is_populated': isPopulated,
    });
  }

  IslandsCompanion copyWith({
    Value<int>? id,
    Value<String>? nameEs,
    Value<String>? nameEn,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? areaKm2,
    Value<double?>? areaHa,
    Value<String?>? descriptionEs,
    Value<String?>? descriptionEn,
    Value<String?>? parkId,
    Value<String?>? islandType,
    Value<String?>? classification,
    Value<bool?>? isPopulated,
  }) {
    return IslandsCompanion(
      id: id ?? this.id,
      nameEs: nameEs ?? this.nameEs,
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaKm2: areaKm2 ?? this.areaKm2,
      areaHa: areaHa ?? this.areaHa,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      parkId: parkId ?? this.parkId,
      islandType: islandType ?? this.islandType,
      classification: classification ?? this.classification,
      isPopulated: isPopulated ?? this.isPopulated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (areaKm2.present) {
      map['area_km2'] = Variable<double>(areaKm2.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (parkId.present) {
      map['park_id'] = Variable<String>(parkId.value);
    }
    if (islandType.present) {
      map['island_type'] = Variable<String>(islandType.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (isPopulated.present) {
      map['is_populated'] = Variable<bool>(isPopulated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IslandsCompanion(')
          ..write('id: $id, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('areaKm2: $areaKm2, ')
          ..write('areaHa: $areaHa, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('parkId: $parkId, ')
          ..write('islandType: $islandType, ')
          ..write('classification: $classification, ')
          ..write('isPopulated: $isPopulated')
          ..write(')'))
        .toString();
  }
}

class $SpeciesRowsTable extends SpeciesRows
    with TableInfo<$SpeciesRowsTable, SpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameEsMeta = const VerificationMeta(
    'commonNameEs',
  );
  @override
  late final GeneratedColumn<String> commonNameEs = GeneratedColumn<String>(
    'common_name_es',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameEnMeta = const VerificationMeta(
    'commonNameEn',
  );
  @override
  late final GeneratedColumn<String> commonNameEn = GeneratedColumn<String>(
    'common_name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conservationStatusMeta =
      const VerificationMeta('conservationStatus');
  @override
  late final GeneratedColumn<String> conservationStatus =
      GeneratedColumn<String>(
        'conservation_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeCmMeta = const VerificationMeta('sizeCm');
  @override
  late final GeneratedColumn<double> sizeCm = GeneratedColumn<double>(
    'size_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _populationEstimateMeta =
      const VerificationMeta('populationEstimate');
  @override
  late final GeneratedColumn<int> populationEstimate = GeneratedColumn<int>(
    'population_estimate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lifespanYearsMeta = const VerificationMeta(
    'lifespanYears',
  );
  @override
  late final GeneratedColumn<int> lifespanYears = GeneratedColumn<int>(
    'lifespan_years',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitatEsMeta = const VerificationMeta(
    'habitatEs',
  );
  @override
  late final GeneratedColumn<String> habitatEs = GeneratedColumn<String>(
    'habitat_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitatEnMeta = const VerificationMeta(
    'habitatEn',
  );
  @override
  late final GeneratedColumn<String> habitatEn = GeneratedColumn<String>(
    'habitat_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heroImageUrlMeta = const VerificationMeta(
    'heroImageUrl',
  );
  @override
  late final GeneratedColumn<String> heroImageUrl = GeneratedColumn<String>(
    'hero_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEndemicMeta = const VerificationMeta(
    'isEndemic',
  );
  @override
  late final GeneratedColumn<bool> isEndemic = GeneratedColumn<bool>(
    'is_endemic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_endemic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _taxonomyKingdomMeta = const VerificationMeta(
    'taxonomyKingdom',
  );
  @override
  late final GeneratedColumn<String> taxonomyKingdom = GeneratedColumn<String>(
    'taxonomy_kingdom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonomyPhylumMeta = const VerificationMeta(
    'taxonomyPhylum',
  );
  @override
  late final GeneratedColumn<String> taxonomyPhylum = GeneratedColumn<String>(
    'taxonomy_phylum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonomyClassMeta = const VerificationMeta(
    'taxonomyClass',
  );
  @override
  late final GeneratedColumn<String> taxonomyClass = GeneratedColumn<String>(
    'taxonomy_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonomyOrderMeta = const VerificationMeta(
    'taxonomyOrder',
  );
  @override
  late final GeneratedColumn<String> taxonomyOrder = GeneratedColumn<String>(
    'taxonomy_order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonomyFamilyMeta = const VerificationMeta(
    'taxonomyFamily',
  );
  @override
  late final GeneratedColumn<String> taxonomyFamily = GeneratedColumn<String>(
    'taxonomy_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonomyGenusMeta = const VerificationMeta(
    'taxonomyGenus',
  );
  @override
  late final GeneratedColumn<String> taxonomyGenus = GeneratedColumn<String>(
    'taxonomy_genus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isNativeMeta = const VerificationMeta(
    'isNative',
  );
  @override
  late final GeneratedColumn<bool> isNative = GeneratedColumn<bool>(
    'is_native',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_native" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isIntroducedMeta = const VerificationMeta(
    'isIntroduced',
  );
  @override
  late final GeneratedColumn<bool> isIntroduced = GeneratedColumn<bool>(
    'is_introduced',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_introduced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _endemismLevelMeta = const VerificationMeta(
    'endemismLevel',
  );
  @override
  late final GeneratedColumn<String> endemismLevel = GeneratedColumn<String>(
    'endemism_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _populationTrendMeta = const VerificationMeta(
    'populationTrend',
  );
  @override
  late final GeneratedColumn<String> populationTrend = GeneratedColumn<String>(
    'population_trend',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breedingSeasonMeta = const VerificationMeta(
    'breedingSeason',
  );
  @override
  late final GeneratedColumn<String> breedingSeason = GeneratedColumn<String>(
    'breeding_season',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clutchSizeMeta = const VerificationMeta(
    'clutchSize',
  );
  @override
  late final GeneratedColumn<String> clutchSize = GeneratedColumn<String>(
    'clutch_size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reproductiveFrequencyMeta =
      const VerificationMeta('reproductiveFrequency');
  @override
  late final GeneratedColumn<String> reproductiveFrequency =
      GeneratedColumn<String>(
        'reproductive_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _socialStructureMeta = const VerificationMeta(
    'socialStructure',
  );
  @override
  late final GeneratedColumn<String> socialStructure = GeneratedColumn<String>(
    'social_structure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityPatternMeta = const VerificationMeta(
    'activityPattern',
  );
  @override
  late final GeneratedColumn<String> activityPattern = GeneratedColumn<String>(
    'activity_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietTypeMeta = const VerificationMeta(
    'dietType',
  );
  @override
  late final GeneratedColumn<String> dietType = GeneratedColumn<String>(
    'diet_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
  primaryFoodSources =
      GeneratedColumn<String>(
        'primary_food_sources',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>(
        $SpeciesRowsTable.$converterprimaryFoodSources,
      );
  static const VerificationMeta _altitudeMinMMeta = const VerificationMeta(
    'altitudeMinM',
  );
  @override
  late final GeneratedColumn<int> altitudeMinM = GeneratedColumn<int>(
    'altitude_min_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMaxMMeta = const VerificationMeta(
    'altitudeMaxM',
  );
  @override
  late final GeneratedColumn<int> altitudeMaxM = GeneratedColumn<int>(
    'altitude_max_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthMinMMeta = const VerificationMeta(
    'depthMinM',
  );
  @override
  late final GeneratedColumn<int> depthMinM = GeneratedColumn<int>(
    'depth_min_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthMaxMMeta = const VerificationMeta(
    'depthMaxM',
  );
  @override
  late final GeneratedColumn<int> depthMaxM = GeneratedColumn<int>(
    'depth_max_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scientificNameAuthorshipMeta =
      const VerificationMeta('scientificNameAuthorship');
  @override
  late final GeneratedColumn<String> scientificNameAuthorship =
      GeneratedColumn<String>(
        'scientific_name_authorship',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _distinguishingFeaturesEsMeta =
      const VerificationMeta('distinguishingFeaturesEs');
  @override
  late final GeneratedColumn<String> distinguishingFeaturesEs =
      GeneratedColumn<String>(
        'distinguishing_features_es',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _distinguishingFeaturesEnMeta =
      const VerificationMeta('distinguishingFeaturesEn');
  @override
  late final GeneratedColumn<String> distinguishingFeaturesEn =
      GeneratedColumn<String>(
        'distinguishing_features_en',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sexualDimorphismMeta = const VerificationMeta(
    'sexualDimorphism',
  );
  @override
  late final GeneratedColumn<String> sexualDimorphism = GeneratedColumn<String>(
    'sexual_dimorphism',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gbifTaxonIdMeta = const VerificationMeta(
    'gbifTaxonId',
  );
  @override
  late final GeneratedColumn<String> gbifTaxonId = GeneratedColumn<String>(
    'gbif_taxon_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eolPageIdMeta = const VerificationMeta(
    'eolPageId',
  );
  @override
  late final GeneratedColumn<String> eolPageId = GeneratedColumn<String>(
    'eol_page_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iucnAssessmentUrlMeta = const VerificationMeta(
    'iucnAssessmentUrl',
  );
  @override
  late final GeneratedColumn<String> iucnAssessmentUrl =
      GeneratedColumn<String>(
        'iucn_assessment_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _soundRecordingUrlMeta = const VerificationMeta(
    'soundRecordingUrl',
  );
  @override
  late final GeneratedColumn<String> soundRecordingUrl =
      GeneratedColumn<String>(
        'sound_recording_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMmFemaleMinMeta = const VerificationMeta(
    'sizeMmFemaleMin',
  );
  @override
  late final GeneratedColumn<double> sizeMmFemaleMin = GeneratedColumn<double>(
    'size_mm_female_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMmFemaleMaxMeta = const VerificationMeta(
    'sizeMmFemaleMax',
  );
  @override
  late final GeneratedColumn<double> sizeMmFemaleMax = GeneratedColumn<double>(
    'size_mm_female_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMmMaleMinMeta = const VerificationMeta(
    'sizeMmMaleMin',
  );
  @override
  late final GeneratedColumn<double> sizeMmMaleMin = GeneratedColumn<double>(
    'size_mm_male_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMmMaleMaxMeta = const VerificationMeta(
    'sizeMmMaleMax',
  );
  @override
  late final GeneratedColumn<double> sizeMmMaleMax = GeneratedColumn<double>(
    'size_mm_male_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buildsWebMeta = const VerificationMeta(
    'buildsWeb',
  );
  @override
  late final GeneratedColumn<bool> buildsWeb = GeneratedColumn<bool>(
    'builds_web',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("builds_web" IN (0, 1))',
    ),
  );
  static const VerificationMeta _webTypeMeta = const VerificationMeta(
    'webType',
  );
  @override
  late final GeneratedColumn<String> webType = GeneratedColumn<String>(
    'web_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _venomousToHumansMeta = const VerificationMeta(
    'venomousToHumans',
  );
  @override
  late final GeneratedColumn<bool> venomousToHumans = GeneratedColumn<bool>(
    'venomous_to_humans',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("venomous_to_humans" IN (0, 1))',
    ),
  );
  static const VerificationMeta _inaturalistTaxonIdMeta =
      const VerificationMeta('inaturalistTaxonId');
  @override
  late final GeneratedColumn<int> inaturalistTaxonId = GeneratedColumn<int>(
    'inaturalist_taxon_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datazoneIdMeta = const VerificationMeta(
    'datazoneId',
  );
  @override
  late final GeneratedColumn<int> datazoneId = GeneratedColumn<int>(
    'datazone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    commonNameEs,
    commonNameEn,
    scientificName,
    conservationStatus,
    weightKg,
    sizeCm,
    populationEstimate,
    lifespanYears,
    descriptionEs,
    descriptionEn,
    habitatEs,
    habitatEn,
    heroImageUrl,
    thumbnailUrl,
    isEndemic,
    taxonomyKingdom,
    taxonomyPhylum,
    taxonomyClass,
    taxonomyOrder,
    taxonomyFamily,
    taxonomyGenus,
    isNative,
    isIntroduced,
    endemismLevel,
    populationTrend,
    breedingSeason,
    clutchSize,
    reproductiveFrequency,
    socialStructure,
    activityPattern,
    dietType,
    primaryFoodSources,
    altitudeMinM,
    altitudeMaxM,
    depthMinM,
    depthMaxM,
    scientificNameAuthorship,
    distinguishingFeaturesEs,
    distinguishingFeaturesEn,
    sexualDimorphism,
    gbifTaxonId,
    eolPageId,
    iucnAssessmentUrl,
    soundRecordingUrl,
    videoUrl,
    sizeMmFemaleMin,
    sizeMmFemaleMax,
    sizeMmMaleMin,
    sizeMmMaleMax,
    buildsWeb,
    webType,
    venomousToHumans,
    inaturalistTaxonId,
    datazoneId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('common_name_es')) {
      context.handle(
        _commonNameEsMeta,
        commonNameEs.isAcceptableOrUnknown(
          data['common_name_es']!,
          _commonNameEsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commonNameEsMeta);
    }
    if (data.containsKey('common_name_en')) {
      context.handle(
        _commonNameEnMeta,
        commonNameEn.isAcceptableOrUnknown(
          data['common_name_en']!,
          _commonNameEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commonNameEnMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('conservation_status')) {
      context.handle(
        _conservationStatusMeta,
        conservationStatus.isAcceptableOrUnknown(
          data['conservation_status']!,
          _conservationStatusMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('size_cm')) {
      context.handle(
        _sizeCmMeta,
        sizeCm.isAcceptableOrUnknown(data['size_cm']!, _sizeCmMeta),
      );
    }
    if (data.containsKey('population_estimate')) {
      context.handle(
        _populationEstimateMeta,
        populationEstimate.isAcceptableOrUnknown(
          data['population_estimate']!,
          _populationEstimateMeta,
        ),
      );
    }
    if (data.containsKey('lifespan_years')) {
      context.handle(
        _lifespanYearsMeta,
        lifespanYears.isAcceptableOrUnknown(
          data['lifespan_years']!,
          _lifespanYearsMeta,
        ),
      );
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    if (data.containsKey('habitat_es')) {
      context.handle(
        _habitatEsMeta,
        habitatEs.isAcceptableOrUnknown(data['habitat_es']!, _habitatEsMeta),
      );
    }
    if (data.containsKey('habitat_en')) {
      context.handle(
        _habitatEnMeta,
        habitatEn.isAcceptableOrUnknown(data['habitat_en']!, _habitatEnMeta),
      );
    }
    if (data.containsKey('hero_image_url')) {
      context.handle(
        _heroImageUrlMeta,
        heroImageUrl.isAcceptableOrUnknown(
          data['hero_image_url']!,
          _heroImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('is_endemic')) {
      context.handle(
        _isEndemicMeta,
        isEndemic.isAcceptableOrUnknown(data['is_endemic']!, _isEndemicMeta),
      );
    }
    if (data.containsKey('taxonomy_kingdom')) {
      context.handle(
        _taxonomyKingdomMeta,
        taxonomyKingdom.isAcceptableOrUnknown(
          data['taxonomy_kingdom']!,
          _taxonomyKingdomMeta,
        ),
      );
    }
    if (data.containsKey('taxonomy_phylum')) {
      context.handle(
        _taxonomyPhylumMeta,
        taxonomyPhylum.isAcceptableOrUnknown(
          data['taxonomy_phylum']!,
          _taxonomyPhylumMeta,
        ),
      );
    }
    if (data.containsKey('taxonomy_class')) {
      context.handle(
        _taxonomyClassMeta,
        taxonomyClass.isAcceptableOrUnknown(
          data['taxonomy_class']!,
          _taxonomyClassMeta,
        ),
      );
    }
    if (data.containsKey('taxonomy_order')) {
      context.handle(
        _taxonomyOrderMeta,
        taxonomyOrder.isAcceptableOrUnknown(
          data['taxonomy_order']!,
          _taxonomyOrderMeta,
        ),
      );
    }
    if (data.containsKey('taxonomy_family')) {
      context.handle(
        _taxonomyFamilyMeta,
        taxonomyFamily.isAcceptableOrUnknown(
          data['taxonomy_family']!,
          _taxonomyFamilyMeta,
        ),
      );
    }
    if (data.containsKey('taxonomy_genus')) {
      context.handle(
        _taxonomyGenusMeta,
        taxonomyGenus.isAcceptableOrUnknown(
          data['taxonomy_genus']!,
          _taxonomyGenusMeta,
        ),
      );
    }
    if (data.containsKey('is_native')) {
      context.handle(
        _isNativeMeta,
        isNative.isAcceptableOrUnknown(data['is_native']!, _isNativeMeta),
      );
    }
    if (data.containsKey('is_introduced')) {
      context.handle(
        _isIntroducedMeta,
        isIntroduced.isAcceptableOrUnknown(
          data['is_introduced']!,
          _isIntroducedMeta,
        ),
      );
    }
    if (data.containsKey('endemism_level')) {
      context.handle(
        _endemismLevelMeta,
        endemismLevel.isAcceptableOrUnknown(
          data['endemism_level']!,
          _endemismLevelMeta,
        ),
      );
    }
    if (data.containsKey('population_trend')) {
      context.handle(
        _populationTrendMeta,
        populationTrend.isAcceptableOrUnknown(
          data['population_trend']!,
          _populationTrendMeta,
        ),
      );
    }
    if (data.containsKey('breeding_season')) {
      context.handle(
        _breedingSeasonMeta,
        breedingSeason.isAcceptableOrUnknown(
          data['breeding_season']!,
          _breedingSeasonMeta,
        ),
      );
    }
    if (data.containsKey('clutch_size')) {
      context.handle(
        _clutchSizeMeta,
        clutchSize.isAcceptableOrUnknown(data['clutch_size']!, _clutchSizeMeta),
      );
    }
    if (data.containsKey('reproductive_frequency')) {
      context.handle(
        _reproductiveFrequencyMeta,
        reproductiveFrequency.isAcceptableOrUnknown(
          data['reproductive_frequency']!,
          _reproductiveFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('social_structure')) {
      context.handle(
        _socialStructureMeta,
        socialStructure.isAcceptableOrUnknown(
          data['social_structure']!,
          _socialStructureMeta,
        ),
      );
    }
    if (data.containsKey('activity_pattern')) {
      context.handle(
        _activityPatternMeta,
        activityPattern.isAcceptableOrUnknown(
          data['activity_pattern']!,
          _activityPatternMeta,
        ),
      );
    }
    if (data.containsKey('diet_type')) {
      context.handle(
        _dietTypeMeta,
        dietType.isAcceptableOrUnknown(data['diet_type']!, _dietTypeMeta),
      );
    }
    if (data.containsKey('altitude_min_m')) {
      context.handle(
        _altitudeMinMMeta,
        altitudeMinM.isAcceptableOrUnknown(
          data['altitude_min_m']!,
          _altitudeMinMMeta,
        ),
      );
    }
    if (data.containsKey('altitude_max_m')) {
      context.handle(
        _altitudeMaxMMeta,
        altitudeMaxM.isAcceptableOrUnknown(
          data['altitude_max_m']!,
          _altitudeMaxMMeta,
        ),
      );
    }
    if (data.containsKey('depth_min_m')) {
      context.handle(
        _depthMinMMeta,
        depthMinM.isAcceptableOrUnknown(data['depth_min_m']!, _depthMinMMeta),
      );
    }
    if (data.containsKey('depth_max_m')) {
      context.handle(
        _depthMaxMMeta,
        depthMaxM.isAcceptableOrUnknown(data['depth_max_m']!, _depthMaxMMeta),
      );
    }
    if (data.containsKey('scientific_name_authorship')) {
      context.handle(
        _scientificNameAuthorshipMeta,
        scientificNameAuthorship.isAcceptableOrUnknown(
          data['scientific_name_authorship']!,
          _scientificNameAuthorshipMeta,
        ),
      );
    }
    if (data.containsKey('distinguishing_features_es')) {
      context.handle(
        _distinguishingFeaturesEsMeta,
        distinguishingFeaturesEs.isAcceptableOrUnknown(
          data['distinguishing_features_es']!,
          _distinguishingFeaturesEsMeta,
        ),
      );
    }
    if (data.containsKey('distinguishing_features_en')) {
      context.handle(
        _distinguishingFeaturesEnMeta,
        distinguishingFeaturesEn.isAcceptableOrUnknown(
          data['distinguishing_features_en']!,
          _distinguishingFeaturesEnMeta,
        ),
      );
    }
    if (data.containsKey('sexual_dimorphism')) {
      context.handle(
        _sexualDimorphismMeta,
        sexualDimorphism.isAcceptableOrUnknown(
          data['sexual_dimorphism']!,
          _sexualDimorphismMeta,
        ),
      );
    }
    if (data.containsKey('gbif_taxon_id')) {
      context.handle(
        _gbifTaxonIdMeta,
        gbifTaxonId.isAcceptableOrUnknown(
          data['gbif_taxon_id']!,
          _gbifTaxonIdMeta,
        ),
      );
    }
    if (data.containsKey('eol_page_id')) {
      context.handle(
        _eolPageIdMeta,
        eolPageId.isAcceptableOrUnknown(data['eol_page_id']!, _eolPageIdMeta),
      );
    }
    if (data.containsKey('iucn_assessment_url')) {
      context.handle(
        _iucnAssessmentUrlMeta,
        iucnAssessmentUrl.isAcceptableOrUnknown(
          data['iucn_assessment_url']!,
          _iucnAssessmentUrlMeta,
        ),
      );
    }
    if (data.containsKey('sound_recording_url')) {
      context.handle(
        _soundRecordingUrlMeta,
        soundRecordingUrl.isAcceptableOrUnknown(
          data['sound_recording_url']!,
          _soundRecordingUrlMeta,
        ),
      );
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('size_mm_female_min')) {
      context.handle(
        _sizeMmFemaleMinMeta,
        sizeMmFemaleMin.isAcceptableOrUnknown(
          data['size_mm_female_min']!,
          _sizeMmFemaleMinMeta,
        ),
      );
    }
    if (data.containsKey('size_mm_female_max')) {
      context.handle(
        _sizeMmFemaleMaxMeta,
        sizeMmFemaleMax.isAcceptableOrUnknown(
          data['size_mm_female_max']!,
          _sizeMmFemaleMaxMeta,
        ),
      );
    }
    if (data.containsKey('size_mm_male_min')) {
      context.handle(
        _sizeMmMaleMinMeta,
        sizeMmMaleMin.isAcceptableOrUnknown(
          data['size_mm_male_min']!,
          _sizeMmMaleMinMeta,
        ),
      );
    }
    if (data.containsKey('size_mm_male_max')) {
      context.handle(
        _sizeMmMaleMaxMeta,
        sizeMmMaleMax.isAcceptableOrUnknown(
          data['size_mm_male_max']!,
          _sizeMmMaleMaxMeta,
        ),
      );
    }
    if (data.containsKey('builds_web')) {
      context.handle(
        _buildsWebMeta,
        buildsWeb.isAcceptableOrUnknown(data['builds_web']!, _buildsWebMeta),
      );
    }
    if (data.containsKey('web_type')) {
      context.handle(
        _webTypeMeta,
        webType.isAcceptableOrUnknown(data['web_type']!, _webTypeMeta),
      );
    }
    if (data.containsKey('venomous_to_humans')) {
      context.handle(
        _venomousToHumansMeta,
        venomousToHumans.isAcceptableOrUnknown(
          data['venomous_to_humans']!,
          _venomousToHumansMeta,
        ),
      );
    }
    if (data.containsKey('inaturalist_taxon_id')) {
      context.handle(
        _inaturalistTaxonIdMeta,
        inaturalistTaxonId.isAcceptableOrUnknown(
          data['inaturalist_taxon_id']!,
          _inaturalistTaxonIdMeta,
        ),
      );
    }
    if (data.containsKey('datazone_id')) {
      context.handle(
        _datazoneIdMeta,
        datazoneId.isAcceptableOrUnknown(data['datazone_id']!, _datazoneIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      commonNameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name_es'],
      )!,
      commonNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name_en'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      conservationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conservation_status'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      sizeCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_cm'],
      ),
      populationEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population_estimate'],
      ),
      lifespanYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifespan_years'],
      ),
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
      habitatEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitat_es'],
      ),
      habitatEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitat_en'],
      ),
      heroImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_image_url'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      isEndemic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_endemic'],
      )!,
      taxonomyKingdom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_kingdom'],
      ),
      taxonomyPhylum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_phylum'],
      ),
      taxonomyClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_class'],
      ),
      taxonomyOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_order'],
      ),
      taxonomyFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_family'],
      ),
      taxonomyGenus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxonomy_genus'],
      ),
      isNative: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_native'],
      ),
      isIntroduced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_introduced'],
      ),
      endemismLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endemism_level'],
      ),
      populationTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}population_trend'],
      ),
      breedingSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breeding_season'],
      ),
      clutchSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clutch_size'],
      ),
      reproductiveFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reproductive_frequency'],
      ),
      socialStructure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}social_structure'],
      ),
      activityPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_pattern'],
      ),
      dietType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diet_type'],
      ),
      primaryFoodSources: $SpeciesRowsTable.$converterprimaryFoodSources
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}primary_food_sources'],
            ),
          ),
      altitudeMinM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}altitude_min_m'],
      ),
      altitudeMaxM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}altitude_max_m'],
      ),
      depthMinM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth_min_m'],
      ),
      depthMaxM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth_max_m'],
      ),
      scientificNameAuthorship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name_authorship'],
      ),
      distinguishingFeaturesEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distinguishing_features_es'],
      ),
      distinguishingFeaturesEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distinguishing_features_en'],
      ),
      sexualDimorphism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sexual_dimorphism'],
      ),
      gbifTaxonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gbif_taxon_id'],
      ),
      eolPageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eol_page_id'],
      ),
      iucnAssessmentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iucn_assessment_url'],
      ),
      soundRecordingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_recording_url'],
      ),
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      sizeMmFemaleMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_mm_female_min'],
      ),
      sizeMmFemaleMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_mm_female_max'],
      ),
      sizeMmMaleMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_mm_male_min'],
      ),
      sizeMmMaleMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_mm_male_max'],
      ),
      buildsWeb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}builds_web'],
      ),
      webType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}web_type'],
      ),
      venomousToHumans: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}venomous_to_humans'],
      ),
      inaturalistTaxonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inaturalist_taxon_id'],
      ),
      datazoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}datazone_id'],
      ),
    );
  }

  @override
  $SpeciesRowsTable createAlias(String alias) {
    return $SpeciesRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>?, String?> $converterprimaryFoodSources =
      const NullableStringListConverter();
}

class SpeciesRow extends DataClass implements Insertable<SpeciesRow> {
  final int id;
  final int categoryId;
  final String commonNameEs;
  final String commonNameEn;
  final String scientificName;
  final String? conservationStatus;
  final double? weightKg;
  final double? sizeCm;
  final int? populationEstimate;
  final int? lifespanYears;
  final String? descriptionEs;
  final String? descriptionEn;
  final String? habitatEs;
  final String? habitatEn;
  final String? heroImageUrl;
  final String? thumbnailUrl;
  final bool isEndemic;
  final String? taxonomyKingdom;
  final String? taxonomyPhylum;
  final String? taxonomyClass;
  final String? taxonomyOrder;
  final String? taxonomyFamily;
  final String? taxonomyGenus;
  final bool? isNative;
  final bool? isIntroduced;
  final String? endemismLevel;
  final String? populationTrend;
  final String? breedingSeason;
  final String? clutchSize;
  final String? reproductiveFrequency;
  final String? socialStructure;
  final String? activityPattern;
  final String? dietType;
  final List<String>? primaryFoodSources;
  final int? altitudeMinM;
  final int? altitudeMaxM;
  final int? depthMinM;
  final int? depthMaxM;
  final String? scientificNameAuthorship;
  final String? distinguishingFeaturesEs;
  final String? distinguishingFeaturesEn;
  final String? sexualDimorphism;
  final String? gbifTaxonId;
  final String? eolPageId;
  final String? iucnAssessmentUrl;
  final String? soundRecordingUrl;
  final String? videoUrl;
  final double? sizeMmFemaleMin;
  final double? sizeMmFemaleMax;
  final double? sizeMmMaleMin;
  final double? sizeMmMaleMax;
  final bool? buildsWeb;
  final String? webType;
  final bool? venomousToHumans;
  final int? inaturalistTaxonId;
  final int? datazoneId;
  const SpeciesRow({
    required this.id,
    required this.categoryId,
    required this.commonNameEs,
    required this.commonNameEn,
    required this.scientificName,
    this.conservationStatus,
    this.weightKg,
    this.sizeCm,
    this.populationEstimate,
    this.lifespanYears,
    this.descriptionEs,
    this.descriptionEn,
    this.habitatEs,
    this.habitatEn,
    this.heroImageUrl,
    this.thumbnailUrl,
    required this.isEndemic,
    this.taxonomyKingdom,
    this.taxonomyPhylum,
    this.taxonomyClass,
    this.taxonomyOrder,
    this.taxonomyFamily,
    this.taxonomyGenus,
    this.isNative,
    this.isIntroduced,
    this.endemismLevel,
    this.populationTrend,
    this.breedingSeason,
    this.clutchSize,
    this.reproductiveFrequency,
    this.socialStructure,
    this.activityPattern,
    this.dietType,
    this.primaryFoodSources,
    this.altitudeMinM,
    this.altitudeMaxM,
    this.depthMinM,
    this.depthMaxM,
    this.scientificNameAuthorship,
    this.distinguishingFeaturesEs,
    this.distinguishingFeaturesEn,
    this.sexualDimorphism,
    this.gbifTaxonId,
    this.eolPageId,
    this.iucnAssessmentUrl,
    this.soundRecordingUrl,
    this.videoUrl,
    this.sizeMmFemaleMin,
    this.sizeMmFemaleMax,
    this.sizeMmMaleMin,
    this.sizeMmMaleMax,
    this.buildsWeb,
    this.webType,
    this.venomousToHumans,
    this.inaturalistTaxonId,
    this.datazoneId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['common_name_es'] = Variable<String>(commonNameEs);
    map['common_name_en'] = Variable<String>(commonNameEn);
    map['scientific_name'] = Variable<String>(scientificName);
    if (!nullToAbsent || conservationStatus != null) {
      map['conservation_status'] = Variable<String>(conservationStatus);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || sizeCm != null) {
      map['size_cm'] = Variable<double>(sizeCm);
    }
    if (!nullToAbsent || populationEstimate != null) {
      map['population_estimate'] = Variable<int>(populationEstimate);
    }
    if (!nullToAbsent || lifespanYears != null) {
      map['lifespan_years'] = Variable<int>(lifespanYears);
    }
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    if (!nullToAbsent || habitatEs != null) {
      map['habitat_es'] = Variable<String>(habitatEs);
    }
    if (!nullToAbsent || habitatEn != null) {
      map['habitat_en'] = Variable<String>(habitatEn);
    }
    if (!nullToAbsent || heroImageUrl != null) {
      map['hero_image_url'] = Variable<String>(heroImageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['is_endemic'] = Variable<bool>(isEndemic);
    if (!nullToAbsent || taxonomyKingdom != null) {
      map['taxonomy_kingdom'] = Variable<String>(taxonomyKingdom);
    }
    if (!nullToAbsent || taxonomyPhylum != null) {
      map['taxonomy_phylum'] = Variable<String>(taxonomyPhylum);
    }
    if (!nullToAbsent || taxonomyClass != null) {
      map['taxonomy_class'] = Variable<String>(taxonomyClass);
    }
    if (!nullToAbsent || taxonomyOrder != null) {
      map['taxonomy_order'] = Variable<String>(taxonomyOrder);
    }
    if (!nullToAbsent || taxonomyFamily != null) {
      map['taxonomy_family'] = Variable<String>(taxonomyFamily);
    }
    if (!nullToAbsent || taxonomyGenus != null) {
      map['taxonomy_genus'] = Variable<String>(taxonomyGenus);
    }
    if (!nullToAbsent || isNative != null) {
      map['is_native'] = Variable<bool>(isNative);
    }
    if (!nullToAbsent || isIntroduced != null) {
      map['is_introduced'] = Variable<bool>(isIntroduced);
    }
    if (!nullToAbsent || endemismLevel != null) {
      map['endemism_level'] = Variable<String>(endemismLevel);
    }
    if (!nullToAbsent || populationTrend != null) {
      map['population_trend'] = Variable<String>(populationTrend);
    }
    if (!nullToAbsent || breedingSeason != null) {
      map['breeding_season'] = Variable<String>(breedingSeason);
    }
    if (!nullToAbsent || clutchSize != null) {
      map['clutch_size'] = Variable<String>(clutchSize);
    }
    if (!nullToAbsent || reproductiveFrequency != null) {
      map['reproductive_frequency'] = Variable<String>(reproductiveFrequency);
    }
    if (!nullToAbsent || socialStructure != null) {
      map['social_structure'] = Variable<String>(socialStructure);
    }
    if (!nullToAbsent || activityPattern != null) {
      map['activity_pattern'] = Variable<String>(activityPattern);
    }
    if (!nullToAbsent || dietType != null) {
      map['diet_type'] = Variable<String>(dietType);
    }
    if (!nullToAbsent || primaryFoodSources != null) {
      map['primary_food_sources'] = Variable<String>(
        $SpeciesRowsTable.$converterprimaryFoodSources.toSql(
          primaryFoodSources,
        ),
      );
    }
    if (!nullToAbsent || altitudeMinM != null) {
      map['altitude_min_m'] = Variable<int>(altitudeMinM);
    }
    if (!nullToAbsent || altitudeMaxM != null) {
      map['altitude_max_m'] = Variable<int>(altitudeMaxM);
    }
    if (!nullToAbsent || depthMinM != null) {
      map['depth_min_m'] = Variable<int>(depthMinM);
    }
    if (!nullToAbsent || depthMaxM != null) {
      map['depth_max_m'] = Variable<int>(depthMaxM);
    }
    if (!nullToAbsent || scientificNameAuthorship != null) {
      map['scientific_name_authorship'] = Variable<String>(
        scientificNameAuthorship,
      );
    }
    if (!nullToAbsent || distinguishingFeaturesEs != null) {
      map['distinguishing_features_es'] = Variable<String>(
        distinguishingFeaturesEs,
      );
    }
    if (!nullToAbsent || distinguishingFeaturesEn != null) {
      map['distinguishing_features_en'] = Variable<String>(
        distinguishingFeaturesEn,
      );
    }
    if (!nullToAbsent || sexualDimorphism != null) {
      map['sexual_dimorphism'] = Variable<String>(sexualDimorphism);
    }
    if (!nullToAbsent || gbifTaxonId != null) {
      map['gbif_taxon_id'] = Variable<String>(gbifTaxonId);
    }
    if (!nullToAbsent || eolPageId != null) {
      map['eol_page_id'] = Variable<String>(eolPageId);
    }
    if (!nullToAbsent || iucnAssessmentUrl != null) {
      map['iucn_assessment_url'] = Variable<String>(iucnAssessmentUrl);
    }
    if (!nullToAbsent || soundRecordingUrl != null) {
      map['sound_recording_url'] = Variable<String>(soundRecordingUrl);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || sizeMmFemaleMin != null) {
      map['size_mm_female_min'] = Variable<double>(sizeMmFemaleMin);
    }
    if (!nullToAbsent || sizeMmFemaleMax != null) {
      map['size_mm_female_max'] = Variable<double>(sizeMmFemaleMax);
    }
    if (!nullToAbsent || sizeMmMaleMin != null) {
      map['size_mm_male_min'] = Variable<double>(sizeMmMaleMin);
    }
    if (!nullToAbsent || sizeMmMaleMax != null) {
      map['size_mm_male_max'] = Variable<double>(sizeMmMaleMax);
    }
    if (!nullToAbsent || buildsWeb != null) {
      map['builds_web'] = Variable<bool>(buildsWeb);
    }
    if (!nullToAbsent || webType != null) {
      map['web_type'] = Variable<String>(webType);
    }
    if (!nullToAbsent || venomousToHumans != null) {
      map['venomous_to_humans'] = Variable<bool>(venomousToHumans);
    }
    if (!nullToAbsent || inaturalistTaxonId != null) {
      map['inaturalist_taxon_id'] = Variable<int>(inaturalistTaxonId);
    }
    if (!nullToAbsent || datazoneId != null) {
      map['datazone_id'] = Variable<int>(datazoneId);
    }
    return map;
  }

  SpeciesRowsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesRowsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      commonNameEs: Value(commonNameEs),
      commonNameEn: Value(commonNameEn),
      scientificName: Value(scientificName),
      conservationStatus: conservationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(conservationStatus),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      sizeCm: sizeCm == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeCm),
      populationEstimate: populationEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(populationEstimate),
      lifespanYears: lifespanYears == null && nullToAbsent
          ? const Value.absent()
          : Value(lifespanYears),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
      habitatEs: habitatEs == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatEs),
      habitatEn: habitatEn == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatEn),
      heroImageUrl: heroImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(heroImageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      isEndemic: Value(isEndemic),
      taxonomyKingdom: taxonomyKingdom == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyKingdom),
      taxonomyPhylum: taxonomyPhylum == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyPhylum),
      taxonomyClass: taxonomyClass == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyClass),
      taxonomyOrder: taxonomyOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyOrder),
      taxonomyFamily: taxonomyFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyFamily),
      taxonomyGenus: taxonomyGenus == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyGenus),
      isNative: isNative == null && nullToAbsent
          ? const Value.absent()
          : Value(isNative),
      isIntroduced: isIntroduced == null && nullToAbsent
          ? const Value.absent()
          : Value(isIntroduced),
      endemismLevel: endemismLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(endemismLevel),
      populationTrend: populationTrend == null && nullToAbsent
          ? const Value.absent()
          : Value(populationTrend),
      breedingSeason: breedingSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(breedingSeason),
      clutchSize: clutchSize == null && nullToAbsent
          ? const Value.absent()
          : Value(clutchSize),
      reproductiveFrequency: reproductiveFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(reproductiveFrequency),
      socialStructure: socialStructure == null && nullToAbsent
          ? const Value.absent()
          : Value(socialStructure),
      activityPattern: activityPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(activityPattern),
      dietType: dietType == null && nullToAbsent
          ? const Value.absent()
          : Value(dietType),
      primaryFoodSources: primaryFoodSources == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryFoodSources),
      altitudeMinM: altitudeMinM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeMinM),
      altitudeMaxM: altitudeMaxM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeMaxM),
      depthMinM: depthMinM == null && nullToAbsent
          ? const Value.absent()
          : Value(depthMinM),
      depthMaxM: depthMaxM == null && nullToAbsent
          ? const Value.absent()
          : Value(depthMaxM),
      scientificNameAuthorship: scientificNameAuthorship == null && nullToAbsent
          ? const Value.absent()
          : Value(scientificNameAuthorship),
      distinguishingFeaturesEs: distinguishingFeaturesEs == null && nullToAbsent
          ? const Value.absent()
          : Value(distinguishingFeaturesEs),
      distinguishingFeaturesEn: distinguishingFeaturesEn == null && nullToAbsent
          ? const Value.absent()
          : Value(distinguishingFeaturesEn),
      sexualDimorphism: sexualDimorphism == null && nullToAbsent
          ? const Value.absent()
          : Value(sexualDimorphism),
      gbifTaxonId: gbifTaxonId == null && nullToAbsent
          ? const Value.absent()
          : Value(gbifTaxonId),
      eolPageId: eolPageId == null && nullToAbsent
          ? const Value.absent()
          : Value(eolPageId),
      iucnAssessmentUrl: iucnAssessmentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iucnAssessmentUrl),
      soundRecordingUrl: soundRecordingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(soundRecordingUrl),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      sizeMmFemaleMin: sizeMmFemaleMin == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeMmFemaleMin),
      sizeMmFemaleMax: sizeMmFemaleMax == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeMmFemaleMax),
      sizeMmMaleMin: sizeMmMaleMin == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeMmMaleMin),
      sizeMmMaleMax: sizeMmMaleMax == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeMmMaleMax),
      buildsWeb: buildsWeb == null && nullToAbsent
          ? const Value.absent()
          : Value(buildsWeb),
      webType: webType == null && nullToAbsent
          ? const Value.absent()
          : Value(webType),
      venomousToHumans: venomousToHumans == null && nullToAbsent
          ? const Value.absent()
          : Value(venomousToHumans),
      inaturalistTaxonId: inaturalistTaxonId == null && nullToAbsent
          ? const Value.absent()
          : Value(inaturalistTaxonId),
      datazoneId: datazoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(datazoneId),
    );
  }

  factory SpeciesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      commonNameEs: serializer.fromJson<String>(json['commonNameEs']),
      commonNameEn: serializer.fromJson<String>(json['commonNameEn']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      conservationStatus: serializer.fromJson<String?>(
        json['conservationStatus'],
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      sizeCm: serializer.fromJson<double?>(json['sizeCm']),
      populationEstimate: serializer.fromJson<int?>(json['populationEstimate']),
      lifespanYears: serializer.fromJson<int?>(json['lifespanYears']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
      habitatEs: serializer.fromJson<String?>(json['habitatEs']),
      habitatEn: serializer.fromJson<String?>(json['habitatEn']),
      heroImageUrl: serializer.fromJson<String?>(json['heroImageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      isEndemic: serializer.fromJson<bool>(json['isEndemic']),
      taxonomyKingdom: serializer.fromJson<String?>(json['taxonomyKingdom']),
      taxonomyPhylum: serializer.fromJson<String?>(json['taxonomyPhylum']),
      taxonomyClass: serializer.fromJson<String?>(json['taxonomyClass']),
      taxonomyOrder: serializer.fromJson<String?>(json['taxonomyOrder']),
      taxonomyFamily: serializer.fromJson<String?>(json['taxonomyFamily']),
      taxonomyGenus: serializer.fromJson<String?>(json['taxonomyGenus']),
      isNative: serializer.fromJson<bool?>(json['isNative']),
      isIntroduced: serializer.fromJson<bool?>(json['isIntroduced']),
      endemismLevel: serializer.fromJson<String?>(json['endemismLevel']),
      populationTrend: serializer.fromJson<String?>(json['populationTrend']),
      breedingSeason: serializer.fromJson<String?>(json['breedingSeason']),
      clutchSize: serializer.fromJson<String?>(json['clutchSize']),
      reproductiveFrequency: serializer.fromJson<String?>(
        json['reproductiveFrequency'],
      ),
      socialStructure: serializer.fromJson<String?>(json['socialStructure']),
      activityPattern: serializer.fromJson<String?>(json['activityPattern']),
      dietType: serializer.fromJson<String?>(json['dietType']),
      primaryFoodSources: serializer.fromJson<List<String>?>(
        json['primaryFoodSources'],
      ),
      altitudeMinM: serializer.fromJson<int?>(json['altitudeMinM']),
      altitudeMaxM: serializer.fromJson<int?>(json['altitudeMaxM']),
      depthMinM: serializer.fromJson<int?>(json['depthMinM']),
      depthMaxM: serializer.fromJson<int?>(json['depthMaxM']),
      scientificNameAuthorship: serializer.fromJson<String?>(
        json['scientificNameAuthorship'],
      ),
      distinguishingFeaturesEs: serializer.fromJson<String?>(
        json['distinguishingFeaturesEs'],
      ),
      distinguishingFeaturesEn: serializer.fromJson<String?>(
        json['distinguishingFeaturesEn'],
      ),
      sexualDimorphism: serializer.fromJson<String?>(json['sexualDimorphism']),
      gbifTaxonId: serializer.fromJson<String?>(json['gbifTaxonId']),
      eolPageId: serializer.fromJson<String?>(json['eolPageId']),
      iucnAssessmentUrl: serializer.fromJson<String?>(
        json['iucnAssessmentUrl'],
      ),
      soundRecordingUrl: serializer.fromJson<String?>(
        json['soundRecordingUrl'],
      ),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      sizeMmFemaleMin: serializer.fromJson<double?>(json['sizeMmFemaleMin']),
      sizeMmFemaleMax: serializer.fromJson<double?>(json['sizeMmFemaleMax']),
      sizeMmMaleMin: serializer.fromJson<double?>(json['sizeMmMaleMin']),
      sizeMmMaleMax: serializer.fromJson<double?>(json['sizeMmMaleMax']),
      buildsWeb: serializer.fromJson<bool?>(json['buildsWeb']),
      webType: serializer.fromJson<String?>(json['webType']),
      venomousToHumans: serializer.fromJson<bool?>(json['venomousToHumans']),
      inaturalistTaxonId: serializer.fromJson<int?>(json['inaturalistTaxonId']),
      datazoneId: serializer.fromJson<int?>(json['datazoneId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'commonNameEs': serializer.toJson<String>(commonNameEs),
      'commonNameEn': serializer.toJson<String>(commonNameEn),
      'scientificName': serializer.toJson<String>(scientificName),
      'conservationStatus': serializer.toJson<String?>(conservationStatus),
      'weightKg': serializer.toJson<double?>(weightKg),
      'sizeCm': serializer.toJson<double?>(sizeCm),
      'populationEstimate': serializer.toJson<int?>(populationEstimate),
      'lifespanYears': serializer.toJson<int?>(lifespanYears),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
      'habitatEs': serializer.toJson<String?>(habitatEs),
      'habitatEn': serializer.toJson<String?>(habitatEn),
      'heroImageUrl': serializer.toJson<String?>(heroImageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'isEndemic': serializer.toJson<bool>(isEndemic),
      'taxonomyKingdom': serializer.toJson<String?>(taxonomyKingdom),
      'taxonomyPhylum': serializer.toJson<String?>(taxonomyPhylum),
      'taxonomyClass': serializer.toJson<String?>(taxonomyClass),
      'taxonomyOrder': serializer.toJson<String?>(taxonomyOrder),
      'taxonomyFamily': serializer.toJson<String?>(taxonomyFamily),
      'taxonomyGenus': serializer.toJson<String?>(taxonomyGenus),
      'isNative': serializer.toJson<bool?>(isNative),
      'isIntroduced': serializer.toJson<bool?>(isIntroduced),
      'endemismLevel': serializer.toJson<String?>(endemismLevel),
      'populationTrend': serializer.toJson<String?>(populationTrend),
      'breedingSeason': serializer.toJson<String?>(breedingSeason),
      'clutchSize': serializer.toJson<String?>(clutchSize),
      'reproductiveFrequency': serializer.toJson<String?>(
        reproductiveFrequency,
      ),
      'socialStructure': serializer.toJson<String?>(socialStructure),
      'activityPattern': serializer.toJson<String?>(activityPattern),
      'dietType': serializer.toJson<String?>(dietType),
      'primaryFoodSources': serializer.toJson<List<String>?>(
        primaryFoodSources,
      ),
      'altitudeMinM': serializer.toJson<int?>(altitudeMinM),
      'altitudeMaxM': serializer.toJson<int?>(altitudeMaxM),
      'depthMinM': serializer.toJson<int?>(depthMinM),
      'depthMaxM': serializer.toJson<int?>(depthMaxM),
      'scientificNameAuthorship': serializer.toJson<String?>(
        scientificNameAuthorship,
      ),
      'distinguishingFeaturesEs': serializer.toJson<String?>(
        distinguishingFeaturesEs,
      ),
      'distinguishingFeaturesEn': serializer.toJson<String?>(
        distinguishingFeaturesEn,
      ),
      'sexualDimorphism': serializer.toJson<String?>(sexualDimorphism),
      'gbifTaxonId': serializer.toJson<String?>(gbifTaxonId),
      'eolPageId': serializer.toJson<String?>(eolPageId),
      'iucnAssessmentUrl': serializer.toJson<String?>(iucnAssessmentUrl),
      'soundRecordingUrl': serializer.toJson<String?>(soundRecordingUrl),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'sizeMmFemaleMin': serializer.toJson<double?>(sizeMmFemaleMin),
      'sizeMmFemaleMax': serializer.toJson<double?>(sizeMmFemaleMax),
      'sizeMmMaleMin': serializer.toJson<double?>(sizeMmMaleMin),
      'sizeMmMaleMax': serializer.toJson<double?>(sizeMmMaleMax),
      'buildsWeb': serializer.toJson<bool?>(buildsWeb),
      'webType': serializer.toJson<String?>(webType),
      'venomousToHumans': serializer.toJson<bool?>(venomousToHumans),
      'inaturalistTaxonId': serializer.toJson<int?>(inaturalistTaxonId),
      'datazoneId': serializer.toJson<int?>(datazoneId),
    };
  }

  SpeciesRow copyWith({
    int? id,
    int? categoryId,
    String? commonNameEs,
    String? commonNameEn,
    String? scientificName,
    Value<String?> conservationStatus = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> sizeCm = const Value.absent(),
    Value<int?> populationEstimate = const Value.absent(),
    Value<int?> lifespanYears = const Value.absent(),
    Value<String?> descriptionEs = const Value.absent(),
    Value<String?> descriptionEn = const Value.absent(),
    Value<String?> habitatEs = const Value.absent(),
    Value<String?> habitatEn = const Value.absent(),
    Value<String?> heroImageUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    bool? isEndemic,
    Value<String?> taxonomyKingdom = const Value.absent(),
    Value<String?> taxonomyPhylum = const Value.absent(),
    Value<String?> taxonomyClass = const Value.absent(),
    Value<String?> taxonomyOrder = const Value.absent(),
    Value<String?> taxonomyFamily = const Value.absent(),
    Value<String?> taxonomyGenus = const Value.absent(),
    Value<bool?> isNative = const Value.absent(),
    Value<bool?> isIntroduced = const Value.absent(),
    Value<String?> endemismLevel = const Value.absent(),
    Value<String?> populationTrend = const Value.absent(),
    Value<String?> breedingSeason = const Value.absent(),
    Value<String?> clutchSize = const Value.absent(),
    Value<String?> reproductiveFrequency = const Value.absent(),
    Value<String?> socialStructure = const Value.absent(),
    Value<String?> activityPattern = const Value.absent(),
    Value<String?> dietType = const Value.absent(),
    Value<List<String>?> primaryFoodSources = const Value.absent(),
    Value<int?> altitudeMinM = const Value.absent(),
    Value<int?> altitudeMaxM = const Value.absent(),
    Value<int?> depthMinM = const Value.absent(),
    Value<int?> depthMaxM = const Value.absent(),
    Value<String?> scientificNameAuthorship = const Value.absent(),
    Value<String?> distinguishingFeaturesEs = const Value.absent(),
    Value<String?> distinguishingFeaturesEn = const Value.absent(),
    Value<String?> sexualDimorphism = const Value.absent(),
    Value<String?> gbifTaxonId = const Value.absent(),
    Value<String?> eolPageId = const Value.absent(),
    Value<String?> iucnAssessmentUrl = const Value.absent(),
    Value<String?> soundRecordingUrl = const Value.absent(),
    Value<String?> videoUrl = const Value.absent(),
    Value<double?> sizeMmFemaleMin = const Value.absent(),
    Value<double?> sizeMmFemaleMax = const Value.absent(),
    Value<double?> sizeMmMaleMin = const Value.absent(),
    Value<double?> sizeMmMaleMax = const Value.absent(),
    Value<bool?> buildsWeb = const Value.absent(),
    Value<String?> webType = const Value.absent(),
    Value<bool?> venomousToHumans = const Value.absent(),
    Value<int?> inaturalistTaxonId = const Value.absent(),
    Value<int?> datazoneId = const Value.absent(),
  }) => SpeciesRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    commonNameEs: commonNameEs ?? this.commonNameEs,
    commonNameEn: commonNameEn ?? this.commonNameEn,
    scientificName: scientificName ?? this.scientificName,
    conservationStatus: conservationStatus.present
        ? conservationStatus.value
        : this.conservationStatus,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    sizeCm: sizeCm.present ? sizeCm.value : this.sizeCm,
    populationEstimate: populationEstimate.present
        ? populationEstimate.value
        : this.populationEstimate,
    lifespanYears: lifespanYears.present
        ? lifespanYears.value
        : this.lifespanYears,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
    habitatEs: habitatEs.present ? habitatEs.value : this.habitatEs,
    habitatEn: habitatEn.present ? habitatEn.value : this.habitatEn,
    heroImageUrl: heroImageUrl.present ? heroImageUrl.value : this.heroImageUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    isEndemic: isEndemic ?? this.isEndemic,
    taxonomyKingdom: taxonomyKingdom.present
        ? taxonomyKingdom.value
        : this.taxonomyKingdom,
    taxonomyPhylum: taxonomyPhylum.present
        ? taxonomyPhylum.value
        : this.taxonomyPhylum,
    taxonomyClass: taxonomyClass.present
        ? taxonomyClass.value
        : this.taxonomyClass,
    taxonomyOrder: taxonomyOrder.present
        ? taxonomyOrder.value
        : this.taxonomyOrder,
    taxonomyFamily: taxonomyFamily.present
        ? taxonomyFamily.value
        : this.taxonomyFamily,
    taxonomyGenus: taxonomyGenus.present
        ? taxonomyGenus.value
        : this.taxonomyGenus,
    isNative: isNative.present ? isNative.value : this.isNative,
    isIntroduced: isIntroduced.present ? isIntroduced.value : this.isIntroduced,
    endemismLevel: endemismLevel.present
        ? endemismLevel.value
        : this.endemismLevel,
    populationTrend: populationTrend.present
        ? populationTrend.value
        : this.populationTrend,
    breedingSeason: breedingSeason.present
        ? breedingSeason.value
        : this.breedingSeason,
    clutchSize: clutchSize.present ? clutchSize.value : this.clutchSize,
    reproductiveFrequency: reproductiveFrequency.present
        ? reproductiveFrequency.value
        : this.reproductiveFrequency,
    socialStructure: socialStructure.present
        ? socialStructure.value
        : this.socialStructure,
    activityPattern: activityPattern.present
        ? activityPattern.value
        : this.activityPattern,
    dietType: dietType.present ? dietType.value : this.dietType,
    primaryFoodSources: primaryFoodSources.present
        ? primaryFoodSources.value
        : this.primaryFoodSources,
    altitudeMinM: altitudeMinM.present ? altitudeMinM.value : this.altitudeMinM,
    altitudeMaxM: altitudeMaxM.present ? altitudeMaxM.value : this.altitudeMaxM,
    depthMinM: depthMinM.present ? depthMinM.value : this.depthMinM,
    depthMaxM: depthMaxM.present ? depthMaxM.value : this.depthMaxM,
    scientificNameAuthorship: scientificNameAuthorship.present
        ? scientificNameAuthorship.value
        : this.scientificNameAuthorship,
    distinguishingFeaturesEs: distinguishingFeaturesEs.present
        ? distinguishingFeaturesEs.value
        : this.distinguishingFeaturesEs,
    distinguishingFeaturesEn: distinguishingFeaturesEn.present
        ? distinguishingFeaturesEn.value
        : this.distinguishingFeaturesEn,
    sexualDimorphism: sexualDimorphism.present
        ? sexualDimorphism.value
        : this.sexualDimorphism,
    gbifTaxonId: gbifTaxonId.present ? gbifTaxonId.value : this.gbifTaxonId,
    eolPageId: eolPageId.present ? eolPageId.value : this.eolPageId,
    iucnAssessmentUrl: iucnAssessmentUrl.present
        ? iucnAssessmentUrl.value
        : this.iucnAssessmentUrl,
    soundRecordingUrl: soundRecordingUrl.present
        ? soundRecordingUrl.value
        : this.soundRecordingUrl,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    sizeMmFemaleMin: sizeMmFemaleMin.present
        ? sizeMmFemaleMin.value
        : this.sizeMmFemaleMin,
    sizeMmFemaleMax: sizeMmFemaleMax.present
        ? sizeMmFemaleMax.value
        : this.sizeMmFemaleMax,
    sizeMmMaleMin: sizeMmMaleMin.present
        ? sizeMmMaleMin.value
        : this.sizeMmMaleMin,
    sizeMmMaleMax: sizeMmMaleMax.present
        ? sizeMmMaleMax.value
        : this.sizeMmMaleMax,
    buildsWeb: buildsWeb.present ? buildsWeb.value : this.buildsWeb,
    webType: webType.present ? webType.value : this.webType,
    venomousToHumans: venomousToHumans.present
        ? venomousToHumans.value
        : this.venomousToHumans,
    inaturalistTaxonId: inaturalistTaxonId.present
        ? inaturalistTaxonId.value
        : this.inaturalistTaxonId,
    datazoneId: datazoneId.present ? datazoneId.value : this.datazoneId,
  );
  SpeciesRow copyWithCompanion(SpeciesRowsCompanion data) {
    return SpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      commonNameEs: data.commonNameEs.present
          ? data.commonNameEs.value
          : this.commonNameEs,
      commonNameEn: data.commonNameEn.present
          ? data.commonNameEn.value
          : this.commonNameEn,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      conservationStatus: data.conservationStatus.present
          ? data.conservationStatus.value
          : this.conservationStatus,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      sizeCm: data.sizeCm.present ? data.sizeCm.value : this.sizeCm,
      populationEstimate: data.populationEstimate.present
          ? data.populationEstimate.value
          : this.populationEstimate,
      lifespanYears: data.lifespanYears.present
          ? data.lifespanYears.value
          : this.lifespanYears,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      habitatEs: data.habitatEs.present ? data.habitatEs.value : this.habitatEs,
      habitatEn: data.habitatEn.present ? data.habitatEn.value : this.habitatEn,
      heroImageUrl: data.heroImageUrl.present
          ? data.heroImageUrl.value
          : this.heroImageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      isEndemic: data.isEndemic.present ? data.isEndemic.value : this.isEndemic,
      taxonomyKingdom: data.taxonomyKingdom.present
          ? data.taxonomyKingdom.value
          : this.taxonomyKingdom,
      taxonomyPhylum: data.taxonomyPhylum.present
          ? data.taxonomyPhylum.value
          : this.taxonomyPhylum,
      taxonomyClass: data.taxonomyClass.present
          ? data.taxonomyClass.value
          : this.taxonomyClass,
      taxonomyOrder: data.taxonomyOrder.present
          ? data.taxonomyOrder.value
          : this.taxonomyOrder,
      taxonomyFamily: data.taxonomyFamily.present
          ? data.taxonomyFamily.value
          : this.taxonomyFamily,
      taxonomyGenus: data.taxonomyGenus.present
          ? data.taxonomyGenus.value
          : this.taxonomyGenus,
      isNative: data.isNative.present ? data.isNative.value : this.isNative,
      isIntroduced: data.isIntroduced.present
          ? data.isIntroduced.value
          : this.isIntroduced,
      endemismLevel: data.endemismLevel.present
          ? data.endemismLevel.value
          : this.endemismLevel,
      populationTrend: data.populationTrend.present
          ? data.populationTrend.value
          : this.populationTrend,
      breedingSeason: data.breedingSeason.present
          ? data.breedingSeason.value
          : this.breedingSeason,
      clutchSize: data.clutchSize.present
          ? data.clutchSize.value
          : this.clutchSize,
      reproductiveFrequency: data.reproductiveFrequency.present
          ? data.reproductiveFrequency.value
          : this.reproductiveFrequency,
      socialStructure: data.socialStructure.present
          ? data.socialStructure.value
          : this.socialStructure,
      activityPattern: data.activityPattern.present
          ? data.activityPattern.value
          : this.activityPattern,
      dietType: data.dietType.present ? data.dietType.value : this.dietType,
      primaryFoodSources: data.primaryFoodSources.present
          ? data.primaryFoodSources.value
          : this.primaryFoodSources,
      altitudeMinM: data.altitudeMinM.present
          ? data.altitudeMinM.value
          : this.altitudeMinM,
      altitudeMaxM: data.altitudeMaxM.present
          ? data.altitudeMaxM.value
          : this.altitudeMaxM,
      depthMinM: data.depthMinM.present ? data.depthMinM.value : this.depthMinM,
      depthMaxM: data.depthMaxM.present ? data.depthMaxM.value : this.depthMaxM,
      scientificNameAuthorship: data.scientificNameAuthorship.present
          ? data.scientificNameAuthorship.value
          : this.scientificNameAuthorship,
      distinguishingFeaturesEs: data.distinguishingFeaturesEs.present
          ? data.distinguishingFeaturesEs.value
          : this.distinguishingFeaturesEs,
      distinguishingFeaturesEn: data.distinguishingFeaturesEn.present
          ? data.distinguishingFeaturesEn.value
          : this.distinguishingFeaturesEn,
      sexualDimorphism: data.sexualDimorphism.present
          ? data.sexualDimorphism.value
          : this.sexualDimorphism,
      gbifTaxonId: data.gbifTaxonId.present
          ? data.gbifTaxonId.value
          : this.gbifTaxonId,
      eolPageId: data.eolPageId.present ? data.eolPageId.value : this.eolPageId,
      iucnAssessmentUrl: data.iucnAssessmentUrl.present
          ? data.iucnAssessmentUrl.value
          : this.iucnAssessmentUrl,
      soundRecordingUrl: data.soundRecordingUrl.present
          ? data.soundRecordingUrl.value
          : this.soundRecordingUrl,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      sizeMmFemaleMin: data.sizeMmFemaleMin.present
          ? data.sizeMmFemaleMin.value
          : this.sizeMmFemaleMin,
      sizeMmFemaleMax: data.sizeMmFemaleMax.present
          ? data.sizeMmFemaleMax.value
          : this.sizeMmFemaleMax,
      sizeMmMaleMin: data.sizeMmMaleMin.present
          ? data.sizeMmMaleMin.value
          : this.sizeMmMaleMin,
      sizeMmMaleMax: data.sizeMmMaleMax.present
          ? data.sizeMmMaleMax.value
          : this.sizeMmMaleMax,
      buildsWeb: data.buildsWeb.present ? data.buildsWeb.value : this.buildsWeb,
      webType: data.webType.present ? data.webType.value : this.webType,
      venomousToHumans: data.venomousToHumans.present
          ? data.venomousToHumans.value
          : this.venomousToHumans,
      inaturalistTaxonId: data.inaturalistTaxonId.present
          ? data.inaturalistTaxonId.value
          : this.inaturalistTaxonId,
      datazoneId: data.datazoneId.present
          ? data.datazoneId.value
          : this.datazoneId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('commonNameEs: $commonNameEs, ')
          ..write('commonNameEn: $commonNameEn, ')
          ..write('scientificName: $scientificName, ')
          ..write('conservationStatus: $conservationStatus, ')
          ..write('weightKg: $weightKg, ')
          ..write('sizeCm: $sizeCm, ')
          ..write('populationEstimate: $populationEstimate, ')
          ..write('lifespanYears: $lifespanYears, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('habitatEs: $habitatEs, ')
          ..write('habitatEn: $habitatEn, ')
          ..write('heroImageUrl: $heroImageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isEndemic: $isEndemic, ')
          ..write('taxonomyKingdom: $taxonomyKingdom, ')
          ..write('taxonomyPhylum: $taxonomyPhylum, ')
          ..write('taxonomyClass: $taxonomyClass, ')
          ..write('taxonomyOrder: $taxonomyOrder, ')
          ..write('taxonomyFamily: $taxonomyFamily, ')
          ..write('taxonomyGenus: $taxonomyGenus, ')
          ..write('isNative: $isNative, ')
          ..write('isIntroduced: $isIntroduced, ')
          ..write('endemismLevel: $endemismLevel, ')
          ..write('populationTrend: $populationTrend, ')
          ..write('breedingSeason: $breedingSeason, ')
          ..write('clutchSize: $clutchSize, ')
          ..write('reproductiveFrequency: $reproductiveFrequency, ')
          ..write('socialStructure: $socialStructure, ')
          ..write('activityPattern: $activityPattern, ')
          ..write('dietType: $dietType, ')
          ..write('primaryFoodSources: $primaryFoodSources, ')
          ..write('altitudeMinM: $altitudeMinM, ')
          ..write('altitudeMaxM: $altitudeMaxM, ')
          ..write('depthMinM: $depthMinM, ')
          ..write('depthMaxM: $depthMaxM, ')
          ..write('scientificNameAuthorship: $scientificNameAuthorship, ')
          ..write('distinguishingFeaturesEs: $distinguishingFeaturesEs, ')
          ..write('distinguishingFeaturesEn: $distinguishingFeaturesEn, ')
          ..write('sexualDimorphism: $sexualDimorphism, ')
          ..write('gbifTaxonId: $gbifTaxonId, ')
          ..write('eolPageId: $eolPageId, ')
          ..write('iucnAssessmentUrl: $iucnAssessmentUrl, ')
          ..write('soundRecordingUrl: $soundRecordingUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('sizeMmFemaleMin: $sizeMmFemaleMin, ')
          ..write('sizeMmFemaleMax: $sizeMmFemaleMax, ')
          ..write('sizeMmMaleMin: $sizeMmMaleMin, ')
          ..write('sizeMmMaleMax: $sizeMmMaleMax, ')
          ..write('buildsWeb: $buildsWeb, ')
          ..write('webType: $webType, ')
          ..write('venomousToHumans: $venomousToHumans, ')
          ..write('inaturalistTaxonId: $inaturalistTaxonId, ')
          ..write('datazoneId: $datazoneId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    categoryId,
    commonNameEs,
    commonNameEn,
    scientificName,
    conservationStatus,
    weightKg,
    sizeCm,
    populationEstimate,
    lifespanYears,
    descriptionEs,
    descriptionEn,
    habitatEs,
    habitatEn,
    heroImageUrl,
    thumbnailUrl,
    isEndemic,
    taxonomyKingdom,
    taxonomyPhylum,
    taxonomyClass,
    taxonomyOrder,
    taxonomyFamily,
    taxonomyGenus,
    isNative,
    isIntroduced,
    endemismLevel,
    populationTrend,
    breedingSeason,
    clutchSize,
    reproductiveFrequency,
    socialStructure,
    activityPattern,
    dietType,
    primaryFoodSources,
    altitudeMinM,
    altitudeMaxM,
    depthMinM,
    depthMaxM,
    scientificNameAuthorship,
    distinguishingFeaturesEs,
    distinguishingFeaturesEn,
    sexualDimorphism,
    gbifTaxonId,
    eolPageId,
    iucnAssessmentUrl,
    soundRecordingUrl,
    videoUrl,
    sizeMmFemaleMin,
    sizeMmFemaleMax,
    sizeMmMaleMin,
    sizeMmMaleMax,
    buildsWeb,
    webType,
    venomousToHumans,
    inaturalistTaxonId,
    datazoneId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.commonNameEs == this.commonNameEs &&
          other.commonNameEn == this.commonNameEn &&
          other.scientificName == this.scientificName &&
          other.conservationStatus == this.conservationStatus &&
          other.weightKg == this.weightKg &&
          other.sizeCm == this.sizeCm &&
          other.populationEstimate == this.populationEstimate &&
          other.lifespanYears == this.lifespanYears &&
          other.descriptionEs == this.descriptionEs &&
          other.descriptionEn == this.descriptionEn &&
          other.habitatEs == this.habitatEs &&
          other.habitatEn == this.habitatEn &&
          other.heroImageUrl == this.heroImageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.isEndemic == this.isEndemic &&
          other.taxonomyKingdom == this.taxonomyKingdom &&
          other.taxonomyPhylum == this.taxonomyPhylum &&
          other.taxonomyClass == this.taxonomyClass &&
          other.taxonomyOrder == this.taxonomyOrder &&
          other.taxonomyFamily == this.taxonomyFamily &&
          other.taxonomyGenus == this.taxonomyGenus &&
          other.isNative == this.isNative &&
          other.isIntroduced == this.isIntroduced &&
          other.endemismLevel == this.endemismLevel &&
          other.populationTrend == this.populationTrend &&
          other.breedingSeason == this.breedingSeason &&
          other.clutchSize == this.clutchSize &&
          other.reproductiveFrequency == this.reproductiveFrequency &&
          other.socialStructure == this.socialStructure &&
          other.activityPattern == this.activityPattern &&
          other.dietType == this.dietType &&
          other.primaryFoodSources == this.primaryFoodSources &&
          other.altitudeMinM == this.altitudeMinM &&
          other.altitudeMaxM == this.altitudeMaxM &&
          other.depthMinM == this.depthMinM &&
          other.depthMaxM == this.depthMaxM &&
          other.scientificNameAuthorship == this.scientificNameAuthorship &&
          other.distinguishingFeaturesEs == this.distinguishingFeaturesEs &&
          other.distinguishingFeaturesEn == this.distinguishingFeaturesEn &&
          other.sexualDimorphism == this.sexualDimorphism &&
          other.gbifTaxonId == this.gbifTaxonId &&
          other.eolPageId == this.eolPageId &&
          other.iucnAssessmentUrl == this.iucnAssessmentUrl &&
          other.soundRecordingUrl == this.soundRecordingUrl &&
          other.videoUrl == this.videoUrl &&
          other.sizeMmFemaleMin == this.sizeMmFemaleMin &&
          other.sizeMmFemaleMax == this.sizeMmFemaleMax &&
          other.sizeMmMaleMin == this.sizeMmMaleMin &&
          other.sizeMmMaleMax == this.sizeMmMaleMax &&
          other.buildsWeb == this.buildsWeb &&
          other.webType == this.webType &&
          other.venomousToHumans == this.venomousToHumans &&
          other.inaturalistTaxonId == this.inaturalistTaxonId &&
          other.datazoneId == this.datazoneId);
}

class SpeciesRowsCompanion extends UpdateCompanion<SpeciesRow> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> commonNameEs;
  final Value<String> commonNameEn;
  final Value<String> scientificName;
  final Value<String?> conservationStatus;
  final Value<double?> weightKg;
  final Value<double?> sizeCm;
  final Value<int?> populationEstimate;
  final Value<int?> lifespanYears;
  final Value<String?> descriptionEs;
  final Value<String?> descriptionEn;
  final Value<String?> habitatEs;
  final Value<String?> habitatEn;
  final Value<String?> heroImageUrl;
  final Value<String?> thumbnailUrl;
  final Value<bool> isEndemic;
  final Value<String?> taxonomyKingdom;
  final Value<String?> taxonomyPhylum;
  final Value<String?> taxonomyClass;
  final Value<String?> taxonomyOrder;
  final Value<String?> taxonomyFamily;
  final Value<String?> taxonomyGenus;
  final Value<bool?> isNative;
  final Value<bool?> isIntroduced;
  final Value<String?> endemismLevel;
  final Value<String?> populationTrend;
  final Value<String?> breedingSeason;
  final Value<String?> clutchSize;
  final Value<String?> reproductiveFrequency;
  final Value<String?> socialStructure;
  final Value<String?> activityPattern;
  final Value<String?> dietType;
  final Value<List<String>?> primaryFoodSources;
  final Value<int?> altitudeMinM;
  final Value<int?> altitudeMaxM;
  final Value<int?> depthMinM;
  final Value<int?> depthMaxM;
  final Value<String?> scientificNameAuthorship;
  final Value<String?> distinguishingFeaturesEs;
  final Value<String?> distinguishingFeaturesEn;
  final Value<String?> sexualDimorphism;
  final Value<String?> gbifTaxonId;
  final Value<String?> eolPageId;
  final Value<String?> iucnAssessmentUrl;
  final Value<String?> soundRecordingUrl;
  final Value<String?> videoUrl;
  final Value<double?> sizeMmFemaleMin;
  final Value<double?> sizeMmFemaleMax;
  final Value<double?> sizeMmMaleMin;
  final Value<double?> sizeMmMaleMax;
  final Value<bool?> buildsWeb;
  final Value<String?> webType;
  final Value<bool?> venomousToHumans;
  final Value<int?> inaturalistTaxonId;
  final Value<int?> datazoneId;
  const SpeciesRowsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.commonNameEs = const Value.absent(),
    this.commonNameEn = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.conservationStatus = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sizeCm = const Value.absent(),
    this.populationEstimate = const Value.absent(),
    this.lifespanYears = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.habitatEs = const Value.absent(),
    this.habitatEn = const Value.absent(),
    this.heroImageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.isEndemic = const Value.absent(),
    this.taxonomyKingdom = const Value.absent(),
    this.taxonomyPhylum = const Value.absent(),
    this.taxonomyClass = const Value.absent(),
    this.taxonomyOrder = const Value.absent(),
    this.taxonomyFamily = const Value.absent(),
    this.taxonomyGenus = const Value.absent(),
    this.isNative = const Value.absent(),
    this.isIntroduced = const Value.absent(),
    this.endemismLevel = const Value.absent(),
    this.populationTrend = const Value.absent(),
    this.breedingSeason = const Value.absent(),
    this.clutchSize = const Value.absent(),
    this.reproductiveFrequency = const Value.absent(),
    this.socialStructure = const Value.absent(),
    this.activityPattern = const Value.absent(),
    this.dietType = const Value.absent(),
    this.primaryFoodSources = const Value.absent(),
    this.altitudeMinM = const Value.absent(),
    this.altitudeMaxM = const Value.absent(),
    this.depthMinM = const Value.absent(),
    this.depthMaxM = const Value.absent(),
    this.scientificNameAuthorship = const Value.absent(),
    this.distinguishingFeaturesEs = const Value.absent(),
    this.distinguishingFeaturesEn = const Value.absent(),
    this.sexualDimorphism = const Value.absent(),
    this.gbifTaxonId = const Value.absent(),
    this.eolPageId = const Value.absent(),
    this.iucnAssessmentUrl = const Value.absent(),
    this.soundRecordingUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.sizeMmFemaleMin = const Value.absent(),
    this.sizeMmFemaleMax = const Value.absent(),
    this.sizeMmMaleMin = const Value.absent(),
    this.sizeMmMaleMax = const Value.absent(),
    this.buildsWeb = const Value.absent(),
    this.webType = const Value.absent(),
    this.venomousToHumans = const Value.absent(),
    this.inaturalistTaxonId = const Value.absent(),
    this.datazoneId = const Value.absent(),
  });
  SpeciesRowsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String commonNameEs,
    required String commonNameEn,
    required String scientificName,
    this.conservationStatus = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sizeCm = const Value.absent(),
    this.populationEstimate = const Value.absent(),
    this.lifespanYears = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.habitatEs = const Value.absent(),
    this.habitatEn = const Value.absent(),
    this.heroImageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.isEndemic = const Value.absent(),
    this.taxonomyKingdom = const Value.absent(),
    this.taxonomyPhylum = const Value.absent(),
    this.taxonomyClass = const Value.absent(),
    this.taxonomyOrder = const Value.absent(),
    this.taxonomyFamily = const Value.absent(),
    this.taxonomyGenus = const Value.absent(),
    this.isNative = const Value.absent(),
    this.isIntroduced = const Value.absent(),
    this.endemismLevel = const Value.absent(),
    this.populationTrend = const Value.absent(),
    this.breedingSeason = const Value.absent(),
    this.clutchSize = const Value.absent(),
    this.reproductiveFrequency = const Value.absent(),
    this.socialStructure = const Value.absent(),
    this.activityPattern = const Value.absent(),
    this.dietType = const Value.absent(),
    this.primaryFoodSources = const Value.absent(),
    this.altitudeMinM = const Value.absent(),
    this.altitudeMaxM = const Value.absent(),
    this.depthMinM = const Value.absent(),
    this.depthMaxM = const Value.absent(),
    this.scientificNameAuthorship = const Value.absent(),
    this.distinguishingFeaturesEs = const Value.absent(),
    this.distinguishingFeaturesEn = const Value.absent(),
    this.sexualDimorphism = const Value.absent(),
    this.gbifTaxonId = const Value.absent(),
    this.eolPageId = const Value.absent(),
    this.iucnAssessmentUrl = const Value.absent(),
    this.soundRecordingUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.sizeMmFemaleMin = const Value.absent(),
    this.sizeMmFemaleMax = const Value.absent(),
    this.sizeMmMaleMin = const Value.absent(),
    this.sizeMmMaleMax = const Value.absent(),
    this.buildsWeb = const Value.absent(),
    this.webType = const Value.absent(),
    this.venomousToHumans = const Value.absent(),
    this.inaturalistTaxonId = const Value.absent(),
    this.datazoneId = const Value.absent(),
  }) : categoryId = Value(categoryId),
       commonNameEs = Value(commonNameEs),
       commonNameEn = Value(commonNameEn),
       scientificName = Value(scientificName);
  static Insertable<SpeciesRow> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? commonNameEs,
    Expression<String>? commonNameEn,
    Expression<String>? scientificName,
    Expression<String>? conservationStatus,
    Expression<double>? weightKg,
    Expression<double>? sizeCm,
    Expression<int>? populationEstimate,
    Expression<int>? lifespanYears,
    Expression<String>? descriptionEs,
    Expression<String>? descriptionEn,
    Expression<String>? habitatEs,
    Expression<String>? habitatEn,
    Expression<String>? heroImageUrl,
    Expression<String>? thumbnailUrl,
    Expression<bool>? isEndemic,
    Expression<String>? taxonomyKingdom,
    Expression<String>? taxonomyPhylum,
    Expression<String>? taxonomyClass,
    Expression<String>? taxonomyOrder,
    Expression<String>? taxonomyFamily,
    Expression<String>? taxonomyGenus,
    Expression<bool>? isNative,
    Expression<bool>? isIntroduced,
    Expression<String>? endemismLevel,
    Expression<String>? populationTrend,
    Expression<String>? breedingSeason,
    Expression<String>? clutchSize,
    Expression<String>? reproductiveFrequency,
    Expression<String>? socialStructure,
    Expression<String>? activityPattern,
    Expression<String>? dietType,
    Expression<String>? primaryFoodSources,
    Expression<int>? altitudeMinM,
    Expression<int>? altitudeMaxM,
    Expression<int>? depthMinM,
    Expression<int>? depthMaxM,
    Expression<String>? scientificNameAuthorship,
    Expression<String>? distinguishingFeaturesEs,
    Expression<String>? distinguishingFeaturesEn,
    Expression<String>? sexualDimorphism,
    Expression<String>? gbifTaxonId,
    Expression<String>? eolPageId,
    Expression<String>? iucnAssessmentUrl,
    Expression<String>? soundRecordingUrl,
    Expression<String>? videoUrl,
    Expression<double>? sizeMmFemaleMin,
    Expression<double>? sizeMmFemaleMax,
    Expression<double>? sizeMmMaleMin,
    Expression<double>? sizeMmMaleMax,
    Expression<bool>? buildsWeb,
    Expression<String>? webType,
    Expression<bool>? venomousToHumans,
    Expression<int>? inaturalistTaxonId,
    Expression<int>? datazoneId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (commonNameEs != null) 'common_name_es': commonNameEs,
      if (commonNameEn != null) 'common_name_en': commonNameEn,
      if (scientificName != null) 'scientific_name': scientificName,
      if (conservationStatus != null) 'conservation_status': conservationStatus,
      if (weightKg != null) 'weight_kg': weightKg,
      if (sizeCm != null) 'size_cm': sizeCm,
      if (populationEstimate != null) 'population_estimate': populationEstimate,
      if (lifespanYears != null) 'lifespan_years': lifespanYears,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (habitatEs != null) 'habitat_es': habitatEs,
      if (habitatEn != null) 'habitat_en': habitatEn,
      if (heroImageUrl != null) 'hero_image_url': heroImageUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isEndemic != null) 'is_endemic': isEndemic,
      if (taxonomyKingdom != null) 'taxonomy_kingdom': taxonomyKingdom,
      if (taxonomyPhylum != null) 'taxonomy_phylum': taxonomyPhylum,
      if (taxonomyClass != null) 'taxonomy_class': taxonomyClass,
      if (taxonomyOrder != null) 'taxonomy_order': taxonomyOrder,
      if (taxonomyFamily != null) 'taxonomy_family': taxonomyFamily,
      if (taxonomyGenus != null) 'taxonomy_genus': taxonomyGenus,
      if (isNative != null) 'is_native': isNative,
      if (isIntroduced != null) 'is_introduced': isIntroduced,
      if (endemismLevel != null) 'endemism_level': endemismLevel,
      if (populationTrend != null) 'population_trend': populationTrend,
      if (breedingSeason != null) 'breeding_season': breedingSeason,
      if (clutchSize != null) 'clutch_size': clutchSize,
      if (reproductiveFrequency != null)
        'reproductive_frequency': reproductiveFrequency,
      if (socialStructure != null) 'social_structure': socialStructure,
      if (activityPattern != null) 'activity_pattern': activityPattern,
      if (dietType != null) 'diet_type': dietType,
      if (primaryFoodSources != null)
        'primary_food_sources': primaryFoodSources,
      if (altitudeMinM != null) 'altitude_min_m': altitudeMinM,
      if (altitudeMaxM != null) 'altitude_max_m': altitudeMaxM,
      if (depthMinM != null) 'depth_min_m': depthMinM,
      if (depthMaxM != null) 'depth_max_m': depthMaxM,
      if (scientificNameAuthorship != null)
        'scientific_name_authorship': scientificNameAuthorship,
      if (distinguishingFeaturesEs != null)
        'distinguishing_features_es': distinguishingFeaturesEs,
      if (distinguishingFeaturesEn != null)
        'distinguishing_features_en': distinguishingFeaturesEn,
      if (sexualDimorphism != null) 'sexual_dimorphism': sexualDimorphism,
      if (gbifTaxonId != null) 'gbif_taxon_id': gbifTaxonId,
      if (eolPageId != null) 'eol_page_id': eolPageId,
      if (iucnAssessmentUrl != null) 'iucn_assessment_url': iucnAssessmentUrl,
      if (soundRecordingUrl != null) 'sound_recording_url': soundRecordingUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (sizeMmFemaleMin != null) 'size_mm_female_min': sizeMmFemaleMin,
      if (sizeMmFemaleMax != null) 'size_mm_female_max': sizeMmFemaleMax,
      if (sizeMmMaleMin != null) 'size_mm_male_min': sizeMmMaleMin,
      if (sizeMmMaleMax != null) 'size_mm_male_max': sizeMmMaleMax,
      if (buildsWeb != null) 'builds_web': buildsWeb,
      if (webType != null) 'web_type': webType,
      if (venomousToHumans != null) 'venomous_to_humans': venomousToHumans,
      if (inaturalistTaxonId != null)
        'inaturalist_taxon_id': inaturalistTaxonId,
      if (datazoneId != null) 'datazone_id': datazoneId,
    });
  }

  SpeciesRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? commonNameEs,
    Value<String>? commonNameEn,
    Value<String>? scientificName,
    Value<String?>? conservationStatus,
    Value<double?>? weightKg,
    Value<double?>? sizeCm,
    Value<int?>? populationEstimate,
    Value<int?>? lifespanYears,
    Value<String?>? descriptionEs,
    Value<String?>? descriptionEn,
    Value<String?>? habitatEs,
    Value<String?>? habitatEn,
    Value<String?>? heroImageUrl,
    Value<String?>? thumbnailUrl,
    Value<bool>? isEndemic,
    Value<String?>? taxonomyKingdom,
    Value<String?>? taxonomyPhylum,
    Value<String?>? taxonomyClass,
    Value<String?>? taxonomyOrder,
    Value<String?>? taxonomyFamily,
    Value<String?>? taxonomyGenus,
    Value<bool?>? isNative,
    Value<bool?>? isIntroduced,
    Value<String?>? endemismLevel,
    Value<String?>? populationTrend,
    Value<String?>? breedingSeason,
    Value<String?>? clutchSize,
    Value<String?>? reproductiveFrequency,
    Value<String?>? socialStructure,
    Value<String?>? activityPattern,
    Value<String?>? dietType,
    Value<List<String>?>? primaryFoodSources,
    Value<int?>? altitudeMinM,
    Value<int?>? altitudeMaxM,
    Value<int?>? depthMinM,
    Value<int?>? depthMaxM,
    Value<String?>? scientificNameAuthorship,
    Value<String?>? distinguishingFeaturesEs,
    Value<String?>? distinguishingFeaturesEn,
    Value<String?>? sexualDimorphism,
    Value<String?>? gbifTaxonId,
    Value<String?>? eolPageId,
    Value<String?>? iucnAssessmentUrl,
    Value<String?>? soundRecordingUrl,
    Value<String?>? videoUrl,
    Value<double?>? sizeMmFemaleMin,
    Value<double?>? sizeMmFemaleMax,
    Value<double?>? sizeMmMaleMin,
    Value<double?>? sizeMmMaleMax,
    Value<bool?>? buildsWeb,
    Value<String?>? webType,
    Value<bool?>? venomousToHumans,
    Value<int?>? inaturalistTaxonId,
    Value<int?>? datazoneId,
  }) {
    return SpeciesRowsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      commonNameEs: commonNameEs ?? this.commonNameEs,
      commonNameEn: commonNameEn ?? this.commonNameEn,
      scientificName: scientificName ?? this.scientificName,
      conservationStatus: conservationStatus ?? this.conservationStatus,
      weightKg: weightKg ?? this.weightKg,
      sizeCm: sizeCm ?? this.sizeCm,
      populationEstimate: populationEstimate ?? this.populationEstimate,
      lifespanYears: lifespanYears ?? this.lifespanYears,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      habitatEs: habitatEs ?? this.habitatEs,
      habitatEn: habitatEn ?? this.habitatEn,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isEndemic: isEndemic ?? this.isEndemic,
      taxonomyKingdom: taxonomyKingdom ?? this.taxonomyKingdom,
      taxonomyPhylum: taxonomyPhylum ?? this.taxonomyPhylum,
      taxonomyClass: taxonomyClass ?? this.taxonomyClass,
      taxonomyOrder: taxonomyOrder ?? this.taxonomyOrder,
      taxonomyFamily: taxonomyFamily ?? this.taxonomyFamily,
      taxonomyGenus: taxonomyGenus ?? this.taxonomyGenus,
      isNative: isNative ?? this.isNative,
      isIntroduced: isIntroduced ?? this.isIntroduced,
      endemismLevel: endemismLevel ?? this.endemismLevel,
      populationTrend: populationTrend ?? this.populationTrend,
      breedingSeason: breedingSeason ?? this.breedingSeason,
      clutchSize: clutchSize ?? this.clutchSize,
      reproductiveFrequency:
          reproductiveFrequency ?? this.reproductiveFrequency,
      socialStructure: socialStructure ?? this.socialStructure,
      activityPattern: activityPattern ?? this.activityPattern,
      dietType: dietType ?? this.dietType,
      primaryFoodSources: primaryFoodSources ?? this.primaryFoodSources,
      altitudeMinM: altitudeMinM ?? this.altitudeMinM,
      altitudeMaxM: altitudeMaxM ?? this.altitudeMaxM,
      depthMinM: depthMinM ?? this.depthMinM,
      depthMaxM: depthMaxM ?? this.depthMaxM,
      scientificNameAuthorship:
          scientificNameAuthorship ?? this.scientificNameAuthorship,
      distinguishingFeaturesEs:
          distinguishingFeaturesEs ?? this.distinguishingFeaturesEs,
      distinguishingFeaturesEn:
          distinguishingFeaturesEn ?? this.distinguishingFeaturesEn,
      sexualDimorphism: sexualDimorphism ?? this.sexualDimorphism,
      gbifTaxonId: gbifTaxonId ?? this.gbifTaxonId,
      eolPageId: eolPageId ?? this.eolPageId,
      iucnAssessmentUrl: iucnAssessmentUrl ?? this.iucnAssessmentUrl,
      soundRecordingUrl: soundRecordingUrl ?? this.soundRecordingUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      sizeMmFemaleMin: sizeMmFemaleMin ?? this.sizeMmFemaleMin,
      sizeMmFemaleMax: sizeMmFemaleMax ?? this.sizeMmFemaleMax,
      sizeMmMaleMin: sizeMmMaleMin ?? this.sizeMmMaleMin,
      sizeMmMaleMax: sizeMmMaleMax ?? this.sizeMmMaleMax,
      buildsWeb: buildsWeb ?? this.buildsWeb,
      webType: webType ?? this.webType,
      venomousToHumans: venomousToHumans ?? this.venomousToHumans,
      inaturalistTaxonId: inaturalistTaxonId ?? this.inaturalistTaxonId,
      datazoneId: datazoneId ?? this.datazoneId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (commonNameEs.present) {
      map['common_name_es'] = Variable<String>(commonNameEs.value);
    }
    if (commonNameEn.present) {
      map['common_name_en'] = Variable<String>(commonNameEn.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (conservationStatus.present) {
      map['conservation_status'] = Variable<String>(conservationStatus.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (sizeCm.present) {
      map['size_cm'] = Variable<double>(sizeCm.value);
    }
    if (populationEstimate.present) {
      map['population_estimate'] = Variable<int>(populationEstimate.value);
    }
    if (lifespanYears.present) {
      map['lifespan_years'] = Variable<int>(lifespanYears.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (habitatEs.present) {
      map['habitat_es'] = Variable<String>(habitatEs.value);
    }
    if (habitatEn.present) {
      map['habitat_en'] = Variable<String>(habitatEn.value);
    }
    if (heroImageUrl.present) {
      map['hero_image_url'] = Variable<String>(heroImageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (isEndemic.present) {
      map['is_endemic'] = Variable<bool>(isEndemic.value);
    }
    if (taxonomyKingdom.present) {
      map['taxonomy_kingdom'] = Variable<String>(taxonomyKingdom.value);
    }
    if (taxonomyPhylum.present) {
      map['taxonomy_phylum'] = Variable<String>(taxonomyPhylum.value);
    }
    if (taxonomyClass.present) {
      map['taxonomy_class'] = Variable<String>(taxonomyClass.value);
    }
    if (taxonomyOrder.present) {
      map['taxonomy_order'] = Variable<String>(taxonomyOrder.value);
    }
    if (taxonomyFamily.present) {
      map['taxonomy_family'] = Variable<String>(taxonomyFamily.value);
    }
    if (taxonomyGenus.present) {
      map['taxonomy_genus'] = Variable<String>(taxonomyGenus.value);
    }
    if (isNative.present) {
      map['is_native'] = Variable<bool>(isNative.value);
    }
    if (isIntroduced.present) {
      map['is_introduced'] = Variable<bool>(isIntroduced.value);
    }
    if (endemismLevel.present) {
      map['endemism_level'] = Variable<String>(endemismLevel.value);
    }
    if (populationTrend.present) {
      map['population_trend'] = Variable<String>(populationTrend.value);
    }
    if (breedingSeason.present) {
      map['breeding_season'] = Variable<String>(breedingSeason.value);
    }
    if (clutchSize.present) {
      map['clutch_size'] = Variable<String>(clutchSize.value);
    }
    if (reproductiveFrequency.present) {
      map['reproductive_frequency'] = Variable<String>(
        reproductiveFrequency.value,
      );
    }
    if (socialStructure.present) {
      map['social_structure'] = Variable<String>(socialStructure.value);
    }
    if (activityPattern.present) {
      map['activity_pattern'] = Variable<String>(activityPattern.value);
    }
    if (dietType.present) {
      map['diet_type'] = Variable<String>(dietType.value);
    }
    if (primaryFoodSources.present) {
      map['primary_food_sources'] = Variable<String>(
        $SpeciesRowsTable.$converterprimaryFoodSources.toSql(
          primaryFoodSources.value,
        ),
      );
    }
    if (altitudeMinM.present) {
      map['altitude_min_m'] = Variable<int>(altitudeMinM.value);
    }
    if (altitudeMaxM.present) {
      map['altitude_max_m'] = Variable<int>(altitudeMaxM.value);
    }
    if (depthMinM.present) {
      map['depth_min_m'] = Variable<int>(depthMinM.value);
    }
    if (depthMaxM.present) {
      map['depth_max_m'] = Variable<int>(depthMaxM.value);
    }
    if (scientificNameAuthorship.present) {
      map['scientific_name_authorship'] = Variable<String>(
        scientificNameAuthorship.value,
      );
    }
    if (distinguishingFeaturesEs.present) {
      map['distinguishing_features_es'] = Variable<String>(
        distinguishingFeaturesEs.value,
      );
    }
    if (distinguishingFeaturesEn.present) {
      map['distinguishing_features_en'] = Variable<String>(
        distinguishingFeaturesEn.value,
      );
    }
    if (sexualDimorphism.present) {
      map['sexual_dimorphism'] = Variable<String>(sexualDimorphism.value);
    }
    if (gbifTaxonId.present) {
      map['gbif_taxon_id'] = Variable<String>(gbifTaxonId.value);
    }
    if (eolPageId.present) {
      map['eol_page_id'] = Variable<String>(eolPageId.value);
    }
    if (iucnAssessmentUrl.present) {
      map['iucn_assessment_url'] = Variable<String>(iucnAssessmentUrl.value);
    }
    if (soundRecordingUrl.present) {
      map['sound_recording_url'] = Variable<String>(soundRecordingUrl.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (sizeMmFemaleMin.present) {
      map['size_mm_female_min'] = Variable<double>(sizeMmFemaleMin.value);
    }
    if (sizeMmFemaleMax.present) {
      map['size_mm_female_max'] = Variable<double>(sizeMmFemaleMax.value);
    }
    if (sizeMmMaleMin.present) {
      map['size_mm_male_min'] = Variable<double>(sizeMmMaleMin.value);
    }
    if (sizeMmMaleMax.present) {
      map['size_mm_male_max'] = Variable<double>(sizeMmMaleMax.value);
    }
    if (buildsWeb.present) {
      map['builds_web'] = Variable<bool>(buildsWeb.value);
    }
    if (webType.present) {
      map['web_type'] = Variable<String>(webType.value);
    }
    if (venomousToHumans.present) {
      map['venomous_to_humans'] = Variable<bool>(venomousToHumans.value);
    }
    if (inaturalistTaxonId.present) {
      map['inaturalist_taxon_id'] = Variable<int>(inaturalistTaxonId.value);
    }
    if (datazoneId.present) {
      map['datazone_id'] = Variable<int>(datazoneId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRowsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('commonNameEs: $commonNameEs, ')
          ..write('commonNameEn: $commonNameEn, ')
          ..write('scientificName: $scientificName, ')
          ..write('conservationStatus: $conservationStatus, ')
          ..write('weightKg: $weightKg, ')
          ..write('sizeCm: $sizeCm, ')
          ..write('populationEstimate: $populationEstimate, ')
          ..write('lifespanYears: $lifespanYears, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('habitatEs: $habitatEs, ')
          ..write('habitatEn: $habitatEn, ')
          ..write('heroImageUrl: $heroImageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isEndemic: $isEndemic, ')
          ..write('taxonomyKingdom: $taxonomyKingdom, ')
          ..write('taxonomyPhylum: $taxonomyPhylum, ')
          ..write('taxonomyClass: $taxonomyClass, ')
          ..write('taxonomyOrder: $taxonomyOrder, ')
          ..write('taxonomyFamily: $taxonomyFamily, ')
          ..write('taxonomyGenus: $taxonomyGenus, ')
          ..write('isNative: $isNative, ')
          ..write('isIntroduced: $isIntroduced, ')
          ..write('endemismLevel: $endemismLevel, ')
          ..write('populationTrend: $populationTrend, ')
          ..write('breedingSeason: $breedingSeason, ')
          ..write('clutchSize: $clutchSize, ')
          ..write('reproductiveFrequency: $reproductiveFrequency, ')
          ..write('socialStructure: $socialStructure, ')
          ..write('activityPattern: $activityPattern, ')
          ..write('dietType: $dietType, ')
          ..write('primaryFoodSources: $primaryFoodSources, ')
          ..write('altitudeMinM: $altitudeMinM, ')
          ..write('altitudeMaxM: $altitudeMaxM, ')
          ..write('depthMinM: $depthMinM, ')
          ..write('depthMaxM: $depthMaxM, ')
          ..write('scientificNameAuthorship: $scientificNameAuthorship, ')
          ..write('distinguishingFeaturesEs: $distinguishingFeaturesEs, ')
          ..write('distinguishingFeaturesEn: $distinguishingFeaturesEn, ')
          ..write('sexualDimorphism: $sexualDimorphism, ')
          ..write('gbifTaxonId: $gbifTaxonId, ')
          ..write('eolPageId: $eolPageId, ')
          ..write('iucnAssessmentUrl: $iucnAssessmentUrl, ')
          ..write('soundRecordingUrl: $soundRecordingUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('sizeMmFemaleMin: $sizeMmFemaleMin, ')
          ..write('sizeMmFemaleMax: $sizeMmFemaleMax, ')
          ..write('sizeMmMaleMin: $sizeMmMaleMin, ')
          ..write('sizeMmMaleMax: $sizeMmMaleMax, ')
          ..write('buildsWeb: $buildsWeb, ')
          ..write('webType: $webType, ')
          ..write('venomousToHumans: $venomousToHumans, ')
          ..write('inaturalistTaxonId: $inaturalistTaxonId, ')
          ..write('datazoneId: $datazoneId')
          ..write(')'))
        .toString();
  }
}

class $SightingsTable extends Sightings
    with TableInfo<$SightingsTable, Sighting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SightingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitSiteIdMeta = const VerificationMeta(
    'visitSiteId',
  );
  @override
  late final GeneratedColumn<int> visitSiteId = GeneratedColumn<int>(
    'visit_site_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    speciesId,
    visitSiteId,
    observedAt,
    notes,
    latitude,
    longitude,
    photoUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sightings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sighting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('visit_site_id')) {
      context.handle(
        _visitSiteIdMeta,
        visitSiteId.isAcceptableOrUnknown(
          data['visit_site_id']!,
          _visitSiteIdMeta,
        ),
      );
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sighting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sighting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      visitSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_site_id'],
      ),
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
    );
  }

  @override
  $SightingsTable createAlias(String alias) {
    return $SightingsTable(attachedDatabase, alias);
  }
}

class Sighting extends DataClass implements Insertable<Sighting> {
  final int id;
  final String userId;
  final int speciesId;
  final int? visitSiteId;
  final DateTime? observedAt;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  const Sighting({
    required this.id,
    required this.userId,
    required this.speciesId,
    this.visitSiteId,
    this.observedAt,
    this.notes,
    this.latitude,
    this.longitude,
    this.photoUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['species_id'] = Variable<int>(speciesId);
    if (!nullToAbsent || visitSiteId != null) {
      map['visit_site_id'] = Variable<int>(visitSiteId);
    }
    if (!nullToAbsent || observedAt != null) {
      map['observed_at'] = Variable<DateTime>(observedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    return map;
  }

  SightingsCompanion toCompanion(bool nullToAbsent) {
    return SightingsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: Value(speciesId),
      visitSiteId: visitSiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitSiteId),
      observedAt: observedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(observedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
    );
  }

  factory Sighting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sighting(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      visitSiteId: serializer.fromJson<int?>(json['visitSiteId']),
      observedAt: serializer.fromJson<DateTime?>(json['observedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'speciesId': serializer.toJson<int>(speciesId),
      'visitSiteId': serializer.toJson<int?>(visitSiteId),
      'observedAt': serializer.toJson<DateTime?>(observedAt),
      'notes': serializer.toJson<String?>(notes),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'photoUrl': serializer.toJson<String?>(photoUrl),
    };
  }

  Sighting copyWith({
    int? id,
    String? userId,
    int? speciesId,
    Value<int?> visitSiteId = const Value.absent(),
    Value<DateTime?> observedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
  }) => Sighting(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    speciesId: speciesId ?? this.speciesId,
    visitSiteId: visitSiteId.present ? visitSiteId.value : this.visitSiteId,
    observedAt: observedAt.present ? observedAt.value : this.observedAt,
    notes: notes.present ? notes.value : this.notes,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
  );
  Sighting copyWithCompanion(SightingsCompanion data) {
    return Sighting(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      visitSiteId: data.visitSiteId.present
          ? data.visitSiteId.value
          : this.visitSiteId,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sighting(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('observedAt: $observedAt, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('photoUrl: $photoUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    speciesId,
    visitSiteId,
    observedAt,
    notes,
    latitude,
    longitude,
    photoUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sighting &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId &&
          other.visitSiteId == this.visitSiteId &&
          other.observedAt == this.observedAt &&
          other.notes == this.notes &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.photoUrl == this.photoUrl);
}

class SightingsCompanion extends UpdateCompanion<Sighting> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> speciesId;
  final Value<int?> visitSiteId;
  final Value<DateTime?> observedAt;
  final Value<String?> notes;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> photoUrl;
  const SightingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.visitSiteId = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.photoUrl = const Value.absent(),
  });
  SightingsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int speciesId,
    this.visitSiteId = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.photoUrl = const Value.absent(),
  }) : userId = Value(userId),
       speciesId = Value(speciesId);
  static Insertable<Sighting> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? speciesId,
    Expression<int>? visitSiteId,
    Expression<DateTime>? observedAt,
    Expression<String>? notes,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? photoUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
      if (visitSiteId != null) 'visit_site_id': visitSiteId,
      if (observedAt != null) 'observed_at': observedAt,
      if (notes != null) 'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photoUrl != null) 'photo_url': photoUrl,
    });
  }

  SightingsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? speciesId,
    Value<int?>? visitSiteId,
    Value<DateTime?>? observedAt,
    Value<String?>? notes,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? photoUrl,
  }) {
    return SightingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      visitSiteId: visitSiteId ?? this.visitSiteId,
      observedAt: observedAt ?? this.observedAt,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (visitSiteId.present) {
      map['visit_site_id'] = Variable<int>(visitSiteId.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SightingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('observedAt: $observedAt, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('photoUrl: $photoUrl')
          ..write(')'))
        .toString();
  }
}

class $SpeciesImagesTable extends SpeciesImages
    with TableInfo<$SpeciesImagesTable, SpeciesImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionEsMeta = const VerificationMeta(
    'captionEs',
  );
  @override
  late final GeneratedColumn<String> captionEs = GeneratedColumn<String>(
    'caption_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionEnMeta = const VerificationMeta(
    'captionEn',
  );
  @override
  late final GeneratedColumn<String> captionEn = GeneratedColumn<String>(
    'caption_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardThumbnailUrlMeta = const VerificationMeta(
    'cardThumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> cardThumbnailUrl = GeneratedColumn<String>(
    'card_thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    imageUrl,
    captionEs,
    captionEn,
    sortOrder,
    isPrimary,
    thumbnailUrl,
    cardThumbnailUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('caption_es')) {
      context.handle(
        _captionEsMeta,
        captionEs.isAcceptableOrUnknown(data['caption_es']!, _captionEsMeta),
      );
    }
    if (data.containsKey('caption_en')) {
      context.handle(
        _captionEnMeta,
        captionEn.isAcceptableOrUnknown(data['caption_en']!, _captionEnMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('card_thumbnail_url')) {
      context.handle(
        _cardThumbnailUrlMeta,
        cardThumbnailUrl.isAcceptableOrUnknown(
          data['card_thumbnail_url']!,
          _cardThumbnailUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      captionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption_es'],
      ),
      captionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption_en'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      cardThumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_thumbnail_url'],
      ),
    );
  }

  @override
  $SpeciesImagesTable createAlias(String alias) {
    return $SpeciesImagesTable(attachedDatabase, alias);
  }
}

class SpeciesImage extends DataClass implements Insertable<SpeciesImage> {
  final int id;
  final int speciesId;
  final String imageUrl;
  final String? captionEs;
  final String? captionEn;
  final int sortOrder;
  final bool isPrimary;
  final String? thumbnailUrl;
  final String? cardThumbnailUrl;
  const SpeciesImage({
    required this.id,
    required this.speciesId,
    required this.imageUrl,
    this.captionEs,
    this.captionEn,
    required this.sortOrder,
    required this.isPrimary,
    this.thumbnailUrl,
    this.cardThumbnailUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['image_url'] = Variable<String>(imageUrl);
    if (!nullToAbsent || captionEs != null) {
      map['caption_es'] = Variable<String>(captionEs);
    }
    if (!nullToAbsent || captionEn != null) {
      map['caption_en'] = Variable<String>(captionEn);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_primary'] = Variable<bool>(isPrimary);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || cardThumbnailUrl != null) {
      map['card_thumbnail_url'] = Variable<String>(cardThumbnailUrl);
    }
    return map;
  }

  SpeciesImagesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesImagesCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      imageUrl: Value(imageUrl),
      captionEs: captionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(captionEs),
      captionEn: captionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(captionEn),
      sortOrder: Value(sortOrder),
      isPrimary: Value(isPrimary),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      cardThumbnailUrl: cardThumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(cardThumbnailUrl),
    );
  }

  factory SpeciesImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesImage(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      captionEs: serializer.fromJson<String?>(json['captionEs']),
      captionEn: serializer.fromJson<String?>(json['captionEn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      cardThumbnailUrl: serializer.fromJson<String?>(json['cardThumbnailUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'captionEs': serializer.toJson<String?>(captionEs),
      'captionEn': serializer.toJson<String?>(captionEn),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'cardThumbnailUrl': serializer.toJson<String?>(cardThumbnailUrl),
    };
  }

  SpeciesImage copyWith({
    int? id,
    int? speciesId,
    String? imageUrl,
    Value<String?> captionEs = const Value.absent(),
    Value<String?> captionEn = const Value.absent(),
    int? sortOrder,
    bool? isPrimary,
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> cardThumbnailUrl = const Value.absent(),
  }) => SpeciesImage(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    imageUrl: imageUrl ?? this.imageUrl,
    captionEs: captionEs.present ? captionEs.value : this.captionEs,
    captionEn: captionEn.present ? captionEn.value : this.captionEn,
    sortOrder: sortOrder ?? this.sortOrder,
    isPrimary: isPrimary ?? this.isPrimary,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    cardThumbnailUrl: cardThumbnailUrl.present
        ? cardThumbnailUrl.value
        : this.cardThumbnailUrl,
  );
  SpeciesImage copyWithCompanion(SpeciesImagesCompanion data) {
    return SpeciesImage(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      captionEs: data.captionEs.present ? data.captionEs.value : this.captionEs,
      captionEn: data.captionEn.present ? data.captionEn.value : this.captionEn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      cardThumbnailUrl: data.cardThumbnailUrl.present
          ? data.cardThumbnailUrl.value
          : this.cardThumbnailUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesImage(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('captionEs: $captionEs, ')
          ..write('captionEn: $captionEn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('cardThumbnailUrl: $cardThumbnailUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    speciesId,
    imageUrl,
    captionEs,
    captionEn,
    sortOrder,
    isPrimary,
    thumbnailUrl,
    cardThumbnailUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesImage &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.imageUrl == this.imageUrl &&
          other.captionEs == this.captionEs &&
          other.captionEn == this.captionEn &&
          other.sortOrder == this.sortOrder &&
          other.isPrimary == this.isPrimary &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.cardThumbnailUrl == this.cardThumbnailUrl);
}

class SpeciesImagesCompanion extends UpdateCompanion<SpeciesImage> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<String> imageUrl;
  final Value<String?> captionEs;
  final Value<String?> captionEn;
  final Value<int> sortOrder;
  final Value<bool> isPrimary;
  final Value<String?> thumbnailUrl;
  final Value<String?> cardThumbnailUrl;
  const SpeciesImagesCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.captionEs = const Value.absent(),
    this.captionEn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.cardThumbnailUrl = const Value.absent(),
  });
  SpeciesImagesCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required String imageUrl,
    this.captionEs = const Value.absent(),
    this.captionEn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.cardThumbnailUrl = const Value.absent(),
  }) : speciesId = Value(speciesId),
       imageUrl = Value(imageUrl);
  static Insertable<SpeciesImage> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? imageUrl,
    Expression<String>? captionEs,
    Expression<String>? captionEn,
    Expression<int>? sortOrder,
    Expression<bool>? isPrimary,
    Expression<String>? thumbnailUrl,
    Expression<String>? cardThumbnailUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (captionEs != null) 'caption_es': captionEs,
      if (captionEn != null) 'caption_en': captionEn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (cardThumbnailUrl != null) 'card_thumbnail_url': cardThumbnailUrl,
    });
  }

  SpeciesImagesCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<String>? imageUrl,
    Value<String?>? captionEs,
    Value<String?>? captionEn,
    Value<int>? sortOrder,
    Value<bool>? isPrimary,
    Value<String?>? thumbnailUrl,
    Value<String?>? cardThumbnailUrl,
  }) {
    return SpeciesImagesCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      imageUrl: imageUrl ?? this.imageUrl,
      captionEs: captionEs ?? this.captionEs,
      captionEn: captionEn ?? this.captionEn,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      cardThumbnailUrl: cardThumbnailUrl ?? this.cardThumbnailUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (captionEs.present) {
      map['caption_es'] = Variable<String>(captionEs.value);
    }
    if (captionEn.present) {
      map['caption_en'] = Variable<String>(captionEn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (cardThumbnailUrl.present) {
      map['card_thumbnail_url'] = Variable<String>(cardThumbnailUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesImagesCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('captionEs: $captionEs, ')
          ..write('captionEn: $captionEn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('cardThumbnailUrl: $cardThumbnailUrl')
          ..write(')'))
        .toString();
  }
}

class $SpeciesReferencesTable extends SpeciesReferences
    with TableInfo<$SpeciesReferencesTable, SpeciesReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationMeta = const VerificationMeta(
    'citation',
  );
  @override
  late final GeneratedColumn<String> citation = GeneratedColumn<String>(
    'citation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  @override
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    citation,
    url,
    doi,
    referenceType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('citation')) {
      context.handle(
        _citationMeta,
        citation.isAcceptableOrUnknown(data['citation']!, _citationMeta),
      );
    } else if (isInserting) {
      context.missing(_citationMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesReference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      citation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citation'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
    );
  }

  @override
  $SpeciesReferencesTable createAlias(String alias) {
    return $SpeciesReferencesTable(attachedDatabase, alias);
  }
}

class SpeciesReference extends DataClass
    implements Insertable<SpeciesReference> {
  final int id;
  final int speciesId;
  final String citation;
  final String? url;
  final String? doi;
  final String? referenceType;
  const SpeciesReference({
    required this.id,
    required this.speciesId,
    required this.citation,
    this.url,
    this.doi,
    this.referenceType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['citation'] = Variable<String>(citation);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    return map;
  }

  SpeciesReferencesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesReferencesCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      citation: Value(citation),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
    );
  }

  factory SpeciesReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesReference(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      citation: serializer.fromJson<String>(json['citation']),
      url: serializer.fromJson<String?>(json['url']),
      doi: serializer.fromJson<String?>(json['doi']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'citation': serializer.toJson<String>(citation),
      'url': serializer.toJson<String?>(url),
      'doi': serializer.toJson<String?>(doi),
      'referenceType': serializer.toJson<String?>(referenceType),
    };
  }

  SpeciesReference copyWith({
    int? id,
    int? speciesId,
    String? citation,
    Value<String?> url = const Value.absent(),
    Value<String?> doi = const Value.absent(),
    Value<String?> referenceType = const Value.absent(),
  }) => SpeciesReference(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    citation: citation ?? this.citation,
    url: url.present ? url.value : this.url,
    doi: doi.present ? doi.value : this.doi,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
  );
  SpeciesReference copyWithCompanion(SpeciesReferencesCompanion data) {
    return SpeciesReference(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      citation: data.citation.present ? data.citation.value : this.citation,
      url: data.url.present ? data.url.value : this.url,
      doi: data.doi.present ? data.doi.value : this.doi,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesReference(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('citation: $citation, ')
          ..write('url: $url, ')
          ..write('doi: $doi, ')
          ..write('referenceType: $referenceType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, speciesId, citation, url, doi, referenceType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesReference &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.citation == this.citation &&
          other.url == this.url &&
          other.doi == this.doi &&
          other.referenceType == this.referenceType);
}

class SpeciesReferencesCompanion extends UpdateCompanion<SpeciesReference> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<String> citation;
  final Value<String?> url;
  final Value<String?> doi;
  final Value<String?> referenceType;
  const SpeciesReferencesCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.citation = const Value.absent(),
    this.url = const Value.absent(),
    this.doi = const Value.absent(),
    this.referenceType = const Value.absent(),
  });
  SpeciesReferencesCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required String citation,
    this.url = const Value.absent(),
    this.doi = const Value.absent(),
    this.referenceType = const Value.absent(),
  }) : speciesId = Value(speciesId),
       citation = Value(citation);
  static Insertable<SpeciesReference> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? citation,
    Expression<String>? url,
    Expression<String>? doi,
    Expression<String>? referenceType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (citation != null) 'citation': citation,
      if (url != null) 'url': url,
      if (doi != null) 'doi': doi,
      if (referenceType != null) 'reference_type': referenceType,
    });
  }

  SpeciesReferencesCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<String>? citation,
    Value<String?>? url,
    Value<String?>? doi,
    Value<String?>? referenceType,
  }) {
    return SpeciesReferencesCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      citation: citation ?? this.citation,
      url: url ?? this.url,
      doi: doi ?? this.doi,
      referenceType: referenceType ?? this.referenceType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (citation.present) {
      map['citation'] = Variable<String>(citation.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesReferencesCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('citation: $citation, ')
          ..write('url: $url, ')
          ..write('doi: $doi, ')
          ..write('referenceType: $referenceType')
          ..write(')'))
        .toString();
  }
}

class $SpeciesSitesTable extends SpeciesSites
    with TableInfo<$SpeciesSitesTable, SpeciesSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitSiteIdMeta = const VerificationMeta(
    'visitSiteId',
  );
  @override
  late final GeneratedColumn<int> visitSiteId = GeneratedColumn<int>(
    'visit_site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, speciesId, visitSiteId, frequency];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesSite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('visit_site_id')) {
      context.handle(
        _visitSiteIdMeta,
        visitSiteId.isAcceptableOrUnknown(
          data['visit_site_id']!,
          _visitSiteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitSiteIdMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesSite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      visitSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_site_id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
    );
  }

  @override
  $SpeciesSitesTable createAlias(String alias) {
    return $SpeciesSitesTable(attachedDatabase, alias);
  }
}

class SpeciesSite extends DataClass implements Insertable<SpeciesSite> {
  final int id;
  final int speciesId;
  final int visitSiteId;
  final String? frequency;
  const SpeciesSite({
    required this.id,
    required this.speciesId,
    required this.visitSiteId,
    this.frequency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['visit_site_id'] = Variable<int>(visitSiteId);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    return map;
  }

  SpeciesSitesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesSitesCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      visitSiteId: Value(visitSiteId),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
    );
  }

  factory SpeciesSite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesSite(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      visitSiteId: serializer.fromJson<int>(json['visitSiteId']),
      frequency: serializer.fromJson<String?>(json['frequency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'visitSiteId': serializer.toJson<int>(visitSiteId),
      'frequency': serializer.toJson<String?>(frequency),
    };
  }

  SpeciesSite copyWith({
    int? id,
    int? speciesId,
    int? visitSiteId,
    Value<String?> frequency = const Value.absent(),
  }) => SpeciesSite(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    visitSiteId: visitSiteId ?? this.visitSiteId,
    frequency: frequency.present ? frequency.value : this.frequency,
  );
  SpeciesSite copyWithCompanion(SpeciesSitesCompanion data) {
    return SpeciesSite(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      visitSiteId: data.visitSiteId.present
          ? data.visitSiteId.value
          : this.visitSiteId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesSite(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('frequency: $frequency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speciesId, visitSiteId, frequency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesSite &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.visitSiteId == this.visitSiteId &&
          other.frequency == this.frequency);
}

class SpeciesSitesCompanion extends UpdateCompanion<SpeciesSite> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<int> visitSiteId;
  final Value<String?> frequency;
  const SpeciesSitesCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.visitSiteId = const Value.absent(),
    this.frequency = const Value.absent(),
  });
  SpeciesSitesCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required int visitSiteId,
    this.frequency = const Value.absent(),
  }) : speciesId = Value(speciesId),
       visitSiteId = Value(visitSiteId);
  static Insertable<SpeciesSite> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<int>? visitSiteId,
    Expression<String>? frequency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (visitSiteId != null) 'visit_site_id': visitSiteId,
      if (frequency != null) 'frequency': frequency,
    });
  }

  SpeciesSitesCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<int>? visitSiteId,
    Value<String?>? frequency,
  }) {
    return SpeciesSitesCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      visitSiteId: visitSiteId ?? this.visitSiteId,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (visitSiteId.present) {
      map['visit_site_id'] = Variable<int>(visitSiteId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesSitesCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('frequency: $frequency')
          ..write(')'))
        .toString();
  }
}

class $SpeciesSoundsTable extends SpeciesSounds
    with TableInfo<$SpeciesSoundsTable, SpeciesSound> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesSoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundUrlMeta = const VerificationMeta(
    'soundUrl',
  );
  @override
  late final GeneratedColumn<String> soundUrl = GeneratedColumn<String>(
    'sound_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundTypeMeta = const VerificationMeta(
    'soundType',
  );
  @override
  late final GeneratedColumn<String> soundType = GeneratedColumn<String>(
    'sound_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByMeta = const VerificationMeta(
    'recordedBy',
  );
  @override
  late final GeneratedColumn<String> recordedBy = GeneratedColumn<String>(
    'recorded_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedDateMeta = const VerificationMeta(
    'recordedDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordedDate = GeneratedColumn<DateTime>(
    'recorded_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    soundUrl,
    soundType,
    descriptionEs,
    descriptionEn,
    recordedBy,
    recordedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_sounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesSound> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('sound_url')) {
      context.handle(
        _soundUrlMeta,
        soundUrl.isAcceptableOrUnknown(data['sound_url']!, _soundUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_soundUrlMeta);
    }
    if (data.containsKey('sound_type')) {
      context.handle(
        _soundTypeMeta,
        soundType.isAcceptableOrUnknown(data['sound_type']!, _soundTypeMeta),
      );
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
        _recordedByMeta,
        recordedBy.isAcceptableOrUnknown(data['recorded_by']!, _recordedByMeta),
      );
    }
    if (data.containsKey('recorded_date')) {
      context.handle(
        _recordedDateMeta,
        recordedDate.isAcceptableOrUnknown(
          data['recorded_date']!,
          _recordedDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesSound map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesSound(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      soundUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_url'],
      )!,
      soundType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_type'],
      ),
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
      recordedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_by'],
      ),
      recordedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_date'],
      ),
    );
  }

  @override
  $SpeciesSoundsTable createAlias(String alias) {
    return $SpeciesSoundsTable(attachedDatabase, alias);
  }
}

class SpeciesSound extends DataClass implements Insertable<SpeciesSound> {
  final int id;
  final int speciesId;
  final String soundUrl;
  final String? soundType;
  final String? descriptionEs;
  final String? descriptionEn;
  final String? recordedBy;
  final DateTime? recordedDate;
  const SpeciesSound({
    required this.id,
    required this.speciesId,
    required this.soundUrl,
    this.soundType,
    this.descriptionEs,
    this.descriptionEn,
    this.recordedBy,
    this.recordedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['sound_url'] = Variable<String>(soundUrl);
    if (!nullToAbsent || soundType != null) {
      map['sound_type'] = Variable<String>(soundType);
    }
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    if (!nullToAbsent || recordedBy != null) {
      map['recorded_by'] = Variable<String>(recordedBy);
    }
    if (!nullToAbsent || recordedDate != null) {
      map['recorded_date'] = Variable<DateTime>(recordedDate);
    }
    return map;
  }

  SpeciesSoundsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesSoundsCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      soundUrl: Value(soundUrl),
      soundType: soundType == null && nullToAbsent
          ? const Value.absent()
          : Value(soundType),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
      recordedBy: recordedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedBy),
      recordedDate: recordedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedDate),
    );
  }

  factory SpeciesSound.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesSound(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      soundUrl: serializer.fromJson<String>(json['soundUrl']),
      soundType: serializer.fromJson<String?>(json['soundType']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
      recordedBy: serializer.fromJson<String?>(json['recordedBy']),
      recordedDate: serializer.fromJson<DateTime?>(json['recordedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'soundUrl': serializer.toJson<String>(soundUrl),
      'soundType': serializer.toJson<String?>(soundType),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
      'recordedBy': serializer.toJson<String?>(recordedBy),
      'recordedDate': serializer.toJson<DateTime?>(recordedDate),
    };
  }

  SpeciesSound copyWith({
    int? id,
    int? speciesId,
    String? soundUrl,
    Value<String?> soundType = const Value.absent(),
    Value<String?> descriptionEs = const Value.absent(),
    Value<String?> descriptionEn = const Value.absent(),
    Value<String?> recordedBy = const Value.absent(),
    Value<DateTime?> recordedDate = const Value.absent(),
  }) => SpeciesSound(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    soundUrl: soundUrl ?? this.soundUrl,
    soundType: soundType.present ? soundType.value : this.soundType,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
    recordedBy: recordedBy.present ? recordedBy.value : this.recordedBy,
    recordedDate: recordedDate.present ? recordedDate.value : this.recordedDate,
  );
  SpeciesSound copyWithCompanion(SpeciesSoundsCompanion data) {
    return SpeciesSound(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      soundUrl: data.soundUrl.present ? data.soundUrl.value : this.soundUrl,
      soundType: data.soundType.present ? data.soundType.value : this.soundType,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      recordedBy: data.recordedBy.present
          ? data.recordedBy.value
          : this.recordedBy,
      recordedDate: data.recordedDate.present
          ? data.recordedDate.value
          : this.recordedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesSound(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('soundUrl: $soundUrl, ')
          ..write('soundType: $soundType, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('recordedDate: $recordedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    speciesId,
    soundUrl,
    soundType,
    descriptionEs,
    descriptionEn,
    recordedBy,
    recordedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesSound &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.soundUrl == this.soundUrl &&
          other.soundType == this.soundType &&
          other.descriptionEs == this.descriptionEs &&
          other.descriptionEn == this.descriptionEn &&
          other.recordedBy == this.recordedBy &&
          other.recordedDate == this.recordedDate);
}

class SpeciesSoundsCompanion extends UpdateCompanion<SpeciesSound> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<String> soundUrl;
  final Value<String?> soundType;
  final Value<String?> descriptionEs;
  final Value<String?> descriptionEn;
  final Value<String?> recordedBy;
  final Value<DateTime?> recordedDate;
  const SpeciesSoundsCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.soundUrl = const Value.absent(),
    this.soundType = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.recordedDate = const Value.absent(),
  });
  SpeciesSoundsCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required String soundUrl,
    this.soundType = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.recordedDate = const Value.absent(),
  }) : speciesId = Value(speciesId),
       soundUrl = Value(soundUrl);
  static Insertable<SpeciesSound> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? soundUrl,
    Expression<String>? soundType,
    Expression<String>? descriptionEs,
    Expression<String>? descriptionEn,
    Expression<String>? recordedBy,
    Expression<DateTime>? recordedDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (soundUrl != null) 'sound_url': soundUrl,
      if (soundType != null) 'sound_type': soundType,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (recordedDate != null) 'recorded_date': recordedDate,
    });
  }

  SpeciesSoundsCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<String>? soundUrl,
    Value<String?>? soundType,
    Value<String?>? descriptionEs,
    Value<String?>? descriptionEn,
    Value<String?>? recordedBy,
    Value<DateTime?>? recordedDate,
  }) {
    return SpeciesSoundsCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      soundUrl: soundUrl ?? this.soundUrl,
      soundType: soundType ?? this.soundType,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedDate: recordedDate ?? this.recordedDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (soundUrl.present) {
      map['sound_url'] = Variable<String>(soundUrl.value);
    }
    if (soundType.present) {
      map['sound_type'] = Variable<String>(soundType.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<String>(recordedBy.value);
    }
    if (recordedDate.present) {
      map['recorded_date'] = Variable<DateTime>(recordedDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesSoundsCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('soundUrl: $soundUrl, ')
          ..write('soundType: $soundType, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('recordedDate: $recordedDate')
          ..write(')'))
        .toString();
  }
}

class $SpeciesThreatsTable extends SpeciesThreats
    with TableInfo<$SpeciesThreatsTable, SpeciesThreat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesThreatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threatTypeMeta = const VerificationMeta(
    'threatType',
  );
  @override
  late final GeneratedColumn<String> threatType = GeneratedColumn<String>(
    'threat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    threatType,
    severity,
    descriptionEs,
    descriptionEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_threats';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesThreat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('threat_type')) {
      context.handle(
        _threatTypeMeta,
        threatType.isAcceptableOrUnknown(data['threat_type']!, _threatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_threatTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesThreat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesThreat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      threatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}threat_type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
    );
  }

  @override
  $SpeciesThreatsTable createAlias(String alias) {
    return $SpeciesThreatsTable(attachedDatabase, alias);
  }
}

class SpeciesThreat extends DataClass implements Insertable<SpeciesThreat> {
  final int id;
  final int speciesId;
  final String threatType;
  final String severity;
  final String? descriptionEs;
  final String? descriptionEn;
  const SpeciesThreat({
    required this.id,
    required this.speciesId,
    required this.threatType,
    required this.severity,
    this.descriptionEs,
    this.descriptionEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['threat_type'] = Variable<String>(threatType);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    return map;
  }

  SpeciesThreatsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesThreatsCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      threatType: Value(threatType),
      severity: Value(severity),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
    );
  }

  factory SpeciesThreat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesThreat(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      threatType: serializer.fromJson<String>(json['threatType']),
      severity: serializer.fromJson<String>(json['severity']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'threatType': serializer.toJson<String>(threatType),
      'severity': serializer.toJson<String>(severity),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
    };
  }

  SpeciesThreat copyWith({
    int? id,
    int? speciesId,
    String? threatType,
    String? severity,
    Value<String?> descriptionEs = const Value.absent(),
    Value<String?> descriptionEn = const Value.absent(),
  }) => SpeciesThreat(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    threatType: threatType ?? this.threatType,
    severity: severity ?? this.severity,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
  );
  SpeciesThreat copyWithCompanion(SpeciesThreatsCompanion data) {
    return SpeciesThreat(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      threatType: data.threatType.present
          ? data.threatType.value
          : this.threatType,
      severity: data.severity.present ? data.severity.value : this.severity,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesThreat(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('threatType: $threatType, ')
          ..write('severity: $severity, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    speciesId,
    threatType,
    severity,
    descriptionEs,
    descriptionEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesThreat &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.threatType == this.threatType &&
          other.severity == this.severity &&
          other.descriptionEs == this.descriptionEs &&
          other.descriptionEn == this.descriptionEn);
}

class SpeciesThreatsCompanion extends UpdateCompanion<SpeciesThreat> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<String> threatType;
  final Value<String> severity;
  final Value<String?> descriptionEs;
  final Value<String?> descriptionEn;
  const SpeciesThreatsCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.threatType = const Value.absent(),
    this.severity = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
  });
  SpeciesThreatsCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required String threatType,
    required String severity,
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
  }) : speciesId = Value(speciesId),
       threatType = Value(threatType),
       severity = Value(severity);
  static Insertable<SpeciesThreat> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? threatType,
    Expression<String>? severity,
    Expression<String>? descriptionEs,
    Expression<String>? descriptionEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (threatType != null) 'threat_type': threatType,
      if (severity != null) 'severity': severity,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
    });
  }

  SpeciesThreatsCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<String>? threatType,
    Value<String>? severity,
    Value<String?>? descriptionEs,
    Value<String?>? descriptionEn,
  }) {
    return SpeciesThreatsCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      threatType: threatType ?? this.threatType,
      severity: severity ?? this.severity,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (threatType.present) {
      map['threat_type'] = Variable<String>(threatType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesThreatsCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('threatType: $threatType, ')
          ..write('severity: $severity, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn')
          ..write(')'))
        .toString();
  }
}

class $TrailsTable extends Trails with TableInfo<$TrailsTable, Trail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _islandIdMeta = const VerificationMeta(
    'islandId',
  );
  @override
  late final GeneratedColumn<int> islandId = GeneratedColumn<int>(
    'island_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitSiteIdMeta = const VerificationMeta(
    'visitSiteId',
  );
  @override
  late final GeneratedColumn<int> visitSiteId = GeneratedColumn<int>(
    'visit_site_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coordinatesMeta = const VerificationMeta(
    'coordinates',
  );
  @override
  late final GeneratedColumn<String> coordinates = GeneratedColumn<String>(
    'coordinates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta(
    'elevationGainM',
  );
  @override
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
    'elevation_gain_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameEn,
    nameEs,
    descriptionEn,
    descriptionEs,
    islandId,
    visitSiteId,
    difficulty,
    distanceKm,
    estimatedMinutes,
    coordinates,
    elevationGainM,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trails';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEsMeta);
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('island_id')) {
      context.handle(
        _islandIdMeta,
        islandId.isAcceptableOrUnknown(data['island_id']!, _islandIdMeta),
      );
    }
    if (data.containsKey('visit_site_id')) {
      context.handle(
        _visitSiteIdMeta,
        visitSiteId.isAcceptableOrUnknown(
          data['visit_site_id']!,
          _visitSiteIdMeta,
        ),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('coordinates')) {
      context.handle(
        _coordinatesMeta,
        coordinates.isAcceptableOrUnknown(
          data['coordinates']!,
          _coordinatesMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(
          data['elevation_gain_m']!,
          _elevationGainMMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      )!,
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      islandId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}island_id'],
      ),
      visitSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_site_id'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      coordinates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coordinates'],
      )!,
      elevationGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_m'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $TrailsTable createAlias(String alias) {
    return $TrailsTable(attachedDatabase, alias);
  }
}

class Trail extends DataClass implements Insertable<Trail> {
  final int id;
  final String nameEn;
  final String nameEs;
  final String? descriptionEn;
  final String? descriptionEs;
  final int? islandId;
  final int? visitSiteId;
  final String? difficulty;
  final double? distanceKm;
  final int? estimatedMinutes;
  final String coordinates;
  final double? elevationGainM;
  final String? userId;
  const Trail({
    required this.id,
    required this.nameEn,
    required this.nameEs,
    this.descriptionEn,
    this.descriptionEs,
    this.islandId,
    this.visitSiteId,
    this.difficulty,
    this.distanceKm,
    this.estimatedMinutes,
    required this.coordinates,
    this.elevationGainM,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_en'] = Variable<String>(nameEn);
    map['name_es'] = Variable<String>(nameEs);
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || islandId != null) {
      map['island_id'] = Variable<int>(islandId);
    }
    if (!nullToAbsent || visitSiteId != null) {
      map['visit_site_id'] = Variable<int>(visitSiteId);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['coordinates'] = Variable<String>(coordinates);
    if (!nullToAbsent || elevationGainM != null) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  TrailsCompanion toCompanion(bool nullToAbsent) {
    return TrailsCompanion(
      id: Value(id),
      nameEn: Value(nameEn),
      nameEs: Value(nameEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      islandId: islandId == null && nullToAbsent
          ? const Value.absent()
          : Value(islandId),
      visitSiteId: visitSiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitSiteId),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      coordinates: Value(coordinates),
      elevationGainM: elevationGainM == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainM),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory Trail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trail(
      id: serializer.fromJson<int>(json['id']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      islandId: serializer.fromJson<int?>(json['islandId']),
      visitSiteId: serializer.fromJson<int?>(json['visitSiteId']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      coordinates: serializer.fromJson<String>(json['coordinates']),
      elevationGainM: serializer.fromJson<double?>(json['elevationGainM']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameEs': serializer.toJson<String>(nameEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'islandId': serializer.toJson<int?>(islandId),
      'visitSiteId': serializer.toJson<int?>(visitSiteId),
      'difficulty': serializer.toJson<String?>(difficulty),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'coordinates': serializer.toJson<String>(coordinates),
      'elevationGainM': serializer.toJson<double?>(elevationGainM),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  Trail copyWith({
    int? id,
    String? nameEn,
    String? nameEs,
    Value<String?> descriptionEn = const Value.absent(),
    Value<String?> descriptionEs = const Value.absent(),
    Value<int?> islandId = const Value.absent(),
    Value<int?> visitSiteId = const Value.absent(),
    Value<String?> difficulty = const Value.absent(),
    Value<double?> distanceKm = const Value.absent(),
    Value<int?> estimatedMinutes = const Value.absent(),
    String? coordinates,
    Value<double?> elevationGainM = const Value.absent(),
    Value<String?> userId = const Value.absent(),
  }) => Trail(
    id: id ?? this.id,
    nameEn: nameEn ?? this.nameEn,
    nameEs: nameEs ?? this.nameEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    islandId: islandId.present ? islandId.value : this.islandId,
    visitSiteId: visitSiteId.present ? visitSiteId.value : this.visitSiteId,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    coordinates: coordinates ?? this.coordinates,
    elevationGainM: elevationGainM.present
        ? elevationGainM.value
        : this.elevationGainM,
    userId: userId.present ? userId.value : this.userId,
  );
  Trail copyWithCompanion(TrailsCompanion data) {
    return Trail(
      id: data.id.present ? data.id.value : this.id,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      islandId: data.islandId.present ? data.islandId.value : this.islandId,
      visitSiteId: data.visitSiteId.present
          ? data.visitSiteId.value
          : this.visitSiteId,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      coordinates: data.coordinates.present
          ? data.coordinates.value
          : this.coordinates,
      elevationGainM: data.elevationGainM.present
          ? data.elevationGainM.value
          : this.elevationGainM,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trail(')
          ..write('id: $id, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('islandId: $islandId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('difficulty: $difficulty, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('coordinates: $coordinates, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameEn,
    nameEs,
    descriptionEn,
    descriptionEs,
    islandId,
    visitSiteId,
    difficulty,
    distanceKm,
    estimatedMinutes,
    coordinates,
    elevationGainM,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trail &&
          other.id == this.id &&
          other.nameEn == this.nameEn &&
          other.nameEs == this.nameEs &&
          other.descriptionEn == this.descriptionEn &&
          other.descriptionEs == this.descriptionEs &&
          other.islandId == this.islandId &&
          other.visitSiteId == this.visitSiteId &&
          other.difficulty == this.difficulty &&
          other.distanceKm == this.distanceKm &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.coordinates == this.coordinates &&
          other.elevationGainM == this.elevationGainM &&
          other.userId == this.userId);
}

class TrailsCompanion extends UpdateCompanion<Trail> {
  final Value<int> id;
  final Value<String> nameEn;
  final Value<String> nameEs;
  final Value<String?> descriptionEn;
  final Value<String?> descriptionEs;
  final Value<int?> islandId;
  final Value<int?> visitSiteId;
  final Value<String?> difficulty;
  final Value<double?> distanceKm;
  final Value<int?> estimatedMinutes;
  final Value<String> coordinates;
  final Value<double?> elevationGainM;
  final Value<String?> userId;
  const TrailsCompanion({
    this.id = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.islandId = const Value.absent(),
    this.visitSiteId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.userId = const Value.absent(),
  });
  TrailsCompanion.insert({
    this.id = const Value.absent(),
    required String nameEn,
    required String nameEs,
    this.descriptionEn = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.islandId = const Value.absent(),
    this.visitSiteId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.userId = const Value.absent(),
  }) : nameEn = Value(nameEn),
       nameEs = Value(nameEs);
  static Insertable<Trail> custom({
    Expression<int>? id,
    Expression<String>? nameEn,
    Expression<String>? nameEs,
    Expression<String>? descriptionEn,
    Expression<String>? descriptionEs,
    Expression<int>? islandId,
    Expression<int>? visitSiteId,
    Expression<String>? difficulty,
    Expression<double>? distanceKm,
    Expression<int>? estimatedMinutes,
    Expression<String>? coordinates,
    Expression<double>? elevationGainM,
    Expression<String>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEn != null) 'name_en': nameEn,
      if (nameEs != null) 'name_es': nameEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (islandId != null) 'island_id': islandId,
      if (visitSiteId != null) 'visit_site_id': visitSiteId,
      if (difficulty != null) 'difficulty': difficulty,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (coordinates != null) 'coordinates': coordinates,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (userId != null) 'user_id': userId,
    });
  }

  TrailsCompanion copyWith({
    Value<int>? id,
    Value<String>? nameEn,
    Value<String>? nameEs,
    Value<String?>? descriptionEn,
    Value<String?>? descriptionEs,
    Value<int?>? islandId,
    Value<int?>? visitSiteId,
    Value<String?>? difficulty,
    Value<double?>? distanceKm,
    Value<int?>? estimatedMinutes,
    Value<String>? coordinates,
    Value<double?>? elevationGainM,
    Value<String?>? userId,
  }) {
    return TrailsCompanion(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameEs: nameEs ?? this.nameEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      islandId: islandId ?? this.islandId,
      visitSiteId: visitSiteId ?? this.visitSiteId,
      difficulty: difficulty ?? this.difficulty,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      coordinates: coordinates ?? this.coordinates,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (islandId.present) {
      map['island_id'] = Variable<int>(islandId.value);
    }
    if (visitSiteId.present) {
      map['visit_site_id'] = Variable<int>(visitSiteId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (coordinates.present) {
      map['coordinates'] = Variable<String>(coordinates.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrailsCompanion(')
          ..write('id: $id, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('islandId: $islandId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('difficulty: $difficulty, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('coordinates: $coordinates, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

class $UserFavoritesTable extends UserFavorites
    with TableInfo<$UserFavoritesTable, UserFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, speciesId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFavorite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
    );
  }

  @override
  $UserFavoritesTable createAlias(String alias) {
    return $UserFavoritesTable(attachedDatabase, alias);
  }
}

class UserFavorite extends DataClass implements Insertable<UserFavorite> {
  final int id;
  final String userId;
  final int speciesId;
  const UserFavorite({
    required this.id,
    required this.userId,
    required this.speciesId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['species_id'] = Variable<int>(speciesId);
    return map;
  }

  UserFavoritesCompanion toCompanion(bool nullToAbsent) {
    return UserFavoritesCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: Value(speciesId),
    );
  }

  factory UserFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFavorite(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'speciesId': serializer.toJson<int>(speciesId),
    };
  }

  UserFavorite copyWith({int? id, String? userId, int? speciesId}) =>
      UserFavorite(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        speciesId: speciesId ?? this.speciesId,
      );
  UserFavorite copyWithCompanion(UserFavoritesCompanion data) {
    return UserFavorite(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFavorite(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, speciesId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFavorite &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId);
}

class UserFavoritesCompanion extends UpdateCompanion<UserFavorite> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> speciesId;
  const UserFavoritesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
  });
  UserFavoritesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int speciesId,
  }) : userId = Value(userId),
       speciesId = Value(speciesId);
  static Insertable<UserFavorite> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? speciesId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
    });
  }

  UserFavoritesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? speciesId,
  }) {
    return UserFavoritesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFavoritesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userTypeMeta = const VerificationMeta(
    'userType',
  );
  @override
  late final GeneratedColumn<String> userType = GeneratedColumn<String>(
    'user_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tourist'),
  );
  static const VerificationMeta _affiliationMeta = const VerificationMeta(
    'affiliation',
  );
  @override
  late final GeneratedColumn<String> affiliation = GeneratedColumn<String>(
    'affiliation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    bio,
    birthDate,
    country,
    countryCode,
    avatarUrl,
    createdAt,
    updatedAt,
    userType,
    affiliation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('user_type')) {
      context.handle(
        _userTypeMeta,
        userType.isAcceptableOrUnknown(data['user_type']!, _userTypeMeta),
      );
    }
    if (data.containsKey('affiliation')) {
      context.handle(
        _affiliationMeta,
        affiliation.isAcceptableOrUnknown(
          data['affiliation']!,
          _affiliationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      userType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_type'],
      )!,
      affiliation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}affiliation'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String? displayName;
  final String? bio;
  final DateTime? birthDate;
  final String? country;
  final String? countryCode;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userType;
  final String? affiliation;
  const UserProfile({
    required this.id,
    this.displayName,
    this.bio,
    this.birthDate,
    this.country,
    this.countryCode,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    required this.userType,
    this.affiliation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['user_type'] = Variable<String>(userType);
    if (!nullToAbsent || affiliation != null) {
      map['affiliation'] = Variable<String>(affiliation);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      userType: Value(userType),
      affiliation: affiliation == null && nullToAbsent
          ? const Value.absent()
          : Value(affiliation),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      bio: serializer.fromJson<String?>(json['bio']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      country: serializer.fromJson<String?>(json['country']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      userType: serializer.fromJson<String>(json['userType']),
      affiliation: serializer.fromJson<String?>(json['affiliation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'bio': serializer.toJson<String?>(bio),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'country': serializer.toJson<String?>(country),
      'countryCode': serializer.toJson<String?>(countryCode),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'userType': serializer.toJson<String>(userType),
      'affiliation': serializer.toJson<String?>(affiliation),
    };
  }

  UserProfile copyWith({
    String? id,
    Value<String?> displayName = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    String? userType,
    Value<String?> affiliation = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    bio: bio.present ? bio.value : this.bio,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    country: country.present ? country.value : this.country,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    userType: userType ?? this.userType,
    affiliation: affiliation.present ? affiliation.value : this.affiliation,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      bio: data.bio.present ? data.bio.value : this.bio,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      country: data.country.present ? data.country.value : this.country,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      userType: data.userType.present ? data.userType.value : this.userType,
      affiliation: data.affiliation.present
          ? data.affiliation.value
          : this.affiliation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('birthDate: $birthDate, ')
          ..write('country: $country, ')
          ..write('countryCode: $countryCode, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('userType: $userType, ')
          ..write('affiliation: $affiliation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    bio,
    birthDate,
    country,
    countryCode,
    avatarUrl,
    createdAt,
    updatedAt,
    userType,
    affiliation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.bio == this.bio &&
          other.birthDate == this.birthDate &&
          other.country == this.country &&
          other.countryCode == this.countryCode &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.userType == this.userType &&
          other.affiliation == this.affiliation);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String?> displayName;
  final Value<String?> bio;
  final Value<DateTime?> birthDate;
  final Value<String?> country;
  final Value<String?> countryCode;
  final Value<String?> avatarUrl;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> userType;
  final Value<String?> affiliation;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.bio = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.country = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.userType = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    this.displayName = const Value.absent(),
    this.bio = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.country = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.userType = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? bio,
    Expression<DateTime>? birthDate,
    Expression<String>? country,
    Expression<String>? countryCode,
    Expression<String>? avatarUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? userType,
    Expression<String>? affiliation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (birthDate != null) 'birth_date': birthDate,
      if (country != null) 'country': country,
      if (countryCode != null) 'country_code': countryCode,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (userType != null) 'user_type': userType,
      if (affiliation != null) 'affiliation': affiliation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String?>? displayName,
    Value<String?>? bio,
    Value<DateTime?>? birthDate,
    Value<String?>? country,
    Value<String?>? countryCode,
    Value<String?>? avatarUrl,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? userType,
    Value<String?>? affiliation,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userType: userType ?? this.userType,
      affiliation: affiliation ?? this.affiliation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (userType.present) {
      map['user_type'] = Variable<String>(userType.value);
    }
    if (affiliation.present) {
      map['affiliation'] = Variable<String>(affiliation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('birthDate: $birthDate, ')
          ..write('country: $country, ')
          ..write('countryCode: $countryCode, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('userType: $userType, ')
          ..write('affiliation: $affiliation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSiteWishlistsTable extends UserSiteWishlists
    with TableInfo<$UserSiteWishlistsTable, UserSiteWishlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSiteWishlistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitSiteIdMeta = const VerificationMeta(
    'visitSiteId',
  );
  @override
  late final GeneratedColumn<int> visitSiteId = GeneratedColumn<int>(
    'visit_site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, visitSiteId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_site_wishlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSiteWishlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('visit_site_id')) {
      context.handle(
        _visitSiteIdMeta,
        visitSiteId.isAcceptableOrUnknown(
          data['visit_site_id']!,
          _visitSiteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitSiteIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSiteWishlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSiteWishlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      visitSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_site_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $UserSiteWishlistsTable createAlias(String alias) {
    return $UserSiteWishlistsTable(attachedDatabase, alias);
  }
}

class UserSiteWishlist extends DataClass
    implements Insertable<UserSiteWishlist> {
  final int id;
  final String userId;
  final int visitSiteId;
  final DateTime? createdAt;
  const UserSiteWishlist({
    required this.id,
    required this.userId,
    required this.visitSiteId,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['visit_site_id'] = Variable<int>(visitSiteId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  UserSiteWishlistsCompanion toCompanion(bool nullToAbsent) {
    return UserSiteWishlistsCompanion(
      id: Value(id),
      userId: Value(userId),
      visitSiteId: Value(visitSiteId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory UserSiteWishlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSiteWishlist(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      visitSiteId: serializer.fromJson<int>(json['visitSiteId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'visitSiteId': serializer.toJson<int>(visitSiteId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  UserSiteWishlist copyWith({
    int? id,
    String? userId,
    int? visitSiteId,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => UserSiteWishlist(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    visitSiteId: visitSiteId ?? this.visitSiteId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  UserSiteWishlist copyWithCompanion(UserSiteWishlistsCompanion data) {
    return UserSiteWishlist(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      visitSiteId: data.visitSiteId.present
          ? data.visitSiteId.value
          : this.visitSiteId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSiteWishlist(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, visitSiteId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSiteWishlist &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.visitSiteId == this.visitSiteId &&
          other.createdAt == this.createdAt);
}

class UserSiteWishlistsCompanion extends UpdateCompanion<UserSiteWishlist> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> visitSiteId;
  final Value<DateTime?> createdAt;
  const UserSiteWishlistsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.visitSiteId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserSiteWishlistsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int visitSiteId,
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       visitSiteId = Value(visitSiteId);
  static Insertable<UserSiteWishlist> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? visitSiteId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (visitSiteId != null) 'visit_site_id': visitSiteId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserSiteWishlistsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? visitSiteId,
    Value<DateTime?>? createdAt,
  }) {
    return UserSiteWishlistsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      visitSiteId: visitSiteId ?? this.visitSiteId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (visitSiteId.present) {
      map['visit_site_id'] = Variable<int>(visitSiteId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSiteWishlistsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('visitSiteId: $visitSiteId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserSpeciesChecklistsTable extends UserSpeciesChecklists
    with TableInfo<$UserSpeciesChecklistsTable, UserSpeciesChecklist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSpeciesChecklistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<DateTime> seenAt = GeneratedColumn<DateTime>(
    'seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, speciesId, seenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_species_checklist';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSpeciesChecklist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(
        _seenAtMeta,
        seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSpeciesChecklist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSpeciesChecklist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_at'],
      ),
    );
  }

  @override
  $UserSpeciesChecklistsTable createAlias(String alias) {
    return $UserSpeciesChecklistsTable(attachedDatabase, alias);
  }
}

class UserSpeciesChecklist extends DataClass
    implements Insertable<UserSpeciesChecklist> {
  final int id;
  final String userId;
  final int speciesId;
  final DateTime? seenAt;
  const UserSpeciesChecklist({
    required this.id,
    required this.userId,
    required this.speciesId,
    this.seenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['species_id'] = Variable<int>(speciesId);
    if (!nullToAbsent || seenAt != null) {
      map['seen_at'] = Variable<DateTime>(seenAt);
    }
    return map;
  }

  UserSpeciesChecklistsCompanion toCompanion(bool nullToAbsent) {
    return UserSpeciesChecklistsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: Value(speciesId),
      seenAt: seenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(seenAt),
    );
  }

  factory UserSpeciesChecklist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSpeciesChecklist(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      seenAt: serializer.fromJson<DateTime?>(json['seenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'speciesId': serializer.toJson<int>(speciesId),
      'seenAt': serializer.toJson<DateTime?>(seenAt),
    };
  }

  UserSpeciesChecklist copyWith({
    int? id,
    String? userId,
    int? speciesId,
    Value<DateTime?> seenAt = const Value.absent(),
  }) => UserSpeciesChecklist(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    speciesId: speciesId ?? this.speciesId,
    seenAt: seenAt.present ? seenAt.value : this.seenAt,
  );
  UserSpeciesChecklist copyWithCompanion(UserSpeciesChecklistsCompanion data) {
    return UserSpeciesChecklist(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSpeciesChecklist(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('seenAt: $seenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, speciesId, seenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSpeciesChecklist &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId &&
          other.seenAt == this.seenAt);
}

class UserSpeciesChecklistsCompanion
    extends UpdateCompanion<UserSpeciesChecklist> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> speciesId;
  final Value<DateTime?> seenAt;
  const UserSpeciesChecklistsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.seenAt = const Value.absent(),
  });
  UserSpeciesChecklistsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int speciesId,
    this.seenAt = const Value.absent(),
  }) : userId = Value(userId),
       speciesId = Value(speciesId);
  static Insertable<UserSpeciesChecklist> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? speciesId,
    Expression<DateTime>? seenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
      if (seenAt != null) 'seen_at': seenAt,
    });
  }

  UserSpeciesChecklistsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? speciesId,
    Value<DateTime?>? seenAt,
  }) {
    return UserSpeciesChecklistsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      seenAt: seenAt ?? this.seenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<DateTime>(seenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSpeciesChecklistsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('seenAt: $seenAt')
          ..write(')'))
        .toString();
  }
}

class $VisitSitesTable extends VisitSites
    with TableInfo<$VisitSitesTable, VisitSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _islandIdMeta = const VerificationMeta(
    'islandId',
  );
  @override
  late final GeneratedColumn<int> islandId = GeneratedColumn<int>(
    'island_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEsMeta = const VerificationMeta(
    'descriptionEs',
  );
  @override
  late final GeneratedColumn<String> descriptionEs = GeneratedColumn<String>(
    'description_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monitoringTypeMeta = const VerificationMeta(
    'monitoringType',
  );
  @override
  late final GeneratedColumn<String> monitoringType = GeneratedColumn<String>(
    'monitoring_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conservationZoneMeta = const VerificationMeta(
    'conservationZone',
  );
  @override
  late final GeneratedColumn<String> conservationZone = GeneratedColumn<String>(
    'conservation_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicUseZoneMeta = const VerificationMeta(
    'publicUseZone',
  );
  @override
  late final GeneratedColumn<String> publicUseZone = GeneratedColumn<String>(
    'public_use_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attractionEsMeta = const VerificationMeta(
    'attractionEs',
  );
  @override
  late final GeneratedColumn<String> attractionEs = GeneratedColumn<String>(
    'attraction_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abbreviationMeta = const VerificationMeta(
    'abbreviation',
  );
  @override
  late final GeneratedColumn<String> abbreviation = GeneratedColumn<String>(
    'abbreviation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parkIdMeta = const VerificationMeta('parkId');
  @override
  late final GeneratedColumn<String> parkId = GeneratedColumn<String>(
    'park_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    islandId,
    nameEs,
    nameEn,
    latitude,
    longitude,
    descriptionEs,
    descriptionEn,
    monitoringType,
    difficulty,
    conservationZone,
    publicUseZone,
    capacity,
    status,
    attractionEs,
    abbreviation,
    parkId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitSite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('island_id')) {
      context.handle(
        _islandIdMeta,
        islandId.isAcceptableOrUnknown(data['island_id']!, _islandIdMeta),
      );
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEsMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('description_es')) {
      context.handle(
        _descriptionEsMeta,
        descriptionEs.isAcceptableOrUnknown(
          data['description_es']!,
          _descriptionEsMeta,
        ),
      );
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    }
    if (data.containsKey('monitoring_type')) {
      context.handle(
        _monitoringTypeMeta,
        monitoringType.isAcceptableOrUnknown(
          data['monitoring_type']!,
          _monitoringTypeMeta,
        ),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('conservation_zone')) {
      context.handle(
        _conservationZoneMeta,
        conservationZone.isAcceptableOrUnknown(
          data['conservation_zone']!,
          _conservationZoneMeta,
        ),
      );
    }
    if (data.containsKey('public_use_zone')) {
      context.handle(
        _publicUseZoneMeta,
        publicUseZone.isAcceptableOrUnknown(
          data['public_use_zone']!,
          _publicUseZoneMeta,
        ),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attraction_es')) {
      context.handle(
        _attractionEsMeta,
        attractionEs.isAcceptableOrUnknown(
          data['attraction_es']!,
          _attractionEsMeta,
        ),
      );
    }
    if (data.containsKey('abbreviation')) {
      context.handle(
        _abbreviationMeta,
        abbreviation.isAcceptableOrUnknown(
          data['abbreviation']!,
          _abbreviationMeta,
        ),
      );
    }
    if (data.containsKey('park_id')) {
      context.handle(
        _parkIdMeta,
        parkId.isAcceptableOrUnknown(data['park_id']!, _parkIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitSite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      islandId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}island_id'],
      ),
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      descriptionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_es'],
      ),
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      ),
      monitoringType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitoring_type'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      conservationZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conservation_zone'],
      ),
      publicUseZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_use_zone'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      attractionEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attraction_es'],
      ),
      abbreviation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbreviation'],
      ),
      parkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}park_id'],
      ),
    );
  }

  @override
  $VisitSitesTable createAlias(String alias) {
    return $VisitSitesTable(attachedDatabase, alias);
  }
}

class VisitSite extends DataClass implements Insertable<VisitSite> {
  final int id;
  final int? islandId;
  final String nameEs;
  final String? nameEn;
  final double? latitude;
  final double? longitude;
  final String? descriptionEs;
  final String? descriptionEn;
  final String? monitoringType;
  final String? difficulty;
  final String? conservationZone;
  final String? publicUseZone;
  final int? capacity;
  final String? status;
  final String? attractionEs;
  final String? abbreviation;
  final String? parkId;
  const VisitSite({
    required this.id,
    this.islandId,
    required this.nameEs,
    this.nameEn,
    this.latitude,
    this.longitude,
    this.descriptionEs,
    this.descriptionEn,
    this.monitoringType,
    this.difficulty,
    this.conservationZone,
    this.publicUseZone,
    this.capacity,
    this.status,
    this.attractionEs,
    this.abbreviation,
    this.parkId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || islandId != null) {
      map['island_id'] = Variable<int>(islandId);
    }
    map['name_es'] = Variable<String>(nameEs);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || descriptionEs != null) {
      map['description_es'] = Variable<String>(descriptionEs);
    }
    if (!nullToAbsent || descriptionEn != null) {
      map['description_en'] = Variable<String>(descriptionEn);
    }
    if (!nullToAbsent || monitoringType != null) {
      map['monitoring_type'] = Variable<String>(monitoringType);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    if (!nullToAbsent || conservationZone != null) {
      map['conservation_zone'] = Variable<String>(conservationZone);
    }
    if (!nullToAbsent || publicUseZone != null) {
      map['public_use_zone'] = Variable<String>(publicUseZone);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<int>(capacity);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || attractionEs != null) {
      map['attraction_es'] = Variable<String>(attractionEs);
    }
    if (!nullToAbsent || abbreviation != null) {
      map['abbreviation'] = Variable<String>(abbreviation);
    }
    if (!nullToAbsent || parkId != null) {
      map['park_id'] = Variable<String>(parkId);
    }
    return map;
  }

  VisitSitesCompanion toCompanion(bool nullToAbsent) {
    return VisitSitesCompanion(
      id: Value(id),
      islandId: islandId == null && nullToAbsent
          ? const Value.absent()
          : Value(islandId),
      nameEs: Value(nameEs),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      descriptionEs: descriptionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEs),
      descriptionEn: descriptionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionEn),
      monitoringType: monitoringType == null && nullToAbsent
          ? const Value.absent()
          : Value(monitoringType),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      conservationZone: conservationZone == null && nullToAbsent
          ? const Value.absent()
          : Value(conservationZone),
      publicUseZone: publicUseZone == null && nullToAbsent
          ? const Value.absent()
          : Value(publicUseZone),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      attractionEs: attractionEs == null && nullToAbsent
          ? const Value.absent()
          : Value(attractionEs),
      abbreviation: abbreviation == null && nullToAbsent
          ? const Value.absent()
          : Value(abbreviation),
      parkId: parkId == null && nullToAbsent
          ? const Value.absent()
          : Value(parkId),
    );
  }

  factory VisitSite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitSite(
      id: serializer.fromJson<int>(json['id']),
      islandId: serializer.fromJson<int?>(json['islandId']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      descriptionEs: serializer.fromJson<String?>(json['descriptionEs']),
      descriptionEn: serializer.fromJson<String?>(json['descriptionEn']),
      monitoringType: serializer.fromJson<String?>(json['monitoringType']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      conservationZone: serializer.fromJson<String?>(json['conservationZone']),
      publicUseZone: serializer.fromJson<String?>(json['publicUseZone']),
      capacity: serializer.fromJson<int?>(json['capacity']),
      status: serializer.fromJson<String?>(json['status']),
      attractionEs: serializer.fromJson<String?>(json['attractionEs']),
      abbreviation: serializer.fromJson<String?>(json['abbreviation']),
      parkId: serializer.fromJson<String?>(json['parkId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'islandId': serializer.toJson<int?>(islandId),
      'nameEs': serializer.toJson<String>(nameEs),
      'nameEn': serializer.toJson<String?>(nameEn),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'descriptionEs': serializer.toJson<String?>(descriptionEs),
      'descriptionEn': serializer.toJson<String?>(descriptionEn),
      'monitoringType': serializer.toJson<String?>(monitoringType),
      'difficulty': serializer.toJson<String?>(difficulty),
      'conservationZone': serializer.toJson<String?>(conservationZone),
      'publicUseZone': serializer.toJson<String?>(publicUseZone),
      'capacity': serializer.toJson<int?>(capacity),
      'status': serializer.toJson<String?>(status),
      'attractionEs': serializer.toJson<String?>(attractionEs),
      'abbreviation': serializer.toJson<String?>(abbreviation),
      'parkId': serializer.toJson<String?>(parkId),
    };
  }

  VisitSite copyWith({
    int? id,
    Value<int?> islandId = const Value.absent(),
    String? nameEs,
    Value<String?> nameEn = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> descriptionEs = const Value.absent(),
    Value<String?> descriptionEn = const Value.absent(),
    Value<String?> monitoringType = const Value.absent(),
    Value<String?> difficulty = const Value.absent(),
    Value<String?> conservationZone = const Value.absent(),
    Value<String?> publicUseZone = const Value.absent(),
    Value<int?> capacity = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> attractionEs = const Value.absent(),
    Value<String?> abbreviation = const Value.absent(),
    Value<String?> parkId = const Value.absent(),
  }) => VisitSite(
    id: id ?? this.id,
    islandId: islandId.present ? islandId.value : this.islandId,
    nameEs: nameEs ?? this.nameEs,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    descriptionEs: descriptionEs.present
        ? descriptionEs.value
        : this.descriptionEs,
    descriptionEn: descriptionEn.present
        ? descriptionEn.value
        : this.descriptionEn,
    monitoringType: monitoringType.present
        ? monitoringType.value
        : this.monitoringType,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    conservationZone: conservationZone.present
        ? conservationZone.value
        : this.conservationZone,
    publicUseZone: publicUseZone.present
        ? publicUseZone.value
        : this.publicUseZone,
    capacity: capacity.present ? capacity.value : this.capacity,
    status: status.present ? status.value : this.status,
    attractionEs: attractionEs.present ? attractionEs.value : this.attractionEs,
    abbreviation: abbreviation.present ? abbreviation.value : this.abbreviation,
    parkId: parkId.present ? parkId.value : this.parkId,
  );
  VisitSite copyWithCompanion(VisitSitesCompanion data) {
    return VisitSite(
      id: data.id.present ? data.id.value : this.id,
      islandId: data.islandId.present ? data.islandId.value : this.islandId,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      descriptionEs: data.descriptionEs.present
          ? data.descriptionEs.value
          : this.descriptionEs,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      monitoringType: data.monitoringType.present
          ? data.monitoringType.value
          : this.monitoringType,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      conservationZone: data.conservationZone.present
          ? data.conservationZone.value
          : this.conservationZone,
      publicUseZone: data.publicUseZone.present
          ? data.publicUseZone.value
          : this.publicUseZone,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      status: data.status.present ? data.status.value : this.status,
      attractionEs: data.attractionEs.present
          ? data.attractionEs.value
          : this.attractionEs,
      abbreviation: data.abbreviation.present
          ? data.abbreviation.value
          : this.abbreviation,
      parkId: data.parkId.present ? data.parkId.value : this.parkId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitSite(')
          ..write('id: $id, ')
          ..write('islandId: $islandId, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('monitoringType: $monitoringType, ')
          ..write('difficulty: $difficulty, ')
          ..write('conservationZone: $conservationZone, ')
          ..write('publicUseZone: $publicUseZone, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status, ')
          ..write('attractionEs: $attractionEs, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('parkId: $parkId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    islandId,
    nameEs,
    nameEn,
    latitude,
    longitude,
    descriptionEs,
    descriptionEn,
    monitoringType,
    difficulty,
    conservationZone,
    publicUseZone,
    capacity,
    status,
    attractionEs,
    abbreviation,
    parkId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitSite &&
          other.id == this.id &&
          other.islandId == this.islandId &&
          other.nameEs == this.nameEs &&
          other.nameEn == this.nameEn &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.descriptionEs == this.descriptionEs &&
          other.descriptionEn == this.descriptionEn &&
          other.monitoringType == this.monitoringType &&
          other.difficulty == this.difficulty &&
          other.conservationZone == this.conservationZone &&
          other.publicUseZone == this.publicUseZone &&
          other.capacity == this.capacity &&
          other.status == this.status &&
          other.attractionEs == this.attractionEs &&
          other.abbreviation == this.abbreviation &&
          other.parkId == this.parkId);
}

class VisitSitesCompanion extends UpdateCompanion<VisitSite> {
  final Value<int> id;
  final Value<int?> islandId;
  final Value<String> nameEs;
  final Value<String?> nameEn;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> descriptionEs;
  final Value<String?> descriptionEn;
  final Value<String?> monitoringType;
  final Value<String?> difficulty;
  final Value<String?> conservationZone;
  final Value<String?> publicUseZone;
  final Value<int?> capacity;
  final Value<String?> status;
  final Value<String?> attractionEs;
  final Value<String?> abbreviation;
  final Value<String?> parkId;
  const VisitSitesCompanion({
    this.id = const Value.absent(),
    this.islandId = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.monitoringType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.conservationZone = const Value.absent(),
    this.publicUseZone = const Value.absent(),
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.attractionEs = const Value.absent(),
    this.abbreviation = const Value.absent(),
    this.parkId = const Value.absent(),
  });
  VisitSitesCompanion.insert({
    this.id = const Value.absent(),
    this.islandId = const Value.absent(),
    required String nameEs,
    this.nameEn = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.descriptionEs = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.monitoringType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.conservationZone = const Value.absent(),
    this.publicUseZone = const Value.absent(),
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.attractionEs = const Value.absent(),
    this.abbreviation = const Value.absent(),
    this.parkId = const Value.absent(),
  }) : nameEs = Value(nameEs);
  static Insertable<VisitSite> custom({
    Expression<int>? id,
    Expression<int>? islandId,
    Expression<String>? nameEs,
    Expression<String>? nameEn,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? descriptionEs,
    Expression<String>? descriptionEn,
    Expression<String>? monitoringType,
    Expression<String>? difficulty,
    Expression<String>? conservationZone,
    Expression<String>? publicUseZone,
    Expression<int>? capacity,
    Expression<String>? status,
    Expression<String>? attractionEs,
    Expression<String>? abbreviation,
    Expression<String>? parkId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (islandId != null) 'island_id': islandId,
      if (nameEs != null) 'name_es': nameEs,
      if (nameEn != null) 'name_en': nameEn,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (monitoringType != null) 'monitoring_type': monitoringType,
      if (difficulty != null) 'difficulty': difficulty,
      if (conservationZone != null) 'conservation_zone': conservationZone,
      if (publicUseZone != null) 'public_use_zone': publicUseZone,
      if (capacity != null) 'capacity': capacity,
      if (status != null) 'status': status,
      if (attractionEs != null) 'attraction_es': attractionEs,
      if (abbreviation != null) 'abbreviation': abbreviation,
      if (parkId != null) 'park_id': parkId,
    });
  }

  VisitSitesCompanion copyWith({
    Value<int>? id,
    Value<int?>? islandId,
    Value<String>? nameEs,
    Value<String?>? nameEn,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? descriptionEs,
    Value<String?>? descriptionEn,
    Value<String?>? monitoringType,
    Value<String?>? difficulty,
    Value<String?>? conservationZone,
    Value<String?>? publicUseZone,
    Value<int?>? capacity,
    Value<String?>? status,
    Value<String?>? attractionEs,
    Value<String?>? abbreviation,
    Value<String?>? parkId,
  }) {
    return VisitSitesCompanion(
      id: id ?? this.id,
      islandId: islandId ?? this.islandId,
      nameEs: nameEs ?? this.nameEs,
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      monitoringType: monitoringType ?? this.monitoringType,
      difficulty: difficulty ?? this.difficulty,
      conservationZone: conservationZone ?? this.conservationZone,
      publicUseZone: publicUseZone ?? this.publicUseZone,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      attractionEs: attractionEs ?? this.attractionEs,
      abbreviation: abbreviation ?? this.abbreviation,
      parkId: parkId ?? this.parkId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (islandId.present) {
      map['island_id'] = Variable<int>(islandId.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (descriptionEs.present) {
      map['description_es'] = Variable<String>(descriptionEs.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (monitoringType.present) {
      map['monitoring_type'] = Variable<String>(monitoringType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (conservationZone.present) {
      map['conservation_zone'] = Variable<String>(conservationZone.value);
    }
    if (publicUseZone.present) {
      map['public_use_zone'] = Variable<String>(publicUseZone.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attractionEs.present) {
      map['attraction_es'] = Variable<String>(attractionEs.value);
    }
    if (abbreviation.present) {
      map['abbreviation'] = Variable<String>(abbreviation.value);
    }
    if (parkId.present) {
      map['park_id'] = Variable<String>(parkId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitSitesCompanion(')
          ..write('id: $id, ')
          ..write('islandId: $islandId, ')
          ..write('nameEs: $nameEs, ')
          ..write('nameEn: $nameEn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('descriptionEs: $descriptionEs, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('monitoringType: $monitoringType, ')
          ..write('difficulty: $difficulty, ')
          ..write('conservationZone: $conservationZone, ')
          ..write('publicUseZone: $publicUseZone, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status, ')
          ..write('attractionEs: $attractionEs, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('parkId: $parkId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $IslandsTable islands = $IslandsTable(this);
  late final $SpeciesRowsTable speciesRows = $SpeciesRowsTable(this);
  late final $SightingsTable sightings = $SightingsTable(this);
  late final $SpeciesImagesTable speciesImages = $SpeciesImagesTable(this);
  late final $SpeciesReferencesTable speciesReferences =
      $SpeciesReferencesTable(this);
  late final $SpeciesSitesTable speciesSites = $SpeciesSitesTable(this);
  late final $SpeciesSoundsTable speciesSounds = $SpeciesSoundsTable(this);
  late final $SpeciesThreatsTable speciesThreats = $SpeciesThreatsTable(this);
  late final $TrailsTable trails = $TrailsTable(this);
  late final $UserFavoritesTable userFavorites = $UserFavoritesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserSiteWishlistsTable userSiteWishlists =
      $UserSiteWishlistsTable(this);
  late final $UserSpeciesChecklistsTable userSpeciesChecklists =
      $UserSpeciesChecklistsTable(this);
  late final $VisitSitesTable visitSites = $VisitSitesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    islands,
    speciesRows,
    sightings,
    speciesImages,
    speciesReferences,
    speciesSites,
    speciesSounds,
    speciesThreats,
    trails,
    userFavorites,
    userProfiles,
    userSiteWishlists,
    userSpeciesChecklists,
    visitSites,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String slug,
      required String nameEs,
      required String nameEn,
      Value<String?> iconName,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> nameEs,
      Value<String> nameEn,
      Value<String?> iconName,
      Value<int> sortOrder,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> nameEs = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                slug: slug,
                nameEs: nameEs,
                nameEn: nameEn,
                iconName: iconName,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String nameEs,
                required String nameEn,
                Value<String?> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                slug: slug,
                nameEs: nameEs,
                nameEn: nameEn,
                iconName: iconName,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$IslandsTableCreateCompanionBuilder =
    IslandsCompanion Function({
      Value<int> id,
      required String nameEs,
      required String nameEn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> areaKm2,
      Value<double?> areaHa,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> parkId,
      Value<String?> islandType,
      Value<String?> classification,
      Value<bool?> isPopulated,
    });
typedef $$IslandsTableUpdateCompanionBuilder =
    IslandsCompanion Function({
      Value<int> id,
      Value<String> nameEs,
      Value<String> nameEn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> areaKm2,
      Value<double?> areaHa,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> parkId,
      Value<String?> islandType,
      Value<String?> classification,
      Value<bool?> isPopulated,
    });

class $$IslandsTableFilterComposer
    extends Composer<_$AppDatabase, $IslandsTable> {
  $$IslandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parkId => $composableBuilder(
    column: $table.parkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get islandType => $composableBuilder(
    column: $table.islandType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPopulated => $composableBuilder(
    column: $table.isPopulated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IslandsTableOrderingComposer
    extends Composer<_$AppDatabase, $IslandsTable> {
  $$IslandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaHa => $composableBuilder(
    column: $table.areaHa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parkId => $composableBuilder(
    column: $table.parkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get islandType => $composableBuilder(
    column: $table.islandType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPopulated => $composableBuilder(
    column: $table.isPopulated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IslandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IslandsTable> {
  $$IslandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get areaKm2 =>
      $composableBuilder(column: $table.areaKm2, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parkId =>
      $composableBuilder(column: $table.parkId, builder: (column) => column);

  GeneratedColumn<String> get islandType => $composableBuilder(
    column: $table.islandType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPopulated => $composableBuilder(
    column: $table.isPopulated,
    builder: (column) => column,
  );
}

class $$IslandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IslandsTable,
          Island,
          $$IslandsTableFilterComposer,
          $$IslandsTableOrderingComposer,
          $$IslandsTableAnnotationComposer,
          $$IslandsTableCreateCompanionBuilder,
          $$IslandsTableUpdateCompanionBuilder,
          (Island, BaseReferences<_$AppDatabase, $IslandsTable, Island>),
          Island,
          PrefetchHooks Function()
        > {
  $$IslandsTableTableManager(_$AppDatabase db, $IslandsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IslandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IslandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IslandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameEs = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> areaKm2 = const Value.absent(),
                Value<double?> areaHa = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> parkId = const Value.absent(),
                Value<String?> islandType = const Value.absent(),
                Value<String?> classification = const Value.absent(),
                Value<bool?> isPopulated = const Value.absent(),
              }) => IslandsCompanion(
                id: id,
                nameEs: nameEs,
                nameEn: nameEn,
                latitude: latitude,
                longitude: longitude,
                areaKm2: areaKm2,
                areaHa: areaHa,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                parkId: parkId,
                islandType: islandType,
                classification: classification,
                isPopulated: isPopulated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameEs,
                required String nameEn,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> areaKm2 = const Value.absent(),
                Value<double?> areaHa = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> parkId = const Value.absent(),
                Value<String?> islandType = const Value.absent(),
                Value<String?> classification = const Value.absent(),
                Value<bool?> isPopulated = const Value.absent(),
              }) => IslandsCompanion.insert(
                id: id,
                nameEs: nameEs,
                nameEn: nameEn,
                latitude: latitude,
                longitude: longitude,
                areaKm2: areaKm2,
                areaHa: areaHa,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                parkId: parkId,
                islandType: islandType,
                classification: classification,
                isPopulated: isPopulated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IslandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IslandsTable,
      Island,
      $$IslandsTableFilterComposer,
      $$IslandsTableOrderingComposer,
      $$IslandsTableAnnotationComposer,
      $$IslandsTableCreateCompanionBuilder,
      $$IslandsTableUpdateCompanionBuilder,
      (Island, BaseReferences<_$AppDatabase, $IslandsTable, Island>),
      Island,
      PrefetchHooks Function()
    >;
typedef $$SpeciesRowsTableCreateCompanionBuilder =
    SpeciesRowsCompanion Function({
      Value<int> id,
      required int categoryId,
      required String commonNameEs,
      required String commonNameEn,
      required String scientificName,
      Value<String?> conservationStatus,
      Value<double?> weightKg,
      Value<double?> sizeCm,
      Value<int?> populationEstimate,
      Value<int?> lifespanYears,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> habitatEs,
      Value<String?> habitatEn,
      Value<String?> heroImageUrl,
      Value<String?> thumbnailUrl,
      Value<bool> isEndemic,
      Value<String?> taxonomyKingdom,
      Value<String?> taxonomyPhylum,
      Value<String?> taxonomyClass,
      Value<String?> taxonomyOrder,
      Value<String?> taxonomyFamily,
      Value<String?> taxonomyGenus,
      Value<bool?> isNative,
      Value<bool?> isIntroduced,
      Value<String?> endemismLevel,
      Value<String?> populationTrend,
      Value<String?> breedingSeason,
      Value<String?> clutchSize,
      Value<String?> reproductiveFrequency,
      Value<String?> socialStructure,
      Value<String?> activityPattern,
      Value<String?> dietType,
      Value<List<String>?> primaryFoodSources,
      Value<int?> altitudeMinM,
      Value<int?> altitudeMaxM,
      Value<int?> depthMinM,
      Value<int?> depthMaxM,
      Value<String?> scientificNameAuthorship,
      Value<String?> distinguishingFeaturesEs,
      Value<String?> distinguishingFeaturesEn,
      Value<String?> sexualDimorphism,
      Value<String?> gbifTaxonId,
      Value<String?> eolPageId,
      Value<String?> iucnAssessmentUrl,
      Value<String?> soundRecordingUrl,
      Value<String?> videoUrl,
      Value<double?> sizeMmFemaleMin,
      Value<double?> sizeMmFemaleMax,
      Value<double?> sizeMmMaleMin,
      Value<double?> sizeMmMaleMax,
      Value<bool?> buildsWeb,
      Value<String?> webType,
      Value<bool?> venomousToHumans,
      Value<int?> inaturalistTaxonId,
      Value<int?> datazoneId,
    });
typedef $$SpeciesRowsTableUpdateCompanionBuilder =
    SpeciesRowsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> commonNameEs,
      Value<String> commonNameEn,
      Value<String> scientificName,
      Value<String?> conservationStatus,
      Value<double?> weightKg,
      Value<double?> sizeCm,
      Value<int?> populationEstimate,
      Value<int?> lifespanYears,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> habitatEs,
      Value<String?> habitatEn,
      Value<String?> heroImageUrl,
      Value<String?> thumbnailUrl,
      Value<bool> isEndemic,
      Value<String?> taxonomyKingdom,
      Value<String?> taxonomyPhylum,
      Value<String?> taxonomyClass,
      Value<String?> taxonomyOrder,
      Value<String?> taxonomyFamily,
      Value<String?> taxonomyGenus,
      Value<bool?> isNative,
      Value<bool?> isIntroduced,
      Value<String?> endemismLevel,
      Value<String?> populationTrend,
      Value<String?> breedingSeason,
      Value<String?> clutchSize,
      Value<String?> reproductiveFrequency,
      Value<String?> socialStructure,
      Value<String?> activityPattern,
      Value<String?> dietType,
      Value<List<String>?> primaryFoodSources,
      Value<int?> altitudeMinM,
      Value<int?> altitudeMaxM,
      Value<int?> depthMinM,
      Value<int?> depthMaxM,
      Value<String?> scientificNameAuthorship,
      Value<String?> distinguishingFeaturesEs,
      Value<String?> distinguishingFeaturesEn,
      Value<String?> sexualDimorphism,
      Value<String?> gbifTaxonId,
      Value<String?> eolPageId,
      Value<String?> iucnAssessmentUrl,
      Value<String?> soundRecordingUrl,
      Value<String?> videoUrl,
      Value<double?> sizeMmFemaleMin,
      Value<double?> sizeMmFemaleMax,
      Value<double?> sizeMmMaleMin,
      Value<double?> sizeMmMaleMax,
      Value<bool?> buildsWeb,
      Value<String?> webType,
      Value<bool?> venomousToHumans,
      Value<int?> inaturalistTaxonId,
      Value<int?> datazoneId,
    });

class $$SpeciesRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesRowsTable> {
  $$SpeciesRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonNameEs => $composableBuilder(
    column: $table.commonNameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonNameEn => $composableBuilder(
    column: $table.commonNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conservationStatus => $composableBuilder(
    column: $table.conservationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeCm => $composableBuilder(
    column: $table.sizeCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get populationEstimate => $composableBuilder(
    column: $table.populationEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifespanYears => $composableBuilder(
    column: $table.lifespanYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitatEs => $composableBuilder(
    column: $table.habitatEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitatEn => $composableBuilder(
    column: $table.habitatEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroImageUrl => $composableBuilder(
    column: $table.heroImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEndemic => $composableBuilder(
    column: $table.isEndemic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyKingdom => $composableBuilder(
    column: $table.taxonomyKingdom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyPhylum => $composableBuilder(
    column: $table.taxonomyPhylum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyClass => $composableBuilder(
    column: $table.taxonomyClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyOrder => $composableBuilder(
    column: $table.taxonomyOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyFamily => $composableBuilder(
    column: $table.taxonomyFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxonomyGenus => $composableBuilder(
    column: $table.taxonomyGenus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNative => $composableBuilder(
    column: $table.isNative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIntroduced => $composableBuilder(
    column: $table.isIntroduced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endemismLevel => $composableBuilder(
    column: $table.endemismLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get populationTrend => $composableBuilder(
    column: $table.populationTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breedingSeason => $composableBuilder(
    column: $table.breedingSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reproductiveFrequency => $composableBuilder(
    column: $table.reproductiveFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get socialStructure => $composableBuilder(
    column: $table.socialStructure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityPattern => $composableBuilder(
    column: $table.activityPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietType => $composableBuilder(
    column: $table.dietType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get primaryFoodSources => $composableBuilder(
    column: $table.primaryFoodSources,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get altitudeMinM => $composableBuilder(
    column: $table.altitudeMinM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get altitudeMaxM => $composableBuilder(
    column: $table.altitudeMaxM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depthMinM => $composableBuilder(
    column: $table.depthMinM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depthMaxM => $composableBuilder(
    column: $table.depthMaxM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificNameAuthorship => $composableBuilder(
    column: $table.scientificNameAuthorship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distinguishingFeaturesEs => $composableBuilder(
    column: $table.distinguishingFeaturesEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distinguishingFeaturesEn => $composableBuilder(
    column: $table.distinguishingFeaturesEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexualDimorphism => $composableBuilder(
    column: $table.sexualDimorphism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gbifTaxonId => $composableBuilder(
    column: $table.gbifTaxonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eolPageId => $composableBuilder(
    column: $table.eolPageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iucnAssessmentUrl => $composableBuilder(
    column: $table.iucnAssessmentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundRecordingUrl => $composableBuilder(
    column: $table.soundRecordingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeMmFemaleMin => $composableBuilder(
    column: $table.sizeMmFemaleMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeMmFemaleMax => $composableBuilder(
    column: $table.sizeMmFemaleMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeMmMaleMin => $composableBuilder(
    column: $table.sizeMmMaleMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeMmMaleMax => $composableBuilder(
    column: $table.sizeMmMaleMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get buildsWeb => $composableBuilder(
    column: $table.buildsWeb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get webType => $composableBuilder(
    column: $table.webType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get venomousToHumans => $composableBuilder(
    column: $table.venomousToHumans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inaturalistTaxonId => $composableBuilder(
    column: $table.inaturalistTaxonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get datazoneId => $composableBuilder(
    column: $table.datazoneId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesRowsTable> {
  $$SpeciesRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonNameEs => $composableBuilder(
    column: $table.commonNameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonNameEn => $composableBuilder(
    column: $table.commonNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conservationStatus => $composableBuilder(
    column: $table.conservationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeCm => $composableBuilder(
    column: $table.sizeCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get populationEstimate => $composableBuilder(
    column: $table.populationEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifespanYears => $composableBuilder(
    column: $table.lifespanYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitatEs => $composableBuilder(
    column: $table.habitatEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitatEn => $composableBuilder(
    column: $table.habitatEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroImageUrl => $composableBuilder(
    column: $table.heroImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEndemic => $composableBuilder(
    column: $table.isEndemic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyKingdom => $composableBuilder(
    column: $table.taxonomyKingdom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyPhylum => $composableBuilder(
    column: $table.taxonomyPhylum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyClass => $composableBuilder(
    column: $table.taxonomyClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyOrder => $composableBuilder(
    column: $table.taxonomyOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyFamily => $composableBuilder(
    column: $table.taxonomyFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxonomyGenus => $composableBuilder(
    column: $table.taxonomyGenus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNative => $composableBuilder(
    column: $table.isNative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIntroduced => $composableBuilder(
    column: $table.isIntroduced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endemismLevel => $composableBuilder(
    column: $table.endemismLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get populationTrend => $composableBuilder(
    column: $table.populationTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breedingSeason => $composableBuilder(
    column: $table.breedingSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reproductiveFrequency => $composableBuilder(
    column: $table.reproductiveFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get socialStructure => $composableBuilder(
    column: $table.socialStructure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityPattern => $composableBuilder(
    column: $table.activityPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietType => $composableBuilder(
    column: $table.dietType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryFoodSources => $composableBuilder(
    column: $table.primaryFoodSources,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get altitudeMinM => $composableBuilder(
    column: $table.altitudeMinM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get altitudeMaxM => $composableBuilder(
    column: $table.altitudeMaxM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depthMinM => $composableBuilder(
    column: $table.depthMinM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depthMaxM => $composableBuilder(
    column: $table.depthMaxM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificNameAuthorship => $composableBuilder(
    column: $table.scientificNameAuthorship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distinguishingFeaturesEs => $composableBuilder(
    column: $table.distinguishingFeaturesEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distinguishingFeaturesEn => $composableBuilder(
    column: $table.distinguishingFeaturesEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexualDimorphism => $composableBuilder(
    column: $table.sexualDimorphism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gbifTaxonId => $composableBuilder(
    column: $table.gbifTaxonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eolPageId => $composableBuilder(
    column: $table.eolPageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iucnAssessmentUrl => $composableBuilder(
    column: $table.iucnAssessmentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundRecordingUrl => $composableBuilder(
    column: $table.soundRecordingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeMmFemaleMin => $composableBuilder(
    column: $table.sizeMmFemaleMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeMmFemaleMax => $composableBuilder(
    column: $table.sizeMmFemaleMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeMmMaleMin => $composableBuilder(
    column: $table.sizeMmMaleMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeMmMaleMax => $composableBuilder(
    column: $table.sizeMmMaleMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get buildsWeb => $composableBuilder(
    column: $table.buildsWeb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get webType => $composableBuilder(
    column: $table.webType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get venomousToHumans => $composableBuilder(
    column: $table.venomousToHumans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inaturalistTaxonId => $composableBuilder(
    column: $table.inaturalistTaxonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get datazoneId => $composableBuilder(
    column: $table.datazoneId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesRowsTable> {
  $$SpeciesRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commonNameEs => $composableBuilder(
    column: $table.commonNameEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commonNameEn => $composableBuilder(
    column: $table.commonNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conservationStatus => $composableBuilder(
    column: $table.conservationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get sizeCm =>
      $composableBuilder(column: $table.sizeCm, builder: (column) => column);

  GeneratedColumn<int> get populationEstimate => $composableBuilder(
    column: $table.populationEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifespanYears => $composableBuilder(
    column: $table.lifespanYears,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get habitatEs =>
      $composableBuilder(column: $table.habitatEs, builder: (column) => column);

  GeneratedColumn<String> get habitatEn =>
      $composableBuilder(column: $table.habitatEn, builder: (column) => column);

  GeneratedColumn<String> get heroImageUrl => $composableBuilder(
    column: $table.heroImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEndemic =>
      $composableBuilder(column: $table.isEndemic, builder: (column) => column);

  GeneratedColumn<String> get taxonomyKingdom => $composableBuilder(
    column: $table.taxonomyKingdom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxonomyPhylum => $composableBuilder(
    column: $table.taxonomyPhylum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxonomyClass => $composableBuilder(
    column: $table.taxonomyClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxonomyOrder => $composableBuilder(
    column: $table.taxonomyOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxonomyFamily => $composableBuilder(
    column: $table.taxonomyFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxonomyGenus => $composableBuilder(
    column: $table.taxonomyGenus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNative =>
      $composableBuilder(column: $table.isNative, builder: (column) => column);

  GeneratedColumn<bool> get isIntroduced => $composableBuilder(
    column: $table.isIntroduced,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endemismLevel => $composableBuilder(
    column: $table.endemismLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get populationTrend => $composableBuilder(
    column: $table.populationTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get breedingSeason => $composableBuilder(
    column: $table.breedingSeason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reproductiveFrequency => $composableBuilder(
    column: $table.reproductiveFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get socialStructure => $composableBuilder(
    column: $table.socialStructure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityPattern => $composableBuilder(
    column: $table.activityPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietType =>
      $composableBuilder(column: $table.dietType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String>
  get primaryFoodSources => $composableBuilder(
    column: $table.primaryFoodSources,
    builder: (column) => column,
  );

  GeneratedColumn<int> get altitudeMinM => $composableBuilder(
    column: $table.altitudeMinM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get altitudeMaxM => $composableBuilder(
    column: $table.altitudeMaxM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get depthMinM =>
      $composableBuilder(column: $table.depthMinM, builder: (column) => column);

  GeneratedColumn<int> get depthMaxM =>
      $composableBuilder(column: $table.depthMaxM, builder: (column) => column);

  GeneratedColumn<String> get scientificNameAuthorship => $composableBuilder(
    column: $table.scientificNameAuthorship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distinguishingFeaturesEs => $composableBuilder(
    column: $table.distinguishingFeaturesEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distinguishingFeaturesEn => $composableBuilder(
    column: $table.distinguishingFeaturesEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sexualDimorphism => $composableBuilder(
    column: $table.sexualDimorphism,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gbifTaxonId => $composableBuilder(
    column: $table.gbifTaxonId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eolPageId =>
      $composableBuilder(column: $table.eolPageId, builder: (column) => column);

  GeneratedColumn<String> get iucnAssessmentUrl => $composableBuilder(
    column: $table.iucnAssessmentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soundRecordingUrl => $composableBuilder(
    column: $table.soundRecordingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<double> get sizeMmFemaleMin => $composableBuilder(
    column: $table.sizeMmFemaleMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sizeMmFemaleMax => $composableBuilder(
    column: $table.sizeMmFemaleMax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sizeMmMaleMin => $composableBuilder(
    column: $table.sizeMmMaleMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sizeMmMaleMax => $composableBuilder(
    column: $table.sizeMmMaleMax,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get buildsWeb =>
      $composableBuilder(column: $table.buildsWeb, builder: (column) => column);

  GeneratedColumn<String> get webType =>
      $composableBuilder(column: $table.webType, builder: (column) => column);

  GeneratedColumn<bool> get venomousToHumans => $composableBuilder(
    column: $table.venomousToHumans,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inaturalistTaxonId => $composableBuilder(
    column: $table.inaturalistTaxonId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get datazoneId => $composableBuilder(
    column: $table.datazoneId,
    builder: (column) => column,
  );
}

class $$SpeciesRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesRowsTable,
          SpeciesRow,
          $$SpeciesRowsTableFilterComposer,
          $$SpeciesRowsTableOrderingComposer,
          $$SpeciesRowsTableAnnotationComposer,
          $$SpeciesRowsTableCreateCompanionBuilder,
          $$SpeciesRowsTableUpdateCompanionBuilder,
          (
            SpeciesRow,
            BaseReferences<_$AppDatabase, $SpeciesRowsTable, SpeciesRow>,
          ),
          SpeciesRow,
          PrefetchHooks Function()
        > {
  $$SpeciesRowsTableTableManager(_$AppDatabase db, $SpeciesRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> commonNameEs = const Value.absent(),
                Value<String> commonNameEn = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<String?> conservationStatus = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> sizeCm = const Value.absent(),
                Value<int?> populationEstimate = const Value.absent(),
                Value<int?> lifespanYears = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> habitatEs = const Value.absent(),
                Value<String?> habitatEn = const Value.absent(),
                Value<String?> heroImageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> isEndemic = const Value.absent(),
                Value<String?> taxonomyKingdom = const Value.absent(),
                Value<String?> taxonomyPhylum = const Value.absent(),
                Value<String?> taxonomyClass = const Value.absent(),
                Value<String?> taxonomyOrder = const Value.absent(),
                Value<String?> taxonomyFamily = const Value.absent(),
                Value<String?> taxonomyGenus = const Value.absent(),
                Value<bool?> isNative = const Value.absent(),
                Value<bool?> isIntroduced = const Value.absent(),
                Value<String?> endemismLevel = const Value.absent(),
                Value<String?> populationTrend = const Value.absent(),
                Value<String?> breedingSeason = const Value.absent(),
                Value<String?> clutchSize = const Value.absent(),
                Value<String?> reproductiveFrequency = const Value.absent(),
                Value<String?> socialStructure = const Value.absent(),
                Value<String?> activityPattern = const Value.absent(),
                Value<String?> dietType = const Value.absent(),
                Value<List<String>?> primaryFoodSources = const Value.absent(),
                Value<int?> altitudeMinM = const Value.absent(),
                Value<int?> altitudeMaxM = const Value.absent(),
                Value<int?> depthMinM = const Value.absent(),
                Value<int?> depthMaxM = const Value.absent(),
                Value<String?> scientificNameAuthorship = const Value.absent(),
                Value<String?> distinguishingFeaturesEs = const Value.absent(),
                Value<String?> distinguishingFeaturesEn = const Value.absent(),
                Value<String?> sexualDimorphism = const Value.absent(),
                Value<String?> gbifTaxonId = const Value.absent(),
                Value<String?> eolPageId = const Value.absent(),
                Value<String?> iucnAssessmentUrl = const Value.absent(),
                Value<String?> soundRecordingUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<double?> sizeMmFemaleMin = const Value.absent(),
                Value<double?> sizeMmFemaleMax = const Value.absent(),
                Value<double?> sizeMmMaleMin = const Value.absent(),
                Value<double?> sizeMmMaleMax = const Value.absent(),
                Value<bool?> buildsWeb = const Value.absent(),
                Value<String?> webType = const Value.absent(),
                Value<bool?> venomousToHumans = const Value.absent(),
                Value<int?> inaturalistTaxonId = const Value.absent(),
                Value<int?> datazoneId = const Value.absent(),
              }) => SpeciesRowsCompanion(
                id: id,
                categoryId: categoryId,
                commonNameEs: commonNameEs,
                commonNameEn: commonNameEn,
                scientificName: scientificName,
                conservationStatus: conservationStatus,
                weightKg: weightKg,
                sizeCm: sizeCm,
                populationEstimate: populationEstimate,
                lifespanYears: lifespanYears,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                habitatEs: habitatEs,
                habitatEn: habitatEn,
                heroImageUrl: heroImageUrl,
                thumbnailUrl: thumbnailUrl,
                isEndemic: isEndemic,
                taxonomyKingdom: taxonomyKingdom,
                taxonomyPhylum: taxonomyPhylum,
                taxonomyClass: taxonomyClass,
                taxonomyOrder: taxonomyOrder,
                taxonomyFamily: taxonomyFamily,
                taxonomyGenus: taxonomyGenus,
                isNative: isNative,
                isIntroduced: isIntroduced,
                endemismLevel: endemismLevel,
                populationTrend: populationTrend,
                breedingSeason: breedingSeason,
                clutchSize: clutchSize,
                reproductiveFrequency: reproductiveFrequency,
                socialStructure: socialStructure,
                activityPattern: activityPattern,
                dietType: dietType,
                primaryFoodSources: primaryFoodSources,
                altitudeMinM: altitudeMinM,
                altitudeMaxM: altitudeMaxM,
                depthMinM: depthMinM,
                depthMaxM: depthMaxM,
                scientificNameAuthorship: scientificNameAuthorship,
                distinguishingFeaturesEs: distinguishingFeaturesEs,
                distinguishingFeaturesEn: distinguishingFeaturesEn,
                sexualDimorphism: sexualDimorphism,
                gbifTaxonId: gbifTaxonId,
                eolPageId: eolPageId,
                iucnAssessmentUrl: iucnAssessmentUrl,
                soundRecordingUrl: soundRecordingUrl,
                videoUrl: videoUrl,
                sizeMmFemaleMin: sizeMmFemaleMin,
                sizeMmFemaleMax: sizeMmFemaleMax,
                sizeMmMaleMin: sizeMmMaleMin,
                sizeMmMaleMax: sizeMmMaleMax,
                buildsWeb: buildsWeb,
                webType: webType,
                venomousToHumans: venomousToHumans,
                inaturalistTaxonId: inaturalistTaxonId,
                datazoneId: datazoneId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String commonNameEs,
                required String commonNameEn,
                required String scientificName,
                Value<String?> conservationStatus = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> sizeCm = const Value.absent(),
                Value<int?> populationEstimate = const Value.absent(),
                Value<int?> lifespanYears = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> habitatEs = const Value.absent(),
                Value<String?> habitatEn = const Value.absent(),
                Value<String?> heroImageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> isEndemic = const Value.absent(),
                Value<String?> taxonomyKingdom = const Value.absent(),
                Value<String?> taxonomyPhylum = const Value.absent(),
                Value<String?> taxonomyClass = const Value.absent(),
                Value<String?> taxonomyOrder = const Value.absent(),
                Value<String?> taxonomyFamily = const Value.absent(),
                Value<String?> taxonomyGenus = const Value.absent(),
                Value<bool?> isNative = const Value.absent(),
                Value<bool?> isIntroduced = const Value.absent(),
                Value<String?> endemismLevel = const Value.absent(),
                Value<String?> populationTrend = const Value.absent(),
                Value<String?> breedingSeason = const Value.absent(),
                Value<String?> clutchSize = const Value.absent(),
                Value<String?> reproductiveFrequency = const Value.absent(),
                Value<String?> socialStructure = const Value.absent(),
                Value<String?> activityPattern = const Value.absent(),
                Value<String?> dietType = const Value.absent(),
                Value<List<String>?> primaryFoodSources = const Value.absent(),
                Value<int?> altitudeMinM = const Value.absent(),
                Value<int?> altitudeMaxM = const Value.absent(),
                Value<int?> depthMinM = const Value.absent(),
                Value<int?> depthMaxM = const Value.absent(),
                Value<String?> scientificNameAuthorship = const Value.absent(),
                Value<String?> distinguishingFeaturesEs = const Value.absent(),
                Value<String?> distinguishingFeaturesEn = const Value.absent(),
                Value<String?> sexualDimorphism = const Value.absent(),
                Value<String?> gbifTaxonId = const Value.absent(),
                Value<String?> eolPageId = const Value.absent(),
                Value<String?> iucnAssessmentUrl = const Value.absent(),
                Value<String?> soundRecordingUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<double?> sizeMmFemaleMin = const Value.absent(),
                Value<double?> sizeMmFemaleMax = const Value.absent(),
                Value<double?> sizeMmMaleMin = const Value.absent(),
                Value<double?> sizeMmMaleMax = const Value.absent(),
                Value<bool?> buildsWeb = const Value.absent(),
                Value<String?> webType = const Value.absent(),
                Value<bool?> venomousToHumans = const Value.absent(),
                Value<int?> inaturalistTaxonId = const Value.absent(),
                Value<int?> datazoneId = const Value.absent(),
              }) => SpeciesRowsCompanion.insert(
                id: id,
                categoryId: categoryId,
                commonNameEs: commonNameEs,
                commonNameEn: commonNameEn,
                scientificName: scientificName,
                conservationStatus: conservationStatus,
                weightKg: weightKg,
                sizeCm: sizeCm,
                populationEstimate: populationEstimate,
                lifespanYears: lifespanYears,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                habitatEs: habitatEs,
                habitatEn: habitatEn,
                heroImageUrl: heroImageUrl,
                thumbnailUrl: thumbnailUrl,
                isEndemic: isEndemic,
                taxonomyKingdom: taxonomyKingdom,
                taxonomyPhylum: taxonomyPhylum,
                taxonomyClass: taxonomyClass,
                taxonomyOrder: taxonomyOrder,
                taxonomyFamily: taxonomyFamily,
                taxonomyGenus: taxonomyGenus,
                isNative: isNative,
                isIntroduced: isIntroduced,
                endemismLevel: endemismLevel,
                populationTrend: populationTrend,
                breedingSeason: breedingSeason,
                clutchSize: clutchSize,
                reproductiveFrequency: reproductiveFrequency,
                socialStructure: socialStructure,
                activityPattern: activityPattern,
                dietType: dietType,
                primaryFoodSources: primaryFoodSources,
                altitudeMinM: altitudeMinM,
                altitudeMaxM: altitudeMaxM,
                depthMinM: depthMinM,
                depthMaxM: depthMaxM,
                scientificNameAuthorship: scientificNameAuthorship,
                distinguishingFeaturesEs: distinguishingFeaturesEs,
                distinguishingFeaturesEn: distinguishingFeaturesEn,
                sexualDimorphism: sexualDimorphism,
                gbifTaxonId: gbifTaxonId,
                eolPageId: eolPageId,
                iucnAssessmentUrl: iucnAssessmentUrl,
                soundRecordingUrl: soundRecordingUrl,
                videoUrl: videoUrl,
                sizeMmFemaleMin: sizeMmFemaleMin,
                sizeMmFemaleMax: sizeMmFemaleMax,
                sizeMmMaleMin: sizeMmMaleMin,
                sizeMmMaleMax: sizeMmMaleMax,
                buildsWeb: buildsWeb,
                webType: webType,
                venomousToHumans: venomousToHumans,
                inaturalistTaxonId: inaturalistTaxonId,
                datazoneId: datazoneId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesRowsTable,
      SpeciesRow,
      $$SpeciesRowsTableFilterComposer,
      $$SpeciesRowsTableOrderingComposer,
      $$SpeciesRowsTableAnnotationComposer,
      $$SpeciesRowsTableCreateCompanionBuilder,
      $$SpeciesRowsTableUpdateCompanionBuilder,
      (
        SpeciesRow,
        BaseReferences<_$AppDatabase, $SpeciesRowsTable, SpeciesRow>,
      ),
      SpeciesRow,
      PrefetchHooks Function()
    >;
typedef $$SightingsTableCreateCompanionBuilder =
    SightingsCompanion Function({
      Value<int> id,
      required String userId,
      required int speciesId,
      Value<int?> visitSiteId,
      Value<DateTime?> observedAt,
      Value<String?> notes,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> photoUrl,
    });
typedef $$SightingsTableUpdateCompanionBuilder =
    SightingsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> speciesId,
      Value<int?> visitSiteId,
      Value<DateTime?> observedAt,
      Value<String?> notes,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> photoUrl,
    });

class $$SightingsTableFilterComposer
    extends Composer<_$AppDatabase, $SightingsTable> {
  $$SightingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SightingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SightingsTable> {
  $$SightingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SightingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SightingsTable> {
  $$SightingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);
}

class $$SightingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SightingsTable,
          Sighting,
          $$SightingsTableFilterComposer,
          $$SightingsTableOrderingComposer,
          $$SightingsTableAnnotationComposer,
          $$SightingsTableCreateCompanionBuilder,
          $$SightingsTableUpdateCompanionBuilder,
          (Sighting, BaseReferences<_$AppDatabase, $SightingsTable, Sighting>),
          Sighting,
          PrefetchHooks Function()
        > {
  $$SightingsTableTableManager(_$AppDatabase db, $SightingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SightingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SightingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SightingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<int?> visitSiteId = const Value.absent(),
                Value<DateTime?> observedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
              }) => SightingsCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
                visitSiteId: visitSiteId,
                observedAt: observedAt,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                photoUrl: photoUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int speciesId,
                Value<int?> visitSiteId = const Value.absent(),
                Value<DateTime?> observedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
              }) => SightingsCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
                visitSiteId: visitSiteId,
                observedAt: observedAt,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                photoUrl: photoUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SightingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SightingsTable,
      Sighting,
      $$SightingsTableFilterComposer,
      $$SightingsTableOrderingComposer,
      $$SightingsTableAnnotationComposer,
      $$SightingsTableCreateCompanionBuilder,
      $$SightingsTableUpdateCompanionBuilder,
      (Sighting, BaseReferences<_$AppDatabase, $SightingsTable, Sighting>),
      Sighting,
      PrefetchHooks Function()
    >;
typedef $$SpeciesImagesTableCreateCompanionBuilder =
    SpeciesImagesCompanion Function({
      Value<int> id,
      required int speciesId,
      required String imageUrl,
      Value<String?> captionEs,
      Value<String?> captionEn,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<String?> thumbnailUrl,
      Value<String?> cardThumbnailUrl,
    });
typedef $$SpeciesImagesTableUpdateCompanionBuilder =
    SpeciesImagesCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<String> imageUrl,
      Value<String?> captionEs,
      Value<String?> captionEn,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<String?> thumbnailUrl,
      Value<String?> cardThumbnailUrl,
    });

class $$SpeciesImagesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesImagesTable> {
  $$SpeciesImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captionEs => $composableBuilder(
    column: $table.captionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captionEn => $composableBuilder(
    column: $table.captionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardThumbnailUrl => $composableBuilder(
    column: $table.cardThumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesImagesTable> {
  $$SpeciesImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captionEs => $composableBuilder(
    column: $table.captionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captionEn => $composableBuilder(
    column: $table.captionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardThumbnailUrl => $composableBuilder(
    column: $table.cardThumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesImagesTable> {
  $$SpeciesImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get captionEs =>
      $composableBuilder(column: $table.captionEs, builder: (column) => column);

  GeneratedColumn<String> get captionEn =>
      $composableBuilder(column: $table.captionEn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardThumbnailUrl => $composableBuilder(
    column: $table.cardThumbnailUrl,
    builder: (column) => column,
  );
}

class $$SpeciesImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesImagesTable,
          SpeciesImage,
          $$SpeciesImagesTableFilterComposer,
          $$SpeciesImagesTableOrderingComposer,
          $$SpeciesImagesTableAnnotationComposer,
          $$SpeciesImagesTableCreateCompanionBuilder,
          $$SpeciesImagesTableUpdateCompanionBuilder,
          (
            SpeciesImage,
            BaseReferences<_$AppDatabase, $SpeciesImagesTable, SpeciesImage>,
          ),
          SpeciesImage,
          PrefetchHooks Function()
        > {
  $$SpeciesImagesTableTableManager(_$AppDatabase db, $SpeciesImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String?> captionEs = const Value.absent(),
                Value<String?> captionEn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> cardThumbnailUrl = const Value.absent(),
              }) => SpeciesImagesCompanion(
                id: id,
                speciesId: speciesId,
                imageUrl: imageUrl,
                captionEs: captionEs,
                captionEn: captionEn,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                thumbnailUrl: thumbnailUrl,
                cardThumbnailUrl: cardThumbnailUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required String imageUrl,
                Value<String?> captionEs = const Value.absent(),
                Value<String?> captionEn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> cardThumbnailUrl = const Value.absent(),
              }) => SpeciesImagesCompanion.insert(
                id: id,
                speciesId: speciesId,
                imageUrl: imageUrl,
                captionEs: captionEs,
                captionEn: captionEn,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                thumbnailUrl: thumbnailUrl,
                cardThumbnailUrl: cardThumbnailUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesImagesTable,
      SpeciesImage,
      $$SpeciesImagesTableFilterComposer,
      $$SpeciesImagesTableOrderingComposer,
      $$SpeciesImagesTableAnnotationComposer,
      $$SpeciesImagesTableCreateCompanionBuilder,
      $$SpeciesImagesTableUpdateCompanionBuilder,
      (
        SpeciesImage,
        BaseReferences<_$AppDatabase, $SpeciesImagesTable, SpeciesImage>,
      ),
      SpeciesImage,
      PrefetchHooks Function()
    >;
typedef $$SpeciesReferencesTableCreateCompanionBuilder =
    SpeciesReferencesCompanion Function({
      Value<int> id,
      required int speciesId,
      required String citation,
      Value<String?> url,
      Value<String?> doi,
      Value<String?> referenceType,
    });
typedef $$SpeciesReferencesTableUpdateCompanionBuilder =
    SpeciesReferencesCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<String> citation,
      Value<String?> url,
      Value<String?> doi,
      Value<String?> referenceType,
    });

class $$SpeciesReferencesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesReferencesTable> {
  $$SpeciesReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesReferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesReferencesTable> {
  $$SpeciesReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesReferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesReferencesTable> {
  $$SpeciesReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get citation =>
      $composableBuilder(column: $table.citation, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );
}

class $$SpeciesReferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesReferencesTable,
          SpeciesReference,
          $$SpeciesReferencesTableFilterComposer,
          $$SpeciesReferencesTableOrderingComposer,
          $$SpeciesReferencesTableAnnotationComposer,
          $$SpeciesReferencesTableCreateCompanionBuilder,
          $$SpeciesReferencesTableUpdateCompanionBuilder,
          (
            SpeciesReference,
            BaseReferences<
              _$AppDatabase,
              $SpeciesReferencesTable,
              SpeciesReference
            >,
          ),
          SpeciesReference,
          PrefetchHooks Function()
        > {
  $$SpeciesReferencesTableTableManager(
    _$AppDatabase db,
    $SpeciesReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> citation = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
              }) => SpeciesReferencesCompanion(
                id: id,
                speciesId: speciesId,
                citation: citation,
                url: url,
                doi: doi,
                referenceType: referenceType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required String citation,
                Value<String?> url = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
              }) => SpeciesReferencesCompanion.insert(
                id: id,
                speciesId: speciesId,
                citation: citation,
                url: url,
                doi: doi,
                referenceType: referenceType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesReferencesTable,
      SpeciesReference,
      $$SpeciesReferencesTableFilterComposer,
      $$SpeciesReferencesTableOrderingComposer,
      $$SpeciesReferencesTableAnnotationComposer,
      $$SpeciesReferencesTableCreateCompanionBuilder,
      $$SpeciesReferencesTableUpdateCompanionBuilder,
      (
        SpeciesReference,
        BaseReferences<
          _$AppDatabase,
          $SpeciesReferencesTable,
          SpeciesReference
        >,
      ),
      SpeciesReference,
      PrefetchHooks Function()
    >;
typedef $$SpeciesSitesTableCreateCompanionBuilder =
    SpeciesSitesCompanion Function({
      Value<int> id,
      required int speciesId,
      required int visitSiteId,
      Value<String?> frequency,
    });
typedef $$SpeciesSitesTableUpdateCompanionBuilder =
    SpeciesSitesCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<int> visitSiteId,
      Value<String?> frequency,
    });

class $$SpeciesSitesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesSitesTable> {
  $$SpeciesSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesSitesTable> {
  $$SpeciesSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesSitesTable> {
  $$SpeciesSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);
}

class $$SpeciesSitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesSitesTable,
          SpeciesSite,
          $$SpeciesSitesTableFilterComposer,
          $$SpeciesSitesTableOrderingComposer,
          $$SpeciesSitesTableAnnotationComposer,
          $$SpeciesSitesTableCreateCompanionBuilder,
          $$SpeciesSitesTableUpdateCompanionBuilder,
          (
            SpeciesSite,
            BaseReferences<_$AppDatabase, $SpeciesSitesTable, SpeciesSite>,
          ),
          SpeciesSite,
          PrefetchHooks Function()
        > {
  $$SpeciesSitesTableTableManager(_$AppDatabase db, $SpeciesSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<int> visitSiteId = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
              }) => SpeciesSitesCompanion(
                id: id,
                speciesId: speciesId,
                visitSiteId: visitSiteId,
                frequency: frequency,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required int visitSiteId,
                Value<String?> frequency = const Value.absent(),
              }) => SpeciesSitesCompanion.insert(
                id: id,
                speciesId: speciesId,
                visitSiteId: visitSiteId,
                frequency: frequency,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesSitesTable,
      SpeciesSite,
      $$SpeciesSitesTableFilterComposer,
      $$SpeciesSitesTableOrderingComposer,
      $$SpeciesSitesTableAnnotationComposer,
      $$SpeciesSitesTableCreateCompanionBuilder,
      $$SpeciesSitesTableUpdateCompanionBuilder,
      (
        SpeciesSite,
        BaseReferences<_$AppDatabase, $SpeciesSitesTable, SpeciesSite>,
      ),
      SpeciesSite,
      PrefetchHooks Function()
    >;
typedef $$SpeciesSoundsTableCreateCompanionBuilder =
    SpeciesSoundsCompanion Function({
      Value<int> id,
      required int speciesId,
      required String soundUrl,
      Value<String?> soundType,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> recordedBy,
      Value<DateTime?> recordedDate,
    });
typedef $$SpeciesSoundsTableUpdateCompanionBuilder =
    SpeciesSoundsCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<String> soundUrl,
      Value<String?> soundType,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> recordedBy,
      Value<DateTime?> recordedDate,
    });

class $$SpeciesSoundsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesSoundsTable> {
  $$SpeciesSoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundUrl => $composableBuilder(
    column: $table.soundUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundType => $composableBuilder(
    column: $table.soundType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedDate => $composableBuilder(
    column: $table.recordedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesSoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesSoundsTable> {
  $$SpeciesSoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundUrl => $composableBuilder(
    column: $table.soundUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundType => $composableBuilder(
    column: $table.soundType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedDate => $composableBuilder(
    column: $table.recordedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesSoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesSoundsTable> {
  $$SpeciesSoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get soundUrl =>
      $composableBuilder(column: $table.soundUrl, builder: (column) => column);

  GeneratedColumn<String> get soundType =>
      $composableBuilder(column: $table.soundType, builder: (column) => column);

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedDate => $composableBuilder(
    column: $table.recordedDate,
    builder: (column) => column,
  );
}

class $$SpeciesSoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesSoundsTable,
          SpeciesSound,
          $$SpeciesSoundsTableFilterComposer,
          $$SpeciesSoundsTableOrderingComposer,
          $$SpeciesSoundsTableAnnotationComposer,
          $$SpeciesSoundsTableCreateCompanionBuilder,
          $$SpeciesSoundsTableUpdateCompanionBuilder,
          (
            SpeciesSound,
            BaseReferences<_$AppDatabase, $SpeciesSoundsTable, SpeciesSound>,
          ),
          SpeciesSound,
          PrefetchHooks Function()
        > {
  $$SpeciesSoundsTableTableManager(_$AppDatabase db, $SpeciesSoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesSoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesSoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesSoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> soundUrl = const Value.absent(),
                Value<String?> soundType = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> recordedBy = const Value.absent(),
                Value<DateTime?> recordedDate = const Value.absent(),
              }) => SpeciesSoundsCompanion(
                id: id,
                speciesId: speciesId,
                soundUrl: soundUrl,
                soundType: soundType,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                recordedBy: recordedBy,
                recordedDate: recordedDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required String soundUrl,
                Value<String?> soundType = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> recordedBy = const Value.absent(),
                Value<DateTime?> recordedDate = const Value.absent(),
              }) => SpeciesSoundsCompanion.insert(
                id: id,
                speciesId: speciesId,
                soundUrl: soundUrl,
                soundType: soundType,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                recordedBy: recordedBy,
                recordedDate: recordedDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesSoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesSoundsTable,
      SpeciesSound,
      $$SpeciesSoundsTableFilterComposer,
      $$SpeciesSoundsTableOrderingComposer,
      $$SpeciesSoundsTableAnnotationComposer,
      $$SpeciesSoundsTableCreateCompanionBuilder,
      $$SpeciesSoundsTableUpdateCompanionBuilder,
      (
        SpeciesSound,
        BaseReferences<_$AppDatabase, $SpeciesSoundsTable, SpeciesSound>,
      ),
      SpeciesSound,
      PrefetchHooks Function()
    >;
typedef $$SpeciesThreatsTableCreateCompanionBuilder =
    SpeciesThreatsCompanion Function({
      Value<int> id,
      required int speciesId,
      required String threatType,
      required String severity,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
    });
typedef $$SpeciesThreatsTableUpdateCompanionBuilder =
    SpeciesThreatsCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<String> threatType,
      Value<String> severity,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
    });

class $$SpeciesThreatsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesThreatsTable> {
  $$SpeciesThreatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threatType => $composableBuilder(
    column: $table.threatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesThreatsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesThreatsTable> {
  $$SpeciesThreatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threatType => $composableBuilder(
    column: $table.threatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesThreatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesThreatsTable> {
  $$SpeciesThreatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get threatType => $composableBuilder(
    column: $table.threatType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );
}

class $$SpeciesThreatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesThreatsTable,
          SpeciesThreat,
          $$SpeciesThreatsTableFilterComposer,
          $$SpeciesThreatsTableOrderingComposer,
          $$SpeciesThreatsTableAnnotationComposer,
          $$SpeciesThreatsTableCreateCompanionBuilder,
          $$SpeciesThreatsTableUpdateCompanionBuilder,
          (
            SpeciesThreat,
            BaseReferences<_$AppDatabase, $SpeciesThreatsTable, SpeciesThreat>,
          ),
          SpeciesThreat,
          PrefetchHooks Function()
        > {
  $$SpeciesThreatsTableTableManager(
    _$AppDatabase db,
    $SpeciesThreatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesThreatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesThreatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesThreatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> threatType = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
              }) => SpeciesThreatsCompanion(
                id: id,
                speciesId: speciesId,
                threatType: threatType,
                severity: severity,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required String threatType,
                required String severity,
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
              }) => SpeciesThreatsCompanion.insert(
                id: id,
                speciesId: speciesId,
                threatType: threatType,
                severity: severity,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesThreatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesThreatsTable,
      SpeciesThreat,
      $$SpeciesThreatsTableFilterComposer,
      $$SpeciesThreatsTableOrderingComposer,
      $$SpeciesThreatsTableAnnotationComposer,
      $$SpeciesThreatsTableCreateCompanionBuilder,
      $$SpeciesThreatsTableUpdateCompanionBuilder,
      (
        SpeciesThreat,
        BaseReferences<_$AppDatabase, $SpeciesThreatsTable, SpeciesThreat>,
      ),
      SpeciesThreat,
      PrefetchHooks Function()
    >;
typedef $$TrailsTableCreateCompanionBuilder =
    TrailsCompanion Function({
      Value<int> id,
      required String nameEn,
      required String nameEs,
      Value<String?> descriptionEn,
      Value<String?> descriptionEs,
      Value<int?> islandId,
      Value<int?> visitSiteId,
      Value<String?> difficulty,
      Value<double?> distanceKm,
      Value<int?> estimatedMinutes,
      Value<String> coordinates,
      Value<double?> elevationGainM,
      Value<String?> userId,
    });
typedef $$TrailsTableUpdateCompanionBuilder =
    TrailsCompanion Function({
      Value<int> id,
      Value<String> nameEn,
      Value<String> nameEs,
      Value<String?> descriptionEn,
      Value<String?> descriptionEs,
      Value<int?> islandId,
      Value<int?> visitSiteId,
      Value<String?> difficulty,
      Value<double?> distanceKm,
      Value<int?> estimatedMinutes,
      Value<String> coordinates,
      Value<double?> elevationGainM,
      Value<String?> userId,
    });

class $$TrailsTableFilterComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get islandId => $composableBuilder(
    column: $table.islandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coordinates => $composableBuilder(
    column: $table.coordinates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrailsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get islandId => $composableBuilder(
    column: $table.islandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coordinates => $composableBuilder(
    column: $table.coordinates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get islandId =>
      $composableBuilder(column: $table.islandId, builder: (column) => column);

  GeneratedColumn<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coordinates => $composableBuilder(
    column: $table.coordinates,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$TrailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrailsTable,
          Trail,
          $$TrailsTableFilterComposer,
          $$TrailsTableOrderingComposer,
          $$TrailsTableAnnotationComposer,
          $$TrailsTableCreateCompanionBuilder,
          $$TrailsTableUpdateCompanionBuilder,
          (Trail, BaseReferences<_$AppDatabase, $TrailsTable, Trail>),
          Trail,
          PrefetchHooks Function()
        > {
  $$TrailsTableTableManager(_$AppDatabase db, $TrailsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<int?> islandId = const Value.absent(),
                Value<int?> visitSiteId = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> coordinates = const Value.absent(),
                Value<double?> elevationGainM = const Value.absent(),
                Value<String?> userId = const Value.absent(),
              }) => TrailsCompanion(
                id: id,
                nameEn: nameEn,
                nameEs: nameEs,
                descriptionEn: descriptionEn,
                descriptionEs: descriptionEs,
                islandId: islandId,
                visitSiteId: visitSiteId,
                difficulty: difficulty,
                distanceKm: distanceKm,
                estimatedMinutes: estimatedMinutes,
                coordinates: coordinates,
                elevationGainM: elevationGainM,
                userId: userId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameEn,
                required String nameEs,
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<int?> islandId = const Value.absent(),
                Value<int?> visitSiteId = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> coordinates = const Value.absent(),
                Value<double?> elevationGainM = const Value.absent(),
                Value<String?> userId = const Value.absent(),
              }) => TrailsCompanion.insert(
                id: id,
                nameEn: nameEn,
                nameEs: nameEs,
                descriptionEn: descriptionEn,
                descriptionEs: descriptionEs,
                islandId: islandId,
                visitSiteId: visitSiteId,
                difficulty: difficulty,
                distanceKm: distanceKm,
                estimatedMinutes: estimatedMinutes,
                coordinates: coordinates,
                elevationGainM: elevationGainM,
                userId: userId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrailsTable,
      Trail,
      $$TrailsTableFilterComposer,
      $$TrailsTableOrderingComposer,
      $$TrailsTableAnnotationComposer,
      $$TrailsTableCreateCompanionBuilder,
      $$TrailsTableUpdateCompanionBuilder,
      (Trail, BaseReferences<_$AppDatabase, $TrailsTable, Trail>),
      Trail,
      PrefetchHooks Function()
    >;
typedef $$UserFavoritesTableCreateCompanionBuilder =
    UserFavoritesCompanion Function({
      Value<int> id,
      required String userId,
      required int speciesId,
    });
typedef $$UserFavoritesTableUpdateCompanionBuilder =
    UserFavoritesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> speciesId,
    });

class $$UserFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $UserFavoritesTable> {
  $$UserFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserFavoritesTable> {
  $$UserFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserFavoritesTable> {
  $$UserFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);
}

class $$UserFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserFavoritesTable,
          UserFavorite,
          $$UserFavoritesTableFilterComposer,
          $$UserFavoritesTableOrderingComposer,
          $$UserFavoritesTableAnnotationComposer,
          $$UserFavoritesTableCreateCompanionBuilder,
          $$UserFavoritesTableUpdateCompanionBuilder,
          (
            UserFavorite,
            BaseReferences<_$AppDatabase, $UserFavoritesTable, UserFavorite>,
          ),
          UserFavorite,
          PrefetchHooks Function()
        > {
  $$UserFavoritesTableTableManager(_$AppDatabase db, $UserFavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
              }) => UserFavoritesCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int speciesId,
              }) => UserFavoritesCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserFavoritesTable,
      UserFavorite,
      $$UserFavoritesTableFilterComposer,
      $$UserFavoritesTableOrderingComposer,
      $$UserFavoritesTableAnnotationComposer,
      $$UserFavoritesTableCreateCompanionBuilder,
      $$UserFavoritesTableUpdateCompanionBuilder,
      (
        UserFavorite,
        BaseReferences<_$AppDatabase, $UserFavoritesTable, UserFavorite>,
      ),
      UserFavorite,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      Value<String?> displayName,
      Value<String?> bio,
      Value<DateTime?> birthDate,
      Value<String?> country,
      Value<String?> countryCode,
      Value<String?> avatarUrl,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> userType,
      Value<String?> affiliation,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String?> displayName,
      Value<String?> bio,
      Value<DateTime?> birthDate,
      Value<String?> country,
      Value<String?> countryCode,
      Value<String?> avatarUrl,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> userType,
      Value<String?> affiliation,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userType => $composableBuilder(
    column: $table.userType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get affiliation => $composableBuilder(
    column: $table.affiliation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userType => $composableBuilder(
    column: $table.userType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get affiliation => $composableBuilder(
    column: $table.affiliation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get userType =>
      $composableBuilder(column: $table.userType, builder: (column) => column);

  GeneratedColumn<String> get affiliation => $composableBuilder(
    column: $table.affiliation,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> userType = const Value.absent(),
                Value<String?> affiliation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                bio: bio,
                birthDate: birthDate,
                country: country,
                countryCode: countryCode,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                userType: userType,
                affiliation: affiliation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> displayName = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> userType = const Value.absent(),
                Value<String?> affiliation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                bio: bio,
                birthDate: birthDate,
                country: country,
                countryCode: countryCode,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                userType: userType,
                affiliation: affiliation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$UserSiteWishlistsTableCreateCompanionBuilder =
    UserSiteWishlistsCompanion Function({
      Value<int> id,
      required String userId,
      required int visitSiteId,
      Value<DateTime?> createdAt,
    });
typedef $$UserSiteWishlistsTableUpdateCompanionBuilder =
    UserSiteWishlistsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> visitSiteId,
      Value<DateTime?> createdAt,
    });

class $$UserSiteWishlistsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSiteWishlistsTable> {
  $$UserSiteWishlistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSiteWishlistsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSiteWishlistsTable> {
  $$UserSiteWishlistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSiteWishlistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSiteWishlistsTable> {
  $$UserSiteWishlistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get visitSiteId => $composableBuilder(
    column: $table.visitSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserSiteWishlistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSiteWishlistsTable,
          UserSiteWishlist,
          $$UserSiteWishlistsTableFilterComposer,
          $$UserSiteWishlistsTableOrderingComposer,
          $$UserSiteWishlistsTableAnnotationComposer,
          $$UserSiteWishlistsTableCreateCompanionBuilder,
          $$UserSiteWishlistsTableUpdateCompanionBuilder,
          (
            UserSiteWishlist,
            BaseReferences<
              _$AppDatabase,
              $UserSiteWishlistsTable,
              UserSiteWishlist
            >,
          ),
          UserSiteWishlist,
          PrefetchHooks Function()
        > {
  $$UserSiteWishlistsTableTableManager(
    _$AppDatabase db,
    $UserSiteWishlistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSiteWishlistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSiteWishlistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSiteWishlistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> visitSiteId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => UserSiteWishlistsCompanion(
                id: id,
                userId: userId,
                visitSiteId: visitSiteId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int visitSiteId,
                Value<DateTime?> createdAt = const Value.absent(),
              }) => UserSiteWishlistsCompanion.insert(
                id: id,
                userId: userId,
                visitSiteId: visitSiteId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSiteWishlistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSiteWishlistsTable,
      UserSiteWishlist,
      $$UserSiteWishlistsTableFilterComposer,
      $$UserSiteWishlistsTableOrderingComposer,
      $$UserSiteWishlistsTableAnnotationComposer,
      $$UserSiteWishlistsTableCreateCompanionBuilder,
      $$UserSiteWishlistsTableUpdateCompanionBuilder,
      (
        UserSiteWishlist,
        BaseReferences<
          _$AppDatabase,
          $UserSiteWishlistsTable,
          UserSiteWishlist
        >,
      ),
      UserSiteWishlist,
      PrefetchHooks Function()
    >;
typedef $$UserSpeciesChecklistsTableCreateCompanionBuilder =
    UserSpeciesChecklistsCompanion Function({
      Value<int> id,
      required String userId,
      required int speciesId,
      Value<DateTime?> seenAt,
    });
typedef $$UserSpeciesChecklistsTableUpdateCompanionBuilder =
    UserSpeciesChecklistsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> speciesId,
      Value<DateTime?> seenAt,
    });

class $$UserSpeciesChecklistsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSpeciesChecklistsTable> {
  $$UserSpeciesChecklistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSpeciesChecklistsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSpeciesChecklistsTable> {
  $$UserSpeciesChecklistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSpeciesChecklistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSpeciesChecklistsTable> {
  $$UserSpeciesChecklistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);
}

class $$UserSpeciesChecklistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSpeciesChecklistsTable,
          UserSpeciesChecklist,
          $$UserSpeciesChecklistsTableFilterComposer,
          $$UserSpeciesChecklistsTableOrderingComposer,
          $$UserSpeciesChecklistsTableAnnotationComposer,
          $$UserSpeciesChecklistsTableCreateCompanionBuilder,
          $$UserSpeciesChecklistsTableUpdateCompanionBuilder,
          (
            UserSpeciesChecklist,
            BaseReferences<
              _$AppDatabase,
              $UserSpeciesChecklistsTable,
              UserSpeciesChecklist
            >,
          ),
          UserSpeciesChecklist,
          PrefetchHooks Function()
        > {
  $$UserSpeciesChecklistsTableTableManager(
    _$AppDatabase db,
    $UserSpeciesChecklistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSpeciesChecklistsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserSpeciesChecklistsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserSpeciesChecklistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<DateTime?> seenAt = const Value.absent(),
              }) => UserSpeciesChecklistsCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
                seenAt: seenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int speciesId,
                Value<DateTime?> seenAt = const Value.absent(),
              }) => UserSpeciesChecklistsCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
                seenAt: seenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSpeciesChecklistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSpeciesChecklistsTable,
      UserSpeciesChecklist,
      $$UserSpeciesChecklistsTableFilterComposer,
      $$UserSpeciesChecklistsTableOrderingComposer,
      $$UserSpeciesChecklistsTableAnnotationComposer,
      $$UserSpeciesChecklistsTableCreateCompanionBuilder,
      $$UserSpeciesChecklistsTableUpdateCompanionBuilder,
      (
        UserSpeciesChecklist,
        BaseReferences<
          _$AppDatabase,
          $UserSpeciesChecklistsTable,
          UserSpeciesChecklist
        >,
      ),
      UserSpeciesChecklist,
      PrefetchHooks Function()
    >;
typedef $$VisitSitesTableCreateCompanionBuilder =
    VisitSitesCompanion Function({
      Value<int> id,
      Value<int?> islandId,
      required String nameEs,
      Value<String?> nameEn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> monitoringType,
      Value<String?> difficulty,
      Value<String?> conservationZone,
      Value<String?> publicUseZone,
      Value<int?> capacity,
      Value<String?> status,
      Value<String?> attractionEs,
      Value<String?> abbreviation,
      Value<String?> parkId,
    });
typedef $$VisitSitesTableUpdateCompanionBuilder =
    VisitSitesCompanion Function({
      Value<int> id,
      Value<int?> islandId,
      Value<String> nameEs,
      Value<String?> nameEn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> descriptionEs,
      Value<String?> descriptionEn,
      Value<String?> monitoringType,
      Value<String?> difficulty,
      Value<String?> conservationZone,
      Value<String?> publicUseZone,
      Value<int?> capacity,
      Value<String?> status,
      Value<String?> attractionEs,
      Value<String?> abbreviation,
      Value<String?> parkId,
    });

class $$VisitSitesTableFilterComposer
    extends Composer<_$AppDatabase, $VisitSitesTable> {
  $$VisitSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get islandId => $composableBuilder(
    column: $table.islandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monitoringType => $composableBuilder(
    column: $table.monitoringType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conservationZone => $composableBuilder(
    column: $table.conservationZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicUseZone => $composableBuilder(
    column: $table.publicUseZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attractionEs => $composableBuilder(
    column: $table.attractionEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parkId => $composableBuilder(
    column: $table.parkId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitSitesTable> {
  $$VisitSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get islandId => $composableBuilder(
    column: $table.islandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monitoringType => $composableBuilder(
    column: $table.monitoringType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conservationZone => $composableBuilder(
    column: $table.conservationZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicUseZone => $composableBuilder(
    column: $table.publicUseZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attractionEs => $composableBuilder(
    column: $table.attractionEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parkId => $composableBuilder(
    column: $table.parkId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitSitesTable> {
  $$VisitSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get islandId =>
      $composableBuilder(column: $table.islandId, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get descriptionEs => $composableBuilder(
    column: $table.descriptionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monitoringType => $composableBuilder(
    column: $table.monitoringType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conservationZone => $composableBuilder(
    column: $table.conservationZone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicUseZone => $composableBuilder(
    column: $table.publicUseZone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get attractionEs => $composableBuilder(
    column: $table.attractionEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parkId =>
      $composableBuilder(column: $table.parkId, builder: (column) => column);
}

class $$VisitSitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitSitesTable,
          VisitSite,
          $$VisitSitesTableFilterComposer,
          $$VisitSitesTableOrderingComposer,
          $$VisitSitesTableAnnotationComposer,
          $$VisitSitesTableCreateCompanionBuilder,
          $$VisitSitesTableUpdateCompanionBuilder,
          (
            VisitSite,
            BaseReferences<_$AppDatabase, $VisitSitesTable, VisitSite>,
          ),
          VisitSite,
          PrefetchHooks Function()
        > {
  $$VisitSitesTableTableManager(_$AppDatabase db, $VisitSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> islandId = const Value.absent(),
                Value<String> nameEs = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> monitoringType = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String?> conservationZone = const Value.absent(),
                Value<String?> publicUseZone = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> attractionEs = const Value.absent(),
                Value<String?> abbreviation = const Value.absent(),
                Value<String?> parkId = const Value.absent(),
              }) => VisitSitesCompanion(
                id: id,
                islandId: islandId,
                nameEs: nameEs,
                nameEn: nameEn,
                latitude: latitude,
                longitude: longitude,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                monitoringType: monitoringType,
                difficulty: difficulty,
                conservationZone: conservationZone,
                publicUseZone: publicUseZone,
                capacity: capacity,
                status: status,
                attractionEs: attractionEs,
                abbreviation: abbreviation,
                parkId: parkId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> islandId = const Value.absent(),
                required String nameEs,
                Value<String?> nameEn = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> descriptionEs = const Value.absent(),
                Value<String?> descriptionEn = const Value.absent(),
                Value<String?> monitoringType = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String?> conservationZone = const Value.absent(),
                Value<String?> publicUseZone = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> attractionEs = const Value.absent(),
                Value<String?> abbreviation = const Value.absent(),
                Value<String?> parkId = const Value.absent(),
              }) => VisitSitesCompanion.insert(
                id: id,
                islandId: islandId,
                nameEs: nameEs,
                nameEn: nameEn,
                latitude: latitude,
                longitude: longitude,
                descriptionEs: descriptionEs,
                descriptionEn: descriptionEn,
                monitoringType: monitoringType,
                difficulty: difficulty,
                conservationZone: conservationZone,
                publicUseZone: publicUseZone,
                capacity: capacity,
                status: status,
                attractionEs: attractionEs,
                abbreviation: abbreviation,
                parkId: parkId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitSitesTable,
      VisitSite,
      $$VisitSitesTableFilterComposer,
      $$VisitSitesTableOrderingComposer,
      $$VisitSitesTableAnnotationComposer,
      $$VisitSitesTableCreateCompanionBuilder,
      $$VisitSitesTableUpdateCompanionBuilder,
      (VisitSite, BaseReferences<_$AppDatabase, $VisitSitesTable, VisitSite>),
      VisitSite,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$IslandsTableTableManager get islands =>
      $$IslandsTableTableManager(_db, _db.islands);
  $$SpeciesRowsTableTableManager get speciesRows =>
      $$SpeciesRowsTableTableManager(_db, _db.speciesRows);
  $$SightingsTableTableManager get sightings =>
      $$SightingsTableTableManager(_db, _db.sightings);
  $$SpeciesImagesTableTableManager get speciesImages =>
      $$SpeciesImagesTableTableManager(_db, _db.speciesImages);
  $$SpeciesReferencesTableTableManager get speciesReferences =>
      $$SpeciesReferencesTableTableManager(_db, _db.speciesReferences);
  $$SpeciesSitesTableTableManager get speciesSites =>
      $$SpeciesSitesTableTableManager(_db, _db.speciesSites);
  $$SpeciesSoundsTableTableManager get speciesSounds =>
      $$SpeciesSoundsTableTableManager(_db, _db.speciesSounds);
  $$SpeciesThreatsTableTableManager get speciesThreats =>
      $$SpeciesThreatsTableTableManager(_db, _db.speciesThreats);
  $$TrailsTableTableManager get trails =>
      $$TrailsTableTableManager(_db, _db.trails);
  $$UserFavoritesTableTableManager get userFavorites =>
      $$UserFavoritesTableTableManager(_db, _db.userFavorites);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$UserSiteWishlistsTableTableManager get userSiteWishlists =>
      $$UserSiteWishlistsTableTableManager(_db, _db.userSiteWishlists);
  $$UserSpeciesChecklistsTableTableManager get userSpeciesChecklists =>
      $$UserSpeciesChecklistsTableTableManager(_db, _db.userSpeciesChecklists);
  $$VisitSitesTableTableManager get visitSites =>
      $$VisitSitesTableTableManager(_db, _db.visitSites);
}
