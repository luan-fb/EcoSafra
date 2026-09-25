import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/data/datasources/place_search_remote_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/place_search_repository.dart';
import 'package:fpdart/fpdart.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl(this._remote);

  final PlaceSearchRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Place>>> search(String query) async {
    try {
      return Right(await _remote.search(query));
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }
}
