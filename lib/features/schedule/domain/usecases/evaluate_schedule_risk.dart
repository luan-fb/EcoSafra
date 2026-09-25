import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

final class EvaluateScheduleRiskParams extends Equatable {
  const EvaluateScheduleRiskParams({
    required this.schedule,
    required this.forecast,
  });

  final FertilizationSchedule schedule;
  final WeatherForecast forecast;

  @override
  List<Object?> get props => [schedule, forecast];
}

/// Usa o mesmo limiar de chuva do painel (`EvaluateApplicationSafety`)
/// para que painel e Agenda nunca discordem sobre o mesmo dia.
class EvaluateScheduleRisk
    implements SyncUseCase<ScheduleRiskLevel, EvaluateScheduleRiskParams> {
  const EvaluateScheduleRisk();

  @override
  Either<Failure, ScheduleRiskLevel> call(EvaluateScheduleRiskParams params) {
    final match = params.forecast.dayOf(params.schedule.scheduledDate);
    if (match == null) return const Right(ScheduleRiskLevel.unknown);

    final isRisky =
        match.precipitationSum > EvaluateApplicationSafety.dangerThresholdMm;
    return Right(isRisky ? ScheduleRiskLevel.atRisk : ScheduleRiskLevel.ok);
  }
}
