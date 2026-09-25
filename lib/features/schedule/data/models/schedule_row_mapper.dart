import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';

/// O `userId` fica de fora: o domínio só enxerga agendamentos do usuário
/// logado.
extension ScheduleRowMapper on ScheduleRow {
  FertilizationSchedule toEntity() => FertilizationSchedule(
    id: id,
    scheduledDate: scheduledDate,
    createdAt: createdAt,
    note: note,
    completedAt: completedAt,
  );
}
