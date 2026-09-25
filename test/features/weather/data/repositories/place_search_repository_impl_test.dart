import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/network/interceptors/error_interceptor.dart';
import 'package:ecosafra/features/weather/data/datasources/open_meteo_geocoding_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/place_search_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/repositories/place_search_repository_impl.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockPlaceSearchRemoteDataSource extends Mock
    implements PlaceSearchRemoteDataSource {}

/// Adaptador que falha como um aparelho sem rede.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException.connectionError(
    requestOptions: options,
    reason: 'offline',
  );

  @override
  void close({bool force = false}) {}
}

const _cuiaba = Place(
  name: 'Cuiabá',
  region: 'Mato Grosso',
  country: 'Brasil',
  coordinates: Coordinates(latitude: -15.6, longitude: -56.1),
);

void main() {
  late MockPlaceSearchRemoteDataSource remote;
  late PlaceSearchRepositoryImpl repository;

  setUp(() {
    remote = MockPlaceSearchRemoteDataSource();
    repository = PlaceSearchRepositoryImpl(remote);
  });

  test('sucesso: repassa a lista de lugares', () async {
    when(() => remote.search('Cuiabá')).thenAnswer((_) async => [_cuiaba]);

    final result = await repository.search('Cuiabá');

    expect(result.getRight().toNullable(), [_cuiaba]);
  });

  test('nenhum lugar: Right com lista vazia', () async {
    when(() => remote.search('xyz')).thenAnswer((_) async => []);

    final result = await repository.search('xyz');

    expect(result.getRight().toNullable(), isEmpty);
  });

  test('NetworkException do data source: Left(NetworkFailure)', () async {
    when(() => remote.search(any())).thenThrow(const NetworkException());

    final result = await repository.search('Cuiabá');

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });

  test(
    'sem rede, com o Dio e o ErrorInterceptor reais: NetworkFailure',
    () async {
      final dio = Dio()
        ..httpClientAdapter = _OfflineAdapter()
        ..interceptors.add(ErrorInterceptor());
      final repository = PlaceSearchRepositoryImpl(
        OpenMeteoGeocodingDataSource(dio),
      );

      final result = await repository.search('Cuiabá');

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    },
  );

  test('ServerException do data source: Left(ServerFailure)', () async {
    when(() => remote.search(any())).thenThrow(
      const ServerException('O serviço de clima está fora do ar.'),
    );

    final result = await repository.search('Cuiabá');

    expect(
      result,
      const Left<Failure, List<Place>>(
        ServerFailure('O serviço de clima está fora do ar.'),
      ),
    );
  });
}
