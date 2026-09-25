import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/features/schedule/data/datasources/schedule_local_data_source.dart';

/// Toda escrita filtra por `id` e `userId` para um usuário não alterar
/// agendamento de outro no mesmo aparelho; "não existe" e "é de outra conta"
/// dão o mesmo erro.
class DriftScheduleLocalDataSource implements ScheduleLocalDataSource {
  const DriftScheduleLocalDataSource(this._database);

  final AppDatabase _database;

  static const _notFoundMessage = 'Agendamento não encontrado.';
  static const _writeFailedMessage = 'Não foi possível salvar o agendamento.';

  $FertilizationSchedulesTable get _table => _database.fertilizationSchedules;

  @override
  Stream<List<ScheduleRow>> watchByUser(String userId) {
    // O drift grava data e hora em segundos: dois agendamentos criados no
    // mesmo segundo empatam em `createdAt`, e o `id` deixa a ordem estável.
    final query = _database.select(_table)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.scheduledDate),
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return query.watch();
  }

  @override
  Future<void> insert(ScheduleRow row) =>
      _write(() => _database.into(_table).insert(row));

  @override
  Future<void> updateDateAndNote({
    required String id,
    required String userId,
    required DateTime scheduledDate,
    required String? note,
  }) => _writeExisting(
    () => (_database.update(_table)..where(_owned(id, userId))).write(
      FertilizationSchedulesCompanion(
        scheduledDate: Value(scheduledDate),
        note: Value(note),
      ),
    ),
  );

  @override
  Future<void> setCompletedAt({
    required String id,
    required String userId,
    required DateTime? completedAt,
  }) => _writeExisting(
    () => (_database.update(_table)..where(_owned(id, userId))).write(
      FertilizationSchedulesCompanion(completedAt: Value(completedAt)),
    ),
  );

  @override
  Future<void> delete({required String id, required String userId}) =>
      _writeExisting(
        () => (_database.delete(_table)..where(_owned(id, userId))).go(),
      );

  Expression<bool> Function($FertilizationSchedulesTable) _owned(
    String id,
    String userId,
  ) =>
      (t) => t.id.equals(id) & t.userId.equals(userId);

  Future<void> _writeExisting(Future<int> Function() action) async {
    final affectedRows = await _write(action);
    if (affectedRows == 0) throw const CacheException(_notFoundMessage);
  }

  Future<int> _write(Future<int> Function() action) async {
    try {
      return await action();
    } on SqliteException {
      throw const CacheException(_writeFailedMessage);
    } on DriftRemoteException catch (e) {
      // No app o SQLite roda em outro isolate e o erro chega embrulhado.
      if (e.remoteCause is SqliteException) {
        throw const CacheException(_writeFailedMessage);
      }
      rethrow;
    }
  }
}
