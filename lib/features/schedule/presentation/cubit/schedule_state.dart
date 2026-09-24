import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:equatable/equatable.dart';

enum ScheduleStatus { loading, loaded, error }

/// Um agendamento pronto para a lista: concluídos e datas passadas ficam
/// sempre com risco `unknown`, porque a tela não exibe risco para eles.
final class ScheduleItem extends Equatable {
  const ScheduleItem({
    required this.schedule,
    required this.risk,
    required this.isPastDue,
  });

  final FertilizationSchedule schedule;
  final ScheduleRiskLevel risk;

  /// Não concluído com data anterior a hoje.
  final bool isPastDue;

  @override
  List<Object?> get props => [schedule, risk, isPastDue];
}

final class ScheduleState extends Equatable {
  const ScheduleState._({
    required this.status,
    required this.window,
    this.upcoming = const [],
    this.completed = const [],
    this.failure,
  });

  const ScheduleState.loading(SchedulingWindow window)
    : this._(status: ScheduleStatus.loading, window: window);

  const ScheduleState.loaded({
    required List<ScheduleItem> upcoming,
    required List<ScheduleItem> completed,
    required SchedulingWindow window,
  }) : this._(
         status: ScheduleStatus.loaded,
         upcoming: upcoming,
         completed: completed,
         window: window,
       );

  const ScheduleState.error(Failure failure, SchedulingWindow window)
    : this._(status: ScheduleStatus.error, failure: failure, window: window);

  final ScheduleStatus status;

  /// Não concluídos, por data crescente.
  final List<ScheduleItem> upcoming;

  /// Concluídos, por data decrescente.
  final List<ScheduleItem> completed;

  /// Datas aceitas pelo seletor ao criar e editar.
  final SchedulingWindow window;

  /// Em `error`, o motivo da tela de erro; nos outros status, a falha de
  /// uma ação (snackbar), que não derruba a lista.
  final Failure? failure;

  ScheduleState withActionFailure(Failure? failure) => ScheduleState._(
    status: status,
    upcoming: upcoming,
    completed: completed,
    window: window,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, upcoming, completed, window, failure];
}
