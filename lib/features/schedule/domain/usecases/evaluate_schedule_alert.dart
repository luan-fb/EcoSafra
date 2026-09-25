import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

final class EvaluateScheduleAlertParams extends Equatable {
  const EvaluateScheduleAlertParams({
    required this.schedules,
    required this.forecast,
    required this.today,
  });

  final List<FertilizationSchedule> schedules;

  /// `null` enquanto o painel não tem previsão: não há risco a avaliar, mas
  /// os lembretes continuam valendo.
  final WeatherForecast? forecast;

  final DateTime today;

  @override
  List<Object?> get props => [schedules, forecast, today];
}

/// Risco tem prioridade sobre lembrete: um agendamento de hoje em risco
/// gera só o alerta de risco.
class EvaluateScheduleAlert
    implements SyncUseCase<ScheduleAlert?, EvaluateScheduleAlertParams> {
  const EvaluateScheduleAlert(this._evaluateRisk);

  final EvaluateScheduleRisk _evaluateRisk;

  @override
  Either<Failure, ScheduleAlert?> call(EvaluateScheduleAlertParams params) {
    final today = params.today.dateOnly;
    // Dia seguinte por calendário: somar `Duration(days: 1)` erra na virada
    // de horário de verão.
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    final pending = params.schedules
        .where(
          (s) => !s.isCompleted && !s.scheduledDate.dateOnly.isBefore(today),
        )
        .toList();

    final forecast = params.forecast;
    if (forecast != null) {
      final riskCount = pending.where((s) => _isAtRisk(s, forecast)).length;
      if (riskCount > 0) return Right(ScheduleRiskAlert(riskCount));
    }

    if (pending.any((s) => s.scheduledDate.isSameDay(today))) {
      return const Right(ScheduleTodayReminder());
    }
    if (pending.any((s) => s.scheduledDate.isSameDay(tomorrow))) {
      return const Right(ScheduleTomorrowReminder());
    }
    return const Right(null);
  }

  bool _isAtRisk(FertilizationSchedule schedule, WeatherForecast forecast) {
    final level = _evaluateRisk(
      EvaluateScheduleRiskParams(schedule: schedule, forecast: forecast),
    ).getOrElse((_) => ScheduleRiskLevel.unknown);
    return level == ScheduleRiskLevel.atRisk;
  }
}
