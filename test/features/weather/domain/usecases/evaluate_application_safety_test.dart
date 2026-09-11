import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluate = EvaluateApplicationSafety();
  const coordinates = Coordinates(latitude: 0, longitude: 0);

  WeatherForecast forecastWithHourlyRain(List<double> mmPerHour) {
    return WeatherForecast(
      coordinates: coordinates,
      daily: const [],
      fetchedAt: DateTime(2026, 9, 7),
      hourly: [
        for (final (i, mm) in mmPerHour.indexed)
          HourlyForecastPoint(
            time: DateTime(2026, 9, 7).add(Duration(hours: i)),
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

    final advice =
        evaluate(forecast).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.safe);
    expect(advice.estimatedLossPercent, isNull);
  });

  test('chuva moderada nas próximas 24h: caution', () {
    // 24 horas com 0.2mm cada = 4.8mm em 24h — acima do limiar de cautela
    // (3mm), abaixo do de perigo (10mm).
    final forecast = forecastWithHourlyRain(List.filled(48, 0.2));

    final advice =
        evaluate(forecast).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.caution);
    expect(advice.estimatedLossPercent, isNull);
  });

  test('chuva forte nas próximas 24h: danger, com prejuízo estimado', () {
    // 24h com 1mm cada = 24mm em 24h — bem acima do limiar de perigo.
    final forecast = forecastWithHourlyRain(List.filled(48, 1));

    final advice =
        evaluate(forecast).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.danger);
    expect(advice.rainNext24h, 24);
    expect(advice.estimatedLossPercent, isNotNull);
    expect(advice.estimatedLossPercent! > 20, isTrue);
  });

  test('perda estimada nunca passa de 80%, mesmo com chuva extrema', () {
    final forecast = forecastWithHourlyRain(List.filled(48, 20));

    final advice =
        evaluate(forecast).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.estimatedLossPercent, 80);
  });

  test('só olha as primeiras 24h para o nível — chuva só no dia seguinte '
      'não bloqueia hoje', () {
    final noRainToday = List<double>.filled(24, 0);
    final heavyRainTomorrow = List<double>.filled(24, 5);
    final forecast =
        forecastWithHourlyRain([...noRainToday, ...heavyRainTomorrow]);

    final advice =
        evaluate(forecast).getOrElse((_) => throw StateError('unexpected'));

    expect(advice.level, AdviceLevel.safe);
    expect(advice.rainNext48h, greaterThan(advice.rainNext24h));
  });
}
