import 'dart:convert';

import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';

/// Cache local via drift — o equivalente do `@Dao` do Room.
///
/// Guarda o JSON pronto (ver o comentário em `CachedForecasts`), então a
/// query é sempre "uma linha por chave" — não existe SQL específico de
/// previsão do tempo aqui, só leitura/escrita de uma tabela genérica.
class DriftWeatherLocalDataSource implements WeatherLocalDataSource {
  const DriftWeatherLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<CachedWeather?> getCached(String locationKey) async {
    final row = await (_database.select(_database.cachedForecasts)
          ..where((t) => t.locationKey.equals(locationKey)))
        .getSingleOrNull();
    if (row == null) return null;

    try {
      final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return (
        model: WeatherForecastModel.fromJson(json),
        fetchedAt: row.fetchedAt,
      );
    } on FormatException {
      // Cache corrompido (ex.: o formato do JSON mudou numa versão antiga
      // do app) — trata como se não houvesse cache, em vez de derrubar a
      // busca inteira por causa de um dado velho.
      return null;
    }
  }

  @override
  Future<void> cache(String locationKey, WeatherForecastModel model) {
    return _database.into(_database.cachedForecasts).insertOnConflictUpdate(
          CachedForecastsCompanion.insert(
            locationKey: locationKey,
            payloadJson: jsonEncode(model.toJson()),
            fetchedAt: DateTime.now(),
          ),
        );
  }
}
