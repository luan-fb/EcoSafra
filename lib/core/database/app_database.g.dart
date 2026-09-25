// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedForecastsTable extends CachedForecasts
    with TableInfo<$CachedForecastsTable, CachedForecast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedForecastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _locationKeyMeta = const VerificationMeta(
    'locationKey',
  );
  @override
  late final GeneratedColumn<String> locationKey = GeneratedColumn<String>(
    'location_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [locationKey, payloadJson, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_forecasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedForecast> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('location_key')) {
      context.handle(
        _locationKeyMeta,
        locationKey.isAcceptableOrUnknown(
          data['location_key']!,
          _locationKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {locationKey};
  @override
  CachedForecast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedForecast(
      locationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedForecastsTable createAlias(String alias) {
    return $CachedForecastsTable(attachedDatabase, alias);
  }
}

class CachedForecast extends DataClass implements Insertable<CachedForecast> {
  final String locationKey;

  /// O `WeatherForecastModel` inteiro, serializado. Guardar o JSON pronto
  /// (em vez de uma coluna por variável meteorológica) é o que deixa este
  /// cache imune a mudanças na Open-Meteo: se amanhã ela adicionar uma
  /// variável nova, não precisamos de migration nenhuma pra continuar
  /// funcionando com o que já temos.
  final String payloadJson;
  final DateTime fetchedAt;
  const CachedForecast({
    required this.locationKey,
    required this.payloadJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['location_key'] = Variable<String>(locationKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedForecastsCompanion toCompanion(bool nullToAbsent) {
    return CachedForecastsCompanion(
      locationKey: Value(locationKey),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedForecast.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedForecast(
      locationKey: serializer.fromJson<String>(json['locationKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'locationKey': serializer.toJson<String>(locationKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedForecast copyWith({
    String? locationKey,
    String? payloadJson,
    DateTime? fetchedAt,
  }) => CachedForecast(
    locationKey: locationKey ?? this.locationKey,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedForecast copyWithCompanion(CachedForecastsCompanion data) {
    return CachedForecast(
      locationKey: data.locationKey.present
          ? data.locationKey.value
          : this.locationKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedForecast(')
          ..write('locationKey: $locationKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(locationKey, payloadJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedForecast &&
          other.locationKey == this.locationKey &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt);
}

class CachedForecastsCompanion extends UpdateCompanion<CachedForecast> {
  final Value<String> locationKey;
  final Value<String> payloadJson;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedForecastsCompanion({
    this.locationKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedForecastsCompanion.insert({
    required String locationKey,
    required String payloadJson,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : locationKey = Value(locationKey),
       payloadJson = Value(payloadJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedForecast> custom({
    Expression<String>? locationKey,
    Expression<String>? payloadJson,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (locationKey != null) 'location_key': locationKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedForecastsCompanion copyWith({
    Value<String>? locationKey,
    Value<String>? payloadJson,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedForecastsCompanion(
      locationKey: locationKey ?? this.locationKey,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (locationKey.present) {
      map['location_key'] = Variable<String>(locationKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedForecastsCompanion(')
          ..write('locationKey: $locationKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FertilizationSchedulesTable extends FertilizationSchedules
    with TableInfo<$FertilizationSchedulesTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FertilizationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    scheduledDate,
    note,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fertilization_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $FertilizationSchedulesTable createAlias(String alias) {
    return $FertilizationSchedulesTable(attachedDatabase, alias);
  }
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  /// UUID v4 gerado no aparelho: o id existe antes de chegar ao banco e não
  /// colide se um dia houver sincronização entre aparelhos.
  final String id;

  /// `uid` do Firebase Auth. Toda leitura e escrita filtra por ele.
  final String userId;

  /// Sempre à meia-noite local; só o dia importa.
  final DateTime scheduledDate;
  final String? note;
  final DateTime createdAt;

  /// `null` enquanto a aplicação não foi marcada como feita.
  final DateTime? completedAt;
  const ScheduleRow({
    required this.id,
    required this.userId,
    required this.scheduledDate,
    this.note,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  FertilizationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return FertilizationSchedulesCompanion(
      id: Value(id),
      userId: Value(userId),
      scheduledDate: Value(scheduledDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ScheduleRow copyWith({
    String? id,
    String? userId,
    DateTime? scheduledDate,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ScheduleRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ScheduleRow copyWithCompanion(FertilizationSchedulesCompanion data) {
    return ScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, scheduledDate, note, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.scheduledDate == this.scheduledDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class FertilizationSchedulesCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> scheduledDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const FertilizationSchedulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FertilizationSchedulesCompanion.insert({
    required String id,
    required String userId,
    required DateTime scheduledDate,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       scheduledDate = Value(scheduledDate),
       createdAt = Value(createdAt);
  static Insertable<ScheduleRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? scheduledDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FertilizationSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? scheduledDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return FertilizationSchedulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FertilizationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChosenLocationsTable extends ChosenLocations
    with TableInfo<$ChosenLocationsTable, ChosenLocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChosenLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    name,
    region,
    country,
    latitude,
    longitude,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chosen_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChosenLocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ChosenLocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChosenLocationRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChosenLocationsTable createAlias(String alias) {
    return $ChosenLocationsTable(attachedDatabase, alias);
  }
}

class ChosenLocationRow extends DataClass
    implements Insertable<ChosenLocationRow> {
  /// `uid` do Firebase Auth.
  final String userId;
  final String name;

  /// Estado (`admin1` da geocodificação), quando o lugar tem.
  final String? region;
  final String? country;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  const ChosenLocationRow({
    required this.userId,
    required this.name,
    this.region,
    this.country,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChosenLocationsCompanion toCompanion(bool nullToAbsent) {
    return ChosenLocationsCompanion(
      userId: Value(userId),
      name: Value(name),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      latitude: Value(latitude),
      longitude: Value(longitude),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChosenLocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChosenLocationRow(
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      region: serializer.fromJson<String?>(json['region']),
      country: serializer.fromJson<String?>(json['country']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'region': serializer.toJson<String?>(region),
      'country': serializer.toJson<String?>(country),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChosenLocationRow copyWith({
    String? userId,
    String? name,
    Value<String?> region = const Value.absent(),
    Value<String?> country = const Value.absent(),
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
  }) => ChosenLocationRow(
    userId: userId ?? this.userId,
    name: name ?? this.name,
    region: region.present ? region.value : this.region,
    country: country.present ? country.value : this.country,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChosenLocationRow copyWithCompanion(ChosenLocationsCompanion data) {
    return ChosenLocationRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      region: data.region.present ? data.region.value : this.region,
      country: data.country.present ? data.country.value : this.country,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChosenLocationRow(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    name,
    region,
    country,
    latitude,
    longitude,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChosenLocationRow &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.region == this.region &&
          other.country == this.country &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.updatedAt == this.updatedAt);
}

class ChosenLocationsCompanion extends UpdateCompanion<ChosenLocationRow> {
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> region;
  final Value<String?> country;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChosenLocationsCompanion({
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChosenLocationsCompanion.insert({
    required String userId,
    required String name,
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    required double latitude,
    required double longitude,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       updatedAt = Value(updatedAt);
  static Insertable<ChosenLocationRow> custom({
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? region,
    Expression<String>? country,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (region != null) 'region': region,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChosenLocationsCompanion copyWith({
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? region,
    Value<String?>? country,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChosenLocationsCompanion(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      region: region ?? this.region,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChosenLocationsCompanion(')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedForecastsTable cachedForecasts = $CachedForecastsTable(
    this,
  );
  late final $FertilizationSchedulesTable fertilizationSchedules =
      $FertilizationSchedulesTable(this);
  late final $ChosenLocationsTable chosenLocations = $ChosenLocationsTable(
    this,
  );
  late final Index schedulesUserDate = Index(
    'schedules_user_date',
    'CREATE INDEX schedules_user_date ON fertilization_schedules (user_id, scheduled_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedForecasts,
    fertilizationSchedules,
    chosenLocations,
    schedulesUserDate,
  ];
}

typedef $$CachedForecastsTableCreateCompanionBuilder =
    CachedForecastsCompanion Function({
      required String locationKey,
      required String payloadJson,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedForecastsTableUpdateCompanionBuilder =
    CachedForecastsCompanion Function({
      Value<String> locationKey,
      Value<String> payloadJson,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedForecastsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedForecastsTable> {
  $$CachedForecastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get locationKey => $composableBuilder(
    column: $table.locationKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedForecastsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedForecastsTable> {
  $$CachedForecastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get locationKey => $composableBuilder(
    column: $table.locationKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedForecastsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedForecastsTable> {
  $$CachedForecastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get locationKey => $composableBuilder(
    column: $table.locationKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedForecastsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedForecastsTable,
          CachedForecast,
          $$CachedForecastsTableFilterComposer,
          $$CachedForecastsTableOrderingComposer,
          $$CachedForecastsTableAnnotationComposer,
          $$CachedForecastsTableCreateCompanionBuilder,
          $$CachedForecastsTableUpdateCompanionBuilder,
          (
            CachedForecast,
            BaseReferences<
              _$AppDatabase,
              $CachedForecastsTable,
              CachedForecast
            >,
          ),
          CachedForecast,
          PrefetchHooks Function()
        > {
  $$CachedForecastsTableTableManager(
    _$AppDatabase db,
    $CachedForecastsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedForecastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedForecastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedForecastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> locationKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedForecastsCompanion(
                locationKey: locationKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String locationKey,
                required String payloadJson,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedForecastsCompanion.insert(
                locationKey: locationKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedForecastsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedForecastsTable,
      CachedForecast,
      $$CachedForecastsTableFilterComposer,
      $$CachedForecastsTableOrderingComposer,
      $$CachedForecastsTableAnnotationComposer,
      $$CachedForecastsTableCreateCompanionBuilder,
      $$CachedForecastsTableUpdateCompanionBuilder,
      (
        CachedForecast,
        BaseReferences<_$AppDatabase, $CachedForecastsTable, CachedForecast>,
      ),
      CachedForecast,
      PrefetchHooks Function()
    >;
typedef $$FertilizationSchedulesTableCreateCompanionBuilder =
    FertilizationSchedulesCompanion Function({
      required String id,
      required String userId,
      required DateTime scheduledDate,
      Value<String?> note,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$FertilizationSchedulesTableUpdateCompanionBuilder =
    FertilizationSchedulesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> scheduledDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$FertilizationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $FertilizationSchedulesTable> {
  $$FertilizationSchedulesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FertilizationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $FertilizationSchedulesTable> {
  $$FertilizationSchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FertilizationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FertilizationSchedulesTable> {
  $$FertilizationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$FertilizationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FertilizationSchedulesTable,
          ScheduleRow,
          $$FertilizationSchedulesTableFilterComposer,
          $$FertilizationSchedulesTableOrderingComposer,
          $$FertilizationSchedulesTableAnnotationComposer,
          $$FertilizationSchedulesTableCreateCompanionBuilder,
          $$FertilizationSchedulesTableUpdateCompanionBuilder,
          (
            ScheduleRow,
            BaseReferences<
              _$AppDatabase,
              $FertilizationSchedulesTable,
              ScheduleRow
            >,
          ),
          ScheduleRow,
          PrefetchHooks Function()
        > {
  $$FertilizationSchedulesTableTableManager(
    _$AppDatabase db,
    $FertilizationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FertilizationSchedulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FertilizationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FertilizationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FertilizationSchedulesCompanion(
                id: id,
                userId: userId,
                scheduledDate: scheduledDate,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime scheduledDate,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FertilizationSchedulesCompanion.insert(
                id: id,
                userId: userId,
                scheduledDate: scheduledDate,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FertilizationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FertilizationSchedulesTable,
      ScheduleRow,
      $$FertilizationSchedulesTableFilterComposer,
      $$FertilizationSchedulesTableOrderingComposer,
      $$FertilizationSchedulesTableAnnotationComposer,
      $$FertilizationSchedulesTableCreateCompanionBuilder,
      $$FertilizationSchedulesTableUpdateCompanionBuilder,
      (
        ScheduleRow,
        BaseReferences<
          _$AppDatabase,
          $FertilizationSchedulesTable,
          ScheduleRow
        >,
      ),
      ScheduleRow,
      PrefetchHooks Function()
    >;
typedef $$ChosenLocationsTableCreateCompanionBuilder =
    ChosenLocationsCompanion Function({
      required String userId,
      required String name,
      Value<String?> region,
      Value<String?> country,
      required double latitude,
      required double longitude,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChosenLocationsTableUpdateCompanionBuilder =
    ChosenLocationsCompanion Function({
      Value<String> userId,
      Value<String> name,
      Value<String?> region,
      Value<String?> country,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChosenLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $ChosenLocationsTable> {
  $$ChosenLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChosenLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChosenLocationsTable> {
  $$ChosenLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChosenLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChosenLocationsTable> {
  $$ChosenLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChosenLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChosenLocationsTable,
          ChosenLocationRow,
          $$ChosenLocationsTableFilterComposer,
          $$ChosenLocationsTableOrderingComposer,
          $$ChosenLocationsTableAnnotationComposer,
          $$ChosenLocationsTableCreateCompanionBuilder,
          $$ChosenLocationsTableUpdateCompanionBuilder,
          (
            ChosenLocationRow,
            BaseReferences<
              _$AppDatabase,
              $ChosenLocationsTable,
              ChosenLocationRow
            >,
          ),
          ChosenLocationRow,
          PrefetchHooks Function()
        > {
  $$ChosenLocationsTableTableManager(
    _$AppDatabase db,
    $ChosenLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChosenLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChosenLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChosenLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChosenLocationsCompanion(
                userId: userId,
                name: name,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String name,
                Value<String?> region = const Value.absent(),
                Value<String?> country = const Value.absent(),
                required double latitude,
                required double longitude,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChosenLocationsCompanion.insert(
                userId: userId,
                name: name,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChosenLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChosenLocationsTable,
      ChosenLocationRow,
      $$ChosenLocationsTableFilterComposer,
      $$ChosenLocationsTableOrderingComposer,
      $$ChosenLocationsTableAnnotationComposer,
      $$ChosenLocationsTableCreateCompanionBuilder,
      $$ChosenLocationsTableUpdateCompanionBuilder,
      (
        ChosenLocationRow,
        BaseReferences<_$AppDatabase, $ChosenLocationsTable, ChosenLocationRow>,
      ),
      ChosenLocationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedForecastsTableTableManager get cachedForecasts =>
      $$CachedForecastsTableTableManager(_db, _db.cachedForecasts);
  $$FertilizationSchedulesTableTableManager get fertilizationSchedules =>
      $$FertilizationSchedulesTableTableManager(
        _db,
        _db.fertilizationSchedules,
      );
  $$ChosenLocationsTableTableManager get chosenLocations =>
      $$ChosenLocationsTableTableManager(_db, _db.chosenLocations);
}
