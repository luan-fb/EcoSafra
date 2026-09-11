import 'package:drift/native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // `NativeDatabase.memory()` é o `Room.inMemoryDatabaseBuilder()` daqui:
    // um banco de verdade, rodando de verdade, que só existe enquanto o
    // teste roda — sem tocar disco, sem sujar o dispositivo.
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('cacheia e lê de volta pela mesma chave de localização', () async {
    const locationKey = '-23.55,-46.63';

    await database.into(database.cachedForecasts).insertOnConflictUpdate(
          CachedForecastsCompanion.insert(
            locationKey: locationKey,
            payloadJson: '{"hourly":[],"daily":[]}',
            fetchedAt: DateTime(2026, 9, 7, 10),
          ),
        );

    final row = await (database.select(database.cachedForecasts)
          ..where((t) => t.locationKey.equals(locationKey)))
        .getSingleOrNull();

    expect(row, isNotNull);
    expect(row!.payloadJson, '{"hourly":[],"daily":[]}');
    expect(row.fetchedAt, DateTime(2026, 9, 7, 10));
  });

  test('salvar de novo na mesma chave substitui a linha, não duplica',
      () async {
    const locationKey = '-23.55,-46.63';

    for (final payload in ['{"v":1}', '{"v":2}']) {
      await database.into(database.cachedForecasts).insertOnConflictUpdate(
            CachedForecastsCompanion.insert(
              locationKey: locationKey,
              payloadJson: payload,
              fetchedAt: DateTime(2026, 9, 7),
            ),
          );
    }

    final rows = await database.select(database.cachedForecasts).get();

    expect(rows, hasLength(1));
    expect(rows.single.payloadJson, '{"v":2}');
  });

  test('sem cache para a chave, devolve nulo', () async {
    final row = await (database.select(database.cachedForecasts)
          ..where((t) => t.locationKey.equals('nunca-buscado')))
        .getSingleOrNull();

    expect(row, isNull);
  });
}
