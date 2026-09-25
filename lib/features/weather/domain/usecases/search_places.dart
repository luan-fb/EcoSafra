import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/place_search_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchPlaces implements UseCase<List<Place>, String> {
  const SearchPlaces(this._repository);

  final PlaceSearchRepository _repository;

  @override
  Future<Either<Failure, List<Place>>> call(String params) =>
      _repository.search(params);
}
