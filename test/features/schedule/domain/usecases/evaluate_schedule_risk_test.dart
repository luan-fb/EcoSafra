import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluate = EvaluateScheduleRisk();
  const coordinates = Coordinates(latitude: 0, longitude: 0);

  FertilizationSchedule scheduleFor(DateTime date) => FertilizationSchedule(
    id: 's1',
    scheduledDate: date,
    createdAt: DateTime(2026, 9, 1),
  );

  WeatherForecast forecastWithDailyRain(Map<DateTime, double> rainByDate) {
    return WeatherForecast(
      coordinates: coordinates,
      hourly: const [],
      fetchedAt: DateTime(2026, 9, 7),
      daily: [
        for (final entry in rainByDate.entries)
          DailyForecastPoint(
            date: entry.key,
            precipitationSum: entry.value,
            precipitationProbabilityMax: 50,
            temperatureMax: 28,
            temperatureMin: 18,
            windSpeedMax: 12,
            weatherCode: 61,
          ),
      ],
    );
  }

  test('dia agendado sem chuva de risco: ok', () {
    final date = DateTime(2026, 9, 10);
    final forecast = forecastWithDailyRain({date: 2});

    final result = evaluate(
      EvaluateScheduleRiskParams(
        schedule: scheduleFor(date),
        forecast: forecast,
      ),
    );

    expect(
      result.getOrElse((_) => throw StateError('unexpected')),
      ScheduleRiskLevel.ok,
    );
  });

  test('previsão mudou e mostra chuva forte no dia agendado: atRisk', () {
    final date = DateTime(2026, 9, 10);
    final forecast = forecastWithDailyRain({date: 15});

    final result = evaluate(
      EvaluateScheduleRiskParams(
        schedule: scheduleFor(date),
        forecast: forecast,
      ),
    );

    expect(
      result.getOrElse((_) => throw StateError('unexpected')),
      ScheduleRiskLevel.atRisk,
    );
  });

  test('a hora da data agendada é ignorada na comparação', () {
    final scheduledAt = DateTime(2026, 9, 10, 14, 32);
    final forecastDay = DateTime(2026, 9, 10);
    final forecast = forecastWithDailyRain({forecastDay: 2});

    final result = evaluate(
      EvaluateScheduleRiskParams(
        schedule: scheduleFor(scheduledAt),
        forecast: forecast,
      ),
    );

    expect(
      result.getOrElse((_) => throw StateError('unexpected')),
      ScheduleRiskLevel.ok,
    );
  });

  test('dia agendado fora da janela de previsão: unknown', () {
    final scheduledFarAway = DateTime(2026, 12, 25);
    final forecast = forecastWithDailyRain({DateTime(2026, 9, 10): 2});

    final result = evaluate(
      EvaluateScheduleRiskParams(
        schedule: scheduleFor(scheduledFarAway),
        forecast: forecast,
      ),
    );

    expect(
      result.getOrElse((_) => throw StateError('unexpected')),
      ScheduleRiskLevel.unknown,
    );
  });
}
