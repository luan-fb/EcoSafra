import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const coordinates = Coordinates(latitude: 0, longitude: 0);

  group('WeatherForecast.dayOf', () {
    test(
      'dia presente consultado com hora diferente devolve o ponto exato',
      () {
        final forecastDate = DateTime(2026, 9, 10);
        final queryDate = DateTime(2026, 9, 10, 14, 32);
        final daily = [
          DailyForecastPoint(
            date: forecastDate,
            precipitationSum: 2.5,
            precipitationProbabilityMax: 50,
            temperatureMax: 28,
            temperatureMin: 18,
            windSpeedMax: 12,
            weatherCode: 61,
          ),
        ];
        final forecast = WeatherForecast(
          coordinates: coordinates,
          hourly: const [],
          daily: daily,
          fetchedAt: DateTime(2026, 9, 7),
        );

        final result = forecast.dayOf(queryDate);

        expect(result, isNotNull);
        expect(result?.precipitationSum, 2.5);
        expect(result?.date, forecastDate);
      },
    );

    test('dia fora da previsão devolve null', () {
      final daily = [
        DailyForecastPoint(
          date: DateTime(2026, 9, 10),
          precipitationSum: 2.5,
          precipitationProbabilityMax: 50,
          temperatureMax: 28,
          temperatureMin: 18,
          windSpeedMax: 12,
          weatherCode: 61,
        ),
      ];
      final forecast = WeatherForecast(
        coordinates: coordinates,
        hourly: const [],
        daily: daily,
        fetchedAt: DateTime(2026, 9, 7),
      );

      final result = forecast.dayOf(DateTime(2026, 12, 25));

      expect(result, isNull);
    });

    test('daily vazio devolve null', () {
      final forecast = WeatherForecast(
        coordinates: coordinates,
        hourly: const [],
        daily: const [],
        fetchedAt: DateTime(2026, 9, 7),
      );

      final result = forecast.dayOf(DateTime(2026, 9, 10));

      expect(result, isNull);
    });
  });
}
