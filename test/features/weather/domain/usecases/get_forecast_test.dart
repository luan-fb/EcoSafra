import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/repositories/weather_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository repository;
  late GetForecast getForecast;

  const coordinates = Coordinates(latitude: -23.55, longitude: -46.63);
  final cachedForecast = WeatherForecast(
    coordinates: coordinates,
    hourly: const [],
    daily: const [],
    fetchedAt: DateTime(2026, 9, 7, 8),
    isStale: true,
  );
  final freshForecast = WeatherForecast(
    coordinates: coordinates,
    hourly: const [],
    daily: const [],
    fetchedAt: DateTime(2026, 9, 7, 12),
  );

  setUp(() {
    repository = MockWeatherRepository();
    getForecast = GetForecast(repository);
  });

  test(
    'com cache e rede OK: emite o cache na hora, depois o fresco '
    '(o usuário nunca fica olhando pra tela vazia esperando a rede)',
    () async {
      when(() => repository.getCachedForecast(coordinates))
          .thenAnswer((_) async => cachedForecast);
      when(() => repository.refreshForecast(coordinates))
          .thenAnswer((_) async => Right(freshForecast));

      final emissions = await getForecast(coordinates).toList();

      expect(emissions, [
        Right<Failure, WeatherForecast>(cachedForecast),
        Right<Failure, WeatherForecast>(freshForecast),
      ]);
    },
  );

  test(
    'com cache mas sem rede (o cenário do talhão sem sinal): só emite o '
    'cache — a tela continua mostrando os dados velhos, não vira uma tela '
    'de erro por causa de uma falha que já era esperada',
    () async {
      when(() => repository.getCachedForecast(coordinates))
          .thenAnswer((_) async => cachedForecast);
      when(() => repository.refreshForecast(coordinates))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final emissions = await getForecast(coordinates).toList();

      expect(emissions, [Right<Failure, WeatherForecast>(cachedForecast)]);
    },
  );

  test(
    'sem cache e sem rede (primeira vez, sem sinal): emite a falha — não '
    'há nada bom pra mostrar',
    () async {
      when(() => repository.getCachedForecast(coordinates))
          .thenAnswer((_) async => null);
      when(() => repository.refreshForecast(coordinates))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final emissions = await getForecast(coordinates).toList();

      expect(emissions, [const Left<Failure, WeatherForecast>(NetworkFailure())]);
    },
  );

  test('sem cache mas com rede: emite só o fresco', () async {
    when(() => repository.getCachedForecast(coordinates))
        .thenAnswer((_) async => null);
    when(() => repository.refreshForecast(coordinates))
        .thenAnswer((_) async => Right(freshForecast));

    final emissions = await getForecast(coordinates).toList();

    expect(emissions, [Right<Failure, WeatherForecast>(freshForecast)]);
  });
}
