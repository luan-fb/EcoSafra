import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/network/network_info.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/models/daily_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/hourly_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';
import 'package:ecosafra/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

class MockWeatherLocalDataSource extends Mock
    implements WeatherLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockWeatherRemoteDataSource remote;
  late MockWeatherLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late WeatherRepositoryImpl repository;

  const coordinates = Coordinates(latitude: -23.55, longitude: -46.63);

  final freshModel = WeatherForecastModel(
    hourly: [
      HourlyForecastPointModel(
        time: DateTime(2026, 9, 7, 12),
        precipitation: 0,
        precipitationProbability: 10,
        temperature: 24,
        relativeHumidity: 60,
        windSpeed: 8,
      ),
    ],
    daily: [
      DailyForecastPointModel(
        date: DateTime(2026, 9, 7),
        precipitationSum: 0,
        precipitationProbabilityMax: 10,
        temperatureMax: 28,
        temperatureMin: 18,
        windSpeedMax: 12,
        weatherCode: 1,
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(freshModel);
    registerFallbackValue(coordinates);
  });

  setUp(() {
    remote = MockWeatherRemoteDataSource();
    local = MockWeatherLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  group('refreshForecast', () {
    test('sem conexão: nem chega a chamar o remoto, devolve a falha na hora',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.refreshForecast(coordinates);

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.getForecast(any()));
    });

    test('com conexão: busca, cacheia e devolve os dados fresquinhos',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getForecast(coordinates))
          .thenAnswer((_) async => freshModel);
      when(() => local.cache(coordinates.cacheKey, freshModel))
          .thenAnswer((_) async {});

      final result = await repository.refreshForecast(coordinates);

      expect(result.isRight(), isTrue);
      verify(() => local.cache(coordinates.cacheKey, freshModel)).called(1);
    });

    test('com conexão mas o servidor falha: devolve a falha mapeada',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getForecast(coordinates))
          .thenThrow(const ServerException('fora do ar'));

      final result = await repository.refreshForecast(coordinates);

      expect(
        result.swap().getOrElse((_) => throw StateError('unexpected')),
        isA<ServerFailure>(),
      );
    });
  });

  group('getCachedForecast', () {
    test('sem nada salvo, devolve null', () async {
      when(() => local.getCached(coordinates.cacheKey))
          .thenAnswer((_) async => null);

      final result = await repository.getCachedForecast(coordinates);

      expect(result, isNull);
    });

    test('com cache salvo, devolve marcado como stale', () async {
      final fetchedAt = DateTime(2026, 9, 7, 8);
      when(() => local.getCached(coordinates.cacheKey)).thenAnswer(
        (_) async => (model: freshModel, fetchedAt: fetchedAt),
      );

      final result = await repository.getCachedForecast(coordinates);

      expect(result, isNotNull);
      expect(result!.isStale, isTrue);
      expect(result.fetchedAt, fetchedAt);
    });
  });
}
