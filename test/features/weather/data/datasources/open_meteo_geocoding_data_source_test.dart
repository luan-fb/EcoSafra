import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/features/weather/data/datasources/open_meteo_geocoding_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

const _searchUrl = 'https://geocoding-api.open-meteo.com/v1/search';

void main() {
  late MockDio dio;
  late OpenMeteoGeocodingDataSource dataSource;

  void stubResponse(Map<String, dynamic> data) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: data,
        requestOptions: RequestOptions(path: _searchUrl),
      ),
    );
  }

  setUp(() {
    dio = MockDio();
    dataSource = OpenMeteoGeocodingDataSource(dio);
  });

  test('pede até 5 lugares em português na URL absoluta de busca', () async {
    stubResponse({});

    await dataSource.search('Cuiabá');

    verify(
      () => dio.get<Map<String, dynamic>>(
        _searchUrl,
        queryParameters: {
          'name': 'Cuiabá',
          'count': 5,
          'language': 'pt',
          'format': 'json',
        },
      ),
    ).called(1);
  });

  test('mapeia name, admin1, country, latitude e longitude', () async {
    stubResponse({
      'results': [
        {
          'id': 3465038,
          'name': 'Cuiabá',
          'latitude': -15.59611,
          'longitude': -56.09667,
          'admin1': 'Mato Grosso',
          'country': 'Brasil',
        },
        {
          'name': 'Sorriso',
          'latitude': -12,
          'longitude': -55,
          'admin1': 'Mato Grosso',
          'country': 'Brasil',
        },
      ],
    });

    final places = await dataSource.search('Cuiabá');

    expect(places, const [
      Place(
        name: 'Cuiabá',
        region: 'Mato Grosso',
        country: 'Brasil',
        coordinates: Coordinates(latitude: -15.59611, longitude: -56.09667),
      ),
      Place(
        name: 'Sorriso',
        region: 'Mato Grosso',
        country: 'Brasil',
        coordinates: Coordinates(latitude: -12, longitude: -55),
      ),
    ]);
  });

  test('resposta sem results: lista vazia', () async {
    stubResponse({'generationtime_ms': 0.5});

    expect(await dataSource.search('xyzxyz'), isEmpty);
  });

  test('lugar sem admin1: região nula', () async {
    stubResponse({
      'results': [
        {
          'name': 'Mônaco',
          'latitude': 43.73,
          'longitude': 7.42,
          'country': 'Mônaco',
        },
      ],
    });

    final places = await dataSource.search('Mônaco');

    expect(places.single.region, isNull);
    expect(places.single.country, 'Mônaco');
  });

  test(
    'falha do Dio: relança a exceção que o ErrorInterceptor anexou',
    () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: _searchUrl),
          type: DioExceptionType.connectionError,
          error: const NetworkException(),
        ),
      );

      await expectLater(
        dataSource.search('Cuiabá'),
        throwsA(isA<NetworkException>()),
      );
    },
  );

  test('resultado com campo obrigatório ausente: ServerException', () async {
    stubResponse({
      'results': [
        {'latitude': 1, 'longitude': 2},
      ],
    });

    await expectLater(
      dataSource.search('Cuiabá'),
      throwsA(isA<ServerException>()),
    );
  });
}
