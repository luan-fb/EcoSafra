import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PlaceSearchRepository {
  /// `Right([])` quando a busca não encontra nenhum lugar.
  Future<Either<Failure, List<Place>>> search(String query);
}
