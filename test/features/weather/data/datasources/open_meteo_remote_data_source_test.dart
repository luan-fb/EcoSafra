import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/features/weather/data/datasources/open_meteo_remote_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late OpenMeteoRemoteDataSource dataSource;

  const coordinates = Coordinates(latitude: -23.55, longitude: -46.63);

  Map<String, dynamic> hourlyJson(List<String> times) => {
    'time': times,
    'precipitation': [for (final _ in times) 0],
    'precipitation_probability': [for (final _ in times) 0],
    'temperature_2m': [for (final _ in times) 20],
    'relative_humidity_2m': [for (final _ in times) 60],
    'wind_speed_10m': [for (final _ in times) 10],
  };

  Map<String, dynamic> dailyJson(List<String> dates) => {
    'time': dates,
    'precipitation_sum': [for (final _ in dates) 0],
    'precipitation_probability_max': [for (final _ in dates) 0],
    'temperature_2m_max': [for (final _ in dates) 28],
    'temperature_2m_min': [for (final _ in dates) 18],
    'wind_speed_10m_max': [for (final _ in dates) 10],
    'weather_code': [for (final _ in dates) 0],
  };

  void stubResponse(Map<String, dynamic> data) {
    when(
      () => dio.get<Map<String, dynamic>>(
        ApiConstants.forecast,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: data,
        requestOptions: RequestOptions(path: ApiConstants.forecast),
      ),
    );
  }

  setUp(() {
    dio = MockDio();
    dataSource = OpenMeteoRemoteDataSource(dio);
  });

  test('hourly vazio: ServerException com a mensagem da spec', () async {
    stubResponse({
      'hourly': hourlyJson([]),
      'daily': dailyJson(['2026-09-07']),
    });

    await expectLater(
      dataSource.getForecast(coordinates),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'A previsão veio incompleta. Tente novamente mais tarde.',
        ),
      ),
    );
  });

  test('daily vazio: ServerException com a mensagem da spec', () async {
    stubResponse({
      'hourly': hourlyJson(['2026-09-07T12:00']),
      'daily': dailyJson([]),
    });

    await expectLater(
      dataSource.getForecast(coordinates),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'A previsão veio incompleta. Tente novamente mais tarde.',
        ),
      ),
    );
  });

  test('hourly e daily com dados: devolve o modelo sem lançar', () async {
    stubResponse({
      'hourly': hourlyJson(['2026-09-07T12:00']),
      'daily': dailyJson(['2026-09-07']),
    });

    final model = await dataSource.getForecast(coordinates);

    expect(model.hourly, hasLength(1));
    expect(model.daily, hasLength(1));
  });

  test(
    'falha do Dio: relança a exceção que o ErrorInterceptor anexou',
    () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          ApiConstants.forecast,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.forecast),
          type: DioExceptionType.connectionTimeout,
          error: const NetworkException(
            'O servidor demorou demais para responder.',
          ),
        ),
      );

      await expectLater(
        dataSource.getForecast(coordinates),
        throwsA(isA<NetworkException>()),
      );
    },
  );

  test(
    'falha do Dio sem AppException anexada: NetworkException genérica',
    () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          ApiConstants.forecast,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.forecast),
          type: DioExceptionType.unknown,
        ),
      );

      await expectLater(
        dataSource.getForecast(coordinates),
        throwsA(isA<NetworkException>()),
      );
    },
  );
}
