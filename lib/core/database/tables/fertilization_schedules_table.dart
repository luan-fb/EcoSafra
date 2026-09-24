import 'package:drift/drift.dart';

/// Agendamentos de adubação, um por linha, sempre de um usuário.
///
/// `ScheduleRow` evita colisão com a entidade de domínio
/// `FertilizationSchedule`. O índice atende a única consulta da agenda:
/// filtrar por usuário e ordenar por data.
@DataClassName('ScheduleRow')
@TableIndex(name: 'schedules_user_date', columns: {#userId, #scheduledDate})
class FertilizationSchedules extends Table {
  /// UUID v4 gerado no aparelho: o id existe antes de chegar ao banco e não
  /// colide se um dia houver sincronização entre aparelhos.
  TextColumn get id => text()();

  /// `uid` do Firebase Auth. Toda leitura e escrita filtra por ele.
  TextColumn get userId => text()();

  /// Sempre à meia-noite local; só o dia importa.
  DateTimeColumn get scheduledDate => dateTime()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// `null` enquanto a aplicação não foi marcada como feita.
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
