import 'package:ecosafra/features/weather/domain/entities/place.dart';

abstract interface class PlaceSearchRemoteDataSource {
  /// Lugares cujo nome combina com [query]; lista vazia quando nenhum.
  Future<List<Place>> search(String query);
}
