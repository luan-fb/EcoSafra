import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/network/interceptors/error_interceptor.dart';
import 'package:ecosafra/core/network/network_info.dart';
import 'package:ecosafra/features/weather/data/datasources/open_meteo_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/models/daily_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/hourly_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';
import 'package:ecosafra/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

class MockWeatherLocalDataSource extends Mock
    implements WeatherLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

/// Adaptador que falha como uma requisição que estourou o timeout.
class _TimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException(
    requestOptions: options,
    type: DioExceptionType.connectionTimeout,
  );

  @override
  void close({bool force = false}) {}
}

/// Adaptador que responde como o servidor fora do ar (HTTP 500).
class _ServerErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    500,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

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
    test(
      'sem conexão: nem chega a chamar o remoto, devolve a falha na hora',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.refreshForecast(coordinates);

        expect(result.isLeft(), isTrue);
        verifyNever(() => remote.getForecast(any()));
      },
    );

    test(
      'com conexão: busca, cacheia e devolve os dados fresquinhos',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remote.getForecast(coordinates),
        ).thenAnswer((_) async => freshModel);
        when(
          () => local.cache(coordinates.cacheKey, freshModel),
        ).thenAnswer((_) async {});

        final result = await repository.refreshForecast(coordinates);

        expect(result.isRight(), isTrue);
        verify(() => local.cache(coordinates.cacheKey, freshModel)).called(1);
      },
    );

    test('com conexão mas o servidor falha: devolve a falha mapeada', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.getForecast(coordinates),
      ).thenThrow(const ServerException('fora do ar'));

      final result = await repository.refreshForecast(coordinates);

      expect(
        result.swap().getOrElse((_) => throw StateError('unexpected')),
        isA<ServerFailure>(),
      );
    });

    // ROB-02: gravar o cache é um efeito colateral da atualização, não uma
    // condição para ela: se a gravação falhar, a previsão nova (que já
    // chegou da rede) ainda deve aparecer.
    test(
      'a gravação do cache falha: devolve a previsão nova mesmo assim',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remote.getForecast(coordinates),
        ).thenAnswer((_) async => freshModel);
        when(
          () => local.cache(coordinates.cacheKey, freshModel),
        ).thenThrow(Exception('disco cheio'));

        final result = await repository.refreshForecast(coordinates);

        final entity = result.getOrElse((_) => throw StateError('unexpected'));
        expect(entity.coordinates, coordinates);
        expect(
          entity.hourly,
          freshModel.hourly.map((point) => point.toEntity()).toList(),
        );
        expect(
          entity.daily,
          freshModel.daily.map((point) => point.toEntity()).toList(),
        );
      },
    );

    // ROB-01: resposta incompleta é o `ServerException` que o data source
    // lança antes de devolver o modelo — a falha não deve apagar o cache
    // anterior, e a única forma de garantir isso é o repositório nunca
    // chegar a chamar `_local.cache` nesse caminho.
    test(
      'com conexão mas o servidor falha: não grava (nem apaga) o cache',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.getForecast(coordinates)).thenThrow(
          const ServerException(
            'A previsão veio incompleta. Tente novamente mais tarde.',
          ),
        );

        await repository.refreshForecast(coordinates);

        verifyNever(() => local.cache(any(), any()));
      },
    );

    // ROB-05: com o Dio e o ErrorInterceptor reais, o data source precisa
    // desembrulhar o DioException — senão ele escapa do `on AppException`
    // do repositório e o teste com mocks acima não pegaria isso.
    test(
      'timeout, com o Dio e o ErrorInterceptor reais: Left(NetworkFailure)',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        final dio = Dio()
          ..httpClientAdapter = _TimeoutAdapter()
          ..interceptors.add(ErrorInterceptor());
        final repository = WeatherRepositoryImpl(
          remote: OpenMeteoRemoteDataSource(dio),
          local: local,
          networkInfo: networkInfo,
        );

        final result = await repository.refreshForecast(coordinates);

        expect(
          result,
          const Left<Failure, WeatherForecast>(
            NetworkFailure('O servidor demorou demais para responder.'),
          ),
        );
      },
    );

    test(
      'HTTP 500, com o Dio e o ErrorInterceptor reais: Left(ServerFailure) '
      'com a mensagem do interceptor',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        final dio = Dio()
          ..httpClientAdapter = _ServerErrorAdapter()
          ..interceptors.add(ErrorInterceptor());
        final repository = WeatherRepositoryImpl(
          remote: OpenMeteoRemoteDataSource(dio),
          local: local,
          networkInfo: networkInfo,
        );

        final result = await repository.refreshForecast(coordinates);

        expect(
          result,
          const Left<Failure, WeatherForecast>(
            ServerFailure('O serviço de clima está fora do ar.'),
          ),
        );
      },
    );
  });

  group('GetForecast com falha real de rede', () {
    // ROB-05: a falha do Dio precisa chegar como Failure ao repositório
    // para o GetForecast poder aplicar a regra de cache desatualizado —
    // sem o desembrulho, o DioException subiria cru e quebraria o stream.
    test(
      'timeout, com cache salvo: emite o cache e depois o mesmo marcado '
      'como desatualizado, em vez de erro no stream',
      () async {
        final fetchedAt = DateTime(2026, 9, 7, 8);
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => local.getCached(coordinates.cacheKey)).thenAnswer(
          (_) async => (model: freshModel, fetchedAt: fetchedAt),
        );
        final dio = Dio()
          ..httpClientAdapter = _TimeoutAdapter()
          ..interceptors.add(ErrorInterceptor());
        final repository = WeatherRepositoryImpl(
          remote: OpenMeteoRemoteDataSource(dio),
          local: local,
          networkInfo: networkInfo,
        );
        final getForecast = GetForecast(repository);
        final cachedEntity = freshModel.toEntity(
          coordinates: coordinates,
          fetchedAt: fetchedAt,
        );

        final emissions = await getForecast(coordinates).toList();

        expect(emissions, [
          Right<Failure, WeatherForecast>(cachedEntity),
          Right<Failure, WeatherForecast>(cachedEntity.asStale()),
        ]);
      },
    );
  });

  group('getCachedForecast', () {
    test('sem nada salvo, devolve null', () async {
      when(
        () => local.getCached(coordinates.cacheKey),
      ).thenAnswer((_) async => null);

      final result = await repository.getCachedForecast(coordinates);

      expect(result, isNull);
    });

    test('com cache salvo, devolve sem a marca de desatualizado', () async {
      final fetchedAt = DateTime(2026, 9, 7, 8);
      when(() => local.getCached(coordinates.cacheKey)).thenAnswer(
        (_) async => (model: freshModel, fetchedAt: fetchedAt),
      );

      final result = await repository.getCachedForecast(coordinates);

      expect(result, isNotNull);
      expect(result!.isStale, isFalse);
      expect(result.fetchedAt, fetchedAt);
    });
  });
}
