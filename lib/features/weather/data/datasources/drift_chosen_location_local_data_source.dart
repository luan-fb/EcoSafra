import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/features/weather/data/datasources/chosen_location_local_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';

class DriftChosenLocationLocalDataSource
    implements ChosenLocationLocalDataSource {
  const DriftChosenLocationLocalDataSource(this._database, this._clock);

  final AppDatabase _database;
  final Clock _clock;

  $ChosenLocationsTable get _table => _database.chosenLocations;

  @override
  Future<Place?> get(String userId) async {
    final row = await (_database.select(
      _table,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();
    if (row == null) return null;

    return Place(
      name: row.name,
      region: row.region,
      country: row.country,
      coordinates: Coordinates(
        latitude: row.latitude,
        longitude: row.longitude,
      ),
    );
  }

  @override
  Future<void> save(String userId, Place place) async {
    await _database
        .into(_table)
        .insertOnConflictUpdate(
          // Companion com `Value` explícito: a partir da data class, o drift
          // omite as colunas nulas do upsert e a região antiga sobreviveria.
          ChosenLocationsCompanion.insert(
            userId: userId,
            name: place.name,
            region: Value(place.region),
            country: Value(place.country),
            latitude: place.coordinates.latitude,
            longitude: place.coordinates.longitude,
            updatedAt: _clock.now(),
          ),
        );
  }

  @override
  Future<void> clear(String userId) async {
    await (_database.delete(
      _table,
    )..where((t) => t.userId.equals(userId))).go();
  }
}
