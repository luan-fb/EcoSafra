import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluate = EvaluateScheduleAlert(EvaluateScheduleRisk());

  const heavyRain = EvaluateApplicationSafety.dangerThresholdMm + 5;
  const lightRain = EvaluateApplicationSafety.dangerThresholdMm - 5;

  // Hora diferente de meia-noite: "hoje" vem do relógio, não de `dateOnly`.
  final now = DateTime(2026, 9, 23, 14, 30);
  final today = DateTime(2026, 9, 23);
  final tomorrow = DateTime(2026, 9, 24);
  final yesterday = DateTime(2026, 9, 22);

  var nextId = 0;
  FertilizationSchedule schedule(DateTime date, {bool completed = false}) =>
      FertilizationSchedule(
        id: 's${nextId++}',
        scheduledDate: date,
        createdAt: DateTime(2026, 9, 20),
        completedAt: completed ? DateTime(2026, 9, 21) : null,
      );

  WeatherForecast forecast(Map<DateTime, double> rainByDate) => WeatherForecast(
    coordinates: const Coordinates(latitude: 0, longitude: 0),
    hourly: const [],
    fetchedAt: DateTime(2026, 9, 23, 6),
    daily: [
      for (final entry in rainByDate.entries)
        DailyForecastPoint(
          date: entry.key,
          precipitationSum: entry.value,
          precipitationProbabilityMax: 80,
          temperatureMax: 28,
          temperatureMin: 18,
          windSpeedMax: 12,
          weatherCode: 61,
        ),
    ],
  );

  /// Previsão de 7 dias a partir de hoje, sem chuva de risco, exceto nos
  /// dias em [heavyOn].
  WeatherForecast weekForecast({Set<DateTime> heavyOn = const {}}) => forecast({
    for (var i = 0; i < WeatherForecast.coverageDays; i++)
      DateTime(2026, 9, 23 + i): heavyOn.contains(DateTime(2026, 9, 23 + i))
          ? heavyRain
          : lightRain,
  });

  ScheduleAlert? run(
    List<FertilizationSchedule> schedules, {
    WeatherForecast? forecast,
    DateTime? at,
  }) => evaluate(
    EvaluateScheduleAlertParams(
      schedules: schedules,
      forecast: forecast,
      today: at ?? now,
    ),
  ).getOrElse((_) => throw StateError('unexpected failure'));

  final inThreeDays = DateTime(2026, 9, 26);
  final inFourDays = DateTime(2026, 9, 27);

  test('AGD-15: dois agendamentos em risco geram alerta com contagem 2', () {
    final result = run(
      [schedule(inThreeDays), schedule(inFourDays)],
      forecast: weekForecast(heavyOn: {inThreeDays, inFourDays}),
    );

    expect(result, const ScheduleRiskAlert(2));
  });

  test('AGD-16: só um agendamento para hoje gera lembrete de hoje', () {
    final result = run([schedule(today)], forecast: weekForecast());

    expect(result, const ScheduleTodayReminder());
  });

  test('AGD-17: só um agendamento para amanhã gera lembrete de amanhã', () {
    final result = run([schedule(tomorrow)], forecast: weekForecast());

    expect(result, const ScheduleTomorrowReminder());
  });

  test('AGD-17: amanhã é o dia seguinte no calendário na virada do mês', () {
    final result = run(
      [schedule(DateTime(2026, 10))],
      at: DateTime(2026, 9, 30, 23, 59),
    );

    expect(result, const ScheduleTomorrowReminder());
  });

  test('AGD-16/17: hoje e amanhã juntos geram só o lembrete de hoje', () {
    final result = run(
      [schedule(tomorrow), schedule(today)],
      forecast: weekForecast(),
    );

    expect(result, const ScheduleTodayReminder());
  });

  test('AGD-18: sem risco nem agendamento para hoje ou amanhã, sem aviso', () {
    final result = run([schedule(inThreeDays)], forecast: weekForecast());

    expect(result, isNull);
  });

  test('AGD-18: sem agendamentos, sem aviso', () {
    expect(run(const [], forecast: weekForecast()), isNull);
  });

  test('AGD-20: agendamento concluído em risco é ignorado', () {
    final result = run(
      [schedule(inThreeDays, completed: true)],
      forecast: weekForecast(heavyOn: {inThreeDays}),
    );

    expect(result, isNull);
  });

  test('AGD-20: agendamento concluído para hoje não gera lembrete', () {
    final result = run(
      [schedule(today, completed: true)],
      forecast: weekForecast(),
    );

    expect(result, isNull);
  });

  test('AGD-20: agendamento de ontem é ignorado, mesmo com chuva forte', () {
    final result = run(
      [schedule(yesterday)],
      forecast: forecast({yesterday: heavyRain, today: lightRain}),
    );

    expect(result, isNull);
  });

  test('edge: agendamento de hoje em risco gera risco, não lembrete', () {
    final result = run(
      [schedule(today)],
      forecast: weekForecast(heavyOn: {today}),
    );

    expect(result, const ScheduleRiskAlert(1));
  });

  test('edge: um em risco e outro amanhã sem risco geram risco com 1', () {
    final result = run(
      [schedule(inThreeDays), schedule(tomorrow)],
      forecast: weekForecast(heavyOn: {inThreeDays}),
    );

    expect(result, const ScheduleRiskAlert(1));
  });

  test('edge: dois agendamentos no mesmo dia em risco contam 2', () {
    final result = run(
      [schedule(inThreeDays), schedule(inThreeDays)],
      forecast: weekForecast(heavyOn: {inThreeDays}),
    );

    expect(result, const ScheduleRiskAlert(2));
  });

  test('edge: sem previsão, agendamento para amanhã gera lembrete', () {
    final result = run([schedule(tomorrow)]);

    expect(result, const ScheduleTomorrowReminder());
  });

  test('edge: dia fora da janela da previsão não conta como risco', () {
    final result = run(
      [schedule(tomorrow)],
      forecast: forecast({today: heavyRain}),
    );

    expect(result, const ScheduleTomorrowReminder());
  });
}
