import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:ecosafra/core/database/app_database.steps.dart';
import 'package:ecosafra/core/database/tables/cached_forecasts_table.dart';
import 'package:ecosafra/core/database/tables/fertilization_schedules_table.dart';

part 'app_database.g.dart';

/// Banco local do app — o equivalente do `@Database` do Room.
///
/// `@DriftDatabase(tables: [...])` faz o `build_runner` gerar `_$AppDatabase`
/// com um método por tabela (`select`, `into`, etc.), do mesmo jeito que o
/// annotation processor do Room gera a implementação de um `@Dao`.
@DriftDatabase(tables: [CachedForecasts, FertilizationSchedules])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Construtor usado só em teste, para trocar a conexão por um banco
  /// em memória (ver `test/core/database`).
  // O parâmetro do super construtor gerado se chama `e` (código gerado,
  // fora do nosso controle) — "executor" é bem mais claro pra quem lê.
  // ignore: matching_super_parameters
  AppDatabase.withExecutor(super.executor);

  /// Toda subida exige um passo em [migration] e um snapshot novo
  /// (`dart run drift_dev make-migrations`).
  ///
  /// - v1: cache da previsão (`cached_forecasts`).
  /// - v2: agenda de adubação (`fertilization_schedules`).
  @override
  int get schemaVersion => 2;

  /// Leva o banco já instalado nos aparelhos para a versão atual; uma
  /// instalação nova é criada direto na última versão. Os passos vêm de
  /// `app_database.steps.dart` (gerado) e são conferidos contra os snapshots
  /// em `test/drift/app_database/`.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.fertilizationSchedules);
        // `createTable` não cria os índices da tabela; sem esta linha, o
        // banco migrado ficaria diferente de uma instalação nova.
        await m.createIndex(schema.schedulesUserDate);
      },
    ),
  );
}

QueryExecutor _openConnection() => driftDatabase(name: 'ecosafra');
