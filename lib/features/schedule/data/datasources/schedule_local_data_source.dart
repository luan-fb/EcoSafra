import 'package:ecosafra/core/database/app_database.dart';

/// Escritas lançam `CacheException` quando falham ou quando o `id` não
/// existe para aquele `userId`.
abstract interface class ScheduleLocalDataSource {
  /// Ordenados por `scheduledDate`, `createdAt` e `id`; reemite a cada
  /// escrita na tabela.
  Stream<List<ScheduleRow>> watchByUser(String userId);

  Future<void> insert(ScheduleRow row);

  Future<void> updateDateAndNote({
    required String id,
    required String userId,
    required DateTime scheduledDate,
    required String? note,
  });

  Future<void> setCompletedAt({
    required String id,
    required String userId,
    required DateTime? completedAt,
  });

  Future<void> delete({required String id, required String userId});
}
