import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:equatable/equatable.dart';

enum ScheduleStatus { loading, loaded, error }

/// Um agendamento pronto para a lista: concluídos e datas passadas ficam
/// sempre com risco `unknown`, porque a tela não exibe risco para eles.
final class ScheduleItem extends Equatable {
  const ScheduleItem({
    required this.schedule,
    required this.risk,
    required this.isPastDue,
    this.expectedRainMm,
  });

  final FertilizationSchedule schedule;
  final ScheduleRiskLevel risk;

  /// Não concluído com data anterior a hoje.
  final bool isPastDue;

  /// Chuva prevista para o dia, em mm. `null` para concluídos, datas
  /// passadas e dias fora da previsão (ou antes de ela chegar).
  final double? expectedRainMm;

  /// O mesmo item com outro agendamento, mantendo risco e chuva.
  ScheduleItem withSchedule(FertilizationSchedule schedule) => ScheduleItem(
    schedule: schedule,
    risk: risk,
    isPastDue: isPastDue,
    expectedRainMm: expectedRainMm,
  );

  @override
  List<Object?> get props => [schedule, risk, isPastDue, expectedRainMm];
}

final class ScheduleState extends Equatable {
  const ScheduleState._({
    required this.status,
    this.upcoming = const [],
    this.completed = const [],
    this.failure,
  });

  const ScheduleState.loading() : this._(status: ScheduleStatus.loading);

  const ScheduleState.loaded({
    required List<ScheduleItem> upcoming,
    required List<ScheduleItem> completed,
  }) : this._(
         status: ScheduleStatus.loaded,
         upcoming: upcoming,
         completed: completed,
       );

  const ScheduleState.error(Failure failure)
    : this._(status: ScheduleStatus.error, failure: failure);

  final ScheduleStatus status;

  /// Não concluídos, por data crescente.
  final List<ScheduleItem> upcoming;

  /// Concluídos, por data decrescente.
  final List<ScheduleItem> completed;

  /// Em `error`, o motivo da tela de erro; nos outros status, a falha de
  /// uma ação (snackbar), que não derruba a lista.
  final Failure? failure;

  ScheduleState withActionFailure(Failure? failure) => ScheduleState._(
    status: status,
    upcoming: upcoming,
    completed: completed,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, upcoming, completed, failure];
}
