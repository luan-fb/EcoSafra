import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  const coordinates = Coordinates(latitude: 0, longitude: 0);

  // Ponto de partida dos testes que não mexem com a janela: meia-noite de
  // 7/9, mesma hora do primeiro ponto de `forecastWithHourlyRain`. Com o
  // relógio fixo nela, `hourlyFrom` inclui a lista inteira, e o
  // comportamento é o mesmo de antes da T2.
  final midnight = DateTime(2026, 9, 7);
  final evaluate = EvaluateApplicationSafety(clock: Clock.fixed(midnight));

  WeatherForecast forecastWithHourlyRain(
    List<double> mmPerHour, {
    DateTime? startingAt,
  }) {
    final start = startingAt ?? midnight;
    return WeatherForecast(
      coordinates: coordinates,
      daily: const [],
      fetchedAt: midnight,
      hourly: [
        for (final (i, mm) in mmPerHour.indexed)
          HourlyForecastPoint(
            time: start.add(Duration(hours: i)),
            precipitation: mm,
            precipitationProbability: 50,
            temperature: 20,
            relativeHumidity: 70,
            windSpeed: 10,
          ),
      ],
    );
  }

  test('sem chuva prevista: safe', () {
    final forecast = forecastWithHourlyRain(List.filled(48, 0));

    final advice = evaluate(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.safe);
    expect(advice.estimatedLossPercent, isNull);
  });

  test('chuva moderada nas próximas 24h: caution', () {
    // 24 horas com 0.2mm cada = 4.8mm em 24h — acima do limiar de cautela
    // (3mm), abaixo do de perigo (10mm).
    final forecast = forecastWithHourlyRain(List.filled(48, 0.2));

    final advice = evaluate(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.caution);
    expect(advice.estimatedLossPercent, isNull);
  });

  test('chuva forte nas próximas 24h: danger, com prejuízo estimado', () {
    // 24h com 1mm cada = 24mm em 24h — bem acima do limiar de perigo.
    final forecast = forecastWithHourlyRain(List.filled(48, 1));

    final advice = evaluate(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.danger);
    expect(advice.rainNext24h, 24);
    expect(advice.estimatedLossPercent, isNotNull);
    expect(advice.estimatedLossPercent! > 20, isTrue);
  });

  test('perda estimada nunca passa de 80%, mesmo com chuva extrema', () {
    final forecast = forecastWithHourlyRain(List.filled(48, 20));

    final advice = evaluate(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.estimatedLossPercent, 80);
  });

  test('só olha as primeiras 24h para o nível — chuva só no dia seguinte '
      'não bloqueia hoje', () {
    final noRainToday = List<double>.filled(24, 0);
    final heavyRainTomorrow = List<double>.filled(24, 5);
    final forecast = forecastWithHourlyRain([
      ...noRainToday,
      ...heavyRainTomorrow,
    ]);

    final advice = evaluate(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.safe);
    expect(advice.rainNext48h, greaterThan(advice.rainNext24h));
  });

  test('WIN-01: às 15h, chuva forte só entre 0h e 6h de hoje não conta — '
      'safe', () {
    // 24 pontos (0h a 23h de 7/9): 7mm em cada uma das 7 primeiras horas
    // (0h-6h, bem acima do limiar de perigo se contasse) e nada depois.
    final mmPerHour = [
      for (var h = 0; h < 24; h++) (h <= 6) ? 7.0 : 0.0,
    ];
    final forecast = forecastWithHourlyRain(mmPerHour);
    final at15h = EvaluateApplicationSafety(
      clock: Clock.fixed(DateTime(2026, 9, 7, 15)),
    );

    final advice = at15h(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.safe);
    expect(advice.rainNext24h, 0);
  });

  test(
    'WIN-02: às 15h, chuva forte entre 20h e 23h de hoje conta — danger',
    () {
      // Mesma previsão do dia, mas a chuva forte cai à noite (20h-23h), que
      // ainda está dentro da janela de 24h a partir das 15h.
      final mmPerHour = [
        for (var h = 0; h < 24; h++) (h >= 20) ? 5.0 : 0.0,
      ];
      final forecast = forecastWithHourlyRain(mmPerHour);
      final at15h = EvaluateApplicationSafety(
        clock: Clock.fixed(DateTime(2026, 9, 7, 15)),
      );

      final advice = at15h(
        forecast,
      ).getOrElse((_) => throw StateError('unexpected'));

      expect(advice.level, AdviceLevel.danger);
      expect(advice.rainNext24h, 20);
    },
  );

  test('WIN-07: às 23h, a janela de 24h inclui as horas do dia seguinte', () {
    // 1h de hoje (23h) + 24h do dia seguinte, com chuva forte só depois da
    // virada: se a janela não cruzasse o dia, ficaria em 1 ponto só e o
    // resultado seria `safe`.
    final mmPerHour = [
      0.0, // 7/9 23h
      for (var h = 0; h < 24; h++) (h == 5) ? 15.0 : 0.0, // 8/9 0h-23h
    ];
    final forecast = forecastWithHourlyRain(
      mmPerHour,
      startingAt: DateTime(2026, 9, 7, 23),
    );
    final at23h = EvaluateApplicationSafety(
      clock: Clock.fixed(DateTime(2026, 9, 7, 23)),
    );

    final advice = at23h(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.danger);
    expect(advice.rainNext24h, 15);
  });

  test('WIN-03: restam só 10 pontos a partir de agora — soma só os 10', () {
    final forecast = forecastWithHourlyRain(List.filled(10, 2));
    final at10Points = EvaluateApplicationSafety(clock: Clock.fixed(midnight));

    final advice = at10Points(
      forecast,
    ).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.rainNext24h, 20);
    expect(advice.rainNext48h, 20);
  });

  test('WIN-04: nenhum ponto da hora atual em diante — CacheFailure com a '
      'mensagem exata', () {
    // A previsão salva só cobre até 9h; o relógio está em 15h.
    final forecast = forecastWithHourlyRain(List.filled(10, 0));
    final at15h = EvaluateApplicationSafety(
      clock: Clock.fixed(DateTime(2026, 9, 7, 15)),
    );

    final result = at15h(forecast);

    expect(
      result,
      const Left<Failure, FertilizerAdvice>(
        CacheFailure(
          'A previsão salva não cobre mais as próximas horas. '
          'Conecte-se à internet para atualizar.',
        ),
      ),
    );
  });
}
