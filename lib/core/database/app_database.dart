import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:ecosafra/core/database/tables/cached_forecasts_table.dart';

part 'app_database.g.dart';

/// Banco local do app — o equivalente do `@Database` do Room.
///
/// `@DriftDatabase(tables: [...])` faz o `build_runner` gerar `_$AppDatabase`
/// com um método por tabela (`select`, `into`, etc.), do mesmo jeito que o
/// annotation processor do Room gera a implementação de um `@Dao`.
@DriftDatabase(tables: [CachedForecasts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Construtor usado só em teste, para trocar a conexão por um banco
  /// em memória (ver `test/core/database`).
  // O parâmetro do super construtor gerado se chama `e` (código gerado,
  // fora do nosso controle) — "executor" é bem mais claro pra quem lê.
  // ignore: matching_super_parameters
  AppDatabase.withExecutor(super.executor);

  /// Sobe a cada mudança de schema — o equivalente de bump na versão do
  /// Room. Como ainda não lançamos nada, começa em 1; o dia que uma tabela
  /// mudar de formato, `onUpgrade` entra aqui.
  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() => driftDatabase(name: 'ecosafra');
