// dart format width=80
// Gerado por `dart run drift_dev make-migrations` e adaptado à mão: o comando
// só cria este arquivo quando ele não existe, então as adaptações ficam.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Cada teste parte de um banco idêntico ao snapshot de uma versão antiga
/// (`drift_schemas/app_database/`), roda a migração real do `AppDatabase` e
/// compara o resultado com o snapshot da versão nova.
void main() {
  // Cada teste abre mais de uma instância de banco em cima da mesma conexão
  // (versão antiga, depois a atual); o aviso do drift para isso é esperado.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            // Adaptado: o gerado chama `AppDatabase(...)`, mas o construtor
            // padrão abre o arquivo do app; em teste usamos `withExecutor`.
            final db = AppDatabase.withExecutor(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  group('migração v1 → v2', () {
    // Cache de previsão como ele existe hoje nos aparelhos com a v1.
    // `fetched_at` é INTEGER em segundos desde a época (formato padrão do
    // drift para `DateTime`), por isso o `int` nas classes do snapshot.
    final fetchedAt = DateTime(2026, 9, 7, 10);
    final fetchedAtSeconds = fetchedAt.millisecondsSinceEpoch ~/ 1000;

    test('preserva as linhas de cached_forecasts e cria a tabela da agenda '
        'aceitando inserts', () async {
      final oldCachedForecastsData = <v1.CachedForecastsData>[
        v1.CachedForecastsData(
          locationKey: '-23.55,-46.63',
          payloadJson: '{"hourly":[],"daily":[]}',
          fetchedAt: fetchedAtSeconds,
        ),
        v1.CachedForecastsData(
          locationKey: '-15.79,-47.88',
          payloadJson: '{"v":2}',
          fetchedAt: fetchedAtSeconds + 3600,
        ),
      ];
      final expectedNewCachedForecastsData = <v2.CachedForecastsData>[
        v2.CachedForecastsData(
          locationKey: '-23.55,-46.63',
          payloadJson: '{"hourly":[],"daily":[]}',
          fetchedAt: fetchedAtSeconds,
        ),
        v2.CachedForecastsData(
          locationKey: '-15.79,-47.88',
          payloadJson: '{"v":2}',
          fetchedAt: fetchedAtSeconds + 3600,
        ),
      ];
      final newSchedule = v2.FertilizationSchedulesData(
        id: 'b3f1c0de-0000-4000-8000-000000000001',
        userId: 'uid-1',
        scheduledDate: fetchedAtSeconds,
        note: 'Ureia no talhão 3',
        createdAt: fetchedAtSeconds,
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        // Adaptado: `AppDatabase.new` do gerado vira `withExecutor`.
        openTestedDatabase: AppDatabase.withExecutor,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.cachedForecasts, oldCachedForecastsData);
        },
        validateItems: (newDb) async {
          final rows = await (newDb.select(
            newDb.cachedForecasts,
          )..orderBy([(t) => OrderingTerm.asc(t.fetchedAt)])).get();
          expect(rows, expectedNewCachedForecastsData);

          expect(
            await newDb.select(newDb.fertilizationSchedules).get(),
            isEmpty,
          );
          await newDb.into(newDb.fertilizationSchedules).insert(newSchedule);
          expect(
            await newDb.select(newDb.fertilizationSchedules).get(),
            [newSchedule],
          );
        },
      );
    });

    test(
      'o AppDatabase migrado lê o cache antigo e grava agendamentos',
      () async {
        final schema = await verifier.schemaAt(1);

        final oldDb = v1.DatabaseAtV1(schema.newConnection());
        await oldDb
            .into(oldDb.cachedForecasts)
            .insert(
              v1.CachedForecastsData(
                locationKey: '-23.55,-46.63',
                payloadJson: '{"hourly":[],"daily":[]}',
                fetchedAt: fetchedAtSeconds,
              ),
            );
        await oldDb.close();

        // Mesmo arquivo, agora aberto pelo app atualizado: a primeira consulta
        // dispara o `onUpgrade` da v1 para a v2.
        final db = AppDatabase.withExecutor(schema.newConnection());
        addTearDown(db.close);

        final cached = await db.select(db.cachedForecasts).getSingle();
        expect(cached.locationKey, '-23.55,-46.63');
        expect(cached.payloadJson, '{"hourly":[],"daily":[]}');
        expect(cached.fetchedAt, fetchedAt);

        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 2);

        final index = await db
            .customSelect(
              "SELECT sql FROM sqlite_master WHERE type = 'index' "
              "AND name = 'schedules_user_date'",
            )
            .getSingleOrNull();
        expect(index, isNotNull);
        expect(
          index!.read<String>('sql'),
          contains('fertilization_schedules (user_id, scheduled_date)'),
        );

        await db
            .into(db.fertilizationSchedules)
            .insert(
              FertilizationSchedulesCompanion.insert(
                id: 'b3f1c0de-0000-4000-8000-000000000001',
                userId: 'uid-1',
                scheduledDate: DateTime(2026, 9, 25),
                note: const Value('Ureia no talhão 3'),
                createdAt: fetchedAt,
              ),
            );

        final schedules = await db.select(db.fertilizationSchedules).get();
        expect(schedules, [
          ScheduleRow(
            id: 'b3f1c0de-0000-4000-8000-000000000001',
            userId: 'uid-1',
            scheduledDate: DateTime(2026, 9, 25),
            note: 'Ureia no talhão 3',
            createdAt: fetchedAt,
          ),
        ]);
      },
    );
  });
}
