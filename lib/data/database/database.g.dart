// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _experienceMeta = const VerificationMeta(
    'experience',
  );
  @override
  late final GeneratedColumn<int> experience = GeneratedColumn<int>(
    'experience',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _strMeta = const VerificationMeta('str');
  @override
  late final GeneratedColumn<int> str = GeneratedColumn<int>(
    'str',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intellectMeta = const VerificationMeta(
    'intellect',
  );
  @override
  late final GeneratedColumn<int> intellect = GeneratedColumn<int>(
    'intellect',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _luckMeta = const VerificationMeta('luck');
  @override
  late final GeneratedColumn<int> luck = GeneratedColumn<int>(
    'luck',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chaMeta = const VerificationMeta('cha');
  @override
  late final GeneratedColumn<int> cha = GeneratedColumn<int>(
    'cha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitMeta = const VerificationMeta('vit');
  @override
  late final GeneratedColumn<int> vit = GeneratedColumn<int>(
    'vit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _willGemsMeta = const VerificationMeta(
    'willGems',
  );
  @override
  late final GeneratedColumn<int> willGems = GeneratedColumn<int>(
    'will_gems',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _currentDebuffMeta = const VerificationMeta(
    'currentDebuff',
  );
  @override
  late final GeneratedColumn<String> currentDebuff = GeneratedColumn<String>(
    'current_debuff',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debuffExpiresAtMeta = const VerificationMeta(
    'debuffExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> debuffExpiresAt =
      GeneratedColumn<DateTime>(
        'debuff_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SkillType?, int> activeSkillType =
      GeneratedColumn<int>(
        'active_skill_type',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<SkillType?>($PlayersTable.$converteractiveSkillTypen);
  static const VerificationMeta _activeSkillValueMeta = const VerificationMeta(
    'activeSkillValue',
  );
  @override
  late final GeneratedColumn<int> activeSkillValue = GeneratedColumn<int>(
    'active_skill_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skillExpiresAtMeta = const VerificationMeta(
    'skillExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> skillExpiresAt =
      GeneratedColumn<DateTime>(
        'skill_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    experience,
    str,
    intellect,
    luck,
    cha,
    vit,
    willGems,
    currentDebuff,
    debuffExpiresAt,
    lastLoginAt,
    activeSkillType,
    activeSkillValue,
    skillExpiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('experience')) {
      context.handle(
        _experienceMeta,
        experience.isAcceptableOrUnknown(data['experience']!, _experienceMeta),
      );
    }
    if (data.containsKey('str')) {
      context.handle(
        _strMeta,
        str.isAcceptableOrUnknown(data['str']!, _strMeta),
      );
    }
    if (data.containsKey('intellect')) {
      context.handle(
        _intellectMeta,
        intellect.isAcceptableOrUnknown(data['intellect']!, _intellectMeta),
      );
    }
    if (data.containsKey('luck')) {
      context.handle(
        _luckMeta,
        luck.isAcceptableOrUnknown(data['luck']!, _luckMeta),
      );
    }
    if (data.containsKey('cha')) {
      context.handle(
        _chaMeta,
        cha.isAcceptableOrUnknown(data['cha']!, _chaMeta),
      );
    }
    if (data.containsKey('vit')) {
      context.handle(
        _vitMeta,
        vit.isAcceptableOrUnknown(data['vit']!, _vitMeta),
      );
    }
    if (data.containsKey('will_gems')) {
      context.handle(
        _willGemsMeta,
        willGems.isAcceptableOrUnknown(data['will_gems']!, _willGemsMeta),
      );
    }
    if (data.containsKey('current_debuff')) {
      context.handle(
        _currentDebuffMeta,
        currentDebuff.isAcceptableOrUnknown(
          data['current_debuff']!,
          _currentDebuffMeta,
        ),
      );
    }
    if (data.containsKey('debuff_expires_at')) {
      context.handle(
        _debuffExpiresAtMeta,
        debuffExpiresAt.isAcceptableOrUnknown(
          data['debuff_expires_at']!,
          _debuffExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('active_skill_value')) {
      context.handle(
        _activeSkillValueMeta,
        activeSkillValue.isAcceptableOrUnknown(
          data['active_skill_value']!,
          _activeSkillValueMeta,
        ),
      );
    }
    if (data.containsKey('skill_expires_at')) {
      context.handle(
        _skillExpiresAtMeta,
        skillExpiresAt.isAcceptableOrUnknown(
          data['skill_expires_at']!,
          _skillExpiresAtMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      experience: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience'],
      )!,
      str: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}str'],
      )!,
      intellect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intellect'],
      )!,
      luck: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}luck'],
      )!,
      cha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cha'],
      )!,
      vit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vit'],
      )!,
      willGems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}will_gems'],
      )!,
      currentDebuff: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_debuff'],
      ),
      debuffExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}debuff_expires_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      )!,
      activeSkillType: $PlayersTable.$converteractiveSkillTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}active_skill_type'],
        ),
      ),
      activeSkillValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_skill_value'],
      ),
      skillExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}skill_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SkillType, int, int> $converteractiveSkillType =
      const EnumIndexConverter<SkillType>(SkillType.values);
  static JsonTypeConverter2<SkillType?, int?, int?> $converteractiveSkillTypen =
      JsonTypeConverter2.asNullable($converteractiveSkillType);
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final int level;
  final int experience;
  final int str;
  final int intellect;
  final int luck;
  final int cha;
  final int vit;
  final int willGems;
  final String? currentDebuff;
  final DateTime? debuffExpiresAt;
  final DateTime lastLoginAt;
  final SkillType? activeSkillType;
  final int? activeSkillValue;
  final DateTime? skillExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Player({
    required this.id,
    required this.level,
    required this.experience,
    required this.str,
    required this.intellect,
    required this.luck,
    required this.cha,
    required this.vit,
    required this.willGems,
    this.currentDebuff,
    this.debuffExpiresAt,
    required this.lastLoginAt,
    this.activeSkillType,
    this.activeSkillValue,
    this.skillExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<int>(level);
    map['experience'] = Variable<int>(experience);
    map['str'] = Variable<int>(str);
    map['intellect'] = Variable<int>(intellect);
    map['luck'] = Variable<int>(luck);
    map['cha'] = Variable<int>(cha);
    map['vit'] = Variable<int>(vit);
    map['will_gems'] = Variable<int>(willGems);
    if (!nullToAbsent || currentDebuff != null) {
      map['current_debuff'] = Variable<String>(currentDebuff);
    }
    if (!nullToAbsent || debuffExpiresAt != null) {
      map['debuff_expires_at'] = Variable<DateTime>(debuffExpiresAt);
    }
    map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    if (!nullToAbsent || activeSkillType != null) {
      map['active_skill_type'] = Variable<int>(
        $PlayersTable.$converteractiveSkillTypen.toSql(activeSkillType),
      );
    }
    if (!nullToAbsent || activeSkillValue != null) {
      map['active_skill_value'] = Variable<int>(activeSkillValue);
    }
    if (!nullToAbsent || skillExpiresAt != null) {
      map['skill_expires_at'] = Variable<DateTime>(skillExpiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      level: Value(level),
      experience: Value(experience),
      str: Value(str),
      intellect: Value(intellect),
      luck: Value(luck),
      cha: Value(cha),
      vit: Value(vit),
      willGems: Value(willGems),
      currentDebuff: currentDebuff == null && nullToAbsent
          ? const Value.absent()
          : Value(currentDebuff),
      debuffExpiresAt: debuffExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(debuffExpiresAt),
      lastLoginAt: Value(lastLoginAt),
      activeSkillType: activeSkillType == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSkillType),
      activeSkillValue: activeSkillValue == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSkillValue),
      skillExpiresAt: skillExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(skillExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<int>(json['level']),
      experience: serializer.fromJson<int>(json['experience']),
      str: serializer.fromJson<int>(json['str']),
      intellect: serializer.fromJson<int>(json['intellect']),
      luck: serializer.fromJson<int>(json['luck']),
      cha: serializer.fromJson<int>(json['cha']),
      vit: serializer.fromJson<int>(json['vit']),
      willGems: serializer.fromJson<int>(json['willGems']),
      currentDebuff: serializer.fromJson<String?>(json['currentDebuff']),
      debuffExpiresAt: serializer.fromJson<DateTime?>(json['debuffExpiresAt']),
      lastLoginAt: serializer.fromJson<DateTime>(json['lastLoginAt']),
      activeSkillType: $PlayersTable.$converteractiveSkillTypen.fromJson(
        serializer.fromJson<int?>(json['activeSkillType']),
      ),
      activeSkillValue: serializer.fromJson<int?>(json['activeSkillValue']),
      skillExpiresAt: serializer.fromJson<DateTime?>(json['skillExpiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<int>(level),
      'experience': serializer.toJson<int>(experience),
      'str': serializer.toJson<int>(str),
      'intellect': serializer.toJson<int>(intellect),
      'luck': serializer.toJson<int>(luck),
      'cha': serializer.toJson<int>(cha),
      'vit': serializer.toJson<int>(vit),
      'willGems': serializer.toJson<int>(willGems),
      'currentDebuff': serializer.toJson<String?>(currentDebuff),
      'debuffExpiresAt': serializer.toJson<DateTime?>(debuffExpiresAt),
      'lastLoginAt': serializer.toJson<DateTime>(lastLoginAt),
      'activeSkillType': serializer.toJson<int?>(
        $PlayersTable.$converteractiveSkillTypen.toJson(activeSkillType),
      ),
      'activeSkillValue': serializer.toJson<int?>(activeSkillValue),
      'skillExpiresAt': serializer.toJson<DateTime?>(skillExpiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Player copyWith({
    int? id,
    int? level,
    int? experience,
    int? str,
    int? intellect,
    int? luck,
    int? cha,
    int? vit,
    int? willGems,
    Value<String?> currentDebuff = const Value.absent(),
    Value<DateTime?> debuffExpiresAt = const Value.absent(),
    DateTime? lastLoginAt,
    Value<SkillType?> activeSkillType = const Value.absent(),
    Value<int?> activeSkillValue = const Value.absent(),
    Value<DateTime?> skillExpiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Player(
    id: id ?? this.id,
    level: level ?? this.level,
    experience: experience ?? this.experience,
    str: str ?? this.str,
    intellect: intellect ?? this.intellect,
    luck: luck ?? this.luck,
    cha: cha ?? this.cha,
    vit: vit ?? this.vit,
    willGems: willGems ?? this.willGems,
    currentDebuff: currentDebuff.present
        ? currentDebuff.value
        : this.currentDebuff,
    debuffExpiresAt: debuffExpiresAt.present
        ? debuffExpiresAt.value
        : this.debuffExpiresAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    activeSkillType: activeSkillType.present
        ? activeSkillType.value
        : this.activeSkillType,
    activeSkillValue: activeSkillValue.present
        ? activeSkillValue.value
        : this.activeSkillValue,
    skillExpiresAt: skillExpiresAt.present
        ? skillExpiresAt.value
        : this.skillExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      experience: data.experience.present
          ? data.experience.value
          : this.experience,
      str: data.str.present ? data.str.value : this.str,
      intellect: data.intellect.present ? data.intellect.value : this.intellect,
      luck: data.luck.present ? data.luck.value : this.luck,
      cha: data.cha.present ? data.cha.value : this.cha,
      vit: data.vit.present ? data.vit.value : this.vit,
      willGems: data.willGems.present ? data.willGems.value : this.willGems,
      currentDebuff: data.currentDebuff.present
          ? data.currentDebuff.value
          : this.currentDebuff,
      debuffExpiresAt: data.debuffExpiresAt.present
          ? data.debuffExpiresAt.value
          : this.debuffExpiresAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      activeSkillType: data.activeSkillType.present
          ? data.activeSkillType.value
          : this.activeSkillType,
      activeSkillValue: data.activeSkillValue.present
          ? data.activeSkillValue.value
          : this.activeSkillValue,
      skillExpiresAt: data.skillExpiresAt.present
          ? data.skillExpiresAt.value
          : this.skillExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('experience: $experience, ')
          ..write('str: $str, ')
          ..write('intellect: $intellect, ')
          ..write('luck: $luck, ')
          ..write('cha: $cha, ')
          ..write('vit: $vit, ')
          ..write('willGems: $willGems, ')
          ..write('currentDebuff: $currentDebuff, ')
          ..write('debuffExpiresAt: $debuffExpiresAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('activeSkillType: $activeSkillType, ')
          ..write('activeSkillValue: $activeSkillValue, ')
          ..write('skillExpiresAt: $skillExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    experience,
    str,
    intellect,
    luck,
    cha,
    vit,
    willGems,
    currentDebuff,
    debuffExpiresAt,
    lastLoginAt,
    activeSkillType,
    activeSkillValue,
    skillExpiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.level == this.level &&
          other.experience == this.experience &&
          other.str == this.str &&
          other.intellect == this.intellect &&
          other.luck == this.luck &&
          other.cha == this.cha &&
          other.vit == this.vit &&
          other.willGems == this.willGems &&
          other.currentDebuff == this.currentDebuff &&
          other.debuffExpiresAt == this.debuffExpiresAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.activeSkillType == this.activeSkillType &&
          other.activeSkillValue == this.activeSkillValue &&
          other.skillExpiresAt == this.skillExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<int> level;
  final Value<int> experience;
  final Value<int> str;
  final Value<int> intellect;
  final Value<int> luck;
  final Value<int> cha;
  final Value<int> vit;
  final Value<int> willGems;
  final Value<String?> currentDebuff;
  final Value<DateTime?> debuffExpiresAt;
  final Value<DateTime> lastLoginAt;
  final Value<SkillType?> activeSkillType;
  final Value<int?> activeSkillValue;
  final Value<DateTime?> skillExpiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.experience = const Value.absent(),
    this.str = const Value.absent(),
    this.intellect = const Value.absent(),
    this.luck = const Value.absent(),
    this.cha = const Value.absent(),
    this.vit = const Value.absent(),
    this.willGems = const Value.absent(),
    this.currentDebuff = const Value.absent(),
    this.debuffExpiresAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.activeSkillType = const Value.absent(),
    this.activeSkillValue = const Value.absent(),
    this.skillExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.experience = const Value.absent(),
    this.str = const Value.absent(),
    this.intellect = const Value.absent(),
    this.luck = const Value.absent(),
    this.cha = const Value.absent(),
    this.vit = const Value.absent(),
    this.willGems = const Value.absent(),
    this.currentDebuff = const Value.absent(),
    this.debuffExpiresAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.activeSkillType = const Value.absent(),
    this.activeSkillValue = const Value.absent(),
    this.skillExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<int>? level,
    Expression<int>? experience,
    Expression<int>? str,
    Expression<int>? intellect,
    Expression<int>? luck,
    Expression<int>? cha,
    Expression<int>? vit,
    Expression<int>? willGems,
    Expression<String>? currentDebuff,
    Expression<DateTime>? debuffExpiresAt,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? activeSkillType,
    Expression<int>? activeSkillValue,
    Expression<DateTime>? skillExpiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (experience != null) 'experience': experience,
      if (str != null) 'str': str,
      if (intellect != null) 'intellect': intellect,
      if (luck != null) 'luck': luck,
      if (cha != null) 'cha': cha,
      if (vit != null) 'vit': vit,
      if (willGems != null) 'will_gems': willGems,
      if (currentDebuff != null) 'current_debuff': currentDebuff,
      if (debuffExpiresAt != null) 'debuff_expires_at': debuffExpiresAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (activeSkillType != null) 'active_skill_type': activeSkillType,
      if (activeSkillValue != null) 'active_skill_value': activeSkillValue,
      if (skillExpiresAt != null) 'skill_expires_at': skillExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<int>? level,
    Value<int>? experience,
    Value<int>? str,
    Value<int>? intellect,
    Value<int>? luck,
    Value<int>? cha,
    Value<int>? vit,
    Value<int>? willGems,
    Value<String?>? currentDebuff,
    Value<DateTime?>? debuffExpiresAt,
    Value<DateTime>? lastLoginAt,
    Value<SkillType?>? activeSkillType,
    Value<int?>? activeSkillValue,
    Value<DateTime?>? skillExpiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      str: str ?? this.str,
      intellect: intellect ?? this.intellect,
      luck: luck ?? this.luck,
      cha: cha ?? this.cha,
      vit: vit ?? this.vit,
      willGems: willGems ?? this.willGems,
      currentDebuff: currentDebuff ?? this.currentDebuff,
      debuffExpiresAt: debuffExpiresAt ?? this.debuffExpiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      activeSkillType: activeSkillType ?? this.activeSkillType,
      activeSkillValue: activeSkillValue ?? this.activeSkillValue,
      skillExpiresAt: skillExpiresAt ?? this.skillExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (experience.present) {
      map['experience'] = Variable<int>(experience.value);
    }
    if (str.present) {
      map['str'] = Variable<int>(str.value);
    }
    if (intellect.present) {
      map['intellect'] = Variable<int>(intellect.value);
    }
    if (luck.present) {
      map['luck'] = Variable<int>(luck.value);
    }
    if (cha.present) {
      map['cha'] = Variable<int>(cha.value);
    }
    if (vit.present) {
      map['vit'] = Variable<int>(vit.value);
    }
    if (willGems.present) {
      map['will_gems'] = Variable<int>(willGems.value);
    }
    if (currentDebuff.present) {
      map['current_debuff'] = Variable<String>(currentDebuff.value);
    }
    if (debuffExpiresAt.present) {
      map['debuff_expires_at'] = Variable<DateTime>(debuffExpiresAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (activeSkillType.present) {
      map['active_skill_type'] = Variable<int>(
        $PlayersTable.$converteractiveSkillTypen.toSql(activeSkillType.value),
      );
    }
    if (activeSkillValue.present) {
      map['active_skill_value'] = Variable<int>(activeSkillValue.value);
    }
    if (skillExpiresAt.present) {
      map['skill_expires_at'] = Variable<DateTime>(skillExpiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('experience: $experience, ')
          ..write('str: $str, ')
          ..write('intellect: $intellect, ')
          ..write('luck: $luck, ')
          ..write('cha: $cha, ')
          ..write('vit: $vit, ')
          ..write('willGems: $willGems, ')
          ..write('currentDebuff: $currentDebuff, ')
          ..write('debuffExpiresAt: $debuffExpiresAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('activeSkillType: $activeSkillType, ')
          ..write('activeSkillValue: $activeSkillValue, ')
          ..write('skillExpiresAt: $skillExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GachaItemsTable extends GachaItems
    with TableInfo<$GachaItemsTable, GachaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GachaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EffectType, int> effectType =
      GeneratedColumn<int>(
        'effect_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EffectType>($GachaItemsTable.$convertereffectType);
  @override
  late final GeneratedColumnWithTypeConverter<GachaItemType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<GachaItemType>($GachaItemsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<Rarity, int> rarity =
      GeneratedColumn<int>(
        'rarity',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(Rarity.n.value),
      ).withConverter<Rarity>($GachaItemsTable.$converterrarity);
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _strBonusMeta = const VerificationMeta(
    'strBonus',
  );
  @override
  late final GeneratedColumn<int> strBonus = GeneratedColumn<int>(
    'str_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intBonusMeta = const VerificationMeta(
    'intBonus',
  );
  @override
  late final GeneratedColumn<int> intBonus = GeneratedColumn<int>(
    'int_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _luckBonusMeta = const VerificationMeta(
    'luckBonus',
  );
  @override
  late final GeneratedColumn<int> luckBonus = GeneratedColumn<int>(
    'luck_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chaBonusMeta = const VerificationMeta(
    'chaBonus',
  );
  @override
  late final GeneratedColumn<int> chaBonus = GeneratedColumn<int>(
    'cha_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitBonusMeta = const VerificationMeta(
    'vitBonus',
  );
  @override
  late final GeneratedColumn<int> vitBonus = GeneratedColumn<int>(
    'vit_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bondLevelMeta = const VerificationMeta(
    'bondLevel',
  );
  @override
  late final GeneratedColumn<int> bondLevel = GeneratedColumn<int>(
    'bond_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SkillType, int> skillType =
      GeneratedColumn<int>(
        'skill_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SkillType>($GachaItemsTable.$converterskillType);
  static const VerificationMeta _skillValueMeta = const VerificationMeta(
    'skillValue',
  );
  @override
  late final GeneratedColumn<int> skillValue = GeneratedColumn<int>(
    'skill_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skillDurationMeta = const VerificationMeta(
    'skillDuration',
  );
  @override
  late final GeneratedColumn<int> skillDuration = GeneratedColumn<int>(
    'skill_duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skillCooldownMeta = const VerificationMeta(
    'skillCooldown',
  );
  @override
  late final GeneratedColumn<int> skillCooldown = GeneratedColumn<int>(
    'skill_cooldown',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSkillUsedAtMeta = const VerificationMeta(
    'lastSkillUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSkillUsedAt =
      GeneratedColumn<DateTime>(
        'last_skill_used_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SeriesType, int> seriesId =
      GeneratedColumn<int>(
        'series_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SeriesType>($GachaItemsTable.$converterseriesId);
  static const VerificationMeta _isSourceMeta = const VerificationMeta(
    'isSource',
  );
  @override
  late final GeneratedColumn<bool> isSource = GeneratedColumn<bool>(
    'is_source',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_source" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imagePath,
    title,
    effectType,
    type,
    rarity,
    isUnlocked,
    strBonus,
    intBonus,
    luckBonus,
    chaBonus,
    vitBonus,
    bondLevel,
    skillType,
    skillValue,
    skillDuration,
    skillCooldown,
    lastSkillUsedAt,
    seriesId,
    isSource,
    sourceId,
    createdAt,
    unlockedAt,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gacha_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<GachaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('str_bonus')) {
      context.handle(
        _strBonusMeta,
        strBonus.isAcceptableOrUnknown(data['str_bonus']!, _strBonusMeta),
      );
    }
    if (data.containsKey('int_bonus')) {
      context.handle(
        _intBonusMeta,
        intBonus.isAcceptableOrUnknown(data['int_bonus']!, _intBonusMeta),
      );
    }
    if (data.containsKey('luck_bonus')) {
      context.handle(
        _luckBonusMeta,
        luckBonus.isAcceptableOrUnknown(data['luck_bonus']!, _luckBonusMeta),
      );
    }
    if (data.containsKey('cha_bonus')) {
      context.handle(
        _chaBonusMeta,
        chaBonus.isAcceptableOrUnknown(data['cha_bonus']!, _chaBonusMeta),
      );
    }
    if (data.containsKey('vit_bonus')) {
      context.handle(
        _vitBonusMeta,
        vitBonus.isAcceptableOrUnknown(data['vit_bonus']!, _vitBonusMeta),
      );
    }
    if (data.containsKey('bond_level')) {
      context.handle(
        _bondLevelMeta,
        bondLevel.isAcceptableOrUnknown(data['bond_level']!, _bondLevelMeta),
      );
    }
    if (data.containsKey('skill_value')) {
      context.handle(
        _skillValueMeta,
        skillValue.isAcceptableOrUnknown(data['skill_value']!, _skillValueMeta),
      );
    }
    if (data.containsKey('skill_duration')) {
      context.handle(
        _skillDurationMeta,
        skillDuration.isAcceptableOrUnknown(
          data['skill_duration']!,
          _skillDurationMeta,
        ),
      );
    }
    if (data.containsKey('skill_cooldown')) {
      context.handle(
        _skillCooldownMeta,
        skillCooldown.isAcceptableOrUnknown(
          data['skill_cooldown']!,
          _skillCooldownMeta,
        ),
      );
    }
    if (data.containsKey('last_skill_used_at')) {
      context.handle(
        _lastSkillUsedAtMeta,
        lastSkillUsedAt.isAcceptableOrUnknown(
          data['last_skill_used_at']!,
          _lastSkillUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_source')) {
      context.handle(
        _isSourceMeta,
        isSource.isAcceptableOrUnknown(data['is_source']!, _isSourceMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GachaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GachaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      effectType: $GachaItemsTable.$convertereffectType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}effect_type'],
        )!,
      ),
      type: $GachaItemsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      rarity: $GachaItemsTable.$converterrarity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}rarity'],
        )!,
      ),
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      strBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}str_bonus'],
      )!,
      intBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_bonus'],
      )!,
      luckBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}luck_bonus'],
      )!,
      chaBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cha_bonus'],
      )!,
      vitBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vit_bonus'],
      )!,
      bondLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bond_level'],
      )!,
      skillType: $GachaItemsTable.$converterskillType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}skill_type'],
        )!,
      ),
      skillValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_value'],
      )!,
      skillDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_duration'],
      )!,
      skillCooldown: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_cooldown'],
      )!,
      lastSkillUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_skill_used_at'],
      ),
      seriesId: $GachaItemsTable.$converterseriesId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}series_id'],
        )!,
      ),
      isSource: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $GachaItemsTable createAlias(String alias) {
    return $GachaItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EffectType, int, int> $convertereffectType =
      const EnumIndexConverter<EffectType>(EffectType.values);
  static JsonTypeConverter2<GachaItemType, int, int> $convertertype =
      const EnumIndexConverter<GachaItemType>(GachaItemType.values);
  static JsonTypeConverter2<Rarity, int, int> $converterrarity =
      const EnumIndexConverter<Rarity>(Rarity.values);
  static JsonTypeConverter2<SkillType, int, int> $converterskillType =
      const EnumIndexConverter<SkillType>(SkillType.values);
  static JsonTypeConverter2<SeriesType, int, int> $converterseriesId =
      const EnumIndexConverter<SeriesType>(SeriesType.values);
}

class GachaItem extends DataClass implements Insertable<GachaItem> {
  final int id;
  final String imagePath;
  final String title;
  final EffectType effectType;
  final GachaItemType type;
  final Rarity rarity;
  final bool isUnlocked;
  final int strBonus;
  final int intBonus;
  final int luckBonus;
  final int chaBonus;
  final int vitBonus;
  final int bondLevel;
  final SkillType skillType;
  final int skillValue;
  final int skillDuration;
  final int skillCooldown;
  final DateTime? lastSkillUsedAt;
  final SeriesType seriesId;
  final bool isSource;
  final int? sourceId;
  final DateTime createdAt;
  final DateTime? unlockedAt;
  final bool isFavorite;
  const GachaItem({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.effectType,
    required this.type,
    required this.rarity,
    required this.isUnlocked,
    required this.strBonus,
    required this.intBonus,
    required this.luckBonus,
    required this.chaBonus,
    required this.vitBonus,
    required this.bondLevel,
    required this.skillType,
    required this.skillValue,
    required this.skillDuration,
    required this.skillCooldown,
    this.lastSkillUsedAt,
    required this.seriesId,
    required this.isSource,
    this.sourceId,
    required this.createdAt,
    this.unlockedAt,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    map['title'] = Variable<String>(title);
    {
      map['effect_type'] = Variable<int>(
        $GachaItemsTable.$convertereffectType.toSql(effectType),
      );
    }
    {
      map['type'] = Variable<int>($GachaItemsTable.$convertertype.toSql(type));
    }
    {
      map['rarity'] = Variable<int>(
        $GachaItemsTable.$converterrarity.toSql(rarity),
      );
    }
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    map['str_bonus'] = Variable<int>(strBonus);
    map['int_bonus'] = Variable<int>(intBonus);
    map['luck_bonus'] = Variable<int>(luckBonus);
    map['cha_bonus'] = Variable<int>(chaBonus);
    map['vit_bonus'] = Variable<int>(vitBonus);
    map['bond_level'] = Variable<int>(bondLevel);
    {
      map['skill_type'] = Variable<int>(
        $GachaItemsTable.$converterskillType.toSql(skillType),
      );
    }
    map['skill_value'] = Variable<int>(skillValue);
    map['skill_duration'] = Variable<int>(skillDuration);
    map['skill_cooldown'] = Variable<int>(skillCooldown);
    if (!nullToAbsent || lastSkillUsedAt != null) {
      map['last_skill_used_at'] = Variable<DateTime>(lastSkillUsedAt);
    }
    {
      map['series_id'] = Variable<int>(
        $GachaItemsTable.$converterseriesId.toSql(seriesId),
      );
    }
    map['is_source'] = Variable<bool>(isSource);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  GachaItemsCompanion toCompanion(bool nullToAbsent) {
    return GachaItemsCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      title: Value(title),
      effectType: Value(effectType),
      type: Value(type),
      rarity: Value(rarity),
      isUnlocked: Value(isUnlocked),
      strBonus: Value(strBonus),
      intBonus: Value(intBonus),
      luckBonus: Value(luckBonus),
      chaBonus: Value(chaBonus),
      vitBonus: Value(vitBonus),
      bondLevel: Value(bondLevel),
      skillType: Value(skillType),
      skillValue: Value(skillValue),
      skillDuration: Value(skillDuration),
      skillCooldown: Value(skillCooldown),
      lastSkillUsedAt: lastSkillUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSkillUsedAt),
      seriesId: Value(seriesId),
      isSource: Value(isSource),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      createdAt: Value(createdAt),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      isFavorite: Value(isFavorite),
    );
  }

  factory GachaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GachaItem(
      id: serializer.fromJson<int>(json['id']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      title: serializer.fromJson<String>(json['title']),
      effectType: $GachaItemsTable.$convertereffectType.fromJson(
        serializer.fromJson<int>(json['effectType']),
      ),
      type: $GachaItemsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      rarity: $GachaItemsTable.$converterrarity.fromJson(
        serializer.fromJson<int>(json['rarity']),
      ),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      strBonus: serializer.fromJson<int>(json['strBonus']),
      intBonus: serializer.fromJson<int>(json['intBonus']),
      luckBonus: serializer.fromJson<int>(json['luckBonus']),
      chaBonus: serializer.fromJson<int>(json['chaBonus']),
      vitBonus: serializer.fromJson<int>(json['vitBonus']),
      bondLevel: serializer.fromJson<int>(json['bondLevel']),
      skillType: $GachaItemsTable.$converterskillType.fromJson(
        serializer.fromJson<int>(json['skillType']),
      ),
      skillValue: serializer.fromJson<int>(json['skillValue']),
      skillDuration: serializer.fromJson<int>(json['skillDuration']),
      skillCooldown: serializer.fromJson<int>(json['skillCooldown']),
      lastSkillUsedAt: serializer.fromJson<DateTime?>(json['lastSkillUsedAt']),
      seriesId: $GachaItemsTable.$converterseriesId.fromJson(
        serializer.fromJson<int>(json['seriesId']),
      ),
      isSource: serializer.fromJson<bool>(json['isSource']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imagePath': serializer.toJson<String>(imagePath),
      'title': serializer.toJson<String>(title),
      'effectType': serializer.toJson<int>(
        $GachaItemsTable.$convertereffectType.toJson(effectType),
      ),
      'type': serializer.toJson<int>(
        $GachaItemsTable.$convertertype.toJson(type),
      ),
      'rarity': serializer.toJson<int>(
        $GachaItemsTable.$converterrarity.toJson(rarity),
      ),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'strBonus': serializer.toJson<int>(strBonus),
      'intBonus': serializer.toJson<int>(intBonus),
      'luckBonus': serializer.toJson<int>(luckBonus),
      'chaBonus': serializer.toJson<int>(chaBonus),
      'vitBonus': serializer.toJson<int>(vitBonus),
      'bondLevel': serializer.toJson<int>(bondLevel),
      'skillType': serializer.toJson<int>(
        $GachaItemsTable.$converterskillType.toJson(skillType),
      ),
      'skillValue': serializer.toJson<int>(skillValue),
      'skillDuration': serializer.toJson<int>(skillDuration),
      'skillCooldown': serializer.toJson<int>(skillCooldown),
      'lastSkillUsedAt': serializer.toJson<DateTime?>(lastSkillUsedAt),
      'seriesId': serializer.toJson<int>(
        $GachaItemsTable.$converterseriesId.toJson(seriesId),
      ),
      'isSource': serializer.toJson<bool>(isSource),
      'sourceId': serializer.toJson<int?>(sourceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  GachaItem copyWith({
    int? id,
    String? imagePath,
    String? title,
    EffectType? effectType,
    GachaItemType? type,
    Rarity? rarity,
    bool? isUnlocked,
    int? strBonus,
    int? intBonus,
    int? luckBonus,
    int? chaBonus,
    int? vitBonus,
    int? bondLevel,
    SkillType? skillType,
    int? skillValue,
    int? skillDuration,
    int? skillCooldown,
    Value<DateTime?> lastSkillUsedAt = const Value.absent(),
    SeriesType? seriesId,
    bool? isSource,
    Value<int?> sourceId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> unlockedAt = const Value.absent(),
    bool? isFavorite,
  }) => GachaItem(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    title: title ?? this.title,
    effectType: effectType ?? this.effectType,
    type: type ?? this.type,
    rarity: rarity ?? this.rarity,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    strBonus: strBonus ?? this.strBonus,
    intBonus: intBonus ?? this.intBonus,
    luckBonus: luckBonus ?? this.luckBonus,
    chaBonus: chaBonus ?? this.chaBonus,
    vitBonus: vitBonus ?? this.vitBonus,
    bondLevel: bondLevel ?? this.bondLevel,
    skillType: skillType ?? this.skillType,
    skillValue: skillValue ?? this.skillValue,
    skillDuration: skillDuration ?? this.skillDuration,
    skillCooldown: skillCooldown ?? this.skillCooldown,
    lastSkillUsedAt: lastSkillUsedAt.present
        ? lastSkillUsedAt.value
        : this.lastSkillUsedAt,
    seriesId: seriesId ?? this.seriesId,
    isSource: isSource ?? this.isSource,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    createdAt: createdAt ?? this.createdAt,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  GachaItem copyWithCompanion(GachaItemsCompanion data) {
    return GachaItem(
      id: data.id.present ? data.id.value : this.id,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      title: data.title.present ? data.title.value : this.title,
      effectType: data.effectType.present
          ? data.effectType.value
          : this.effectType,
      type: data.type.present ? data.type.value : this.type,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      strBonus: data.strBonus.present ? data.strBonus.value : this.strBonus,
      intBonus: data.intBonus.present ? data.intBonus.value : this.intBonus,
      luckBonus: data.luckBonus.present ? data.luckBonus.value : this.luckBonus,
      chaBonus: data.chaBonus.present ? data.chaBonus.value : this.chaBonus,
      vitBonus: data.vitBonus.present ? data.vitBonus.value : this.vitBonus,
      bondLevel: data.bondLevel.present ? data.bondLevel.value : this.bondLevel,
      skillType: data.skillType.present ? data.skillType.value : this.skillType,
      skillValue: data.skillValue.present
          ? data.skillValue.value
          : this.skillValue,
      skillDuration: data.skillDuration.present
          ? data.skillDuration.value
          : this.skillDuration,
      skillCooldown: data.skillCooldown.present
          ? data.skillCooldown.value
          : this.skillCooldown,
      lastSkillUsedAt: data.lastSkillUsedAt.present
          ? data.lastSkillUsedAt.value
          : this.lastSkillUsedAt,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      isSource: data.isSource.present ? data.isSource.value : this.isSource,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GachaItem(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('title: $title, ')
          ..write('effectType: $effectType, ')
          ..write('type: $type, ')
          ..write('rarity: $rarity, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('strBonus: $strBonus, ')
          ..write('intBonus: $intBonus, ')
          ..write('luckBonus: $luckBonus, ')
          ..write('chaBonus: $chaBonus, ')
          ..write('vitBonus: $vitBonus, ')
          ..write('bondLevel: $bondLevel, ')
          ..write('skillType: $skillType, ')
          ..write('skillValue: $skillValue, ')
          ..write('skillDuration: $skillDuration, ')
          ..write('skillCooldown: $skillCooldown, ')
          ..write('lastSkillUsedAt: $lastSkillUsedAt, ')
          ..write('seriesId: $seriesId, ')
          ..write('isSource: $isSource, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    imagePath,
    title,
    effectType,
    type,
    rarity,
    isUnlocked,
    strBonus,
    intBonus,
    luckBonus,
    chaBonus,
    vitBonus,
    bondLevel,
    skillType,
    skillValue,
    skillDuration,
    skillCooldown,
    lastSkillUsedAt,
    seriesId,
    isSource,
    sourceId,
    createdAt,
    unlockedAt,
    isFavorite,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GachaItem &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.title == this.title &&
          other.effectType == this.effectType &&
          other.type == this.type &&
          other.rarity == this.rarity &&
          other.isUnlocked == this.isUnlocked &&
          other.strBonus == this.strBonus &&
          other.intBonus == this.intBonus &&
          other.luckBonus == this.luckBonus &&
          other.chaBonus == this.chaBonus &&
          other.vitBonus == this.vitBonus &&
          other.bondLevel == this.bondLevel &&
          other.skillType == this.skillType &&
          other.skillValue == this.skillValue &&
          other.skillDuration == this.skillDuration &&
          other.skillCooldown == this.skillCooldown &&
          other.lastSkillUsedAt == this.lastSkillUsedAt &&
          other.seriesId == this.seriesId &&
          other.isSource == this.isSource &&
          other.sourceId == this.sourceId &&
          other.createdAt == this.createdAt &&
          other.unlockedAt == this.unlockedAt &&
          other.isFavorite == this.isFavorite);
}

class GachaItemsCompanion extends UpdateCompanion<GachaItem> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<String> title;
  final Value<EffectType> effectType;
  final Value<GachaItemType> type;
  final Value<Rarity> rarity;
  final Value<bool> isUnlocked;
  final Value<int> strBonus;
  final Value<int> intBonus;
  final Value<int> luckBonus;
  final Value<int> chaBonus;
  final Value<int> vitBonus;
  final Value<int> bondLevel;
  final Value<SkillType> skillType;
  final Value<int> skillValue;
  final Value<int> skillDuration;
  final Value<int> skillCooldown;
  final Value<DateTime?> lastSkillUsedAt;
  final Value<SeriesType> seriesId;
  final Value<bool> isSource;
  final Value<int?> sourceId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> unlockedAt;
  final Value<bool> isFavorite;
  const GachaItemsCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.title = const Value.absent(),
    this.effectType = const Value.absent(),
    this.type = const Value.absent(),
    this.rarity = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.strBonus = const Value.absent(),
    this.intBonus = const Value.absent(),
    this.luckBonus = const Value.absent(),
    this.chaBonus = const Value.absent(),
    this.vitBonus = const Value.absent(),
    this.bondLevel = const Value.absent(),
    this.skillType = const Value.absent(),
    this.skillValue = const Value.absent(),
    this.skillDuration = const Value.absent(),
    this.skillCooldown = const Value.absent(),
    this.lastSkillUsedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.isSource = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  GachaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    required String title,
    required EffectType effectType,
    this.type = const Value.absent(),
    this.rarity = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.strBonus = const Value.absent(),
    this.intBonus = const Value.absent(),
    this.luckBonus = const Value.absent(),
    this.chaBonus = const Value.absent(),
    this.vitBonus = const Value.absent(),
    this.bondLevel = const Value.absent(),
    this.skillType = const Value.absent(),
    this.skillValue = const Value.absent(),
    this.skillDuration = const Value.absent(),
    this.skillCooldown = const Value.absent(),
    this.lastSkillUsedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.isSource = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
  }) : imagePath = Value(imagePath),
       title = Value(title),
       effectType = Value(effectType);
  static Insertable<GachaItem> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<String>? title,
    Expression<int>? effectType,
    Expression<int>? type,
    Expression<int>? rarity,
    Expression<bool>? isUnlocked,
    Expression<int>? strBonus,
    Expression<int>? intBonus,
    Expression<int>? luckBonus,
    Expression<int>? chaBonus,
    Expression<int>? vitBonus,
    Expression<int>? bondLevel,
    Expression<int>? skillType,
    Expression<int>? skillValue,
    Expression<int>? skillDuration,
    Expression<int>? skillCooldown,
    Expression<DateTime>? lastSkillUsedAt,
    Expression<int>? seriesId,
    Expression<bool>? isSource,
    Expression<int>? sourceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? unlockedAt,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (title != null) 'title': title,
      if (effectType != null) 'effect_type': effectType,
      if (type != null) 'type': type,
      if (rarity != null) 'rarity': rarity,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (strBonus != null) 'str_bonus': strBonus,
      if (intBonus != null) 'int_bonus': intBonus,
      if (luckBonus != null) 'luck_bonus': luckBonus,
      if (chaBonus != null) 'cha_bonus': chaBonus,
      if (vitBonus != null) 'vit_bonus': vitBonus,
      if (bondLevel != null) 'bond_level': bondLevel,
      if (skillType != null) 'skill_type': skillType,
      if (skillValue != null) 'skill_value': skillValue,
      if (skillDuration != null) 'skill_duration': skillDuration,
      if (skillCooldown != null) 'skill_cooldown': skillCooldown,
      if (lastSkillUsedAt != null) 'last_skill_used_at': lastSkillUsedAt,
      if (seriesId != null) 'series_id': seriesId,
      if (isSource != null) 'is_source': isSource,
      if (sourceId != null) 'source_id': sourceId,
      if (createdAt != null) 'created_at': createdAt,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  GachaItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? imagePath,
    Value<String>? title,
    Value<EffectType>? effectType,
    Value<GachaItemType>? type,
    Value<Rarity>? rarity,
    Value<bool>? isUnlocked,
    Value<int>? strBonus,
    Value<int>? intBonus,
    Value<int>? luckBonus,
    Value<int>? chaBonus,
    Value<int>? vitBonus,
    Value<int>? bondLevel,
    Value<SkillType>? skillType,
    Value<int>? skillValue,
    Value<int>? skillDuration,
    Value<int>? skillCooldown,
    Value<DateTime?>? lastSkillUsedAt,
    Value<SeriesType>? seriesId,
    Value<bool>? isSource,
    Value<int?>? sourceId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? unlockedAt,
    Value<bool>? isFavorite,
  }) {
    return GachaItemsCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      effectType: effectType ?? this.effectType,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      strBonus: strBonus ?? this.strBonus,
      intBonus: intBonus ?? this.intBonus,
      luckBonus: luckBonus ?? this.luckBonus,
      chaBonus: chaBonus ?? this.chaBonus,
      vitBonus: vitBonus ?? this.vitBonus,
      bondLevel: bondLevel ?? this.bondLevel,
      skillType: skillType ?? this.skillType,
      skillValue: skillValue ?? this.skillValue,
      skillDuration: skillDuration ?? this.skillDuration,
      skillCooldown: skillCooldown ?? this.skillCooldown,
      lastSkillUsedAt: lastSkillUsedAt ?? this.lastSkillUsedAt,
      seriesId: seriesId ?? this.seriesId,
      isSource: isSource ?? this.isSource,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (effectType.present) {
      map['effect_type'] = Variable<int>(
        $GachaItemsTable.$convertereffectType.toSql(effectType.value),
      );
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $GachaItemsTable.$convertertype.toSql(type.value),
      );
    }
    if (rarity.present) {
      map['rarity'] = Variable<int>(
        $GachaItemsTable.$converterrarity.toSql(rarity.value),
      );
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (strBonus.present) {
      map['str_bonus'] = Variable<int>(strBonus.value);
    }
    if (intBonus.present) {
      map['int_bonus'] = Variable<int>(intBonus.value);
    }
    if (luckBonus.present) {
      map['luck_bonus'] = Variable<int>(luckBonus.value);
    }
    if (chaBonus.present) {
      map['cha_bonus'] = Variable<int>(chaBonus.value);
    }
    if (vitBonus.present) {
      map['vit_bonus'] = Variable<int>(vitBonus.value);
    }
    if (bondLevel.present) {
      map['bond_level'] = Variable<int>(bondLevel.value);
    }
    if (skillType.present) {
      map['skill_type'] = Variable<int>(
        $GachaItemsTable.$converterskillType.toSql(skillType.value),
      );
    }
    if (skillValue.present) {
      map['skill_value'] = Variable<int>(skillValue.value);
    }
    if (skillDuration.present) {
      map['skill_duration'] = Variable<int>(skillDuration.value);
    }
    if (skillCooldown.present) {
      map['skill_cooldown'] = Variable<int>(skillCooldown.value);
    }
    if (lastSkillUsedAt.present) {
      map['last_skill_used_at'] = Variable<DateTime>(lastSkillUsedAt.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(
        $GachaItemsTable.$converterseriesId.toSql(seriesId.value),
      );
    }
    if (isSource.present) {
      map['is_source'] = Variable<bool>(isSource.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GachaItemsCompanion(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('title: $title, ')
          ..write('effectType: $effectType, ')
          ..write('type: $type, ')
          ..write('rarity: $rarity, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('strBonus: $strBonus, ')
          ..write('intBonus: $intBonus, ')
          ..write('luckBonus: $luckBonus, ')
          ..write('chaBonus: $chaBonus, ')
          ..write('vitBonus: $vitBonus, ')
          ..write('bondLevel: $bondLevel, ')
          ..write('skillType: $skillType, ')
          ..write('skillValue: $skillValue, ')
          ..write('skillDuration: $skillDuration, ')
          ..write('skillCooldown: $skillCooldown, ')
          ..write('lastSkillUsedAt: $lastSkillUsedAt, ')
          ..write('seriesId: $seriesId, ')
          ..write('isSource: $isSource, ')
          ..write('sourceId: $sourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskType, int> taskType =
      GeneratedColumn<int>(
        'task_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskType>($HabitsTable.$convertertaskType);
  @override
  late final GeneratedColumnWithTypeConverter<TaskDifficulty, int> difficulty =
      GeneratedColumn<int>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(TaskDifficulty.normal.value),
      ).withConverter<TaskDifficulty>($HabitsTable.$converterdifficulty);
  static const VerificationMeta _rewardGemsMeta = const VerificationMeta(
    'rewardGems',
  );
  @override
  late final GeneratedColumn<int> rewardGems = GeneratedColumn<int>(
    'reward_gems',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _rewardXpMeta = const VerificationMeta(
    'rewardXp',
  );
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
    'reward_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    taskType,
    difficulty,
    rewardGems,
    rewardXp,
    isCompleted,
    completedAt,
    dueDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('reward_gems')) {
      context.handle(
        _rewardGemsMeta,
        rewardGems.isAcceptableOrUnknown(data['reward_gems']!, _rewardGemsMeta),
      );
    }
    if (data.containsKey('reward_xp')) {
      context.handle(
        _rewardXpMeta,
        rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      taskType: $HabitsTable.$convertertaskType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}task_type'],
        )!,
      ),
      difficulty: $HabitsTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      rewardGems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_gems'],
      )!,
      rewardXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_xp'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskType, int, int> $convertertaskType =
      const EnumIndexConverter<TaskType>(TaskType.values);
  static JsonTypeConverter2<TaskDifficulty, int, int> $converterdifficulty =
      const EnumIndexConverter<TaskDifficulty>(TaskDifficulty.values);
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final TaskType taskType;
  final TaskDifficulty difficulty;
  final int rewardGems;
  final int rewardXp;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Habit({
    required this.id,
    required this.name,
    required this.taskType,
    required this.difficulty,
    required this.rewardGems,
    required this.rewardXp,
    required this.isCompleted,
    this.completedAt,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['task_type'] = Variable<int>(
        $HabitsTable.$convertertaskType.toSql(taskType),
      );
    }
    {
      map['difficulty'] = Variable<int>(
        $HabitsTable.$converterdifficulty.toSql(difficulty),
      );
    }
    map['reward_gems'] = Variable<int>(rewardGems);
    map['reward_xp'] = Variable<int>(rewardXp);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      taskType: Value(taskType),
      difficulty: Value(difficulty),
      rewardGems: Value(rewardGems),
      rewardXp: Value(rewardXp),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      taskType: $HabitsTable.$convertertaskType.fromJson(
        serializer.fromJson<int>(json['taskType']),
      ),
      difficulty: $HabitsTable.$converterdifficulty.fromJson(
        serializer.fromJson<int>(json['difficulty']),
      ),
      rewardGems: serializer.fromJson<int>(json['rewardGems']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'taskType': serializer.toJson<int>(
        $HabitsTable.$convertertaskType.toJson(taskType),
      ),
      'difficulty': serializer.toJson<int>(
        $HabitsTable.$converterdifficulty.toJson(difficulty),
      ),
      'rewardGems': serializer.toJson<int>(rewardGems),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    TaskType? taskType,
    TaskDifficulty? difficulty,
    int? rewardGems,
    int? rewardXp,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    taskType: taskType ?? this.taskType,
    difficulty: difficulty ?? this.difficulty,
    rewardGems: rewardGems ?? this.rewardGems,
    rewardXp: rewardXp ?? this.rewardXp,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      rewardGems: data.rewardGems.present
          ? data.rewardGems.value
          : this.rewardGems,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taskType: $taskType, ')
          ..write('difficulty: $difficulty, ')
          ..write('rewardGems: $rewardGems, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    taskType,
    difficulty,
    rewardGems,
    rewardXp,
    isCompleted,
    completedAt,
    dueDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.taskType == this.taskType &&
          other.difficulty == this.difficulty &&
          other.rewardGems == this.rewardGems &&
          other.rewardXp == this.rewardXp &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<TaskType> taskType;
  final Value<TaskDifficulty> difficulty;
  final Value<int> rewardGems;
  final Value<int> rewardXp;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.taskType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.rewardGems = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required TaskType taskType,
    this.difficulty = const Value.absent(),
    this.rewardGems = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       taskType = Value(taskType);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? taskType,
    Expression<int>? difficulty,
    Expression<int>? rewardGems,
    Expression<int>? rewardXp,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (taskType != null) 'task_type': taskType,
      if (difficulty != null) 'difficulty': difficulty,
      if (rewardGems != null) 'reward_gems': rewardGems,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<TaskType>? taskType,
    Value<TaskDifficulty>? difficulty,
    Value<int>? rewardGems,
    Value<int>? rewardXp,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? dueDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      taskType: taskType ?? this.taskType,
      difficulty: difficulty ?? this.difficulty,
      rewardGems: rewardGems ?? this.rewardGems,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<int>(
        $HabitsTable.$convertertaskType.toSql(taskType.value),
      );
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(
        $HabitsTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (rewardGems.present) {
      map['reward_gems'] = Variable<int>(rewardGems.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taskType: $taskType, ')
          ..write('difficulty: $difficulty, ')
          ..write('rewardGems: $rewardGems, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TitlesTable extends Titles with TableInfo<$TitlesTable, Title> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TitlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passiveSkillMeta = const VerificationMeta(
    'passiveSkill',
  );
  @override
  late final GeneratedColumn<String> passiveSkill = GeneratedColumn<String>(
    'passive_skill',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unlockConditionTypeMeta =
      const VerificationMeta('unlockConditionType');
  @override
  late final GeneratedColumn<String> unlockConditionType =
      GeneratedColumn<String>(
        'unlock_condition_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _unlockConditionValueMeta =
      const VerificationMeta('unlockConditionValue');
  @override
  late final GeneratedColumn<String> unlockConditionValue =
      GeneratedColumn<String>(
        'unlock_condition_value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    passiveSkill,
    unlockConditionType,
    unlockConditionValue,
    isUnlocked,
    unlockedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Title> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('passive_skill')) {
      context.handle(
        _passiveSkillMeta,
        passiveSkill.isAcceptableOrUnknown(
          data['passive_skill']!,
          _passiveSkillMeta,
        ),
      );
    }
    if (data.containsKey('unlock_condition_type')) {
      context.handle(
        _unlockConditionTypeMeta,
        unlockConditionType.isAcceptableOrUnknown(
          data['unlock_condition_type']!,
          _unlockConditionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockConditionTypeMeta);
    }
    if (data.containsKey('unlock_condition_value')) {
      context.handle(
        _unlockConditionValueMeta,
        unlockConditionValue.isAcceptableOrUnknown(
          data['unlock_condition_value']!,
          _unlockConditionValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockConditionValueMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
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
  Title map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Title(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      passiveSkill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passive_skill'],
      ),
      unlockConditionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlock_condition_type'],
      )!,
      unlockConditionValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlock_condition_value'],
      )!,
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TitlesTable createAlias(String alias) {
    return $TitlesTable(attachedDatabase, alias);
  }
}

class Title extends DataClass implements Insertable<Title> {
  final int id;
  final String name;
  final String? description;
  final String? passiveSkill;
  final String unlockConditionType;
  final String unlockConditionValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;
  const Title({
    required this.id,
    required this.name,
    this.description,
    this.passiveSkill,
    required this.unlockConditionType,
    required this.unlockConditionValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || passiveSkill != null) {
      map['passive_skill'] = Variable<String>(passiveSkill);
    }
    map['unlock_condition_type'] = Variable<String>(unlockConditionType);
    map['unlock_condition_value'] = Variable<String>(unlockConditionValue);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TitlesCompanion toCompanion(bool nullToAbsent) {
    return TitlesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      passiveSkill: passiveSkill == null && nullToAbsent
          ? const Value.absent()
          : Value(passiveSkill),
      unlockConditionType: Value(unlockConditionType),
      unlockConditionValue: Value(unlockConditionValue),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Title.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Title(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      passiveSkill: serializer.fromJson<String?>(json['passiveSkill']),
      unlockConditionType: serializer.fromJson<String>(
        json['unlockConditionType'],
      ),
      unlockConditionValue: serializer.fromJson<String>(
        json['unlockConditionValue'],
      ),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'passiveSkill': serializer.toJson<String?>(passiveSkill),
      'unlockConditionType': serializer.toJson<String>(unlockConditionType),
      'unlockConditionValue': serializer.toJson<String>(unlockConditionValue),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Title copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> passiveSkill = const Value.absent(),
    String? unlockConditionType,
    String? unlockConditionValue,
    bool? isUnlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Title(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    passiveSkill: passiveSkill.present ? passiveSkill.value : this.passiveSkill,
    unlockConditionType: unlockConditionType ?? this.unlockConditionType,
    unlockConditionValue: unlockConditionValue ?? this.unlockConditionValue,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Title copyWithCompanion(TitlesCompanion data) {
    return Title(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      passiveSkill: data.passiveSkill.present
          ? data.passiveSkill.value
          : this.passiveSkill,
      unlockConditionType: data.unlockConditionType.present
          ? data.unlockConditionType.value
          : this.unlockConditionType,
      unlockConditionValue: data.unlockConditionValue.present
          ? data.unlockConditionValue.value
          : this.unlockConditionValue,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Title(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('passiveSkill: $passiveSkill, ')
          ..write('unlockConditionType: $unlockConditionType, ')
          ..write('unlockConditionValue: $unlockConditionValue, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    passiveSkill,
    unlockConditionType,
    unlockConditionValue,
    isUnlocked,
    unlockedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Title &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.passiveSkill == this.passiveSkill &&
          other.unlockConditionType == this.unlockConditionType &&
          other.unlockConditionValue == this.unlockConditionValue &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt &&
          other.createdAt == this.createdAt);
}

class TitlesCompanion extends UpdateCompanion<Title> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> passiveSkill;
  final Value<String> unlockConditionType;
  final Value<String> unlockConditionValue;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  final Value<DateTime> createdAt;
  const TitlesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.passiveSkill = const Value.absent(),
    this.unlockConditionType = const Value.absent(),
    this.unlockConditionValue = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TitlesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.passiveSkill = const Value.absent(),
    required String unlockConditionType,
    required String unlockConditionValue,
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       unlockConditionType = Value(unlockConditionType),
       unlockConditionValue = Value(unlockConditionValue);
  static Insertable<Title> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? passiveSkill,
    Expression<String>? unlockConditionType,
    Expression<String>? unlockConditionValue,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (passiveSkill != null) 'passive_skill': passiveSkill,
      if (unlockConditionType != null)
        'unlock_condition_type': unlockConditionType,
      if (unlockConditionValue != null)
        'unlock_condition_value': unlockConditionValue,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TitlesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? passiveSkill,
    Value<String>? unlockConditionType,
    Value<String>? unlockConditionValue,
    Value<bool>? isUnlocked,
    Value<DateTime?>? unlockedAt,
    Value<DateTime>? createdAt,
  }) {
    return TitlesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      passiveSkill: passiveSkill ?? this.passiveSkill,
      unlockConditionType: unlockConditionType ?? this.unlockConditionType,
      unlockConditionValue: unlockConditionValue ?? this.unlockConditionValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (passiveSkill.present) {
      map['passive_skill'] = Variable<String>(passiveSkill.value);
    }
    if (unlockConditionType.present) {
      map['unlock_condition_type'] = Variable<String>(
        unlockConditionType.value,
      );
    }
    if (unlockConditionValue.present) {
      map['unlock_condition_value'] = Variable<String>(
        unlockConditionValue.value,
      );
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TitlesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('passiveSkill: $passiveSkill, ')
          ..write('unlockConditionType: $unlockConditionType, ')
          ..write('unlockConditionValue: $unlockConditionValue, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PartyDecksTable extends PartyDecks
    with TableInfo<$PartyDecksTable, PartyDeck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartyDecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _equippedFrameIdMeta = const VerificationMeta(
    'equippedFrameId',
  );
  @override
  late final GeneratedColumn<int> equippedFrameId = GeneratedColumn<int>(
    'equipped_frame_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gacha_items (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isActive,
    equippedFrameId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyDeck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('equipped_frame_id')) {
      context.handle(
        _equippedFrameIdMeta,
        equippedFrameId.isAcceptableOrUnknown(
          data['equipped_frame_id']!,
          _equippedFrameIdMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartyDeck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyDeck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      equippedFrameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipped_frame_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PartyDecksTable createAlias(String alias) {
    return $PartyDecksTable(attachedDatabase, alias);
  }
}

class PartyDeck extends DataClass implements Insertable<PartyDeck> {
  final int id;
  final String name;
  final bool isActive;
  final int? equippedFrameId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PartyDeck({
    required this.id,
    required this.name,
    required this.isActive,
    this.equippedFrameId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || equippedFrameId != null) {
      map['equipped_frame_id'] = Variable<int>(equippedFrameId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PartyDecksCompanion toCompanion(bool nullToAbsent) {
    return PartyDecksCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      equippedFrameId: equippedFrameId == null && nullToAbsent
          ? const Value.absent()
          : Value(equippedFrameId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PartyDeck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyDeck(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      equippedFrameId: serializer.fromJson<int?>(json['equippedFrameId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'equippedFrameId': serializer.toJson<int?>(equippedFrameId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PartyDeck copyWith({
    int? id,
    String? name,
    bool? isActive,
    Value<int?> equippedFrameId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PartyDeck(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    equippedFrameId: equippedFrameId.present
        ? equippedFrameId.value
        : this.equippedFrameId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PartyDeck copyWithCompanion(PartyDecksCompanion data) {
    return PartyDeck(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      equippedFrameId: data.equippedFrameId.present
          ? data.equippedFrameId.value
          : this.equippedFrameId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyDeck(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('equippedFrameId: $equippedFrameId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isActive, equippedFrameId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyDeck &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.equippedFrameId == this.equippedFrameId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PartyDecksCompanion extends UpdateCompanion<PartyDeck> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int?> equippedFrameId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PartyDecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.equippedFrameId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PartyDecksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    this.equippedFrameId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PartyDeck> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? equippedFrameId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (equippedFrameId != null) 'equipped_frame_id': equippedFrameId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PartyDecksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
    Value<int?>? equippedFrameId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PartyDecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      equippedFrameId: equippedFrameId ?? this.equippedFrameId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (equippedFrameId.present) {
      map['equipped_frame_id'] = Variable<int>(equippedFrameId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyDecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('equippedFrameId: $equippedFrameId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PartyMembersTable extends PartyMembers
    with TableInfo<$PartyMembersTable, PartyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES party_decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _gachaItemIdMeta = const VerificationMeta(
    'gachaItemId',
  );
  @override
  late final GeneratedColumn<int> gachaItemId = GeneratedColumn<int>(
    'gacha_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gacha_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotPositionMeta = const VerificationMeta(
    'slotPosition',
  );
  @override
  late final GeneratedColumn<int> slotPosition = GeneratedColumn<int>(
    'slot_position',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    gachaItemId,
    slotPosition,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('gacha_item_id')) {
      context.handle(
        _gachaItemIdMeta,
        gachaItemId.isAcceptableOrUnknown(
          data['gacha_item_id']!,
          _gachaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gachaItemIdMeta);
    }
    if (data.containsKey('slot_position')) {
      context.handle(
        _slotPositionMeta,
        slotPosition.isAcceptableOrUnknown(
          data['slot_position']!,
          _slotPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_slotPositionMeta);
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
  PartyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      gachaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gacha_item_id'],
      )!,
      slotPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PartyMembersTable createAlias(String alias) {
    return $PartyMembersTable(attachedDatabase, alias);
  }
}

class PartyMember extends DataClass implements Insertable<PartyMember> {
  final int id;
  final int deckId;
  final int gachaItemId;
  final int slotPosition;
  final DateTime createdAt;
  const PartyMember({
    required this.id,
    required this.deckId,
    required this.gachaItemId,
    required this.slotPosition,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['gacha_item_id'] = Variable<int>(gachaItemId);
    map['slot_position'] = Variable<int>(slotPosition);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PartyMembersCompanion toCompanion(bool nullToAbsent) {
    return PartyMembersCompanion(
      id: Value(id),
      deckId: Value(deckId),
      gachaItemId: Value(gachaItemId),
      slotPosition: Value(slotPosition),
      createdAt: Value(createdAt),
    );
  }

  factory PartyMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyMember(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      gachaItemId: serializer.fromJson<int>(json['gachaItemId']),
      slotPosition: serializer.fromJson<int>(json['slotPosition']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'gachaItemId': serializer.toJson<int>(gachaItemId),
      'slotPosition': serializer.toJson<int>(slotPosition),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PartyMember copyWith({
    int? id,
    int? deckId,
    int? gachaItemId,
    int? slotPosition,
    DateTime? createdAt,
  }) => PartyMember(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    gachaItemId: gachaItemId ?? this.gachaItemId,
    slotPosition: slotPosition ?? this.slotPosition,
    createdAt: createdAt ?? this.createdAt,
  );
  PartyMember copyWithCompanion(PartyMembersCompanion data) {
    return PartyMember(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      gachaItemId: data.gachaItemId.present
          ? data.gachaItemId.value
          : this.gachaItemId,
      slotPosition: data.slotPosition.present
          ? data.slotPosition.value
          : this.slotPosition,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyMember(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('gachaItemId: $gachaItemId, ')
          ..write('slotPosition: $slotPosition, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deckId, gachaItemId, slotPosition, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyMember &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.gachaItemId == this.gachaItemId &&
          other.slotPosition == this.slotPosition &&
          other.createdAt == this.createdAt);
}

class PartyMembersCompanion extends UpdateCompanion<PartyMember> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<int> gachaItemId;
  final Value<int> slotPosition;
  final Value<DateTime> createdAt;
  const PartyMembersCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.gachaItemId = const Value.absent(),
    this.slotPosition = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PartyMembersCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required int gachaItemId,
    required int slotPosition,
    this.createdAt = const Value.absent(),
  }) : deckId = Value(deckId),
       gachaItemId = Value(gachaItemId),
       slotPosition = Value(slotPosition);
  static Insertable<PartyMember> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<int>? gachaItemId,
    Expression<int>? slotPosition,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (gachaItemId != null) 'gacha_item_id': gachaItemId,
      if (slotPosition != null) 'slot_position': slotPosition,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PartyMembersCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<int>? gachaItemId,
    Value<int>? slotPosition,
    Value<DateTime>? createdAt,
  }) {
    return PartyMembersCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      gachaItemId: gachaItemId ?? this.gachaItemId,
      slotPosition: slotPosition ?? this.slotPosition,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (gachaItemId.present) {
      map['gacha_item_id'] = Variable<int>(gachaItemId.value);
    }
    if (slotPosition.present) {
      map['slot_position'] = Variable<int>(slotPosition.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyMembersCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('gachaItemId: $gachaItemId, ')
          ..write('slotPosition: $slotPosition, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _isProMeta = const VerificationMeta('isPro');
  @override
  late final GeneratedColumn<bool> isPro = GeneratedColumn<bool>(
    'is_pro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _maxHabitsMeta = const VerificationMeta(
    'maxHabits',
  );
  @override
  late final GeneratedColumn<int> maxHabits = GeneratedColumn<int>(
    'max_habits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _maxGachaItemsMeta = const VerificationMeta(
    'maxGachaItems',
  );
  @override
  late final GeneratedColumn<int> maxGachaItems = GeneratedColumn<int>(
    'max_gacha_items',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _maxDecksMeta = const VerificationMeta(
    'maxDecks',
  );
  @override
  late final GeneratedColumn<int> maxDecks = GeneratedColumn<int>(
    'max_decks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeColorMeta = const VerificationMeta(
    'themeColor',
  );
  @override
  late final GeneratedColumn<String> themeColor = GeneratedColumn<String>(
    'theme_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showEffectMeta = const VerificationMeta(
    'showEffect',
  );
  @override
  late final GeneratedColumn<bool> showEffect = GeneratedColumn<bool>(
    'show_effect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_effect" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showMainFrameMeta = const VerificationMeta(
    'showMainFrame',
  );
  @override
  late final GeneratedColumn<bool> showMainFrame = GeneratedColumn<bool>(
    'show_main_frame',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_main_frame" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isPro,
    maxHabits,
    maxGachaItems,
    maxDecks,
    themeColor,
    showEffect,
    showMainFrame,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('is_pro')) {
      context.handle(
        _isProMeta,
        isPro.isAcceptableOrUnknown(data['is_pro']!, _isProMeta),
      );
    }
    if (data.containsKey('max_habits')) {
      context.handle(
        _maxHabitsMeta,
        maxHabits.isAcceptableOrUnknown(data['max_habits']!, _maxHabitsMeta),
      );
    }
    if (data.containsKey('max_gacha_items')) {
      context.handle(
        _maxGachaItemsMeta,
        maxGachaItems.isAcceptableOrUnknown(
          data['max_gacha_items']!,
          _maxGachaItemsMeta,
        ),
      );
    }
    if (data.containsKey('max_decks')) {
      context.handle(
        _maxDecksMeta,
        maxDecks.isAcceptableOrUnknown(data['max_decks']!, _maxDecksMeta),
      );
    }
    if (data.containsKey('theme_color')) {
      context.handle(
        _themeColorMeta,
        themeColor.isAcceptableOrUnknown(data['theme_color']!, _themeColorMeta),
      );
    }
    if (data.containsKey('show_effect')) {
      context.handle(
        _showEffectMeta,
        showEffect.isAcceptableOrUnknown(data['show_effect']!, _showEffectMeta),
      );
    }
    if (data.containsKey('show_main_frame')) {
      context.handle(
        _showMainFrameMeta,
        showMainFrame.isAcceptableOrUnknown(
          data['show_main_frame']!,
          _showMainFrameMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isPro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pro'],
      )!,
      maxHabits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_habits'],
      )!,
      maxGachaItems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_gacha_items'],
      )!,
      maxDecks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_decks'],
      )!,
      themeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_color'],
      ),
      showEffect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_effect'],
      )!,
      showMainFrame: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_main_frame'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingsData extends DataClass
    implements Insertable<UserSettingsData> {
  final int id;
  final bool isPro;
  final int maxHabits;
  final int maxGachaItems;
  final int maxDecks;
  final String? themeColor;
  final bool showEffect;
  final bool showMainFrame;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserSettingsData({
    required this.id,
    required this.isPro,
    required this.maxHabits,
    required this.maxGachaItems,
    required this.maxDecks,
    this.themeColor,
    required this.showEffect,
    required this.showMainFrame,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_pro'] = Variable<bool>(isPro);
    map['max_habits'] = Variable<int>(maxHabits);
    map['max_gacha_items'] = Variable<int>(maxGachaItems);
    map['max_decks'] = Variable<int>(maxDecks);
    if (!nullToAbsent || themeColor != null) {
      map['theme_color'] = Variable<String>(themeColor);
    }
    map['show_effect'] = Variable<bool>(showEffect);
    map['show_main_frame'] = Variable<bool>(showMainFrame);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      isPro: Value(isPro),
      maxHabits: Value(maxHabits),
      maxGachaItems: Value(maxGachaItems),
      maxDecks: Value(maxDecks),
      themeColor: themeColor == null && nullToAbsent
          ? const Value.absent()
          : Value(themeColor),
      showEffect: Value(showEffect),
      showMainFrame: Value(showMainFrame),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsData(
      id: serializer.fromJson<int>(json['id']),
      isPro: serializer.fromJson<bool>(json['isPro']),
      maxHabits: serializer.fromJson<int>(json['maxHabits']),
      maxGachaItems: serializer.fromJson<int>(json['maxGachaItems']),
      maxDecks: serializer.fromJson<int>(json['maxDecks']),
      themeColor: serializer.fromJson<String?>(json['themeColor']),
      showEffect: serializer.fromJson<bool>(json['showEffect']),
      showMainFrame: serializer.fromJson<bool>(json['showMainFrame']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isPro': serializer.toJson<bool>(isPro),
      'maxHabits': serializer.toJson<int>(maxHabits),
      'maxGachaItems': serializer.toJson<int>(maxGachaItems),
      'maxDecks': serializer.toJson<int>(maxDecks),
      'themeColor': serializer.toJson<String?>(themeColor),
      'showEffect': serializer.toJson<bool>(showEffect),
      'showMainFrame': serializer.toJson<bool>(showMainFrame),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsData copyWith({
    int? id,
    bool? isPro,
    int? maxHabits,
    int? maxGachaItems,
    int? maxDecks,
    Value<String?> themeColor = const Value.absent(),
    bool? showEffect,
    bool? showMainFrame,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserSettingsData(
    id: id ?? this.id,
    isPro: isPro ?? this.isPro,
    maxHabits: maxHabits ?? this.maxHabits,
    maxGachaItems: maxGachaItems ?? this.maxGachaItems,
    maxDecks: maxDecks ?? this.maxDecks,
    themeColor: themeColor.present ? themeColor.value : this.themeColor,
    showEffect: showEffect ?? this.showEffect,
    showMainFrame: showMainFrame ?? this.showMainFrame,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSettingsData copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingsData(
      id: data.id.present ? data.id.value : this.id,
      isPro: data.isPro.present ? data.isPro.value : this.isPro,
      maxHabits: data.maxHabits.present ? data.maxHabits.value : this.maxHabits,
      maxGachaItems: data.maxGachaItems.present
          ? data.maxGachaItems.value
          : this.maxGachaItems,
      maxDecks: data.maxDecks.present ? data.maxDecks.value : this.maxDecks,
      themeColor: data.themeColor.present
          ? data.themeColor.value
          : this.themeColor,
      showEffect: data.showEffect.present
          ? data.showEffect.value
          : this.showEffect,
      showMainFrame: data.showMainFrame.present
          ? data.showMainFrame.value
          : this.showMainFrame,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsData(')
          ..write('id: $id, ')
          ..write('isPro: $isPro, ')
          ..write('maxHabits: $maxHabits, ')
          ..write('maxGachaItems: $maxGachaItems, ')
          ..write('maxDecks: $maxDecks, ')
          ..write('themeColor: $themeColor, ')
          ..write('showEffect: $showEffect, ')
          ..write('showMainFrame: $showMainFrame, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    isPro,
    maxHabits,
    maxGachaItems,
    maxDecks,
    themeColor,
    showEffect,
    showMainFrame,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsData &&
          other.id == this.id &&
          other.isPro == this.isPro &&
          other.maxHabits == this.maxHabits &&
          other.maxGachaItems == this.maxGachaItems &&
          other.maxDecks == this.maxDecks &&
          other.themeColor == this.themeColor &&
          other.showEffect == this.showEffect &&
          other.showMainFrame == this.showMainFrame &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingsData> {
  final Value<int> id;
  final Value<bool> isPro;
  final Value<int> maxHabits;
  final Value<int> maxGachaItems;
  final Value<int> maxDecks;
  final Value<String?> themeColor;
  final Value<bool> showEffect;
  final Value<bool> showMainFrame;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.isPro = const Value.absent(),
    this.maxHabits = const Value.absent(),
    this.maxGachaItems = const Value.absent(),
    this.maxDecks = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.showEffect = const Value.absent(),
    this.showMainFrame = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.isPro = const Value.absent(),
    this.maxHabits = const Value.absent(),
    this.maxGachaItems = const Value.absent(),
    this.maxDecks = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.showEffect = const Value.absent(),
    this.showMainFrame = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserSettingsData> custom({
    Expression<int>? id,
    Expression<bool>? isPro,
    Expression<int>? maxHabits,
    Expression<int>? maxGachaItems,
    Expression<int>? maxDecks,
    Expression<String>? themeColor,
    Expression<bool>? showEffect,
    Expression<bool>? showMainFrame,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isPro != null) 'is_pro': isPro,
      if (maxHabits != null) 'max_habits': maxHabits,
      if (maxGachaItems != null) 'max_gacha_items': maxGachaItems,
      if (maxDecks != null) 'max_decks': maxDecks,
      if (themeColor != null) 'theme_color': themeColor,
      if (showEffect != null) 'show_effect': showEffect,
      if (showMainFrame != null) 'show_main_frame': showMainFrame,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? isPro,
    Value<int>? maxHabits,
    Value<int>? maxGachaItems,
    Value<int>? maxDecks,
    Value<String?>? themeColor,
    Value<bool>? showEffect,
    Value<bool>? showMainFrame,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      isPro: isPro ?? this.isPro,
      maxHabits: maxHabits ?? this.maxHabits,
      maxGachaItems: maxGachaItems ?? this.maxGachaItems,
      maxDecks: maxDecks ?? this.maxDecks,
      themeColor: themeColor ?? this.themeColor,
      showEffect: showEffect ?? this.showEffect,
      showMainFrame: showMainFrame ?? this.showMainFrame,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isPro.present) {
      map['is_pro'] = Variable<bool>(isPro.value);
    }
    if (maxHabits.present) {
      map['max_habits'] = Variable<int>(maxHabits.value);
    }
    if (maxGachaItems.present) {
      map['max_gacha_items'] = Variable<int>(maxGachaItems.value);
    }
    if (maxDecks.present) {
      map['max_decks'] = Variable<int>(maxDecks.value);
    }
    if (themeColor.present) {
      map['theme_color'] = Variable<String>(themeColor.value);
    }
    if (showEffect.present) {
      map['show_effect'] = Variable<bool>(showEffect.value);
    }
    if (showMainFrame.present) {
      map['show_main_frame'] = Variable<bool>(showMainFrame.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('isPro: $isPro, ')
          ..write('maxHabits: $maxHabits, ')
          ..write('maxGachaItems: $maxGachaItems, ')
          ..write('maxDecks: $maxDecks, ')
          ..write('themeColor: $themeColor, ')
          ..write('showEffect: $showEffect, ')
          ..write('showMainFrame: $showMainFrame, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BossResultsTable extends BossResults
    with TableInfo<$BossResultsTable, BossResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BossResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BossType, int> bossType =
      GeneratedColumn<int>(
        'boss_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<BossType>($BossResultsTable.$converterbossType);
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isWinMeta = const VerificationMeta('isWin');
  @override
  late final GeneratedColumn<bool> isWin = GeneratedColumn<bool>(
    'is_win',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_win" IN (0, 1))',
    ),
  );
  static const VerificationMeta _playerPowerMeta = const VerificationMeta(
    'playerPower',
  );
  @override
  late final GeneratedColumn<int> playerPower = GeneratedColumn<int>(
    'player_power',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossPowerMeta = const VerificationMeta(
    'bossPower',
  );
  @override
  late final GeneratedColumn<int> bossPower = GeneratedColumn<int>(
    'boss_power',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _battledAtMeta = const VerificationMeta(
    'battledAt',
  );
  @override
  late final GeneratedColumn<DateTime> battledAt = GeneratedColumn<DateTime>(
    'battled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bossType,
    periodKey,
    isWin,
    playerPower,
    bossPower,
    battledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boss_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<BossResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('is_win')) {
      context.handle(
        _isWinMeta,
        isWin.isAcceptableOrUnknown(data['is_win']!, _isWinMeta),
      );
    } else if (isInserting) {
      context.missing(_isWinMeta);
    }
    if (data.containsKey('player_power')) {
      context.handle(
        _playerPowerMeta,
        playerPower.isAcceptableOrUnknown(
          data['player_power']!,
          _playerPowerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playerPowerMeta);
    }
    if (data.containsKey('boss_power')) {
      context.handle(
        _bossPowerMeta,
        bossPower.isAcceptableOrUnknown(data['boss_power']!, _bossPowerMeta),
      );
    } else if (isInserting) {
      context.missing(_bossPowerMeta);
    }
    if (data.containsKey('battled_at')) {
      context.handle(
        _battledAtMeta,
        battledAt.isAcceptableOrUnknown(data['battled_at']!, _battledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BossResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BossResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bossType: $BossResultsTable.$converterbossType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}boss_type'],
        )!,
      ),
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      isWin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_win'],
      )!,
      playerPower: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_power'],
      )!,
      bossPower: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boss_power'],
      )!,
      battledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}battled_at'],
      )!,
    );
  }

  @override
  $BossResultsTable createAlias(String alias) {
    return $BossResultsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BossType, int, int> $converterbossType =
      const EnumIndexConverter<BossType>(BossType.values);
}

class BossResult extends DataClass implements Insertable<BossResult> {
  final int id;
  final BossType bossType;
  final String periodKey;
  final bool isWin;
  final int playerPower;
  final int bossPower;
  final DateTime battledAt;
  const BossResult({
    required this.id,
    required this.bossType,
    required this.periodKey,
    required this.isWin,
    required this.playerPower,
    required this.bossPower,
    required this.battledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['boss_type'] = Variable<int>(
        $BossResultsTable.$converterbossType.toSql(bossType),
      );
    }
    map['period_key'] = Variable<String>(periodKey);
    map['is_win'] = Variable<bool>(isWin);
    map['player_power'] = Variable<int>(playerPower);
    map['boss_power'] = Variable<int>(bossPower);
    map['battled_at'] = Variable<DateTime>(battledAt);
    return map;
  }

  BossResultsCompanion toCompanion(bool nullToAbsent) {
    return BossResultsCompanion(
      id: Value(id),
      bossType: Value(bossType),
      periodKey: Value(periodKey),
      isWin: Value(isWin),
      playerPower: Value(playerPower),
      bossPower: Value(bossPower),
      battledAt: Value(battledAt),
    );
  }

  factory BossResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BossResult(
      id: serializer.fromJson<int>(json['id']),
      bossType: $BossResultsTable.$converterbossType.fromJson(
        serializer.fromJson<int>(json['bossType']),
      ),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      isWin: serializer.fromJson<bool>(json['isWin']),
      playerPower: serializer.fromJson<int>(json['playerPower']),
      bossPower: serializer.fromJson<int>(json['bossPower']),
      battledAt: serializer.fromJson<DateTime>(json['battledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bossType': serializer.toJson<int>(
        $BossResultsTable.$converterbossType.toJson(bossType),
      ),
      'periodKey': serializer.toJson<String>(periodKey),
      'isWin': serializer.toJson<bool>(isWin),
      'playerPower': serializer.toJson<int>(playerPower),
      'bossPower': serializer.toJson<int>(bossPower),
      'battledAt': serializer.toJson<DateTime>(battledAt),
    };
  }

  BossResult copyWith({
    int? id,
    BossType? bossType,
    String? periodKey,
    bool? isWin,
    int? playerPower,
    int? bossPower,
    DateTime? battledAt,
  }) => BossResult(
    id: id ?? this.id,
    bossType: bossType ?? this.bossType,
    periodKey: periodKey ?? this.periodKey,
    isWin: isWin ?? this.isWin,
    playerPower: playerPower ?? this.playerPower,
    bossPower: bossPower ?? this.bossPower,
    battledAt: battledAt ?? this.battledAt,
  );
  BossResult copyWithCompanion(BossResultsCompanion data) {
    return BossResult(
      id: data.id.present ? data.id.value : this.id,
      bossType: data.bossType.present ? data.bossType.value : this.bossType,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      isWin: data.isWin.present ? data.isWin.value : this.isWin,
      playerPower: data.playerPower.present
          ? data.playerPower.value
          : this.playerPower,
      bossPower: data.bossPower.present ? data.bossPower.value : this.bossPower,
      battledAt: data.battledAt.present ? data.battledAt.value : this.battledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BossResult(')
          ..write('id: $id, ')
          ..write('bossType: $bossType, ')
          ..write('periodKey: $periodKey, ')
          ..write('isWin: $isWin, ')
          ..write('playerPower: $playerPower, ')
          ..write('bossPower: $bossPower, ')
          ..write('battledAt: $battledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bossType,
    periodKey,
    isWin,
    playerPower,
    bossPower,
    battledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BossResult &&
          other.id == this.id &&
          other.bossType == this.bossType &&
          other.periodKey == this.periodKey &&
          other.isWin == this.isWin &&
          other.playerPower == this.playerPower &&
          other.bossPower == this.bossPower &&
          other.battledAt == this.battledAt);
}

class BossResultsCompanion extends UpdateCompanion<BossResult> {
  final Value<int> id;
  final Value<BossType> bossType;
  final Value<String> periodKey;
  final Value<bool> isWin;
  final Value<int> playerPower;
  final Value<int> bossPower;
  final Value<DateTime> battledAt;
  const BossResultsCompanion({
    this.id = const Value.absent(),
    this.bossType = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.isWin = const Value.absent(),
    this.playerPower = const Value.absent(),
    this.bossPower = const Value.absent(),
    this.battledAt = const Value.absent(),
  });
  BossResultsCompanion.insert({
    this.id = const Value.absent(),
    required BossType bossType,
    required String periodKey,
    required bool isWin,
    required int playerPower,
    required int bossPower,
    this.battledAt = const Value.absent(),
  }) : bossType = Value(bossType),
       periodKey = Value(periodKey),
       isWin = Value(isWin),
       playerPower = Value(playerPower),
       bossPower = Value(bossPower);
  static Insertable<BossResult> custom({
    Expression<int>? id,
    Expression<int>? bossType,
    Expression<String>? periodKey,
    Expression<bool>? isWin,
    Expression<int>? playerPower,
    Expression<int>? bossPower,
    Expression<DateTime>? battledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bossType != null) 'boss_type': bossType,
      if (periodKey != null) 'period_key': periodKey,
      if (isWin != null) 'is_win': isWin,
      if (playerPower != null) 'player_power': playerPower,
      if (bossPower != null) 'boss_power': bossPower,
      if (battledAt != null) 'battled_at': battledAt,
    });
  }

  BossResultsCompanion copyWith({
    Value<int>? id,
    Value<BossType>? bossType,
    Value<String>? periodKey,
    Value<bool>? isWin,
    Value<int>? playerPower,
    Value<int>? bossPower,
    Value<DateTime>? battledAt,
  }) {
    return BossResultsCompanion(
      id: id ?? this.id,
      bossType: bossType ?? this.bossType,
      periodKey: periodKey ?? this.periodKey,
      isWin: isWin ?? this.isWin,
      playerPower: playerPower ?? this.playerPower,
      bossPower: bossPower ?? this.bossPower,
      battledAt: battledAt ?? this.battledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bossType.present) {
      map['boss_type'] = Variable<int>(
        $BossResultsTable.$converterbossType.toSql(bossType.value),
      );
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (isWin.present) {
      map['is_win'] = Variable<bool>(isWin.value);
    }
    if (playerPower.present) {
      map['player_power'] = Variable<int>(playerPower.value);
    }
    if (bossPower.present) {
      map['boss_power'] = Variable<int>(bossPower.value);
    }
    if (battledAt.present) {
      map['battled_at'] = Variable<DateTime>(battledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BossResultsCompanion(')
          ..write('id: $id, ')
          ..write('bossType: $bossType, ')
          ..write('periodKey: $periodKey, ')
          ..write('isWin: $isWin, ')
          ..write('playerPower: $playerPower, ')
          ..write('bossPower: $bossPower, ')
          ..write('battledAt: $battledAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GachaItemsTable gachaItems = $GachaItemsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $TitlesTable titles = $TitlesTable(this);
  late final $PartyDecksTable partyDecks = $PartyDecksTable(this);
  late final $PartyMembersTable partyMembers = $PartyMembersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $BossResultsTable bossResults = $BossResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    gachaItems,
    habits,
    titles,
    partyDecks,
    partyMembers,
    userSettings,
    bossResults,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'party_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('party_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gacha_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('party_members', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<int> level,
      Value<int> experience,
      Value<int> str,
      Value<int> intellect,
      Value<int> luck,
      Value<int> cha,
      Value<int> vit,
      Value<int> willGems,
      Value<String?> currentDebuff,
      Value<DateTime?> debuffExpiresAt,
      Value<DateTime> lastLoginAt,
      Value<SkillType?> activeSkillType,
      Value<int?> activeSkillValue,
      Value<DateTime?> skillExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<int> level,
      Value<int> experience,
      Value<int> str,
      Value<int> intellect,
      Value<int> luck,
      Value<int> cha,
      Value<int> vit,
      Value<int> willGems,
      Value<String?> currentDebuff,
      Value<DateTime?> debuffExpiresAt,
      Value<DateTime> lastLoginAt,
      Value<SkillType?> activeSkillType,
      Value<int?> activeSkillValue,
      Value<DateTime?> skillExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
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

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get str => $composableBuilder(
    column: $table.str,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intellect => $composableBuilder(
    column: $table.intellect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get luck => $composableBuilder(
    column: $table.luck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cha => $composableBuilder(
    column: $table.cha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vit => $composableBuilder(
    column: $table.vit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get willGems => $composableBuilder(
    column: $table.willGems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentDebuff => $composableBuilder(
    column: $table.currentDebuff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get debuffExpiresAt => $composableBuilder(
    column: $table.debuffExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SkillType?, SkillType, int>
  get activeSkillType => $composableBuilder(
    column: $table.activeSkillType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get activeSkillValue => $composableBuilder(
    column: $table.activeSkillValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get skillExpiresAt => $composableBuilder(
    column: $table.skillExpiresAt,
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
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
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

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get str => $composableBuilder(
    column: $table.str,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intellect => $composableBuilder(
    column: $table.intellect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get luck => $composableBuilder(
    column: $table.luck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cha => $composableBuilder(
    column: $table.cha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vit => $composableBuilder(
    column: $table.vit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get willGems => $composableBuilder(
    column: $table.willGems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentDebuff => $composableBuilder(
    column: $table.currentDebuff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get debuffExpiresAt => $composableBuilder(
    column: $table.debuffExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSkillType => $composableBuilder(
    column: $table.activeSkillType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSkillValue => $composableBuilder(
    column: $table.activeSkillValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get skillExpiresAt => $composableBuilder(
    column: $table.skillExpiresAt,
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
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => column,
  );

  GeneratedColumn<int> get str =>
      $composableBuilder(column: $table.str, builder: (column) => column);

  GeneratedColumn<int> get intellect =>
      $composableBuilder(column: $table.intellect, builder: (column) => column);

  GeneratedColumn<int> get luck =>
      $composableBuilder(column: $table.luck, builder: (column) => column);

  GeneratedColumn<int> get cha =>
      $composableBuilder(column: $table.cha, builder: (column) => column);

  GeneratedColumn<int> get vit =>
      $composableBuilder(column: $table.vit, builder: (column) => column);

  GeneratedColumn<int> get willGems =>
      $composableBuilder(column: $table.willGems, builder: (column) => column);

  GeneratedColumn<String> get currentDebuff => $composableBuilder(
    column: $table.currentDebuff,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get debuffExpiresAt => $composableBuilder(
    column: $table.debuffExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SkillType?, int> get activeSkillType =>
      $composableBuilder(
        column: $table.activeSkillType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get activeSkillValue => $composableBuilder(
    column: $table.activeSkillValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get skillExpiresAt => $composableBuilder(
    column: $table.skillExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
          Player,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> experience = const Value.absent(),
                Value<int> str = const Value.absent(),
                Value<int> intellect = const Value.absent(),
                Value<int> luck = const Value.absent(),
                Value<int> cha = const Value.absent(),
                Value<int> vit = const Value.absent(),
                Value<int> willGems = const Value.absent(),
                Value<String?> currentDebuff = const Value.absent(),
                Value<DateTime?> debuffExpiresAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
                Value<SkillType?> activeSkillType = const Value.absent(),
                Value<int?> activeSkillValue = const Value.absent(),
                Value<DateTime?> skillExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                level: level,
                experience: experience,
                str: str,
                intellect: intellect,
                luck: luck,
                cha: cha,
                vit: vit,
                willGems: willGems,
                currentDebuff: currentDebuff,
                debuffExpiresAt: debuffExpiresAt,
                lastLoginAt: lastLoginAt,
                activeSkillType: activeSkillType,
                activeSkillValue: activeSkillValue,
                skillExpiresAt: skillExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> experience = const Value.absent(),
                Value<int> str = const Value.absent(),
                Value<int> intellect = const Value.absent(),
                Value<int> luck = const Value.absent(),
                Value<int> cha = const Value.absent(),
                Value<int> vit = const Value.absent(),
                Value<int> willGems = const Value.absent(),
                Value<String?> currentDebuff = const Value.absent(),
                Value<DateTime?> debuffExpiresAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
                Value<SkillType?> activeSkillType = const Value.absent(),
                Value<int?> activeSkillValue = const Value.absent(),
                Value<DateTime?> skillExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                level: level,
                experience: experience,
                str: str,
                intellect: intellect,
                luck: luck,
                cha: cha,
                vit: vit,
                willGems: willGems,
                currentDebuff: currentDebuff,
                debuffExpiresAt: debuffExpiresAt,
                lastLoginAt: lastLoginAt,
                activeSkillType: activeSkillType,
                activeSkillValue: activeSkillValue,
                skillExpiresAt: skillExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
      Player,
      PrefetchHooks Function()
    >;
typedef $$GachaItemsTableCreateCompanionBuilder =
    GachaItemsCompanion Function({
      Value<int> id,
      required String imagePath,
      required String title,
      required EffectType effectType,
      Value<GachaItemType> type,
      Value<Rarity> rarity,
      Value<bool> isUnlocked,
      Value<int> strBonus,
      Value<int> intBonus,
      Value<int> luckBonus,
      Value<int> chaBonus,
      Value<int> vitBonus,
      Value<int> bondLevel,
      Value<SkillType> skillType,
      Value<int> skillValue,
      Value<int> skillDuration,
      Value<int> skillCooldown,
      Value<DateTime?> lastSkillUsedAt,
      Value<SeriesType> seriesId,
      Value<bool> isSource,
      Value<int?> sourceId,
      Value<DateTime> createdAt,
      Value<DateTime?> unlockedAt,
      Value<bool> isFavorite,
    });
typedef $$GachaItemsTableUpdateCompanionBuilder =
    GachaItemsCompanion Function({
      Value<int> id,
      Value<String> imagePath,
      Value<String> title,
      Value<EffectType> effectType,
      Value<GachaItemType> type,
      Value<Rarity> rarity,
      Value<bool> isUnlocked,
      Value<int> strBonus,
      Value<int> intBonus,
      Value<int> luckBonus,
      Value<int> chaBonus,
      Value<int> vitBonus,
      Value<int> bondLevel,
      Value<SkillType> skillType,
      Value<int> skillValue,
      Value<int> skillDuration,
      Value<int> skillCooldown,
      Value<DateTime?> lastSkillUsedAt,
      Value<SeriesType> seriesId,
      Value<bool> isSource,
      Value<int?> sourceId,
      Value<DateTime> createdAt,
      Value<DateTime?> unlockedAt,
      Value<bool> isFavorite,
    });

final class $$GachaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $GachaItemsTable, GachaItem> {
  $$GachaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartyDecksTable, List<PartyDeck>>
  _partyDecksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partyDecks,
    aliasName: $_aliasNameGenerator(
      db.gachaItems.id,
      db.partyDecks.equippedFrameId,
    ),
  );

  $$PartyDecksTableProcessedTableManager get partyDecksRefs {
    final manager = $$PartyDecksTableTableManager(
      $_db,
      $_db.partyDecks,
    ).filter((f) => f.equippedFrameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partyDecksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PartyMembersTable, List<PartyMember>>
  _partyMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partyMembers,
    aliasName: $_aliasNameGenerator(
      db.gachaItems.id,
      db.partyMembers.gachaItemId,
    ),
  );

  $$PartyMembersTableProcessedTableManager get partyMembersRefs {
    final manager = $$PartyMembersTableTableManager(
      $_db,
      $_db.partyMembers,
    ).filter((f) => f.gachaItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partyMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GachaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $GachaItemsTable> {
  $$GachaItemsTableFilterComposer({
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

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EffectType, EffectType, int> get effectType =>
      $composableBuilder(
        column: $table.effectType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GachaItemType, GachaItemType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Rarity, Rarity, int> get rarity =>
      $composableBuilder(
        column: $table.rarity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strBonus => $composableBuilder(
    column: $table.strBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intBonus => $composableBuilder(
    column: $table.intBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get luckBonus => $composableBuilder(
    column: $table.luckBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chaBonus => $composableBuilder(
    column: $table.chaBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vitBonus => $composableBuilder(
    column: $table.vitBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bondLevel => $composableBuilder(
    column: $table.bondLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SkillType, SkillType, int> get skillType =>
      $composableBuilder(
        column: $table.skillType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get skillValue => $composableBuilder(
    column: $table.skillValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skillDuration => $composableBuilder(
    column: $table.skillDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skillCooldown => $composableBuilder(
    column: $table.skillCooldown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSkillUsedAt => $composableBuilder(
    column: $table.lastSkillUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SeriesType, SeriesType, int> get seriesId =>
      $composableBuilder(
        column: $table.seriesId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isSource => $composableBuilder(
    column: $table.isSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> partyDecksRefs(
    Expression<bool> Function($$PartyDecksTableFilterComposer f) f,
  ) {
    final $$PartyDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyDecks,
      getReferencedColumn: (t) => t.equippedFrameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyDecksTableFilterComposer(
            $db: $db,
            $table: $db.partyDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partyMembersRefs(
    Expression<bool> Function($$PartyMembersTableFilterComposer f) f,
  ) {
    final $$PartyMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyMembers,
      getReferencedColumn: (t) => t.gachaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyMembersTableFilterComposer(
            $db: $db,
            $table: $db.partyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GachaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $GachaItemsTable> {
  $$GachaItemsTableOrderingComposer({
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

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectType => $composableBuilder(
    column: $table.effectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strBonus => $composableBuilder(
    column: $table.strBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intBonus => $composableBuilder(
    column: $table.intBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get luckBonus => $composableBuilder(
    column: $table.luckBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chaBonus => $composableBuilder(
    column: $table.chaBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vitBonus => $composableBuilder(
    column: $table.vitBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bondLevel => $composableBuilder(
    column: $table.bondLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillType => $composableBuilder(
    column: $table.skillType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillValue => $composableBuilder(
    column: $table.skillValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillDuration => $composableBuilder(
    column: $table.skillDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillCooldown => $composableBuilder(
    column: $table.skillCooldown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSkillUsedAt => $composableBuilder(
    column: $table.lastSkillUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSource => $composableBuilder(
    column: $table.isSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GachaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GachaItemsTable> {
  $$GachaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EffectType, int> get effectType =>
      $composableBuilder(
        column: $table.effectType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<GachaItemType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Rarity, int> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get strBonus =>
      $composableBuilder(column: $table.strBonus, builder: (column) => column);

  GeneratedColumn<int> get intBonus =>
      $composableBuilder(column: $table.intBonus, builder: (column) => column);

  GeneratedColumn<int> get luckBonus =>
      $composableBuilder(column: $table.luckBonus, builder: (column) => column);

  GeneratedColumn<int> get chaBonus =>
      $composableBuilder(column: $table.chaBonus, builder: (column) => column);

  GeneratedColumn<int> get vitBonus =>
      $composableBuilder(column: $table.vitBonus, builder: (column) => column);

  GeneratedColumn<int> get bondLevel =>
      $composableBuilder(column: $table.bondLevel, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SkillType, int> get skillType =>
      $composableBuilder(column: $table.skillType, builder: (column) => column);

  GeneratedColumn<int> get skillValue => $composableBuilder(
    column: $table.skillValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skillDuration => $composableBuilder(
    column: $table.skillDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skillCooldown => $composableBuilder(
    column: $table.skillCooldown,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSkillUsedAt => $composableBuilder(
    column: $table.lastSkillUsedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SeriesType, int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<bool> get isSource =>
      $composableBuilder(column: $table.isSource, builder: (column) => column);

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  Expression<T> partyDecksRefs<T extends Object>(
    Expression<T> Function($$PartyDecksTableAnnotationComposer a) f,
  ) {
    final $$PartyDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyDecks,
      getReferencedColumn: (t) => t.equippedFrameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.partyDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partyMembersRefs<T extends Object>(
    Expression<T> Function($$PartyMembersTableAnnotationComposer a) f,
  ) {
    final $$PartyMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyMembers,
      getReferencedColumn: (t) => t.gachaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.partyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GachaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GachaItemsTable,
          GachaItem,
          $$GachaItemsTableFilterComposer,
          $$GachaItemsTableOrderingComposer,
          $$GachaItemsTableAnnotationComposer,
          $$GachaItemsTableCreateCompanionBuilder,
          $$GachaItemsTableUpdateCompanionBuilder,
          (GachaItem, $$GachaItemsTableReferences),
          GachaItem,
          PrefetchHooks Function({bool partyDecksRefs, bool partyMembersRefs})
        > {
  $$GachaItemsTableTableManager(_$AppDatabase db, $GachaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GachaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GachaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GachaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<EffectType> effectType = const Value.absent(),
                Value<GachaItemType> type = const Value.absent(),
                Value<Rarity> rarity = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<int> strBonus = const Value.absent(),
                Value<int> intBonus = const Value.absent(),
                Value<int> luckBonus = const Value.absent(),
                Value<int> chaBonus = const Value.absent(),
                Value<int> vitBonus = const Value.absent(),
                Value<int> bondLevel = const Value.absent(),
                Value<SkillType> skillType = const Value.absent(),
                Value<int> skillValue = const Value.absent(),
                Value<int> skillDuration = const Value.absent(),
                Value<int> skillCooldown = const Value.absent(),
                Value<DateTime?> lastSkillUsedAt = const Value.absent(),
                Value<SeriesType> seriesId = const Value.absent(),
                Value<bool> isSource = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => GachaItemsCompanion(
                id: id,
                imagePath: imagePath,
                title: title,
                effectType: effectType,
                type: type,
                rarity: rarity,
                isUnlocked: isUnlocked,
                strBonus: strBonus,
                intBonus: intBonus,
                luckBonus: luckBonus,
                chaBonus: chaBonus,
                vitBonus: vitBonus,
                bondLevel: bondLevel,
                skillType: skillType,
                skillValue: skillValue,
                skillDuration: skillDuration,
                skillCooldown: skillCooldown,
                lastSkillUsedAt: lastSkillUsedAt,
                seriesId: seriesId,
                isSource: isSource,
                sourceId: sourceId,
                createdAt: createdAt,
                unlockedAt: unlockedAt,
                isFavorite: isFavorite,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imagePath,
                required String title,
                required EffectType effectType,
                Value<GachaItemType> type = const Value.absent(),
                Value<Rarity> rarity = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<int> strBonus = const Value.absent(),
                Value<int> intBonus = const Value.absent(),
                Value<int> luckBonus = const Value.absent(),
                Value<int> chaBonus = const Value.absent(),
                Value<int> vitBonus = const Value.absent(),
                Value<int> bondLevel = const Value.absent(),
                Value<SkillType> skillType = const Value.absent(),
                Value<int> skillValue = const Value.absent(),
                Value<int> skillDuration = const Value.absent(),
                Value<int> skillCooldown = const Value.absent(),
                Value<DateTime?> lastSkillUsedAt = const Value.absent(),
                Value<SeriesType> seriesId = const Value.absent(),
                Value<bool> isSource = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => GachaItemsCompanion.insert(
                id: id,
                imagePath: imagePath,
                title: title,
                effectType: effectType,
                type: type,
                rarity: rarity,
                isUnlocked: isUnlocked,
                strBonus: strBonus,
                intBonus: intBonus,
                luckBonus: luckBonus,
                chaBonus: chaBonus,
                vitBonus: vitBonus,
                bondLevel: bondLevel,
                skillType: skillType,
                skillValue: skillValue,
                skillDuration: skillDuration,
                skillCooldown: skillCooldown,
                lastSkillUsedAt: lastSkillUsedAt,
                seriesId: seriesId,
                isSource: isSource,
                sourceId: sourceId,
                createdAt: createdAt,
                unlockedAt: unlockedAt,
                isFavorite: isFavorite,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GachaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({partyDecksRefs = false, partyMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partyDecksRefs) db.partyDecks,
                    if (partyMembersRefs) db.partyMembers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partyDecksRefs)
                        await $_getPrefetchedData<
                          GachaItem,
                          $GachaItemsTable,
                          PartyDeck
                        >(
                          currentTable: table,
                          referencedTable: $$GachaItemsTableReferences
                              ._partyDecksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GachaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).partyDecksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.equippedFrameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (partyMembersRefs)
                        await $_getPrefetchedData<
                          GachaItem,
                          $GachaItemsTable,
                          PartyMember
                        >(
                          currentTable: table,
                          referencedTable: $$GachaItemsTableReferences
                              ._partyMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GachaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).partyMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gachaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GachaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GachaItemsTable,
      GachaItem,
      $$GachaItemsTableFilterComposer,
      $$GachaItemsTableOrderingComposer,
      $$GachaItemsTableAnnotationComposer,
      $$GachaItemsTableCreateCompanionBuilder,
      $$GachaItemsTableUpdateCompanionBuilder,
      (GachaItem, $$GachaItemsTableReferences),
      GachaItem,
      PrefetchHooks Function({bool partyDecksRefs, bool partyMembersRefs})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      required TaskType taskType,
      Value<TaskDifficulty> difficulty,
      Value<int> rewardGems,
      Value<int> rewardXp,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<TaskType> taskType,
      Value<TaskDifficulty> difficulty,
      Value<int> rewardGems,
      Value<int> rewardXp,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskType, TaskType, int> get taskType =>
      $composableBuilder(
        column: $table.taskType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TaskDifficulty, TaskDifficulty, int>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get rewardGems => $composableBuilder(
    column: $table.rewardGems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
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
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardGems => $composableBuilder(
    column: $table.rewardGems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
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
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskType, int> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskDifficulty, int> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get rewardGems => $composableBuilder(
    column: $table.rewardGems,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TaskType> taskType = const Value.absent(),
                Value<TaskDifficulty> difficulty = const Value.absent(),
                Value<int> rewardGems = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                taskType: taskType,
                difficulty: difficulty,
                rewardGems: rewardGems,
                rewardXp: rewardXp,
                isCompleted: isCompleted,
                completedAt: completedAt,
                dueDate: dueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required TaskType taskType,
                Value<TaskDifficulty> difficulty = const Value.absent(),
                Value<int> rewardGems = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                taskType: taskType,
                difficulty: difficulty,
                rewardGems: rewardGems,
                rewardXp: rewardXp,
                isCompleted: isCompleted,
                completedAt: completedAt,
                dueDate: dueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$TitlesTableCreateCompanionBuilder =
    TitlesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<String?> passiveSkill,
      required String unlockConditionType,
      required String unlockConditionValue,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
      Value<DateTime> createdAt,
    });
typedef $$TitlesTableUpdateCompanionBuilder =
    TitlesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> passiveSkill,
      Value<String> unlockConditionType,
      Value<String> unlockConditionValue,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
      Value<DateTime> createdAt,
    });

class $$TitlesTableFilterComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passiveSkill => $composableBuilder(
    column: $table.passiveSkill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockConditionType => $composableBuilder(
    column: $table.unlockConditionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockConditionValue => $composableBuilder(
    column: $table.unlockConditionValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passiveSkill => $composableBuilder(
    column: $table.passiveSkill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockConditionType => $composableBuilder(
    column: $table.unlockConditionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockConditionValue => $composableBuilder(
    column: $table.unlockConditionValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passiveSkill => $composableBuilder(
    column: $table.passiveSkill,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockConditionType => $composableBuilder(
    column: $table.unlockConditionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockConditionValue => $composableBuilder(
    column: $table.unlockConditionValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TitlesTable,
          Title,
          $$TitlesTableFilterComposer,
          $$TitlesTableOrderingComposer,
          $$TitlesTableAnnotationComposer,
          $$TitlesTableCreateCompanionBuilder,
          $$TitlesTableUpdateCompanionBuilder,
          (Title, BaseReferences<_$AppDatabase, $TitlesTable, Title>),
          Title,
          PrefetchHooks Function()
        > {
  $$TitlesTableTableManager(_$AppDatabase db, $TitlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> passiveSkill = const Value.absent(),
                Value<String> unlockConditionType = const Value.absent(),
                Value<String> unlockConditionValue = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TitlesCompanion(
                id: id,
                name: name,
                description: description,
                passiveSkill: passiveSkill,
                unlockConditionType: unlockConditionType,
                unlockConditionValue: unlockConditionValue,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> passiveSkill = const Value.absent(),
                required String unlockConditionType,
                required String unlockConditionValue,
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TitlesCompanion.insert(
                id: id,
                name: name,
                description: description,
                passiveSkill: passiveSkill,
                unlockConditionType: unlockConditionType,
                unlockConditionValue: unlockConditionValue,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TitlesTable,
      Title,
      $$TitlesTableFilterComposer,
      $$TitlesTableOrderingComposer,
      $$TitlesTableAnnotationComposer,
      $$TitlesTableCreateCompanionBuilder,
      $$TitlesTableUpdateCompanionBuilder,
      (Title, BaseReferences<_$AppDatabase, $TitlesTable, Title>),
      Title,
      PrefetchHooks Function()
    >;
typedef $$PartyDecksTableCreateCompanionBuilder =
    PartyDecksCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
      Value<int?> equippedFrameId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$PartyDecksTableUpdateCompanionBuilder =
    PartyDecksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
      Value<int?> equippedFrameId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PartyDecksTableReferences
    extends BaseReferences<_$AppDatabase, $PartyDecksTable, PartyDeck> {
  $$PartyDecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GachaItemsTable _equippedFrameIdTable(_$AppDatabase db) =>
      db.gachaItems.createAlias(
        $_aliasNameGenerator(db.partyDecks.equippedFrameId, db.gachaItems.id),
      );

  $$GachaItemsTableProcessedTableManager? get equippedFrameId {
    final $_column = $_itemColumn<int>('equipped_frame_id');
    if ($_column == null) return null;
    final manager = $$GachaItemsTableTableManager(
      $_db,
      $_db.gachaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equippedFrameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PartyMembersTable, List<PartyMember>>
  _partyMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partyMembers,
    aliasName: $_aliasNameGenerator(db.partyDecks.id, db.partyMembers.deckId),
  );

  $$PartyMembersTableProcessedTableManager get partyMembersRefs {
    final manager = $$PartyMembersTableTableManager(
      $_db,
      $_db.partyMembers,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partyMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartyDecksTableFilterComposer
    extends Composer<_$AppDatabase, $PartyDecksTable> {
  $$PartyDecksTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  $$GachaItemsTableFilterComposer get equippedFrameId {
    final $$GachaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equippedFrameId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableFilterComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> partyMembersRefs(
    Expression<bool> Function($$PartyMembersTableFilterComposer f) f,
  ) {
    final $$PartyMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyMembers,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyMembersTableFilterComposer(
            $db: $db,
            $table: $db.partyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartyDecksTableOrderingComposer
    extends Composer<_$AppDatabase, $PartyDecksTable> {
  $$PartyDecksTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  $$GachaItemsTableOrderingComposer get equippedFrameId {
    final $$GachaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equippedFrameId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartyDecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartyDecksTable> {
  $$PartyDecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GachaItemsTableAnnotationComposer get equippedFrameId {
    final $$GachaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equippedFrameId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> partyMembersRefs<T extends Object>(
    Expression<T> Function($$PartyMembersTableAnnotationComposer a) f,
  ) {
    final $$PartyMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyMembers,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.partyMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartyDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartyDecksTable,
          PartyDeck,
          $$PartyDecksTableFilterComposer,
          $$PartyDecksTableOrderingComposer,
          $$PartyDecksTableAnnotationComposer,
          $$PartyDecksTableCreateCompanionBuilder,
          $$PartyDecksTableUpdateCompanionBuilder,
          (PartyDeck, $$PartyDecksTableReferences),
          PartyDeck,
          PrefetchHooks Function({bool equippedFrameId, bool partyMembersRefs})
        > {
  $$PartyDecksTableTableManager(_$AppDatabase db, $PartyDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartyDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartyDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartyDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> equippedFrameId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PartyDecksCompanion(
                id: id,
                name: name,
                isActive: isActive,
                equippedFrameId: equippedFrameId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<int?> equippedFrameId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PartyDecksCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
                equippedFrameId: equippedFrameId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartyDecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({equippedFrameId = false, partyMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partyMembersRefs) db.partyMembers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (equippedFrameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.equippedFrameId,
                                    referencedTable: $$PartyDecksTableReferences
                                        ._equippedFrameIdTable(db),
                                    referencedColumn:
                                        $$PartyDecksTableReferences
                                            ._equippedFrameIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partyMembersRefs)
                        await $_getPrefetchedData<
                          PartyDeck,
                          $PartyDecksTable,
                          PartyMember
                        >(
                          currentTable: table,
                          referencedTable: $$PartyDecksTableReferences
                              ._partyMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PartyDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).partyMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deckId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PartyDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartyDecksTable,
      PartyDeck,
      $$PartyDecksTableFilterComposer,
      $$PartyDecksTableOrderingComposer,
      $$PartyDecksTableAnnotationComposer,
      $$PartyDecksTableCreateCompanionBuilder,
      $$PartyDecksTableUpdateCompanionBuilder,
      (PartyDeck, $$PartyDecksTableReferences),
      PartyDeck,
      PrefetchHooks Function({bool equippedFrameId, bool partyMembersRefs})
    >;
typedef $$PartyMembersTableCreateCompanionBuilder =
    PartyMembersCompanion Function({
      Value<int> id,
      required int deckId,
      required int gachaItemId,
      required int slotPosition,
      Value<DateTime> createdAt,
    });
typedef $$PartyMembersTableUpdateCompanionBuilder =
    PartyMembersCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<int> gachaItemId,
      Value<int> slotPosition,
      Value<DateTime> createdAt,
    });

final class $$PartyMembersTableReferences
    extends BaseReferences<_$AppDatabase, $PartyMembersTable, PartyMember> {
  $$PartyMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartyDecksTable _deckIdTable(_$AppDatabase db) =>
      db.partyDecks.createAlias(
        $_aliasNameGenerator(db.partyMembers.deckId, db.partyDecks.id),
      );

  $$PartyDecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$PartyDecksTableTableManager(
      $_db,
      $_db.partyDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GachaItemsTable _gachaItemIdTable(_$AppDatabase db) =>
      db.gachaItems.createAlias(
        $_aliasNameGenerator(db.partyMembers.gachaItemId, db.gachaItems.id),
      );

  $$GachaItemsTableProcessedTableManager get gachaItemId {
    final $_column = $_itemColumn<int>('gacha_item_id')!;

    final manager = $$GachaItemsTableTableManager(
      $_db,
      $_db.gachaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gachaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PartyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableFilterComposer({
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

  ColumnFilters<int> get slotPosition => $composableBuilder(
    column: $table.slotPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PartyDecksTableFilterComposer get deckId {
    final $$PartyDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.partyDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyDecksTableFilterComposer(
            $db: $db,
            $table: $db.partyDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GachaItemsTableFilterComposer get gachaItemId {
    final $$GachaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gachaItemId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableFilterComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableOrderingComposer({
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

  ColumnOrderings<int> get slotPosition => $composableBuilder(
    column: $table.slotPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartyDecksTableOrderingComposer get deckId {
    final $$PartyDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.partyDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyDecksTableOrderingComposer(
            $db: $db,
            $table: $db.partyDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GachaItemsTableOrderingComposer get gachaItemId {
    final $$GachaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gachaItemId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotPosition => $composableBuilder(
    column: $table.slotPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PartyDecksTableAnnotationComposer get deckId {
    final $$PartyDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.partyDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartyDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.partyDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GachaItemsTableAnnotationComposer get gachaItemId {
    final $$GachaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gachaItemId,
      referencedTable: $db.gachaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GachaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.gachaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartyMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartyMembersTable,
          PartyMember,
          $$PartyMembersTableFilterComposer,
          $$PartyMembersTableOrderingComposer,
          $$PartyMembersTableAnnotationComposer,
          $$PartyMembersTableCreateCompanionBuilder,
          $$PartyMembersTableUpdateCompanionBuilder,
          (PartyMember, $$PartyMembersTableReferences),
          PartyMember,
          PrefetchHooks Function({bool deckId, bool gachaItemId})
        > {
  $$PartyMembersTableTableManager(_$AppDatabase db, $PartyMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<int> gachaItemId = const Value.absent(),
                Value<int> slotPosition = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartyMembersCompanion(
                id: id,
                deckId: deckId,
                gachaItemId: gachaItemId,
                slotPosition: slotPosition,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required int gachaItemId,
                required int slotPosition,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartyMembersCompanion.insert(
                id: id,
                deckId: deckId,
                gachaItemId: gachaItemId,
                slotPosition: slotPosition,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartyMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false, gachaItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$PartyMembersTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$PartyMembersTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (gachaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gachaItemId,
                                referencedTable: $$PartyMembersTableReferences
                                    ._gachaItemIdTable(db),
                                referencedColumn: $$PartyMembersTableReferences
                                    ._gachaItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PartyMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartyMembersTable,
      PartyMember,
      $$PartyMembersTableFilterComposer,
      $$PartyMembersTableOrderingComposer,
      $$PartyMembersTableAnnotationComposer,
      $$PartyMembersTableCreateCompanionBuilder,
      $$PartyMembersTableUpdateCompanionBuilder,
      (PartyMember, $$PartyMembersTableReferences),
      PartyMember,
      PrefetchHooks Function({bool deckId, bool gachaItemId})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<bool> isPro,
      Value<int> maxHabits,
      Value<int> maxGachaItems,
      Value<int> maxDecks,
      Value<String?> themeColor,
      Value<bool> showEffect,
      Value<bool> showMainFrame,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<bool> isPro,
      Value<int> maxHabits,
      Value<int> maxGachaItems,
      Value<int> maxDecks,
      Value<String?> themeColor,
      Value<bool> showEffect,
      Value<bool> showMainFrame,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<bool> get isPro => $composableBuilder(
    column: $table.isPro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHabits => $composableBuilder(
    column: $table.maxHabits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxGachaItems => $composableBuilder(
    column: $table.maxGachaItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxDecks => $composableBuilder(
    column: $table.maxDecks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showEffect => $composableBuilder(
    column: $table.showEffect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showMainFrame => $composableBuilder(
    column: $table.showMainFrame,
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
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get isPro => $composableBuilder(
    column: $table.isPro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHabits => $composableBuilder(
    column: $table.maxHabits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxGachaItems => $composableBuilder(
    column: $table.maxGachaItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxDecks => $composableBuilder(
    column: $table.maxDecks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showEffect => $composableBuilder(
    column: $table.showEffect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showMainFrame => $composableBuilder(
    column: $table.showMainFrame,
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
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isPro =>
      $composableBuilder(column: $table.isPro, builder: (column) => column);

  GeneratedColumn<int> get maxHabits =>
      $composableBuilder(column: $table.maxHabits, builder: (column) => column);

  GeneratedColumn<int> get maxGachaItems => $composableBuilder(
    column: $table.maxGachaItems,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxDecks =>
      $composableBuilder(column: $table.maxDecks, builder: (column) => column);

  GeneratedColumn<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showEffect => $composableBuilder(
    column: $table.showEffect,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showMainFrame => $composableBuilder(
    column: $table.showMainFrame,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSettingsData,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSettingsData,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsData>,
          ),
          UserSettingsData,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isPro = const Value.absent(),
                Value<int> maxHabits = const Value.absent(),
                Value<int> maxGachaItems = const Value.absent(),
                Value<int> maxDecks = const Value.absent(),
                Value<String?> themeColor = const Value.absent(),
                Value<bool> showEffect = const Value.absent(),
                Value<bool> showMainFrame = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                isPro: isPro,
                maxHabits: maxHabits,
                maxGachaItems: maxGachaItems,
                maxDecks: maxDecks,
                themeColor: themeColor,
                showEffect: showEffect,
                showMainFrame: showMainFrame,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isPro = const Value.absent(),
                Value<int> maxHabits = const Value.absent(),
                Value<int> maxGachaItems = const Value.absent(),
                Value<int> maxDecks = const Value.absent(),
                Value<String?> themeColor = const Value.absent(),
                Value<bool> showEffect = const Value.absent(),
                Value<bool> showMainFrame = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                isPro: isPro,
                maxHabits: maxHabits,
                maxGachaItems: maxGachaItems,
                maxDecks: maxDecks,
                themeColor: themeColor,
                showEffect: showEffect,
                showMainFrame: showMainFrame,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSettingsData,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSettingsData,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsData>,
      ),
      UserSettingsData,
      PrefetchHooks Function()
    >;
typedef $$BossResultsTableCreateCompanionBuilder =
    BossResultsCompanion Function({
      Value<int> id,
      required BossType bossType,
      required String periodKey,
      required bool isWin,
      required int playerPower,
      required int bossPower,
      Value<DateTime> battledAt,
    });
typedef $$BossResultsTableUpdateCompanionBuilder =
    BossResultsCompanion Function({
      Value<int> id,
      Value<BossType> bossType,
      Value<String> periodKey,
      Value<bool> isWin,
      Value<int> playerPower,
      Value<int> bossPower,
      Value<DateTime> battledAt,
    });

class $$BossResultsTableFilterComposer
    extends Composer<_$AppDatabase, $BossResultsTable> {
  $$BossResultsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<BossType, BossType, int> get bossType =>
      $composableBuilder(
        column: $table.bossType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWin => $composableBuilder(
    column: $table.isWin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerPower => $composableBuilder(
    column: $table.playerPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bossPower => $composableBuilder(
    column: $table.bossPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get battledAt => $composableBuilder(
    column: $table.battledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BossResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $BossResultsTable> {
  $$BossResultsTableOrderingComposer({
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

  ColumnOrderings<int> get bossType => $composableBuilder(
    column: $table.bossType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWin => $composableBuilder(
    column: $table.isWin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerPower => $composableBuilder(
    column: $table.playerPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bossPower => $composableBuilder(
    column: $table.bossPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get battledAt => $composableBuilder(
    column: $table.battledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BossResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BossResultsTable> {
  $$BossResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BossType, int> get bossType =>
      $composableBuilder(column: $table.bossType, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<bool> get isWin =>
      $composableBuilder(column: $table.isWin, builder: (column) => column);

  GeneratedColumn<int> get playerPower => $composableBuilder(
    column: $table.playerPower,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bossPower =>
      $composableBuilder(column: $table.bossPower, builder: (column) => column);

  GeneratedColumn<DateTime> get battledAt =>
      $composableBuilder(column: $table.battledAt, builder: (column) => column);
}

class $$BossResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BossResultsTable,
          BossResult,
          $$BossResultsTableFilterComposer,
          $$BossResultsTableOrderingComposer,
          $$BossResultsTableAnnotationComposer,
          $$BossResultsTableCreateCompanionBuilder,
          $$BossResultsTableUpdateCompanionBuilder,
          (
            BossResult,
            BaseReferences<_$AppDatabase, $BossResultsTable, BossResult>,
          ),
          BossResult,
          PrefetchHooks Function()
        > {
  $$BossResultsTableTableManager(_$AppDatabase db, $BossResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BossResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BossResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BossResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<BossType> bossType = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<bool> isWin = const Value.absent(),
                Value<int> playerPower = const Value.absent(),
                Value<int> bossPower = const Value.absent(),
                Value<DateTime> battledAt = const Value.absent(),
              }) => BossResultsCompanion(
                id: id,
                bossType: bossType,
                periodKey: periodKey,
                isWin: isWin,
                playerPower: playerPower,
                bossPower: bossPower,
                battledAt: battledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required BossType bossType,
                required String periodKey,
                required bool isWin,
                required int playerPower,
                required int bossPower,
                Value<DateTime> battledAt = const Value.absent(),
              }) => BossResultsCompanion.insert(
                id: id,
                bossType: bossType,
                periodKey: periodKey,
                isWin: isWin,
                playerPower: playerPower,
                bossPower: bossPower,
                battledAt: battledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BossResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BossResultsTable,
      BossResult,
      $$BossResultsTableFilterComposer,
      $$BossResultsTableOrderingComposer,
      $$BossResultsTableAnnotationComposer,
      $$BossResultsTableCreateCompanionBuilder,
      $$BossResultsTableUpdateCompanionBuilder,
      (
        BossResult,
        BaseReferences<_$AppDatabase, $BossResultsTable, BossResult>,
      ),
      BossResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GachaItemsTableTableManager get gachaItems =>
      $$GachaItemsTableTableManager(_db, _db.gachaItems);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db, _db.titles);
  $$PartyDecksTableTableManager get partyDecks =>
      $$PartyDecksTableTableManager(_db, _db.partyDecks);
  $$PartyMembersTableTableManager get partyMembers =>
      $$PartyMembersTableTableManager(_db, _db.partyMembers);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$BossResultsTableTableManager get bossResults =>
      $$BossResultsTableTableManager(_db, _db.bossResults);
}
