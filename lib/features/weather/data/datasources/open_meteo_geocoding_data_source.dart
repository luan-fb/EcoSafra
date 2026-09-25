import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/features/weather/data/datasources/place_search_remote_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';

/// Busca por nome na geocodificação da Open-Meteo, com o mesmo `Dio` da
/// previsão: a URL absoluta sobrepõe o `baseUrl` dele.
class OpenMeteoGeocodingDataSource implements PlaceSearchRemoteDataSource {
  const OpenMeteoGeocodingDataSource(this._dio);

  final Dio _dio;

  static const maxResults = 5;

  @override
  Future<List<Place>> search(String query) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingSearch}',
        queryParameters: {
          'name': query,
          'count': maxResults,
          'language': 'pt',
          'format': 'json',
        },
      );
    } on DioException catch (e) {
      // O `ErrorInterceptor` guarda a exceção do app em `error`.
      final error = e.error;
      if (error is AppException) throw error;
      throw const NetworkException();
    }

    // Sem nenhum lugar, a API omite `results` em vez de mandar lista vazia.
    final results = response.data?['results'] as List?;
    if (results == null) return const [];

    try {
      return [
        for (final result in results.cast<Map<String, dynamic>>())
          Place(
            name: result['name']! as String,
            region: result['admin1'] as String?,
            country: result['country'] as String?,
            coordinates: Coordinates(
              latitude: (result['latitude']! as num).toDouble(),
              longitude: (result['longitude']! as num).toDouble(),
            ),
          ),
      ];
    }
    // Campo ausente ou de outro tipo é o contrato externo mudando.
    // ignore: avoid_catching_errors
    on TypeError {
      throw const ServerException(
        'A busca de lugares devolveu dados em um formato inesperado.',
      );
    }
  }
}
