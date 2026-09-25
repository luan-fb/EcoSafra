import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';

/// Diferente dos outros: `describe` não falha, sempre devolve uma descrição.
/// Não usa `Either` como os outros casos de uso porque não há erro a tratar.
class GetLocationDescription {
  const GetLocationDescription(this._repository);

  final LocationRepository _repository;

  Future<LocationDescription> call(Coordinates params) =>
      _repository.describe(params);
}
